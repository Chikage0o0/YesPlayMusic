#!/bin/sh

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

# if [ -z "${PORT}" ]; then
#     PORT="80"
# fi

# if [ -z "${CONFIG_SPACE}" ]; then
#     CONFIG_SPACE="/opt/filebrowser/config"
# fi

# echo "=================== 启动参数 ==================="
# echo "USER_GID = ${PGID}"
# echo "USER_UID = ${PUID}"
# echo "UMASK = ${UMASK}"
# echo "WORK_SPACE = ${WORK_SPACE}"
# echo "CONFIG_SPACE = ${CONFIG_SPACE}"
# echo "PORT = ${PORT}"
# echo "==============================================="

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

nginx ; NeteaseCloudMusicApi