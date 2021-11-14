
WORKDIR="$PWD/../build/proftpd"

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

  mkdir $WORKDIR && \
  cd $WORKDIR && \
  git clone https://github.com/proftpd/proftpd.git && \
  cd proftpd && \
  #git checkout 4017eff8 && \
  CC="$CC $ASAN" CXX="$CPP $ASAN" ./configure --enable-devel=nodaemon:nofork && \
  make -j && \
  echo "SUCCESS"

else
  echo "Error: AFL clang compiler not found:\n\t$CC\n\t$CPP"
fi


# Target is located at /tmp/openssl_build/openssl/apps/openssl
