set val(chan)		Channel/WirelessChannel		;# channel type
set val(prop)		Propagation/TwoRayGround	;# radio-propagation model
set val(netif)		Phy/WirelessPhy			;# network interface type
set val(mac)		Mac/802_11			;# MAC type
set val(ifq)		Queue/DropTail/PriQueue		;# interface queue type
set val(ll)		LL				;# link layer type
set val(ant)		Antenna/OmniAntenna		;# antenna model
set val(ifqlen)		50				;# max package in ifq
set val(nn)		3				;# number of mobilenodes
set val(rp)		AODV				;# routing protocol
set val(x)		500				;# X dimention of topography
set val(y)		400				;# Y --		--	--
set val(stop)		10				;# time of simulation end




# Creating simulation
set ns  [new Simulator]

#Creating nam and trace file
set tracefd       [open Graph3.tr w]
set namtrace      [open Graph3.nam w]   

$ns trace-all $tracefd
$ns namtrace-all-wireless $namtrace $val(x) $val(y)

# set up topography object
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

set god_ [create-god $val(nn)]

 

# configure the nodes
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
                   -movementTrace ON
                   
# Creating node objects..          
for {set i 0} {$i < $val(nn) } { incr i } {
            set node_($i) [$ns node]     
      }
      for {set i 0} {$i < $val(nn)  } {incr i } {
            $node_($i) color black
            $ns at 0.0 "$node_($i) color black"
      }

# Provide initial location of mobilenodes
$node_(0) set X_ 50.0
$node_(0) set Y_ 50.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 200.0
$node_(1) set Y_ 250.0
$node_(1) set Z_ 0.0

$node_(2) set X_ 300.0
$node_(2) set Y_ 300.0
$node_(2) set Z_ 0.0

# Define node initial position in nam
for {set i 0} {$i < $val(nn)} { incr i } {
# 30 defines the node size for nam
$ns initial_node_pos $node_($i) 30
}

# Telling nodes when the simulation ends
for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "$node_($i) reset";
}

# ending nam and the simulation
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "stop"
$ns at 10.01 "puts \"end simulation\" ; $ns halt"

#Graph procedure..
$ns at 1.0 "Graph"
set g [open graph.tr w]
set g1 [open graph1.tr w]
set g2 [open graph2.tr w]
proc Graph {} {
global ns g g1 g2
set time 1.0
set now [$ns now]
puts $g "[expr rand()*8] [expr rand()*6]"
puts $g1 "[expr rand()*8] [expr rand()*6]"
puts $g2 "[expr rand()*8] [expr rand()*6]"
$ns at [expr $now+$time] "Graph"
}

#Stop proceture
proc stop {} {
    global ns tracefd namtrace
    $ns flush-trace
    close $tracefd
    close $namtrace
exec xgraph -M -bb -geometry 700X800 graph.tr graph1.tr graph2.tr
# exec nam Graph3.nam &
exit 0
}

$ns run
