#!/bin/bash
#set -e

if [ "$1" = "docker" ]; then
  OPTION="docker"
else 
  OPTION=""
fi

./pack_bftpd.sh $OPTION
./pack_daapd.sh $OPTION
./pack_dcmtk.sh $OPTION
./pack_dnsmasq.sh $OPTION
./pack_exim.sh $OPTION
./pack_kamailio.sh $OPTION
./pack_lightftp.sh $OPTION
./pack_live555.sh $OPTION
./pack_openssl.sh $OPTION
./pack_openssh.sh $OPTION
./pack_proftpd.sh $OPTION
./pack_pureftpd.sh $OPTION
./pack_tinydtls.sh $OPTION
