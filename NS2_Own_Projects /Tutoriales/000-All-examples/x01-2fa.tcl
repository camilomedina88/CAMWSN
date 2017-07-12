#
#      http://www.ensc.sfu.ca/~ljilja/ENSC833/News/Presentations/2fa.txt
#
# ======================================================================
# Define options
# ======================================================================

set opt(chan)   Channel/WirelessChannel        ;# channel type
set opt(prop)   Propagation/TwoRayGround       ;# radio-propagation model
set opt(netif)  Phy/WirelessPhy                ;# network interface type
set opt(mac)    Mac/802_11                     ;# MAC type
set opt(ifq)    Queue/DropTail/PriQueue        ;# interface queue type
set opt(ll)     LL                             ;# link layer type
set opt(ant)    Antenna/OmniAntenna            ;# antenna model
set opt(ifqlen)         50                     ;# max packet in ifq
set opt(nn)             1                      ;# number of mobilenodes
set opt(adhocRouting)   DSDV                   ;# routing protocol
set opt(threshold) 3.41828e-08				   ;# the distance of coverage 75m

set opt(cp)     ""                             ;# cp file not used
set opt(sc)     ""                             ;# node movement file. 

set opt(x)      10                            ;# x coordinate of topology
set opt(y)      50                            ;# y coordinate of topology
set opt(seed)   0.0                            ;# random seed
set opt(stop)   90                            ;# time to stop simulation

set opt(cbr-start)      5.0

set num_wired_nodes      1
#set num_bs_nodes       2  ; this is not really used here.

# ======================================================================

# check for boundary parameters and random seed
if { $opt(x) == 0 || $opt(y) == 0 } {
	puts "No X-Y boundary values given for wireless topology\n"
}
if {$opt(seed) > 0} {
	puts "Seeding Random number generator with $opt(seed)\n"
	ns-random $opt(seed)
}

# create simulator instance
set ns_   [new Simulator]

# set up for hierarchical routing
$ns_ node-config -addressType hierarchical

AddrParams set domain_num_ 4           ;# number of domains
lappend cluster_num 2 1 1 1             ;# number of clusters in each domain
AddrParams set cluster_num_ $cluster_num
lappend eilastlevel 1 1 2 1 1          ;# number of nodes in each cluster 
AddrParams set nodes_num_ $eilastlevel ;# of each domain

set tracefd  [open out.tr w]
set namtrace [open out.nam w]
$ns_ trace-all $tracefd
$ns_ namtrace-all-wireless $namtrace $opt(x) $opt(y)

# Create topography object
set topo   [new Topography]

# define topology
$topo load_flatgrid $opt(x) $opt(y)

# create God
#   4 for HA and FA, FA2 and CH
create-god [expr $opt(nn) + 4]

#create wired nodes
set temp {0.0.0}           ;# hierarchical addresses 
for {set i 0} {$i < $num_wired_nodes} {incr i} {
    set W($i) [$ns_ node [lindex $temp $i]] 
}

# Configure for ForeignAgent and HomeAgent nodes
$ns_ node-config -mobileIP ON \
                 -adhocRouting $opt(adhocRouting) \
                 -llType $opt(ll) \
                 -macType $opt(mac) \
                 -ifqType $opt(ifq) \
                 -ifqLen $opt(ifqlen) \
                 -antType $opt(ant) \
                 -propType $opt(prop) \
                 -phyType $opt(netif) \
                 -channelType $opt(chan) \
		 -topoInstance $topo \
                 -wiredRouting ON \
		 -agentTrace ON \
                 -routerTrace OFF \
                 -macTrace OFF 

Phy/WirelessPhy set RXThresh_ $opt(threshold)
#Phy/WirelessPhy set Pt_ 0.281838

# Create HA and FA, FA2
set HA [$ns_ node 1.0.0]
set FA [$ns_ node 2.0.0]
set FA2 [$ns_ node 3.0.0]
# Create CH
set CH [$ns_ node 0.1.0]

