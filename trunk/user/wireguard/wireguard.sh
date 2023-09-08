#!/bin/sh

start_wg() {
	localip="$(nvram get wireguard_localip)"
	privatekey="$(nvram get wireguard_localkey)"
	peerkey="$(nvram get wireguard_peerkey)"
	peerip="$(nvram get wireguard_peerip)"
 	presharedkey="$(nvram get wireguard_presharedkey)"
  	allowedips="$(nvram get wireguard_allowedips)"
	logger -t "WIREGUARD" "正在启动wireguard"
	cp /etc/wg0.conf /tmp/wg0.conf
 	sed -i "s/WG_PRIVATEKEY/$privatekey/g" /tmp/wg0.conf
 	sed -i "s/localip/$localip/g" /tmp/wg0.conf
   	sed -i "s/WG_PUBLICKEY/$peerkey/g" /tmp/wg0.conf
     	sed -i "s/WG_ENDPOINT/$peerip/g" /tmp/wg0.conf
       	sed -i "s/WG_PRESHAREDKEY/$presharedkey/g" /tmp/wg0.conf
	sed -i "s/WG_ALLOWEDIPS/$allowedips/g" /tmp/wg0.conf
 	wg-quick up /tmp/wg0.conf wg0
	iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE
	iptables -A FORWARD -i wg0 -j ACCEPT
	iptables -A FORWARD -o wg0 -j ACCEPT
}


stop_wg() {
	logger -t "WIREGUARD" "正在关闭wireguard"
 	wg-quick down /tmp/wg0.conf wg0
	iptables -t nat -D POSTROUTING -o wg0 -j MASQUERADE
	iptables -D FORWARD -i wg0 -j ACCEPT
	iptables -D FORWARD -o wg0 -j ACCEPT 
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
