#!/bin/sh
# SPDX-License-Identifier: GPL-2.0
# Dynamic DNS re-resolver for WireGuard on Padavan
# Adjusted by bsdcpp to make it compatible with Padavan's ash shell.

CONFIG_FILE="$1"

# 检查并解析配置文件路径和接口名称
if echo "$CONFIG_FILE" | grep -qE '^[a-zA-Z0-9_=+.-]{1,15}$'; then
    CONFIG_FILE="/etc/wireguard/$CONFIG_FILE.conf"
fi
INTERFACE=$(echo "$CONFIG_FILE" | sed -n 's:.*/\([a-zA-Z0-9_=+.-]\{1,15\}\)\.conf$:\1:p')

# 初始化 Peer 节点相关变量
reset_peer_section() {
    PEER_SECTION=0
    PUBLIC_KEY=""
    ENDPOINT=""
}

# 处理 Peer 节点
process_peer() {
    if [ "$PEER_SECTION" -ne 1 ] || [ -z "$PUBLIC_KEY" ] || [ -z "$ENDPOINT" ]; then
        return
    fi
    HANDSHAKE_LINE=$(wg show "$INTERFACE" latest-handshakes | grep "$(echo "$PUBLIC_KEY" | sed 's/+/\+/g')")
    if [ -n "$HANDSHAKE_LINE" ]; then
        HANDSHAKE_TIME=$(echo "$HANDSHAKE_LINE" | awk '{print $2}')
        CURRENT_TIME=$(date +%s)
        if [ $((CURRENT_TIME - HANDSHAKE_TIME)) -gt 135 ]; then
            wg set "$INTERFACE" peer "$PUBLIC_KEY" endpoint "$ENDPOINT"
        fi
    fi
    reset_peer_section
}

# 初始化
reset_peer_section

# 逐行读取配置文件
while read -r line || [ -n "$line" ]; do
    # 去掉注释与多余空格
    stripped=$(echo "${line%%#*}" | xargs)
    key=$(echo "$stripped" | cut -d= -f1 | xargs)
    value=$(echo "$stripped" | cut -d= -f2- | xargs)

    # 检测新段落并处理
    if echo "$key" | grep -qE '^\[.*\]$'; then
        process_peer
        reset_peer_section
    fi

    # 进入 Peer 节点
    if [ "$key" = "[Peer]" ]; then
        PEER_SECTION=1
    fi

    # 读取 Peer 的关键信息
    if [ "$PEER_SECTION" -eq 1 ]; then
        case "$key" in
            PublicKey) PUBLIC_KEY="$value" ;;
            Endpoint) ENDPOINT="$value" ;;
        esac
    fi
done < "$CONFIG_FILE"

# 处理最后一个 Peer
process_peer
