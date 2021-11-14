
WORKDIR="$PWD/../build/dcmtk"

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
  git clone https://github.com/DCMTK/dcmtk && \
  cd dcmtk && \
  git checkout 7f8564c && \
  sed "s#afl-clang-fast#$CC#" $ROOT/fuzzing.patch.template > fuzzing.patch && \
  patch -p1 < fuzzing.patch && \
  sed -e "6iSET(CMAKE_C_FLAGS $ASAN)" -i CMakeLists.txt
  sed -e "7iSET(CMAKE_CXX_FLAGS $ASAN)" -i CMakeLists.txt
  mkdir build && cd build && \
  cmake .. && \
  cmake .. && \
  make dcmqrscp && \
  echo "SUCCESS"
else
  echo "Error: AFL clang compiler not found:\n\t$CC\n\t$CPP"
fi


# /tmp/dcmtk_build/dcmtk/build/bin/dcmqrscp