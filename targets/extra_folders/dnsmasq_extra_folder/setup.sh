echo "Executing dnsmasq Setup Script" | ./hcat 

touch /etc/group
adduser nobody
addgroup nogroup


./hget setup/dnsmasq.conf /etc/dnsmasq.conf
./hget setup/resolv.conf  /etc/resolv.conf 

id dnsmasq  | ./hcat

echo /etc/passwd | ./hcat 
cat /etc/passwd | ./hcat

echo /etc/group | ./hcat 
cat /etc/group | ./hcat

#sleep 10

#echo "nobody:*:65534:nobody" >> /etc/group
#echo "nobody:*:0:0:99999:7:::" >> /etc/shadow
#chown dnsmasq.dnsmasq ./target_executable

echo "dnsmasq Setup Script finished" | ./hcat 

