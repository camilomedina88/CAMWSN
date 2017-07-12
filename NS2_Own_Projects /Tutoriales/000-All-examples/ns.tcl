# TCL script takes three parameters: #senders, #receivers, #scenario

#
# Check for command-line parameters
#

if {$argc != 3} {
        error "Usages: ns ns.tcl <no_of_senders> <no_receivers> <scenario>"
}

set opt(stop) 910.0
set nodes 	50
set mobility	1
set scenario	[lindex $argv 2]
set pausetime	0
set traffic	cbr
set senders	[lindex $argv 0]
set receivers   [lindex $argv 1] 

set ns_ [new Simulator]
set topo [new Topography]
$topo load_flatgrid 1500 300

set tracefd [open ./trace-$pausetime-$mobility-$scenario-$senders-$receivers w]
$ns_ trace-all $tracefd

set god_ [create-god $nodes]
$ns_ node-config -adhocRouting AODV \
			-llType LL \
			-macType Mac/802_11 \
			-ifqLen 50 \
			-ifqType Queue/DropTail/PriQueue \
			-antType Antenna/OmniAntenna \
			-propType Propagation/TwoRayGround \
			-phyType Phy/WirelessPhy \
			-channel [new Channel/WirelessChannel] \
			-topoInstance $topo \
			-agentTrace ON \
			-routerTrace ON \
			-macTrace OFF \
			-movementTrace OFF

for {set i 0} {$i < $nodes} {incr i} {
	set node_($i) [$ns_ node]
	$node_($i) random-motion 0;
}

puts "Loading connection pattern ..."
source "traffic/$traffic-$senders-$receivers"

puts "Loading scenarios file..."
source "scenarios/scen-1500x300-$nodes-$pausetime-$mobility-$scenario"

for {set i 0} {$i < $nodes} {incr i} {
	$ns_ at $opt(stop) "$node_($i) reset";
}

$ns_ at $opt(stop) "$ns_ halt"

puts "Starting Simulation ..."
$ns_ run

