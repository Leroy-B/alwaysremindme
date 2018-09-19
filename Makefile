THEOS_DEVICE_IP = 192.168.1.63
#THEOS_DEVICE_IP = 192.168.1.5
TARGET = iphone:clang:11.2:4.0
#
ARCHS = armv7 armv7s arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AlwaysRemindMe
AlwaysRemindMe_FILES = AlwaysRemindMe.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += alwaysremindmepref
include $(THEOS_MAKE_PATH)/aggregate.mk
