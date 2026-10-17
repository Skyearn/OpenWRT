#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
# NOTE: coolsnowwolf/lede already ships `src-git helloworld ...` in
# feeds.conf.default. Appending it again makes `./scripts/feeds update -a`
# fail with "Duplicate feed name 'helloworld'" (exit code 25), so only add it
# when it is really missing.
grep -q '^src-git helloworld' feeds.conf.default || \
  echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
#echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >>feeds.conf.default
