#!/bin/bash
# This script installs a systemd timer template named WireguardReResolveDNS.(service|timer)
# to run every 30 seconds. Requires that wireguard-tools is installed.

# Enable using e.g. systemctl enable --now wg-reresolve-dns@wg0
# You need to do that separately for each wireguard interface

export NAME=wg-reresolve-dns@
cat >/etc/systemd/system/${NAME}.service <<EOF
[Unit]
Description=${NAME}
[Service]
Type=oneshot
ExecStart=/usr/share/doc/wireguard-tools/examples/reresolve-dns/reresolve-dns.sh %i
EOF

cat >/etc/systemd/system/${NAME}.timer <<EOF
[Unit]
Description=${NAME} timer
[Timer]
Unit=${NAME}%i.service
OnCalendar=*-*-* *:*:00,30
Persistent=true
[Install]
WantedBy=timers.target
EOF
