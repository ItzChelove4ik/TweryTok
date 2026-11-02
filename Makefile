TARGET := iphone:clang:16.5
INSTALL_TARGET_PROCESSES = TikTok
THEOS_DEVICE_IP = 192.168.100.246
THEOS_DEVICE_USER = root
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TweryTok

TweryTok_FILES = Tweak.x $(wildcard *.m JGProgressHUD/*.m Settings/*.m)
TweryTok_FRAMEWORKS = UIKit Foundation CoreGraphics Photos Security QuartzCore
TweryTok_CFLAGS = -fobjc-arc -Wno-unused-variable -Wno-unused-value -Wno-deprecated-declarations -Wno-nullability-completeness -Wno-unused-function -Wno-incompatible-pointer-types

include $(THEOS_MAKE_PATH)/tweak.mk
