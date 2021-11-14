#!/bin/bash
set -e
source ./config.sh

SHAREDIR="../packed_targets/nyx_kamailio/"

if [ "$1" = "docker" ]; then
  DEFAULT_CONFIG="--path_to_default_config ../default_config_kernel.ron"
else 
  DEFAULT_CONFIG=""
fi

python3 $PACKER ../setup_scripts/build/kamalio/kamailio/src/kamailio $SHAREDIR m64 \
--afl_mode \
--purge \
--nyx_net \
--nyx_net_udp \
--nyx_net_port 5060 \
-spec ../specs/sip \
-args '-f /tmp/kamailio-basic.cfg -L /tmp/modules -Y /tmp/runtime_dir -n 1 -D -E' \
--setup_folder ../extra_folders/kamalio \
--ignore_udp_port 5068 \
--set_client_udp_port 5061 \
--add_pre_process ../setup_scripts/build/kamalio/pjproject/pjsip-apps/bin/pjsua-x86_64-unknown-linux-gnu \
--add_pre_process_args "--local-port=5068 --id sip:33@127.0.0.1 --registrar sip:127.0.0.1 --proxy sip:127.0.0.1 --realm '*' --username 33 --password 33 --auto-answer 200 --auto-play --play-file /tmp/StarWars3.wav --auto-play-hangup --duration=10 --use-cli --no-cli-console --cli-telnet-port=34254 >/dev/null 2>&1"
python3 $CONFIG_GEN $SHAREDIR Kernel -m 1024 -s ../specs/sip/ $DEFAULT_CONFIG

