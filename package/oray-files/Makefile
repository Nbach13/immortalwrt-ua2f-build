include $(TOPDIR)/rules.mk

PKG_NAME:=oray-files
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/oray-files
  SECTION:=base
  CATEGORY:=Base system
  TITLE:=Oray X1 Pro custom defaults (zh_Hans lang, Argon theme, WAN fallback)
endef

define Package/oray-files/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(CP) ./files/etc/uci-defaults/90-oray-custom $(1)/etc/uci-defaults/90-oray-custom
endef

$(eval $(call BuildPackage,oray-files))
