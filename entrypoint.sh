#!/bin/bash

# if [ -z "${PUID}" ]; then
#     PUID="`id -u filebrowser`"
# fi

# if [ -z "${PGID}" ]; then
#     PGID="`id -g filebrowser`"
# fi

# if [ -z "${UMASK}" ]; then
#     UMASK="022"
# fi

# if [ -z "${WORK_SPACE}" ]; then
#     WORK_SPACE="/data"
# fi

if [ -z "${PORT}" ]; then
    PORT="8080"
fi

if [ -z "${ENABLE_UNBLOCK}" ]; then
    ENABLE_UNBLOCK="true"
fi

if [ "${PORT}" = "80" ] || [ "${PORT}" = "443" ] || [ "${PORT}" = "3000" ]; then
    echo "端口 ${PORT} 为系统保留端口，请更换其他端口"
    exit 1
fi

echo "=================== 启动参数 ==================="
# echo "USER_GID = ${PGID}"
# echo "USER_UID = ${PUID}"
# echo "UMASK = ${UMASK}"
# echo "WORK_SPACE = ${WORK_SPACE}"
# echo "CONFIG_SPACE = ${CONFIG_SPACE}"
echo "PORT = ${PORT}"
echo "==============================================="

# # 更新用户UID?
# if [ -n "${PUID}" ] && [ "${PUID}" != "`id -u filebrowser`" ]; then
#     echo "更新用户UID..."
#     sed -i -e "s/^filebrowser:\([^:]*\):[0-9]*:\([0-9]*\)/filebrowser:\1:${PUID}:\2/" /etc/passwd
# fi

# # 更新用户GID?
# if [ -n "${PGID}" ] && [ "${PGID}" != "`id -g filebrowser`" ]; then
#     echo "更新用户GID..."
#     sed -i -e "s/^filebrowser:\([^:]*\):[0-9]*/filebrowser:\1:${PGID}/" /etc/group
#     sed -i -e "s/^filebrowser:\([^:]*\):\([0-9]*\):[0-9]*/filebrowser:\1:\2:${PGID}/" /etc/passwd
# fi

# # 更新umask?
# if [ -n "${UMASK}" ]; then
#     echo "更新umask..."
#     umask ${UMASK}
# fi

# # 创建配置文件目录
# if [ ! -d "${CONFIG_SPACE}" ];then
#     echo "生成配置文件目录 ${CONFIG_SPACE} ..."
#     mkdir -p ${CONFIG_SPACE}
# fi
# chown -R filebrowser:filebrowser ${CONFIG_SPACE};

# # 启动filebrowser
# echo "启动filebrowser..."
# exec su-exec filebrowser /opt/filebrowser/filebrowser -r ${WORK_SPACE} -p ${PORT} -a 0.0.0.0 -c ${CONFIG_SPACE}/config.json -d ${CONFIG_SPACE}/database.db

# 生成nginx配置文件
cat > /etc/nginx/conf.d/default.conf <<EOF
server {
  gzip on;
  listen       ${PORT};
  server_name  localhost;

  location / {
    root      /usr/share/nginx/html;
    index     index.html;
    try_files \$uri \$uri/ /index.html;
  }

  location @rewrites {
    rewrite ^(.*)$ /index.html last;
  }

  location /api/ {
    proxy_buffers           16 32k;
    proxy_buffer_size       128k;
    proxy_busy_buffers_size 128k;
    proxy_set_header        Host \$host;
    proxy_set_header        X-Real-IP \$remote_addr;
    proxy_set_header        X-Forwarded-For \$remote_addr;
    proxy_set_header        X-Forwarded-Host \$remote_addr;
    proxy_set_header        X-NginX-Proxy true;
    proxy_pass              http://localhost:3000/;
  }
}
EOF



if [ "${ENABLE_UNBLOCK}" = "true" ]; then
    # 添加指定条目到 /etc/hosts 并防止重复添加
    cp /etc/hosts /etc/hosts.bak
    HOSTS_ENTRIES=(
    "127.0.0.1 music.163.com"
    "127.0.0.1 interface.music.163.com"
    "127.0.0.1 interface3.music.163.com"
    "127.0.0.1 interface.music.163.com.163jiasu.com"
    "127.0.0.1 interface3.music.163.com.163jiasu.com"
    )

    for entry in "${HOSTS_ENTRIES[@]}"; do
        if ! grep -Fxq "$entry" /etc/hosts; then
            echo "$entry" >> /etc/hosts
        fi
    done
    trap "cp /etc/hosts.bak /etc/hosts" EXIT

    # 设置环境变量
    export ENABLE_FLAC="true"
    export ENABLE_LOCAL_VIP="svip"

    # 启动 unblockneteasemusic
    unblockneteasemusic -o pyncmd bilibili kugou kuwo -p 80:443 -f 45.127.129.53 -e - &
fi

# 启动 NeteaseCloudMusicApi
echo "启动 NeteaseCloudMusicApi..."
NeteaseCloudMusicApi &

# 启动nginx
echo "启动nginx..."
nginx -g "daemon off;" > /dev/null 2>&1

