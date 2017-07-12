# =============================================
# Procedure to create a common node application
# =============================================
proc create_common_app {destination_id disseminating_type disseminating_interval} {
	set app_ [new Application/SensorBaseApp/CommonNodeApp]
	$app_ set destination_id_ $destination_id
	$app_ set disseminating_type_ $disseminating_type
	$app_ set disseminating_interval_ $disseminating_interval
	return $app_
}

# ===================================================
# Procedure to create a cluster head node application
# ===================================================
proc create_cluster_head_app {destination_id disseminating_type disseminating_interval} {
	set app_ [new Application/SensorBaseApp/ClusterHeadApp]
	$app_ set destination_id_ $destination_id
	$app_ set disseminating_type_ $disseminating_type
	$app_ set disseminating_interval_ $disseminating_interval
	return $app_
}

# ====================================================
# Procedure to create a access point node application. 
# ====================================================
proc create_access_point_app {destination_id} {
	set app_ [new Application/AccessPointApp]
	$app_ set destination_id_ $destination_id
	return $app_
}

# ================================================
# Procedure to create a Temperature Data Generator
# ================================================
proc create_temp_data_generator {sensing_interval sensing_type avg_measure std_deviation} {
	set temp_gen_ [new DataGenerator/TemperatureDataGenerator]
	$temp_gen_ set sensing_interval_ $sensing_interval
	$temp_gen_ set sensing_type_ $sensing_type
	$temp_gen_ set avg_measure $avg_measure
	$temp_gen_ set std_deviation $std_deviation
	return $temp_gen_
}

# ====================================================
# Procedure to create a Carbon Monoxide Data Generator
# ====================================================
proc create_carbon_data_generator {sensing_interval sensing_type avg_measure std_deviation} {
	set carbon_gen_ [new DataGenerator/CarbonMonoxideDataGenerator]
	$carbon_gen_ set sensing_interval_ $sensing_interval
	$carbon_gen_ set sensing_type_ $sensing_type
	$carbon_gen_ set avg_measure $avg_measure
	$carbon_gen_ set std_deviation $std_deviation
	return $carbon_gen_
}

# =================================
# Antenna Settings
# =================================
Antenna/OmniAntenna set X_ 0
Antenna/OmniAntenna set Y_ 0
Antenna/OmniAntenna set Z_ 1.5
Antenna/OmniAntenna set Gt_ 1.0
Antenna/OmniAntenna set Gr_ 1.0

# =================================
# Wireless Phy Settings
# =================================
Phy/WirelessPhy set CPThresh_ 10.0
Phy/WirelessPhy set CSThresh_ 1.559e-11
Phy/WirelessPhy set RXThresh_ 3.652e-10
Phy/WirelessPhy set Rb_ 2*1e6
Phy/WirelessPhy set Pt_ 0.2818
Phy/WirelessPhy set freq_ 914e+6
Phy/WirelessPhy set L_ 1.0

set contador_nodos 0

# ==================================
# Simulation parameters
# ==================================
set val(pt_common) 8.564879510890936E-4
set val(pt_cluster_head) 0.0

set val(chan)	Channel/WirelessChannel		; # channel
set val(prop)	Propagation/TwoRayGround	; # propagation 
set val(netif)	Phy/WirelessPhy			; # phy
set val(mac)	Mac/802_11			; # mac
set val(ifq) 	Queue/DropTail/PriQueue		; # queue
set val(ll) 	LL				; # link layer
set val(ant) 	Antenna/OmniAntenna		; # antenna 
set val(ifqlen)	200				; # queue length
set val(rp)	DumbAgent			; # routing protocol
set val(en)	EnergyModel/Battery		; # energy model
set val(nn)	12				; # number of nodes
set val(n_pas)	1				; # number os access points
set val(n_sinks) 1				; # number of sink
set val(n_cluster) 	0			; # number of cluster heads
set val(n_common) 	10			; # number of common nodes
set val(x)		30.0			; # x lenght of scenario
set val(y)		30.0			; # y lenght of scenario

set val(disseminating_type)	0		; # common node disseminating type
set val(ch_disseminating_type)	0		; # cluster heard disseminating type
set val(disseminating_interval)	5.0		; # common node disseminating interval
set val(cluster_head_disseminating_interval)	0.0 ; # cluster head disseminating interval

set val(start)			5.0		; # simulation start time
set val(stop)			15.0		; # simulation stop time

set val(father_addr) 		1		; # sink address
set val(port)			2020		; # default port

# =======================================
# Global variables
# =======================================
set ns_	[new Simulator]
set traceFile	[open mannasim-rede-plana.tr w]
$ns_ trace-all $traceFile

$ns_ namtrace-all $traceFile
set traceFile [open mannasim-rede-p.nam w]
$ns_ namtrace-all $traceFile
# $ns_ namtrace-all [open mannasim-rede-p.nam w]


