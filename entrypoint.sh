#!/bin/sh

/etc/init.d/epson_devicecontrollogserviced restart
/etc/init.d/epson_pcsvcd restart
/usr/sbin/cupsd -f
