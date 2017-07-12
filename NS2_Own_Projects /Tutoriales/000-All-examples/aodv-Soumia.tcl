#    https://groups.google.com/forum/?fromgroups=#!topic/ns-users/UpoupWOpQ-I

# Define options
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             10                         ;# number of mobilenodes
set val(rp)             AODV                       ;# routing protocol
set val(X)              500  			   ;# X dimension of topography
set val(Y)              500  			   ;# Y dimension of topography  
set val(stop)		100			   ;# time of simulation end
set val(energymodel)    EnergyModel		   ;#Energy set up

# Simulator Instance Creation
set ns	[new Simulator]

set tracefd     [open simple.tr w]
$ns trace-all $tracefd

set namtrace [open wireless1-out.nam w]        
$ns namtrace-all-wireless $namtrace $val(X) $val(Y)

#Fixing the co-ordinate of simulation area


# set up topography object
set topo       [new Topography]
$topo load_flatgrid $val(X) $val(Y)

# general operational descriptor- storing the hop details in the network
create-god $val(nn)



# configure the first 5 nodes with transmission range of 500m 

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
                   -energyModel $val(energymodel) \
			 -initialEnergy 10 \
                   -rxPower 0.5 \
			 -txPower 1.0 \
                   -idlePower 0.0 \
			 -sensePower 0.3 \
			 -agentTrace ON \
			 -routerTrace ON \
			 -macTrace OFF \
			 -movementTrace ON


# Node Creation Sink



set energy(0) 1000

$ns node-config -initialEnergy 1000 \
                -rxPower 0.5 \
		-txPower 1.0 \
                -idlePower 0.0 \
		-sensePower 0.3 

	set node_(0) [$ns node]
		$node_(0) set X_ [expr 10 + round (rand() *480)]
   		$node_(0) set Y_ [expr 10 + round (rand() *480)]
		$node_(0) set Z_ 0.0
	#$node_(0) color black
	



for {set i 1} {$i <$val(nn)} {incr i} {

set energy($i) 400

$ns node-config -initialEnergy $energy($i) \
                -rxPower 0.5 \
		-txPower 1.0 \
                -idlePower 0.0 \
		-sensePower 0.3 

	set node_($i) [$ns node]
	

		$node_($i) set X_ [expr 10 + round (rand() *480)]
   		$node_($i) set Y_ [expr 10 + round (rand() *480)]
		$node_($i) set Z_ 0.0
	#$node_($i) color black

}
 set t 1.0
 set f 15.0	
for {set i 1} {$i < $val(nn)} {incr i} {

# Defining a transport agent for sending
set udp [new Agent/UDP]

# Attaching transport agent to sender node
$ns attach-agent $node_($i) $udp

# Defining a transport agent for receiving
set null [new Agent/Null]

# Attaching transport agent to receiver node
$ns attach-agent $node_(0) $null

#Connecting sending and receiving transport agents
$ns connect $udp $null

#Defining Application instance
set cbr [new Application/Traffic/CBR]

# Attaching transport agent to application agent
$cbr attach-agent $udp
#Packet size in bytes 
$cbr set packetSize_ 512   
# data packet generation starting time
$ns at $t "$cbr start"
$ns at $f "$cbr stop"

set t [expr 10 * $i]
set f [expr 15+ $t]
}





# Define node initial position in nam
for {set i 0} {$i < $val(nn)} {incr i} {

        # 20 defines the node size in nam, must adjust it according to your
        # scenario size.
        # The function must be called after mobility model is defined
        $ns initial_node_pos $node_($i) 50
}
# Tell nodes when the simulation ends
#



for {set i 0} {$i < $val(nn) } {incr i} {
    $ns at 100.0 "$node_($i) reset";
}
$ns at 100.0 "stop"
$ns at 100.01 "puts \"NS EXITING...\" ; $ns halt"
 proc stop {} {
    global ns tracefd namtrace
    $ns flush-trace
    close $tracefd
    close $namtrace
    exec nam wireless1-out.nam &
    exit 0
}

puts "Starting Simulation..."
$ns run
 
