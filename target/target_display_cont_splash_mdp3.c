#include <arch/defines.h>
#include <bits.h>
#include <debug.h>
#include <reg.h>
#include <string.h>
#include <target.h>

#include <dev/fbcon.h>
#include <mdp3.h>
#include <platform.h>
#include <platform/iomap.h>
#include <platform/timer.h>

static struct fbcon_config fb = {
	.bpp    = 24,
	.format = FB_FORMAT_RGB888,
};

extern int check_aboot_addr_range_overlap(uintptr_t start, uint32_t size);
extern int check_ddr_addr_range_bound(uintptr_t start, uint32_t size);

static void mdp3_cmd_mode_flush(void)
{
	writel(0x00000001, MDP_DMA_P_START);
	mdelay(10);
}

static int mdp3_read_config(struct fbcon_config *fb)
{
	uint32_t stride, out_size, size;

	fb->base = (void*) readl(MDP_DMA_P_BUF_ADDR);
	if (!fb->base) {
		dprintf(CRITICAL, "Continuous splash does not appear to be enabled\n");
		return -1;
	}

	stride = readl(MDP_DMA_P_BUF_Y_STRIDE);
	out_size = readl(MDP_DMA_P_SIZE);

	dprintf(SPEW, "Continuous splash detected: base: %p, stride: %d, "
		"output: %dx%d\n",
		fb->base, stride,
		out_size & 0xffff, out_size >> 16
	);

	fb->stride = stride / (fb->bpp/8);
	fb->width = fb->stride;
	fb->height = out_size >> 16;

	fb->update_start = mdp3_cmd_mode_flush; // Hardcode cmd mode for now

	// Validate parameters
	if (fb->stride == 0 || fb->width == 0 || fb->height == 0) {
		dprintf(CRITICAL, "Invalid parameters for continuous splash\n");
		return -1;
	}

	// Validate memory region
	size = stride * fb->height;
	if (check_aboot_addr_range_overlap((uintptr_t) fb->base, size)
			|| check_ddr_addr_range_bound((uintptr_t) fb->base, size)) {
		dprintf(CRITICAL, "Invalid memory region for continuous splash"
			" (overlap or out of bounds)\n");
		return -1;
	}

	// Add MMU mappings if necessary
	fb->base = (void*) platform_map_fb((addr_t) fb->base, size);
	if (!fb->base) {
		dprintf(CRITICAL, "Failed to map continuous splash memory region\n");
		return -1;
	}

	return 0;
}

void target_display_init(const char *panel_name)
{
	dprintf(SPEW, "Panel: %s\n", panel_name);

	if (mdp3_read_config(&fb))
		return;

	// Setup framebuffer
	fbcon_setup(&fb);
}
