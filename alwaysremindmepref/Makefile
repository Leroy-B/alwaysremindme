include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = AlwaysRemindMePref
AlwaysRemindMePref_FILES = ARMRootListController.m HeaderCell.mm
AlwaysRemindMePref_INSTALL_PATH = /Library/PreferenceBundles
AlwaysRemindMePref_FRAMEWORKS = UIKit
AlwaysRemindMePref_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/AlwaysRemindMePref.plist$(ECHO_END)
