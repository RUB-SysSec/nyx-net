echo "Executing forked-daapd Setup Script" | ./hcat

mkdir /var/
mkdir /var/log
mkdir /var/run
mkdir /usr/
mkdir /usr/share
mkdir /usr/share/forked-daapd/

./hget setup/htdocs.tar.gz /usr/share/forked-daapd/htdocs.tar.gz
cd /usr/share/forked-daapd/
tar xf htdocs.tar.gz
cd -

touch /var/log/forked-daapd.log
touch /var/run/forked-daapd.pid


mkdir /home/ubuntu/experiments
mkdir /home/ubuntu/experiments/db

mkdir /root/.config

chown -R ubuntu /home/ubuntu/experiments
chown -R ubuntu /var
chown -R ubuntu /usr/share

chown -R ubuntu /root/.config

./hget setup/mp3.tar.gz mp3.tar.gz

tar xf mp3.tar.gz

#ln -s /home/ubuntu/experiments/MP3 /tmp/MP3

mv /tmp/MP3 /home/ubuntu/experiments/MP3

./hget setup/forked-daapd.conf forked-daapd.conf

vmtouch -t /home/ubuntu/experiments/
#vmtouch -t /tmp/MP3
vmtouch -t /usr/share/forked-daapd/

echo "forked-daapd Setup Script finished" | ./hcat

# disable swap
sudo swapoff -a 