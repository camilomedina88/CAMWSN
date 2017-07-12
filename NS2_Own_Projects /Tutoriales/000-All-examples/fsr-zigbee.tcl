############################################################
# Final Project
# Fisheye State Routing ( FSR) Protocols, 10 nodes
# Zigbee Technology (IEEE 802.15.4)
# Sabri Alimi ---- abi_x52@yahoo.com
# 2012
############################################################

#mendeklarasikan parameter
set val(chan) Channel/WirelessChannel ;# tipe kanal
set val(prop) Propagation/FreeSpace ;# model propagasi radio
set val(netif) Phy/WirelessPhy/802_15_4 ;# network inteface type
set val(mac) Mac/802_15_4 ;# MAC type
set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# model antena
set val(ifqlen) 5 ;# jumlah max pkt dlm antrian
set val(nn) 10 ;# jumlah mobile node
set val(rp) FSR ;# tipe routing protokol
set val(x) 500 ;# dimensi topografi x
set val(y) 500 ;# dimensi topografi y
set val(stop) 300 ;# waktu simulasi berhenti

# Set Energy model
set dist(5m) 7.69113e-06
set dist(9m) 2.37381e-06
set dist(10m) 1.92278e-06
set dist(11m) 1.58908e-06
set dist(12m) 1.33527e-06
set dist(13m) 1.13774e-06
set dist(14m) 9.81011e-07
set dist(15m) 8.54570e-07
set dist(16m) 7.51087e-07
set dist(20m) 4.80696e-07
set dist(25m) 3.07645e-07
set dist(30m) 2.13643e-07
set dist(35m) 1.56962e-07
set dist(40m) 1.20174e-07
Phy/WirelessPhy set CSThresh_ $dist(40m)
Phy/WirelessPhy set RXThresh_ $dist(40m)

# main program
set ns_ [new Simulator]

# set Tracefile
set tracefd [ open 10nodesprojfszbr.tr w]
$ns_ trace-all $tracefd

