# http://www.linuxquestions.org/questions/linux-newbie-8/blackhole-in-aodv-error-4175459161/



# ======================================================================
# Default Script Options
set val(x) 800 ; # X dimension of the topography
set val(y) 800 ; # Y dimension of the topography
set val(nn) 50 ; # how many nodes
set val(stop) 200.0 ; # simulation time
set val(routing) blackholeAODV

set ns_ [new Simulator]
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)
set tracefd [open out.tr w]
$ns_ trace-all $tracefd
$ns_ use-newtrace
set namtrace [open out.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

set god_ [create-god $val(nn)]
$ns_ node-config -adhocRouting $val(routing) \
-llType LL \
-macType Mac/802_11 \
-ifqType Queue/DropTail/PriQueue \
-ifqLen 50 \
-antType Antenna/OmniAntenna \
-propType Propagation/TwoRayGround \
-phyType Phy/WirelessPhy \
-channelType Channel/WirelessChannel \
-topoInstance $topo \
-agentTrace ON \
-routerTrace ON \
-macTrace OFF

# ======================================================================

set opt(ragent) Agent/rtProto/blackholeAODV
set opt(pos) NONE

if { $opt(pos) != "NONE" } {
puts "*** WARNING: blackholeAODV using $opt(pos) position configuration..."
}

# ======================================================================
Agent instproc init args {
$self next $args
}
Agent/rtProto instproc init args {
$self next $args
}
Agent/rtProto/blackholeAODV instproc init args {
$self next $args
}

Agent/rtProto/blackholeAODV set sport_ 0
Agent/rtProto/" set dport_ 0

# ======================================================================

proc create-routing-agent { node id } {
global ns_ ragent_ tracefd opt

#
# Create the Routing Agent and attach it to port 255.
#
set ragent_($id) [new $opt(ragent) $id]
set ragent $ragent_($id)
$node attach $ragent 255

$ragent if-queue [$node set ifq_(0)] ;# ifq between LL and MAC
$ns_ at 0.$id "$ragent_($id) start" ;# start BEACON/HELLO Messages

#
# Drop Target (always on regardless of other tracing)
#
set drpT [cmu-trace Drop "RTR" $node]
$ragent drop-target $drpT

#
# Log Target
#
set T [new Trace/Generic]
$T target [$ns_ set nullAgent_]
$T attach $tracefd
$T set src_ $id
$ragent log-target $T
}


proc create-mobile-node { id } {
global ns_ chan prop topo tracefd opt node_
global chan prop tracefd topo opt

set node_($id) [new MobileNode]

set node $node_($id)
$node random-motion 0 ;# disable random motion
$node topography $topo

#
# This Trace Target is used to log changes in direction
# and velocity for the mobile node.
#
set T [new Trace/Generic]
$T target [$ns_ set nullAgent_]
$T attach $tracefd
$T set src_ $id
$node log-target $T

$node add-interface $chan $prop $opt(ll) $opt(mac) \
$opt(ifq) $opt(ifqlen) $opt(netif) $opt(ant)

#
# Create a Routing Agent for the Node
#
create-routing-agent $node $id

# ============================================================

if { $opt(pos) == "Box" } {

set spacing 200
set maxrow 3
set col [expr ($id - 1) % $maxrow]
set row [expr ($id - 1) / $maxrow]
$node set X_ [expr $col * $spacing]
$node set Y_ [expr $row * $spacing]
$node set Z_ 0.0
$node set speed_ 0.0

$ns_ at 0.0 "$node_($id) start"

} elseif { $opt(pos) == "Random" } {

$node random-motion 1

$ns_ at 0.0 "$node_($id) start"
}

}
