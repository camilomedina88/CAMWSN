#
# nodes: 6, pause: 0.00, max speed: 0.00, max x: 10.00, max y: 10.00
#
$node_(0) set X_ 5
$node_(0) set Y_ 110
$node_(0) set Z_ 0.000000000000
$node_(1) set X_ 5
$node_(1) set Y_ 90
$node_(1) set Z_ 0.000000000000
$node_(2) set X_ 10
$node_(2) set Y_ 120
$node_(2) set Z_ 0.000000000000
$node_(3) set X_ 10
$node_(3) set Y_ 80
$node_(3) set Z_ 0.000000000000
$node_(4) set X_ 15
$node_(4) set Y_ 130
$node_(4) set Z_ 0.000000000000
$node_(5) set X_ 15
$node_(5) set Y_ 70
$node_(5) set Z_ 0.000000000000
$node_(6) set X_ 20
$node_(6) set Y_ 140
$node_(6) set Z_ 0.000000000000
$node_(7) set X_ 20
$node_(7) set Y_ 60
$node_(7) set Z_ 0.000000000000

$node_(8) set X_ 25
$node_(8) set Y_ 150
$node_(8) set Z_ 0.000000000000
$node_(9) set X_ 25
$node_(9) set Y_ 50
$node_(9) set Z_ 0.000000000000
$node_(10) set X_ 35
$node_(10) set Y_ 140
$node_(10) set Z_ 0.000000000000

$node_(11) set X_ 35
$node_(11) set Y_ 60
$node_(11) set Z_ 0.000000000000
$node_(12) set X_ 40
$node_(12) set Y_ 130
$node_(12) set Z_ 0.000000000000
$node_(13) set X_ 40
$node_(13) set Y_ 70
$node_(13) set Z_ 0.000000000000
$node_(14) set X_ 45
$node_(14) set Y_ 120
$node_(14) set Z_ 0.000000000000
$node_(15) set X_ 45
$node_(15) set Y_ 80
$node_(15) set Z_ 0.000000000000
$node_(16) set X_ 20
$node_(16) set Y_ 110
$node_(16) set Z_ 0.000000000000
$node_(17) set X_ 20
$node_(17) set Y_ 90
$node_(17) set Z_ 0.000000000000
$node_(18) set X_ 35
$node_(18) set Y_ 80
$node_(18) set Z_ 0.000000000000

$node_(19) set X_ 45
$node_(19) set Y_ 80
$node_(19) set Z_ 0.000000000000
$node_(20) set X_ 25
$node_(20) set Y_ 90
$node_(20) set Z_ 0.000000000000
$node_(21) set X_ 35
$node_(21) set Y_ 90
$node_(21) set Z_ 0.000000000000

$node_(22) set X_ 20
$node_(22) set Y_ 120
$node_(22) set Z_ 0.000000000000
$node_(23) set X_ 40
$node_(23) set Y_ 120
$node_(23) set Z_ 0.000000000000
$node_(24) set X_ 0
$node_(24) set Y_ 100
$node_(24) set Z_ 0.000000000000

$node_(25) set X_ 50
$node_(25) set Y_ 100
$node_(25) set Z_ 0.000000000000
#
# nodes: 6, max conn: 3, send rate: 0.0, seed: 1
#
$node_(0) setdest 5 110 1
$node_(1) setdest   5 90 1
$node_(2) setdest 10 120 1
$node_(3) setdest 10  80 1
$node_(4) setdest 15 130 1
$node_(5) setdest 15 70 1
$node_(6) setdest 20 140 1
$node_(7) setdest 20 60 1

$node_(8) setdest 25 150 1
$node_(9) setdest 25 50 1
$node_(10) setdest 35 140 1
$node_(11) setdest 35 60 1
$node_(12) setdest 40 130 1
$node_(13) setdest 40 70 1
$node_(14) setdest 45 120  1
$node_(15) setdest 45 80 1
$node_(16) setdest 20 110 1
$node_(17) setdest 20 90 1
$node_(18) setdest 35 80 1
$node_(19) setdest 45 80 1
$node_(20) setdest 25 90 1
$node_(21) setdest 35 90 1
$node_(22) setdest 20 120 1
$node_(23) setdest 40 120 1

