FROM debian:stretch

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update \
    && apt-get -y install \
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
        usbutils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

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
COPY rootfs/usr/share/ppd/Epson/tm-* /usr/share/ppd/Epson/
COPY rootfs/etc/cups/printers.conf /etc/cups/
COPY rootfs/etc/cups/ppd/TM-T88V.ppd /etc/cups/ppd/

RUN chmod 640 /etc/cups/ppd/TM-T88V.ppd \
    && chgrp lp /etc/cups/ppd/TM-T88V.ppd

RUN dpkg -i \
      /pcs-3.17.0.0-1.amd64.deb \
      /tmx-cups-backend-1.2.4.0-1.amd64.deb \
      /tmx-cups_1.2.2-1_amd64.deb

RUN /usr/sbin/cupsd \
    && while [ ! -f /var/run/cups/cupsd.pid ]; do sleep 1; done \
    && cupsctl --remote-admin --remote-any --share-printers \
    && kill $(cat /var/run/cups/cupsd.pid)

RUN sed -i 's/631/9631/g' /etc/cups/cupsd.conf

#CMD ["/usr/sbin/cupsd", "-f"]
COPY ./entrypoint.sh .
RUN chmod 755 entrypoint.sh
ENTRYPOINT ./entrypoint.sh