$ns_ use-newtrace
set topo	[new Topography]
$topo load_flatgrid $val(x) $val(y)
create-god $val(nn)
set rng [new RNG]
$rng seed 0

# =================================
# Procedure to create a common node 
# =================================
proc create_common_node {} {
	global val ns_ node_ topo udp_ app_ gen_ contador_nodos rng

Phy/WirelessPhy set Pt_ $val(pt_common)
	$ns_ node-config -sensorNode ON \
	-adhocRouting $val(rp) \
	-llType $val(ll) \
	-macType $val(mac) \
	-ifqType $val(ifq) \
	-ifqLen $val(ifqlen) \
	-antType $val(ant) \
	-propType $val(prop) \
	-energyModel $val(en) \
	-phyType $val(netif) \
	-channelType $val(chan) \
	-topoInstance $topo \
	 -agentTrace ON \
	-routerTrace ON \
	-macTrace OFF \
	-rxPower 0.024 \
	-txPower 0.036 \
	-initialEnergy 10.0 \
	-movementTrace OFF
	set node_($contador_nodos) [$ns_ node]
	$node_($contador_nodos) random-motion 0
	set x [$rng uniform 0.0 $val(x)]
	set y [$rng uniform 0.0 $val(y)]
	$node_($contador_nodos) set X_ $x
	$node_($contador_nodos) set Y_ $y
	$node_($contador_nodos) set Z_ 0.0
	set interval [$rng uniform 0.0 1.0]

	Node/MobileNode/SensorNode set sensingPower_ 0.015
	Node/MobileNode/SensorNode set processingPower 0.024
	Node/MobileNode/SensorNode set instructionsPerSecond_ 8000000
	Phy/WirelessPhy set  bandwidth_ 288000.0

	set udp_($contador_nodos) [new Agent/UDP]

	set distance 10000000
	set initial [expr $val(n_pas) + $val(n_sinks)]

	for {set j $initial} {$j < [expr $initial + $val(n_cluster)]} {incr j} {
		set x_father [$node_($j) set X_]
		set y_father [$node_($j) set Y_]
		set x_son [$node_($contador_nodos) set X_]
		set y_son [$node_($contador_nodos) set Y_]
		set x_temp [expr pow([expr $x_father-$x_son],2)]
		set y_temp [expr pow([expr $y_father-$y_son],2)]
		set temp_distance [expr sqrt([expr $x_temp + $y_temp])]
		if {$temp_distance < $distance} {
			set distance $temp_distance
			set val(father_addr) [$node_($j) node-addr]
		}
	}

	set app_($contador_nodos) [create_common_app $val(father_addr) $val(disseminating_type) $val(disseminating_interval)]
	$node_($contador_nodos) attach $udp_($contador_nodos) $val(port)
	$node_($contador_nodos) add-app $app_($contador_nodos)

	set processing_($contador_nodos) [new Processing/AggregateProcessing]

	$app_($contador_nodos) node $node_($contador_nodos)
	$app_($contador_nodos) attach-agent $udp_($contador_nodos)

	$app_($contador_nodos) attach-processing $processing_($contador_nodos)
	$processing_($contador_nodos) node $node_($contador_nodos)

	$ns_ at [expr $val(start) + 1 + $interval] "$app_($contador_nodos) start"
	$ns_ at $val(stop) "$app_($contador_nodos) stop"

	set gen_($contador_nodos) [create_temp_data_generator 3.0 0 25.0 1.0]
	$app_($contador_nodos) attach_data_generator $gen_($contador_nodos)

	incr contador_nodos

}

