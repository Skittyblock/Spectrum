#INSTALL_TARGET_PROCESSES = SpringBoard
ARCHS = arm64
TARGET = iphone:clang::13.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Spectrum

Spectrum_FILES = Tweak.x
Spectrum_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += prefs
include $(THEOS_MAKE_PATH)/aggregate.mk
