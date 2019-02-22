FROM alpine:3.7

ADD https://github.com/resin-io/qemu/releases/download/v2.9.0%2Bresin1/qemu-2.9.0.resin1-arm.tar.gz /tmp/qemu-2.9.0.tar.gz

RUN mkdir -p /opt/qemu && \
    tar xf /tmp/qemu-2.9.0.tar.gz -C /opt/qemu --strip-components=1

FROM arm32v6/alpine:3.7
COPY --from=0 /opt/qemu/qemu-arm-static /qemu-arm-static

ARG S6_OVERLAY_VER=1.21.2.2
ARG OPENRESTY_VER=1.13.6.1
ARG NGINX_RTMP_VER=1.2.1
ARG LUAROCKS_VER=2.4.3
ARG MULTISTREAMER_VER=12.2.1
ARG SOCKEXEC_VER=2.0.3

ARG LUA_LAPIS_VER=1.6.0-1
ARG LUA_LUA_RESTY_EXEC_VER=3.0.3-0
ARG LUA_LUA_RESTY_JIT_UUID_VER=0.0.6-1
ARG LUA_LUA_RESTY_HTTP_VER=0.11-0
ARG LUA_ETLUA_VER=1.3.0-1
ARG LUA_LUAPOSIX_VER=34.0.1-3
ARG LUA_LUAFILESYSTEM_VER=1.7.0-2
ARG LUA_WHEREAMI_VER=1.2.1-0
ARG LUA_LUACRYPTO_VER=0.3.2-2
ARG LUA_LYAML_VER=6.2-1
ARG LUA_REDIS_VER=2.0.4-1
ARG LUA_MD5_VER=1.2-1

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VER}/s6-overlay-armhf.tar.gz /tmp/s6-overlay.tar.gz
ADD https://github.com/jprjr/sockexec/releases/download/${SOCKEXEC_VER}/sockexec-arm-linux-musleabihf.tar.gz /tmp/sockexec.tar.gz

COPY rootfs /
RUN ["/qemu-arm-static","-execve","/bin/sh","/opt/multistreamer/build"]

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS 2

ENTRYPOINT ["/init"]

EXPOSE 1935 6667 8081
