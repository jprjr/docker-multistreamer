FROM alpine:3.5

ARG S6_OVERLAY_VER=1.19.1.1
ARG NGINX_VER=1.10.3
ARG NGINX_DEVEL_KIT_VER=0.3.0
ARG NGINX_LUA_VER=0.10.8
ARG NGINX_RTMP_VER=1.2.0
ARG NGINX_STREAM_LUA_VER=e527417c5d04da0c26c12cf4d8a0ef0f1e36e051
ARG LUAROCKS_VER=2.4.2
ARG MULTISTREAMER_VER=master
ARG SOCKEXEC_VER=2.0.1

RUN apk add --no-cache \
    bash \
    gcc \
    make \
    musl-dev \
    luajit-dev \
    linux-headers \
    gd-dev \
    geoip-dev \
    libxml2-dev \
    libxslt-dev \
    libressl-dev \
    paxmark \
    pcre-dev \
    perl-dev \
    pkgconf \
    zlib-dev \
    curl \
    git \
    unzip \
    ffmpeg \
    luajit \
    pcre \
    libressl2.4-libssl \
    libressl2.4-libtls \
    libressl2.4-libcrypto \
    ca-certificates \
    postgresql-client \
    zlib

RUN mkdir /tmp/openresty-build && \
  cd /tmp/openresty-build && \
  curl -R -L -o s6-overlay-amd64.tar.gz \
    https://github.com/just-containers/s6-overlay/releases/download/v$S6_OVERLAY_VER/s6-overlay-amd64.tar.gz  && \
  curl -R -L -o sockexec-x86_64-linux-musl.tar.gz \
    https://github.com/jprjr/sockexec/releases/download/$SOCKEXEC_VER/sockexec-x86_64-linux-musl.tar.gz && \
  curl -R -L -o nginx-$NGINX_VER.tar.gz \
    https://nginx.org/download/nginx-$NGINX_VER.tar.gz && \
  curl -R -L -o ngx_devel_kit-$NGINX_DEVEL_KIT_VER.tar.gz \
    https://github.com/simpl/ngx_devel_kit/archive/v$NGINX_DEVEL_KIT_VER.tar.gz && \
  curl -R -L -o lua-nginx-module-$NGINX_LUA_VER.tar.gz \
    https://github.com/openresty/lua-nginx-module/archive/v$NGINX_LUA_VER.tar.gz && \
  curl -R -L -o nginx-rtmp-module-$NGINX_RTMP_VER.tar.gz \
    https://github.com/arut/nginx-rtmp-module/archive/v$NGINX_RTMP_VER.tar.gz && \
  curl -R -L -o stream-lua-nginx-module-$NGINX_STREAM_LUA_VER.tar.gz \
    https://github.com/openresty/stream-lua-nginx-module/archive/$NGINX_STREAM_LUA_VER.tar.gz && \
  curl -R -L -o luarocks-$LUAROCKS_VER.tar.gz \
    http://luarocks.github.io/luarocks/releases/luarocks-$LUAROCKS_VER.tar.gz && \
  tar xzf nginx-$NGINX_VER.tar.gz && \
  tar xzf ngx_devel_kit-$NGINX_DEVEL_KIT_VER.tar.gz && \
  tar xzf lua-nginx-module-$NGINX_LUA_VER.tar.gz && \
  tar xzf nginx-rtmp-module-$NGINX_RTMP_VER.tar.gz && \
  tar xzf stream-lua-nginx-module-$NGINX_STREAM_LUA_VER.tar.gz && \
  tar xzf luarocks-$LUAROCKS_VER.tar.gz && \
  tar xzf s6-overlay-amd64.tar.gz -C / && \
  tar xzf sockexec-x86_64-linux-musl.tar.gz -C /usr && \
  cd nginx-$NGINX_VER && \
  ( \
    export LUAJIT_LIB=$(pkg-config --variable=libdir luajit) && \
    export LUAJIT_INC=$(pkg-config --variable=includedir luajit) && \
    export CC=$(which gcc) && \
    ./configure \
      --prefix=/opt/nginx \
      --with-threads \
      --with-file-aio \
      --with-ipv6 \
      --with-http_ssl_module \
      --with-pcre \
      --with-pcre-jit \
      --with-stream \
      --with-stream_ssl_module \
      --add-module=../ngx_devel_kit-$NGINX_DEVEL_KIT_VER \
      --add-module=../lua-nginx-module-$NGINX_LUA_VER \
      --add-module=../nginx-rtmp-module-$NGINX_RTMP_VER \
      --add-module=../stream-lua-nginx-module-$NGINX_STREAM_LUA_VER && \
    make  && \
    make install \
  ) && \
  cd /tmp/openresty-build/luarocks-$LUAROCKS_VER && \
  ./configure \
    --prefix=/opt/luarocks \
    --with-lua-include=$(pkg-config --variable=includedir luajit) \
    --lua-suffix=jit && \
  make && \
  make build && \
  make install && \
  cd / && \
  rm -rf /tmp/openresty-build

