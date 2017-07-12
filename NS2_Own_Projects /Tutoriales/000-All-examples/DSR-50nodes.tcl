
#      http://stackoverflow.com/questions/15599472/a-modified-dsr-code-in-ns2



set val(chan) Channel/WirelessChannel ;# channel type
set val(prop) Propagation/TwoRayGround ;# radio-propagation model
set val(netif) Phy/WirelessPhy ;# network interface type
set val(mac) Mac/802_11 ;# MAC type
#set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model
set val(ifqlen) 1000 ;# max packet in ifq
set val(rp) DSR ;# routing protocol
set val(seed) 1.0 ;#
if { $val(rp) == "DSR" } {
    set val(ifq) CMUPriQueue
} else {
    set val(ifq) Queue/DropTail/PriQueue
}
set val(nn) 50 ;# number of mobilenodes
set val(x) 1000 ;# X dimension of the topography
set val(y) 1000 ;# Y dimension of the topography
set val(stop) 900.0 ;# simulation time
#set val(path) /home/acharya/ns-allinone-2.35/ns-2.35
set val(cp) "./cbr-25-conf";
set val(sc) "./scen-25-conf1";
Agent/Null set sport_ 0
Agent/Null set dport_ 0
Agent/CBR set sport_ 0
Agent/CBR set dport_ 0

Antenna/OmniAntenna set X_ 0
Antenna/OmniAntenna set Y_ 0
Antenna/OmniAntenna set Z_ 1.5
Antenna/OmniAntenna set Gt_ 1.0
Antenna/OmniAntenna set Gr_ 1.0
set nominal_range 250.0
set configured_range -1.0
set configured_raw_bitrate -1.0
#Phy/WirelessPhy set bandwidth_ 11e6
#Mac/802_11 set basicRate_ 0
#Mac/802_11 set dataRate_ 0
#Mac/802_11 set bandwidth_ 11e6 ;
#Mac/802_11 set PLCPDataRate_ 11e6;
set ns_ [new Simulator]
set tracefd [open conf-out-tdsr.tr w]
$ns_ trace-all $tracefd
#$ns_ use-newtrace
# set the new channel interface.
#set chan [new $val(chan)]
#Open the nam file
set namtrace [open confout.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)
#Set up topography object to keep track of movement of nodes
set topo [new Topography]
#Provide topography object with coordinates
$topo load_flatgrid $val(x) $val(y)
proc finish {} {
    global ns f f0 f1 f2 f3 namtrace
    $ns flush-trace
    close $namtrace   
close $f0
    close $f1
close $f2
    close $f3
exec nam -r 5m 1_out.nam       
    # exec xgraph proj_out0.tr proj_out1.tr 
    # proj_out2.tr proj_out3.tr 
     &
exit 0
}
create-god $val(nn)
$ns_ node-config -adhocRouting $val(rp) \
    -llType $val(ll) \
    -macType $val(mac) \
    -ifqType $val(ifq) \
    -ifqLen $val(ifqlen) \
    -antType $val(ant) \
    -propType $val(prop) \
    -phyType $val(netif) \
    -channelType $val(chan)\
    -topoInstance $topo \
    -agentTrace ON \
    -routerTrace OFF \
    -macTrace OFF \
    -movementTrace ON
#-channel $chan
for {set i 0} {$i < $val(nn) } {incr i} {
    puts "i: $i"
    set node_($i) [$ns_ node]
    $node_($i) random-motion 0 ;# disable random motion
}
puts "Loading connection pattern..."
source $val(cp)
puts "Loading scenario file..."
source $val(sc)
for {set i 0} {$i < $val(nn)} {incr i} {
    $ns_ initial_node_pos $node_($i) 50
}
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $val(stop).0 "$node_($i) reset";
}
$ns_ at $val(stop).0002 "puts \"NS EXITING...\" ; $ns_ halt"
puts $tracefd "Confidant Wrote this!"
puts $tracefd "M 0.0 nn $val(nn) x $val(x) y $val(y) rp $val(rp)"
puts $tracefd "M 0.0 sc $val(sc) cp $val(cp) seed $val(seed)"
puts $tracefd "M 0.0 prop $val(prop) ant $val(ant)"
puts "Starting Simulation..."
$ns_ run