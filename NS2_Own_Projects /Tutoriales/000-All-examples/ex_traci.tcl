# ======================================================================
# Define options
# ======================================================================
set val(chan)   Channel/WirelessChannel		      ;# channel type
set val(prop)   Propagation/TwoRayGround		      ;# radio-propagation model
set val(netif)  Phy/WirelessPhy		      ;# network interface type
set val(mac)    Mac/802_11		      ;# MAC type
set val(ifq)    Queue/DropTail/PriQueue		      ;# interface queue type
set val(ll)     LL		      ;# link layer type
set val(ant)    Antenna/OmniAntenna		      ;# antenna model
set val(ifqlen) 50		      ;# max packet in ifq
set val(nn)     60	      ;# number of mobilenodes
set val(rp)     AODV		      ;# routing protocol

set opt(x)      1652			      ;# x coordinate of topology
set opt(y)      1652			     ;# y coordinate of topology
set stopTime      290.00

# ======================================================================
# Main Program
# ======================================================================
# 
# Initialize Global Variables
# 
set ns_ [new Simulator]
set tracefd [open ns.tr w]
$ns_ trace-all $tracefd

set namtrace [open ns.nam w]
$ns_ namtrace-all-wireless $namtrace $opt(x) $opt(y)

# set up topography object
set topo    [new Topography]
$topo load_flatgrid $opt(x) $opt(y)

# 
# Create God
# 
create-god $val(nn)

# ======================================================================
#       TraCI Connection Setup
# ======================================================================
set mobilityInterfaceClient [new TraCIClient]
$mobilityInterfaceClient set-remoteHost localhost
$mobilityInterfaceClient set-remotePort 8888
$mobilityInterfaceClient set-timeInterval 1.0
puts "Connect to TraCI server"
$mobilityInterfaceClient connect
$mobilityInterfaceClient startSimStepHandler

# Configure node

set chan_1_ [new $val(chan)]
$ns_ node-config  -adhocRouting $val(rp) \
 		 -llType $val(ll) \
 		 -macType $val(mac) \
 		 -ifqType $val(ifq) \
 		 -ifqLen $val(ifqlen) \
 		 -antType $val(ant) \
 		 -propType $val(prop) \
 		 -phyType $val(netif) \
 		 -topoInstance $topo \
 		 -agentTrace OFF \
 		 -routerTrace OFF \
 		 -macTrace OFF \
 		 -movementTrace OFF \
 		 -channel $chan_1_  

for {set i 0} {$i < $val(nn)} {incr i} {
  set node_($i) [$ns_ node]
  $node_($i) random-motion 0 ;# disable random motion
  $mobilityInterfaceClient add-node $node_($i)
}
# 
# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
# 
# predefine node in NAM  
  # ID of SUMO: flow60A_0
$node_(0) set X_ 30.65
$node_(0) set Y_ 410.05
$node_(0) set Z_ 0.0
$node_(0) setdest 30.65 410.05 1
  # ID of SUMO: flow50A_0
$node_(1) set X_ 30.65
$node_(1) set Y_ 810.05
$node_(1) set Z_ 0.0
$node_(1) setdest 30.65 810.05 1
  # ID of SUMO: flow40A_0
$node_(2) set X_ 30.65
$node_(2) set Y_ 1210.05
$node_(2) set Z_ 0.0
$node_(2) setdest 30.65 1210.05 1
  # ID of SUMO: flow10B_0
$node_(3) set X_ 419.95
$node_(3) set Y_ 30.65
$node_(3) set Z_ 0.0
$node_(3) setdest 419.95 30.65 1
  # ID of SUMO: flow10A_0
$node_(4) set X_ 410.05
$node_(4) set Y_ 1599.3500000000001
$node_(4) set Z_ 0.0
$node_(4) setdest 410.05 1599.3500000000001 1
  # ID of SUMO: flow20B_0
$node_(5) set X_ 819.95
$node_(5) set Y_ 30.65
$node_(5) set Z_ 0.0
$node_(5) setdest 819.95 30.65 1
  # ID of SUMO: flow20A_0
