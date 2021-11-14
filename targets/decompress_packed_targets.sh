cd packed_targets
rm -r nyx_*
rm init.cpio.gz
rm bzImage-linux-4.15-rc7
rm default_config_kernel.ron
rm default_config_vm.ron
cat archives/packed_targets_1 archives/packed_targets_2 archives/packed_targets_3 > packed_targets.zip 
unzip packed_targets.zip
cd -
