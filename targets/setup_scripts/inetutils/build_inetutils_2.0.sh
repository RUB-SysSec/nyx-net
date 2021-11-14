# sudo apt-get install gnulib

WORKDIR="$PWD/../build/inetutils"

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
  cd $WORKDIR && \
  #wget http://archive.ubuntu.com/ubuntu/pool/universe/i/inetutils/inetutils_2.0.orig.tar.xz && \
  cp $ROOT/inetutils_2.0.orig.tar.xz ./ && \
  tar xf inetutils_2.0.orig.tar.xz && \
  cd inetutils-2.0/ && \
  CC="$CC $ASAN" CXX="$CPP $ASAN" ./configure && \
  make && \
  echo "SUCCESS"

else
  echo "Error: AFL clang compiler not found:\n\t$CC\n\t$CPP"
fi

# /tmp/dnsmasq_build/dnsmasq/src/dnsmasq
