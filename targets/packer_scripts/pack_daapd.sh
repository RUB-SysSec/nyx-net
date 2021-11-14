#!/bin/bash
set -e
source ./config.sh

SHAREDIR="../packed_targets/nyx_forked-daapd"

if [ "$1" = "docker" ]; then
  DEFAULT_CONFIG="--path_to_default_config ../default_config_vm.ron"
else 
  DEFAULT_CONFIG=""
fi

python3 $PACKER ../setup_scripts/build/daapd/forked-daapd/src/forked-daapd $SHAREDIR m64 \
--purge \
--nyx_net \
--nyx_net_port 3689 \
-spec ../specs/daap \
-args '-d 0 -c /tmp/forked-daapd.conf -f' \
--setup_folder ../extra_folders/daapd --afl_mode && \
python3 $CONFIG_GEN $SHAREDIR Snapshot -m 1024 -s ../specs/daap/ -n 600000000 $DEFAULT_CONFIG