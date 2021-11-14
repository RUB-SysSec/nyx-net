#!/bin/bash
set -e
source ./config.sh

SHAREDIR="../packed_targets/nyx_bftpd/"

if [ "$1" = "docker" ]; then
  DEFAULT_CONFIG="--path_to_default_config ../default_config_kernel.ron"
else 
  DEFAULT_CONFIG=""
fi

python3 $PACKER ../setup_scripts/build/bftpd/bftpd/bftpd $SHAREDIR m64 \
--afl_mode \
--purge \
--nyx_net \
--nyx_net_port 21 \
-spec ../specs/ftp \
-args "-D -c /tmp/basic.conf" \
--setup_folder ../extra_folders/bftpd  && \
python3 $CONFIG_GEN $SHAREDIR Kernel -s ../specs/ftp/proftpd/ -d ../dicts/bftpd.dict $DEFAULT_CONFIG
