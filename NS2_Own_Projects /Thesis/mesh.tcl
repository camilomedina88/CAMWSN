set val(chan)   	Channel/WirelessChannel
set val(prop)   	Propagation/TwoRayGround
set val(ant)    	Antenna/OmniAntenna
set val(ll)     	LL
set val(ifq)    	Queue/DropTail/PriQueue
set val(ifqlen) 	50
set val(netif)  	Phy/WirelessPhy/802_15_4
set val(mac)    	Mac/802_15_4
set val(rp)     	AODV
set val(nn)     	100
set val(x)      	1000
set val(y)      	1000
set val(stop)   	15
set val(traffic)        cbr
set pckstr 		1
set val(traffic)        tcp
set ns              	[new Simulator]
set val(Congestion) 		"DAIPAS" 
#FUSION,ECODA,DAIPAS


set tracefd       	[open Congestionmesh.tr w]
set namtrace      	[open Congestionmesh.nam w] 



$ns trace-all $tracefd
$ns namtrace-all-wireless $namtrace $val(x) $val(y)


set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)
set god_ [create-god $val(nn) ]




        $ns node-config -adhocRouting $val(rp) \
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
		   -energyModel "EnergyModel" \
		   -rxPower 2.0 \
		   -txPower 2.0 \
		   -initialEnergy 1000 \
		   -sleepPower 0.5 \
		   -transitionPower 0.2 \
		   -transitionTime 0.001 \
		   -idlePower 0.1


# Energy model
     $ns node-config  -energyModel EnergyModel \
		      -rxPower 2.0 \
		      -txPower 2.0 \
		      -initialEnergy 1000 \
		      -sleepPower 0.5 \
		      -transitionPower 0.2 \
		      -transitionTime 0.001 \
		      -idlePower 0.1
     
             
      for {set i 0} {$i < $val(nn) } { incr i } {
            set node_($i) [$ns node]     
      }

      for {set i 0} {$i < $val(nn) } {incr i } {
            $node_($i) color blue
            $ns at 0.0 "$node_($i) color blue"
      }
   


 for {set i 0} {$i < $val(nn) } {incr i } {
$ns at 0.2 "$node_($i) label \"sensorNode\""
      }



for {set i $val(nn)} {$i < $val(nn) } {incr i } {
#start sending beacon message
$ns at 0.0 "[$node_($i) set ragent_] id"
}



for {set i 0} {$i < $val(nn)} { incr i } {

$ns initial_node_pos $node_($i) 30
}



for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "$node_($i) reset";
}


#$ns at 0.1 "destination"



#$ns at 0.1 "$node_(10) label \" Source \""
#$ns at 0.1 "$node_(15) label \" Destination \""
#$ns at 1.0 "$node_(31) label \" Attacker \""



$ns at 0.1 "$node_(1) color red"
$ns at 0.1 "$node_(1) add-mark m1 red circle"
$ns at 0.2 "$node_(1) label \"SinkNode\""
#$ns at 0.1 "$node_(15) color red"
#$ns at 0.1 "$node_(15) add-mark m1 red circle"

$ns at 0.0001 "$ns trace-annotate \"      \""
$ns at 0.0001 "$ns trace-annotate \" Network Formation  \""
$ns at 0.0001 "$ns trace-annotate \"      \""
$ns at 0.1 "$ns trace-annotate \" Select Congestion Control Algorithm  \""
$ns at 0.1 "$ns trace-annotate \"          \""
$ns at 1.0 "$ns trace-annotate \" Perform Packet Transmission  \""
$ns at 1.0 "$ns trace-annotate \"    \""


 for {set i 0} {$i< $val(stop) } {incr i} {
$ns at $i "destination1"
}

#============================================

 #Create 100 nodes

#$node_(0) set X_ 106
#$node_(0) set Y_ 547
#$node_(0) set Z_ 0.0


$node_(1) set X_ 256
$node_(1) set Y_ 547
$node_(1) set Z_ 0.0


$node_(2) set X_ 406
$node_(2) set Y_ 547
$node_(2) set Z_ 0.0


