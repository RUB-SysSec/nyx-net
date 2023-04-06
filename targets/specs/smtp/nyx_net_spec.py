import sys, os
sys.path.insert(1, os.getenv("NYX_INTERPRETER_BUILD_PATH"))

from spec_lib.graph_spec import *
from spec_lib.data_spec import *
from spec_lib.graph_builder import *
from spec_lib.generators import opts,flags,limits,regex

import jinja2
import pyshark
import glob

s = Spec()
s.use_std_lib = False
s.includes.append("\"custom_includes.h\"")
s.includes.append("\"nyx.h\"")
s.interpreter_user_data_type = "socket_state_t*"

#with open("send_code.include.c") as f:
#    send_code = f.read()

with open("send_code_raw.include.c") as f:
    send_code_raw = f.read()

d_byte = s.data_u8("u8", generators=[limits(0x00, 0xff)])


method="(USER|QUIT|NOOP|PWD|TYPE|PORT|LIST|CDUP|CWD|RETR|ABOR|DELE|PASV|PASS|REST|SIZE|MKD|RMD|STOR|SYST|FEAT|APPE|RNFR|RNTO|OPTS|MLSD|AUTH|PBSZ|PROT|EPSV|HELP|SITE)"

arg = "((\\./)?(\\.\\./|[^/]*/)*([.]+)?|ubuntu|/etc/passwd|\\./a)"
args="( %s)* %s"%(arg,arg)

pkt = method+args

d_bytes = s.data_vec("pkt_content", d_byte, size_range=(0,1<<12), generators=[]) #regex(pkt)])

#n_pkt = s.node_type("packet", interact=True, data=d_bytes, code=send_code)

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
    msgs = data.split(b"\r\n")
    new_msgs = []
    tmp = b""
    for msg in msgs:
        new_msgs.append(msg+b"\r\n")

    return(new_msgs[:-1])

def stream_to_bin(path,stream):
    if stream == None:
        return
    nodes = split_packets(stream)
    print(nodes)
    for content in nodes:
        print(repr(content))
        b.packet_raw(content)
    b.write_to_file(path+".bin")

for path in glob.glob("pcaps/*.pcap"):
    b = Builder(s)
    raise("FIX PORT")
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
