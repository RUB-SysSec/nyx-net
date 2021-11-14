set -e
target=$1
file=$2
echo "target spec is: $target, file is: $file"
pushd "../$target/"
NYX_INTERPRETER_BUILD_PATH=/home/kafl/nyx_fuzzer_snapshot/structured_fuzzer/interpreter/ python3 nyx_net_spec.py
popd
clang main.c -I../../../../agents/ -fsanitize=address -ggdb -DTARGET_PATH="\"../$target/build/interpreter.h\"" -DTARGET_SPEC="\"$target\""
./a.out $file.bin > out
md5sum ./out $file