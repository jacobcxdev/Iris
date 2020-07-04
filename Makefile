export ARCHS = arm64 arm64e
export TARGET := iphone::latest:13.0
export ADDITIONAL_CFLAGS = -DTHEOS_LEAN_AND_MEAN # -DMOCKUP
INSTALL_TARGET_PROCESSES = MobileSMS Preferences # SpringBoard imagent tccd

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Iris
Iris_FILES = $(wildcard Objective-C/**/*.x) $(wildcard Objective-C/**/*.m) $(wildcard Swift/**/*.*)
Iris_SWIFT_BRIDGING_HEADER = Objective-C/Iris-Bridging-Header.h
Iris_EXTRA_FRAMEWORKS = libJCX Alderis
Iris_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS = irispreferences
include $(THEOS_MAKE_PATH)/aggregate.mk
