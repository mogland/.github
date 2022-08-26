###
 # @FilePath: /nx-space.github/install.sh
 # @author: Wibus
 # @Date: 2022-08-26 14:49:25
 # @LastEditors: Wibus
 # @LastEditTime: 2022-08-26 15:16:44
 # Coding With IU
### 

red='\033[0;31m'
blue='\033[0;34m'
green='\033[0;32m'
yellow='\033[0;33m'
underline='\033[4m'
reset='\033[0m'

check_sys(){
  if [[ -f /etc/redhat-release ]]; then
    release="centos"
  elif cat /etc/issue | grep -q -E -i "debian"; then
    release="debian"
  elif cat /etc/issue | grep -q -E -i "ubuntu"; then
    release="ubuntu"
  elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
    release="centos"
  elif cat /proc/version | grep -q -E -i "debian"; then
    release="debian"
  elif cat /proc/version | grep -q -E -i "ubuntu"; then
    release="ubuntu"
  elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
    release="centos"
  else
    echo "未知系统版本，请联系作者获取最新版本"
    release="others(无法识别)"
  fi
  bit=`uname -m`
}

install_dependencies(){
  if [[ ${release} == "centos" ]]; then
    yum update
    yum install -y git wget curl unzip
  elif [[ ${release} == "ubuntu" ]]; then
    apt-get update
    apt-get install -y git wget curl unzip
  elif [[ ${release} == "debian" ]]; then
    apt-get update
    apt-get install -y git wget curl unzip
  fi
}

echo "#############################################################"
echo "#                nx-space 安装脚本 0.1                       #"
check_sys
echo "你的系统为 ${release} ${bit} 你的系统版本为 ${version}"
echo "#############################################################"
echo "1. 安装依赖"
echo "2. 安装 nx-space 服务端"
echo "3. 安装 nx-theme-Single 前端"
echo "4. 安装 nx-theme-Tiny 前端"

read -p "请输入你的选择[1-4]: " num
case "$num" in
  1)
    echo -e "${green}开始安装依赖${reset}"
    install_dependencies

    # 安装 Docker
    echo -e "${green}开始安装 Docker${reset}"
    curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
    # 检查是否安装完成
    if [ -x "$(command -v docker)" ]; then
      echo -e "${green}Docker 安装成功${reset}"
    else
      echo -e "${red}Docker 安装失败${reset}"
      exit 1
    fi

    # 安装 nodejs 版本管理器 n
    echo -e "${green}开始安装 NodeJS 版本管理器 n${reset}"
    curl -L https://raw.githubusercontent.com/tj/n/master/bin/n -o n
    # 安装 LTS 版本
    echo -e "${green}开始安装 NodeJS LTS 版本${reset}"
    bash n lts

    # 安装 pnpm
    echo -e "${green}开始安装 pnpm${reset}"
    npm install -g pnpm
    npm install -g pm2
    ;;
  2)
    echo -e "${green}开始安装 nx-space 服务端${reset} 默认使用 Docker 容器"
    cd ~
    mkdir nx-space && cd nx-space
    mkdir core && cd core
    wget https://fastly.jsdelivr.net/gh/nx-space/core@main/docker-compose.yml
    # 请输入 JWT_SECRET，若不明白此项，仅需要随意输入字符串即可
    read -p "请输入 JWT_SECRET（若不明白此项，仅需要随意输入字符串即可）: " JWT_SECRET
    # 请输入允许访问的域名，至少准备3个域名，用于反向代理服务端、中后台绑定域名、反向代理前端
    read -p "请输入允许访问的域名（至少准备3个域名，用于反向代理服务端、中后台绑定域名、反向代理前端）使用英文逗号进行分割，${red}请不要带上协议头${reset}: " ALLOWED_ORIGINS
    touch .env
    echo "JWT_SECRET=$JWT_SECRET" >> .env
    echo "ALLOWED_ORIGINS=$ALLOWED_ORIGINS" >> .env
    docker compose up -d
    echo -e "${green}此时访问 http://服务端IP:3333, 请确保已允许端口，如果正常返回数据，则表示服务端安装成功啦！${reset}"
    echo -e "${red} 使用 Docker 安装服务端，数据库和 Redis 容器将会在内部被创建，并且将会被映射到本地的端口，当然，你也可以自行修改映射关系${reset}"
    echo -e "${red} 数据库文件已经挂载成数据卷做持久化处理，请不要随意删除 data 目录，否则将会造成数据库文件丢失；如果你需要备份数据，请进入后台面板，将数据备份下载，或者，备份 data 目录${reset}"
    ;;
  3)
    echo -e "${green}开始安装 nx-theme-Single 前端${reset}"
    cd ~
    # 验证是否有 nx-space 文件夹
    if [ -d "nx-space" ]; then
      echo -e "${green}nx-space 文件夹存在，开始安装 nx-theme-Single 前端${reset}"
      cd nx-space
      if [ -d "core" ]; then
        echo -e "${green}core 存在，开始安装 nx-theme-Single 前端${reset}"
        if [ -d "nx-theme-Single" ]; then
          echo -e "${red}nx-theme-Single 已存在，请先删除 nx-theme-Single ${reset}"
          exit 1
        else
          git clone https://github.com/nx-space/nx-theme-Single.git --depth 1
          cd nx-theme-Single
          pnpm i
          read -p "请输入后端访问地址${red}（需要外网可访问，请带上协议头）${reset}: " BACKEND_URL
          touch .env
          echo "NEXT_PUBLIC_API_URL=$BACKEND_URL" >> .env
          pnpm build
          pnpm prod:pm2
          echo -e "${green}nx-theme-Single 前端安装成功，端口为 2323，请确保服务器端口号是可用的，且后端环境变量已配置前端访问地址${reset}"
        fi
      else
        echo -e "${red}core 不存在，请先安装 nx-space 服务端${reset}"
        exit 1
      fi
    else
      echo -e "${red}nx-space 文件夹不存在，请先安装 nx-space 服务端${reset}"
      exit 1
    fi
    ;;
  4)
    echo -e "${green}开始安装 nx-theme-Tiny 前端${reset}"
    cd ~
    # 验证是否有 nx-space 文件夹
    if [ -d "nx-space" ]; then
      echo -e "${green}nx-space 文件夹存在，开始安装 nx-theme-Tiny 前端${reset}"
      cd nx-space
      if [ -d "core" ]; then
        echo -e "${green}core 存在，开始安装 nx-theme-Tiny 前端${reset}"
        if [ -d "nx-theme-Tiny" ]; then
          echo -e "${red}nx-theme-Tiny 已存在，请先删除 nx-theme-Tiny ${reset}"
          exit 1
        else
          git clone https://github.com/nx-space/nx-theme-Tiny.git --depth 1
          cd nx-theme-Tiny
          pnpm i
          read -p "请输入后端访问地址${red}（需要外网可访问，请带上协议头）${reset}: " BACKEND_URL
          touch .env
          echo "NEXT_PUBLIC_API_URL=$BACKEND_URL" >> .env
          pnpm build
          pnpm prod:pm2
          echo -e "${green}nx-theme-Tiny 前端安装成功，端口为 2323，请确保服务器端口号是可用的，且后端环境变量已配置前端访问地址${reset}"
        fi
      else
        echo -e "${red}core 不存在，请先安装 nx-space 服务端${reset}"
        exit 1
      fi
    else
      echo -e "${red}nx-space 文件夹不存在，请先安装 nx-space 服务端${reset}"
      exit 1
    fi
    ;;
