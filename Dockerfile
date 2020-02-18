FROM debian:stretch

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update && \
    apt-get -y install \
      sudo \
      whois \
      cups \
      cups-bsd \
      cups-client \
      cups-common \
      cups-core-drivers \
      cups-daemon \
      cups-filters \
      cups-filters-core-drivers \
      cups-ipp-utils \
      cups-ppdc \
      cups-server-common \
      foomatic-db-compressed-ppds \
      printer-driver-all \
      openprinting-ppds \
      hpijs-ppds \
      hp-ppd \
      hplip \
      smbclient \
      avahi-daemon

RUN apt-get -y install joe vim

RUN useradd \
	--groups=sudo,lp,lpadmin \
	--create-home \
	--home-dir=/home/print \
	--shell=/bin/bash \
	--password=$(mkpasswd print) \
	print 

COPY deb/pcs-3.17.0.0-1.amd64.deb /
COPY deb/tmx-cups-backend-1.2.4.0-1.amd64.deb /
COPY deb/tmx-cups_1.2.2-1_amd64.deb /
COPY ppd /ppd

RUN dpkg -i /pcs-3.17.0.0-1.amd64.deb /tmx-cups-backend-1.2.4.0-1.amd64.deb /tmx-cups_1.2.2-1_amd64.deb
RUN mkdir -p /usr/share/ppd/Epson && \
    cp -p /ppd/tm-* /usr/share/ppd/Epson && \
    chmod -f 644 /usr/share/ppd/Epson/*

RUN /usr/sbin/cupsd \
  && while [ ! -f /var/run/cups/cupsd.pid ]; do sleep 1; done \
  && cupsctl --remote-admin --remote-any --share-printers \
  && kill $(cat /var/run/cups/cupsd.pid)

CMD ["/usr/sbin/cupsd", "-f"]
