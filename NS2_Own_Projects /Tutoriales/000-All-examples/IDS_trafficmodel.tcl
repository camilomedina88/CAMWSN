global XX_ YY_
proc topology-grid_ {min_X max_X min_Y max_Y num} {
	global XX_ YY_
#only appropiate for square area currently
	set node_edge [expr sqrt(($max_X-$min_X)*($max_Y-$min_Y)/$num)]
	set area_edge [expr sqrt(($max_X-$min_X)*($max_Y-$min_Y))]
	set row [expr $area_edge/$node_edge]
	set column [expr $num/$row]
	for {set i 0} {$i < $row} {incr i} {
		for {set j 0} {$j < $column} {incr j} {
			set XX_([expr int($i*$row+$j)]) [expr $j*$node_edge+$node_edge/2]
			set YY_([expr int($i*$row+$j)]) [expr $i*$node_edge+$node_edge/2]
		}
	}
}
#
# ======================================================================
# Define options
# ======================================================================
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(PHENOMmac)		Mac
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             111                         ;# number of mobilenodes
set val(rp)             AODV                    ;# routing protocol
set val(x)	            1000                 ;# grid width
set val(y)	            1000                 ;# grid hieght

Queue/DropTail/PriQueue set Prefer_Routing_Protocols    1


#below parameters together with other default antenna parameter values set in the ns-default.tcl make the transmission range to be 250m
# for two-ray ground signal propagation model
#this group of parameters is used to specify sensing and transmission range.
Phy/WirelessPhy set RXThresh_ 3.65262e-10
Phy/WirelessPhy set Pt_ 0.281838
Phy/WirelessPhy set freq_ 914e+6 



puts "This is a multi-channel sensor network test program."

# =====================================================================
# Main Program
# ======================================================================
#source ../../ns-allinone-2.27/ns-2.27/tcl/lib/ns-lib.tcl
#
# Initialize Global Variables
#

set ns_		[new Simulator]
#set tracefd [open phenom06.tr w]
set idstracefd [open idstrace.tr w]
set idsappfd [open result_idsapp w]
set few_on [open few_on.txt w]
set few_arrival [open few_arrival.txt w]
set few_off [open few_off.txt w]
set few_freq [open few_freq.txt w]
set many_on [open many_on.txt w]
set many_arrival [open many_arrival.txt w]
set many_off [open many_off.txt w]
set many_freq [open many_freq.txt w]
set training_general [open training_general.txt w]
#$ns_ trace-all $tracefd

#set namtrace [open phenom06.nam w]
#$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

# set up topography object
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

#
# Create God
#
set god_ [create-god $val(nn)]
$god_ off
$god_ allow_to_stop
$god_ num_data_types 1

#configure phenomenon channel and data channel
set chan_1_ [new $val(chan)]
set chan_2_ [new $val(chan)]

# configure phenomenon node
set val(rp) PHENOM                              ;# PHENOM routing protocol
$ns_ node-config \
     -adhocRouting $val(rp) \
	 -llType $val(ll) \
	 -macType $val(PHENOMmac) \
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
	 -movementTrace OFF\

    set node_(0) [$ns_ node 0]
    $node_(0) random-motion 1		            ;# enable random motion
    $god_ new_node $node_(0)
   # $node_(0) namattach $namtrace
    #$ns_ initial_node_pos $node_(0) 25
    [$node_(0) set ragent_] pulserate .1       ;#configures PHENOM node, 10 times per second
    [$node_(0) set ragent_] phenomenon CO      ;#configures PHENOM node
#start random-motion
	$node_(0) start

# configure sensor nodes
set val(rp) AODVUU                                ;# AODV routing protocol
$ns_ node-config \
     -adhocRouting $val(rp) \
	 -channel $chan_2_ \
	 -macType $val(mac) \
     -PHENOMchannel $chan_1_ \
	 -PHENOMmacType $val(PHENOMmac)

