#!/bin/sh
WG_INTERFACE='wg0'
wgconf=/etc/storage/${WG_INTERFACE}.conf
http_username=`nvram get http_username`
wireguard_enable=`nvram get wireguard_enable`

start_wg() {
    logger -t "WIREGUARD" "正在启动wireguard"
    /usr/bin/wg-quick up ${wgconf}
    sed -i '/wireguard/d' /etc/storage/cron/crontabs/$http_username
    cat >> /etc/storage/cron/crontabs/$http_username << EOF
*/1 * * * * /bin/sh /usr/bin/wireguard.sh C >/dev/null 2>&1
EOF
}


stop_wg() {
    /usr/bin/wg-quick down ${wgconf}
    sed -i '/wireguard/d' /etc/storage/cron/crontabs/$http_username
    logger -t "WIREGUARD" "正在关闭wireguard"
}

check_wg() {
    if [ "$wireguard_enable" = "1" ]; then
        echo "WireGuard 已启动，检查 iptables 规则..."
        iptables -C INPUT -i $WG_INTERFACE -j ACCEPT || iptables -A INPUT -i $WG_INTERFACE -j ACCEPT
        iptables -C FORWARD -i $WG_INTERFACE -j ACCEPT || iptables -A FORWARD -i $WG_INTERFACE -j ACCEPT
        iptables -t nat -C POSTROUTING -o $WG_INTERFACE -j MASQUERADE || iptables -t nat -A POSTROUTING -o $WG_INTERFACE -j MASQUERADE

        echo "检查对端通信时效，针对ddns变化"
        /bin/sh /usr/bin/reresolve-dns.sh ${wgconf}
    else
        echo "WireGuard 未启动，跳过设置 iptables 规则。"
    fi
}

case $1 in
start)
    start_wg
    ;;
stop)
    stop_wg
    ;;
C)
    check_wg
    ;;
*)
    echo "check"
    #exit 0
    ;;
esac