# ========================================
# Procedure to create a cluster head node 
# ========================================
proc create_cluster_head_node {} {

global val ns_ node_ topo contador_nodos rng

Phy/WirelessPhy set Pt_ $val(pt_cluster_head)
	$ns_ node-config -sensorNode ON \
	-adhocRouting $val(rp) \
	-llType $val(ll) \
	-macType $val(mac) \
	-ifqType $val(ifq) \
	-ifqLen $val(ifqlen) \
	-antType $val(ant) \
	-propType $val(prop) \
	-energyModel $val(en) \
	-phyType $val(netif) \
	-channelType $val(chan) \
	-topoInstance $topo \
	 -agentTrace ON \
	-routerTrace ON \
	-macTrace OFF \
	-rxPower 0.0 \
	-txPower 0.0 \
	-initialEnergy 0.0 \
	-movementTrace OFF
	set node_($contador_nodos) [$ns_ node]
	$node_($contador_nodos) random-motion 0
	set x [$rng uniform 0.0 $val(x)]
	set y [$rng uniform 0.0 $val(y)]
	$node_($contador_nodos) set X_ $x
	$node_($contador_nodos) set Y_ $y
	$node_($contador_nodos) set Z_ 0.0
	set interval [$rng uniform 0.0 1.0]
	Node/MobileNode/SensorNode set processingPower 0.0
	Node/MobileNode/SensorNode set instructionsPerSecond_ 0
	Phy/WirelessPhy set  bandwidth_ 0.0

	set udp_($contador_nodos) [new Agent/UDP]

	set app_($contador_nodos) [create_cluster_head_app [$node_(1) node-addr] $val(disseminating_type) $val(cluster_head_disseminating_interval)]
	$node_($contador_nodos) attach $udp_($contador_nodos) $val(port)
	$node_($contador_nodos) add-app $app_($contador_nodos)
	set processing_($contador_nodos) [new ]

	$app_($contador_nodos) node $node_($contador_nodos)
	$app_($contador_nodos) attach-agent $udp_($contador_nodos)

	$app_($contador_nodos) attach-processing $processing_($contador_nodos)
	$processing_($contador_nodos) node $node_($contador_nodos)

	$ns_ at [expr $val(start) + 1 + $interval] "$app_($contador_nodos) start"
	$ns_ at $val(stop) "$app_($contador_nodos) stop"

	incr contador_nodos

}

# ===================================
# Procedure to create a sink node 
# ===================================
proc create_sink {} {
	global ns_ val node_ sink_ contador_nodos topo

	Phy/WirelessPhy set Pt_ 0.2818

	$ns_ node-config -sensorNode ON \
	-adhocRouting $val(rp) \
	-llType $val(ll) \
	-macType $val(mac) \
	-ifqType $val(ifq) \
	-ifqLen $val(ifqlen) \
	-antType $val(ant) \
	-propType $val(prop) \
	-energyModel $val(en) \
	-phyType $val(netif) \
	-channelType $val(chan) \
	-topoInstance $topo \
	-agentTrace ON \
	-routerTrace ON \
	-macTrace OFF \
	-rxPower 0.5 \
	-txPower 0.5 \
	-initialEnergy 100.0 \
	-movementTrace OFF

	set node_($contador_nodos) [$ns_ node]
	$node_($contador_nodos) random-motion 0

	set sink_(0) [new Agent/LossMonitor]
	$node_($contador_nodos) attach $sink_(0) $val(port)

	$node_($contador_nodos) set X_ 0.0
	$node_($contador_nodos) set Y_ 0.0
	$node_($contador_nodos) set Z_ 0.0

	incr contador_nodos

}

# ========================================
# Procedure to create a access point node 
# ========================================
proc create_access_point {} {
	global ns_ val node_ app_ udp_ contador_nodos topo
	Phy/WirelessPhy set Pt_ 0.2818
	$ns_ node-config -sensorNode ON \
	-adhocRouting $val(rp) \
	-llType $val(ll) \
	-macType $val(mac) \
	-ifqType $val(ifq) \
	-ifqLen $val(ifqlen) \
	-antType $val(ant) \
	-propType $val(prop) \
	-energyModel $val(en) \
	-phyType $val(netif) \
	-channelType $val(chan) \
	-topoInstance $topo \
	-agentTrace ON \
	-routerTrace ON \
	-macTrace OFF \
	-rxPower 0.5 \
	-txPower 0.5 \
	-initialEnergy 100.0 \
	-movementTrace OFF
	set node_($contador_nodos) [$ns_ node]
	$node_($contador_nodos) random-motion 0
	set  udp_($contador_nodos) [new Agent/UDP]
	set app_($contador_nodos) [create_access_point_app [$node_(0) node-addr]]
	$node_($contador_nodos) attach $udp_($contador_nodos) $val(port)
	$app_($contador_nodos) attach-agent $udp_($contador_nodos)
	$node_($contador_nodos) set X_ 5.0
	$node_($contador_nodos) set Y_ 5.0
	$node_($contador_nodos) set Z_ 0.0
	$ns_ at [expr $val(stop)+1] "$app_($contador_nodos) stop"
	incr contador_nodos

}

# =================================================================
# Procedures to control common node and cluster head node creation
# =================================================================
create_sink
create_access_point

for {set j 0} {$j < $val(n_cluster)} {incr j} {
	create_cluster_head_node
}

for {set i 0} {$i < $val(n_common)} {incr i} {
	create_common_node
}

# =========================
# Simulation
# =========================
$ns_ at [expr $val(stop)+2.0] "finish"

$ns_ at [expr $val(stop)+2.0] "puts \"NS EXITING...\" ; $ns_ halt"

$ns_ at [expr $val(stop)+2.0] "$ns_ nam-end-wireless $val(stop)"

proc finish {} {
	global ns_ traceFile
	$ns_ flush-trace
	close $traceFile

}

puts "Starting Simulation..."
$ns_ run
