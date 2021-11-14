

#sudo apt-get install antlr3 libantlr3c-dev libconfuse-dev libunistring-dev libsqlite3-dev libavcodec-dev libavformat-dev libavfilter-dev libswscale-dev libavutil-dev libasound2-dev libmxml-dev libgcrypt20-dev libavahi-client-dev zlib1g-dev libevent-dev libplist-dev libsodium-dev libjson-c-dev libwebsockets-dev libcurl4-openssl-dev avahi-daemon

WORKDIR="$PWD/../build/daapd"

ROOT=$PWD
CC=$ROOT/../../../packer/packer/compiler/afl-clang-fast
CPP=$ROOT/../../../packer/packer/compiler/afl-clang-fast++

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

if test -f "$CC" && test -f "$CPP"; then

  if [ "$1" = "asan" ]; then
    ASAN="-fsanitize=address"
  else 
    ASAN=""
  fi

  rm -rf $WORKDIR

  mkdir $WORKDIR
  cp forked-daapd.patch $WORKDIR
  cd $WORKDIR && \
  git clone https://github.com/ejurgensen/forked-daapd.git && \
  cd forked-daapd && \
  git checkout 2ca10d9 && \
  patch -p1 < $WORKDIR/forked-daapd.patch && \
  autoreconf -i && \
  CC="$CC" CFLAGS="-DSQLITE_CORE $ASAN" ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var  --disable-mpd --disable-itunes --disable-lastfm --disable-spotify --disable-verification  --disable-shared --enable-static && \
  make clean all && \
  cd $WORKDIR/forked-daapd/ && \
  tar -zcvf htdocs.tar.gz htdocs/ && \
  cd $ROOT && \
  cp $WORKDIR/forked-daapd/htdocs.tar.gz ../../extra_folders/daapd/ && \
  echo "SUCCESS"


else
  echo "Error: AFL clang compiler not found:\n\t$CC\n\t$CPP"
fi

