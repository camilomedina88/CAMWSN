#set the required parameters for the VANET wireless 				#
#################################################################################
Antenna/OmniAntenna set X_ 0	;						#
Antenna/OmniAntenna set Y_ 0	;						#
Antenna/OmniAntenna set Z_ 1.51	;						#	
Antenna/OmniAntenna set Gt_ 1.0	;						#	
Antenna/OmniAntenna set Gr_ 1.0	;						#
Phy/WirelessPhy set CPThresh_ 10.0	;					#
Phy/WirelessPhy set CSThresh_ 1.559e-11	;					#
Phy/WirelessPhy set RXThresh_ 3.61705e-09	;				#
Phy/WirelessPhy set bandwidth_ 2e6		;				#	
Phy/WirelessPhy set Pt_ 0.2818			;				#
Phy/WirelessPhy set freq_ 5.90e+9		;				#
Phy/WirelessPhy set L_ 1.0			;				#
										#
										#
#################################################################################
#wireless system of two moving nodes
#using the VANET propagation model

#set array val() with wireless network parameters
set val(netif)		Phy/WirelessPhy		;
set val(mac)		Mac/802_11		;
set val(ifq)		Queue/DropTail/PriQueue	;
set val(ll)		LL			;
set val(ant)		Antenna/OmniAntenna	;
set val(ifqlen)		50			;
set val(chan)		Channel/WirelessChannel	;
set val(prop)		Propagation/VanetProp	;
set val(rp)		DSDV			;
set val(nn)		2			;
set val(max_x)		1100			;
set val(max_y)		1100			;
set val(MaxNodeID)  	[expr {$val(nn)-1}]  	;
##################################################################################

#initialize global variables
set ns_ [new Simulator]
#set the tracing object
set tracefd [open simple.tr w]
$ns_ trace-all $tracefd
#set the topology
set val(topo) [new Topography]
$val(topo) load_flatgrid $val(max_x) $val(max_y)
#create GOD
create-god	$val(nn)

#configure the wireless nodes
$ns_ node-config	-adhocRouting	$val(rp)	\
			-llType 	$val(ll)	\
			-macType	$val(mac)	\
			-ifqType	$val(ifq)	\
			-ifqLen		$val(ifqlen)	\
			-antType	$val(ant)	\
			-propType	$val(prop)	\
			-phyType	$val(netif)	\
			-channelType	$val(chan)	\
			-topoInstance	$val(topo)	\
			-agentTrace	ON		\
			-routerTrace	OFF		\
			-macTrace	OFF		\
			-movementTrace	oFF

#create the actual nodes
for {set i 0} {$i < $val(nn)} {incr i} {
	set node_($i) [$ns_ node]
	$node_($i) random-motion 0
}

#provide initial coordinates of the nodes
$node_(0) set X_ 5.0
$node_(0) set Y_ 2.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 6.0
$node_(1) set Y_ 2.0
$node_(1) set Z_ 0.0

#initialize the signal power tracing
set prop_inst [$ns_ set propInstance_]
set pwrfd [open vanetpwr.tr w]
set pwrTrace [new BaseTrace]
$pwrTrace attach $pwrfd
$pwrTrace set src_ 0
$prop_inst Tracer $pwrTrace

#configure the VANET channel propagation module
$prop_inst LoadPropFile  env.txt;
$prop_inst Environment Rural
$prop_inst MaxNodeID $val(MaxNodeID)

#produce simple node movement: node_(1) moves away from node_(0), with speed changing
$ns_ at 10.0 "$node_(1) setdest 1000.0 2.0 20"


##################################
#setup traffic flow between nodes# 
##################################

#TCP connection between node_(0) and node_(1)
set udp [new Agent/UDP]
$udp set class_ 2
set sink [new Agent/Null]
$ns_ attach-agent $node_(0) $udp
$ns_ attach-agent $node_(1) $sink
$ns_ connect $udp $sink
set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp


$ns_ at 10.0 "$cbr0 start"

#tell nodes when simulation ends
for {set i 0} {$i < $val(nn)} {incr i} {
	$ns_ at 150.0 "$node_($i) reset";
}

$ns_ at 150.0 "stop"
$ns_ at 150.01 "puts \"NS EXITING...\"; $ns_ halt"

proc stop {} {
	global ns_ tracefd pwrfd
	$ns_ flush-trace
	close $tracefd
	close $pwrfd
}


#start simulation
$ns_ run


