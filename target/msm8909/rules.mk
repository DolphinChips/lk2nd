LOCAL_DIR := $(GET_LOCAL_DIR)

INCLUDES += -I$(LOCAL_DIR)/include -I$(LK_TOP_DIR)/platform/msm_shared
INCLUDES += -I$(LK_TOP_DIR)/dev/gcdb/display -I$(LK_TOP_DIR)/dev/gcdb/display/include

PLATFORM := msm8909

MEMBASE := 0x8F600000 # SDRAM
ifeq ($(VERIFIED_BOOT),1)
  MEMSIZE := 0x00200000 # 2MB
else
  MEMSIZE := 0x00100000 # 1MB
endif

BASE_ADDR        := 0x80000000
SCRATCH_ADDR     := 0x90100000
SCRATCH_REGION1_SIZE  := 0x0FC00000 #252MB

SCRATCH_REGION_256 := 0x90A00000
SCRATCH_REGION_1_256 := 0x82000000
SCRATCH_REGION_2_256 := 0x83C00000
SCRATCH_REGION_3_256 := 0x88000000
SCRATCH_REGION_4_256 := 0x8F700000
SCRATCH_REGION_1_256_SIZE := 0x01200000 #18MB
SCRATCH_REGION_2_256_SIZE := 0x04000000 #64MB
SCRATCH_REGION_3_256_SIZE := 0x07600000 #118MB
SCRATCH_REGION_4_256_SIZE := 0x00900000 #9MB

SCRATCH_REGION2  := 0x83800000
ifeq ($(VERIFIED_BOOT),1)
  SCRATCH_REGION2_SIZE  := 0x4000000 #64MB
else
  SCRATCH_REGION2_SIZE  := 0x4200000 #66MB
endif

DEFINES += DISPLAY_SPLASH_SCREEN=1
DEFINES += DISPLAY_TYPE_MIPI=1
DEFINES += DISPLAY_TYPE_DSI6G=1

MODULES += \
	dev/keys \
	dev/vib \
	lib/ptable \
	dev/gcdb/display \
	dev/pmic/pm8x41 \
	lib/libfdt

DEFINES += \
	MEMSIZE=$(MEMSIZE) \
	MEMBASE=$(MEMBASE) \
	BASE_ADDR=$(BASE_ADDR) \
	SCRATCH_ADDR=$(SCRATCH_ADDR) \
	SCRATCH_REGION2=$(SCRATCH_REGION2) \
	SCRATCH_REGION_256=$(SCRATCH_REGION_256) \
	SCRATCH_REGION_1_256=$(SCRATCH_REGION_1_256) \
	SCRATCH_REGION_2_256=$(SCRATCH_REGION_2_256) \
	SCRATCH_REGION_3_256=$(SCRATCH_REGION_3_256) \
	SCRATCH_REGION_4_256=$(SCRATCH_REGION_4_256) \
	SCRATCH_REGION_1_256_SIZE=$(SCRATCH_REGION_1_256_SIZE) \
	SCRATCH_REGION_2_256_SIZE=$(SCRATCH_REGION_2_256_SIZE) \
	SCRATCH_REGION_3_256_SIZE=$(SCRATCH_REGION_3_256_SIZE) \
	SCRATCH_REGION_4_256_SIZE=$(SCRATCH_REGION_4_256_SIZE) \
	SCRATCH_REGION2_SIZE=$(SCRATCH_REGION2_SIZE) \
	SCRATCH_REGION1_SIZE=$(SCRATCH_REGION1_SIZE)


OBJS += \
	$(LOCAL_DIR)/init.o \
	$(LOCAL_DIR)/meminfo.o \
	$(LOCAL_DIR)/oem_panel.o

ifneq ($(DISPLAY_USE_CONTINUOUS_SPLASH),1)
OBJS += \
	$(LOCAL_DIR)/target_display.o
endif

ifeq ($(ENABLE_SMD_SUPPORT),1)
OBJS += \
    $(LOCAL_DIR)/regulator.o
endif