$HA random-motion 0
$FA random-motion 0
$FA2 random-motion 0
$CH random-motion 0

puts "HA id : [$HA id]"
puts "FA id : [$FA id]"
puts "FA2 id : [$FA2 id]"
puts "CH id : [$CH id]"

# Position (fixed) for base-station nodes (HA & FA).
$HA set X_ 200.000000000000
$HA set Y_ 30.000000000000
$HA set Z_ 0.000000000000

$FA set X_ 350.000000000000
$FA set Y_ 30.000000000000
$FA set Z_ 0.000000000000

$FA2 set X_ 150.000000000000
$FA2 set Y_ 30.000000000000
$FA2 set Z_ 0.000000000000

$CH set X_ 800.00000000000
$CH set Y_ 80.0000000000
$CH set Z_ 0.0000000000

# create a mobilenode that would be moving between HA and FA.
# note address of MH indicates its in the same domain as HA.
$ns_ node-config -wiredRouting OFF

set MH [$ns_ node 1.0.1]
puts "MH id : [$MH id]\n"
set node_(0) $MH
set HAaddress [AddrParams addr2id [$HA node-addr]]
[$MH set regagent_] set home_agent_ $HAaddress

# movement of the MH
$MH set X_ 150.000000000000
$MH set Y_ 275.000000000000
$MH set Z_ 0.000000000000

# MH starts to move towards FA
$ns_ at 10.000000000000 "$MH setdest 560.00000000000 275.000000000000 5.00000000000"

# create links between wired and BaseStation nodes
$ns_ duplex-link $CH $W(0) 5Mb 5ms DropTail
$ns_ duplex-link $W(0) $HA 5Mb 20ms DropTail
$ns_ duplex-link $W(0) $FA 5Mb 12ms DropTail
$ns_ duplex-link $W(0) $FA2 5Mb 5ms DropTail

# set the layout of links in NAM
$ns_ duplex-link-op $CH $W(0) orient down
$ns_ duplex-link-op $W(0) $HA orient left-down
$ns_ duplex-link-op $W(0) $FA orient down
$ns_ duplex-link-op $W(0) $FA2 orient right-down

# setup TCP connections between a wired node and the MobileHost

set tcp1 [new Agent/TCP]
#$tcp1 set class_ 2
set sink1 [new Agent/TCPSink]
$ns_ attach-agent $CH $tcp1
$ns_ attach-agent $MH $sink1
$ns_ connect $tcp1 $sink1
#set cbr [new Application/Traffic/CBR]
set cbr [new Application/FTP]
$cbr attach-agent $tcp1
$ns_ at $opt(cbr-start) "$cbr start"

# Define initial node position in nam

for {set i 0} {$i < $opt(nn)} {incr i} {

    # 20 defines the node size in nam, must adjust it according to your
    # scenario
    # The function must be called after mobility model is defined

    $ns_ initial_node_pos $node_($i) 20
}     

# Tell all nodes when the siulation ends
for {set i 0} {$i < $opt(nn) } {incr i} {
    $ns_ at $opt(stop).0 "$node_($i) reset";
}

$ns_ at $opt(stop).0 "$HA reset";
$ns_ at $opt(stop).0 "$FA reset";
$ns_ at $opt(stop).0 "$FA2 reset";
$ns_ at $opt(stop).0 "$CH reset";
$ns_ at $opt(stop).0 "$MH reset";

$ns_ at $opt(stop).0002 "puts \"NS EXITING...\" ; $ns_ halt"
$ns_ at $opt(stop).0001 "stop"
proc stop {} {
    global ns_ tracefd namtrace
    close $tracefd
    close $namtrace
}

# some useful headers for tracefile
puts $tracefd "M 0.0 nn $opt(nn) x $opt(x) y $opt(y) rp \
	$opt(adhocRouting)"
puts $tracefd "M 0.0 sc $opt(sc) cp $opt(cp) seed $opt(seed)"
puts $tracefd "M 0.0 prop $opt(prop) ant $opt(ant)"

puts "Starting Simulation..."
$ns_ run
