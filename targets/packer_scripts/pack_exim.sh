#!/bin/bash
set -e
source ./config.sh

SHAREDIR="../packed_targets/nyx_exim/"

if [ "$1" = "docker" ]; then
  DEFAULT_CONFIG="--path_to_default_config ../default_config_vm.ron"
else 
  DEFAULT_CONFIG=""
fi

python3 $PACKER ../setup_scripts/build/exim/exim/src/build-Linux-x86_64/exim $SHAREDIR m64 \
--afl_mode \
--purge \
--nyx_net \
--nyx_net_port 2225 \
-spec ../specs/smtp \
-args '-bdf -oX 2225 -C /usr/exim/configure' \
--setup_folder ../extra_folders/exim && \
python3 $CONFIG_GEN $SHAREDIR Snapshot -m 1024 -s ../specs/smtp/ -d ../dicts/smtp.dict $DEFAULT_CONFIG


