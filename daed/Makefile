# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=daed
PKG_VERSION:=2025.12.15
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
  daed backend extracted from upstream release binary.
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


define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)

	# 下载 ipk
	wget -L --content-disposition -O $(PKG_BUILD_DIR)/daed.ipk "$(DAED_URL)"

	# 解包 ipk
	cd $(PKG_BUILD_DIR) && \
		tar -xzf daed.ipk && \
		tar -xzf data.tar.gz
endef

define Build/Configure
	true
endef

define Build/Compile
	true
endef

define Package/daed/install
	# 安装自动提取的二进制
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
endef

$(eval $(call BuildPackage,daed))
