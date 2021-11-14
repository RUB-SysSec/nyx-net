echo "Executing openssl Setup Script" | ./hcat 

./hget setup/cert.pem /tmp/cert.pem
./hget setup/key.pem /tmp/key.pem

echo "openssl Setup Script finished" | ./hcat 

