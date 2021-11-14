WORKDIR="$PWD/../build/pureftpd"

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
  git clone https://github.com/jedisct1/pure-ftpd.git && \
  cd pure-ftpd && \
  git checkout c21b45f && \
  patch -p1 < ${ROOT}/fuzzing.patch && \
  sh autogen.sh && \
  CC="$CC $ASAN -Wno-deprecated" CXX="$CPP $ASAN -Wno-deprecated" ./configure --without-privsep -without-capabilities && \
  make && \
  echo "SUCCESS"


else
  echo "Error: AFL clang compiler not found:\n\t$CC\n\t$CPP"
fi


# /tmp/lightftp_build/LightFTP-gcov/Source/Release/fftp
