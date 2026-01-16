#!/bin/bash
# ============================================================================
# UDPspeeder Docker Entrypoint Script
# ============================================================================
# 项目: UDPspeeder
# 版本: v1.0.0
# 日期: 2026-01-16
# 描述: Docker 容器启动脚本，支持健康检查
# ============================================================================

set -e

# 健康检查函数
health_check() {
    if pgrep -x speederv2 > /dev/null; then
        exit 0
    else
        exit 1
    fi
}

# 如果是健康检查调用
if [ "$1" = "health" ]; then
    health_check
fi

# 默认参数
MODE="${MODE:-server}"
LOCAL_ADDR="${LOCAL_ADDR:-0.0.0.0}"
LOCAL_PORT="${LOCAL_PORT:-4096}"
REMOTE_ADDR="${REMOTE_ADDR:-127.0.0.1}"
REMOTE_PORT="${REMOTE_PORT:-7777}"
FEC_PARAMS="${FEC_PARAMS:-20:10}"
PASSWORD="${PASSWORD:-passwd}"
WORK_MODE="${WORK_MODE:-0}"
TIMEOUT="${TIMEOUT:-8}"
EXTRA_ARGS="${EXTRA_ARGS:-}"

# 构建命令
CMD="/usr/local/bin/speederv2"

if [ "$MODE" = "server" ] || [ "$MODE" = "-s" ]; then
    CMD="$CMD -s"
elif [ "$MODE" = "client" ] || [ "$MODE" = "-c" ]; then
    CMD="$CMD -c"
else
    echo "Error: MODE must be 'server' or 'client'"
    exit 1
fi

CMD="$CMD -l${LOCAL_ADDR}:${LOCAL_PORT}"
CMD="$CMD -r${REMOTE_ADDR}:${REMOTE_PORT}"
CMD="$CMD -f${FEC_PARAMS}"
CMD="$CMD -k\"${PASSWORD}\""
CMD="$CMD --mode ${WORK_MODE}"
CMD="$CMD --timeout ${TIMEOUT}"

[ -n "$EXTRA_ARGS" ] && CMD="$CMD $EXTRA_ARGS"

echo "=========================================="
echo "UDPspeeder Docker Container"
echo "=========================================="
echo "Mode: $MODE"
echo "Listen: ${LOCAL_ADDR}:${LOCAL_PORT}"
echo "Remote: ${REMOTE_ADDR}:${REMOTE_PORT}"
echo "FEC: ${FEC_PARAMS}"
echo "Work Mode: ${WORK_MODE}"
echo "=========================================="
echo "Starting: $CMD"
echo "=========================================="

exec $CMD
