echo "Executing exim Setup Script" | ./hcat 

mkdir /var/
mkdir /var/mail
chmod 1777 /var/mail

mkdir /usr/
mkdir /usr/exim/
./hget setup/configure /usr/exim/configure

./hget setup/aliases /etc/aliases

./hget setup/hosts /etc/hosts


mkdir /var/
mkdir /var/spool
mkdir /var/spool/exim
mkdir /var/spool/exim/log/



touch /var/spool/exim/log/mainlog
touch /var/spool/exim/log/paniclog

touch /etc/services

chown -R ubuntu /var/

mkdir /var/mail
chmod 1777 /var/mail

echo "exim Setup Script finished" | ./hcat 

