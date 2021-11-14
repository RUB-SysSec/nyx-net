#!/bin/bash
set -e
source ./config.sh

SHAREDIR="../packed_targets/nyx_openssh/"

if [ "$1" = "docker" ]; then
  DEFAULT_CONFIG="--path_to_default_config ../default_config_kernel.ron"
else 
  DEFAULT_CONFIG=""
fi

LD_LIBRARY_PATH= python=../setup_scripts/build/openssh-bin/sshd python3 $PACKER ../setup_scripts/build/openssh-bin/sshd $SHAREDIR m64 \
--afl_mode \
--purge \
--nyx_net \
--nyx_net_port 22 \
-spec ../specs/ssh \
--setup_folder ../extra_folders/openssh \
-args '-d -e -p 22 -r -f sshd_config'  && \
python3 $CONFIG_GEN $SHAREDIR Kernel -m 1024 -s ../specs/ssh/ -d ../dicts/ssh.dict $DEFAULT_CONFIG


