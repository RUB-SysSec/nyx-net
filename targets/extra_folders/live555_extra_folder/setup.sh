echo "Executing Live555 Setup Script" | ./hcat 
./hget setup/test.aac test.aac
./hget setup/test.ac3 test.ac3
./hget setup/test.mkv test.mkv
./hget setup/test.mp3 test.mp3
./hget setup/test.mpg test.mpg
./hget setup/test.wav test.wav
./hget setup/test.webm test.webm
echo "Live555 Setup Script finished" | ./hcat 
