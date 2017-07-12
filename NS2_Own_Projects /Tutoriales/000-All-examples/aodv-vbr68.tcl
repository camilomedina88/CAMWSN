# http://www.scribd.com/doc/98292357/aodv-vbr


set opt(chan)		Channel/WirelessChannel
set opt(prop)		Propagation/TwoRayGround
set opt(netif)		Phy/WirelessPhy
set opt(mac) 		Mac/802_11 ;# MAC type
set opt(ifq)		Queue/DropTail/PriQueue
set opt(ll)	LL
set opt(ant) 		Antenna/OmniAntenna

set opt(x)	1500	;# X dimension of the topography
set opt(y)	300	;# Y dimension of the topography
set opt(cp)	"cbr/cbr_rate21"
set opt(sc)	"scen/scen-1500x300-50-0-20-1"

set opt(ifqlen)	50		;# max packet in ifq
set opt(nn)	100		;# number of nodes
set opt(seed)	0.0
set opt(stop)	300.0		;# simulation time
set opt(tr)	out.tr		;# trace file
set opt(nam)	out.nam		;# animation file
set opt(rp)	AODV 		;# routing protocol script
#set opt(lm)	"off" 		;# log movement
set opt(agent)	AODV
set opt(energymodel)	EnergyModel ;
#set opt(energymodel)	RadioModel ;
set opt(radiomodel) 	RadioModel ;
set opt(initialenergy) 100 ;# Initial energy in Joules
#set opt(logenergy) "on"	;# log energy every 150 seconds

#set opt(lm) 	"off"		;# log movement
#set opt(imep) 	"OFF"

#set opt(debug) "OFF"
#set opt(errmodel)	""	;# for errmodel
#set opt(em)		""	;# set to name of errmodel file

#set opt(ps)		128	;# cbr data pkt size
#set opt(pi)		0.33	;# cbr data interval
set opt(usepsm)		1	;# use power saving mode
 
set opt(usespan)	1	;# use span election
set opt(spanopt)	1	;# use psm optimization
#set opt(slaver)	""	;# remote drive an ad-hockey at this ip addr


# ======================================================================
set AgentTraceON
set RouterTraceON
set MacTrace ON
LL set delay_0LL 
set mindelay_25us
LL set maxdelay_50us
#LL set bandwidth_0	;# not used
#LL set off_prune_0	;# not used
#LL set off_CtrMcast_0	;# not used

#source rp
Agent/CBR set sport_0
Agent/CBR set dport_0
#Agent/TCPSink set sport_0
#Agent/TCPSink set dport_0#Agent/TCP set sport_0
#Agent/TCP set dport_0
#Agent/TCP set packetSize_1460


#if [TclObject is-class Scheduler/RealTime] {
# Scheduler/RealTime set maxslop_ 10
#}


# unity gain, omni-directional antennas
# set up the antennas to be centered in the node and 1.5 meters above it
Antenna/OmniAntenna set X_ 0
Antenna/OmniAntenna set Y_ 0
Antenna/OmniAntenna set Z_ 1.5
Antenna/OmniAntenna set Gt_ 1.0
Antenna/OmniAntenna set Gr_ 1.0

# Initialize the SharedMedia interface with parameters to make
# it work like the 914MHz Lucent WaveLAN DSSS radio interface
Phy/WirelessPhy set CPThresh_ 10.0
Phy/WirelessPhy set CSThresh_ 1.559e-11
Phy/WirelessPhy set RXThresh_ 3.652e-10
Phy/WirelessPhy set Rb_ 2.0e6
Phy/WirelessPhy set Pt_ 0.2818
Phy/WirelessPhy set freq_ 914e+6
Phy/WirelessPhy set L_ 1.0
#source mac
# the above parameters result in a nominal range of 250m
set nominal_range 250.0
set configured_range -1.0
 set configured_raw_bitrate -1.0


# ======================================================================
set ns_	[new Simulator]
set topo	[new Topography]
set tracefd	[open $opt(tr) w]
set namtrace	[open $opt(nam) w]
set prop	[new $opt(prop)]
#$ns_ use-newtrace
$topo load_flatgrid $opt(x) $opt(y)
#ns-random 1.0
$ns_ trace-all $tracefd
$ns_ namtrace-all-wireless $namtrace 1500 300

#
# Create god
#
set god_ [create-god $opt(nn)]


# global node setting
	$ns_ node-config -adhocRouting $opt(agent) \
		-llType $opt(ll) \
		-macType $opt(mac) \
		-ifqType $opt(ifq) \
		-ifqLen $opt(ifqlen) \
		-antType $opt(ant) \
		-propType $opt(prop) \
		-phyType $opt(netif) \
		-channelType $opt(chan) \
		-topoInstance $topo \
		-agentTrace ON \
		-routerTrace ON \
		-macTrace ON \
		-energyModel $opt(energymodel) \
		-idlePower 1.0 \
		-rxPower 1.0 \
		-txPower 1.0 \
		-sleepPower 0.001 \
		-transitionPower 0.2 \
		-transitionTime 0.005 \
		-initialEnergy $opt(initialenergy)


$ns_ set WirelessNewTrace_ ON
		set AgentTrace	ON
		set RouterTrace	ON
		set MacTrace	ON

	for {set i 0} {$i < $opt(nn) } {incr i} {
		set node_($i) [$ns_ node]
$ns_ initial_node_pos $node_($i) 30;
 	$node_($i) random-motion 0	;# disable random motion

	}


source $opt(sc)

#	$node_(1) set agentTrace ON
#	$node_(1) set macTrace ON
#	$node_(1) set routerTrace ON
#	$node_(0) set macTrace ON
#	$node_(0) set agentTrace ON
#	$node_(0) set routerTrace ON

$ns_ at 0.0000 "$node_(1) add-mark m2 red circle"
$ns_ at 0.0000 "$node_(2) add-mark m2 red circle"
$ns_ at 0.0000 "$node_(1) label \"Sender\""
$ns_ at 0.0000 "$node_(2) label \"Receiver\""

set udp_(0) [new Agent/TCP]
$ns_ attach-agent $node_(1) $udp_(0)
set null_(0) [new Agent/TCPSink]$ns_ attach-agent $node_(2) $null_(0)
set cbr_(0) [new Application/FTP]
$cbr_(0) set packetSize_ 512
$cbr_(0) set interval_ 5.0
$cbr_(0) set random_ 1
$cbr_(0) set maxpkts_ 10000
$cbr_(0) attach-agent $udp_(0)
$ns_ connect $udp_(0) $null_(0)
$ns_ at 2.5568388786897245 "$cbr_(0) start"
#$ns_ at 177.000	"$node_(0) set ifqLen"

#
# Tell all the nodes when the simulation ends
#
for {set i 0} {$i < $opt(nn) } {incr i} {
	$ns_ at $opt(stop) "$node_($i) reset";
}
$ns_ at $opt(stop) "puts \"NS EXITING...\" ; $ns_ halt"
puts "Starting Simulation..."
$ns_ run
