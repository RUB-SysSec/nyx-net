#!/bin/bash
set -e
source ./config.sh

SHAREDIR="../packed_targets/nyx_expat/"

if [ "$1" = "docker" ]; then
  DEFAULT_CONFIG="--path_to_default_config ../default_config_kernel.ron"
else
  DEFAULT_CONFIG=""
fi

# --debug_stdin_stderr \
# --nyx_net_debug_mode \
python3 $PACKER ../setup_scripts/build/expat/libexpat_repo/expat/build/xmlwf/xmlwf $SHAREDIR m64 \
--afl_mode \
--purge \
-spec ../specs/expat/ \
--setup_folder ../extra_folders/expat_extra_folder && \
python3 $CONFIG_GEN $SHAREDIR Kernel -s ../specs/expat/ $DEFAULT_CONFIG
