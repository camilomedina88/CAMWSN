set val(chan)           Channel/WirelessChannel    ;#Channel Type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(ni)		4
set val(nn)             5                          ;# number of mobilenodes
set val(rp)             AODV                       ;# routing protocol
set val(x)		500
set val(y)		500

set ns_ [new Simulator]

set tracefd [open im3p.tr w]
$ns_ trace-all $tracefd 

set namtrace [open im3p.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

set topo [new Topography]

$topo load_flatgrid $val(x) $val(y)

for {set i 0} {$i < $val(ni)} {incr i} {
	set chan_($i) [new $val(chan)]
}

create-god [expr $val(nn)*$val(ni)]

#set chan_1_ [new $val(chan)]
#set chan_2_ [new $val(chan)]

$ns_ node-config -adhocRouting $val(rp) \
		-llType $val(ll) \
		-macType $val(mac) \
		-ifqType $val(ifq) \
		-ifqLen $val(ifqlen) \
		-antType $val(ant) \
		-propType $val(prop) \
		-phyType $val(netif) \
		-channel $chan_(0) \
		-topoInstance $topo \
		-agentTrace ON \
		-routerTrace ON \
		-macTrace ON \
		-movementTrace OFF \
		-ifNum $val(ni) 

$ns_ change-numifs 2
$ns_ add-channel 0 $chan_(0)
$ns_ add-channel 1 $chan_(2) 
set node_(0) [$ns_ node]
$node_(0) random-motion 0

$ns_ change-numifs 1
$ns_ add-channel 0 $chan_(2)
#$ns_ add-channel 1 $chan_(2) 
set node_(1) [$ns_ node]
$node_(1) random-motion 0

$ns_ change-numifs 1
$ns_ add-channel 0 $chan_(2)
#$ns_ add-channel 1 $chan_(2) 
set node_(2) [$ns_ node]
$node_(2) random-motion 0

$ns_ change-numifs 1
$ns_ add-channel 0 $chan_(2)
#$ns_ add-channel 1 $chan_(2) 
set node_(3) [$ns_ node]
$node_(3) random-motion 0

$ns_ change-numifs 1
$ns_ add-channel 0 $chan_(2)
#$ns_ add-channel 1 $chan_(2) 
set node_(4) [$ns_ node]
$node_(4) random-motion 0

for {set i 0} {$i < $val(nn)} {incr i} {
	$ns_ initial_node_pos $node_($i) 40
}

$ns_ at 10.0 "$node_(1) setdest 490.0 80.0 20.0"
$ns_ at 10.0 "$node_(0) setdest 50.0 80.0 20.0"
$ns_ at 10.0 "$node_(2) setdest 255.0 150.0 20.0"
$ns_ at 10.0 "$node_(3) setdest 255.0 80.0 20.0"
$ns_ at 10.0 "$node_(4) setdest 255.0 20.0 20.0"

# TCP connections between node_(0) and node_(1)
set tcp [new Agent/TCP]
#$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns_ attach-agent $node_(0) $tcp
$ns_ attach-agent $node_(1) $sink
$ns_ connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns_ at 10.0 "$ftp start"
$ns_ at 145.0 "$ftp stop" 

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
