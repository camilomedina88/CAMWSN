#
# nodes: 10, pause: 0.00, max speed: 1.00, max x: 500.00, max y: 500.00
#
$node_(0) set X_ 27.630672847661
$node_(0) set Y_ 439.061501488274
$node_(0) set Z_ 0.000000000000
$node_(1) set X_ 161.805234187164
$node_(1) set Y_ 164.594890721081
$node_(1) set Z_ 0.000000000000
$node_(2) set X_ 407.077351159437
$node_(2) set Y_ 165.394979971963
$node_(2) set Z_ 0.000000000000
$node_(3) set X_ 366.000928480223
$node_(3) set Y_ 225.541975096038
$node_(3) set Z_ 0.000000000000
$node_(4) set X_ 217.062732355913
$node_(4) set Y_ 237.237885441976
$node_(4) set Z_ 0.000000000000
$node_(5) set X_ 418.661406631948
$node_(5) set Y_ 5.503186989730
$node_(5) set Z_ 0.000000000000
$node_(6) set X_ 429.244561535974
$node_(6) set Y_ 406.489607889633
$node_(6) set Z_ 0.000000000000
$node_(7) set X_ 221.814341176623
$node_(7) set Y_ 330.587562816733
$node_(7) set Z_ 0.000000000000
$node_(8) set X_ 271.897453711059
$node_(8) set Y_ 442.584120914689
$node_(8) set Z_ 0.000000000000
$node_(9) set X_ 290.832898927211
$node_(9) set Y_ 382.061624892246
$node_(9) set Z_ 0.000000000000
$ns_ at 0.000000000000 "$node_(0) setdest 119.192436172633 201.908800284618 0.273231322838"
$ns_ at 0.000000000000 "$node_(1) setdest 307.584634744004 24.450615766861 0.294280953754"
$ns_ at 0.000000000000 "$node_(2) setdest 220.630640953587 52.483394606166 0.938556170142"
$ns_ at 0.000000000000 "$node_(3) setdest 207.751586617047 466.343223233565 0.174800679870"
$ns_ at 0.000000000000 "$node_(4) setdest 333.856553524305 307.967139188471 0.814938225901"
$ns_ at 0.000000000000 "$node_(5) setdest 77.347544158876 254.811178776604 0.674535525568"
$ns_ at 0.000000000000 "$node_(6) setdest 123.058747173338 349.416170892903 0.467298604594"
$ns_ at 0.000000000000 "$node_(7) setdest 165.792396404971 411.060411832427 0.200569523433"
$ns_ at 0.000000000000 "$node_(8) setdest 471.295441973361 361.285263939606 0.157987997835"
$ns_ at 0.000000000000 "$node_(9) setdest 430.073651823988 245.078530971970 0.882023095959"
$god_ set-dist 0 1 2
$god_ set-dist 0 2 2
$god_ set-dist 0 3 2
$god_ set-dist 0 4 2
$god_ set-dist 0 5 3
$god_ set-dist 0 6 2
$god_ set-dist 0 7 1
$god_ set-dist 0 8 1
$god_ set-dist 0 9 2
$god_ set-dist 1 2 1
$god_ set-dist 1 3 1
$god_ set-dist 1 4 1
$god_ set-dist 1 5 2
$god_ set-dist 1 6 2
$god_ set-dist 1 7 1
$god_ set-dist 1 8 2
$god_ set-dist 1 9 2
$god_ set-dist 2 3 1
$god_ set-dist 2 4 1
$god_ set-dist 2 5 1
$god_ set-dist 2 6 1
$god_ set-dist 2 7 1
$god_ set-dist 2 8 2
$god_ set-dist 2 9 1
$god_ set-dist 3 4 1
$god_ set-dist 3 5 1
$god_ set-dist 3 6 1
$god_ set-dist 3 7 1
$god_ set-dist 3 8 1
$god_ set-dist 3 9 1
$god_ set-dist 4 5 2
$god_ set-dist 4 6 2
$god_ set-dist 4 7 1
$god_ set-dist 4 8 1
$god_ set-dist 4 9 1
$god_ set-dist 5 6 2
$god_ set-dist 5 7 2
$god_ set-dist 5 8 2
$god_ set-dist 5 9 2
$god_ set-dist 6 7 1
$god_ set-dist 6 8 1
$god_ set-dist 6 9 1
$god_ set-dist 7 8 1
$god_ set-dist 7 9 1
$god_ set-dist 8 9 1
$ns_ at 17.598131689601 "$god_ set-dist 4 6 1"
$ns_ at 18.188479567548 "$god_ set-dist 2 6 2"
$ns_ at 22.087435066268 "$god_ set-dist 1 9 1"
#
# Destination Unreachables: 0
#
# Route Changes: 3
#
# Link Changes: 3
#
# Node | Route Changes | Link Changes
#    0 |             0 |            0
#    1 |             1 |            1
#    2 |             1 |            1
#    3 |             0 |            0
#    4 |             1 |            1
#    5 |             0 |            0
#    6 |             2 |            2
#    7 |             0 |            0
#    8 |             0 |            0
#    9 |             1 |            1
#
#
# nodes: 10, max conn: 5, send rate: 0.0, seed: 1
#
#
# 1 connecting to 2 at time 2.5568388786897245
#
set tcp_(0) [$ns_ create-connection  TCP $node_(1) TCPSink $node_(2) 0]
$tcp_(0) set window_ 32
$tcp_(0) set packetSize_ 512
set ftp_(0) [$tcp_(0) attach-source FTP]
$ns_ at 2.5568388786897245 "$ftp_(0) start"
#
# 4 connecting to 5 at time 56.333118917575632
#
set tcp_(1) [$ns_ create-connection  TCP $node_(4) TCPSink $node_(5) 0]
$tcp_(1) set window_ 32
$tcp_(1) set packetSize_ 512
set ftp_(1) [$tcp_(1) attach-source FTP]
$ns_ at 56.333118917575632 "$ftp_(1) start"
#
# 4 connecting to 6 at time 146.96568928983328
#
set tcp_(2) [$ns_ create-connection  TCP $node_(4) TCPSink $node_(6) 0]
$tcp_(2) set window_ 32
$tcp_(2) set packetSize_ 512
set ftp_(2) [$tcp_(2) attach-source FTP]
$ns_ at 146.96568928983328 "$ftp_(2) start"
#
# 6 connecting to 7 at time 55.634230382570173
#
set tcp_(3) [$ns_ create-connection  TCP $node_(6) TCPSink $node_(7) 0]
$tcp_(3) set window_ 32
$tcp_(3) set packetSize_ 512
set ftp_(3) [$tcp_(3) attach-source FTP]
$ns_ at 55.634230382570173 "$ftp_(3) start"
#
# 7 connecting to 8 at time 29.546173154165118
#
set tcp_(4) [$ns_ create-connection  TCP $node_(7) TCPSink $node_(8) 0]
$tcp_(4) set window_ 32
$tcp_(4) set packetSize_ 512
set ftp_(4) [$tcp_(4) attach-source FTP]
$ns_ at 29.546173154165118 "$ftp_(4) start"
#
#Total sources/connections: 4/5
#
