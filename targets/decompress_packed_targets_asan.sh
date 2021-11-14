cd packed_targets
rm -r nyx_*
rm init.cpio.gz
rm bzImage-linux-4.15-rc7
rm default_config_kernel.ron
rm default_config_vm.ron
cat archives/packed_targets_asan_1 archives/packed_targets_asan_2 archives/packed_targets_asan_3 > packed_targets_asan.zip 
unzip packed_targets_asan.zip
cd -
