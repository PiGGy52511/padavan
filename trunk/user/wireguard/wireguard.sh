#!/bin/sh

WG_INTERFACE='wg0'
wgconf=/etc/storage/${WG_INTERFACE}.conf
http_username=$(nvram get http_username)

# 设置或删除配置行：
# 值为空时删除对应占位符所在行，否则替换占位符
set_line() {
	placeholder="$1"
	value="$2"

	if [ -z "$value" ]; then
		sed -i "/${placeholder}/d" /etc/storage/wg0.conf
	else
		sed -i "s|${placeholder}|${value}|g" /etc/storage/wg0.conf
	fi
}

start_wg() {
	address="$(nvram get wireguard_address)"
	privatekey="$(nvram get wireguard_privatekey)"
	publickey="$(nvram get wireguard_publickey)"
	endpoint="$(nvram get wireguard_endpoint)"
	presharedkey="$(nvram get wireguard_presharedkey)"
	allowedips="$(nvram get wireguard_allowedips)"
	persistentkeepalive="$(nvram get wireguard_persistentkeepalive)"
	postup="$(nvram get wireguard_postup)"
	postdown="$(nvram get wireguard_postdown)"

	logger -t "WIREGUARD" "正在启动wireguard"

	cp -f /etc_ro/wg0.conf /etc/storage/wg0.conf

	set_line WG_PRIVATEKEY "$privatekey"
	set_line WG_ADDRESS "$address"
	set_line WG_PUBLICKEY "$publickey"
	set_line WG_ENDPOINT "$endpoint"
	set_line WG_PRESHAREDKEY "$presharedkey"
	set_line WG_ALLOWEDIPS "$allowedips"
	set_line WG_PERSISTENTKEEPALIVE "$persistentkeepalive"
	set_line WG_POSTUP "$postup"
	set_line WG_POSTDOWN "$postdown"

	wg-quick up ${wgconf}

	# 启动成功后添加每分钟 DDNS 检查
	mkdir -p /etc/storage/cron/crontabs
	sed -i '/wireguard\.sh C/d' /etc/storage/cron/crontabs/$http_username
	echo "*/1 * * * * /bin/sh /usr/bin/wireguard.sh C >/dev/null 2>&1" >> /etc/storage/cron/crontabs/$http_username
}

stop_wg() {
	logger -t "WIREGUARD" "正在关闭wireguard"
	wg-quick down ${wgconf}

	# 关闭后移除 DDNS 检查
	sed -i '/wireguard\.sh C/d' /etc/storage/cron/crontabs/$http_username
}

check_wg() {
	# 接口不存在说明 WG 已关闭，直接跳过
	if ! ip link show $WG_INTERFACE >/dev/null 2>&1; then
		exit 0
	fi

	logger -t "WIREGUARD" "检查 DDNS 对端变化"
	/bin/sh /usr/bin/reresolve-dns.sh ${wgconf}
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
	echo "Usage: $0 {start|stop|C}"
	;;
esac
