#!/bin/sh
http_username=`nvram get http_username`
start_wg() {
	address="$(nvram get wireguard_address)"
	privatekey="$(nvram get wireguard_privatekey)"
	publickey="$(nvram get wireguard_publickey)"
	endpoint="$(nvram get wireguard_endpoint)"
	presharedkey="$(nvram get wireguard_presharedkey)"
  	allowedips="$(nvram get wireguard_allowedips)"
	persistentkeepalive ="$(nvram get wireguard_persistentkeepalive)"
	postup="$(nvram get wireguard_postup)"
	postdown="$(nvram get wireguard_postdown)"
	logger -t "WIREGUARD" "正在启动wireguard"
	cp -f /etc_ro/wg0.conf /tmp/wg0.conf
 	sed -i "s|WG_PRIVATEKEY|$privatekey|g" /tmp/wg0.conf
 	sed -i "s|WG_ADDRESS|$address|g" /tmp/wg0.conf
   	sed -i "s|WG_PUBLICKEY|$publickey|g" /tmp/wg0.conf
	sed -i "s|WG_ENDPOINT|$endpoint|g" /tmp/wg0.conf
	sed -i "s|WG_PRESHAREDKEY|$presharedkey|g" /tmp/wg0.conf
	sed -i "s|WG_ALLOWEDIPS|$allowedips|g" /tmp/wg0.conf
	sed -i "s|WG_PERSISTENTKEEPALIVE|$persistentkeepalive|g" /tmp/wg0.conf
	sed -i "s|WG_POSTUP|$postup|g" /tmp/wg0.conf
	sed -i "s|WG_POSTDOWN|$postdown|g" /tmp/wg0.conf
 	wg-quick up /tmp/wg0.conf
	sed -i '/reresolve-dns/d' /etc/storage/cron/crontabs/$http_username
	cat >> /etc/storage/cron/crontabs/$http_username << EOF
*/1 * * * * /bin/sh /usr/bin/reresolve-dns.sh C >/dev/null 2>&1
}


stop_wg() {
	logger -t "WIREGUARD" "正在关闭wireguard"
	wg-quick down /tmp/wg0.conf
	}



case $1 in
start)
	start_wg
	;;
stop)
	stop_wg
	;;
*)
	echo "check"
	#exit 0
	;;
esac
