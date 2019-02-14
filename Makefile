#
# Copyright (C) 2019 Xingwang Liao
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=v2ray-core
PKG_VERSION:=4.16
PKG_SOURCE_DATE:=2019-02-03
PKG_SOURCE_VERSION:=c8f446aba50b2a422f3fff5f55d18a4aed78f0a5
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_DATE).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/v2ray/v2ray-core/tar.gz/$(PKG_SOURCE_VERSION)?
PKG_HASH:=043ec5c8ef56883b287aefd4e8c8ba1a8b7d5334ce441adc0cf90ab35995d396
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_SOURCE_VERSION)

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Xingwang Liao <kuoruan@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=v2ray.com/core

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/v2ray-core/Default
  TITLE:=A platform for building proxies to bypass network restrictions
  URL:=https://www.v2ray.com/
endef

define Package/v2ray-core/Default/description
Project V is a set of network tools that help you to build your own computer network.
It secures your network connections and thus protects your privacy.
endef

define v2ray-core/templates
  define Package/$(1)
  $$(call Package/v2ray-core/Default)
    TITLE+= ($(1))
    USERID:=v2ray=10800:v2ray=10800
    SECTION:=net
    CATEGORY:=Network
    SUBMENU:=Web Servers/Proxies
    DEPENDS:=$$(GO_ARCH_DEPENDS)
  endef

  define Package/$(1)/description
  $(call Package/v2ray-core/Default/description)

  This package contains the $(1).
  endef

  define Package/$(1)/install
	$$(INSTALL_DIR) $$(1)/usr/bin
	$$(INSTALL_BIN) $$(GO_PKG_BUILD_BIN_DIR)/$(1) $$(1)/usr/bin
  endef
endef

define Package/golang-v2ray-core-dev
$(call Package/v2ray-core/Default)
$(call GoPackage/GoSubMenu)
  TITLE+= (source files)
  PKGARCH:=all
endef

define Package/golang-v2ray-core-dev/description
$(call Package/v2ray-core/Default/description)

This package provides the source files for v2ray.
endef

define Build/Compile
	$(eval GO_PKG_BUILD_PKG:=v2ray.com/core/main)
	$(call GoPackage/Build/Compile,-ldflags "-s -w")
	mv -f $(GO_PKG_BUILD_BIN_DIR)/main $(GO_PKG_BUILD_BIN_DIR)/v2ray

	$(eval GO_PKG_BUILD_PKG:=v2ray.com/core/infra/control/main)
	$(call GoPackage/Build/Compile,-ldflags "-s -w")
	mv -f $(GO_PKG_BUILD_BIN_DIR)/main $(GO_PKG_BUILD_BIN_DIR)/v2ctl
endef

V2RAY_COMPONENTS:=v2ray v2ctl

$(foreach component,$(V2RAY_COMPONENTS), \
  $(eval $(call v2ray-core/templates,$(component))) \
  $(eval $(call GoBinPackage,$(component))) \
  $(eval $(call BuildPackage,$(component))) \
)

$(eval $(call GoSrcPackage,golang-v2ray-core-dev))
$(eval $(call BuildPackage,golang-v2ray-core-dev))