all:

install:
	mkdir -p $(DESTDIR)/usr/bin
	cp tinc-create-config $(DESTDIR)/usr/bin
