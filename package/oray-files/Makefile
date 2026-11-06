include $(TOPDIR)/rules.mk

PKG_NAME:=oray-files
PKG_RELEASE:=1
PKG_LICENSE:=MIT

include $(INCLUDE_DIR)/package.mk

define Package/oray-files
  SECTION:=base
  CATEGORY:=Base system
  TITLE:=Oray X1 Pro custom defaults (zh-cn lang, argon theme, wan fallback)
  DEPENDS:=
endef

define Package/oray-files/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DATA) ./files/etc/uci-defaults/90-oray-custom $(1)/etc/uci-defaults/90-oray-custom
endef

$(eval $(call BuildPackage,oray-files))
