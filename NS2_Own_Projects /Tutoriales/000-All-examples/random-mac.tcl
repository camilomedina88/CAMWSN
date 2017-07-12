# https://github.com/jhshi/blog_source/blob/fa4bd3881a173928967b2a47108bc3a9cd7f999e/source/_posts/2013-12-13-simulate-random-mac-protocol-in-ns2-part-i.markdown
#  RMAC					RMAC
#

#	Simulator Parameters
#	First, let's define some parameters that we'll use later.

# ======================================================================
# Project parameters
# ======================================================================
set val(node_num)       101 
set val(duration)       10
set val(packetsize)     16
set val(repeatTx)       10
set val(interval)       0.02
set val(dimx)           50
set val(dimy)           50
set val(nam_file)       "jinghaos_pa3.nam"
set val(trace_file)     "jinghaos_pa3.tr"
set val(stats_file)     "jinghaos_pa3.stats"
set val(node_size)      5

# ======================================================================
# Node options
# ======================================================================
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/RMAC                 ;# MAC type
#set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             $val(node_num)                          ;# number of mobilenodes
set val(rp)             DSDV                       ;# routing protocol

#The first part is parameters from the project specification. Here we have 101 nodes 
#(100 source node plus 1 sink node), simulation duration, packet rate, terrain size, etc.

#The second part is for node configuration. Here we use WirelessChannel with DSDV routing protocol. 
#Note that for MAC protocol, we use Mac/RMAC, which stands for the random MAC protocol we'll add to NS2. 
#Of course, at this point, we don't have our RMAC protocol yet, 
#so you can substitute it with Mac/802_11 for the moment.

#Simulator Configuration
#We can obtain an instance of the simulator, and configure it this way.

# ======================================================================
# Global variables
# ======================================================================
set ns                      [new Simulator]
set tracefd                 [open $val(trace_file) w]
set nam                     [open $val(nam_file) w]
set stats                   [open $val(stats_file) w]
$ns namtrace-all-wireless   $nam $val(dimx) $val(dimy)
$ns trace-all               $tracefd
set topo                    [new Topography]
$topo load_flatgrid         $val(dimx) $val(dimy)

#Here we set up various global variables, including trace and stats file fd, and also the topology.

#The we configure the node.

#
# Create God
#
create-god $val(nn)

#Mac/RMAC set repeatTx_ $val(repeatTx)
#Mac/RMAC set interval_ $val(interval)

$ns node-config \
        -adhocRouting $val(rp) \
        -llType $val(ll) \
        -macType $val(mac) \
        -ifqType $val(ifq) \
        -ifqLen $val(ifqlen) \
        -antType $val(ant) \
        -propType $val(prop) \
        -phyType $val(netif) \
        -channelType $val(chan) \
        -topoInstance $topo \
        -agentTrace ON \
        -routerTrace ON \
        -macTrace ON \
        -movementTrace OFF          

### Here we first create an General Operations Director(GOD) object 
### to track the nodes' position in the topology grid. 
### Then we configure the nodes using the parameters we set up earlier.

### Note that, again at this point we don't have a RMAC protocol, 
### so we can just comment out the two lines that configure RMAC for now.

#	The Only Sink Node
#	Next, we're going to create the sink node.

#
# The only sink node
#
set sink_node [$ns node]
$sink_node random-motion 0
$sink_node set X_ [expr $val(dimx)/2]
$sink_node set Y_ [expr $val(dimy)/2]
$sink_node set Z_ 0
$ns initial_node_pos $sink_node $val(node_size)

set sink [new Agent/LossMonitor]
$ns attach-agent $sink_node $sink

#	Here we place the sink node at the center of the terrain, and attach an LossMonitor to it, 
#	so that we can get the packet statistics. Although the project specification requires us 
#	to get the packet statistics from the trace file, we can use the results from LossMonitor 
#	to verify that analysis results.

# The Source Nodes
# We need to create 100 source nodes, they should scatter the whole terrain randomly, 
# also, they should start transmission also randomly, which has two benefits:
#    	In practice, they're highly unlikable to synchronize perfectly, 
#	so we can simulator real world better.
#	By starting randomly, we're minimizing the chances they have collision.

#  So we'll have two random number generators, one for the position, and one for the starting time.

#
# Set up random number generator, to scatter the source nodes
#
set rng [new RNG]
$rng seed 0

set xrand [new RandomVariable/Uniform]
$xrand use-rng $rng
$xrand set min_ [expr -$val(dimx)/2]
$xrand set max_ [expr $val(dimx)/2]

set yrand [new RandomVariable/Uniform]
$yrand use-rng $rng
$yrand set min_ [expr -$val(dimy)/2]
$yrand set max_ [expr $val(dimy)/2]

set trand [new RandomVariable/Uniform]
$trand use-rng $rng
$trand set min_ 0
$trand set max_ $val(interval)

#	Also note that we set the seed to the Random Number Generator (RNG) to a constant value 0, 
#	so that in each simulation we can get the same results, easy for debug and also analyzing.

#	Then we create all the source nodes in a for loop.

#
# Create all the source nodes
#
for {set i 0} {$i < $val(nn)-1 } {incr i} {
    set src_node($i) [$ns node] 
    $src_node($i) random-motion 0
    set x [expr $val(dimx)/2 + [$xrand value]]
    set y [expr $val(dimx)/2 + [$xrand value]]
    $src_node($i) set X_ $x
    $src_node($i) set Y_ $y
    $src_node($i) set Z_ 0
    $ns initial_node_pos $src_node($i) $val(node_size)

    set udp($i) [new Agent/UDP]
    $udp($i) set class_ $i
    $ns attach-agent $src_node($i) $udp($i)
    $ns connect $udp($i) $sink

    set cbr($i) [new Application/Traffic/CBR]
    $cbr($i) set packet_size_ $val(packetsize)
    $cbr($i) set interval_ $val(interval)
    $cbr($i) attach-agent $udp($i)
    set start [$trand value]
    $ns at $start "$cbr($i) start" 
    $ns at $val(duration) "$cbr($i) stop"
}

#	Note that we use UDP here instead of TCP, since we don't need any reliable 
#	transfer or congestion control from up layer. 
#	Also, we attach an Constant Bit Generator (CBR) as the application.

# Simulator Control
#	We first define the actions to take when the simulator stops.

proc stop {} {
    global ns tracefd nam stats val sink

    set bytes [$sink set bytes_]
    set losts  [$sink set nlost_]
    set pkts [$sink set npkts_]
    puts $stats "bytes losts pkts"
    puts $stats "$bytes $losts $pkts"

    $ns flush-trace
    close $nam
    close $tracefd
    close $stats
}

# Here we first get the packet statistics from LossMonitor, and write them to the stats file, 
#  then we flush ns trace and close all the files.

# Finally, we start the simulator.

puts "Starting Simulation..."
$ns run
 