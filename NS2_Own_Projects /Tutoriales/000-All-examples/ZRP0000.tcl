############################################
#  http://www.linuxquestions.org/questions/programming-9/some-problems-when-using-ns2-930156/
############################################


set val(chan) Channel/WirelessChannel ;Channel Type
set val(prop) Propagation/TwoRayGround ;# radio-propagation model
set val(netif) Phy/WirelessPhy ;# network interface type
set val(mac) Mac/802_11 ;# MAC type
set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model
set val(ifqlen) 50 ;# max packet in ifq
set val(nn) 25 ;# number of mobilenodes
set val(rp) ZRP ;# routing protocol <—————————————-ZRP Agent
set val(x) 600 ;# X dimension of the topography
set val(y) 600 ;# Y dimension of the topography
set val(stop) 30.0 ;# simulation time
Agent/ZRP set radius_ 2 ;# Setting ZRP radius=2
# ======================================================================
# 2. Main Program
# ======================================================================
# 2.0 Removing Packet Headers[Adding only necessary for ZRP]...
remove-all-packet-headers
add-packet-header Common Flags IP RTP ARP GAF LL LRWPAN Mac ZRP
# 2.1 Initialize Global Variables...
# 2.1.1 create simulator instance
set ns_ [new Simulator]
# 2.1.2 Use New trace format...
$ns_ use-newtrace
set tracefd [open Grid_TC1.tr w]
$ns_ trace-all $tracefd
set namtrace [open Grid_TC1.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)
# 2.1.3 set up topography object
set topo [new Topography]
# define topology
$topo load_flatgrid $val(x) $val(y)
# 2.1.4 Create God
set god_ [create-god $val(nn)]
# 2.2 All About Nodes [Node Config + Location Info]...
# 2.2.1 configure node, please note the change below. ;
# [Originaly macTrace=ON]

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
-macTrace OFF \
-movementTrace OFF \
# 2.2.2 Create the specified number of nodes [$val(nn)] and "attach" them to the channel.
for {set i 0} {$i < $val(nn) } {incr i} {
set node_($i) [$ns_ node]
$node_($i) random-motion 0 ;# disable random motion
}
# 2.2.3 Node locations
for {set i 0} {$i < 5} {incr i} {
for {set j 0} {$j < 5} {incr j} {
set id [expr $i*5 + $j]
set X [expr $j*140+20]
set Y [expr $i*140+20]
$node_($id) set X_ [expr $j*140+20]
$node_($id) set Y_ [expr $i*140+20]
$node_($id) set Z_ 0.0
puts "CO-ORD of Node $id = ($X, $Y)"
}
}
# 2.3 Traffic Profile [Only One connection]...
# You can define traffic profile here
# 2.4 Events...
# 2.4.1 Tell nodes when the simulation ends
for {set i 0} {$i < $val(nn) } {incr i} {
$ns_ at $val(stop).0 "$node_($i) reset";
}
$ns_ at $val(stop).0002 "puts n"NS EXITING...n" ; $ns_ halt"
puts $tracefd "M 0.0 nn $val(nn) x $val(x) y $val(y) rp $val(rp)"
puts $tracefd "M 0.0 prop $val(prop) ant $val(ant)"
proc stop {} {
global ns_ tracefd
$ns_ flush-trace
close $tracefd
}
puts "Starting Simulation..."
$ns_ run
