# ===================================================================
# RPGM, connection rate using AODV as Routing Protocol,no of node 20,blachole
#====================================================================
#====================================================================
# Define options
#====================================================================
set opt(chan) 	Channel/WirelessChannel
set opt(prop)	Propagation/TwoRayGround
set opt(netif)	Phy/WirelessPhy
set opt(mac)	Mac/802_11
set opt(ifq)	Queue/DropTail/PriQueue
set opt(ll)	LL
set opt(ant)	Antenna/OmniAntenna
set opt(x)	750			;# X dimension of the topography
set opt(y)	750			;# Y dimension of the topography
set opt(ifqlen)	150			;#packet in ifq
set opt(seed)	1.0
set opt(tr)	bhaodv.tr		;# trace file
set opt(nam)	bhaodv.nam 	;# nam trace file
set opt(rp)	AODV 		;#routing protocol
set opt(nn)	20			;# how many nodes are simulated
set opt(nnaodv)	19
set opt(cp)	"bh/SC1FORaodv-N20-t500-x750-y750"  ;# Connection Pattern
set opt(sc)	"bh/cbr"    ;# CBR Connections
set opt(stop)	500.0			;# simulation time
#set opt(energyModel)	EnergyModel	;# To be activated when	evalutating energy
# ===================================================================
# Other default settings
# ===================================================================
LL set mindelay_	50us
LL set delay_		25us	
LL set bandwidth_	0		;# not used
Agent/Null set sport_	0	
Agent/Null set dport_	0
Agent/CBR set sport_	0
Agent/CBR set dport_	0
Agent/TCPSink set sport_	0
Agent/TCPSink set dport_	0
Agent/TCP set sport_		0
Agent/TCP set dport_		0
Agent/TCP set packetSize_	512
Queue/DropTail/PriQueue 	set Prefer_Routing_Protocols


# ====================================================================
# Main Program

set ns_ [new Simulator]
#=====================================================================
# set wireless channel, radio-model and topography objects
#=====================================================================

set wtopo [new Topography]
#=====================================================================
# create trace object for ns and nam
#=====================================================================
set tracefd [open $opt(tr) w]

set namtrace [open $opt(nam) w]
$ns_ trace-all $tracefd
$ns_ namtrace-all-wireless $namtrace $opt(x) $opt(y)
#=====================================================================
# use new trace file format
#=====================================================================
#$ns_ use-newtrace
#=====================================================================
# define topology
#=====================================================================
$wtopo load_flatgrid $opt(x) $opt(y)
#$wprop topography $wtopo
#=====================================================================
# Create God
#=====================================================================
set god_ [create-god $opt(nn)]
#=====================================================================
#Create channel #1 and #2
#=====================================================================
set chan_1_ [new $opt(chan)]
set chan_2_ [new $opt(chan)]
#=====================================================================
#global node setting -define how wireless/mobile node should be created
#=====================================================================
$ns_ node-config 	-adhocRouting $opt(rp) \
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
-macTrace ON \
-MovementTrace ON

#=====================================================================
# Create the specified number of nodes [$opt(nnaodv)] 
# to the channel.
#=====================================================================
for {set i 0} {$i < $opt(nnaodv) } {incr i} {
set node_($i) [$ns_ node]
$node_($i) random-motion 0 ;# disable random motion
#$node_($i) topography $wtopo
}
#=====================================================================
# Create the specified number of nodes [$opt(nn)] 
# to the channel.
#=====================================================================
$ns_ node-config	-adhocRouting blackholeaodv
for {set i 0} {$i < $opt(nn) } {incr i} {
set node_($i) [$ns_ node]
$node_($i) random-motion 0 ;# disable random motion
$ns_ at 0.01 "$node_($i)lable \"blackhole node\""
#$node_($i) topography $wtopo
}
#=====================================================================
# Define node movement model
#=====================================================================
puts "Loading connection pattern..."
set god_ [God instance]
source $opt(cp)
#=====================================================================
# Define traffic model CBR Connection generated by cbrgen
#=====================================================================
#source $opt(cp)
# ################### CBRGEN GENERATE SAME CODE #############################
#set j 0

#for {set i 0} {$i < 18} {incr i} {

#Create a UDP and NULL agents, then attach them to the appropriate nodes
#???? set udp_($j) [new Agent/UDP]
#???? $ns_ attach-agent $node_($i) $udp_($j)
#???? set null_($j) [new Agent/Null]
#???? $ns_ attach-agent $node_([expr $i + 1]) $null_($j)

#Attach CBR application;
#???? set cbr_($j) [new Application/Traffic/CBR]
#???? puts "cbr_($j) has been created over udp_($j)"
#???? $cbr_($j) set packet_size_ 512
#???? $cbr_($j) set interval_ 1
#???? $cbr_($j) set rate_ 10kb
#???? $cbr_($j) set random_ false
#???? $cbr_($j) attach-agent $udp_($j)
#???? $ns_ connect $udp_($j) $null_($j)
#???? puts "udp_($j) and null_($j) agents has been connected each other"
#???? $ns_ at 1.0 "$cbr_($j) start"

#???? set j [expr $j + 1]
#???? set i [expr $i + 1]
#?}
#############################################################################
puts "Loading scenario file..."
source $opt(sc)
# Define node initial position in nam
for {set i 0} {$i < $opt(nn)} {incr i} {
# 20 defines the node size in nam, must adjust it according to your scenario
# The function must be called after mobility model is defined
$ns_ initial_node_pos $node_($i) 30
}
#=====================================================================
# CBR connection stops
#for {set i 0} {incr i} {
#$ns_ at opt(stop) "$cbr_($i)stop"
#}
#=====================================================================
# Tell nodes when the simulation ends
#=====================================================================
for {set i 0} {$i < $opt(nn) } {incr i} {
$ns_ at $opt(stop).000000001 "$node_($i) reset";
}
#=====================================================================
# tell nam the simulation stop time
#=====================================================================
$ns_ at $opt(stop) "$ns_ nam-end-wireless $opt(stop)"
exec nam $opt(nam) & 
$ns_ flush-trace   
$ns_ at $opt(stop).000000001 "puts \"NS EXITING...\" ; $ns_ halt"
puts "Starting Simulation.."
$ns_ run
#=====================================================================
# END OF SIMULATION SCRIPT
#=====================================================================


