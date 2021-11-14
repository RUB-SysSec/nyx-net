
error () {
  echo "$0: <asan/no_asan>"
  exit 0
}

if test "$#" -ne 1; then
  error
fi

if [ "$1" != "asan" ] && [ "$1" != "no_asan" ] ; then
  error
fi


cd bftpd
sh build.sh "$1"
cd - 

cd daapd
sh build.sh "$1"
cd - 

cd dcmtk
sh build.sh "$1"
cd - 

cd dnsmasq
sh build.sh "$1"
cd - 

cd bftpd
sh build.sh "$1"
cd - 

cd exim
sh build.sh "$1"
cd - 

cd kamalio
sh build.sh "$1"
cd - 

cd lightftp
sh build.sh "$1"
cd - 

cd live555
sh build.sh "$1"
cd - 

cd openssl
sh build.sh "$1"
cd - 

cd openssh
sh build_openssh.sh
cd -

cd proftpd
sh build.sh "$1"
cd - 

cd pureftpd
sh build.sh "$1"
cd - 

cd tinydtls
sh build.sh "$1"
cd - 
