#!/bin/bash
set -e
source ./config.sh

SHAREDIR="../packed_targets/nyx_openssl/"

if [ "$1" = "docker" ]; then
  DEFAULT_CONFIG="--path_to_default_config ../default_config_kernel.ron"
else 
  DEFAULT_CONFIG=""
fi

python3 $PACKER ../setup_scripts/build/openssl/openssl/apps/openssl $SHAREDIR m64 \
--afl_mode \
--purge \
--nyx_net \
--nyx_net_port 4433 \
-spec ../specs/tls \
--setup_folder ../extra_folders/openssl_extra_folder \
-args 's_server -key /tmp/key.pem -cert /tmp/cert.pem -4 -naccept 1 -no_anti_replay' && \
python3 $CONFIG_GEN $SHAREDIR Kernel -s ../specs/tls/ -d ../dicts/tls.dict $DEFAULT_CONFIG


