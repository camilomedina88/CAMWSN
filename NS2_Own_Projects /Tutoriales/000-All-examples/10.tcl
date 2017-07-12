#
#   
# http://www.linuxquestions.org/questions/linux-software-2/invalid-command-name-agent-consbuffer-4175412391/#8
#
set val(chan)	Channel/WirelessChannel	  ;# tipe channel
set val(prop)	Propagation/TwoRayGround  ;# model propagasi radio
set val(netif)	Phy/WirelessPhy/802_15_4  ;# network inteface type
set val(mac)	Mac/802_15_4	 	  ;# MAC type
set val(ifq)	Queue/DropTail/PriQueue	  ;# interface queue type
set val(ll)	LL			  ;# link layer type
set val(ant)	Antenna/OmniAntenna	  ;# model antena	
set val(ifqlen)	5			  ;# jumlah max pkt dlm antrian
set val(nn)	10			  ;# jumlah mobile node
set val(rp)	FSR			  ;# tipe routing protokol
set val(x)	500			  ;# dimensi topografi x
set val(y)	500			  ;# dimensi topografi y
set val(stop)	200			  ;# waktu simulasi berhenti

# main program
set ns_ [new Simulator]

# set Tracefile
set tracefd [open 10.tr w]
$ns_ trace-all $tracefd

# set Namfile
set namtrace [open 10.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

# create god
create-god $val(nn)
set chan_1_ [new $val(chan)]
set chan_2_ [new $val(chan)]

$ns_ node-config -adhocRouting $val(rp) \
		-llType	$val(ll) \
		-macType $val(mac) \
		-ifqType $val(ifq) \
		-ifqLen $val(ifqlen) \
		-antType $val(ant) \
		-propType $val(prop) \
		-phyType $val(netif) \
		-topoInstance $topo \
		-agentTrace ON \
		-routerTrace ON \
		-macTrace OFF \
		-movementTrace OFF \
		-channel $chan_1_


	for {set i 0} {$i < $val(nn) } { incr i } {
		set node_($i) [$ns_ node] 
	$node_($i) random-motion 0
	}




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


$ns_ at 3.0 "$node_(0) setdest 431.0 178.0 1.0"
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


set tcp [new Agent/TCP]
$tcp set window_ 2000
set sink [new Agent/TCPSink]
$ns_ attach-agent $node_(0) $tcp
$ns_ attach-agent $node_(1) $sink
$ns_ connect $tcp $sink 
set ftp [new Application/FTP]
$ftp set packetSize_ 20		
$ftp set rate_ 124 Kb		;# sending rate
$ftp attach-agent $tcp 
$ns_ at 1.0 "$ftp start"
$ns_ at 1500 "$ftp stop"

set tcp1 [new Agent/TCP]
$tcp1 set window_ 2000
set sink1 [new Agent/TCPSink]
$ns_ attach-agent $node_(2) $tcp1
$ns_ attach-agent $node_(3) $sink1
$ns_ connect $tcp1 $sink1 
set ftp1 [new Application/FTP]
$ftp1 set packetSize_ 20	
$ftp1 set rate_ 124 Kb		
$ftp1 attach-agent $tcp1 
$ns_ at 1.0 "$ftp1 start"
$ns_ at 1500 "$ftp1 stop"

set tcp2 [new Agent/TCP]
$tcp2 set window_ 2000
set sink2 [new Agent/TCPSink]
$ns_ attach-agent $node_(5) $tcp2
$ns_ attach-agent $node_(4) $sink2
$ns_ connect $tcp2 $sink2 
set ftp2 [new Application/FTP]
$ftp2 set packetSize_ 20
$ftp2 set rate_ 124 Kb		
$ftp2 attach-agent $tcp2 
$ns_ at 1.0 "$ftp2 start"
$ns_ at 1500 "$ftp2 stop"

set tcp3 [new Agent/TCP]
$tcp3 set window_ 2000
set sink3 [new Agent/TCPSink]
$ns_ attach-agent $node_(2) $tcp3
$ns_ attach-agent $node_(0) $sink3
$ns_ connect $tcp3 $sink3 
set ftp3 [new Application/FTP]
$ftp3 set packetSize_ 20
$ftp3 set rate_ 124 Kb		
$ftp3 attach-agent $tcp3 
$ns_ at 1.0 "$ftp3 start"
$ns_ at 1500 "$ftp3 stop"

set tcp4 [new Agent/TCP]
$tcp4 set window_ 2000
set sink4 [new Agent/TCPSink]
$ns_ attach-agent $node_(6) $tcp4
$ns_ attach-agent $node_(7) $sink4
$ns_ connect $tcp4 $sink4 
set ftp4 [new Application/FTP]
$ftp4 set packetSize_ 20	
$ftp4 set rate_ 124 Kb		
$ftp4 attach-agent $tcp4 
$ns_ at 1.0 "$ftp4 start"
$ns_ at 1500 "$ftp4 stop"

set tcp5 [new Agent/TCP]
$tcp5 set window_ 2000
set sink5 [new Agent/TCPSink]
$ns_ attach-agent $node_(7) $tcp5
$ns_ attach-agent $node_(8) $sink5
$ns_ connect $tcp5 $sink5 
set ftp5 [new Application/FTP]
$ftp5 set packetSize_ 20	
$ftp5 set rate_ 124 Kb	
$ftp5 attach-agent $tcp5 
$ns_ at 1.0 "$ftp5 start"
$ns_ at 1500 "$ftp5 stop"

set tcp6 [new Agent/TCP]
$tcp6 set window_ 2000
set sink6 [new Agent/TCPSink]
$ns_ attach-agent $node_(9) $tcp6
$ns_ attach-agent $node_(6) $sink6
$ns_ connect $tcp6 $sink6 
set ftp6 [new Application/FTP]
$ftp6 set packetSize_ 20	
$ftp6 set rate_ 124 Kb		
$ftp6 attach-agent $tcp6 
$ns_ at 1.0 "$ftp6 start"
$ns_ at 1500 "$ftp6 stop"

set tcp7 [new Agent/TCP]
$tcp7 set window_ 2000
set sink7 [new Agent/TCPSink]
$ns_ attach-agent $node_(1) $tcp7
$ns_ attach-agent $node_(7) $sink7
$ns_ connect $tcp7 $sink7 
set ftp7 [new Application/FTP]
$ftp7 set packetSize_ 20	
$ftp7 set rate_ 124 Kb		
$ftp7 attach-agent $tcp7 
$ns_ at 1.0 "$ftp7 start"
$ns_ at 1500 "$ftp7 stop"


	for {set i 0} {$i < $val(nn) } { incr i } {
	$ns_ initial_node_pos $node_($i) 10
	}

	for {set i 0} {$i < $val(nn) } { incr i } {
	$ns_ at $val(stop) "$node_($i) reset";
	}

$ns_ at $val(stop) "$ns_ nam-end-wireless $val(stop)"
$ns_ at $val(stop) "stop"
$ns_ at 201.0 "puts \"end simulation\" ; $ns_ halt"


proc stop {} {
	global ns_ tracefd namtrace
	$ns_ flush-trace
	close $tracefd
	close $namtrace

	exec nam 10.nam &
	exit 0
}

$ns_ run
