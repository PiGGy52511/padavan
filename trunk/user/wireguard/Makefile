SRC_NAME = wireguard
THISDIR = $(shell pwd)

all: 

config_test:

configure:

clean:

romfs:
	$(ROMFSINST) -p +x $(THISDIR)/wireguard.sh /usr/bin/wireguard.sh
	$(ROMFSINST) $(THISDIR)/wg0.conf /etc_ro/wg0.conf
	$(ROMFSINST) -p +x $(THISDIR)/reresolve-dns.sh /usr/bin/reresolve-dns.sh
