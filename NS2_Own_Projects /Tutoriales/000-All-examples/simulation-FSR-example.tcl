# Exemplary NS-2 Simulation Script for FSR
#
#
set opt(chan)		Channel/WirelessChannel
set opt(prop)		Propagation/TwoRayGround
set opt(netif)		Phy/WirelessPhy
set opt(mac)		Mac/802_11
set opt(ifq)		Queue/DropTail/PriQueue
set opt(ll)		LL
set opt(ant)		Antenna/OmniAntenna
set opt(x)		500;		# X dimension of the topography
set opt(y)		500; 		# Y dimension of the topography
set opt(ifqlen)		50;		# max packet in ifq
set opt(seed)		0,0
set opt(adhocRouting)	FSR
set opt(nn)		50;		# number of nodes in the simulation
set opt(stop)		200;		# simulation time
set opt(cp)		"tcp-FSR-example"
set opt(sc)		"scen-FSR-example"
set opt(tr)		simulation-FSR-example.tr;# trace file
# Define Transmission range
set opt(rxthresh)	1.426613e-08
puts "txRange is 100m ( $opt(rxthresh) )"
puts "scenFile: $opt(sc)"
puts "trafFile: $opt(cp)"
puts "trceFile: $opt(tr)"
#
##########################################################################################
remove-all-packet-headers       ;# removes all except common
add-packet-header Flags IP TCP Message ARP Mac LL;# hdrs reqd for TCP
#
# Initialize the SharedMedia interface with parameters to make
# it work like the 914MHz Lucent WaveLAN DSSS radio interface
#
Phy/WirelessPhy set CPThresh_ 10.0 ;# Capture threshold (db)
Phy/WirelessPhy set CSThresh_ 1.559e-11 ;# Carrier sense threshold(W)
Phy/WirelessPhy set RXThresh_ $opt(rxthresh);# Receive power threshold(W)
Phy/WirelessPhy set Rb_ 2*1e6 ;# Bandwidth
Phy/WirelessPhy set Pt_ 0.2818 ;# Transmission power (W)
Phy/WirelessPhy set freq_ 914e6 ;# frequency
Phy/WirelessPhy set L_ 1.0 ;# system loss factor
#
# unity gain, omni-directional antennas
# set up the antennas to be centered in the node and 1.5 meters above it
#
Antenna/OmniAntenna set X_ 0
Antenna/OmniAntenna set Y_ 0
Antenna/OmniAntenna set Z_ 1.5
Antenna/OmniAntenna set Gt_ 1.0
Antenna/OmniAntenna set Gr_ 1.0
#
#
LL set mindelay_		50us
LL set delay_			25us
LL set bandwidth_		0	;# not used
#
#

#
# Main Program
#

#
# initialize global variables
#

# create simulator instance
set ns_ [new Simulator]

# set wireless channel, radio-model and topography objects
set wtopo [new Topography]

#create trace object for ns and nam
set tracefd [open $opt(tr) w]
$ns_ trace-all $tracefd
# use new trace file format
#$ns_ use-newtrace

#define topology
$wtopo load_flatgrid $opt(x) $opt(y)

#create god
set god_ [create-god $opt(nn)]

#define how node should be created
#global node setting


$ns_ node-config -adhocRouting $opt(adhocRouting)\
		 -llType $opt(ll) \
		 -macType $opt(mac) \
		 -ifqType $opt(ifq) \
		 -ifqLen $opt(ifqlen) \
		 -antType $opt(ant) \
		 -propType $opt(prop) \
		 -phyType $opt(netif) \
		 -channelType $opt(chan) \
		 -topoInstance $wtopo \
		 -agentTrace ON \
		 -routerTrace ON \
		 -macTrace OFF \
		 -movementTrace OFF

# create the specified number of node [$opt(nn)] and "attach" them
# to the channel

for {set i 0} {$i < $opt(nn)} {incr i} {
	set node_($i) [$ns_ node]
	$node_($i) random-motion 0		;#disable random motion
}

# Define node movement model
puts "Loading connection pattern ..."
source $opt(cp)

# Define traffic model
puts "Loading scenario file ..."
source $opt(sc)

#Define node initial position in nam

for {set i 0} {$i<$opt(nn)} {incr i} {
	$ns_ initial_node_pos $node_($i) 20
}

#Tell nodes when the simulaton ends
for {set i 0} {$i < $opt(nn)} {incr i} {
	$ns_ at $opt(stop).000000001 "$node_($i) reset";
}

$ns_ at $opt(stop).0002 "stop"

proc stop {} {
	global ns_ tracefd namtrace
	$ns_ flush-trace
	close $tracefd
}

#
#Tell nam the simulation stop time
#
$ns_ at $opt(stop).0003 "puts \"NS EXITING..\";$ns_ halt"

#
# START
#

puts $tracefd "M 0.0 file: $opt(tr)"
puts $tracefd "M 0.0 movement pattern: $opt(sc)"
puts $tracefd "M 0.0 communication pattern: $opt(cp)"
puts $tracefd "M 0.0 n $opt(nn) x $opt(x) y $opt(y) rp $opt(adhocRouting) time $opt(stop)"
puts $tracefd "M 0.0 chan $opt(chan) netif $opt(netif) prop $opt(prop) ant $opt(ant) rxThresh $opt(rxthresh)"
puts $tracefd "M 0.0 mac $opt(mac) ifq $opt(ifq) ll $opt(ll)"
puts $tracefd "seed $opt(seed)"


puts "Starting Simulation ..."
$ns_ run