topology-grid_ 0 $val(x) 0 $val(y) 100

	for {set i 1} {$i < [expr $val(nn)-10] } {incr i} {
		set node_($i) [$ns_ node]
		$node_($i) random-motion 0
        $god_ new_node $node_($i)
       # $node_($i) namattach $namtrace
	   $node_($i) set X_ $XX_([expr int($i-1)])
	   $node_($i) set Y_ $YY_([expr int($i-1)])
	}

#configure cluster heads (only one cluster head and it also serves as the BS)
$ns_ node-config \
	-ids DDOS_IDS \
	-channel $chan_2_ \
	-PHENOMchannel "off"

		set node_($i) [$ns_ node]
		$node_($i) random-motion 0
		$god_ new_node $node_($i)
	   $node_($i) set X_ 500
	   $node_($i) set Y_ 500


###############################################################################
# Attach the sensor agent to the sensor node, and build a conduit thru which
# recieved PHENOM packets will reach the sensor agent's recv routine

# attach a Sensor Agent (i.e. sensor agent) to sensor node
for {set i 1} {$i < [expr $val(nn)-10] } {incr i} {
  set sensor_($i) [new Agent/SensorAgent]
  $ns_ attach-agent $node_($i) $sensor_($i)
}

# specify the sensor agent as the up-target for the sensor node's link layer
# configured on the PHENOM interface
for {set i 1} {$i < [expr $val(nn)-10] } {incr i} {
  [$node_($i) set ll_(1)] up-target $sensor_($i)
  $ns_ at 4.0 "$sensor_($i) start"
}

###############################################################################

# setup UDP connections to data collection point, and attach sensor apps
set sink [new Agent/UDP/MIUN_WSN]
$ns_ attach-agent $node_(101) $sink
$ns_ set_sinknode $node_(101)
for {set i 1} {$i < [expr $val(nn)-10] } {incr i} {
  set src_($i) [new Agent/UDP/MIUN_WSN]
  $ns_ attach-agent $node_($i) $src_($i)
  #$ns_ connect $src_($i) $sink
  
  set app_($i) [new Application/SensorApp]
  $app_($i) attach-agent $src_($i)
  $app_($i) dst_agent $sink
}
for {set i 1} {$i < [expr $val(nn)-10] } {incr i} {
  $ns_ at 5.0 "$app_($i) start $sensor_($i)"
}

set IDSapp_ [new Application/IDSApp]
$IDSapp_ bind_ids [$ns_ set ids_handler_]
$IDSapp_ node $node_(101)
$IDSapp_ file $idsappfd
$node_(101) ids-app $IDSapp_

$ns_ at 50000 "$IDSapp_ result-dump $few_on $few_arrival $few_off $few_freq $many_on $many_arrival $many_off $many_freq $training_general"

#
# start dos attack
#for {set i 10} {$i < 20} {incr i} {
#  $ns_ at 105.0 "$app_($i) start_dos_attack $src_(5)"
#  $ns_ at 110.0 "$app_($i) stop_dos_attack"
#}
#set the IDS state.
$ns_ at 5.0 "$ns_ set_ids_state training"
#$ns_ at 10000.0 "$ns_ set_ids_state detecting"

#Tell nodes when the simulation ends
#
for {set i 0} {$i < 102} {incr i} {
  $ns_ at 50001.0 "$node_($i) reset";
}  

$ns_ at 50001.0 "stop"
$ns_ at 50002.0 "puts \"NS EXITING...\" ; $ns_ halt"

proc stop {} {
    global ns_ idstracefd idsappfd few_on few_off few_arrival few_freq many_on many_arrival many_off many_freq training_general
    $ns_ flush-trace
    #close $tracefd
    #close $namtrace
    close $idstracefd
	close $idsappfd
	close $few_on
	close $few_arrival
	close $few_off
	close $few_freq
	close $many_on
	close $many_arrival
	close $many_off
	close $many_freq
	close $training_general
}
#Begin command line parsing

puts "Starting Simulation..."
$ns_ run



