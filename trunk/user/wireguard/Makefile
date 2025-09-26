SRC_NAME = wireguard
THISDIR = $(shell pwd)

all: 

config_test:

configure:

clean:

romfs:
	$(ROMFSINST) -p +x $(THISDIR)/wireguard.sh /usr/bin/wireguard.sh
	$(ROMFSINST) /etc_ro/wg0.conf
