#   #46  http://www.linuxquestions.org/questions/ubuntu-63/configure-error-installation-of-tclcl-seems-incomplete-or-can%27t-be-found-automatica-4175522820/page4.html


# ======================================================================

# Define options

# ======================================================================

set val(chan)           Channel/WirelessChannel    ;# channel type

set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model

set val(netif)          Phy/WirelessPhy            ;# network interface type

set val(mac)            Mac/MacI               ;# MAC type

set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type

set val(ll)             LL                         ;# link layer type

set val(ant)            Antenna/OmniAntenna        ;# antenna model

set val(ifqlen)         50                         ;# max packet in ifq

set val(rp)             NCR                        ;# routing protocol

set val(nn)             20                        ;# number of mobilenodes

set val(x)		1250

set val(y)		1250

set val(stop_sim)	50

set val(print)		80

set val(flooding)	1

set val(probabilistic_nc) 1

set val(force_first)	1

set val(send_count)	1

set val(statistics)	1

set val(gen_mngt)	5

set val(pseudo)         0

set val(sc)		1

set val(dist)		250

set data_size 		8

set data_rate		12Kb

set step		0.004

set BROADCAST		-1





# Setting input arguments

if {[llength $argv]>0} {

	set val(send_count) [lindex $argv 0]; # it si an integer

}

if {[llength $argv]>1} {

	set val(sc) [lindex $argv 1]; # it si an integer

}

if {[llength $argv]>2} {

	set val(nn) [lindex $argv 2];  # Number of nodes

}

if {[llength $argv]>3} {

	set val(dist) [lindex $argv 3];  # Number of nodes

}

#if {[llength $argv]>3} {

#	set val(x) [lindex $argv 3]; # x size

#}

#if {[llength $argv]>4} {

#	set val(y) [lindex $argv 4]; # y size

#}

#if {[llength $argv]>5} {

#	set val(probabilistic_routing) [lindex $argv 5];  # Probabilistic routing 0-no, 1-yes

#}

#if {[llength $argv]>6} {

#	set val(force_first) [lindex $argv 6]; # Force first: 0-no, 1-yes

#}

#if {[llength $argv]>7} {

#	set val(statistics) [lindex $argv 7]; # set to 1 to collect statistic

#}

#if {[llength $argv]>8} {

#	set val(gen_mngt) [lindex $argv 8]; # an integer

#}





# NCR parameters

Agent/NCR set probabilistic_nc $val(probabilistic_nc)

Agent/NCR set force_first $val(force_first)

Agent/NCR set send_count $val(send_count)

Agent/NCR set statistics $val(statistics)

Agent/NCR set generation_management $val(gen_mngt)

Agent/NCR set flooding $val(flooding)

Agent/NCR set pseudo $val(pseudo)

Agent/NCR set scenario $val(sc)

Mac/802_11 set send_count $val(send_count)

Mac/802_11 set flooding $val(flooding)

Mac/802_11 set RTSThreshold_ 2000



Mac/MacI set send_count $val(send_count)

Mac/MacI set flooding $val(flooding)

Mac/MacI set range_ 250



# ======================================================================

# Main Program

# ======================================================================



#

# Initialize Global Variables

#

set ns_		[new Simulator]

#set tracefd     [open ./Traces/SquareNet_$val(nn)_$val(dist)_$val(send_count)_$val(sc).tr w]

set tracefd     [open out.tr w]

$ns_ trace-all $tracefd



# set up topography object

set topo       [new Topography]



#$topo load_flatgrid $val(x) $val(y)



# ------------

# Create God

# -----------

create-god $val(nn)





# ------------

# Configure the nodes

# -----------



set chan_1_ [new $val(chan)]



        $ns_ node-config -adhocRouting $val(rp) \

			 -llType $val(ll) \

			 -macType $val(mac) \

			 -ifqType $val(ifq) \

			 -ifqLen $val(ifqlen) \

			 -antType $val(ant) \

			 -propType $val(prop) \

			 -phyType $val(netif) \

			 -channel $chan_1_ \

			 -topoInstance $topo \

			 -agentTrace OFF \

			 -routerTrace OFF \

			 -macTrace OFF \

			 -movementTrace OFF			



puts "...Create nodes..."

			 

	for {set i 0} {$i < $val(nn) } {incr i} {

		set node_($i) [$ns_ node]

		set mac [$node_($i) getMac 0]

		$mac node $node_($i)

		$node_($i) random-motion 0		;# disable random motion

	}



puts "..OK!"



# -----------------

# TOPOLOGY

