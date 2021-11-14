#!/bin/bash
set -e
source ./config.sh

SHAREDIR="../packed_targets/nyx_dnsmasq/"

if [ "$1" = "docker" ]; then
  DEFAULT_CONFIG="--path_to_default_config ../default_config_kernel.ron"
else 
  DEFAULT_CONFIG=""
fi

python3 $PACKER ../setup_scripts/build/dnsmasq/dnsmasq/src/dnsmasq $SHAREDIR m64 \
--afl_mode \
--purge \
--nyx_net \
--nyx_net_port 5353 \
-spec ../specs/dns/ \
--setup_folder ../extra_folders/dnsmasq_extra_folder && \
python3 $CONFIG_GEN $SHAREDIR Kernel -s ../specs/dns/ $DEFAULT_CONFIG
