#
# OpenWrt Build system
# (C) 2014 Jon Suphammer <jon@suphammer.net>
#

# Check for valid target
ifndef TARGET
  $(warning No target selected. Using default)
  TARGET := esr1750
endif
ifeq (,$(firstword $(wildcard target/$(TARGET))))
  $(error Target '$(TARGET)' not found)
endif

# Check for valid firmware destination location
FWDIR := /mnt/owncloud/fw
ifeq (,$(firstword $(wildcard $(FWDIR))))
  FWDIR := /tmp
  $(warning Firmware destination is $(FWDIR).)
endif

all:
	@echo "Please select one of the following:"
	@echo "* make init                      - Fetches all submodules."
	@echo "* make TARGET=<target> prepare   - Configure target configuration."
	@echo "* make TARGET=<target> release   - Build OpenWrt for specified target."

init:
	@git submodule init
	@git submodule update
	@git submodule foreach git checkout master

prepare:
	@cp target/$(TARGET)/feeds.conf openwrt/$(TARGET)/
	(cd openwrt/$(TARGET) && ./scripts/feeds update -a && ./scripts/feeds install -a)
#	(cd openwrt/$(TARGET) && make defconfig < /dev/null)
#	@cat target/$(TARGET)/openwrt.config >> openwrt/$(TARGET)/.config
	@cat target/$(TARGET)/openwrt.config > openwrt/$(TARGET)/.config
	(cd openwrt/$(TARGET) && make oldconfig < /dev/null 2> /dev/null)

release:
	@date +%Y%m%d%H%M > openwrt/$(TARGET)/version
	@(cd openwrt/$(TARGET) && make -j16)
ifeq ($(TARGET),esr1750)
	@cp openwrt/$(TARGET)/bin/ar71xx/openwrt-ar71xx-generic-esr1750-squashfs-sysupgrade.bin $(FWDIR)/openwrt-esr1750-`cat openwrt/$(TARGET)/version`.bin
endif
	@rm -f openwrt/$(TARGET)/version

