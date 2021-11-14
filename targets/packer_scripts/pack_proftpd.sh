#!/bin/bash
set -e
source ./config.sh

SHAREDIR="../packed_targets/nyx_proftpd/"

if [ "$1" = "docker" ]; then
  DEFAULT_CONFIG="--path_to_default_config ../default_config_kernel.ron"
else 
  DEFAULT_CONFIG=""
fi

python3 $PACKER ../setup_scripts/build/proftpd/proftpd/proftpd $SHAREDIR m64 \
--purge \
--nyx_net \
--nyx_net_port 21 \
-spec ../specs/ftp \
-args "-n -c /tmp/basic.conf -X" \
--setup_folder ../extra_folders/proftpd_extra_folder \
--afl_mode && \
python3 $CONFIG_GEN $SHAREDIR Kernel -s ../specs/ftp/proftpd/ -d ../dicts/proftpd.dict $DEFAULT_CONFIG


