addgroup fuzzing
adduser --ingroup fuzzing --shell /bin/sh --disabled-password fuzzing
echo "fuzzing:fuzzing" | chpasswd

mkdir /home/fuzzing/
chown -R fuzzing /home/fuzzing/