$node_(3) set X_ 556
$node_(3) set Y_ 547
$node_(3) set Z_ 0.0


$node_(4) set X_ 706
$node_(4) set Y_ 547
$node_(4) set Z_ 0.0


$node_(5) set X_ 856
$node_(5) set Y_ 547
$node_(5) set Z_ 0.0


$node_(6) set X_ 1006
$node_(6) set Y_ 547
$node_(6) set Z_ 0.0


$node_(7) set X_ 1156
$node_(7) set Y_ 547
$node_(7) set Z_ 0.0


$node_(8) set X_ 1306
$node_(8) set Y_ 547
$node_(8) set Z_ 0.0


$node_(9) set X_ 1456
$node_(9) set Y_ 547
$node_(9) set Z_ 0.0


$node_(10) set X_ 106
$node_(10) set Y_ 397
$node_(10) set Z_ 0.0


$node_(11) set X_ 256
$node_(11) set Y_ 397
$node_(11) set Z_ 0.0


$node_(12) set X_ 406
$node_(12) set Y_ 397
$node_(12) set Z_ 0.0


$node_(13) set X_ 556
$node_(13) set Y_ 397
$node_(13) set Z_ 0.0


$node_(14) set X_ 706
$node_(14) set Y_ 397
$node_(14) set Z_ 0.0


$node_(15) set X_ 856
$node_(15) set Y_ 397
$node_(15) set Z_ 0.0


$node_(16) set X_ 1006
$node_(16) set Y_ 397
$node_(16) set Z_ 0.0



$node_(17) set X_ 1156
$node_(17) set Y_ 397
$node_(17) set Z_ 0.0

$node_(18) set X_ 1306
$node_(18) set Y_ 397
$node_(18) set Z_ 0.0

$node_(19) set X_ 1456
$node_(19) set Y_ 397
$node_(19) set Z_ 0.0

$node_(20) set X_ 106
$node_(20) set Y_ 247
$node_(20) set Z_ 0.0

$node_(21) set X_ 256
$node_(21) set Y_ 247
$node_(21) set Z_ 0.0


$node_(22) set X_ 406
$node_(22) set Y_ 247
$node_(22) set Z_ 0.0

$node_(23) set X_ 556
$node_(23) set Y_ 247
$node_(23) set Z_ 0.0

$node_(24) set X_ 706
$node_(24) set Y_ 247
$node_(24) set Z_ 0.0

$node_(25) set X_ 856
$node_(25) set Y_ 247
$node_(25) set Z_ 0.0


$node_(26) set X_ 1006
$node_(26) set Y_ 247
$node_(26) set Z_ 0.0

$node_(27) set X_ 1156
$node_(27) set Y_ 247
$node_(27) set Z_ 0.0

$node_(28) set X_ 1306
$node_(28) set Y_ 247
$node_(28) set Z_ 0.0

$node_(29) set X_ 1456
$node_(29) set Y_ 247
$node_(29) set Z_ 0.0


$node_(30) set X_ 106
$node_(30) set Y_ 97
$node_(30) set Z_ 0.0

$node_(31) set X_ 256
$node_(31) set Y_ 97
$node_(31) set Z_ 0.0


$node_(32) set X_ 406
$node_(32) set Y_ 97
$node_(32) set Z_ 0.0
$node_(33) set X_ 556
$node_(33) set Y_ 97
$node_(33) set Z_ 0.0
$node_(34) set X_ 706
$node_(34) set Y_ 97
$node_(34) set Z_ 0.0
$node_(35) set X_ 856
$node_(35) set Y_ 97
$node_(35) set Z_ 0.0
$node_(36) set X_ 1006
$node_(36) set Y_ 97
$node_(36) set Z_ 0.0


$node_(37) set X_ 1156
$node_(37) set Y_ 97
$node_(37) set Z_ 0.0


$node_(38) set X_ 1306
$node_(38) set Y_ 97
$node_(38) set Z_ 0.0

$node_(39) set X_ 1456
$node_(39) set Y_ 97
$node_(39) set Z_ 0.0


