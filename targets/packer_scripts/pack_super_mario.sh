#!/bin/bash
set -e
source ./config.sh

SHAREDIR="../packed_targets/nyx_super_mario/"

if [ $# -eq 0 ]
then
  LEVEL="0"
else
  LEVEL="$1"

  if [ $1 -ge 35 ];
  then
    echo "Error: unkown Level (0-34)"
    exit 1
  fi

  if [ "$2" != "" ]; then
    SHAREDIR="$2"
  fi
fi

FILE="../extra_folders/super_mario_extra_folder/Super Mario Bros. (JU) (PRG0) [!].nes"
if [ ! -f "$FILE" ]; then
  echo "Error: $FILE not found"
  exit 1
fi

if ! md5sum --status -c <(echo 811b027eaf99c2def7b933c5208636de "$FILE")  ; then
  echo "Error: checksum mismatch ($FILE)"
  exit 1
fi

python3 $PACKER ../setup_scripts/super_mario/smbc_nyx $SHAREDIR m64 \
--purge \
-spec ../specs/super_mario \
-args $LEVEL \
--setup_folder ../extra_folders/super_mario_extra_folder/ \
--delayed_init \
--fast_reload_mode \
--afl_mode && \
python3 $CONFIG_GEN $SHAREDIR Kernel --disable_timeouts 

