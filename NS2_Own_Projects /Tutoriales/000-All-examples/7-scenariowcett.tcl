#   http://www.linuxquestions.org/questions/showthread.php?p=5060585#post5060585
#   @fattabiouni

set val(chan) Channel/WirelessChannel ; #Channel Type
set val(prop) Propagation/TwoRayGround ; #Radio propagation model
set val(netif) Phy/WirelessPhy ; #Network interface type
set val(ant) Antenna/OmniAntenna ; #Antenna model
set val(rp) WCETT ;#Routing Protocol
set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ifqlen) 50 ;# max packet in ifq
set val(mac) Mac/802_11 ;# MAC type
set val(ll) LL ;# link layer type
set val(nn) 8 ;# number of mobilenodes
set val(ni) 2 ;# number of interfaces
set val(channum) 2 ;# number of channels per radio
set val(cp) ./scenario2random.tcl ; # topology traffic file
set val(stop) 50 ;# simulation time
#set Pt_ 0.04 ;#power level
# ==================================================================
# Main Program
# ======================================================================


# Initialize Global Variables
set ns_ [new Simulator]
set tracefd [open scenario2.tr w]
$ns_ trace-all $tracefd

# set up topography object
set topo [new Topography]
$topo load_flatgrid 500 500

#create nam
set namtrace [open scenario2.nam w]
$ns_ namtrace-all-wireless $namtrace 500 500

# Create God
set god_ [create-god $val(nn)]
# configure node
Phy/WirelessPhy set Pt_ 0.33 ;#power level
$ns_ node-config -adhocRouting $val(rp) -llType $val(ll) -macType $val(mac) -ifqType $val(ifq) -ifqLen $val(ifqlen) -antType $val(ant) -propType $val(prop) -phyType $val(netif) -topoInstance $topo -agentTrace ON -routerTrace ON -macTrace ON -movementTrace ON

for {set i 0} { $i < $val(ni)} {incr i} {
set chan_($i) [new $val(chan)]
}


#configure for interface and channel

$ns_ node-config -ifNum $val(ni) -channel $chan_(0)


for {set i 0} {$i < $val(ni) } {incr i} {
$ns_ add-channel $i $chan_($i)
}

for {set i 0} {$i < $val(nn) } {incr i} {
set node_($i) [$ns_ node]
$node_($i) set recordIfall 1
$node_($i) random-motion 0 ;# disable random motion
}


source $val(cp) ; #source topology and traffic file generated by others

# Tell nodes when the simulation ends
for {set i 0} {$i < $val(nn) } {incr i} {
$ns_ at $val(stop).0 "$node_($i) reset";
}
$ns_ at $val(stop).0002 "puts \"NS EXITING...\" ; $ns_ halt "
proc stop {} {
global ns_ tracefd
$ns_ flush-trace
close $tracefd
exec nam scenario2.nam &
exit 0
}
puts "Starting Simulation..."
$ns_ run