$node_(40) set X_ 106
$node_(40) set Y_ -53
$node_(40) set Z_ 0.0

$node_(41) set X_ 256
$node_(41) set Y_ -53
$node_(41) set Z_ 0.0


$node_(42) set X_ 406
$node_(42) set Y_ -53
$node_(42) set Z_ 0.0


$node_(43) set X_ 556
$node_(43) set Y_ -53
$node_(43) set Z_ 0.0

$node_(44) set X_ 706
$node_(44) set Y_ -53
$node_(44) set Z_ 0.0


$node_(45) set X_ 856
$node_(45) set Y_ -53
$node_(45) set Z_ 0.0


$node_(46) set X_ 1006
$node_(46) set Y_ -53
$node_(46) set Z_ 0.0


$node_(47) set X_ 1156
$node_(47) set Y_ -53
$node_(47) set Z_ 0.0


$node_(48) set X_ 1306
$node_(48) set Y_ -53
$node_(48) set Z_ 0.0


$node_(49) set X_ 1456
$node_(49) set Y_ -53
$node_(49) set Z_ 0.0


$node_(50) set X_ 106
$node_(50) set Y_ -203
$node_(50) set Z_ 0.0


$node_(51) set X_ 256
$node_(51) set Y_ -203
$node_(51) set Z_ 0.0


$node_(52) set X_ 406
$node_(52) set Y_ -203
$node_(52) set Z_ 0.0


$node_(53) set X_ 556
$node_(53) set Y_ -203
$node_(53) set Z_ 0.0

$node_(54) set X_ 706
$node_(54) set Y_ -203
$node_(54) set Z_ 0.0


$node_(55) set X_ 856
$node_(55) set Y_ -203
$node_(55) set Z_ 0.0

$node_(56) set X_ 1006
$node_(56) set Y_ -203
$node_(56) set Z_ 0.0


$node_(57) set X_ 1156
$node_(57) set Y_ -203
$node_(57) set Z_ 0.0


$node_(58) set X_ 1306
$node_(58) set Y_ -203
$node_(58) set Z_ 0.0


$node_(59) set X_ 1456
$node_(59) set Y_ -203
$node_(59) set Z_ 0.0

$node_(60) set X_ 106
$node_(60) set Y_ -353
$node_(60) set Z_ 0.0


$node_(61) set X_ 256
$node_(61) set Y_ -353
$node_(61) set Z_ 0.0

$node_(62) set X_ 406
$node_(62) set Y_ -353
$node_(62) set Z_ 0.0


$node_(63) set X_ 556
$node_(63) set Y_ -353
$node_(63) set Z_ 0.0

$node_(64) set X_ 706
$node_(64) set Y_ -353
$node_(64) set Z_ 0.0


$node_(65) set X_ 856
$node_(65) set Y_ -353
$node_(65) set Z_ 0.0


$node_(66) set X_ 1006
$node_(66) set Y_ -353
$node_(66) set Z_ 0.0

$node_(67) set X_ 1156
$node_(67) set Y_ -353
$node_(67) set Z_ 0.0


$node_(68) set X_ 1306
$node_(68) set Y_ -353
$node_(68) set Z_ 0.0


$node_(69) set X_ 1456
$node_(69) set Y_ -353
$node_(69) set Z_ 0.0


$node_(70) set X_ 106
$node_(70) set Y_ -503
$node_(70) set Z_ 0.0


$node_(71) set X_ 256
$node_(71) set Y_ -503
$node_(71) set Z_ 0.0


$node_(72) set X_ 406
$node_(72) set Y_ -503
$node_(72) set Z_ 0.0

$node_(73) set X_ 556
$node_(73) set Y_ -503
$node_(73) set Z_ 0.0

$node_(74) set X_ 706
$node_(74) set Y_ -503
$node_(74) set Z_ 0.0


$node_(75) set X_ 856
$node_(75) set Y_ -503
$node_(75) set Z_ 0.0

