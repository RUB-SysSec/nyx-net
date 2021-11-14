#!/bin/bash
set -e
source ./config.sh

SHAREDIR="../packed_targets/nyx_live555/"

if [ "$1" = "docker" ]; then
  DEFAULT_CONFIG="--path_to_default_config ../default_config_kernel.ron"
else 
  DEFAULT_CONFIG=""
fi

python3 $PACKER ../setup_scripts/build/live555/live555/testProgs/testOnDemandRTSPServer $SHAREDIR m64 \
--afl_mode \
--purge \
--nyx_net \
--nyx_net_port 8554 \
-spec ../specs/rtsp \
-args '8554' \
--setup_folder ../extra_folders/live555_extra_folder && \
python3 $CONFIG_GEN $SHAREDIR Kernel -s ../specs/rtsp/ -d ../dicts/live555.dict $DEFAULT_CONFIG


