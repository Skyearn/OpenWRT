#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate

# ---------------------------------------------------------------------------
# brcmfmac (used by the K3 image) does not compile against Linux 6.6.157+.
#
# Linux 6.6.157 backported the removal of struct usb_driver.drvwrap (the same
# change landed in 6.8), so the driver now has to use usb_driver.driver
# directly. backports-6.6.15 (the version lede uses for kernel 6.6) only
# handles kernels >= 6.8 in patch 221-brcmfmac_usb_driver_backport.patch, which
# makes brcmfmac/usb.c fail with:
#   error: 'struct usb_driver' has no member named 'drvwrap'
# Broaden that version check so the >= 6.6.157 kernels take the new path.
# The patch dir is called "patchs" (sic) for the 6.6 backports in lede, and the
# patch has to live in the "build" subdir to be applied after 221- there
# (Build/Patch only walks the known subdirs, in sorted order).
# ---------------------------------------------------------------------------
if [ -d package/kernel/mac80211/patchs ]; then
	mkdir -p package/kernel/mac80211/patchs/build
	cat > package/kernel/mac80211/patchs/build/222-brcmfmac_usb_driver_6.6.157.patch <<'PATCH'
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/usb.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/usb.c
@@ -1581,7 +1581,7 @@
 
 void brcmf_usb_exit(void)
 {
-#if LINUX_VERSION_IS_GEQ(6,8,0)
+#if LINUX_VERSION_IS_GEQ(6,6,157) || LINUX_VERSION_IS_GEQ(6,8,0)
 	struct device_driver *drv = &brcmf_usbdrvr.driver;
 #else
 	struct device_driver *drv = &brcmf_usbdrvr.drvwrap.driver;
PATCH
fi
