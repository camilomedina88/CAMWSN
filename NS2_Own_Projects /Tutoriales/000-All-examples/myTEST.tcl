set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/Ricean     ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             20                          ;# number of mobilenodes
set val(halfnn)         10
set val(rp)             Mon_Ndp                       ;# routing protocol
                                                                                

#Phy/WirelessPhy set CSThresh_ 1e-13
#Phy/WirelessPhy set RXThresh_ 1e-13

#Phy/WirelessPhy set Pt_ 0.4
Mac/802_11 set RTSThreshold_ 3000; #c supposé désactive RTS/CTS marche pas ?

#Create a simulator object
set ns [new Simulator]
set tracefd [open mes_traces.tr w]
$ns trace-all $tracefd

set topo       [new Topography]
$topo load_flatgrid 1000000 1000000

set god_ [create-god $val(nn)] 
$god_ on 

$ns node-config -adhocRouting $val(rp) \
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
                         -routerTrace OFF \
                         -macTrace OFF \
                         -movementTrace OFF
                         
set prop_inst [$ns set propInstance_]
$prop_inst MaxVelocity  2.5;
$prop_inst RiceanK        6;
$prop_inst LoadRiceFile  "rice_table.txt";
                                                                                                                                      
for {set i 0} {$i < $val(halfnn) } {incr i} {
                set node_($i) [$ns node]
                $node_($i) random-motion 0 
		$god_ new_node $node_($i)      
		$node_($i) set X_ [expr (($i)*600.0)]
                $node_($i) set Y_ 0.0
                $node_($i) set Z_ 0.0
 
}
for {set i 10} {$i < $val(nn) } {incr i} {
                set node_($i) [$ns node]
                $node_($i) random-motion 0
                $god_ new_node $node_($i)
                $node_($i) set X_ [expr (($i-10)*600.0)]
                $node_($i) set Y_ 400.0
                $node_($i) set Z_ 0.0

}


#Open a trace file
set nf [open out.nam w]
$ns namtrace-all $nf



set tcp [new Agent/TCP]
set sink [new Agent/TCPSink]
$ns attach-agent $node_(0) $tcp
$ns attach-agent $node_(19) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp

set tcp2 [new Agent/TCP]
set sink2 [new Agent/TCPSink]
$ns attach-agent $node_(18) $tcp2
$ns attach-agent $node_(1) $sink2
$ns connect $tcp2 $sink2
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2

$ns at 700.00 "$ftp start"
$ns at 700.00 "$ftp2 start"



#Define a 'finish' procedure
proc finish {} {
        #global ns nf
 #       $ns flush-trace
 #       close $nf
#        exec nam out.nam &
        exit 0
}



$ns at 1000.0 "finish"
#
#Run the simulation
$ns run
