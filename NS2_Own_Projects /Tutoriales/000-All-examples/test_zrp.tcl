# 
# http://www.linuxquestions.org/questions/ubuntu-63/how-to-install-zrp-zone-routing-protocol-patch-in-ns-2-34-a-905025/page2.html
# ( post # 19 )



#"Agent/ZRP set radius_ 2"
set val(chan) Channel/WirelessChannel;#
set val(prop) Propagation/TwoRayGround;#
set val(netif) Phy/WirelessPhy;#
set val(mac) Mac/802_11;#
set val(ifq) Queue/DropTail/PriQueue;#
set val(ll) LL;#
set val(ant) Antenna/OmniAntenna;#
set val(ifqlen) 50;#
set val(nn) 25;#
set val(rp) ZRP;#
set val(x) 600;#
set val(y) 600;#
set val(stop) 30.0;#
Agent/ZRP set radius_ 2;#

remove-all-packet-headers
add-packet-header Common Flags IP RTP ARP GAF LL LRWPAN Mac ZRP
set ns_ [new Simulator]
$ns_ use-newtrace
set tracefd [open Grid-TCl.tr w]
$ns_ trace-all $tracefd
set namtrace [open Grid-TCl.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)
set god_ [create-god $val(nn)]

$ns_ node-config -adhocRouting $val(rp)\
                    -llType $val(ll)\
                    -macType $val(mac)\
                    -ifqLen $val(ifqlen)\
                    -ifqType $val(ifq)\
                    -antType $val(ant)\
                    -propType $val(prop)\
                    -phyType $val(netif)\
                    -channelType $val(chan)\
                    -topoInstance $topo\
                    -agentTrace ON\
                    -routerTrace ON\
                    -macTrace OFF\
                    -movementTrace OFF

for {set i 0} {$i<$val(nn)} {incr i} {
        set node_($i) [$ns_ node]
        $node_($i) random-motion 0;#
}

for {set i 0} {$i<5} {incr i} {
        for {set j 0} {$j<5} {incr j} {
                set id [expr $i*5+$j]
                set X [expr $j*140+20]
                set Y [expr $i*140+20]
                $node_($id) set X_ [expr $j*140+20]
                $node_($id) set Y_ [expr $i*140+20]
                $node_($id) set Z_ 0.0
                puts "CO-ORD of Node $id=($X,$Y)"
        }
}    

for {set i 0} {$i<$val(nn)} {incr i} {
        $ns_ at $val(stop).0 "$node_($i) reset"
}

$ns_ at $val(stop).0002 "puts \"NS EXITING...\";$ns_ halt"
puts $tracefd "M 0.0 nn $val(nn) x $val(x) y $val(y) rp $val(rp)"
puts $tracefd "M 0.0 prop $val(prop) ant $val(ant)"
proc stop {} {
        global ns_ tracefd
        $ns_ flush-trace
        close $tracefd
}
puts "Starting Simulation..."
$ns_ run
