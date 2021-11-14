echo "Executing kamalio Setup Script" | ./hcat 


mkdir /tmp/runtime_dir

./hget setup/StarWars3.wav StarWars3.wav
echo "DONE starwars"

./hget setup/modules.tar.gz  /tmp/modules.tar.gz
echo "DONE modules"

./hget setup/kamailio-basic.cfg /tmp/kamailio-basic.cfg
echo "DONE config"


tar xf modules.tar.gz 
echo "DONE unpack"

rm modules.tar.gz 


./hget setup/libsrdb1.so.1.0 libsrdb1.so.1

echo "kamalio setup Script finished" | ./hcat 

