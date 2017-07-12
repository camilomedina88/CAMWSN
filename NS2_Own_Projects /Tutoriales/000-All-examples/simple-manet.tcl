#
#          http://www.isi.edu/nsnam/archive/ns-users/webarch/2001/msg04616.html
#
# simple-manet.tcl
# A simple example for wireless simulation
# usage: ns simple_manet.tcl manet <routing protocol name>
# - Joe Macker

# ======================================================================
# Define options
# ======================================================================
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             10                          ;# number of mobilenodes
set val(rp)             AODV                     ;# routing protocol
set val(x)              500
set val(y)              500

proc usage {} {
    puts {cbr_mobile: Usage> ns simple_manet.tcl [manet <DSR,AODV,TORA,OLSR,NRLOLSR,others> }
    puts {PARAMETERS NEED NOT BE SPECIFIED... DEFAULTS WILL BE USED}
    exit
} 

set state flag
foreach arg $argv {
        switch -- $state {
                flag {
                switch -- $arg {
                        manet   {set state manet}
                        help    {usage}
                        default {error "unknown flag $arg"}
                }
                }
                manet   {set state flag; set val(rp) $arg}
        }       
}

puts "this is a basic manet test program"
# =====================================================================
# Main Program
# ======================================================================

#
# Initialize Global Variables
#

set ns_         [new Simulator]
set tracefd     [open simple_manet.tr w]
$ns_ trace-all $tracefd

set namtrace [open simple_manet.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

# set up topography object
set topo       [new Topography]

$topo load_flatgrid 500 500

#
# Create God
#
create-god $val(nn)

#
#  Create the specified number of mobilenodes [$val(nn)] and "attach" them
#  to the channel. 
#  Here two nodes are created : node(0) and node(1)

# configure node
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
                         -agentTrace ON \
                         -routerTrace ON \
                         -macTrace OFF \
                         -movementTrace ON                      

        for {set i 0} {$i < $val(nn) } {incr i} {
                set node_($i) [$ns_ node]       
                $node_($i) random-motion 1
                                ;# enable random motion
        }
        for {set i 0} {$i < $val(nn) } {incr i} {
                $ns_ initial_node_pos $node_($i) 25             ;# set size of nodes
        }
#
# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
#
$node_(0) set X_ 50.0
$node_(0) set Y_ 90.0
$node_(1) set X_ 450.0
$node_(1) set Y_ 410.0
for {set i 2} {$i < $val(nn) } {incr i} {
                $node_($i) set X_ 250.0
                $node_($i) set Y_ 250.0
                $node_($i) set Z_ 0.0
                }
#
# Now produce some simple node movements
# Node_(1) starts to move towards node_(0)
#
$ns_ at 0.1 "$node_(1) setdest 10.0 460.0 5.0"
$ns_ at 0.1 "$node_(0) setdest 420.0 100.0 5.0"
$ns_ at 0.1 "$node_(2) setdest 10.0 260.0 10.0"
$ns_ at 0.1 "$node_(3) setdest 50.0 280.0 5.0"
$ns_ at 0.1 "$node_(4) setdest 180.0 230.0 20.0"
$ns_ at 0.1 "$node_(5) setdest 0.1 200.0 10.0"
$ns_ at 0.1 "$node_(6) setdest 230.0 250.0 3.0"
$ns_ at 0.1 "$node_(7) setdest 420.0 250.0 5.0"
$ns_ at 0.1 "$node_(8) setdest 350.0 290.0 20.0"
$ns_ at 0.1 "$node_(9) setdest 490.0 189.0 5.0"

# Node_(1) then starts to move away from node_(0)
$ns_ at 100.0 "$node_(0) setdest 2.0 450.0 25.0" 
$ns_ at 100.0 "$node_(1) setdest 490.0 40.0 15.0"

#Set cbr agent
set udp1 [new Agent/UDP]
$ns_ attach-agent $node_(1) $udp1
$udp1 set class_ 0
#$udp1 set fid_ 2
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1
$cbr1 set packetSize_ 1000
$cbr1 set interval_ 0.02

set null1 [new Agent/Null]
$ns_ attach-agent $node_(0) $null1

$ns_ connect $udp1 $null1
$ns_ at 2.0 "$cbr1 start"

$ns_ at 160.0 "stop"
$ns_ at 160.01 "puts \"NS EXITING...\" ; $ns_ halt"

proc stop {} {
    global ns_ tracefd namtrace
    $ns_ flush-trace
    close $tracefd
    close $namtrace
}

   
puts "Starting Simulation..."
$ns_ run