# set Namfile
set namtrace [open 10nodesprojfszbr.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

# membuat topografi
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

# create god
create-god $val(nn)

$ns_ color 0 red

# mendefinisikan konfigurasi mobile node
$ns_ node-config -adhocRouting $val(rp) \
-llType $val(ll) \
-macType $val(mac) \
-ifqType $val(ifq) \
-ifqLen $val(ifqlen) \
-antType $val(ant) \
-propType $val(prop) \
-phyType $val(netif) \
-channelType $val(chan) \
-topoInstance $topo \
-agentTrace ON \
-routerTrace ON \
-macTrace OFF \
-movementTrace OFF \

############################################################

# membuat 10 node
for {set i 0} {$i < $val(nn) } { incr i } {
set node_($i) [$ns_ node]
$node_($i) random-motion 0
}

# pewarnaan node
$node_(0) color blue
$node_(1) color blue
$node_(2) color green
$node_(3) color green

$node_(4) color yellow
$node_(5) color yellow
$node_(6) color yellow
$node_(7) color yellow
$node_(8) color yellow
$node_(9) color yellow

# membuat lokasi node awal
$node_(0) set X_ 251.0
$node_(0) set Y_ 200.0
$node_(0) set Z_ 0.0
$node_(1) set X_ 231.0
$node_(1) set Y_ 285.0
$node_(1) set Z_ 0.0
$node_(2) set X_ 231.0
$node_(2) set Y_ 245.0
$node_(2) set Z_ 0.0
$node_(3) set X_ 254.0
$node_(3) set Y_ 235.0
$node_(3) set Z_ 0.0
$node_(4) set X_ 243.0
$node_(4) set Y_ 203.0
$node_(4) set Z_ 0.0
$node_(5) set X_ 282.0
$node_(5) set Y_ 303.0
$node_(5) set Z_ 0.0
$node_(6) set X_ 323.0
$node_(6) set Y_ 394.0
$node_(6) set Z_ 0.0
$node_(7) set X_ 243.0
$node_(7) set Y_ 293.0
$node_(7) set Z_ 0.0
$node_(8) set X_ 212.0
$node_(8) set Y_ 213.0
$node_(8) set Z_ 0.0
$node_(9) set X_ 229.0
$node_(9) set Y_ 242.0
$node_(9) set Z_ 0.0

# membuat lokasi pergerakan node
$ns_ at 3.0 "$node_(0) setdest 431.0 179.0 1.0"
$ns_ at 3.0 "$node_(3) setdest 134.0 296.0 2.0"
$ns_ at 3.0 "$node_(6) setdest 341.0 368.0 1.0"
$ns_ at 3.0 "$node_(8) setdest 314.0 197.0 3.0"
$ns_ at 3.0 "$node_(2) setdest 178.0 397.0 2.0"
$ns_ at 3.0 "$node_(9) setdest 318.0 156.0 3.0"
$ns_ at 3.0 "$node_(5) setdest 397.0 247.0 1.0"
$ns_ at 3.0 "$node_(4) setdest 134.0 186.0 1.0"
$ns_ at 3.0 "$node_(7) setdest 476.0 169.0 2.0"
$ns_ at 3.0 "$node_(1) setdest 165.0 448.0 3.0"

$ns_ at 20.0 "$node_(2) setdest 123.0 316.0 1.0"
$ns_ at 20.0 "$node_(8) setdest 412.0 157.0 1.0"
$ns_ at 20.0 "$node_(4) setdest 276.0 348.0 1.0"
$ns_ at 20.0 "$node_(7) setdest 128.0 275.0 2.0"
$ns_ at 20.0 "$node_(1) setdest 273.0 478.0 2.0"
$ns_ at 20.0 "$node_(6) setdest 496.0 265.0 2.0"
$ns_ at 20.0 "$node_(3) setdest 148.0 443.0 3.0"
$ns_ at 20.0 "$node_(9) setdest 179.0 139.0 3.0"
$ns_ at 20.0 "$node_(5) setdest 389.0 185.0 3.0"
$ns_ at 20.0 "$node_(0) setdest 497.0 239.0 1.0"

$ns_ at 80.0 "$node_(3) setdest 175.0 149.0 3.0"
$ns_ at 80.0 "$node_(6) setdest 145.0 434.0 2.0"
$ns_ at 80.0 "$node_(2) setdest 135.0 187.0 1.0"
$ns_ at 80.0 "$node_(9) setdest 426.0 178.0 3.0"
$ns_ at 80.0 "$node_(0) setdest 174.0 497.0 2.0"
$ns_ at 80.0 "$node_(5) setdest 356.0 279.0 1.0"
$ns_ at 80.0 "$node_(8) setdest 431.0 498.0 3.0"
$ns_ at 80.0 "$node_(1) setdest 129.0 389.0 2.0"
$ns_ at 80.0 "$node_(7) setdest 285.0 379.0 2.0"
$ns_ at 80.0 "$node_(4) setdest 355.0 219.0 1.0"

$ns_ at 150.0 "$node_(3) setdest 239.0 179.0 3.0"
$ns_ at 150.0 "$node_(6) setdest 149.0 277.0 2.0"
$ns_ at 150.0 "$node_(2) setdest 491.0 368.0 1.0"
$ns_ at 150.0 "$node_(9) setdest 167.0 178.0 3.0"
$ns_ at 150.0 "$node_(0) setdest 410.0 286.0 2.0"
$ns_ at 150.0 "$node_(5) setdest 289.0 367.0 1.0"
$ns_ at 150.0 "$node_(8) setdest 222.0 477.0 3.0"
$ns_ at 150.0 "$node_(1) setdest 381.0 157.0 2.0"
$ns_ at 150.0 "$node_(7) setdest 172.0 462.0 2.0"
$ns_ at 150.0 "$node_(4) setdest 111.0 444.0 1.0"

$ns_ at 220.0 "$node_(3) setdest 239.0 279.0 1.0"
$ns_ at 220.0 "$node_(6) setdest 249.0 277.0 1.0"
$ns_ at 220.0 "$node_(2) setdest 291.0 268.0 1.0"
$ns_ at 220.0 "$node_(9) setdest 237.0 278.0 1.0"
$ns_ at 220.0 "$node_(0) setdest 210.0 216.0 1.0"
$ns_ at 220.0 "$node_(5) setdest 289.0 247.0 1.0"
$ns_ at 220.0 "$node_(8) setdest 222.0 227.0 1.0"
$ns_ at 220.0 "$node_(1) setdest 291.0 257.0 1.0"
$ns_ at 220.0 "$node_(7) setdest 272.0 262.0 1.0"
$ns_ at 220.0 "$node_(4) setdest 211.0 244.0 1.0"

# membuat traffik antar node
$ns_ at 1.0 "$node_(9) color blue"
$ns_ at 1.2 "$node_(9) add-mark c4 red circle"
$ns_ at 1.0 "$node_(1) color blue"
$ns_ at 1.2 "$node_(1) add-mark c4 red circle"
set tcp [new Agent/TCP]
$tcp set window_ 2000
set sink [new Agent/TCPSink]
$ns_ attach-agent $node_(9) $tcp
$ns_ attach-agent $node_(1) $sink
$ns_ connect $tcp $sink
set ftp [new Application/FTP]
$ftp set packetSize_ 500 ;# nilai paket yang dibangkitkan
$ftp set rate_ 64 Kb ;# sending rate
$ftp attach-agent $tcp
$ns_ at 1.0 "$ftp start"
$ns_ at 300 "$ftp stop"

set tcp1 [new Agent/TCP]
$tcp1 set window_ 2000
set sink1 [new Agent/TCPSink]
$ns_ attach-agent $node_(1) $tcp1
$ns_ attach-agent $node_(9) $sink1
$ns_ connect $tcp1 $sink1
set ftp1 [new Application/FTP]
$ftp1 set packetSize_ 500 ;# nilai paket yang dibangkitkan
$ftp1 set rate_ 64 Kb ;# sending rate
$ftp1 attach-agent $tcp1
$ns_ at 1.0 "$ftp1 start"
$ns_ at 300 "$ftp1 stop"

$ns_ at 1.5 "$node_(2) color green"
$ns_ at 1.5 "$node_(8) color green"
$ns_ at 1.7 "$node_(2) add-mark c4 red circle"
$ns_ at 1.7 "$node_(8) add-mark c4 red circle"
set tcp2 [new Agent/TCP]
$tcp2 set window_ 2000
set sink2 [new Agent/TCPSink]
$ns_ attach-agent $node_(2) $tcp2
$ns_ attach-agent $node_(8) $sink2
$ns_ connect $tcp2 $sink2
set ftp2 [new Application/FTP]
$ftp2 set packetSize_ 500 ;# nilai paket yang dibangkitkan
$ftp2 set rate_ 64 Kb ;# sending rate
$ftp2 attach-agent $tcp2
$ns_ at 1.0 "$ftp2 start"
$ns_ at 300 "$ftp2 stop"

set tcp3 [new Agent/TCP]
$tcp3 set window_ 2000
set sink3 [new Agent/TCPSink]
$ns_ attach-agent $node_(8) $tcp3
$ns_ attach-agent $node_(2) $sink3
$ns_ connect $tcp3 $sink3
set ftp3 [new Application/FTP]
$ftp3 set packetSize_ 500 ;# nilai paket yang dibangkitkan
$ftp3 set rate_ 64 Kb ;# sending rate
$ftp3 attach-agent $tcp3
$ns_ at 1.0 "$ftp3 start"
$ns_ at 300 "$ftp3 stop"

############################################################

# menentukan posisi node initial pada network animator
for {set i 0} {$i < $val(nn) } { incr i } {
$ns_ initial_node_pos $node_($i) 10
}

# memberi tahu node kapan simulasi berhenti
for {set i 0} {$i < $val(nn) } { incr i } {
$ns_ at $val(stop) "$node_($i) reset";
}

# meghentikan nam dan simulasi
$ns_ at $val(stop) "$ns_ nam-end-wireless $val(stop)"
$ns_ at $val(stop) "stop"
$ns_ at 301.0 "puts \"end simulation\" ; $ns_ halt"

# prosedur berhenti
proc stop {} {
global ns_ tracefd namtrace
$ns_ flush-trace
close $tracefd
close $namtrace

exec nam 10nodesprojfszbr.nam &
exit 0
}

# memulai simulasi
$ns_ run
