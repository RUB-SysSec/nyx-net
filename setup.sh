#!/bin/bash
set -e

echo "[?] Checking submodules ..."
git submodule init
git submodule update

#git submodule update --init --recursive

echo "[?] Checking QEMU-NYX ..."
if [ ! -f "qemu-nyx/x86_64-softmmu/qemu-system-x86_64" ]; then
	echo "[*] Compiling QEMU-NYX ..."
	cd qemu-nyx
	sh compile_qemu_nyx.sh
	cd -
fi

echo "[?] Checking NYX-Net fuzzer ..."
if [ ! -f "fuzzer/rust_fuzzer/target/release/rust_fuzzer" ]; then
	echo "[*] Compiling NYX-Net fuzzer ..."
	cd fuzzer/
	./setup.sh
	cd ..
fi

echo "[*] Compiling AFL clang compiler ..."
cd packer/packer/compiler
# https://issuehint.com/issue/aflnet/aflnet/81
# llvm should be <= 12
LLVM_CONFIG=llvm-config-10 CC=clang-10 CXX=clang++-10 make
cd -

echo "[*] Preparing Initramfs..."
cd packer/linux_initramfs/
sh pack.sh
cd -

echo "[*] Done ... "