$node_(24) setdest 1 100 1
$node_(25) setdest 50 100 1

#set k 25
#set l 50
#for {set i 0} {$i <  [expr $val(nn) -0] } {set i [expr $i +2]} {
# $node_($i) set X_ $k
#$node_($i) set Y_ $l
#$node_($i) set Z_ 0.000000000000
#$node_([expr $i +1]) set X_ $k
#$node_([expr $i +1]) set Y_ [expr $l + 75 ]
#$node_([expr $i +1]) set Z_ 0.000000000000
#set k [expr $k +25]
#set l [expr $l +10]
#}

#$node_($i) set X_ 1
#$node_($i) set Y_ 75
#$node_($i) set Z_ 0
#$node_([expr $i +1]) set X_ $k
#$node_([expr $i +1]) set Y_ 75
#$node_([expr $i +1]) set Z_ 0.000000000000

#puts "hello"

#set k 25
#set l 50
#for {set i 0} {$i < [expr $val(nn) -0] } {set i [expr $i +2]} {
#$node_($i) setdest $k $l 1
#$node_([expr $i +1]) setdest $k [expr $l +75 ] 1
#set k [expr $k +25]

#set l [expr $l +10]
#}
#$node_($i) setdest 1 75 1
#$node_([expr $i +1]) setdest $k 75 1
#puts "hello1"
#set j 0
#for {set i 0} {$i <  $val(nn) } {set i [expr $i +2]} {

#	set tcp_($j) [$ns_ create-connection  TCP $node_($i) TCPSink $node_([expr $i +1]) 0]
#$tcp_($j) set window_ 32
#$tcp_($j) set packetSize_ 512
#set ftp_($j) [$tcp_($j) attach-source FTP]
 #$ns_ at 0.1 "$ftp_($j) start"
#puts $i
#puts $j 
#incr j
#}
#set j 0
#set rt 11000
#for {set i 0} {$i <  [expr $val(nn) -2] } {set i [expr $i +2]} {

#set udp_($j) [new Agent/UDP]
#$ns_ attach-agent $node_($i) $udp_($j)
#set null_($j) [new Agent/UDP]
#$ns_ attach-agent $node_([expr $i +1]) $null_($j)
#set cbr_($j) [new Application/Traffic/CBR]
#$cbr_($j) set packetSize_ 512
#$cbr_($j) set rate_ $rt kbps
#$cbr_($j) set random_ 1
#$cbr_($j) attach-agent $udp_($j)
#$ns_ connect $udp_($j) $null_($j)
#$ns_ at $j "$cbr_($j) start"
#incr j
#set rt [expr $rt -100]
#}
#set udp_($j) [new Agent/UDP]
#$ns_ attach-agent $node_($i) $udp_($j)
#set null_($j) [new Agent/UDP]
#$ns_ attach-agent $node_([expr $i +1]) $null_($j)
#set cbr_($j) [new Application/Traffic/CBR]
#$cbr_($j) set packetSize_ 512
#$cbr_($j) set rate_ 11Mbps
#$cbr_($j) set random_ 1
#$cbr_($j) attach-agent $udp_($j)
#$ns_ connect $udp_($j) $null_($j)
#$ns_ at j "$cbr_($j) start"
#incr j
set udp_(0) [new Agent/UDP]
$ns_ attach-agent $node_(0) $udp_(0)
set null_(0) [new Agent/UDP]
$ns_ attach-agent $node_(1) $null_(0)
set cbr_(0) [new Application/Traffic/CBR]
$cbr_(0) set packetSize_ 512
$cbr_(0) set rate_ 900kbps
$cbr_(0) set random_ 1
$cbr_(0) attach-agent $udp_(0)
$ns_ connect $udp_(0) $null_(0)
$ns_ at 0.1 "$cbr_(0) start"

