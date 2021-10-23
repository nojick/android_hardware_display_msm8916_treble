LOCAL_PATH := $(call my-dir)
include $(LOCAL_PATH)/../common.mk
include $(CLEAR_VARS)

LOCAL_MODULE                  := hwcomposer.$(TARGET_BOARD_PLATFORM)
LOCAL_MODULE_RELATIVE_PATH    := hw
LOCAL_VENDOR_MODULE           := true
LOCAL_MODULE_TAGS             := optional
LOCAL_HEADER_LIBRARIES	      := libui_v_headers libhardware_legacy_headers
LOCAL_C_INCLUDES              := $(common_includes) $(kernel_includes) \
                                 frameworks/native/libs/arect/include

ifeq ($(strip $(TARGET_USES_QCOM_DISPLAY_PP)),true)
LOCAL_C_INCLUDES              += $(TARGET_OUT_HEADERS)/qdcm/inc \
                                 $(TARGET_OUT_HEADERS)/common/inc \
                                 $(TARGET_OUT_HEADERS)/pp/inc
endif

LOCAL_SHARED_LIBRARIES        := $(common_libs) libEGL liboverlay \
                                 libhdmi libqdutils \
                                 libdl libmemalloc libqservice libsync \
                                 libbinder libdisplayconfig \
                                 libbfqio_vendor

LOCAL_CFLAGS                  := $(common_flags) -DLOG_TAG=\"qdhwcomposer\" -Wno-absolute-value \
                                 -Wno-float-conversion -Wno-unused-parameter -Wno-shorten-64-to-32

#Enable Dynamic FPS if PHASE_OFFSET is not set
ifeq ($(VSYNC_EVENT_PHASE_OFFSET_NS),)
    LOCAL_CFLAGS += -DDYNAMIC_FPS
endif

LOCAL_ADDITIONAL_DEPENDENCIES := $(common_deps)
LOCAL_SRC_FILES               := hwc.cpp          \
                                 hwc_utils.cpp    \
                                 hwc_uevents.cpp  \
                                 hwc_vsync.cpp    \
                                 hwc_fbupdate.cpp \
                                 hwc_mdpcomp.cpp  \
                                 hwc_copybit.cpp  \
                                 hwc_qclient.cpp  \
                                 hwc_dump_layers.cpp \
                                 hwc_ad.cpp \
                                 hwc_virtual.cpp \
                                 android/uevent.cpp

TARGET_MIGRATE_QDCM_LIST := msm8909
TARGET_MIGRATE_QDCM := $(call is-board-platform-in-list,$(TARGET_MIGRATE_QDCM_LIST))

ifeq ($(TARGET_MIGRATE_QDCM), true)
ifeq ($(strip $(TARGET_USES_QCOM_DISPLAY_PP)),true)
LOCAL_SRC_FILES += hwc_qdcm.cpp
else
LOCAL_SRC_FILES += hwc_qdcm_legacy.cpp
endif
else
LOCAL_SRC_FILES += hwc_qdcm_legacy.cpp
endif

ifeq ($(TARGET_SUPPORTS_ANDROID_WEAR), true)
    LOCAL_CFLAGS += -DSUPPORT_BLIT_TO_FB
endif

include $(BUILD_SHARED_LIBRARY)
