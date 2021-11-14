FROM ubuntu:18.04

RUN apt-get update

RUN apt-get install -y sudo build-essential  libgtk-3-dev llvm clang python3-pip pax-utils autoconf cmake libpcre3-dev libdb5.3-dev libgnutls28-dev \
    openssl \
    graphviz-dev \
    git \
    python-pip \
    python-jinja2 \
    wget \
    nano \
    net-tools \
    vim \
    bison \
    flex \
    autotools-dev autoconf automake libtool gettext gawk \
    gperf antlr3 libantlr3c-dev libconfuse-dev libunistring-dev libsqlite3-dev \
    libavcodec-dev libavformat-dev libavfilter-dev libswscale-dev libavutil-dev \
    libasound2-dev libmxml-dev libgcrypt20-dev libavahi-client-dev zlib1g-dev \
    libevent-dev libplist-dev libsodium-dev libjson-c-dev libwebsockets-dev \
    libcurl4-openssl-dev avahi-daemon python3-jinja2 zip cpio

RUN pip install msgpack pyshark ipdb
RUN pip3 install msgpack pyshark ipdb

RUN pip3 install msgpack pyshark ipdb

RUN groupadd ubuntu && \
    useradd -rm -d /home/ubuntu -s /bin/bash -g ubuntu -G sudo -u 1000 ubuntu -p "$(openssl passwd -1 ubuntu)"

USER ubuntu
WORKDIR /home/ubuntu
ENV USER="ubuntu"

RUN mkdir -p targets/setup_scripts/build
RUN mkdir -p packed_targets/


COPY --chown=ubuntu:ubuntu targets/docker/default_config_kernel.ron /home/ubuntu/targets/packed_targets/default_config_kernel.ron
COPY --chown=ubuntu:ubuntu targets/docker/default_config_vm.ron /home/ubuntu/targets/packed_targets/default_config_vm.ron

COPY --chown=ubuntu:ubuntu targets/docker /home/ubuntu/targets/docker
COPY --chown=ubuntu:ubuntu targets/dicts /home/ubuntu/targets/dicts
COPY --chown=ubuntu:ubuntu targets/extra_folders /home/ubuntu/targets/extra_folders
COPY --chown=ubuntu:ubuntu targets/specs /home/ubuntu/targets/specs
COPY --chown=ubuntu:ubuntu targets/packer_scripts /home/ubuntu/targets/packer_scripts

COPY --chown=ubuntu:ubuntu targets/setup_scripts/build_all.sh /home/ubuntu/targets/setup_scripts/build_all.sh
COPY --chown=ubuntu:ubuntu targets/setup_scripts/bftpd /home/ubuntu/targets/setup_scripts/bftpd
COPY --chown=ubuntu:ubuntu targets/setup_scripts/daapd /home/ubuntu/targets/setup_scripts/daapd
COPY --chown=ubuntu:ubuntu targets/setup_scripts/dcmtk /home/ubuntu/targets/setup_scripts/dcmtk
COPY --chown=ubuntu:ubuntu targets/setup_scripts/dnsmasq /home/ubuntu/targets/setup_scripts/dnsmasq
COPY --chown=ubuntu:ubuntu targets/setup_scripts/exim /home/ubuntu/targets/setup_scripts/exim
COPY --chown=ubuntu:ubuntu targets/setup_scripts/kamalio /home/ubuntu/targets/setup_scripts/kamalio
COPY --chown=ubuntu:ubuntu targets/setup_scripts/lightftp /home/ubuntu/targets/setup_scripts/lightftp
COPY --chown=ubuntu:ubuntu targets/setup_scripts/live555 /home/ubuntu/targets/setup_scripts/live555
COPY --chown=ubuntu:ubuntu targets/setup_scripts/openssh /home/ubuntu/targets/setup_scripts/openssh
COPY --chown=ubuntu:ubuntu targets/setup_scripts/openssl /home/ubuntu/targets/setup_scripts/openssl
COPY --chown=ubuntu:ubuntu targets/setup_scripts/proftpd /home/ubuntu/targets/setup_scripts/proftpd
COPY --chown=ubuntu:ubuntu targets/setup_scripts/pureftpd /home/ubuntu/targets/setup_scripts/pureftpd
COPY --chown=ubuntu:ubuntu targets/setup_scripts/tinydtls /home/ubuntu/targets/setup_scripts/tinydtls

COPY --chown=ubuntu:ubuntu packer /home/ubuntu/packer


WORKDIR /home/ubuntu/

RUN cp targets/docker/nyx.ini packer/packer/

RUN mkdir qemu-nyx/
RUN mkdir qemu-nyx/x86_64-softmmu/
RUN touch qemu-nyx/x86_64-softmmu/qemu-system-x86_64

WORKDIR /home/ubuntu/packer/linux_initramfs/
RUN sh pack.sh

WORKDIR /home/ubuntu/packer/packer/compiler/

RUN make clean
RUN make

WORKDIR /home/ubuntu/targets/setup_scripts/

RUN mkdir -p build
RUN sh ./build_all.sh asan
RUN mv build build_asan
RUN mkdir -p build

RUN sh ./build_all.sh no_asan

WORKDIR /home/ubuntu/

RUN echo "Done"
