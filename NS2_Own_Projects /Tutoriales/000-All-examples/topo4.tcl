#
# nodes: 6, pause: 0.00, max speed: 0.00, max x: 10.00, max y: 10.00
#
$node_(0) set X_ 3.601381887935
$node_(0) set Y_ 3.345826579242
$node_(0) set Z_ 0.000000000000
$node_(1) set X_ 4.745853808042
$node_(1) set Y_ 9.164080933232
$node_(1) set Z_ 0.000000000000
$node_(2) set X_ 4.306890956553
$node_(2) set Y_ 0.690149239626
$node_(2) set Z_ 0.000000000000
$node_(3) set X_ 6.293287263020
$node_(3) set Y_ 4.794732888067
$node_(3) set Z_ 0.000000000000
$node_(4) set X_ 4.888168970761
$node_(4) set Y_ 8.633286067220
$node_(4) set Z_ 0.000000000000
$node_(5) set X_ 4.649753073963
$node_(5) set Y_ 0.424774093170
$node_(5) set Z_ 0.000000000000
#
# nodes: 6, max conn: 3, send rate: 0.0, seed: 1
#
#
# 1 connecting to 2 at time 2.5568388786897245
#
set tcp_(0) [$ns_ create-connection  TCP $node_(0) TCPSink $node_(1) 0]
$tcp_(0) set window_ 32
$tcp_(0) set packetSize_ 512
set ftp_(0) [$tcp_(0) attach-source FTP]
$ns_ at 2.5568388786897245 "$ftp_(0) start"
#
# 4 connecting to 5 at time 56.333118917575632
#
set tcp_(1) [$ns_ create-connection  TCP $node_(2) TCPSink $node_(3) 0]
$tcp_(1) set window_ 32
$tcp_(1) set packetSize_ 512
set ftp_(1) [$tcp_(1) attach-source FTP]
$ns_ at 2.333118917575632 "$ftp_(1) start"
#
# 4 connecting to 6 at time 146.96568928983328
#
set tcp_(2) [$ns_ create-connection  TCP $node_(4) TCPSink $node_(5) 0]
$tcp_(2) set window_ 32
$tcp_(2) set packetSize_ 512
set ftp_(2) [$tcp_(2) attach-source FTP]
$ns_ at 2.96568928983328 "$ftp_(2) start"
#
#Total sources/connections: 2/3
#
