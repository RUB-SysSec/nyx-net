import sys, os
sys.path.insert(1, os.getenv("NYX_INTERPRETER_BUILD_PATH"))

from spec_lib.graph_spec import *
from spec_lib.data_spec import *
from spec_lib.graph_builder import *
from spec_lib.generators import opts,flags,limits,regex

import jinja2

s = Spec()
s.use_std_lib = False
s.includes.append("\"custom_includes.h\"")
s.includes.append("\"nyx.h\"")
s.interpreter_user_data_type = "socket_state_t*"

with open("send_code.include.c") as f:
    send_code = f.read()

d_byte = s.data_u8("u8", generators=[limits(0x00, 0xff)])

method="(OPTIONS|DESCRIBE|SETUP|TEARDOWN|PLAY|PAUSE|GET_PARAMETER|SET_PARAMETER|REDIRECT|RECORD|ANNOUNCE|REGISTER|DREGISTER|GET|POST)"
url="rtsp://127\\.0\\.0\\.1:8554/(wavAudioTest|ac3AudioTest|matroskaFileTest|webmFileTest)(/track1)?"
prot="RTSP/1\\.0"
req = method+" "+url+" "+prot+"\\r\\n"

cseq="CSeq: (1|2|3|4|5|6|7|8|9|[0-9]+)"
useragent="User-Agent: \\./testRTSPClient \\(LIVE555 Streaming Media v2018\\.08\\.28\\)"
accept="Accept: application/sdp"
transport="Transport: (RTP/AVP/TCP|RAW/RAW/UDP|MP2T/H2221/UDP);unicast;client_port=37952-37953" # add: destination= interleaved=
rng="Range: npt=(0\\.000-|9)"
session="Session: 000022B8"
field="(%s|%s|%s|%s|%s|%s)"%(cseq,useragent,accept,transport,rng,session)
fields = "((%s\\r\\n)*%s)?"%(field,field)
pkt = req+fields

d_bytes = s.data_vec("pkt_content", d_byte, size_range=(0,1<<12))#, generators=[regex(pkt)])

n_pkt = s.node_type("packet", interact=True, data=d_bytes, code=send_code)

snapshot_code="""
//hprintf("ASKING TO CREATE SNAPSHOT\\n");
kAFL_hypercall(HYPERCALL_KAFL_CREATE_TMP_SNAPSHOT, 0);
kAFL_hypercall(HYPERCALL_KAFL_USER_FAST_ACQUIRE, 0);
//hprintf("RETURNING FROM SNAPSHOT\\n");
vm->ops_i -= OP_CREATE_TMP_SNAPSHOT_SIZE;
"""
n_close = s.node_type("create_tmp_snapshot", code=snapshot_code)

s.build_interpreter()

import msgpack
serialized_spec = s.build_msgpack()
with open("nyx_net_spec.msgp","wb") as f:
    f.write(msgpack.packb(serialized_spec))


def split_packets(data):
        return [["rtsp_packet", d] for d in data.split(b"\r\n\r\n") if len(d) > 0]

import pyshark
import glob

def stream_to_bin(path,stream):
    nodes = split_packets(stream)

    for (ntype, content) in nodes:
        b.packet(content)
    b.write_to_file(path+".bin")

for path in glob.glob("pcaps/*.pcap"):
    b = Builder(s)
    cap = pyshark.FileCapture(path, display_filter="tcp.dstport eq 8554")

    #ipdb.set_trace()
    stream = b""
    for pkt in cap:
        #print("LEN: ", repr((pkt.tcp.len, int(pkt.tcp.len))))
        if int(pkt.tcp.len) > 0:
            stream+=pkt.tcp.payload.binary_value
        stream_to_bin(path, stream)
    cap.close()

for path in glob.glob("raw_streams/*.raw"):
    b = Builder(s)
    with open(path,mode='rb') as f:
        stream_to_bin(path, f.read())

