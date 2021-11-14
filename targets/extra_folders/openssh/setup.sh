echo "Executing openssh Setup Script" | ./hcat

#mkdir /home/ubuntu/ftpshare

./hget setup/sshd_config /tmp/sshd_config
./hget setup/install.tar.gz /tmp/install.tar.gz

mkdir /home/
mkdir /home/ubuntu/
mkdir /home/ubuntu/experiments/
mkdir /home/ubuntu/experiments/openssh/
cd /home/ubuntu/experiments/openssh/
mv /tmp/install.tar.gz install.tar.gz
#echo "Extract stuff" | ./hcat
tar xvf install.tar.gz
# | ./hcat
#echo "DONE" | ./hcat
cd -


#ls /home/ubuntu/experiments/openssh/install/ | ./hcat

echo "openssh Setup Script finished" | ./hcat

