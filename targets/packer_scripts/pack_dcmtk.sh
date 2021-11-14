#!/bin/bash
set -e
source ./config.sh

SHAREDIR="../packed_targets/nyx_dcmtk/"

if [ "$1" = "docker" ]; then
  DEFAULT_CONFIG="--path_to_default_config ../default_config_kernel.ron"
else 
  DEFAULT_CONFIG=""
fi

python3 $PACKER ../setup_scripts/build/dcmtk/dcmtk/build/bin/dcmqrscp $SHAREDIR m64 \
--afl_mode \
--purge \
--nyx_net \
--nyx_net_port 5158 \
-spec ../specs/dicom/ \
--setup_folder ../extra_folders/dcmtk_extra_folder && \
python3 $CONFIG_GEN $SHAREDIR Kernel -s ../specs/dicom/ $DEFAULT_CONFIG
