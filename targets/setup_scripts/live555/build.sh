WORKDIR="$PWD/../build/live555"

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
  git clone https://github.com/rgaufman/live555.git && \
  cd live555 && \
  git checkout ceeb4f4 && \
  sed "s#CC_COMPILER#$CC $ASAN#" $ROOT/fuzzing.patch.template > fuzzing.patch2 && \
  sed "s#CPP_COMPILER#$CPP $ASAN#" fuzzing.patch2 > fuzzing.patch && \
  patch -p1 < fuzzing.patch && \
  ./genMakefiles linux && \
  make clean all -j && \
  echo "SUCCESS"

else
  echo "Error: AFL clang compiler not found:\n\t$CC\n\t$CPP"
fi


# /tmp/live555_build/live555/testProgs/testOnDemandRTSPServer