set udp_(1) [new Agent/UDP]
$ns_ attach-agent $node_(2) $udp_(1)
set null_(1) [new Agent/UDP]
$ns_ attach-agent $node_(3) $null_(1)
set cbr_(1) [new Application/Traffic/CBR]
$cbr_(1) set packetSize_ 512
$cbr_(1) set rate_ 3Mbps
$cbr_(1) set random_ 1
$cbr_(1) attach-agent $udp_(1)
$ns_ connect $udp_(1) $null_(1)
$ns_ at 0.2 "$cbr_(1) start"

set udp_(2) [new Agent/UDP]
$ns_ attach-agent $node_(4) $udp_(2)
set null_(2) [new Agent/UDP]
$ns_ attach-agent $node_(5) $null_(2)
set cbr_(2) [new Application/Traffic/CBR]
$cbr_(2) set packetSize_ 512
$cbr_(2) set rate_ 5Mbps
$cbr_(2) set random_ 1
$cbr_(2) attach-agent $udp_(2)
$ns_ connect $udp_(2) $null_(2)
$ns_ at 0.3 "$cbr_(2) start"

set udp_(3) [new Agent/UDP]
$ns_ attach-agent $node_(6) $udp_(3)
set null_(3) [new Agent/UDP]
$ns_ attach-agent $node_(7) $null_(3)
set cbr_(3) [new Application/Traffic/CBR]
$cbr_(3) set packetSize_ 512
$cbr_(3) set rate_ 8Mbps
$cbr_(3) set random_ 1
$cbr_(3) attach-agent $udp_(3)
$ns_ connect $udp_(3) $null_(3)
$ns_ at 0.4 "$cbr_(3) start"

set udp_(4) [new Agent/UDP]
$ns_ attach-agent $node_(8) $udp_(4)
set null_(4) [new Agent/UDP]
$ns_ attach-agent $node_(9) $null_(4)
set cbr_(4) [new Application/Traffic/CBR]
$cbr_(4) set packetSize_ 512
$cbr_(4) set rate_ 10Mbps
$cbr_(4) set random_ 1
$cbr_(4) attach-agent $udp_(4)
$ns_ connect $udp_(4) $null_(4)
$ns_ at 0.5 "$cbr_(4) start"

set udp_(5) [new Agent/UDP]
$ns_ attach-agent $node_(10) $udp_(5)
set null_(5) [new Agent/UDP]
$ns_ attach-agent $node_(11) $null_(5)
set cbr_(5) [new Application/Traffic/CBR]
$cbr_(5) set packetSize_ 512
$cbr_(5) set rate_ 11Mbps
$cbr_(5) set random_ 1
$cbr_(5) attach-agent $udp_(5)
$ns_ connect $udp_(5) $null_(5)
$ns_ at 0.6 "$cbr_(5) start"

set udp_(6) [new Agent/UDP]
$ns_ attach-agent $node_(12) $udp_(6)
set null_(6) [new Agent/UDP]
$ns_ attach-agent $node_(13) $null_(6)
set cbr_(6) [new Application/Traffic/CBR]
$cbr_(6) set packetSize_ 512
$cbr_(6) set rate_ 8Mbps
$cbr_(6) set random_ 1
$cbr_(6) attach-agent $udp_(6)
$ns_ connect $udp_(6) $null_(6)
$ns_ at 0.7 "$cbr_(6) start"

set udp_(7) [new Agent/UDP]
$ns_ attach-agent $node_(14) $udp_(7)
set null_(7) [new Agent/UDP]
$ns_ attach-agent $node_(15) $null_(7)
set cbr_(7) [new Application/Traffic/CBR]
$cbr_(7) set packetSize_ 512
$cbr_(7) set rate_ 10Mbps
$cbr_(7) set random_ 1
$cbr_(7) attach-agent $udp_(7)
$ns_ connect $udp_(7) $null_(7)
$ns_ at 0.8 "$cbr_(7) start"

