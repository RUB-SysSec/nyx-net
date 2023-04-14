import sys, os 
sys.path.insert(1, os.getenv("NYX_INTERPRETER_BUILD_PATH"))
sys.path.insert(1, os.getenv("TANGO_PATH"))

from tango.net import PCAPInput
from tango.core import TransmitInstruction

class FMT(object):
    def __init__(self):
        self.protocol = 'tcp'
        self.port = 2022


def to_pcap(aflnet_raw_pathname, inp):
    pathname = aflnet_raw_pathname + '.tpcap'
    new_inp = PCAPInput(file=pathname, fmt=FMT())
    import ipdb; ipdb.set_trace()
    new_inp.dump(inp, name='openssh-seed-0')
    print('dump to {}'.format(pathname))


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


# TODO these might be fucky as fuck! check the count-X lines in those C files
with open("send_code.include_pkt.c") as f:
    send_code_pkt = f.read() 

with open("send_code.include_pkt_mac.c") as f:
    send_code_pkt_mac = f.read() 

with open("send_code.include_string.c") as f:
    send_code_string = f.read() 

d_byte = s.data_u8("u8", generators=[limits(0x0, 0xff)])

d_bytes = s.data_vec("pkt_content", d_byte, size_range=(0,1<<12), generators=[]) #regex(pkt)

n_pkt = s.node_type("packet", interact=True, data=d_bytes, code=send_code_pkt)
n_pkt_mac = s.node_type("packet_mac", interact=True, data=d_bytes, code=send_code_pkt_mac)
n_pkt_str = s.node_type("string", interact=True, data=d_bytes, code=send_code_string)

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

import struct
import pyshark
import glob

def split_packets(data):   
    i = 0
    res = []

    # print(type(data))
    header_end = data.find("\x0d\x0a".encode(), 0, len(data)) + 2
    res.append(["ssh-string", data[:header_end] ])

    i = header_end

    while i+6 <= len(data):
        length,pad_length,msg = struct.unpack(">IBB",data[i:i+6])  
        content_len = length-2+6
        if not (msg >= 20 and msg <= 49):
            # print("add MAC length")
            pkt = data[i:i+content_len+8]
            # print(f"disecting: {repr((length,pad_length,msg,pkt))}" )
            res.append( ["ssh-pkt-mac", pkt] )
            i+=(content_len+8)
        else:
            # print("no MAC")
            pkt = data[i:i+content_len]
            # print(f"disecting: {repr((length,pad_length,msg,pkt))}" )
            res.append( ["ssh-pkt", pkt] )
            i+=(content_len)
    return res

instructions = []

def stream_to_bin(path,stream):
    nodes = split_packets(stream)

    for (ntype, content) in nodes:
        if ntype == "ssh-pkt":
            b.packet(content)
            ins = TransmitInstruction(content)
            instructions.append(ins)
        elif ntype == "ssh-pkt-mac":
            b.packet_mac(content)
            ins = TransmitInstruction(content)
            instructions.append(ins)
        elif ntype == "ssh-string":
            b.string(content)
            ins = TransmitInstruction(content)
            instructions.append(ins)
    b.write_to_file(path+".bin")

"""
# convert existing pcaps
for path in glob.glob("pcaps/*.pcap"):
    b = Builder(s)
    cap = pyshark.FileCapture(path, display_filter="tcp.dstport eq 5158")

    #ipdb.set_trace()
    stream = b""
    for pkt in cap:
        #print("LEN: ", repr((pkt.tcp.len, int(pkt.tcp.len))))
        if int(pkt.tcp.len) > 0:
            stream+=pkt.tcp.payload.binary_value
    stream_to_bin(path, stream)
    cap.close()
"""

# convert afl net samples
for path in glob.glob("raw_streams/*.raw"):
    b = Builder(s)
    with open(path,mode='rb') as f:
        instructions.clear()
        stream_to_bin(path, f.read())
        to_pcap(path, instructions)

