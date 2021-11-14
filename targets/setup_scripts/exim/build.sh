
WORKDIR="$PWD/../build/exim"

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

  cp patches/exim.configure.patch $WORKDIR
  cp patches/exim.patch $WORKDIR
  cp patches/log.c.patch $WORKDIR

  mkdir $WORKDIR/exim_install

  export ASAN_OPTIONS=detect_leaks=0

  cd $WORKDIR && \
  git clone https://github.com/Exim/exim && \
  cd exim && \
  git checkout 38903fb && \
  patch -p1 < $WORKDIR/log.c.patch && \
  cd src; mkdir Local; cp src/EDITME Local/Makefile && \
  sed -i "s/kafl/$USER/g" $WORKDIR/exim.patch
  cd Local; patch -p1 < $WORKDIR/exim.patch; cd .. && \
  make CC="$CC $ASAN" clean all -j && \
  sed -i '/^#define EXIM_UID/d' $WORKDIR/exim/src/build-Linux-x86_64/config.h && \
  sed -i '/^#define EXIM_GID/d' $WORKDIR/exim/src/build-Linux-x86_64/config.h && \
  echo "#define EXIM_UID              1000" >> $WORKDIR/exim/src/build-Linux-x86_64/config.h && \
  echo "#define EXIM_GID              1000" >> $WORKDIR/exim/src/build-Linux-x86_64/config.h && \
  make CC="$CC $ASAN" all -j && \
  ASAN_OPTIONS=detect_leaks=0 make CC="$CC $ASAN -fPIC" INSTALL_ARG="-no_symlink -no_chown" DESTDIR=$WORKDIR/exim_install install -j && \
  cd $WORKDIR/exim_install/usr/exim && \
  patch -p1 < ../../../exim.configure.patch && \
  echo "smtp_enforce_sync = false" >> configure_fuzz && \
  echo "daemon_smtp_ports = 2225" >> configure_fuzz && \
  cat configure >> configure_fuzz && \
  cp $WORKDIR/exim_install/usr/exim/configure_fuzz $ROOT/../../extra_folders/exim/configure && \
  echo "SUCCESS"

else
  echo "Error: AFL clang compiler not found:\n\t$CC\n\t$CPP"
fi

# Target is located at /tmp/exim_build/exim/src/build-Linux-x86_64/exim
