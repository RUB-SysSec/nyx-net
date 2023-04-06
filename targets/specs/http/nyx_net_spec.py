import sys, os
sys.path.insert(1, os.getenv("NYX_INTERPRETER_BUILD_PATH"))

from spec_lib.graph_spec import *
from spec_lib.data_spec import *
from spec_lib.graph_builder import *
from spec_lib.generators import opts,flags,limits,regex

import jinja2

def get_rtsp_regex():
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
  return pkt

def get_content_codings():
  return "(aes128gcm|br|compress)"#|deflate|exi|gzip|identity)"
  #|pack200-gzip|x-compress|x-gzip|zstd)"

def get_http_regex():
  method="(GET|HEAD|POST|PUT|DELETE|CONNECT|OPTIONS|TRACE|PATCH)"
  files="(/|/index\\.html|/data\\.txt|/example\\.png|/example\\.jpg)"

  proto="(HTTP/1\\.0|HTTP/1\\.1)"

  keep_alive = "Connection: keep-alive"
  #keep_alive = "Connection: (close|keep-alive)"

  range_max_64 = "([1-9][0-9]{0,18}|0)"
  hex_32 = "[0-9A-F]{32}"

  accept_mime_type = "(application/andrew-inset|application/annodex|application/atom+xml|application/atomcat+xml|application/atomserv+xml|application/bbolin|application/cu-seeme|application/davmount+xml|application/dicom|application/dsptype|application/ecmascript|application/epub+zip|application/font-tdpfr|application/futuresplash|application/gzip|application/hta|application/java-archive|application/java-serialized-object|application/java-vm|application/javascript|application/json|application/m3g|application/mac-binhex40|application/mac-compactpro|application/mathematica|application/mbox|application/msaccess|application/msword|application/mxf|application/octet-stream|application/oda|application/oebps-package+xml|application/ogg|application/onenote|application/pdf|application/pgp-encrypted|application/pgp-keys|application/pgp-signature|application/pics-rules|application/postscript|application/rar|application/rdf+xml|application/rtf|application/sla|application/smil+xml|application/vnd\\.android\\.package-archive|application/vnd\\.cinderella|application/vnd\\.debian\\.binary-package|application/vnd\\.font-fontforge-sfd|application/vnd\\.google-earth\\.kml+xml|application/vnd\\.google-earth\\.kmz|application/vnd\\.mozilla\\.xul+xml|application/vnd\\.ms-excel|application/vnd\\.ms-excel\\.addin\\.macroEnabled\\.12|application/vnd\\.ms-excel\\.sheet\\.binary\\.macroEnabled\\.12|application/vnd\\.ms-excel\\.sheet\\.macroEnabled\\.12|application/vnd\\.ms-excel\\.template\\.macroEnabled\\.12|application/vnd\\.ms-fontobject|application/vnd\\.ms-officetheme|application/vnd\\.ms-pki\\.seccat|application/vnd\\.ms-powerpoint|application/vnd\\.ms-powerpoint\\.addin\\.macroEnabled\\.12|application/vnd\\.ms-powerpoint\\.presentation\\.macroEnabled\\.12|application/vnd\\.ms-powerpoint\\.slide\\.macroEnabled\\.12|application/vnd\\.ms-powerpoint\\.slideshow\\.macroEnabled\\.12|application/vnd\\.ms-powerpoint\\.template\\.macroEnabled\\.12|application/vnd\\.ms-word\\.document\\.macroEnabled\\.12|application/vnd\\.ms-word\\.template\\.macroEnabled\\.12|application/vnd\\.oasis\\.opendocument\\.chart|application/vnd\\.oasis\\.opendocument\\.database|application/vnd\\.oasis\\.opendocument\\.formula|application/vnd\\.oasis\\.opendocument\\.graphics|application/vnd\\.oasis\\.opendocument\\.graphics-template|application/vnd\\.oasis\\.opendocument\\.image|application/vnd\\.oasis\\.opendocument\\.presentation|application/vnd\\.oasis\\.opendocument\\.presentation-template|application/vnd\\.oasis\\.opendocument\\.spreadsheet|application/vnd\\.oasis\\.opendocument\\.spreadsheet-template|application/vnd\\.oasis\\.opendocument\\.text|application/vnd\\.oasis\\.opendocument\\.text-master|application/vnd\\.oasis\\.opendocument\\.text-template|application/vnd\\.oasis\\.opendocument\\.text-web|application/vnd\\.openxmlformats-officedocument\\.presentationml\\.presentation|application/vnd\\.openxmlformats-officedocument\\.presentationml\\.slide|application/vnd\\.openxmlformats-officedocument\\.presentationml\\.slideshow|application/vnd\\.openxmlformats-officedocument\\.presentationml\\.template|application/vnd\\.openxmlformats-officedocument\\.spreadsheetml\\.sheet|application/vnd\\.openxmlformats-officedocument\\.spreadsheetml\\.template|application/vnd\\.openxmlformats-officedocument\\.wordprocessingml\\.document|application/vnd\\.openxmlformats-officedocument\\.wordprocessingml\\.template|application/vnd\\.rim\\.cod|application/vnd\\.smaf|application/vnd\\.stardivision\\.calc|application/vnd\\.stardivision\\.chart|application/vnd\\.stardivision\\.draw|application/vnd\\.stardivision\\.impress|application/vnd\\.stardivision\\.math|application/vnd\\.stardivision\\.writer|application/vnd\\.stardivision\\.writer-global|application/vnd\\.sun\\.xml\\.calc|application/vnd\\.sun\\.xml\\.calc\\.template|application/vnd\\.sun\\.xml\\.draw|application/vnd\\.sun\\.xml\\.draw\\.template|application/vnd\\.sun\\.xml\\.impress|application/vnd\\.sun\\.xml\\.impress\\.template|application/vnd\\.sun\\.xml\\.math|application/vnd\\.sun\\.xml\\.writer|application/vnd\\.sun\\.xml\\.writer\\.global|application/vnd\\.sun\\.xml\\.writer\\.template|application/vnd\\.symbian\\.install|application/vnd\\.tcpdump\\.pcap|application/vnd\\.visio|application/vnd\\.wap\\.wbxml|application/vnd\\.wap\\.wmlc|application/vnd\\.wap\\.wmlscriptc|application/vnd\\.wordperfect|application/vnd\\.wordperfect5\\.1|application/x-123|application/x-7z-compressed|application/x-abiword|application/x-apple-diskimage|application/x-bcpio|application/x-bittorrent|application/x-bzip|application/x-cab|application/x-cbr|application/x-cbz|application/x-cdf|application/x-cdlink|application/x-chess-pgn|application/x-comsol|application/x-cpio|application/x-director|application/x-dms|application/x-doom|application/x-dvi|application/x-font|application/x-font-pcf|application/x-freemind|application/x-ganttproject|application/x-gnumeric|application/x-go-sgf|application/x-graphing-calculator|application/x-gtar|application/x-gtar-compressed|application/x-hdf|application/x-hwp|application/x-ica|application/x-info|application/x-internet-signup|application/x-iphone|application/x-iso9660-image|application/x-jam|application/x-java-jnlp-file|application/x-jmol|application/x-kchart|application/x-killustrator|application/x-koan|application/x-kpresenter|application/x-kspread|application/x-kword|application/x-latex|application/x-lha|application/x-lyx|application/x-lzh|application/x-lzx|application/x-maker|application/x-mif|application/x-mpegURL|application/x-ms-application|application/x-ms-manifest|application/x-ms-wmd|application/x-ms-wmz|application/x-msdos-program|application/x-msi|application/x-netcdf|application/x-ns-proxy-autoconfig|application/x-nwc|application/x-object|application/x-oz-application|application/x-pkcs7-certreqresp|application/x-pkcs7-crl|application/x-python-code|application/x-qgis|application/x-quicktimeplayer|application/x-rdp|application/x-redhat-package-manager|application/x-rss+xml|application/x-ruby|application/x-scilab|application/x-scilab-xcos|application/x-shar|application/x-shockwave-flash|application/x-silverlight|application/x-sql|application/x-stuffit|application/x-sv4cpio|application/x-sv4crc|application/x-tar|application/x-tex-gf|application/x-tex-pk|application/x-texinfo|application/x-troff|application/x-troff-man|application/x-troff-me|application/x-troff-ms|application/x-ustar|application/x-wais-source|application/x-wingz|application/x-x509-ca-cert|application/x-xcf|application/x-xfig|application/x-xpinstall|application/x-xz|application/xhtml+xml|application/xml|application/xml-dtd|application/xslt+xml|application/xspf+xml|application/zip|audio/amr|audio/amr-wb|audio/annodex|audio/basic|audio/csound|audio/flac|audio/midi|audio/mpeg|audio/mpegurl|audio/ogg|audio/prs\\.sid|audio/x-aiff|audio/x-gsm|audio/x-ms-wax|audio/x-ms-wma|audio/x-realaudio|audio/x-scpls|audio/x-sd2|audio/x-wav|chemical/x-alchemy|chemical/x-cache|chemical/x-cache-csf|chemical/x-cactvs-binary|chemical/x-cdx|chemical/x-cerius|chemical/x-chem3d|chemical/x-chemdraw|chemical/x-cif|chemical/x-cmdf|chemical/x-cml|chemical/x-compass|chemical/x-crossfire|chemical/x-csml|chemical/x-ctx|chemical/x-cxf|chemical/x-embl-dl-nucleotide|chemical/x-galactic-spc|chemical/x-gamess-input|chemical/x-gaussian-checkpoint|chemical/x-gaussian-cube|chemical/x-gaussian-input|chemical/x-gaussian-log|chemical/x-gcg8-sequence|chemical/x-genbank|chemical/x-hin|chemical/x-isostar|chemical/x-jcamp-dx|chemical/x-kinemage|chemical/x-macmolecule|chemical/x-macromodel-input|chemical/x-mdl-molfile|chemical/x-mdl-rdfile|chemical/x-mdl-rxnfile|chemical/x-mdl-sdfile|chemical/x-mdl-tgf|chemical/x-mmcif|chemical/x-mol2|chemical/x-molconn-Z|chemical/x-mopac-graph|chemical/x-mopac-input|chemical/x-mopac-out|chemical/x-mopac-vib|chemical/x-ncbi-asn1-ascii|chemical/x-ncbi-asn1-binary|chemical/x-pdb|chemical/x-rosdal|chemical/x-swissprot|chemical/x-vamas-iso14976|chemical/x-vmd|chemical/x-xtel|chemical/x-xyz|font/collection|font/ttf|font/woff|font/woff2|image/gif|image/ief|image/jp2|image/jpeg|image/jpm|image/jpx|image/pcx|image/png|image/svg+xml|image/tiff|image/vnd\\.djvu|image/vnd\\.microsoft\\.icon|image/vnd\\.wap\\.wbmp|image/x-canon-cr2|image/x-canon-crw|image/x-cmu-raster|image/x-coreldraw|image/x-coreldrawpattern|image/x-coreldrawtemplate|image/x-epson-erf|image/x-jg|image/x-jng|image/x-ms-bmp|image/x-nikon-nef|image/x-olympus-orf|image/x-photoshop|image/x-portable-anymap|image/x-portable-bitmap|image/x-portable-graymap|image/x-portable-pixmap|image/x-rgb|image/x-xbitmap|image/x-xpixmap|image/x-xwindowdump|message/rfc822|model/iges|model/mesh|model/vrml|model/x3d+binary|model/x3d+vrml|model/x3d+xml|text/cache-manifest|text/calendar|text/css; charset=utf-8|text/csv; charset=utf-8|text/h323|text/html|text/iuls|text/markdown; charset=utf-8|text/mathml|text/plain; charset=utf-8|text/richtext|text/scriptlet|text/tab-separated-values|text/texmacs|text/turtle|text/vcard|text/vnd\\.sun\\.j2me\\.app-descriptor|text/vnd\\.wap\\.wml|text/vnd\\.wap\\.wmlscript|text/x-bibtex; charset=utf-8|text/x-boo; charset=utf-8|text/x-c++hdr; charset=utf-8|text/x-c++src; charset=utf-8|text/x-chdr; charset=utf-8|text/x-component|text/x-csh; charset=utf-8|text/x-csrc; charset=utf-8|text/x-diff; charset=utf-8|text/x-dsrc; charset=utf-8|text/x-haskell; charset=utf-8|text/x-java; charset=utf-8|text/x-lilypond; charset=utf-8|text/x-literate-haskell; charset=utf-8|text/x-makefile; charset=utf-8|text/x-moc; charset=utf-8|text/x-pascal; charset=utf-8|text/x-pcs-gcd|text/x-perl; charset=utf-8|text/x-python; charset=utf-8|text/x-scala; charset=utf-8|text/x-setext|text/x-sfv|text/x-sh; charset=utf-8|text/x-tcl; charset=utf-8|text/x-tex; charset=utf-8|text/x-vcalendar|video/3gpp|video/MP2T|video/annodex|video/dl|video/dv|video/fli|video/gl|video/mp4|video/mpeg|video/ogg|video/quicktime|video/vnd\\.mpegurl|video/webm|video/x-flv|video/x-la-asf|video/x-matroska|video/x-mng|video/x-ms-asf|video/x-ms-wm|video/x-ms-wmv|video/x-ms-wmx|video/x-ms-wvx|video/x-msvideo|video/x-sgi-movie|x-conference/x-cooltalk|x-epoc/x-sisx-app|x-world/x-vrml|application/x-font-pcf)"
  accept_mime_types = "((%s(|;q=0\\.[0-9]),)*%s(|;q=0\\.[0-9]))?"%(accept_mime_type,accept_mime_type)

  content_encoding = "(aes128gcm|br|compress|deflate|exi|gzip|identity|pack200-gzip|x-compress|x-gzip|zstd)"
  content_encodings = "((%s,)*%s)?"%(content_encoding,content_encoding)

  language_tag = "(art-lojban|az-Arab|az-Cyrl|az-Latn|be-Latn|bs-Cyrl|bs-Latn|cel-gaulish Gaulish|de-1901|de-1996|de-AT-1901|de-AT-1996|de-CH-1901|de-CH-1996|de-DE-1901|de-DE-1996|el-Latn|en-boont|en-GB-oed|en-scouse|es-419|i-ami|i-bnn|i-default|i-enochian|i-hak|i-klingon|i-lux|i-mingo|i-navajo|i-pwn|i-tao|i-tay|i-tsu|iu-Cans|iu-Latn|mn-Cyrl|mn-Mong|no-bok|no-nyn|sgn-BE-fr|sgn-BE-nl|sgn-BR|sgn-CH-de|sgn-CO|sgn-DE|sgn-DK|sgn-ES|sgn-FR|sgn-GB|sgn-GR|sgn-IE|sgn-IT|sgn-JP|sgn-MX|sgn-NI|sgn-NL|sgn-NO|sgn-PT|sgn-SE|sgn-US|sgn-ZA|sl-nedis|sl-rozaj|sr-Cyrl|sr-Latn|tg-Arab|tg-Cyrl|uz-Cyrl|uz-Latn|yi-latn|zh-cmn|zh-cmn-Hans|zh-cmn-Hant|zh-Hans|zh-Hans-CN|zh-Hans-HK|zh-Hans-MO|zh-Hans-SG|zh-Hans-TW|zh-Hant|zh-Hant-CN|zh-Hant-HK|zh-Hant-MO|zh-Hant-SG|zh-Hant-TW|zh-gan|zh-guoyu|zh-hakka|zh-min|zh-min-nan|zh-wuu|zh-xiang|zh-yue)"
  language_tags = "((%s,)*%s)?"%(language_tag,language_tag)

  transfer_encoding_type = "(chunked|compress|deflate|gzip|identity)"
  transfer_encoding_types = "((%s,)*%s)?"%(transfer_encoding_type,transfer_encoding_type)

  upgrade_type = "(HTTP/1\\.0|HTTP/1\\.1|HTTP/2\\.0|SHTTP/1\\.3|IRC/6\\.9|RTA/x11)"
  upgrade_types = "((%s,)*%s)?"%(upgrade_type, upgrade_type)

  accept = "Accept: " + accept_mime_types
  host = "Host: 127\\.0\\.0\\.1:8080"
  user_agent = "User-Agent: Mozilla/5\\.0"
  accept_encoding = "Accept-Encoding: " + content_encodings
  accept_language = "Accept-Language: " + language_tags
  range = "Range: bytes=%s-%s"%(range_max_64,range_max_64)
  if_match = "If-Match: %s"%(hex_32)
  if_none_match = "If-None-Match: %s"%(hex_32)
  if_range = "If-Range: %s"%(hex_32)
  content_length = "Content-Length: " + "(([1-9][0-9]{0,18}|0)|([1-9][0-9]{0,6}|0))"


  transfer_encoding = "Transfer-Encoding: " + transfer_encoding_types
  upgrade = "Upgrade: " + upgrade_types

  referer = "Referer: https://google\\.de/"

  field="(%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s)"%(host,user_agent,accept_encoding,accept_language, range, if_match, if_none_match, if_range, accept, content_length, transfer_encoding, upgrade, referer)
  fields = "((%s\\r\\n)*%s)?"%(field,field)

  req = method+" "+files+" "+proto+"\\r\\n" + keep_alive + "\\r\\n"
  #req = method+" "+files+" "+proto + "\\r\\n"

  pkt = req + fields

  return pkt


s = Spec()
s.use_std_lib = False
s.includes.append("\"custom_includes.h\"")
s.includes.append("\"nyx.h\"")
s.interpreter_user_data_type = "socket_state_t*"

with open("send_code.include.c") as f:
    send_code = f.read()

d_byte = s.data_u8("u8", generators=[limits(0x00, 0xff)])

d_bytes = s.data_vec("pkt_content", d_byte, size_range=(0,1<<12), generators=[regex(get_http_regex())])

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

