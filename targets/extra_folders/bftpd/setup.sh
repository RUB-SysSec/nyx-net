echo "Executing bftpd Setup Script" | ./hcat 


mkdir /home/ubuntu/ftpshare
chown -R ubuntu:ubuntu /home/ubuntu/ftpshare

./hget setup/basic.conf /tmp/basic.conf

echo "bftpd Setup Script finished" | ./hcat 

