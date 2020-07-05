include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = IrisPreferences
IrisPreferences_FILES = $(wildcard *.m) $(wildcard src/Swift/Model/*ButtonModel.swift) src/Objective-C/Model/IrisConversationTag.m src/Objective-C/Globals.m
IrisPreferences_SWIFT_BRIDGING_HEADER = src/Objective-C/Iris-Bridging-Header.h
IrisPreferences_INSTALL_PATH = /Library/PreferenceBundles
IrisPreferences_PRIVATE_FRAMEWORKS = Preferences
IrisPreferences_EXTRA_FRAMEWORKS += libJCX
IrisPreferences_CFLAGS = -fobjc-arc -DIS_PREFS

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/IrisPreferences.plist$(ECHO_END)
