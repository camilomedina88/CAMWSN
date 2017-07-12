#        http://ns-2sourcecode.blogspot.dk/search/label/TCL%20script%20---%20adhoc.tcl
###      Performance Evaluation of DSDV, AODV, and DSR
####     TCL script --- adhoc.tcl
#########        
#########        $ ns AODV-DSR-DSDV-performance.tcl DSDV cbr-50-10-8 scene-50-0-20

if {$argc !=3} {
        puts "Usage: ns adhoc.tcl  Routing_Protocol Traffic_Pattern Scene_Pattern "
        puts "Example:ns adhoc.tcl AODV cbr-50-10-8 scene-50-0-20"
        exit
}

set par1 [lindex $argv 0]
set par2 [lindex $argv 1]
set par3 [lindex $argv 2]

set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagationmodel
set val(netif)            Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type

if { $par1=="DSR"} {
  set val(ifq)           CMUPriQueue
} else {
  set val(ifq)          Queue/DropTail/PriQueue    ;# interface queue type
}
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)          50                         ;# max packet in ifq
set val(rp)             $par1                       ;# routing protocol
set val(x)                   500
set val(y)                500
set val(seed)               0.0
set val(tr)                aodv.tr
set val(nn)             50
set val(cp)                $par2
set val(sc)        $par3
set val(stop)              100.0

set ns_              [new Simulator]

set tracefd     [open $val(tr) w]
$ns_ trace-all $tracefd
$ns_ use-newtrace

set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)

set god_ [create-god $val(nn)]

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
                         -macTrace OFF                                        

        for {set i 0} {$i < $val(nn) } {incr i} {
                set node_($i) [$ns_ node]
                $node_($i) random-motion 0            ;# disable random motion
        }

puts "Loading connection pattern..."
source $val(cp)

puts "Loading scenario file..."
source $val(sc)

for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ initial_node_pos $node_($i) 20
}

for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $val(stop).000000001 "$node_($i) reset";
}

$ns_ at $val(stop).000000001 "puts \"NS EXITING...\"; $ns_ halt"
puts "Start Simulation..."
$ns_ run
