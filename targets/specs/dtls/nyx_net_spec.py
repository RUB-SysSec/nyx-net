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

d_byte = s.data_u8("u8", generators=[limits(0x0, 0xff)])

d_bytes = s.data_vec("pkt_content", d_byte, size_range=(0,1<<12), generators=[]) #regex(pkt)

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
    i = 0
    res = []

    """
    print(len(data))

    print(hex(data[0]))
    print(hex(data[1]))
    print(hex(data[2]))
    print(hex(data[3]))
    """

    while i < len(data):
        #tt,
        content_len = struct.unpack("<I",data[i:i+4])[0]  
        #i += 4
        #print(type(content_len))
        #print("packet %d"%(content_len))
        res.append( ["dtls", data[i:i+4+content_len]] )
        i+=(content_len)+4

    """
    for a in res:
        print(hex((a[1][0])))
        print(hex((a[1][1])))
        print(hex((a[1][2])))
        print(hex((a[1][3])))
        print("------------")

    print("DONE %d vs %s"%(len(data), i))
    """
    return res

def stream_to_bin(path,stream):
    nodes = split_packets(stream)

    for (ntype, content) in nodes:
        b.packet(content)
    b.write_to_file(path+".bin")


import pyshark
import glob
import ipdb

# convert existing pcaps
for path in glob.glob("pcaps/*.pcap"):
    b = Builder(s)
    cap = pyshark.FileCapture(path, display_filter="udp.dstport eq 53", include_raw=True, use_json=True)

    #ipdb.set_trace()
    stream = b""
    for pkt in cap:
        #ipdb.set_trace()
        if int(pkt.udp.length) > 0:
            data = bytearray.fromhex(pkt.dns_raw.value)
            #print("LEN: ", repr((pkt.udp.length, data)))
            b.packet(data)
    b.write_to_file(path+".bin")
    cap.close()


# convert afl net samples
for path in glob.glob("raw_streams/*.raw"):
    b = Builder(s)
    with open(path,mode='rb') as f:
        stream_to_bin(path, f.read())
