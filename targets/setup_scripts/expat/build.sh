WORKDIR="$PWD/../build/expat"

ROOT=$PWD
export CC=$ROOT/../../../packer/packer/compiler/afl-clang-fast
export CXX=$ROOT/../../../packer/packer/compiler/afl-clang-fast++

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

if test -f "$CC" && test -f "$CXX"; then

  if [ "$1" = "asan" ]; then
    CFLAGS="-fsanitize=address"
    CXXFLAGS="-fsanitize=address"
    LDFLAGS="-fsanitize=address"
  else
    CFLAGS=""
    CXXFLAGS=""
    LDFLAGS=""
  fi

  export CFLAGS="$CFLAGS -O0 -g -fno-inline"
  export CXXFLAGS=$CFLAGS
  export LDFLAGS=$LDFLAGS

  rm -rf $WORKDIR

  mkdir $WORKDIR

  cp hashsalt.patch $WORKDIR
  cp bufsize.patch $WORKDIR

  cd $WORKDIR && \
  git clone https://github.com/libexpat/libexpat.git libexpat_repo && \
  cd libexpat_repo && \
  patch -p1 < ../hashsalt.patch && \
  patch -p1 < ../bufsize.patch && \
  cd expat && \
  mkdir build && cd build && \
  cmake \
    -DEXPAT_BUILD_TOOLS=ON \
    -DEXPAT_BUILD_EXAMPLES=OFF \
    -DEXPAT_BUILD_TESTS=OFF \
    -DEXPAT_SHARED_LIBS=OFF \
    -DEXPAT_BUILD_DOCS=OFF \
    -DEXPAT_BUILD_PKGCONFIG=OFF \
    -DEXPAT_DEV_URANDOM=OFF \
    .. && \
  make && \
  echo "SUCCESS"
else
  echo "Error: AFL clang compiler not found:\n\t$CC\n\t$CPP"
fi
