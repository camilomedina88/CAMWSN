#       http://stackoverflow.com/questions/20937521/ns2-nam-output-for-smac-protocol-for-2-nodes-not-showing-cbr-transmission
set opt(chan)        Channel/WirelessChannel
set opt(prop)        Propagation/TwoRayGround
set opt(netif)       Phy/WirelessPhy
set opt(mac)         Mac/SMAC                   ;# MAC type
set opt(ifq)         Queue/DropTail/PriQueue
set opt(ll)          LL
set opt(ant)         Antenna/OmniAntenna

set opt(x)        800    ;# X dimension of the topography
set opt(y)        800        ;# Y dimension of the topography
set opt(cp)        "/root/ns-allinone-2.34/ns-2.34/tcl/mobility/scene/cbr-50-10-4-512"
set opt(sc)        "/root/ns-allinone-2.34/ns-2.34/tcl/mobility/scene/scen-670x670-50-600-20-0"
set opt(ifqlen)        50        ;# max packet in ifq
set opt(nn)        2        ;# number of nodes
set opt(seed)        0.0
set opt(stop)        700.0        ;# simulation time
set opt(tr)        Test.tr    ;# trace file
set opt(nam)       Test.nam    ;# animation file
set opt(rp)             AODV           ;# routing protocol script
set opt(lm)             "off"           ;# log movement
set opt(agent)          Agent/DSDV
set opt(energymodel)    EnergyModel     ;
#set opt(energymodel)    RadioModel     ;
set opt(radiomodel)        RadioModel     ;
set opt(initialenergy)  1000            ;# Initial energy in Joules
#set opt(logenergy)      "on"           ;# log energy every 150 seconds


Mac/SMAC set syncFlag_ 1

Mac/SMAC set dutyCycle_ 10

set ns_        [new Simulator]
set topo    [new Topography]
set tracefd    [open $opt(tr) w]
set namtrace    [open $opt(nam) w]
set prop    [new $opt(prop)]

$topo load_flatgrid $opt(x) $opt(y)
ns-random 1.0
$ns_ trace-all $tracefd
$ns_ namtrace-all-wireless $namtrace 500 500

#
# Create god
#
create-god $opt(nn)


#global node setting

$ns_ node-config -adhocRouting $opt(rp) \
         -llType $opt(ll) \
         -macType $opt(mac) \
         -ifqType $opt(ifq) \
         -ifqLen $opt(ifqlen) \
         -antType $opt(ant) \
         -propType $opt(prop) \
         -phyType $opt(netif) \
         -channelType $opt(chan) \
         -topoInstance $topo \
         -agentTrace ON \
         -routerTrace ON \
         -macTrace ON \
         -energyModel $opt(energymodel) \
         -idlePower 1.0 \
         -rxPower 1.0 \
         -txPower 1.0 \
         -sleepPower 0.001 \
         -transitionPower 0.2 \
         -transitionTime 0.005 \
         -initialEnergy $opt(initialenergy)



    $ns_ set WirelessNewTrace_ ON

    for {set i 0} {$i < $opt(nn) } {incr i} {
        set node_($i) [$ns_ node]    
        $node_($i) random-motion 0        ;# disable random motion

    }

set god_ [God instance]
$node_(0) set X_ 250.159448320886
$node_(0) set Y_ 320.107989080168
$node_(0) set Z_ 0.000000000000
$node_(1) set X_ 360.514473960930
$node_(1) set Y_ 400.755796386780
$node_(1) set Z_ 0.000000000000

for {set i 0} {$i < $opt(nn) } {incr i} {
    $ns_ initial_node_pos $node_($i) 30+i*100
}

set udp_(0) [new Agent/UDP]
$ns_ attach-agent $node_(0) $udp_(0)
set null_(0) [new Agent/Null]
$ns_ attach-agent $node_(1) $null_(0)
set cbr_(0) [new Application/Traffic/CBR]
$cbr_(0) set packetSize_ 512
$cbr_(0) set interval_ 10.0
$cbr_(0) set random_ 1
$cbr_(0) set maxpkts_ 50000
$cbr_(0) attach-agent $udp_(0)
$ns_ connect $udp_(0) $null_(0)



$ns_ at 1.00 "$cbr_(0) start"
#$ns_ at 177.000 "$node_(0) set ifqLen"


#
# Tell all the nodes when the simulation ends
#
for {set i 0} {$i < $opt(nn) } {incr i} {
    $ns_ at $opt(stop) "$node_($i) reset";
}
$ns_ at $opt(stop) "puts \"NS EXITING...\" ; $ns_ halt"

puts "Starting Simulation..."
$ns_ run
