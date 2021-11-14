method="(OPTIONS|DESCRIBE|SETUP|TEARDOWN|PLAY|PAUSE|GET_PARAMETER|SET_PARAMETER)"
url="rtsp://127.0.0.1:8554(wavAudioTest|ac3AudioTest|matroskaFileTest|webmFileTest)(/track1)?"
prot="RTSP/1.0"

req = method+" "+url+" "+prot+"\\r\\n"
cseq="CSeq: \\d+\\r\\n"
useragent="User-Agent: ./testRTSPClient (LIVE555 Streaming Media v2018.08.28)\\r\\n"
accept="Accept: application/sdp\\r\\n"
transport="Transport: RTP/AVP;unicast;client_port=37952-37953\\r\\n"
rng="Range: npt=(0.000-|9)\\r\\n"
session="Session: 000022B8\\r\\n"
fields="(%s|%s|%s|%s|%s|%s)*"%(cseq,useragent,accept,transport,rng,session)
pkt = req+fields
