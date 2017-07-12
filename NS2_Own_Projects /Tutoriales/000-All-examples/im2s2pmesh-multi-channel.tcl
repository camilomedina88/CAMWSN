#      http://www.linuxquestions.org/questions/linux-newbie-8/urgent-4175520906/
#      -----------------------------


set val(chan) Channel/WirelessChannel ;#Channel Type
set val(prop) Propagation/TwoRayGround ;# radio-propagation model
set val(netif) Phy/WirelessPhy ;# network interface type
set val(mac) Mac/802_11 ;# MAC type
set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model
set val(ifqlen) 50 ;# max packet in ifq
set val(ni) 3
set val(nn) 6 ;# number of mobilenodes
set val(rp) DSDV ;# routing protocol
set val(x) 500
set val(y) 500

set ns_ [new Simulator]

set tracefd [open im2s2pmesh.tr w]
$ns_ trace-all $tracefd

set namtrace [open im2s2pmesh.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

set topo [new Topography]

$topo load_flatgrid $val(x) $val(y)

for {set i 0} {$i < $val(ni)} {incr i} {
set chan_($i) [new $val(chan)]
}

create-god [expr $val(nn)*$val(ni)]

$ns_ node-config -adhocRouting $val(rp) \
-llType $val(ll) \
-macType $val(mac) \
-ifqType $val(ifq) \
-ifqLen $val(ifqlen) \
-antType $val(ant) \
-propType $val(prop) \
-phyType $val(netif) \
-topoInstance $topo \
-agentTrace ON \
-routerTrace ON \
-macTrace ON \
-movementTrace OFF \
-ifNum $val(ni)

$ns_ change-numifs $val(ni)
for {set i 0} {$i < $val(ni)} {incr i} {
$ns_ add-channel $i $chan_($i)
}

for {set i 0} {$i < $val(nn) } {incr i} {
set node_($i) [$ns_ node ]
$node_($i) random-motion 0 ;# disable random motion
}

for {set i 0} {$i < $val(nn)} {incr i} {
$ns_ initial_node_pos $node_($i) 40
}

$ns_ at 10.0 "$node_(1) setdest 490.0 80.0 20.0"
$ns_ at 10.0 "$node_(0) setdest 50.0 80.0 20.0"
$ns_ at 10.0 "$node_(2) setdest 150.0 120.0 20.0"
$ns_ at 10.0 "$node_(3) setdest 300.0 120.0 20.0"
$ns_ at 10.0 "$node_(4) setdest 150.0 50.0 20.0"
$ns_ at 10.0 "$node_(5) setdest 300.0 50.0 20.0"


# TCP connections

set tcp0 [new Agent/TCP]
$tcp0 set class_ 2
set sink0 [new Agent/TCPSink]
$ns_ attach-agent $node_(0) $tcp0
$ns_ attach-agent $node_(1) $sink0
$ns_ connect $tcp0 $sink0
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ns_ at 50.0 "$ftp0 start"

set tcp1 [new Agent/TCP]
$tcp1 set class_ 2
set sink1 [new Agent/TCPSink]
$ns_ attach-agent $node_(0) $tcp1
$ns_ attach-agent $node_(1) $sink1
$ns_ connect $tcp1 $sink1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ns_ at 50.0 "$ftp1 start"

#
# Tell nodes when the simulation ends
#
for {set i 0} {$i < $val(nn) } {incr i} {
$ns_ at 150.0 "$node_($i) reset";
}
$ns_ at 150.0001 "stop"
$ns_ at 150.0002 "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
global ns_ tracefd
close $tracefd
}
puts "Starting Simulation..."
$ns_ run
