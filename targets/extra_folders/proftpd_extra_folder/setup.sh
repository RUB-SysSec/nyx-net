echo "Executing proftpd Setup Script" | ./hcat 


echo "127.0.0.1             localhost" > /etc/hosts

hostname fuzz


./hget setup/basic.conf basic.conf 
mv basic.conf /tmp/basic.conf 

mkdir /home/ubuntu/ftpshare

chown -R ubuntu:ubuntu /home/ubuntu/ftpshare


chown -R ubuntu:ubuntu /home/ubuntu/ftpshare



echo "proftpd Setup Script finished" | ./hcat 