$node_(6) set X_ 810.05
$node_(6) set Y_ 1599.3500000000001
$node_(6) set Z_ 0.0
$node_(6) setdest 810.05 1599.3500000000001 1
  # ID of SUMO: flow30B_0
$node_(7) set X_ 1219.95
$node_(7) set Y_ 30.65
$node_(7) set Z_ 0.0
$node_(7) setdest 1219.95 30.65 1
  # ID of SUMO: flow60B_0
$node_(8) set X_ 1599.3500000000001
$node_(8) set Y_ 419.95
$node_(8) set Z_ 0.0
$node_(8) setdest 1599.3500000000001 419.95 1
  # ID of SUMO: flow50B_0
$node_(9) set X_ 1599.3500000000001
$node_(9) set Y_ 819.95
$node_(9) set Z_ 0.0
$node_(9) setdest 1599.3500000000001 819.95 1
  # ID of SUMO: flow30A_0
$node_(10) set X_ 1210.05
$node_(10) set Y_ 1599.3500000000001
$node_(10) set Z_ 0.0
$node_(10) setdest 1210.05 1599.3500000000001 1
  # ID of SUMO: flow40B_0
$node_(11) set X_ 1599.3500000000001
$node_(11) set Y_ 1219.95
$node_(11) set Z_ 0.0
$node_(11) setdest 1599.3500000000001 1219.95 1
  # ID of SUMO: flow60A_1
$node_(12) set X_ 30.65
$node_(12) set Y_ 410.05
$node_(12) set Z_ 0.0
$node_(12) setdest 30.65 410.05 1
  # ID of SUMO: flow50A_1
$node_(13) set X_ 30.65
$node_(13) set Y_ 810.05
$node_(13) set Z_ 0.0
$node_(13) setdest 30.65 810.05 1
  # ID of SUMO: flow40A_1
$node_(14) set X_ 30.65
$node_(14) set Y_ 1210.05
$node_(14) set Z_ 0.0
$node_(14) setdest 30.65 1210.05 1
  # ID of SUMO: flow10B_1
$node_(15) set X_ 419.95
$node_(15) set Y_ 30.65
$node_(15) set Z_ 0.0
$node_(15) setdest 419.95 30.65 1
  # ID of SUMO: flow10A_1
$node_(16) set X_ 410.05
$node_(16) set Y_ 1599.3500000000001
$node_(16) set Z_ 0.0
$node_(16) setdest 410.05 1599.3500000000001 1
  # ID of SUMO: flow20B_1
$node_(17) set X_ 819.95
$node_(17) set Y_ 30.65
$node_(17) set Z_ 0.0
$node_(17) setdest 819.95 30.65 1
  # ID of SUMO: flow20A_1
$node_(18) set X_ 810.05
$node_(18) set Y_ 1599.3500000000001
$node_(18) set Z_ 0.0
$node_(18) setdest 810.05 1599.3500000000001 1
  # ID of SUMO: flow30B_1
$node_(19) set X_ 1219.95
$node_(19) set Y_ 30.65
$node_(19) set Z_ 0.0
$node_(19) setdest 1219.95 30.65 1
  # ID of SUMO: flow60B_1
$node_(20) set X_ 1599.3500000000001
$node_(20) set Y_ 419.95
$node_(20) set Z_ 0.0
$node_(20) setdest 1599.3500000000001 419.95 1
  # ID of SUMO: flow50B_1
$node_(21) set X_ 1599.3500000000001
$node_(21) set Y_ 819.95
$node_(21) set Z_ 0.0
$node_(21) setdest 1599.3500000000001 819.95 1
  # ID of SUMO: flow30A_1
$node_(22) set X_ 1210.05
$node_(22) set Y_ 1599.3500000000001
$node_(22) set Z_ 0.0
$node_(22) setdest 1210.05 1599.3500000000001 1
  # ID of SUMO: flow40B_1
