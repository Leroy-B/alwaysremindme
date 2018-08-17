#THEOS_DEVICE_IP = 192.168.1.37
THEOS_DEVICE_IP = 192.168.1.105
TARGET = iphone:11.2:11.0
# TARGET = simulator:clang::11.0

ARCHS = arm64
# ARCHS = x86_64

DEBUG = 0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = AlwaysRemindMePref
AlwaysRemindMePref_FILES = ARMRootListController.m
AlwaysRemindMePref_INSTALL_PATH = /Library/PreferenceBundles
AlwaysRemindMePref_FRAMEWORKS = UIKit
AlwaysRemindMePref_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/AlwaysRemindMePref.plist$(ECHO_END)
