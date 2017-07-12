set val(modIndex)  [lindex $argv 0]
set val(ncars) [lindex $argv 1]
set val(payload) [lindex $argv 2]
set val(comRange) [lindex $argv 3] ;#"intended" Communication Range
set val(vseed)     [lindex $argv 4]

set payload [expr - $val(payload)]
set modulationIndex [expr $val(modIndex)]
# In 802.11p
#modIndex = 0 (BPSK and 1/2 coding rate): 3Mbps
#modIndex = 1 (QPSK and 1/2 coding rate): 6Mbps
#modIndex = 2 (QAM16 and 1/2 coding rate): 12Mbps
#modIndex = 3 (QAM 64 and 2/3 coding rate): 24Mbps
#=====================================================================
#Calculate the needed Transmission power corresponding to the intended Communication Range
set lambda	    [expr 3e+8/5.9e+9]	;# lambda = c / f
set PI 		    3.1415926535897931
set M   	    [expr $lambda / [expr 4 * $PI * $val(comRange)]];
set Pr2Pt	    [expr [expr 5.118 * 5.118 * $M * $M ] / 1];
set Pt		    [expr 3.162e-12 / $Pr2Pt]
set PtmW	    [expr $Pt * 1000]
puts "mod Index is $val(modIndex)"
puts "# of cars is $val(ncars)"
puts "TCL Payload Size is: $val(payload) bytes"
puts "comRange is: $val(comRange) meters"
puts "Used Transmission Power is: $PtmW mW"
# =====================================================================

set val(chan)       Channel/WirelessChannel
set val(prop)       Propagation/Nakagami

set val(netif)      Phy/WirelessPhyExt
set val(mac)        Mac/802_11Ext
set val(ifq)        Queue/DSRC ;#DropTail/PriQueue
set val(ll)         LL
set val(ant)        Antenna/OmniAntenna
set val(x)          1100   	;# X dimension of the topography
set val(y)          20   	;# Y dimension of the topography
set val(ifqlen)     20          ;# max packet in ifq
set val(nn)         $val(ncars) ;# how many nodes are simulated
set val(rtg)        DumbAgent
set val(stop)       5        ;# simulation time in seconds


# 802.11p Paramters
#**************************************************
set val(sc)		802.11p.tcl
source 			$val(sc)        ;# load 802.11p configuration file

# =====================================================================
# Main Program
# ======================================================================

#
# Initialize Global Variables
#

global defaultRNG
$defaultRNG seed $val(vseed)

set ns_		[new Simulator]
set topo	[new Topography]
set tracefd	[open tracefile.txt w]
$ns_ trace-all $tracefd
#$ns_ use-newtrace

$topo load_flatgrid $val(x) $val(y)
set god_ [create-god $val(nn)]
$god_ off

set chan [new $val(chan)]
$ns_ node-config -adhocRouting $val(rtg) \
                 -llType $val(ll) \
                 -macType $val(mac) \
                 -ifqType $val(ifq) \
                 -ifqLen $val(ifqlen) \
                 -antType $val(ant) \
                 -propType $val(prop) \
                 -phyType $val(netif) \
                 -channel $chan \
		 -topoInstance $topo \
		 -agentTrace ON \
                 -routerTrace OFF \
                 -macTrace ON \
                 -phyTrace ON

set lane	4	;#number of lanes in the scenario

#set channel_ [new RandomVariable/Normal]
#$channel_ set max_ 6
#$channel_ set min_ 0

for {set counter 0} {$counter < $lane} {incr counter} {
	for {set i 0} {$i < [expr $val(ncars) / $lane] } {incr i} {
	    set index [expr $i + [expr $counter * [expr $val(ncars) / $lane]]]
	    set ID_($index) $index
	    set vehicle_($index) [$ns_ node]
	    $vehicle_($index) set id_  $ID_($index)
	    $vehicle_($index) set address_ $ID_($index)
	    $vehicle_($index) set X_ [expr $i * 10]
	    $vehicle_($index) set Y_ [expr $counter * 5 ]
	    $vehicle_($index) set Z_ 0
	    $vehicle_($index) nodeid $ID_($index)

	    set agent_($index) [new Agent/DSRCApp]
	    $ns_ attach-agent $vehicle_($index)  $agent_($index)
	    $agent_($index) set modulationScheme_ $val(modIndex)
	    $agent_($index) set interval_ 0.1
	    $agent_($index) set packetSize_ $val(payload)

	    $ns_ at $val(stop).0 "$vehicle_($index) reset";
	    #puts "$index [expr $i * 5] [expr $counter * 5 ]";
	}
}

#set repetition	1; #How many time each packet is repeated

#for {set i 0} {$i < $repetition} {incr i} {
#	for {set j 0} {$j < [expr $val(ncars)] } {incr j} {
#		set rand [expr rand() * 0.05]
		#$ns_ at $rand "$agent_($j) send"
		#$ns_ at 0.02 "$agent_($j) send"
#	}
#}

# When sending a packet, you need to specify the packetType (0 = safety, 1 = service)
# If it is a Service Type packet, you need to specify the channel number (0 to 5)
# If it is a Safety Type packet, you have to set the channel number to -99.

	    
for {set i 0} {$i < $val(ncars)} {incr i} {
	set txtime_ [new RandomVariable/Uniform]
	$txtime_ set max_ 0.1
	$txtime_ set min_ 0
	
	$agent_($i) set channel_ -99
	$agent_($i) set type_dsrc_ 0
	$ns_ at [$txtime_ value] "$agent_($i) send"
}

$ns_ at $val(stop).0002 "puts \"NS EXITING...\" ; $ns_ halt"
$ns_ at $val(stop).0003 "$ns_ flush-trace"
puts "Starting Simulation..."
$ns_ run
