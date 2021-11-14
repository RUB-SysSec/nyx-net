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
	git submodule init
	git submodule update
	cd -
	cd fuzzer/rust_fuzzer
	cargo build --release
	cd -
	cd fuzzer/rust_fuzzer_debug
        cargo build --release
        cd -
fi

echo "[*] Compiling AFL clang compiler ..."
cd packer/packer/compiler
make
cd -

echo "[*] Preparing Initramfs..."
cd packer/linux_initramfs/
sh pack.sh
cd -

echo "[*] Done ... "
