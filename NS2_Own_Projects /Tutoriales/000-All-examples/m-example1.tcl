####  http://www.mannasim.dcc.ufmg.br/howto.htm
#
######################   Page 1 ###########################

set ns_	[new Simulator]                 ;# simulation object
set traceFile [open trace.tr w]         ;# trace file
$ns_ trace-all $traceFile               ;# attach trace to simulation
$ns_ use-newtrace                       ;# use new trace format



# Unity gain, omni-directional antennas set up the antenas to be
# centered in the node and 1.5 meters above it
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
Phy/WirelessPhy set Rb_ 2*1e6
Phy/WirelessPhy set Pt_ 0.2818
Phy/WirelessPhy set freq_ 914e+6
Phy/WirelessPhy set L_ 1.0



set val(chan)	 Channel/WirelessChannel  ;# channel type
set val(prop)	 Propagation/TwoRayGround ;# radio-propagation model 
set val(netif)	 Phy/WirelessPhy          ;# network interface type
set val(mac)	 Mac/802_11               ;# MAC type
set val(ifq)	 Queue/DropTail/PriQueue  ;# interface queye type
set val(ll) 	 LL                       ;# link layer type
set val(ant)	 Antenna/OmniAntenna      ;# antenna model
set val(ifqlen)	 200                      ;# max packet in ifq
set val(rp)      AODV	                  ;# routing protocol 
set val(x)       30.0                     ;# scenario X dimension  
set val(y)       30.0                     ;# scenario Y dimension 
set val(start)   5.0                      ;# simulation start time
set val(stop)	 3605.0                   ;# simulation stop time
set val(energy)  10.0                     ;# initial energy (joules)
set val(rx)      0.024                    ;# reception energy
set val(tx)      0.045                    ;# transmission energy
set val(idle)    0.000                    ;# idle energy
set val(nn)      22                       ;# total number of nodes

set val(en)  EnergyModel/Battery             ; # energy model

#set udp_($counter) [new Agent/UDP]
#set app_($counter) [new Application/SensorBaseApp/ClusterHeadApp]
#set processing_($counter) [new Processing/AggregateProcessing]


set topo [new Topography]               ;# simulation topology
$topo load_flatgrid $val(x) $val(y)     ;# flat topology
create-god $val(nn) 
                    ;# god

################################  Page 2  ##########################

$ns_ node-config -sensorNode ON \
                 -adhocRouting $val(rp) \
		 -adhocRouting $val(rp) \
		 -llType $val(ll) \
		 -macType $val(mac) \
		 -ifqType $val(ifq) \
		 -ifqLen $val(ifqlen) \
		 -antType $val(ant) \
	   	 -propType $val(prop) \
 		 -energyModel $val(en)


set node_($counter) [$ns_ node]
set udp_($counter) [new Agent/UDP]
set app_($counter) [new Application/SensorBaseApp/AccessPointApp]


$app_($counter) set destination_id_ 0;
$app_($counter) attach-agent $udp_($counter)



$node_($counter) random-motion 0
$node_($counter) set X_ 5.0
$node_($counter) set Y_ 5.0
$node_($counter) set Z_ 0.0
$node_($counter) attach $udp_($counter) $val(port)


$ns_ at 1200.0 "$app_($counter) stop"


$app_($counter) set request_type_ 25 0
$ns_ at 120.0 "$app_($counter) add_temp_data_param 25 0"
$ns_ at 120.5 "$app_ send_request"



######################   Page 3   #####################################

set node_($counter) [$ns_ node]
set udp_($counter) [new Agent/UDP]
set app_($counter) [new Application/SensorBaseApp/ClusterHeadApp]
set processing_($counter) [new Processing/AggregateProcessing]


$app_($counter) node $node_($counter);
$app_($counter) set destination_id_ 0;
$app_($counter) set dissemination_type 0;
$app_($counter) set dissemination_interval 30.0;
$app_($counter) attach-agent $udp_($counter)
$app_($counter) attach-processing $processing_($counter) 


$node_($counter) random-motion 0
$node_($counter) set X_ 5.0
$node_($counter) set Y_ 5.0
$node_($counter) set Z_ 0.0
$node_($counter) add-app $app_($counter)
$node_($counter) attach $udp_($counter) $val(port)
Node/MobileNode/SensorNode set processingPower_ 0.024
Node/MobileNode/SensorNode set instructionsPerSecond_ 8000000

$processing_($counter) node $node_($counter)
$ns_ at 1.0 "$app_($counter) start"
$ns_ at 1200.0 "$app_($counter) stop"


##########################   Page 4   ###########################


set node_($counter) [$ns_ node]
set udp_($counter) [new Agent/UDP]
set processing_($counter) [new Processing/AggregateProcessing]
set gen_($counter) [new DataGenerator/TemperatureDataGenerator]
set app_($counter) [new Application/SensorBaseApp/CommonNodeApp]


$app_($counter) set destination_id_ 0;
$app_($counter) set dissemination_type 0;
$app_($counter) set dissemination_interval 30.0;
$app_($counter) node $node_($counter);
$app_($counter) attach-agent $udp_($counter)
$app_($counter) attach_data_generator $gen_($counter)
$app_($counter) attach-processing $processing_($counter)


$node_($counter) random-motion 0
$node_($counter) set X_ 5.0
$node_($counter) set Y_ 5.0
$node_($counter) set Z_ 0.0
$node_($counter) add-app $app_($counter)
$node_($counter) attach $udp_($counter) $val(port)

Node/MobileNode/SensorNode set sensingPower_ 0.015
Node/MobileNode/SensorNode set processingPower_ 0.024
Node/MobileNode/SensorNode set instructionsPerSecond_ 8000000

$ns run