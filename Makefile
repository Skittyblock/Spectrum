INSTALL_TARGET_PROCESSES = SpringBoard

export ARCHS = arm64 arm64e
export TARGET = iphone:clang::13.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Spectrum

Spectrum_FILES = $(wildcard *.x) $(wildcard *.m)
Spectrum_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += prefs
include $(THEOS_MAKE_PATH)/aggregate.mk