$node_(23) set X_ 1599.3500000000001
$node_(23) set Y_ 1219.95
$node_(23) set Z_ 0.0
$node_(23) setdest 1599.3500000000001 1219.95 1
  # ID of SUMO: flow60A_2
$node_(24) set X_ 30.65
$node_(24) set Y_ 410.05
$node_(24) set Z_ 0.0
$node_(24) setdest 30.65 410.05 1
  # ID of SUMO: flow50A_2
$node_(25) set X_ 30.65
$node_(25) set Y_ 810.05
$node_(25) set Z_ 0.0
$node_(25) setdest 30.65 810.05 1
  # ID of SUMO: flow40A_2
$node_(26) set X_ 30.65
$node_(26) set Y_ 1210.05
$node_(26) set Z_ 0.0
$node_(26) setdest 30.65 1210.05 1
  # ID of SUMO: flow10B_2
$node_(27) set X_ 419.95
$node_(27) set Y_ 30.65
$node_(27) set Z_ 0.0
$node_(27) setdest 419.95 30.65 1
  # ID of SUMO: flow10A_2
$node_(28) set X_ 410.05
$node_(28) set Y_ 1599.3500000000001
$node_(28) set Z_ 0.0
$node_(28) setdest 410.05 1599.3500000000001 1
  # ID of SUMO: flow20B_2
$node_(29) set X_ 819.95
$node_(29) set Y_ 30.65
$node_(29) set Z_ 0.0
$node_(29) setdest 819.95 30.65 1
  # ID of SUMO: flow20A_2
$node_(30) set X_ 810.05
$node_(30) set Y_ 1599.3500000000001
$node_(30) set Z_ 0.0
$node_(30) setdest 810.05 1599.3500000000001 1
  # ID of SUMO: flow30B_2
$node_(31) set X_ 1219.95
$node_(31) set Y_ 30.65
$node_(31) set Z_ 0.0
$node_(31) setdest 1219.95 30.65 1
  # ID of SUMO: flow60B_2
$node_(32) set X_ 1599.3500000000001
$node_(32) set Y_ 419.95
$node_(32) set Z_ 0.0
$node_(32) setdest 1599.3500000000001 419.95 1
  # ID of SUMO: flow50B_2
$node_(33) set X_ 1599.3500000000001
$node_(33) set Y_ 819.95
$node_(33) set Z_ 0.0
$node_(33) setdest 1599.3500000000001 819.95 1
  # ID of SUMO: flow30A_2
$node_(34) set X_ 1210.05
$node_(34) set Y_ 1599.3500000000001
$node_(34) set Z_ 0.0
$node_(34) setdest 1210.05 1599.3500000000001 1
  # ID of SUMO: flow40B_2
$node_(35) set X_ 1599.3500000000001
$node_(35) set Y_ 1219.95
$node_(35) set Z_ 0.0
$node_(35) setdest 1599.3500000000001 1219.95 1
  # ID of SUMO: flow60A_3
$node_(36) set X_ 30.65
$node_(36) set Y_ 410.05
$node_(36) set Z_ 0.0
$node_(36) setdest 30.65 410.05 1
  # ID of SUMO: flow50A_3
$node_(37) set X_ 30.65
$node_(37) set Y_ 810.05
$node_(37) set Z_ 0.0
$node_(37) setdest 30.65 810.05 1
  # ID of SUMO: flow40A_3
$node_(38) set X_ 30.65
$node_(38) set Y_ 1210.05
$node_(38) set Z_ 0.0
$node_(38) setdest 30.65 1210.05 1
  # ID of SUMO: flow10B_3
$node_(39) set X_ 419.95
$node_(39) set Y_ 30.65
$node_(39) set Z_ 0.0
$node_(39) setdest 419.95 30.65 1
  # ID of SUMO: flow10A_3
$node_(40) set X_ 410.05
$node_(40) set Y_ 1599.3500000000001
$node_(40) set Z_ 0.0
$node_(40) setdest 410.05 1599.3500000000001 1
  # ID of SUMO: flow20B_3
