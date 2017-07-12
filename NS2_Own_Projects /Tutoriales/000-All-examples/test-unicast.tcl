#---------------------------------------------------------------------------
# Sample file for OLSR simulation
#---------------------------------------------------------------------------

#---------------------------------------------------------------------------
# Initialization
#---------------------------------------------------------------------------

# (possibly) Remove and create result directory
set dirName "test-unicast-result"
exec sh -c "rm -rf $dirName && mkdir $dirName"

# Default node configuration
set nodeConfig "no-log 0; log-none ; log-route 1"

# Load the OOLSR as plugin
load-plugin ./oolsr-plugin --output $dirName/ns2agent.log \
              multicast route packet-drop

#---------------------------------------------------------------------------
# Create a simulation, with wireless support. This is basic (see ns2 doc)
#---------------------------------------------------------------------------
set ns [new Simulator]

set val(chan) Channel/WirelessChannel
set val(prop) Propagation/TwoRayGround
set val(netif) Phy/WirelessPhy
set val(mac) Mac/802_11
set val(ifq) Queue/DropTail/PriQueue
set val(ll) LL
set val(ant) Antenna/OmniAntenna
set val(ifqlen) 50 ;#
set val(nn)     50  ;# nb mobiles
set val(rp) PLUGINPROTOCOL
set val(x) [expr $val(nn) *100.0 + 100.0]
set val(y) 1000

set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)
set god [create-god $val(nn)]

$ns use-newtrace
set tracefd [open $dirName/unicast.tr w]
$ns trace-all $tracefd

set namtrace [open $dirName/unicast.nam w]
$ns namtrace-all-wireless $namtrace $val(x) $val(y)

$ns node-config -adhocRouting $val(rp) \
    -llType $val(ll) \
    -macType $val(mac) \
    -ifqType $val(ifq) \
    -ifqLen $val(ifqlen) \
    -antType $val(ant) \
    -propType $val(prop) \
    -phyType $val(netif) \
    -channel [new $val(chan)] \
    -topoInstance $topo \
    -agentTrace ON \
    -routerTrace ON \
    -macTrace OFF \
    -movementTrace OFF

#---------------------------------------------------------------------------
# Create nodes with OOLSR agent
#---------------------------------------------------------------------------
  
for {set i 0} {$i < $val(nn)} {incr i} {
    set node($i) [$ns node]

    $node($i) random-motion 1
    $node($i) set X_ [expr $i * 100.0]
    $node($i) set Y_ [expr 500.0 + ((($i * 93) % 21) - 10 ) * 10.0]
    $node($i) set Z_ 0.0
    $ns initial_node_pos $node($i) 20

     [$node($i) set ragent_] set-config \
       "$nodeConfig ; log-file-name $dirName/oolsr-node-$i.log"


#    [$node($i) set ragent_] start
#    [$node($i) set ragent_] config
}

#---------------------------------------------------------------------------
# Sending traffic
#---------------------------------------------------------------------------

set sender [new Agent/UDP]
$ns attach-agent $node(0) $sender
set cbr [new Application/Traffic/CBR]
$cbr set packetSize_ 128
$cbr set interval_ 0.1
$cbr attach-agent $sender 

set receiver [new Agent/Null]
$ns attach-agent $node([expr $val(nn)-1]) $receiver

$ns connect $sender $receiver
$ns at 0.0 "$cbr start"

#---------------------------------------------------------------------------
# Finishing procedure
#---------------------------------------------------------------------------

proc finishSimulation { } {
    global ns node val dirName

    # Log the final state of all the nodes
    for {set i 0} {$i < $val(nn)} {incr i} {
	[$node($i) set ragent_] state "$dirName/oolsr-node-$i.final-state"
    }

    # Exit
    puts "Finished simulation."
    $ns halt
}

#---------------------------------------------------------------------------
# Run the simulation
#---------------------------------------------------------------------------

proc runSimulation {duration} {
    global ns finishSimulation
    for {set j 1.0} {$j < $duration} {set j [expr $j * 1.3 ]} {
	$ns at $j "puts t=$j"
    }
    $ns at $duration "finishSimulation"
    $ns run
}

runSimulation 305.0

#---------------------------------------------------------------------------
