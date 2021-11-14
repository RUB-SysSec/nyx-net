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

with open("send_code_raw.include.c") as f:
    send_code_raw = f.read() 
 

d_byte = s.data_u8("u8", generators=[limits(0x0, 0xff)])

d_bytes = s.data_vec("pkt_content", d_byte, size_range=(0,1<<12), generators=[]) #regex(pkt)

n_pkt = s.node_type("packet", interact=True, data=d_bytes, code=send_code)

n_pkt = s.node_type("packet_raw", interact=True, data=d_bytes, code=send_code_raw)

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
    i = 0
    res = []
    while i*6 < len(data):
        tt,content_len = struct.unpack(">2sI",data[i:i+6])  
        res.append( ["dicom", data[i:i+content_len]] )
        i+=(content_len+6)
    return res


def stream_to_bin(path,stream):
    b.packet(stream)
    b.write_to_file(path+".bin")



import pyshark
import glob
import ipdb


# convert existing pcaps
for path in glob.glob("pcaps/*.pcap"):
    b = Builder(s)
    cap = pyshark.FileCapture(path, display_filter="tcp.dstport eq  45036", include_raw=True, use_json=True)

    #ipdb.set_trace()
    stream = b""
    for pkt in cap:

        #if int(pkt.tcp.payload) > 0:
        #print(dir(pkt.tcp))
        #print("LEN -> " + str(pkt.tcp.len))
        if int(pkt.tcp.len) != 0:
            #print("STREAM -> " + str(pkt.tcp.payload))
            data = bytearray.fromhex(pkt.tcp.payload.replace(":", ""))
            b.packet_raw(data)

            #print("REAL -> " + str(pkt.get_raw_packet()))

        #print("PAYLOAD -> " + str(pkt.tcp.payload))
        #time.sleep(100)
        #ipdb.set_trace()
        #if int(pkt.udp.length) > 0:
        #    data = bytearray.fromhex(pkt.dns_raw.value)
        #    print("LEN: ", repr((pkt.udp.length, data)))
        #    b.packet(data)
    b.write_to_file(path+".bin")
    cap.close()


# convert afl net samples
#for path in glob.glob("raw_streams/*.raw"):
#    b = Builder(s)
#    with open(path,mode='rb') as f:
#        stream_to_bin(path, f.read())