$node_(41) set X_ 819.95
$node_(41) set Y_ 30.65
$node_(41) set Z_ 0.0
$node_(41) setdest 819.95 30.65 1
  # ID of SUMO: flow20A_3
$node_(42) set X_ 810.05
$node_(42) set Y_ 1599.3500000000001
$node_(42) set Z_ 0.0
$node_(42) setdest 810.05 1599.3500000000001 1
  # ID of SUMO: flow30B_3
$node_(43) set X_ 1219.95
$node_(43) set Y_ 30.65
$node_(43) set Z_ 0.0
$node_(43) setdest 1219.95 30.65 1
  # ID of SUMO: flow60B_3
$node_(44) set X_ 1599.3500000000001
$node_(44) set Y_ 419.95
$node_(44) set Z_ 0.0
$node_(44) setdest 1599.3500000000001 419.95 1
  # ID of SUMO: flow50B_3
$node_(45) set X_ 1599.3500000000001
$node_(45) set Y_ 819.95
$node_(45) set Z_ 0.0
$node_(45) setdest 1599.3500000000001 819.95 1
  # ID of SUMO: flow30A_3
$node_(46) set X_ 1210.05
$node_(46) set Y_ 1599.3500000000001
$node_(46) set Z_ 0.0
$node_(46) setdest 1210.05 1599.3500000000001 1
  # ID of SUMO: flow40B_3
$node_(47) set X_ 1599.3500000000001
$node_(47) set Y_ 1219.95
$node_(47) set Z_ 0.0
$node_(47) setdest 1599.3500000000001 1219.95 1
  # ID of SUMO: flow60A_4
$node_(48) set X_ 30.65
$node_(48) set Y_ 410.05
$node_(48) set Z_ 0.0
$node_(48) setdest 30.65 410.05 1
  # ID of SUMO: flow50A_4
$node_(49) set X_ 30.65
$node_(49) set Y_ 810.05
$node_(49) set Z_ 0.0
$node_(49) setdest 30.65 810.05 1
  # ID of SUMO: flow40A_4
$node_(50) set X_ 30.65
$node_(50) set Y_ 1210.05
$node_(50) set Z_ 0.0
$node_(50) setdest 30.65 1210.05 1
  # ID of SUMO: flow10B_4
$node_(51) set X_ 419.95
$node_(51) set Y_ 30.65
$node_(51) set Z_ 0.0
$node_(51) setdest 419.95 30.65 1
  # ID of SUMO: flow10A_4
$node_(52) set X_ 410.05
$node_(52) set Y_ 1599.3500000000001
$node_(52) set Z_ 0.0
$node_(52) setdest 410.05 1599.3500000000001 1
  # ID of SUMO: flow20B_4
$node_(53) set X_ 819.95
$node_(53) set Y_ 30.65
$node_(53) set Z_ 0.0
$node_(53) setdest 819.95 30.65 1
  # ID of SUMO: flow20A_4
$node_(54) set X_ 810.05
$node_(54) set Y_ 1599.3500000000001
$node_(54) set Z_ 0.0
$node_(54) setdest 810.05 1599.3500000000001 1
  # ID of SUMO: flow30B_4
$node_(55) set X_ 1219.95
$node_(55) set Y_ 30.65
$node_(55) set Z_ 0.0
$node_(55) setdest 1219.95 30.65 1
  # ID of SUMO: flow60B_4
$node_(56) set X_ 1599.3500000000001
$node_(56) set Y_ 419.95
$node_(56) set Z_ 0.0
$node_(56) setdest 1599.3500000000001 419.95 1
  # ID of SUMO: flow50B_4
$node_(57) set X_ 1599.3500000000001
$node_(57) set Y_ 819.95
$node_(57) set Z_ 0.0
$node_(57) setdest 1599.3500000000001 819.95 1
  # ID of SUMO: flow30A_4
