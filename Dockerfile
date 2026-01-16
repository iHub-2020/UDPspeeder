# ============================================================================
# UDPspeeder Docker Image
# ============================================================================
# 项目: UDPspeeder
# 版本: v2.0
# 基础镜像: Debian 12 (Bookworm)
# 日期: 2026-01-16
# 描述: 双边网络加速工具，通过 FEC 技术对抗丢包
# ============================================================================

FROM debian:12-slim AS builder

LABEL maintainer="UDPspeeder Project"
LABEL description="UDP network accelerator with FEC"

# 构建参数
ARG BUILD_DATE
ARG VCS_REF

# 安装编译依赖
RUN apt-get update && apt-get install -y \
    build-essential \
    g++ \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# 复制源码
COPY . .

# 生成版本信息并编译
RUN echo "const char *gitversion = \"${VCS_REF:-unknown}\";" > git_version.h && \
    g++ -std=c++11 -Wall -Wextra -Wno-unused-variable \
        -Wno-unused-parameter -Wno-missing-field-initializers \
        -O2 -static -o speederv2 -I. \
        main.cpp log.cpp common.cpp lib/fec.cpp lib/rs.cpp \
        crc32/Crc32.cpp packet.cpp delay_manager.cpp fd_manager.cpp \
        connection.cpp fec_manager.cpp misc.cpp tunnel_client.cpp \
        tunnel_server.cpp my_ev.cpp -isystem libev -lrt

# ============================================================================
# 运行时镜像
# ============================================================================
FROM debian:12-slim

LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.revision="${VCS_REF}"
LABEL org.opencontainers.image.title="UDPspeeder"
LABEL org.opencontainers.image.description="UDP network accelerator with FEC"

# 创建运行用户
RUN groupadd -r speeder && useradd -r -g speeder speeder

# 复制二进制文件
COPY --from=builder /build/speederv2 /usr/local/bin/
COPY docker/entrypoint.sh /entrypoint.sh

RUN chmod +x /usr/local/bin/speederv2 /entrypoint.sh && \
    mkdir -p /var/log/speeder && \
    chown -R speeder:speeder /var/log/speeder

USER speeder

EXPOSE 4096/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD /entrypoint.sh health

ENTRYPOINT ["/entrypoint.sh"]
CMD ["server"]
