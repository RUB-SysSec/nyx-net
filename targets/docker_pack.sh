
current_user=$USER

sudo docker build ../ -t nyx-net-packing && \
sudo docker run --name nyx-net-packing-container -v /tmp:/container/directory nyx-net-packing /bin/sh targets/docker/prepare_targets.sh && \
sudo docker cp nyx-net-packing-container:/home/ubuntu/targets/packed_targets/packed_targets.zip /tmp/ && \
sudo docker cp nyx-net-packing-container:/home/ubuntu/targets/packed_targets/packed_targets_asan.zip /tmp/ && \
sudo docker rm nyx-net-packing-container && \

sudo chown $current_user:$current_user /tmp/packed_targets.zip && \
sudo chown $current_user:$current_user /tmp/packed_targets_asan.zip && \
cp /tmp/packed_targets.zip packed_targets/packed_targets.zip && \
cp /tmp/packed_targets_asan.zip packed_targets/packed_targets_asan.zip