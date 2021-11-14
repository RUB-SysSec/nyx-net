rm -fr SuperMarioBros-C
git clone https://github.com/MitchellSternke/SuperMarioBros-C.git
cd SuperMarioBros-C
git checkout 5bb9205
patch -u -p1 < ../smb.patch
cd - 

gcc \
libnyx.c \
-o libnyx.so -shared -fPIC -Wall -std=gnu11 -Wl,-soname,libnyx.so

g++  ./SuperMarioBros-C/source/Util/Video.cpp \
./SuperMarioBros-C/source/SMB/SMB.cpp \
./SuperMarioBros-C/source/SMB/SMBData.cpp \
./SuperMarioBros-C/source/SMB/SMBEngine.cpp \
./SuperMarioBros-C/source/Main.cpp \
./SuperMarioBros-C/source/Configuration.cpp \
./SuperMarioBros-C/source/Emulation/PPU.cpp \
./SuperMarioBros-C/source/Emulation/Controller.cpp \
./SuperMarioBros-C/source/Emulation/MemoryAccess.cpp \
./SuperMarioBros-C/source/Emulation/APU.cpp \
 -I./ -DNYX -o smbc_nyx -L./ -lSDL2 -L./ -I./ -lnyx

