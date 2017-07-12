#  Example by Ratish J. Punnoose to 
# show integration of Ricean Fading into ns2.
# Tested with version 2.28 and 2.30
# ==================================================


# Log File Configuration.  Set filename as null to avoid logging.
set val(logfile)        ricean-log.tr       ;#Set Log File name
#set val(namlog)         ricean-sample-namlog.nam   ;#Set NAM Log File name
set val(namlog)         null                       ;#Set NAM Log File name
set val(proplog)        ricean-proplog.tr   ;#Set Log for RF propagation info




set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/Simple                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             3                          ;# number of mobilenodes

set val(chan)           Channel/WirelessChannel    ;#Channel Type
#set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(prop)           Propagation/Ricean         ;# Rayleigh and Ricean
set val(RiceanK)        6                          ;# Ricean K factor
set val(RiceanMaxVel)   2.5                        ;# Ricean  Propagation  MaxVelocity Parameter

# Ricean  Propagation: Maximum ID of nodes (Total number of nodes) used to
# compute pairwise table offsets.
set val(RiceMaxNodeID)  [expr {$val(nn)-1}]        ;
set val(RiceDataFile)   rice_table.txt             ;# Ricean Propagation Data File




# routing protocol
set val(rp)              DumbAgent  
#set val(rp)             DSDV                     
#set val(rp)             DSR                      
#set val(rp)             AODV                     

set val(x)		1500
set val(y)		1500
set val(endtime)	500





# Initialize Global Variables and Logging 
set ns_		[new Simulator]
if {$val(logfile) != "null"} {
    set tracefd     [open $val(logfile)  w]
    $ns_ trace-all $tracefd
}
if {$val(namlog) != "null"} {
    set namtrace [open ricean-sample_nam_log.nam w]
    $ns_ namtrace-all-wireless $namtrace $val(x) $val(y)
}


# set up topography object
set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)

# Create God
create-god $val(nn)

# Create channel
set chan_ [new $val(chan)]

# Create node(0) and node(1)

# configure node, please note the change below.
$ns_ node-config -adhocRouting $val(rp) \
		-llType $val(ll) \
		-macType $val(mac) \
		-ifqType $val(ifq) \
		-ifqLen $val(ifqlen) \
		-antType $val(ant) \
		-propType $val(prop) \
		-phyType $val(netif) \
		-topoInstance $topo \
		-agentTrace OFF \
		-routerTrace ON \
		-macTrace ON \
		-movementTrace OFF \
		-channel $chan_

# Set propagation settings
if { $val(prop) == "Propagation/Ricean"} {
    set prop_inst [$ns_ set propInstance_]
    #$prop_inst MaxVelocity  2.5;
    #$prop_inst RiceanK        6;
    #$prop_inst LoadRiceFile  "rice_table.txt";

    $prop_inst MaxVelocity  $val(RiceanMaxVel);
    $prop_inst RiceanK      $val(RiceanK);
    $prop_inst LoadRiceFile  $val(RiceDataFile);
    $prop_inst RiceMaxNodeID $val(RiceMaxNodeID);

    ###############################################
    #   LOG the propagation information
    ## ###########################################
    if { $val(proplog) != "null" } {
	set prop_tracefd [open $val(proplog) w];
	set prop_log [new BaseTrace]
	$prop_log attach $prop_tracefd
	$prop_log set src_ 0
	$prop_inst tracetarget $prop_log
    }
}



# Create Nodes with defaults
for {set i 0} {$i < $val(nn)} {incr i} {
    set node_($i) [$ns_ node]
    $node_($i) random-motion 0
    $ns_ initial_node_pos $node_($i) 20
}

# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
$node_(0) set X_ 10.0
$node_(0) set Y_ 10.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 100.0
$node_(1) set Y_ 100.0
$node_(1) set Z_ 0.0

$node_(2) set X_ 200.0
$node_(2) set Y_ 100.0
$node_(2) set Z_ 0.0




# Now produce some simple node movements
# Node_(1) moves away from Node_(0)
$ns_ at 0.0 "$node_(0) setdest 1200.0 1200.0 5.0"

# Setup traffic flow between nodes

# Create connection
set udp_0_1 [$ns_ create-connection UDP $node_(0) Null $node_(1) 0]

set udp_2_1 [$ns_ create-connection UDP $node_(2) Null $node_(1) 0]

# Create traffic flow from 0 to 1
set cbr_0_1 [new Application/Traffic/CBR]
$cbr_0_1   set packetSize_ 1024
$cbr_0_1   set interval_ 1
$cbr_0_1   set random_ 1
$cbr_0_1   set maxpkts_ 10000
$cbr_0_1   attach-agent $udp_0_1

# Create traffic flow from 2 to 0
set cbr_2_1 [new Application/Traffic/CBR]
$cbr_2_1   set packetSize_ 256
$cbr_2_1   set interval_ 2
$cbr_2_1   set random_ 1
$cbr_2_1   set maxpkts_ 10000
$cbr_2_1   attach-agent $udp_2_1


$ns_ at 0.5000 "$cbr_0_1 start"
$ns_ at 2.5000 "$cbr_2_1 start"


#
# Tell nodes when the simulation ends
#
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $val(endtime) "$node_($i) reset";
}
$ns_ at $val(endtime) "stop"
$ns_ at $val(endtime) "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd
    $ns_ flush-trace
    close $tracefd
}

puts "Starting Simulation..."
$ns_ run
