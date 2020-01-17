ARCHS = arm64 arm64e
TARGET = iphone:clang::11.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Spectrum
Spectrum_FILES = $(wildcard *.m)
Spectrum_INSTALL_PATH = /Library/PreferenceBundles
Spectrum_PRIVATE_FRAMEWORKS = Preferences
Spectrum_LIBRARIES = skittycolor
Spectrum_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/$(BUNDLE_NAME).plist$(ECHO_END)
