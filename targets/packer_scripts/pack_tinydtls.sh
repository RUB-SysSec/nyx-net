#!/bin/bash
set -e
source ./config.sh

SHAREDIR="../packed_targets/nyx_tinydtls/"

if [ "$1" = "docker" ]; then
  DEFAULT_CONFIG="--path_to_default_config ../default_config_kernel.ron"
else 
  DEFAULT_CONFIG=""
fi

python3 $PACKER ../setup_scripts/build/tinydtls/tinydtls/tests/dtls-server $SHAREDIR m64 \
--afl_mode \
--purge \
--nyx_net \
--nyx_net_port 20220 \
--nyx_net_udp \
-spec ../specs/dtls  && \
python3 $CONFIG_GEN $SHAREDIR Kernel -s ../specs/dtls/ $DEFAULT_CONFIG

