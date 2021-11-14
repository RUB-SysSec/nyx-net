WORKDIR="$PWD/../build/kamalio"

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

  cp kamailio.patch $WORKDIR
  cp pjsip.patch $WORKDIR

  cd $WORKDIR && \
  git clone https://github.com/kamailio/kamailio.git && \
  cd kamailio && \
  git checkout 2648eb3 && \
  patch -p1 < $WORKDIR/kamailio.patch && \
  CC="$CC $ASAN" make cfg && \
  CC="$CC $ASAN" make all -j 8


  cd $WORKDIR && \
  git clone https://github.com/pjsip/pjproject.git && \
  cd pjproject && \
  git checkout bba95b8 && \
  patch -p1 < $WORKDIR/pjsip.patch && \
  ./configure && \
  make dep && make clean && make -j 8 && \ 
  cp $WORKDIR/kamailio/src/lib/srdb1/libsrdb1.so.1.0  $ROOT/../../extra_folders/kamalio/libsrdb1.so.1.0 && \
  cd $WORKDIR/kamailio/src/ && tar -zcvf modules.tar.gz modules && \
  cp modules.tar.gz $ROOT/../../extra_folders/kamalio/modules.tar.gz && \
  echo "SUCCESS"

else
  echo "Error: AFL clang compiler not found:\n\t$CC\n\t$CPP"
fi


