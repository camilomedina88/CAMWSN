#    https://groups.google.com/forum/?fromgroups#!topic/ns-users/EqpMo2-Mglg , usage :
if {$argc < 5} {
    puts stderr "usage: ns $argv0 <scenario> <connectivity> <mode> <number_of_nodes> <propagation> "
    puts stderr "       argv0 (example): main.tcl"
    puts stderr "       scenario (example): cbr, expo..."
    puts stderr "       connectivity (example): scen, scen-moibile...."
    puts stderr "       mode: "
    puts stderr "          0 --> RBAR"
    puts stderr "          1 --> OAR"
    puts stderr "          2 --> single-rate 802.11"
    puts stderr "       propagation: "
    puts stderr "             1 ---> Ricean "
    puts stderr "             0 ---> TwoRayGround "
    exit 1;
}

set scenario [lindex $argv 0]
set connectivity [lindex $argv 1]
puts "% scenario $scenario"
puts "% connectivity $connectivity"

# Mode
set mode [lindex $argv 2]

# Number of Nodes
set val(nn) [lindex $argv 3]
puts "% Number of nodes: $val(nn)"

# Propagation Model
set prop [lindex $argv 4]
if {$prop == 0} {
    puts "% Propagation Model: TwoRayGround"
    set val(prop)       Propagation/TwoRayGround
} elseif {$prop == 1} {
    puts "% Propagation Model: Ricean"
    set val(prop)       Propagation/Ricean
}

# ======================================================================
# Define options
# ======================================================================
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model

#numerical options
set val(ifqlen)         50                       ;# max packet in ifq
set val(rp)             DSDV                       ;# routing protocol
set stopSource          24.000                     ; 
set val(stop)           24.000                     ;
set val(trace)          orig.tr                    ;
                  
# ======================================================================
# Main Program
# ======================================================================

Mac/802_11 set bandwidth_ 2e6
Mac/802_11 set mode_ $mode

# To enable Null routing
Agent/DSDV set dsdv_active 0
Agent/DSDV set num_nodes $val(nn)

# removing double ring
Phy/WirelessPhy set CSThresh_ 3.652e-10

# Initialize Global Variables
set ns_		[new Simulator]
ns-random 0
set tracefd     [open $val(trace) w]
$ns_ trace-all $tracefd

# set up topography object
set topo       [new Topography]
$topo load_flatgrid 500 500

if { $val(rp) == "DSR" } {
set val(ifq)            CMUPriQueue
} else {
set val(ifq)            Queue/DropTail/PriQueue
} 


# Create God
create-god $val(nn)

# Create channel #1 
set chan_1_ [new $val(chan)]

# configure node
$ns_ node-config -adhocRouting $val(rp) \
	-llType $val(ll) \
	-macType $val(mac) \
	-ifqType $val(ifq) \
	-ifqLen $val(ifqlen) \
	-antType $val(ant) \
	-propType $val(prop) \
	-phyType $val(netif) \
	-topoInstance $topo \
	-agentTrace ON \
	-routerTrace OFF \
	-macTrace ON \
	-movementTrace ON \
	-channel $chan_1_

# create nodes			 
for {set i 0} {$i < $val(nn) } {incr i} {
    set node_($i) [$ns_ node]	
    $node_($i) random-motion 0; # disable random motion
}

# load the traffic pattern file
# create flows between nodes
source $connectivity
source $scenario.tcl

# Configuring the Ricean Channel
if {$prop == 1} {
    set prop_inst [$ns_ set propInstance_]
    $prop_inst MaxVelocity  2.5;
    $prop_inst RiceanK        0;
    $prop_inst LoadRiceFile  "./rice_table.txt";

###############################################
#   LOG the propagation information
#  To disable logging, simply comment this section
#  out
## ###########################################
set prop_tracefd [open proptrace.tr w];
set prop_log [new Trace/Generic]
$prop_log target [$ns_ set nullAgent_]
$prop_log attach $prop_tracefd
$prop_log set src_ 0
$prop_inst tracetarget $prop_log
##############################################
}

# Tell nodes when the simulation ends
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $val(stop) "$node_($i) reset";
}


$ns_ at $val(stop) "stop"
$ns_ at [expr $val(stop) + .01] "$ns_ halt"

# procedure to track the position of nodes
proc track {node} {
    global ns_ 
    set now [$ns_ now]
    puts "$now [$node set X_]"
    $ns_ at [expr $now + .1] "track $node"
}

proc stop {} {
    global ns_ tracefd 
    $ns_ flush-trace
    close $tracefd
}

$ns_ run
