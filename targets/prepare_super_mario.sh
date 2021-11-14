#!/bin/bash
set -e

# compile
if [ ! -f "setup_scripts/super_mario/smbc_nyx" ] || [ ! -f "setup_scripts/super_mario/libnyx.so" ]; then
  cd setup_scripts/super_mario/
  sh compile.sh
  cd -
  if [ ! -f "setup_scripts/super_mario/smbc_nyx" ] || [ ! -f "setup_scripts/super_mario/libnyx.so" ]; then
    echo "Error: something went wrong..."
    exit 1
  fi
fi

# self check
FILE="./extra_folders/super_mario_extra_folder/Super Mario Bros. (JU) (PRG0) [!].nes"
if [ ! -f "$FILE" ]; then
  echo "Error: $FILE not found"
  exit 1
fi

if ! md5sum --status -c <(echo 811b027eaf99c2def7b933c5208636de "$FILE")  ; then
  echo "Error: checksum mismatch ($FILE)"
  exit 1
fi

# pack targets
cd packer_scripts/
./pack_super_mario.sh  0 ../packed_targets/smb_1-1
./pack_super_mario.sh  2 ../packed_targets/smb_1-2
./pack_super_mario.sh  3 ../packed_targets/smb_1-3
./pack_super_mario.sh  4 ../packed_targets/smb_1-4
./pack_super_mario.sh  5 ../packed_targets/smb_2-1
./pack_super_mario.sh  7 ../packed_targets/smb_2-2
./pack_super_mario.sh  8 ../packed_targets/smb_2-3
./pack_super_mario.sh  9 ../packed_targets/smb_2-4
./pack_super_mario.sh  10 ../packed_targets/smb_3-1
./pack_super_mario.sh  11 ../packed_targets/smb_3-2
./pack_super_mario.sh  12 ../packed_targets/smb_3-3
./pack_super_mario.sh  13 ../packed_targets/smb_3-4
./pack_super_mario.sh  14 ../packed_targets/smb_4-1
./pack_super_mario.sh  16 ../packed_targets/smb_4-2
./pack_super_mario.sh  17 ../packed_targets/smb_4-3
./pack_super_mario.sh  18 ../packed_targets/smb_4-4
./pack_super_mario.sh  19 ../packed_targets/smb_5-1
./pack_super_mario.sh  20 ../packed_targets/smb_5-2
./pack_super_mario.sh  21 ../packed_targets/smb_5-3
./pack_super_mario.sh  22 ../packed_targets/smb_5-4
./pack_super_mario.sh  23 ../packed_targets/smb_6-1
./pack_super_mario.sh  24 ../packed_targets/smb_6-2
./pack_super_mario.sh  25 ../packed_targets/smb_6-3
./pack_super_mario.sh  26 ../packed_targets/smb_6-4
./pack_super_mario.sh  27 ../packed_targets/smb_7-1
./pack_super_mario.sh  29 ../packed_targets/smb_7-2
./pack_super_mario.sh  30 ../packed_targets/smb_7-3
./pack_super_mario.sh  31 ../packed_targets/smb_7-4
./pack_super_mario.sh  32 ../packed_targets/smb_8-1
./pack_super_mario.sh  33 ../packed_targets/smb_8-2
./pack_super_mario.sh  34 ../packed_targets/smb_8-3
cd -
