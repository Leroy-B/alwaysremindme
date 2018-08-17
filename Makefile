THEOS_DEVICE_IP = 192.168.1.37
#THEOS_DEVICE_IP = 192.168.1.105
TARGET = iphone:11.2:11.0
# TARGET = simulator:clang::11.0

ARCHS = arm64
# ARCHS = x86_64

DEBUG = 0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AlwaysRemindMe
AlwaysRemindMe_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += alwaysremindmepref
include $(THEOS_MAKE_PATH)/aggregate.mk
