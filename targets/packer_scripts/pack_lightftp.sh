#!/bin/bash
set -e
source ./config.sh

SHAREDIR="../packed_targets/nyx_lightftp/"

if [ "$1" = "docker" ]; then
  DEFAULT_CONFIG="--path_to_default_config ../default_config_kernel.ron"
else 
  DEFAULT_CONFIG=""
fi

python3 $PACKER ../setup_scripts/build/lightftp/LightFTP-gcov/Source/Release/fftp $SHAREDIR m64 \
--afl_mode \
--purge \
--nyx_net \
--nyx_net_port 2200 \
-spec ../specs/ftp \
-args "fftp.conf 2200" \
--setup_folder ../extra_folders/lightftp_extra_folder && \
python3 $CONFIG_GEN $SHAREDIR Kernel -s ../specs/ftp/lightftpd/ -d ../dicts/ftp.dict $DEFAULT_CONFIG


