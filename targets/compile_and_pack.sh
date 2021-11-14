cd setup_scripts && \
sh build_all.sh no_asan && \
cd - && \
cd packer_scripts/ && \
sh pack_all.sh && \
cd -
