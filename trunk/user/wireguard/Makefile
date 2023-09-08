SRC_NAME = wireguard
THISDIR = $(shell pwd)

all: 

config_test:

configure:

clean:

romfs:
	$(ROMFSINST) -p +x $(THISDIR)/wireguard.sh /usr/bin/wireguard.sh
	$(ROMFSINST) -p +x $(THISDIR)/wg0.conf /etc/wg0.conf
