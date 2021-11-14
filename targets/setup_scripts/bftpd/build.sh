WORKDIR="$PWD/../build/bftpd"

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
    ASAN="-fPIE -fsanitize=address"
  else 
    ASAN="-fPIE "
  fi

  rm -rf $WORKDIR

  mkdir $WORKDIR 

  cd $WORKDIR && \
  wget https://phoenixnap.dl.sourceforge.net/project/bftpd/bftpd/bftpd-5.7/bftpd-5.7.tar.gz && \
  tar -zxvf bftpd-5.7.tar.gz && \
  mv bftpd bftpd-gcov && \
  tar -zxvf bftpd-5.7.tar.gz && \
  cd bftpd && \
  patch -p1 < ${ROOT}/fuzzing.patch && \
  CC="$CC $ASAN" make clean all && \
  echo "SUCCESS"
else
  echo "Error: AFL clang compiler not found:\n\t$CC\n\t$CPP"
fi


# /tmp/lightftp_build/LightFTP-gcov/Source/Release/fftp
