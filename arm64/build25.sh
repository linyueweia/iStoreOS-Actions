#!/bin/bash
# 此脚本在Imagebuilder 根目录运行
source custom-packages.sh
echo "第三方软件包: $CUSTOM_PACKAGES"
LOGFILE="/tmp/uci-defaults-log.txt"
echo "Starting 99-custom.sh at $(date)" >> $LOGFILE
echo "Include Docker: $INCLUDE_DOCKER"

if [ -z "$CUSTOM_PACKAGES" ]; then
  echo "⚪️ 未选择 任何第三方软件包"
else
  # ============= 同步第三方插件库==============
  # 同步第三方软件仓库run/ipk
  echo "🔄 正在同步第三方软件仓库 Cloning run file repo..."
  git clone --depth=1 https://github.com/wukongdaily/store.git /tmp/store-run-repo

  # 拷贝 run/arm64 下所有 run 文件和ipk文件 到 extra-packages 目录
  mkdir -p extra-packages
  cp -r /tmp/store-run-repo/run/arm64/* extra-packages/

  echo "✅ Run files copied to extra-packages:"
  ls -lh extra-packages/*.run
  # 解压并拷贝ipk到packages目录
  sh prepare-packages.sh
  echo "打印imagebuilder/packages目录结构"
  ls -lah packages/ |grep partexp
fi

# 输出调试信息
echo "$(date '+%Y-%m-%d %H:%M:%S') - 开始构建固件..."

# ============= iStoreOS仓库内的插件==============
# 定义所需安装的包列表 下列插件你都可以自行删减

# 初始化变量
PACKAGES=""

# 精简构建
PACKAGES="$PACKAGES luci"
PACKAGES="$PACKAGES -dnsmasq"
PACKAGES="$PACKAGES dnsmasq-full"
PACKAGES="$PACKAGES luci-theme-argon"
PACKAGES="$PACKAGES luci-i18n-argon-zh-cn"
PACKAGES="$PACKAGES luci-app-argon-config"
PACKAGES="$PACKAGES luci-i18n-argon-config-zh-cn"
PACKAGES="$PACKAGES luci-i18n-base-zh-cn"
PACKAGES="$PACKAGES luci-i18n-firewall-zh-cn"
PACKAGES="$PACKAGES luci-i18n-ttyd-zh-cn"
PACKAGES="$PACKAGES luci-i18n-package-manager-zh-cn"
PACKAGES="$PACKAGES luci-i18n-quickstart-zh-cn"
PACKAGES="$PACKAGES luci-i18n-upnp-zh-cn"
PACKAGES="$PACKAGES luci-i18n-samba4-zh-cn"
PACKAGES="$PACKAGES luci-i18n-dockerman-zh-cn"
PACKAGES="$PACKAGES -libustream-mbedtls"

# O大打包脚本补充插件
PACKAGES="$PACKAGES perlbase-base perlbase-file perlbase-time perlbase-utf8 perlbase-xsloader"

# file/etc/packages目录的第三方可选插件
#PACKAGES="$PACKAGES filebrowser"
#PACKAGES="$PACKAGES luci-app-filebrowser-go"
#PACKAGES="$PACKAGES luci-i18n-filebrowser-go-zh-cn"
#PACKAGES="$PACKAGES luci-app-amlogic"
#PACKAGES="$PACKAGES luci-i18n-amlogic-zh-cn"
#PACKAGES="$PACKAGES lucky"
#PACKAGES="$PACKAGES luci-app-lucky"
#PACKAGES="$PACKAGES luci-i18n-lucky-zh-cn"
#PACKAGES="$PACKAGES openlist2"
#PACKAGES="$PACKAGES luci-app-openlist2"
#PACKAGES="$PACKAGES luci-i18n-openlist2-zh-cn"
#PACKAGES="$PACKAGES luci-app-ramfree"
#PACKAGES="$PACKAGES luci-i18n-ramfree-zh-cn"

# 追加自定义包
PACKAGES="$PACKAGES $CUSTOM_PACKAGES"


# 构建镜像
echo "开始构建......打印所有包名===="
echo "$PACKAGES"


# 开始构建
make image PROFILE=generic PACKAGES="$PACKAGES" FILES="files"

if [ $? -ne 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: Build failed!"
    exit 1
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') - 构建成功."
