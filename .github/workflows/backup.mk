# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=daed
PKG_VERSION:=2026.02.03
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/daed
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=A Modern Dashboard For dae
  URL:=https://github.com/QiuSimons/luci-app-daed
  DEPENDS:=+ca-bundle +kmod-sched-core +kmod-sched-bpf
endef

define Package/daed/description
  daed backend extracted from upstream release binary, bundled with v2ray geoip/geosite data.
endef

define Package/daed/conffiles
/etc/daed/wing.db
/etc/config/daed
endef

DAED_ARCH := $(if $(filter x86_64,$(ARCH)),x86_64,$(if $(filter i386,$(TARGET_ARCH)),i386_pentium4,aarch64_generic))

# 自动获取最新 release 的 aarch64_generic.ipk 下载链接
DAED_URL := $(shell \
  curl -s https://api.github.com/repos/QiuSimons/luci-app-daed/releases/latest \
	| jq -r '.assets[] | select(.name | test("$(DAED_ARCH)\\.ipk$$")) | .browser_download_url' \
)

# v2ray 数据文件下载地址
GEOIP_URL:=https://github.com/Loyalsoldier/geoip/releases/latest/download/geoip-only-cn-private.dat
GEOSITE_URL:=https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)

	# 下载 daed ipk
	wget -L --content-disposition -O $(PKG_BUILD_DIR)/daed.ipk "$(DAED_URL)"

	# 解包 ipk
	cd $(PKG_BUILD_DIR) && \
		tar -xzf daed.ipk && \
		tar -xzf data.tar.gz

	# 下载 v2ray 数据文件
	curl -L $(GEOIP_URL) -o $(PKG_BUILD_DIR)/geoip.dat --progress-bar
	curl -L $(GEOSITE_URL) -o $(PKG_BUILD_DIR)/geosite.dat --progress-bar

	# 校验 sha256
	[ "$(curl -sL $(GEOIP_URL).sha256sum | awk '{print $1}')" = "$(sha256sum $(PKG_BUILD_DIR)/geoip.dat | awk '{print $1}')" ]
	[ "$(curl -sL $(GEOSITE_URL).sha256sum | awk '{print $1}')" = "$(sha256sum $(PKG_BUILD_DIR)/geosite.dat | awk '{print $1}')" ]
endef

define Build/Configure
	true
endef

define Build/Compile
	true
endef

define Package/daed/install
	# 安装 daed 二进制
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/usr/bin/daed $(1)/usr/bin/daed

	# 安装配置文件
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/daed.config $(1)/etc/config/daed

	# 安装启动脚本
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/daed.init $(1)/etc/init.d/daed

	# 创建数据目录
	$(INSTALL_DIR) $(1)/etc/daed
	$(INSTALL_DIR) $(1)/etc/daed/config

	# 安装 v2ray 数据文件
	$(INSTALL_DIR) $(1)/usr/share/v2ray
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/geoip.dat $(1)/usr/share/v2ray/geoip.dat
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/geosite.dat $(1)/usr/share/v2ray/geosite.dat
endef

$(eval $(call BuildPackage,daed))
