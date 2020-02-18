#!/bin/sh

mkdir -p /usr/share/cups/model/Epson
cp -av ${HOME}/tmx-cups/ppd/tm-* /usr/share/cups/model/Epson
chmod -f 644 /usr/share/cups/model/Epson/*
      

cp -av pcs/etc/init.d/* /etc/init.d/
cp -av pcs/etc/udev/rules.d/* /etc/udev/rules.d/
#cp -av opt/epson_pcs /opt/
cp -av pcs/opt /

SRV_NAME=epson_pcsvcd
LOG_SRV_NAME=epson_devicecontrollogserviced
update-rc.d $LOG_SRV_NAME start 20 2 3 4 5 . stop 80 0 1 6 .
update-rc.d $SRV_NAME start 20 2 3 4 5 . stop 80 0 1 6 .
/etc/init.d/$LOG_SRV_NAME start
/etc/init.d/$SRV_NAME start

# these are symlinks, make sure they get copied correctly
cp -av pcs/usr/sbin/* /usr/sbin
cp -av var/*  /var/ 

cp -av tmx-cups-backend/usr/lib/* /usr/lib/
cp -av tmx-cups-backend/usr/sbin/* /usr/sbin/
