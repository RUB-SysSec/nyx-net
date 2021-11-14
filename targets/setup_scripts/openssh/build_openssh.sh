tar xf openssh-bin.tar.gz -C ../build/
cp ../build/openssh-bin/openssh/sshd_config ../../extra_folders/openssh/
cp -R ../build/openssh-bin/openssh/install/ ../../extra_folders/openssh/install
cd ../../extra_folders/openssh/
tar -zcvf install.tar.gz install/
cd -
exit 1
