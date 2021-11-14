
WORKDIR="$PWD/../build/openssl"

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
  cp cert/*.pem $WORKDIR
  cd $WORKDIR && \
  git clone https://github.com/openssl/openssl.git && \
  cd openssl && \
  cp ../*.pem ./ && \
  git checkout 0437435a && \
  CC="$CC" CXX="$CPP" ./config no-shared $ASAN && \
  make -j 8

else
  echo "Error: AFL clang compiler not found:\n\t$CC\n\t$CPP"
fi


# Target is located at /tmp/openssl_build/openssl/apps/openssl
