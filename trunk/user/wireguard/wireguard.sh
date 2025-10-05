#!/bin/sh
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
	cp -f /etc_ro/wg0.conf /etc/storage/wireguard/wg0.conf
 	sed -i "s|WG_PRIVATEKEY|$privatekey|g" /etc/storage/wireguard/wg0.conf
 	sed -i "s|WG_ADDRESS|$address|g" /etc/storage/wireguard/wg0.conf
   	sed -i "s|WG_PUBLICKEY|$publickey|g" /etc/storage/wireguard/wg0.conf
	sed -i "s|WG_ENDPOINT|$endpoint|g" /etc/storage/wireguard/wg0.conf
	sed -i "s|WG_PRESHAREDKEY|$presharedkey|g" /etc/storage/wireguard/wg0.conf
	sed -i "s|WG_ALLOWEDIPS|$allowedips|g" /etc/storage/wireguard/wg0.conf
	sed -i "s|WG_PERSISTENTKEEPALIVE|$persistentkeepalive|g" /etc/storage/wireguard/wg0.conf
	sed -i "s|WG_POSTUP|$postup|g" /etc/storage/wireguard/wg0.conf
	sed -i "s|WG_POSTDOWN|$postdown|g" /etc/storage/wireguard/wg0.conf
 	wg-quick up wg0
}


stop_wg() {
	logger -t "WIREGUARD" "正在关闭wireguard"
	wg-quick down wg0
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
