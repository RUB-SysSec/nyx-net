cd targets/packer_scripts/
./pack_all.sh docker
cd -

cp packer/linux_initramfs/bzImage-linux-4.15-rc7 targets/packed_targets/
cp packer/linux_initramfs/init.cpio.gz targets/packed_targets/

cd targets/packed_targets/
zip -r packed_targets.zip .
cd -

cd targets/packer_scripts/
mv ../setup_scripts/build ../setup_scripts/build_no_asan/
mv ../setup_scripts/build_asan/ ../setup_scripts/build/
./pack_all.sh docker
cd -

cp packer/linux_initramfs/bzImage-linux-4.15-rc7 targets/packed_targets/
cp packer/linux_initramfs/init.cpio.gz targets/packed_targets/

cd targets/packed_targets/
mv packed_targets.zip /tmp/
zip -r packed_targets_asan.zip .

mv /tmp/packed_targets.zip ./packed_targets.zip