# -----------------



puts "... Create topology..."



#ource "/home/partha/nsnetcode/ns-allinone-2.27/ns-2.27/network-coding/topology_examples/GridNetwork/gridNet_16_150.tcl"



$topo load_flatgrid 500.000000 500.000000 

$node_(0) set X_ 0.000000

$node_(0) set Y_ 0.000000

$node_(0) set Z_ 0.000000

$node_(1) set X_ 150.000000

$node_(1) set Y_ 0.000000

$node_(1) set Z_ 0.000000

$node_(2) set X_ 300.000000

$node_(2) set Y_ 0.000000

$node_(2) set Z_ 0.000000

$node_(3) set X_ 450.000000

$node_(3) set Y_ 0.000000

$node_(3) set Z_ 0.000000

$node_(4) set X_ 0.000000

$node_(4) set Y_ 150.000000

$node_(4) set Z_ 0.000000

$node_(5) set X_ 150.000000

$node_(5) set Y_ 150.000000

$node_(5) set Z_ 0.000000

$node_(6) set X_ 300.000000

$node_(6) set Y_ 150.000000

$node_(6) set Z_ 0.000000

$node_(7) set X_ 450.000000

$node_(7) set Y_ 150.000000

$node_(7) set Z_ 0.000000

$node_(8) set X_ 0.000000

$node_(8) set Y_ 300.000000

$node_(8) set Z_ 0.000000

$node_(9) set X_ 150.000000

$node_(9) set Y_ 300.000000

$node_(9) set Z_ 0.000000

$node_(10) set X_ 300.000000

$node_(10) set Y_ 300.000000

$node_(10) set Z_ 0.000000

$node_(11) set X_ 450.000000

$node_(11) set Y_ 300.000000

$node_(11) set Z_ 0.000000

$node_(12) set X_ 0.000000

$node_(12) set Y_ 450.000000

$node_(12) set Z_ 0.000000

$node_(13) set X_ 150.000000

$node_(13) set Y_ 450.000000

$node_(13) set Z_ 0.000000

$node_(14) set X_ 300.000000

$node_(14) set Y_ 450.000000

$node_(14) set Z_ 0.000000

$node_(15) set X_ 450.000000

$node_(15) set Y_ 450.000000

$node_(15) set Z_ 0.000000





puts "...OK!"



# -------------------

# TRAFFIC

# -------------------



puts "...Create traffic..."



# All sources



   for {set i 0} {$i < $val(nn)} {incr i} {   



	set udp_($i) [new Agent/UDP]

	$ns_ attach-agent $node_($i) $udp_($i)



	set cbr_($i) [new Application/Traffic/CBR]

   	$cbr_($i) set rate_ $data_rate

   	$cbr_($i) set packetSize_ $data_size

   	$cbr_($i) attach-agent $udp_($i)

	

	set null_($i) [new Agent/Null]

   	$ns_ attach-agent $node_($i) $null_($i)	

   }



   #for {set i 0} {$i < $val(nn)} {incr i} {   

	#for {set k 0} {$k < $val(nn)} {incr k} {

		$ns_ connect $udp_(0) $null_([expr $val(nn) -1])

	#}

   #}



set rng1 [new RNG]

$rng1 seed 13113



set e [new RandomVariable/Uniform]

$e use-rng $rng1

#$e set avg_ 1; #sec 

set start 2





for {set i 0} {$i < [expr $val(sc)*10 - $val(sc)]} {incr i} {

	set tmp [$e value]

}

    

   for {set i 0} {$i < $val(nn)} {incr i} {

	#set start_my [expr $start + [$e value]]

	set start_my [expr $start + [$e value]*0.1]

	set stop_my [expr $start_my + $step]

    	$ns_ at $start_my "$cbr_($i) start"

    	$ns_ at $stop_my "$cbr_($i) stop"

   }	



puts "...OK!"	



#-----------



# Print statistics



# ---------





for {set i 0} {$i < $val(nn) } {incr i} {

    $ns_ at $val(print) "$node_($i) print_stat";

}





#

# Tell nodes when the simulation ends

#

for {set i 0} {$i < $val(nn) } {incr i} {

    $ns_ at $val(stop_sim) "$node_($i) reset";

}

$ns_ at $val(stop_sim) "stop"

$ns_ at [expr $val(stop_sim) + 1] "puts \"NS EXITING...\" ; $ns_ halt"

proc stop {} {

    global ns_ tracefd

    $ns_ flush-trace

    close $tracefd

}



puts "Starting Simulation..."

$ns_ run 