$node_(58) set X_ 1210.05
$node_(58) set Y_ 1599.3500000000001
$node_(58) set Z_ 0.0
$node_(58) setdest 1210.05 1599.3500000000001 1
  # ID of SUMO: flow40B_4
$node_(59) set X_ 1599.3500000000001
$node_(59) set Y_ 1219.95
$node_(59) set Z_ 0.0
$node_(59) setdest 1599.3500000000001 1219.95 1

# All nodes enable command-enablePositionUpdate

for {set i 1} {$i < $stopTime } {incr i} {
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 0 flow60A_0"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 1 flow50A_0"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 2 flow40A_0"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 3 flow10B_0"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 4 flow10A_0"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 5 flow20B_0"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 6 flow20A_0"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 7 flow30B_0"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 8 flow60B_0"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 9 flow50B_0"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 10 flow30A_0"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 11 flow40B_0"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 12 flow60A_1"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 13 flow50A_1"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 14 flow40A_1"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 15 flow10B_1"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 16 flow10A_1"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 17 flow20B_1"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 18 flow20A_1"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 19 flow30B_1"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 20 flow60B_1"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 21 flow50B_1"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 22 flow30A_1"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 23 flow40B_1"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 24 flow60A_2"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 25 flow50A_2"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 26 flow40A_2"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 27 flow10B_2"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 28 flow10A_2"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 29 flow20B_2"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 30 flow20A_2"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 31 flow30B_2"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 32 flow60B_2"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 33 flow50B_2"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 34 flow30A_2"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 35 flow40B_2"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 36 flow60A_3"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 37 flow50A_3"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 38 flow40A_3"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 39 flow10B_3"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 40 flow10A_3"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 41 flow20B_3"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 42 flow20A_3"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 43 flow30B_3"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 44 flow60B_3"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 45 flow50B_3"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 46 flow30A_3"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 47 flow40B_3"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 48 flow60A_4"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 49 flow50A_4"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 50 flow40A_4"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 51 flow10B_4"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 52 flow10A_4"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 53 flow20B_4"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 54 flow20A_4"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 55 flow30B_4"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 56 flow60B_4"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 57 flow50B_4"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 58 flow30A_4"
  $ns_ at $i "$mobilityInterfaceClient command-enablePositionUpdate 59 flow40B_4"
}


# The example of TraCI API
# Please use MOVE's traCI example scenario to test TraCI's running environment

# command-GetRoadID [nsID] [sumoID]
# Returns the id of the edge the named vehicle was at within the last step; error value: ""
# $ns_ at 3.0 "$mobilityInterfaceClient command-GetRoadID 6 flow20A_0"

# command-SetMaxSpeed [nsID] [sumoID] [max speed]
# Sets the vehicle's maximum speed to the given value
# $ns_ at 5.0 "$mobilityInterfaceClient command-SetMaxSpeed 0 flow60A_0 5"

# command-SetMaxSpeed [nsID] [sumoID] [target edge]
# The vehicle's destination edge is set to the given. The route is rebuilt.
# $ns_ at 5.0 "$mobilityInterfaceClient command-ChangeTarget 0 flow60A_0 4344-2"

# command-changeRoute [nsID] [sumoID] [number of edges] [edges lists] 
# Assigns the list of edges as the vehicle's new route assuming the first edge given is the one the vehicle is curently at: The first occurence of the edge is currently at is searched within the new route; the vehicle continues the route from this point in the route from. If the edge the vehicle is currently does not exist within the new route, an error is generated.
 $ns_ at 5.0 "$mobilityInterfaceClient command-changeRoute 0 flow60A_0 7 0111-1,1011-2,1020-1,2021-1,2131-1,3141-1,3141-2"

#
# Tell nodes when the simulation ends
#
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $stopTime "$node_($i) reset";
}
$ns_ at $stopTime "$mobilityInterfaceClient close"
$ns_ at $stopTime "stop"
$ns_ at $stopTime "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd namtrace
    $ns_ flush-trace
    close $tracefd
    close $namtrace
}

puts "Starting Simulation..."
$ns_ run

