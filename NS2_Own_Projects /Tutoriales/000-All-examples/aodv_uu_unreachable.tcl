# https://github.com/patsgit/Click-AODV/blob/master/aodvscripts/aodv_uu_unreachable.tcl



#
# Set some general simulation parameters
#

#
# Unity gain, omnidirectional antennas, centered 1.5m above each node.
# These values are lifted from the ns-2 sample files.
#
Antenna/OmniAntenna set X_ 0
Antenna/OmniAntenna set Y_ 0
Antenna/OmniAntenna set Z_ 1.5
Antenna/OmniAntenna set Gt_ 1.0
Antenna/OmniAntenna set Gr_ 1.0

#
# Initialize the SharedMedia interface with parameters to make
# it work like the 914MHz Lucent WaveLAN DSSS radio interface
# These are taken directly from the ns-2 sample files.
#
# capture threshold (db)
Phy/WirelessPhy set CPThresh_ 10.0
# carrier sense threshold (W)
Phy/WirelessPhy set CSThresh_ 1.559e-11
# receive power threshold (W)
Phy/WirelessPhy set RXThresh_ 7.33648e-10
Phy/WirelessPhy set Rb_ 2*1e6
# Pt -- transmitted signal power
Phy/WirelessPhy set Pt_ 1
# frequency
Phy/WirelessPhy set freq_ 914e+6
# L -- system loss (L >= 1)
Phy/WirelessPhy set L_ 1.0

#
# Set the size of the playing field and the topography.
#
set xsize 1000
set ysize 1000
set topo [new Topography]
$topo load_flatgrid $xsize $ysize

#
# The network channel, physical layer, MAC, propagation model,
# and antenna model are all standard ns-2.
#
set val(chan)	Channel/WirelessChannel
set netphy Phy/WirelessPhy
set netmac Mac/802_11
set netprop Propagation/TwoRayGround
set antenna Antenna/OmniAntenna

Mac/802_11 set dataRate_ 1e6

#
# We have to use a special queue and link layer. This is so that
# Click can have control over the network interface packet queue,
# which is vital if we want to play with, e.g. QoS algorithms.
#
set netifq Queue/ClickQueue
set netll LL/Ext
LL set delay_ 1ms

#
# These are pretty self-explanatory, just the number of nodes.
# and when we'll stop
#
set nodecount 2

set stoptime 300

#
# With nsclick, we have to worry about details like which network
# port to use for communication. This sets the default ports to 5000.
#
Agent/Null set sport_ 5000
Agent/Null set dport_ 5000

Agent/CBR set sport_ 5000
Agent/CBR set dport_ 5000

#
# Standard ns-2 stuff here - create the simulator object.
#
Simulator set MacTrace_ OFF
set ns_ [new Simulator]

#
# Create and activate trace files.
#
set tracefd [open "aodv_uu_unreachable.tr" w]
set namtrace [open "aodv_uu_unreachable.nam" w]
$ns_ trace-all $tracefd
$ns_ namtrace-all-wireless $namtrace $xsize $ysize
#$ns_ use-newtrace

# AODV trace support
set T [new Trace/Generic]
$T target [$ns_ set nullAgent_]
$T attach $tracefd

#
# Create the "god" object. This is another artifact of using
# the mobile node type. We have to have this even though
# we never use it.
#
set god_ [create-god $nodecount]

#
# Create a network Channel for the nodes to use. One channel
# per LAN. Also set the propagation model to be used.
#
set chan_1_ [new $val(chan)]
set chan_2_ [new $val(chan)]

#
# Tell the simulator to create AODVUU nodes.
#
 $ns_ node-config -adhocRouting AODVUU \
                     -llType LL \
                     -macType Mac/802_11 \
                     -ifqType Queue/DropTail/PriQueue \
                     -ifqLen 50 \
                     -antType Antenna/OmniAntenna \
                     -propType Propagation/TwoRayGround \
                     -phyType Phy/WirelessPhy \
                     -topoInstance $topo \
                     -agentTrace ON \
                     -routerTrace ON \
                     -movementTrace ON \
-channel $chan_1_

#
# Here is where we actually create all of the nodes.
#
for {set i 0} {$i < $nodecount} {incr i} {
set node_($i) [$ns_ node]
$node_($i) random-motion 0 ;# disable random motion
set r [$node_($i) set ragent_]
#AODV-UU configuration to confirm to situation possible in nsclick
$r set debug_ 1
$r set rt_log_interval_ 1000
$r set expanding_ring_search_ 1
$r set llfeedback_ 0
$r set local_repair_ 0
$r set log_to_file_ 1
$r set optimized_hellos_ 0
$r set ratelimit_ 0
# because it's a good thing
$r set rreq_gratuitous_ 1
$r set unidir_hack 0
$r set internet_gw_node_ 0

$node_($i) start
}


#
# Define node network traffic. There isn't a whole lot going on
# in this simple test case, we're just going to have the first node
# send packets to the last node, starting at 1 second, and ending at 10.
# There are Perl scripts available to automatically generate network
# traffic.
#


#
# Start transmitting at $startxmittime, $xmitrate packets per second.
#
set startxmittime 5
set xmitrate 4
set xmitinterval 0.1
set packetsize 67

#
# We use the "raw" packet type, which sends real packet data
# down the pipe.
#
set origin 0
set destination 1

set raw [new Agent/UDP]
$ns_ attach-agent $node_($origin) $raw

set cbr [new Application/Traffic/CBR]
$cbr set packetSize_ $packetsize
$cbr set interval_ $xmitinterval
$cbr set maxpkts_ [expr ($stoptime - $startxmittime)*$xmitrate]
$cbr attach-agent $raw

set null [new Agent/Null]
$ns_ attach-agent $node_($destination) $null

$ns_ connect $raw $null

$ns_ at $startxmittime "$cbr start"


$node_(0) set X_ 0
$node_(0) set Y_ 0
$node_(0) set Z_ 0

$node_(1) set X_ 1000
$node_(1) set Y_ 1000
$node_(1) set Z_ 1000


#
# Stop the simulation
#
$ns_ at $stoptime "puts \"NS EXITING...\" ; $ns_ halt"

#
# Let nam know that the simulation is done.
#
$ns_ at $stoptime	"$ns_ nam-end-wireless $stoptime"


puts "Starting Simulation..."
$ns_ run
