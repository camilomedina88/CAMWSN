# Carlos Miguel Tavares http://mailman.isi.edu/pipermail/ns-users/2003-April/031621.html
# "" I have set up a super-simple scenario with just 2 nodes. One FTP 
# transfer is being performed between them.
#
# I found that the behavior with AODV or AODV-UU with both ns2.1b9a and 
# ns2.26 is quite poor (I haven't tested previous versions), with 
# consecutive connexion breaks lasting 1 second after aproximately 1.2 
# seconds of successfull transmission.
#
# It can be clearly seen with nam by looking at sent and lost packets. 
# Other reactive protocols did not show this behavior.
#
# I attach the code I used for anyone who wishes to test it. The problem 
# occurs at both 1 and 11 Mbps. ""
########################################################################



# ======================================================================
# Define options
# ======================================================================

set val(chan)       Channel/WirelessChannel
set val(prop)       Propagation/TwoRayGround
set val(netif)      Phy/WirelessPhy
set val(mac)        Mac/802_11
set val(ifq)        Queue/DropTail/PriQueue
set val(ll)         LL
set val(ant)        Antenna/OmniAntenna
set val(x)              500   ;# X dimension of the topography
set val(y)              500   ;# Y dimension of the topography
set val(ifqlen)         50            ;# max packet in ifq
set val(seed)           1.0
set val(rp)   AODVUU  ;#one of AODV, AODVUU, DSR, TORA, OLSR(v7)
set val(nn)             2             ;# how many nodes are simulated 
set val(cp)             "none" ;#padron de conexiones
set val(sc)             "none"; #escenario de trafico
set val(stop)           20          ;# simulation time (300)
set val(trfile)         out.tr
set val(namfile)        out.nam
set val(random_mobility)   FALSE
set val(bw)             1Mb

# =====================================================================
# Main Program
# ======================================================================




# create simulator instance

set ns_		[new Simulator]

#trace file format

$ns_ use-newtrace

# setup topography object

set topo	[new Topography]

# create trace object for ns and nam

set tracefd	[open $val(trfile) w]
set namtrace    [open $val(namfile) w]

$ns_ trace-all $tracefd
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

# define topology
$topo load_flatgrid $val(x) $val(y)

#
# Create God
#
set god_ [create-god $val(nn)]

#
# define how node should be created
#

#global node setting

$ns_ node-config -adhocRouting $val(rp) \
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
                 -movementTrace  OFF


#
#  Create the specified number of nodes [$val(nn)] and "attach" them
#  to the channel. 

for {set i 0} {$i < $val(nn) } {incr i} {
	set node_($i) [$ns_ node]		
}


$node_(0) set X_ 100.0
$node_(0) set Y_ 250.0
$node_(0) set Z_ 0.000000000000
$node_(1) set X_ 250.0
$node_(1) set Y_ 250.0
$node_(1) set Z_ 0.000000000000


set tcp_(0) [$ns_ create-connection  TCP $node_(0) TCPSink $node_(1) 0]
$tcp_(0) set window_ 32
$tcp_(0) set packetSize_ 512
set ftp_(0) [$tcp_(0) attach-source FTP]
$ns_ at 0.0 "$ftp_(0) start"




# Define node initial position in nam

for {set i 0} {$i < $val(nn)} {incr i} {

    # 20 defines the node size in nam, must adjust it according to your scenario
    # The function must be called after mobility model is defined
    
    $ns_ initial_node_pos $node_($i) 20
}


#
# Tell nodes when the simulation ends
#
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $val(stop).0 "$node_($i) reset";
}

$ns_ at  $val(stop).000001 "puts \"NS EXITING...\" ; $ns_ halt"

puts "Starting Simulation..."
$ns_ run
