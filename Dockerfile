FROM node:16-alpine AS build
ENV YesPlayMusic_VERSION=v0.4.9
RUN apk add --no-cache python3 make g++ git
WORKDIR /js/src/github.com/qier222/
RUN git clone --depth=1 --recursive https://github.com/qier222/YesPlayMusic.git  -b ${YesPlayMusic_VERSION}  YesPlayMusic
ENV VUE_APP_NETEASE_API_URL=/api
WORKDIR /js/src/github.com/qier222/YesPlayMusic
RUN yarn install
RUN yarn config set electron_mirror https://npmmirror.com/mirrors/electron/ && \
    yarn build

FROM nginx:alpine AS app

RUN apk add --no-cache bash nodejs npm

ENV NeteaseCloudMusicApi_VERSION=4.25.0
ENV UnBlockNeteaseMusic_VERSION=0.27.8-patch.1

# Install NeteaseCloudMusicApi and UnBlockNeteaseMusic
RUN npm install -g NeteaseCloudMusicApi@${NeteaseCloudMusicApi_VERSION} @unblockneteasemusic/server@${UnBlockNeteaseMusic_VERSION}
RUN wget https://raw.githubusercontent.com/UnblockNeteaseMusic/server/refs/heads/enhanced/ca.crt -O /etc/ssl/certs/netease.crt && \
    update-ca-certificates
RUN apk add --no-cache python3 yt-dlp


COPY --from=build /js/src/github.com/qier222/YesPlayMusic/dist /usr/share/nginx/html
COPY entrypoint.sh /usr/bin/entrypoint.sh

RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
