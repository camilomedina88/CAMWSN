#    http://www.linuxquestions.org/questions/linux-software-2/problem-while-executing-an-tcl-code-on-ns-2-35-a-4175502054/#3   

set val(chan) Channel/WirelessChannel 
set val(prop) Propagation/TwoRayGround 
set val(netif) Phy/WirelessPhy 
set val(mac) Mac/802_11 
set val(ifq) Queue/DropTail/PriQueue 
set val(ll) LL 
set val(ant) Antenna/OmniAntenna 
set val(x) 900
set val(y) 550
set val(ifqlen) 50 
set val(adhocRouting) OLSR
set val(nn) 30 

set val(stop) 30.0
# Initialize Global Variables

set ns_ [new Simulator]
$ns_ use-newtrace

set val(tracefile) aodvsm1.tr
set val(namtrace) aodvsm1.nam
set val(throughtrace) aodvsm1.tpt

set tracefd  [open $val(tracefile) w]
$ns_ trace-all $tracefd
set f [open 1_out.tr w]
set namtrace [open $val(namtrace) w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)
set f0 [open packets_received.tr w]
set f1 [open packets_lost.tr w]
set f2 [open proj_out2.tr w]
set f3 [open proj_out3.tr w]
set f4 [open proj_out4.tr w]
set f5 [open proj_out5.tr w]
set throughFile  [open $val(throughtrace) w]

set topo  [new Topography]

$topo load_flatgrid $val(x) $val(y)

set god_ [create-god $val(nn)]


$ns_ node-config -adhocRouting $val(adhocRouting) \
                  -llType $val(ll) \
                  -macType $val(mac) \
                  -ifqType $val(ifq) \
                  -ifqLen $val(ifqlen) \
                  -antType $val(ant) \
                  -propType $val(prop) \
                  -phyType $val(netif) \
                  -channelType $val(chan) \
                  -topoInstance $topo \
	          -agentTrace OFF \
	          -routerTrace ON \
	          -macTrace OFF \
	          -movementTrace OFF 
#	          -wiredRouting OFF 
     

for {set i 0} {$i < $val(nn) } {incr i} {
      	set node_($i) [$ns_ node]
      	$node_($i) random-motion 0 ;
}

$node_(0) set X_ 27.00
$node_(0) set Y_ 72.00
$node_(0) set Z_ 0.00

$node_(1) set X_ 512.00
$node_(1) set Y_ 475.00
$node_(1) set Z_ 0.00

$node_(2) set X_ 200.00
$node_(2) set Y_ 194.00
$node_(2) set Z_ 0.00

$node_(3) set X_ 74.00
$node_(3) set Y_ 219.00
$node_(3) set Z_ 0.00

$node_(12) set X_ 496.00
$node_(12) set Y_ 438.00
$node_(12) set Z_ 0.00

$node_(4) set X_ 250.00
$node_(4) set Y_ 320.00
$node_(4) set Z_ 0.00

$node_(5) set X_ 312.00
$node_(5) set Y_ 164.00
$node_(5) set Z_ 0.00

$node_(19) set X_ 610.00
$node_(19) set Y_ 605.00
$node_(19) set Z_ 0.00

$node_(6) set X_ 473.00
$node_(6) set Y_ 265.00
$node_(6) set Z_ 0.00

$node_(7) set X_ 492.00
$node_(7) set Y_ 4.00
$node_(7) set Z_ 0.00

$node_(8) set X_ 459.00
$node_(8) set Y_ 63.00
$node_(8) set Z_ 0.00


$node_(9) set X_ 610.00
$node_(9) set Y_ 288.00
$node_(9) set Z_ 0.00


$node_(10) set X_ 212.00
$node_(10) set Y_ 108.00
$node_(10) set Z_ 0.00

$node_(11) set X_ 563.00
$node_(11) set Y_ 447.00
$node_(11) set Z_ 0.00

$node_(13) set X_ 485.00
$node_(13) set Y_ 105.00
$node_(13) set Z_ 0.00

$node_(14) set X_ 363.00
$node_(14) set Y_ 449.00
$node_(14) set Z_ 0.00

$node_(15) set X_ 500.00
$node_(15) set Y_ 179.00
$node_(15) set Z_ 0.00

$node_(16) set X_ 400.00
$node_(16) set Y_ 498.00
$node_(16) set Z_ 0.00

$node_(17) set X_ 278.00
$node_(17) set Y_ 285.00
$node_(17) set Z_ 0.00

$node_(18) set X_ 428.00
$node_(18) set Y_ 163.00
$node_(18) set Z_ 0.00

$node_(20) set X_ 114.00
$node_(20) set Y_ 102.00
$node_(20) set Z_ 0.00