set udp_(8) [new Agent/UDP]
$ns_ attach-agent $node_(16) $udp_(8)
set null_(8) [new Agent/UDP]
$ns_ attach-agent $node_(17) $null_(8)
set cbr_(8) [new Application/Traffic/CBR]
$cbr_(8) set packetSize_ 512
$cbr_(8) set rate_ 11Mbps
$cbr_(8) set random_ 1
$cbr_(8) attach-agent $udp_(8)
$ns_ connect $udp_(8) $null_(8)
$ns_ at 0.9 "$cbr_(8) start"

set udp_(9) [new Agent/UDP]
$ns_ attach-agent $node_(18) $udp_(9)
set null_(9) [new Agent/UDP]
$ns_ attach-agent $node_(19) $null_(9)
set cbr_(9) [new Application/Traffic/CBR]
$cbr_(9) set packetSize_ 512
$cbr_(9) set rate_ 100kbps
$cbr_(9) set random_ 1
$cbr_(9) attach-agent $udp_(9)
$ns_ connect $udp_(9) $null_(9)
$ns_ at 1.0 "$cbr_(9) start"

set udp_(10) [new Agent/UDP]
$ns_ attach-agent $node_(20) $udp_(10)
set null_(10) [new Agent/UDP]
$ns_ attach-agent $node_(21) $null_(10)
set cbr_(10) [new Application/Traffic/CBR]
$cbr_(10) set packetSize_ 512
$cbr_(10) set rate_ 140kbps
$cbr_(10) set random_ 1
$cbr_(10) attach-agent $udp_(10)
$ns_ connect $udp_(10) $null_(10)
$ns_ at 1.3 "$cbr_(10) start"

set udp_(11) [new Agent/UDP]
$ns_ attach-agent $node_(22) $udp_(11)
set null_(11) [new Agent/UDP]
$ns_ attach-agent $node_(23) $null_(11)
set cbr_(11) [new Application/Traffic/CBR]
$cbr_(11) set packetSize_ 512
$cbr_(11) set rate_ 180kbps
$cbr_(11) set random_ 1
$cbr_(11) attach-agent $udp_(11)
$ns_ connect $udp_(11) $null_(11)
$ns_ at 1.1 "$cbr_(11) start"

set udp_(12) [new Agent/UDP]
$ns_ attach-agent $node_(24) $udp_(12)
set null_(12) [new Agent/UDP]
$ns_ attach-agent $node_(25) $null_(12)
set cbr_(12) [new Application/Traffic/CBR]
$cbr_(12) set packetSize_ 512
$cbr_(12) set rate_ 11Mbps
$cbr_(12) set random_ 1
$cbr_(12) attach-agent $udp_(12)
$ns_ connect $udp_(12) $null_(12)
$ns_ at 1.2 "$cbr_(12) start"
$ns_ at 50 "$cbr_(12) stop"
set udp_(13) [new Agent/UDP]
$ns_ attach-agent $node_(25) $udp_(13)
set null_(13) [new Agent/UDP]
$ns_ attach-agent $node_(24) $null_(13)
set cbr_(13) [new Application/Traffic/CBR]
$cbr_(13) set packetSize_ 512
$cbr_(13) set rate_ 11Mbps
$cbr_(13) set random_ 1
$cbr_(13) attach-agent $udp_(13)
$ns_ connect $udp_(13) $null_(13)
$ns_ at 50.1 "$cbr_(13) start"

$ns_ at 52 "$cbr_(13) stop"
$ns_ at 52.1 "$cbr_(12) start"
#incr j
#$ns_ at  "$cbr_(1) stop"
#$ns_ at 22 "$cbr_(1) start"
#$ns_ at 2 "$ftp_(3) stop"
#$ns_ at 2 "$ftp_(4) stop"
 
