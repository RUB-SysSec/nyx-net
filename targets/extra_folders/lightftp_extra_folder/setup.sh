echo "Executing lightftp Setup Script" | ./hcat 

mkdir /tmp/ftpdir
echo YOLO > /tmp/ftpdir/YOLO
mkdir /tmp/ftpdir/BLUB
echo BLA > /tmp/ftpdir/BLUB/BLA

mkdir certificate
./hget setup/certificate/my.crt certificate/my.crt
./hget setup/certificate/my.key certificate/my.key
./hget setup/certificate/my.pem certificate/my.pem

./hget setup/fftp.conf fftp.conf

echo "lightftp Setup Script finished" | ./hcat 