RUN  mkdir /etc/htpasswd-auth-server && \
  mkdir /etc/redis-auth-server && \
  adduser -h /home/redisauth -g redisauth -s /sbin/nologin -S -D redisauth && \
  cd /home/redisauth && \
  curl -R -L -o redis-auth-server-master.tar.gz \
    https://github.com/jprjr/redis-auth-server/archive/master.tar.gz && \
  tar xzf redis-auth-server-master.tar.gz && \
  mv redis-auth-server-master/* . && \
  rm -rf redis-auth-server-master && \
  chown -R redisauth:nogroup . && \
  ln -sf /home/multistreamer/lua_modules ./lua_modules && \
  rm -rf ./etc && \
  ln -sf /etc/redis-auth-server ./etc && \
  adduser -h /home/htpasswdauth -g htpasswdauth -s /sbin/nologin -S -D htpasswdauth && \
  cd /home/htpasswdauth && \
  curl -R -L -o htpasswd-auth-server-master.tar.gz \
    https://github.com/jprjr/htpasswd-auth-server/archive/master.tar.gz && \
  tar xzf htpasswd-auth-server-master.tar.gz && \
  mv htpasswd-auth-server-master/* . && \
  rm -rf htpasswd-auth-server-master && \
  chown -R htpasswdauth:nogroup . && \
  ln -sf /home/multistreamer/lua_modules ./lua_modules && \
  rm -rf ./etc && \
  ln -sf /etc/htpasswd-auth-server ./etc

RUN adduser -h /home/multistreamer -g multistreamer -s /sbin/nologin -S -D multistreamer && \
  cd /home/multistreamer && \
  rm -rf ./* && \
  git clone https://github.com/jprjr/multistreamer.git . && \
  ln -fs /etc/multistreamer/config.lua /home/multistreamer/config.lua && \
  /opt/luarocks/bin/luarocks --tree lua_modules install lua-resty-exec && \
  /opt/luarocks/bin/luarocks --tree lua_modules install lua-resty-jit-uuid && \
  /opt/luarocks/bin/luarocks --tree lua_modules install lua-resty-string && \
  /opt/luarocks/bin/luarocks --tree lua_modules install lua-resty-http && \
  /opt/luarocks/bin/luarocks --tree lua_modules install lua-resty-upload && \
  /opt/luarocks/bin/luarocks --tree lua_modules install lapis && \
  /opt/luarocks/bin/luarocks --tree lua_modules install etlua && \
  /opt/luarocks/bin/luarocks --tree lua_modules install luaposix && \
  /opt/luarocks/bin/luarocks --tree lua_modules install luafilesystem && \
  /opt/luarocks/bin/luarocks --tree lua_modules install whereami && \
  /opt/luarocks/bin/luarocks --tree lua_modules install luacrypto && \
  chown -R multistreamer:nogroup . && \
  mkdir /etc/multistreamer && \
  mkdir -p /var/log/multistreamer && \
  chown nobody:nogroup /var/log/multistreamer

COPY rootfs /

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS 2

ENTRYPOINT ["/init"]

EXPOSE 1935 6667 8081