$node_(76) set X_ 1006
$node_(76) set Y_ -503
$node_(76) set Z_ 0.0


$node_(77) set X_ 1156
$node_(77) set Y_ -503
$node_(77) set Z_ 0.0

$node_(78) set X_ 1306
$node_(78) set Y_ -503
$node_(78) set Z_ 0.0


$node_(79) set X_ 1456
$node_(79) set Y_ -503
$node_(79) set Z_ 0.0


$node_(80) set X_ 106
$node_(80) set Y_ -653
$node_(80) set Z_ 0.0


$node_(81) set X_ 256
$node_(81) set Y_ -653
$node_(81) set Z_ 0.0


$node_(82) set X_ 406
$node_(82) set Y_ -653
$node_(82) set Z_ 0.0


$node_(83) set X_ 556
$node_(83) set Y_ -653
$node_(83) set Z_ 0.0


$node_(84) set X_ 706
$node_(84) set Y_ -653
$node_(84) set Z_ 0.0

$node_(85) set X_ 856
$node_(85) set Y_ -653
$node_(85) set Z_ 0.0

$node_(86) set X_ 1006
$node_(86) set Y_ -653
$node_(86) set Z_ 0.0


$node_(87) set X_ 1156
$node_(87) set Y_ -653
$node_(87) set Z_ 0.0

$node_(88) set X_ 1306
$node_(88) set Y_ -653
$node_(88) set Z_ 0.0


$node_(89) set X_ 1456
$node_(89) set Y_ -653
$node_(89) set Z_ 0.0


$node_(90) set X_ 106
$node_(90) set Y_ -803
$node_(90) set Z_ 0.0


$node_(91) set X_ 256
$node_(91) set Y_ -803
$node_(91) set Z_ 0.0

$node_(92) set X_ 406
$node_(92) set Y_ -803
$node_(92) set Z_ 0.0


$node_(93) set X_ 556
$node_(93) set Y_ -803
$node_(93) set Z_ 0.0

$node_(94) set X_ 706
$node_(94) set Y_ -803
$node_(94) set Z_ 0.0


$node_(95) set X_ 856
$node_(95) set Y_ -803
$node_(95) set Z_ 0.0


$node_(96) set X_ 1006
$node_(96) set Y_ -803
$node_(96) set Z_ 0.0


$node_(97) set X_ 1156
$node_(97) set Y_ -803
$node_(97) set Z_ 0.0


$node_(98) set X_ 1306
$node_(98) set Y_ -803
$node_(98) set Z_ 0.0


$node_(99) set X_ 1456
$node_(99) set Y_ -803
$node_(99) set Z_ 0.0
##=======================================================

proc destination {} {
      global ns val node_
      set time 1.0
      set now [$ns now]
      for {set i 0} {$i< $val(nn) } {incr i} {
            set xx [expr $i+50]
            set yy [expr $i+20]
		

           $ns at $now "$node_($i) setdest $xx $yy 30.0"

		
      }

#      $ns at [expr $now+$time] "destination"
}





source cbr1
set startval 		1
cbrval $startval $val(stop)
#} 

proc destination1 {} {
      global ns val node_
      set time 1.0
      set now [$ns now]
      for {set i 0} {$i< $val(nn) } {incr i} {
if {$i == 2} {
} elseif {$i == 6} {
} else {
            set xx [expr rand()*1000 ]
           set yy [expr rand()*1000 ]
          $ns at $now "$node_($i) setdest $xx $yy 1.0"
}
		
      }

#      $ns at [expr $now+$time] "destination"
}

$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "stop"
$ns at [expr $val(stop) + 0.01] "puts \"end simulation\" ; $ns halt"
proc stop {} {
    global ns tracefd namtrace
    $ns flush-trace
    close $tracefd
    close $namtrace



exec nam Congestionmesh.nam &

exec awk -f delay.awk Congestionmesh.tr > delay.fg
exec awk -f plr.awk Congestionmesh.tr > plr.fg
exec awk -f throughput.awk Congestionmesh.tr > throughput.fg
}

$ns run

#$ns OUT.tcl
