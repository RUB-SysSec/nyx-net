#!/bin/bash
set -e
source ./config.sh

SHAREDIR="../packed_targets/nyx_pure-ftpd/"

if [ "$1" = "docker" ]; then
  DEFAULT_CONFIG="--path_to_default_config ../default_config_kernel.ron"
else 
  DEFAULT_CONFIG=""
fi

python3 $PACKER ../setup_scripts/build/pureftpd/pure-ftpd/src/pure-ftpd $SHAREDIR m64 \
--afl_mode \
--purge \
--nyx_net \
--nyx_net_port 21 \
-spec ../specs/ftp \
--setup_folder ../extra_folders/pure-ftpd \
-args "-A " && \
python3 $CONFIG_GEN $SHAREDIR Kernel -s ../specs/ftp/pure-ftpd/ -d ../dicts/bftpd.dict $DEFAULT_CONFIG


