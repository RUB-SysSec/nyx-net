WORKDIR="$PWD/../build/lightftp"

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
  git clone https://github.com/hfiref0x/LightFTP.git LightFTP-gcov && \
  cd LightFTP-gcov && \
  git checkout 5980ea1 && \
  patch -p1 < ${ROOT}/fuzzing.patch && \
  cd Source/Release && \
  CC="$CC $ASAN" make clean all && \
  echo "SUCCESS"
else
  echo "Error: AFL clang compiler not found:\n\t$CC\n\t$CPP"
fi


# /tmp/lightftp_build/LightFTP-gcov/Source/Release/fftp