$node_(21) set X_ 473.00
$node_(21) set Y_ 265.00
$node_(21) set Z_ 0.00
$node_(22) set X_ 241.00
$node_(22) set Y_ 414.00
$node_(22) set Z_ 0.00
$node_(23) set X_ 200.00
$node_(23) set Y_ 194.00
$node_(23) set Z_ 0.00
$node_(24) set X_ 492.00
$node_(24) set Y_ 4.00
$node_(24) set Z_ 0.00
$node_(25) set X_ 459.00
$node_(25) set Y_ 63.00
$node_(25) set Z_ 0.00
$node_(26) set X_ 418.00
$node_(26) set Y_ 659.00
$node_(26) set Z_ 0.00
$node_(27) set X_ 258.00
$node_(27) set Y_ 240.00
$node_(27) set Z_ 0.00
$node_(28) set X_ 664.00
$node_(28) set Y_ 47.00
$node_(28) set Z_ 0.00
$node_(29) set X_ 304.00
$node_(29) set Y_ 412.00
$node_(29) set Z_ 0.00


$ns_ at 1.0 "$node_(19) setdest 880.0 220.0 10.0"
$ns_ at 1.0 "$node_(10) setdest 400.0  118.0 10.0"
$ns_ at 1.0 "$node_(12) setdest 496.OO 500.0 10.0"
$ns_ at 1.0 "$node_(8) setdest 500.O0 63.00 10.0"

$ns_ at 0.0 "$node_(16) setdest 555.0 220.0 10.0"
$ns_ at 1.0 "$node_(1) setdest 301.0 450.0 10.0"
$ns_ at 1.0 "$node_(11) setdest 280.0 500.0 10.0"


for {set i 0} {$i < $val(nn)} {incr i} {
 $ns_ initial_node_pos $node_($i) 35
     }

$ns_ at 0.0 "$node_(0) label \"Src_AODV\""
     $ns_ at 0.0 "$node_(0) add-mark src yellow circle" 
     $ns_ at 0.0 "$node_(19) label \"Dest_AODV\""
     $ns_ at 0.0 "$node_(19) add-mark src blue circle" 

set udp [new Agent/UDP]
     $ns_ attach-agent $node_(0) $udp
     $udp set class_ 1
     $udp  set fid_ 1
	 
	 set udp2 [new Agent/UDP]
     $ns_ attach-agent $node_(3) $udp2
     $udp2 set class_ 1
     $udp2  set fid_ 1
	 
	 set udp3 [new Agent/UDP]
     $ns_ attach-agent $node_(1) $udp3
     $udp3 set class_ 1
     $udp3  set fid_ 1
     
	 set cbr [new Application/Traffic/CBR]
     $cbr attach-agent $udp
     $cbr set rate_ 20kb
     $cbr set packetSize_ 512
	 
	 set cbr2 [new Application/Traffic/CBR]
     $cbr2 attach-agent $udp2
     $cbr2 set rate_ 20kb
     $cbr2 set packetSize_ 512
	 
	 set cbr3 [new Application/Traffic/CBR]
     $cbr3 attach-agent $udp3
     $cbr3 set rate_ 20kb
     $cbr3 set packetSize_ 512
	 
     set sink0 [new Agent/LossMonitor]
     $ns_ attach-agent $node_(29) $sink0
     $ns_ connect $udp $sink0

	 set sink1 [new Agent/LossMonitor]
     $ns_ attach-agent $node_(28) $sink1
     $ns_ connect $udp2 $sink1
	 
	  set sink2 [new Agent/LossMonitor]
     $ns_ attach-agent $node_(24) $sink2
     $ns_ connect $udp3 $sink2
	 
proc record {} {
  global f0 f1 f2 f3 f4 f5 sink0 sink1 sink2
   #Get An Instance Of The Simulator
   set ns [Simulator instance]
   
   #Set The Time After Which The Procedure Should Be Called Again
   set time 0.05
   #How Many Bytes Have Been Received By The Traffic Sinks?
   set bw0 [$sink0 set npkts_]
   set bw1 [$sink0 set nlost_]
   set bw2 [$sink1 set npkts_]
   set bw3 [$sink1 set nlost_]
   set bw4 [$sink2 set npkts_]
   set bw5 [$sink2 set nlost_]
   #Get The Current Time
   set now [$ns now]
   
   #Save Data To The Files
   puts $f0 "$now [expr $bw0]"
   puts $f1 "$now [expr $bw1]"
   puts $f2 "$now [expr $bw2]"
   puts $f3 "$now [expr $bw3]"
   puts $f4 "$now [expr $bw4]"
   puts $f5 "$now [expr $bw5]"
   #Re-Schedule The Procedure
   $ns at [expr $now+$time] "record"
  }

$ns_ at 0.0 "record"


     $ns_ at 0.0  "$cbr start"
     $ns_ at 28.0  "$cbr stop"
$ns_ at 0.0  "$cbr2 start"
     $ns_ at 28.0  "$cbr2 stop"
$ns_ at 0.0  "$cbr3 start"
     $ns_ at 28.0  "$cbr3 stop"
     $ns_ at 30.0 "stop"
  


     proc stop {} {
   	global ns_ tracefd namtrace throughFile f0 f1 f2 f3 f4 f5
	$ns_ flush-trace
	close $tracefd
	close $namtrace
	close $throughFile
	close $f0
	close $f1
	close $f2
	close $f3
	close $f4
	close $f5
        exec nam aodvsm1.nam &
	exec xgraph packets_received.tr packets_lost.tr proj_out2.tr proj_out3.tr proj_out4.tr proj_out5.tr
	exit 0
	}
	puts "Starting Simulation..."
	$ns_ run
