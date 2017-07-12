set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/Ricean     ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             11                          ;# number of mobilenodes
set val(rp)             Mon_Ndp                       ;# routing protocolO
                                                                                

#Phy/WirelessPhy set CSThresh_ 1e-13
#Phy/WirelessPhy set RXThresh_ 1e-13

#Phy/WirelessPhy set Pt_ 0.4
Mac/802_11 set RTSThreshold_ 30000; #c supposé désactive RTS/CTS marche pas ?

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
$prop_inst MaxVelocity  2.5;  #Attention
$prop_inst RiceanK        6;
$prop_inst LoadRiceFile  "rice_table.txt";
                                                                                                                                      
 
for {set i 0} {$i < $val(nn) } {incr i} {
                set node_($i) [$ns node]
                $node_($i) random-motion 0
                $god_ new_node $node_($i)

}

 
 $node_(0) set X_ 0.0
 $node_(0) set Y_ 0.0
 $node_(0) set Z_ 0.0

 $node_(1) set X_ 300.0
 $node_(1) set Y_ 0.0
 $node_(1) set Z_ 0.0


 $node_(2) set X_ 500
 $node_(2) set Y_ 600.0
 $node_(2) set Z_ 0.0

 $node_(3) set X_ 500
 $node_(3) set Y_ 300.0
 $node_(3) set Z_ 0.0

 $node_(4) set X_ 900
 $node_(4) set Y_ 300.0
 $node_(4) set Z_ 0.0

 $node_(5) set X_ 1200
 $node_(5) set Y_ 300
 $node_(5) set Z_ 0

 $node_(10) set X_ 1000
 $node_(10) set Y_ 850
 $node_(10) set Z_ 0.0



 $node_(6) set X_ 1500
 $node_(6) set Y_ 300
 $node_(6) set Z_ 0.0

 $node_(7) set X_ 1800
 $node_(7) set Y_ 150
 $node_(7) set Z_ 0.0

 $node_(8) set X_ 2100
 $node_(8) set Y_ 150
 $node_(8) set Z_ 0.0

 $node_(9) set X_ 2200
 $node_(9) set Y_ 150
 $node_(9) set Z_ 0.0


#Open a trace file
set nf [open out.nam w]
$ns namtrace-all $nf


set tcp [new Agent/TCP]
set sink [new Agent/TCPSink]
$ns attach-agent $node_(0) $tcp
$ns attach-agent $node_(9) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 400.00 "$ftp start"



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
