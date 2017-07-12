#      http://naveenshanmugam.blogspot.dk/2014/02/handoff-in-ns2-handoff-between-wlan-and.html
#
#   #    UMTS
#
remove-all-packet-headers  
 add-packet-header MPEG4 MAC_HS RLC LL Mac RTP TCP IP Common Flags  
  set val(x)      1000  
  set val(y)      1000  
 set ns [new Simulator]  
 global ns  
 set f [open out.tr w]  
 $ns trace-all $f  
 set namtrace [open log.nam w]  
 $ns namtrace-all-wireless $namtrace $val(x) $val(y)  
 #set f0 [open proj_simple.tr w]  
 proc finish {} {  
   global ns  
   global f namtrace  
   $ns flush-trace  
   close $f   
  close $namtrace  
   puts " Simulation ended."  
     exec nam log.nam &  
     exit 0  
     exit 0  
 }  
 #for {set i 0} {$i < $val(nn)} {incr i} {  
  #    $ns initial_node_pos $n($i) 30+i*100  
 #}  
 #$ns at 0.0 "$n(0) setdest 76.0 224.0 30000.0"  
 #$ns at 0.0 "$n(0) label node_0"  
 #-----------------------------------------------------------------------------------------------------------------------------  
 $ns set debug_ 0  
 $ns set hsdschEnabled_ 1  
 $ns set hsdsch_rlc_set_ 0  
 $ns set hsdsch_rlc_nif_ 0  
 $ns node-config -UmtsNodeType rnc  
 # Node address is 0.  
 set rnc [$ns create-Umtsnode]  
 $ns node-config -UmtsNodeType bs \
           -downlinkBW 32kbs \
           -downlinkTTI 10ms \
           -uplinkBW 32kbs \
           -uplinkTTI 10ms \
    -hs_downlinkTTI 2ms \
    -hs_downlinkBW 64kbs \
 # Node address is 1.  
 set bs [$ns create-Umtsnode]  
 $ns setup-Iub $bs $rnc 622Mbit 622Mbit 15ms 15ms DummyDropTail 2000  
 $ns node-config -UmtsNodeType ue \
           -baseStation $bs \
           -radioNetworkController $rnc  
 # Node address for ue1 and ue2 is 2 and 3, respectively.  
 set ue1 [$ns create-Umtsnode]  
 set ue2 [$ns create-Umtsnode]  
 # Node address for sgsn0 and ggsn0 is 4 and 5, respectively.  
 set sgsn0 [$ns node]  
 set ggsn0 [$ns node]  
 # Node address for node1 and node2 is 6 and 7, respectively.  
 set node1 [$ns node]  
 set node2 [$ns node]  
 $ns duplex-link $rnc $sgsn0 622Mbit 0.4ms DropTail 1000  
 $ns duplex-link $sgsn0 $ggsn0 622MBit 10ms DropTail 1000  
 $ns duplex-link $ggsn0 $node1 10MBit 15ms DropTail 1000  
 $ns duplex-link $node1 $node2 10MBit 35ms DropTail 1000  
 $rnc add-gateway $sgsn0  
 set tcp0 [new Agent/UDP]  
 $tcp0 set fid_ 0  
 $tcp0 set prio_ 2  
 $ns at 0.0 "$node1 label Node1"  
 $ns at 0.0 "$node2 label Node2"  
 $ns at 0.0 "$ue1 label Umtsnode1"  
 $ns at 0.0 "$ue2 label Umtsnode2"  
 $ns at 0.0 "$bs label Base_Station"  
 $ns at 0.0 "$bs label Base_Station"  
 $ns at 0.0 "$sgsn0 label Node_1"  
 $ns at 0.0 "$ggsn0 label Node_2"  
 $ns at 0.0 "$rnc label Node_0"  
 $node1 set X_ 119.0  
 $node1 set Y_ 38.0  
 $node1 set Z_ 0.0  
 $bs set X_ 31.0  
 $bs set Y_ 35.0  
 $bs set Z_ 0.0  
 $node2 set X_ 138.0  
 $node2 set Y_ 3.0  
 $node2 set Z_ 0.0  
 $ue1 set X_ 7.0  
 $ue1 set Y_ 72.0  
 $ue1 set Z_ 0.0  
 $ue2 set X_ 66.0  
 $ue2 set Y_ 77.0  
 $ue2 set Z_ 0.0  
 $sgsn0 set X_ 71.0  
 $sgsn0 set Y_ 37.0  
 $sgsn0 set Z_ 0.0  
 $ggsn0 set X_ 101.0  
 $ggsn0 set Y_ 2.0  
 $ggsn0 set Z_ 0.0  
 $rnc set X_ 58.0  
 $rnc set Y_ 4.0  
 $rnc set Z_ 0.0  
 $ns attach-agent $rnc $tcp0  
 set ftp0 [new Application/Traffic/CBR]  
 $ftp0 attach-agent $tcp0  
 set sink0 [new Agent/Null]  
 $sink0 set fid_ 0  
 $ns attach-agent $ue1 $sink0  
 $ns connect $tcp0 $sink0  
 $ns node-config -llType UMTS/RLC/UM \
           -downlinkBW 64kbs \
           -uplinkBW 64kbs \
           -downlinkTTI 20ms \
           -uplinkTTI 20ms \
    -hs_downlinkTTI 2ms \
    -hs_downlinkBW 64kbs
 $ns create-hsdsch $ue1 $sink0  
 $bs setErrorTrace 0 "./idealtrace"  
 $bs setErrorTrace 1 "./idealtrace"  
 $bs loadSnrBlerMatrix "./SNRBLERMatrix"  
 #set dch0 [$ns create-dch $ue1 $sink0]  
 $ue1 trace-inlink $f 1  
 $bs trace-outlink $f 1  
 #$rnc trace-inlink-tcp $f 0  
 # tracing for all hsdpa traffic in downtarget  
 $rnc trace-inlink-tcp $f 0  
 $bs trace-outlink $f 2  
 # per UE  
 $ue1 trace-inlink $f 2  
 $ue1 trace-outlink $f 3  
 $bs trace-inlink $f 3  
 $ue1 trace-inlink-tcp $f 2  
 #______________________________________________________________  
  set val(chan)     Channel/WirelessChannel ;# channel type  
  set val(prop)     Propagation/TwoRayGround ;# radio-propagation model  
  set val(ant)     Antenna/OmniAntenna   ;# Antenna type  
  set val(ll)      LL            ;# Link layer type  
  set val(ifq)     Queue/DropTail/PriQueue ;# Interface queue type  
  set val(ifqlen)    2000           ;# max packet in ifq  
  set val(netif)    Phy/WirelessPhy     ;# network interface type  
  set val(mac)     Mac/802_11        ;# MAC type  
  set val(nn)      51            ;# number of mobilenodes  
  set val(rp)      OPTG          ;# routing protocol  
  set umtsflow "umtsflow"  
  set umts "umts"   
  set topo [new Topography]  
 $topo load_flatgrid $val(x) $val(y)  
 #===========================================================================  
 create-god $val(nn)  
 #===========================================================================  
 set chan_1 [new $val(chan)]  
 $ns node-config -adhocRouting $val(rp) \
          -llType $val(ll) \
          -macType $val(mac) \
          -ifqType $val(ifq) \
          -ifqLen $val(ifqlen) \
          -antType $val(ant) \
          -propType $val(prop) \
          -phyType $val(netif) \
          -topoInstance $topo \
          -agentTrace ON \
          -routerTrace ON \
          -macTrace ON \
          -movementTrace OFF \
          -channel $chan_1  \
             -energyModel EnergyModel \
             -initialEnergy 20 \
             -txPower 0.09 \
             -rxPower 0.08 \
             -idlePower 0.0 \
             -sensePower 0.0175  
 set n(0) [$ns node]  
 $ns at 0.0 "$n(0) color blue"  
 $n(0) color red  
 $n(0) shape "circle"  
 set n(1) [$ns node]  
 $ns at 0.0 "$n(1) color red"  
 $n(1) color red  
 $n(1) shape "circle"  
 set n(2) [$ns node]  
 $ns at 0.0 "$n(2) color darkgreen"  
 $n(2) color red  
 $n(2) shape "circle"  
 #-------------------  
 set n(7) [$ns node]  
 $ns at 0.0 "$n(7) color red"  
 $n(7) color red  
 $n(7) shape "circle"  
 set n(8) [$ns node]  
 $ns at 0.0 "$n(8) color red"  
 $n(8) color red  
 $n(8) shape "circle"  
 set n(9) [$ns node]  
 $ns at 0.0 "$n(9) color red"  
 $n(9) color red  
 $n(9) shape "circle"  
 set n(10) [$ns node]  
 $ns at 0.0 "$n(10) color red"  
 $n(10) color red  
 $n(10) shape "circle"  
 set n(11) [$ns node]  
 $ns at 0.0 "$n(11) color red"  
 $n(11) color red  
 $n(11) shape "circle"  
 set n(12) [$ns node]  
 $ns at 0.0 "$n(12) color red"  
 $n(12) color red  
 $n(12) shape "circle"  
 set n(13) [$ns node]  
 $ns at 0.0 "$n(13) color red"  
 $n(13) color red  
 $n(13) shape "circle"  
 set n(14) [$ns node]  
 $ns at 0.0 "$n(14) color red"  
 $n(14) color red  
 $n(14) shape "circle"  
 set n(15) [$ns node]  
 $ns at 0.0 "$n(15) color red"  
 $n(15) color red  
 $n(15) shape "circle"  
 set n(16) [$ns node]  
 $ns at 0.0 "$n(16) color red"  
 $n(16) color red  
 $n(16) shape "circle"  
 set n(17) [$ns node]  
 $ns at 0.0 "$n(17) color red"  
 $n(17) color red  
 $n(0) shape "circle"  
 set n(18) [$ns node]  
 $ns at 0.0 "$n(18) color red"  
 $n(18) color red  
 $n(18) shape "circle"  
 set n(19) [$ns node]  
 $ns at 0.0 "$n(19) color red"  
 $n(19) color red  
 $n(19) shape "circle"  
 set n(20) [$ns node]  
 $ns at 0.0 "$n(20) color red"  
 $n(20) color red  
 $n(20) shape "circle"  
 set n(21) [$ns node]  
 $ns at 0.0 "$n(21) color darkgreen"  
 $n(21) color red  
 $n(21) shape "circle"  
 set n(22) [$ns node]  
 $ns at 0.0 "$n(22) color red"  
 $n(22) color red  
 $n(22) shape "circle"  
 set n(23) [$ns node]  
 $ns at 0.0 "$n(23) color red"  
 $n(23) color red  
 $n(23) shape "circle"  
 set n(24) [$ns node]  
 $ns at 0.0 "$n(24) color red"  
 $n(24) color red  
 $n(24) shape "circle"  
 set n(25) [$ns node]  
 $ns at 0.0 "$n(25) color red"  
 $n(25) color red  
 $n(25) shape "circle"  
 set n(26) [$ns node]  
 $ns at 0.0 "$n(26) color darkgreen"  
 $n(26) color red  
 $n(26) shape "circle"  
 set n(27) [$ns node]  
 $ns at 0.0 "$n(27) color red"  
 $n(27) color red  
 $n(27) shape "circle"  
 set n(28) [$ns node]  
 $ns at 0.0 "$n(28) color red"  
 $n(28) color green  
 $n(28) shape "square"  
 set n(29) [$ns node]  
 $ns at 0.0 "$n(29) color red"  
 $n(29) color green  
 $n(29) shape "square"  
 set n(30) [$ns node]  
 $ns at 0.0 "$n(30) color darkgreen"  
 $n(30) color green  
 $n(30) shape "circle"  
 set n(31) [$ns node]  
 $ns at 0.0 "$n(31) color red"  
 $n(31) color green  
 $n(31) shape "circle"  
 set n(32) [$ns node]  
 $ns at 0.0 "$n(32) color red"  
 $n(32) color green  
 $n(32) shape "circle"  
 set n(33) [$ns node]  
 $ns at 0.0 "$n(33) color red"  
 $n(33) color green  
 $n(33) shape "circle"  
 set n(34) [$ns node]  
 $ns at 0.0 "$n(34) color darkgreen"  
 $n(34) color green  
 $n(34) shape "circle"  
 set n(35) [$ns node]  
 $ns at 0.0 "$n(35) color red"  
 $n(35) color green  
 $n(35) shape "square"  
 set n(36) [$ns node]  
 $ns at 0.0 "$n(36) color red"  
 $n(36) color green  
 $n(36) shape "square"  
 set n(37) [$ns node]  
 $ns at 0.0 "$n(37) color red"  
 $n(37) color green  
 $n(37) shape "circle"  
 set n(38) [$ns node]  
 $ns at 0.0 "$n(38) color darkgreen"  
 $n(38) color green  
 $n(38) shape "square"  
 set n(39) [$ns node]  
 $ns at 0.0 "$n(39) color red"  
 $n(39) color green  
 $n(39) shape "square"  
 set n(40) [$ns node]  
 $ns at 0.0 "$n(40) color red"  
 $n(40) color green  
 $n(40) shape "circle"  
 set n(41) [$ns node]  
 $ns at 0.0 "$n(41) color red"  
 $n(41) color green  
 $n(41) shape "circle"  
 set n(42) [$ns node]  
 $ns at 0.0 "$n(42) color red"  
 $n(42) color green  
 $n(42) shape "circle"  
 set n(43) [$ns node]  
 $ns at 0.0 "$n(43) color red"  
 $n(43) color green  
 $n(43) shape "circle"  
 set n(44) [$ns node]  
 $ns at 0.0 "$n(44) color red"  
 $n(44) color green  
 $n(44) shape "circle"  
 set n(45) [$ns node]  
 $ns at 0.0 "$n(45) color darkgreen"  
 $n(45) color green  
 $n(45) shape "square"  
 set n(46) [$ns node]  
 $ns at 0.0 "$n(46) color red"  
 $n(46) color green  
 $n(46) shape "square"  
 set n(47) [$ns node]  
 $ns at 0.0 "$n(47) color red"  
 $n(47) color green  
 $n(47) shape "circle"  
 set n(48) [$ns node]  
 $ns at 0.0 "$n(48) color red"  
 $n(48) color green  
 $n(48) shape "square"  
 set n(50) [$ns node]  
 $ns at 0.0 "$n(50) color darkgreen"  
 $n(50) color green  
 $n(50) shape "square"                                                            
 set n(49) [$ns node]  
 $ns at 0.0 "$n(49) color darkgreen"  
 $n(49) color green  
 $n(49) shape "square"  
 #--------  
 set n(6) [$ns node]  
 $ns at 0.0 "$n(6) color red"  
 $ns at 2.81 "$n(6) color green"  
 $ns at 2.82 "$n(6) color red"  
 $ns at 2.83 "$n(6) color green"  
 $ns at 2.84 "$n(6) color red"  
 $ns at 2.85 "$n(6) color green"  
 $ns at 2.86 "$n(6) color red"  
 $ns at 2.87 "$n(6) color green"  
 $ns at 2.88 "$n(6) color red"  
 $ns at 2.89 "$n(6) color green"  
 $ns at 2.90 "$n(6) color red"  
 $ns at 3.83 "$n(40) color green"  
 $ns at 3.84 "$n(40) color red"  
 $ns at 3.842 "$n(40) color green"  
 $ns at 3.845 "$n(40) color red"  
 $ns at 3.85 "$n(40) color green"  
 $ns at 3.86 "$n(40) color red"  
 $n(6) color red  
 $n(6) shape "circle"  
 $ns at 0.0 "$n(0) label WLAN_NODE1"  
 $ns at 0.0 "$n(1) label WLAN_NODE2"  
 $ns at 0.0 "$n(2) label WLAN_BaseStation"  
 $ns at 0.0 "$n(50) label NODE"  
 $n(0) label-color black  
 $n(1) label-color black  
 $n(2) label-color black  
 for {set i 0} {$i < 3} {incr i} {  
     $ns initial_node_pos $n($i) 10+i*10  
 }  
 $n(0) set X_ 58.0  
 $n(0) set Y_ 136.0  
 $n(0) set Z_ 0.0  
 $n(2) set X_ 34.0  
 $n(2) set Y_ 104.0  
 $n(2) set Z_ 0.0  
 $n(1) set X_ 0.5  
 $n(1) set Y_ 136.0  
 $n(1) set Z_ 0.0  
 $n(6) set X_ 6.0  
 $n(6) set Y_ 94.0  
 $n(6) set Z_ 0.0  
 $ns at 0.0 "$n(0) setdest 58.0 136.0 100000.0"  
 $ns at 0.0 "$n(2) setdest 25.0 111.0 100000.0"  
 $ns at 0.0 "$n(1) setdest 0.5 136.0 100000.0"  
 $ns at 0.0 "$n(6) setdest 6.0 94.0 100000.0"  
 $ns at 2.0 "$n(6) setdest 46.0 76.0 100.0"  
 $ns at 2.6 "$n(6) setdest 46.0 66.0 10.0"  
 #---  
 $ns at 0.0 "$n(7) setdest 300.0 500.0 10000.0"  
 $ns at 0.0 "$n(8) setdest 300.0 700.0 10000.0"  
 $ns at 0.0 "$n(9) setdest 300.0 900.0 10000.0"  
 $ns at 0.0 "$n(10) setdest 500.0 100.0 10000.0"  
 $ns at 0.0 "$n(11) setdest 500.0 300.0 10000.0"  
 $ns at 0.0 "$n(12) setdest 500.0 500.0 10000.0"  
 $ns at 0.0 "$n(13) setdest 500.0 700.0 10000.0"  
 $ns at 0.0 "$n(14) setdest 500.0 900.0 10000.0"  
 $ns at 0.0 "$n(15) setdest 700.0 100.0 10000.0"  
 $ns at 0.0 "$n(16) setdest 700.0 300.0 10000.0"  
 $ns at 0.0 "$n(17) setdest 700.0 500.0 10000.0"  
 $ns at 0.0 "$n(18) setdest 700.0 700.0 10000.0"  
 $ns at 0.0 "$n(19) setdest 700.0 900.0 10000.0"  
 $ns at 0.0 "$n(20) setdest 900.0 100.0 10000.0"  
 $ns at 0.0 "$n(21) setdest 900.0 300.0 10000.0"  
 $ns at 0.0 "$n(22) setdest 900.0 500.0 10000.0"  
 $ns at 0.0 "$n(23) setdest 900.0 700.0 10000.0"  
 $ns at 0.0 "$n(24) setdest 900.0 900.0 10000.0"  
 $ns at 0.0 "$n(25) setdest 579.0 425.0 10000.0"  
 $ns at 0.0 "$n(26) setdest 450.0 10.0 10000.0"  
 $ns at 0.0 "$n(27) setdest 999.0 500.0 10000.0"  
 $ns at 0.0 "$n(28) setdest 999.0 700.0 10000.0"  
 $ns at 0.0 "$n(29) setdest 999.0 300.0 10000.0"  
 $ns at 0.0 "$n(30) setdest 749.0 189.0 10000.0"  
 $ns at 0.0 "$n(31) setdest 850.0 300.0 10000.0"  
 $ns at 0.0 "$n(32) setdest 750.0 500.0 10000.0"  
 $ns at 0.0 "$n(33) setdest 550.0 700.0 10000.0"  
 $ns at 0.0 "$n(34) setdest 550.0 900.0 10000.0"  
 $ns at 0.0 "$n(35) setdest 220.1 257.1 10000.0"  
 $ns at 4.4 "$n(35) setdest 51.1 91.1 100.0"  
 $ns at 0.0 "$n(36) setdest 400.0 10.0 10000.0"  
 $ns at 0.0 "$n(37) setdest 649.0 500.0 10000.0"  
 $ns at 0.0 "$n(38) setdest 419.0 610.0 10000.0"  
 $ns at 0.0 "$n(39) setdest 349.0 300.0 10000.0"  
 $ns at 0.0 "$n(40) setdest 150.0 100.0 10000.0"  
 $ns at 0.0 "$n(41) setdest 250.0 400.0 10000.0"  
 $ns at 0.0 "$n(42) setdest 350.0 550.0 10000.0"  
 $ns at 0.0 "$n(43) setdest 450.0 750.0 10000.0"  
 $ns at 0.0 "$n(44) setdest 550.0 950.0 10000.0"  
 $ns at 0.0 "$n(45) setdest 314.1 135.1 10000.0"  
 $ns at 0.0 "$n(46) setdest 550.0 50.0 10000.0"  
 $ns at 0.0 "$n(47) setdest 784.0 372.0 10000.0"  
 $ns at 0.0 "$n(48) setdest 649.0 750.0 10000.0"  
 $ns at 0.0 "$n(49) setdest 749.0 450.0 10000.0"  
 $ns at 0.0 "$n(50) setdest 8.0 186.0 10000.0"  
 $ns at 4.0 "$n(50) setdest 30.0 147.0 100.0"  
 $ns at 3.1 "$n(8) setdest 100.0 500.0 10.0"  
 $ns at 3.1 "$n(9) setdest 100.0 100.0 10.0"  
 $ns at 3.1 "$n(10) setdest 700.0 300.0 10.0"  
 $ns at 3.1 "$n(11) setdest 700.0 500.0 10.0"  
 $ns at 3.1 "$n(12) setdest 500.0 500.0 10.0"  
 $ns at 3.1 "$n(13) setdest 300.0 500.0 10.0"  
 $ns at 3.1 "$n(14) setdest 300.0 700.0 10.0"  
 $ns at 3.1 "$n(15) setdest 700.0 900.0 10.0"  
 $ns at 3.1 "$n(16) setdest 900.0 500.0 10.0"  
 $ns at 3.1 "$n(17) setdest 500.0 700.0 10.0"  
 $ns at 3.1 "$n(18) setdest 500.0 900.0 10.0"  
 $ns at 3.1 "$n(19) setdest 300.0 900.0 10.0"  
 $ns at 3.1 "$n(20) setdest 900.0 700.0 10.0"  
 $ns at 3.1 "$n(21) setdest 900.0 900.0 10.0"  
 $ns at 3.1 "$n(22) setdest 700.0 700.0 10.0"  
 $ns at 3.1 "$n(23) setdest 100.0 900.0 10.0"  
 $ns at 3.1 "$n(24) setdest 100.0 700.0 10.0"  
 $ns at 3.1 "$n(27) setdest 999.0 500.0 10.0"  
 $ns at 3.1 "$n(28) setdest 999.0 700.0 10.0"  
 $ns at 3.1 "$n(29) setdest 999.0 900.0 10.0"  
 $ns at 3.0 "$n(30) setdest 950.0 100.0 10.0"  
 $ns at 3.0 "$n(31) setdest 850.0 300. 10.0"  
 $ns at 3.0 "$n(32) setdest 750.0 500.0 10.0"  
 $ns at 3.0 "$n(33) setdest 550.0 700.0 10.0"  
 $ns at 3.0 "$n(34) setdest 550.0 900.0 10.0"  
 $ns at 3.0 "$n(35) setdest 50.1 0.1 10.0"  
 $ns at 3.0 "$n(36) setdest 400.0 10.0 10.0"  
 $ns at 3.0 "$n(37) setdest 649.0 500.0 10.0"  
 $ns at 3.0 "$n(38) setdest 549.0 700.0 10.0"  
 $ns at 3.0 "$n(39) setdest 349.0 300.0 10.0"  
 $ns at 2.8 "$n(40) setdest 83.0 111.0 100.0"  
 $ns at 3.5 "$n(40) setdest 95.0 67.0 100.0"  
 $ns at 3.0 "$n(41) setdest 250.0 400.0 10.0"  
 $ns at 3.0 "$n(42) setdest 350.0 550.0 10.0"  
 $ns at 3.0 "$n(43) setdest 450.0 750.0 10.0"  
 $ns at 3.0 "$n(44) setdest 550.0 950.0 10.0"  
 $ns at 3.0 "$n(45) setdest 50.1 50.1 10.0"  
 $ns at 3.0 "$n(46) setdest 550.0 50.0 10.0"  
 $ns at 3.0 "$n(47) setdest 849.0 550.0 10.0"  
 $ns at 3.0 "$n(48) setdest 649.0 750.0 10.0"  
 $ns at 3.0 "$n(49) setdest 749.0 450.0 10.0"  
 #--  
 set sink9 [new Agent/LossMonitor]  
 set sink10 [new Agent/LossMonitor]  
 set sink11 [new Agent/LossMonitor]  
 set sink15 [new Agent/LossMonitor]  
 set sink16 [new Agent/LossMonitor]  
 set sink17 [new Agent/LossMonitor]  
 set sink18 [new Agent/LossMonitor]  
 set sink19 [new Agent/LossMonitor]  
 set sink20 [new Agent/LossMonitor]  
 set sink21 [new Agent/LossMonitor]  
 set sink22 [new Agent/LossMonitor]  
 set sink23 [new Agent/LossMonitor]  
 set sink24 [new Agent/LossMonitor]  
 set sink25 [new Agent/LossMonitor]  
 set sink26 [new Agent/LossMonitor]     
 set sink27 [new Agent/LossMonitor]  
 set sink28 [new Agent/LossMonitor]  
 set sink29 [new Agent/LossMonitor]  
 set sink30 [new Agent/LossMonitor]  
 set sink31 [new Agent/LossMonitor]  
 set sink32 [new Agent/LossMonitor]  
 set sink33 [new Agent/LossMonitor]  
 set sink34 [new Agent/LossMonitor]  
 set sink35 [new Agent/LossMonitor]  
 set sink36 [new Agent/LossMonitor]  
 set sink37 [new Agent/LossMonitor]  
 set sink38 [new Agent/LossMonitor]  
 set sink39 [new Agent/LossMonitor]  
 set sink40 [new Agent/LossMonitor]  
 set sink41 [new Agent/LossMonitor]  
 set sink42 [new Agent/LossMonitor]  
 set sink43 [new Agent/LossMonitor]  
 set sink44 [new Agent/LossMonitor]  
 set sink45 [new Agent/LossMonitor]  
 set sink46 [new Agent/LossMonitor]  
 set sink47 [new Agent/LossMonitor]  
 set sink48 [new Agent/LossMonitor]  
 set sink49 [new Agent/LossMonitor]  
 $ns attach-agent $n(0) $sink9  
 $ns attach-agent $n(1) $sink10  
 $ns attach-agent $n(2) $sink11  
 $ns attach-agent $n(6) $sink15  
 $ns attach-agent $n(16) $sink16  
 $ns attach-agent $n(17) $sink17  
 $ns attach-agent $n(18) $sink18  
 $ns attach-agent $n(19) $sink19  
 $ns attach-agent $n(20) $sink20  
 $ns attach-agent $n(21) $sink21  
 $ns attach-agent $n(22) $sink22  
 $ns attach-agent $n(23) $sink23  
 $ns attach-agent $n(24) $sink24  
 $ns attach-agent $n(25) $sink25  
 $ns attach-agent $n(26) $sink26  
 $ns attach-agent $n(27) $sink27  
 $ns attach-agent $n(28) $sink28  
 $ns attach-agent $n(29) $sink29  
 $ns attach-agent $n(30) $sink30  
 $ns attach-agent $n(31) $sink31  
 $ns attach-agent $n(32) $sink32  
 $ns attach-agent $n(33) $sink33  
 $ns attach-agent $n(34) $sink34  
 $ns attach-agent $n(35) $sink35  
 $ns attach-agent $n(36) $sink36  
 $ns attach-agent $n(37) $sink37  
 $ns attach-agent $n(38) $sink38  
 $ns attach-agent $n(39) $sink39  
 $ns attach-agent $n(40) $sink40  
 $ns attach-agent $n(41) $sink41  
 $ns attach-agent $n(42) $sink42  
 $ns attach-agent $n(43) $sink43  
 $ns attach-agent $n(44) $sink44  
 $ns attach-agent $n(45) $sink45  
 $ns attach-agent $n(46) $sink46  
 $ns attach-agent $n(47) $sink47  
 $ns attach-agent $n(48) $sink48  
 $ns attach-agent $n(49) $sink49  
 set tcp9 [new Agent/TCP]  
 $ns attach-agent $n(0) $tcp9  
 set tcp10 [new Agent/TCP]  
 $ns attach-agent $n(1) $tcp10  
 set tcp11 [new Agent/TCP]  
 $ns attach-agent $n(2) $tcp11set tcp15 [new Agent/TCP]  
 $ns attach-agent $n(6) $tcp15  
 set tcp16 [new Agent/TCP]  
 $ns attach-agent $n(16) $tcp16  
 set tcp17 [new Agent/TCP]  
 $ns attach-agent $n(17) $tcp17  
 set tcp18 [new Agent/TCP]  
 $ns attach-agent $n(18) $tcp18  
 set tcp19 [new Agent/TCP]  
 $ns attach-agent $n(19) $tcp19  
 set tcp20 [new Agent/TCP]  
 $ns attach-agent $n(20) $tcp20  
 set tcp21 [new Agent/TCP]  
 $ns attach-agent $n(21) $tcp21  
 set tcp22 [new Agent/TCP]  
 $ns attach-agent $n(22) $tcp22  
 set tcp23 [new Agent/TCP]  
 $ns attach-agent $n(23) $tcp23  
 set tcp24 [new Agent/TCP]  
 $ns attach-agent $n(24) $tcp24  
 set tcp25 [new Agent/TCP]  
 $ns attach-agent $n(25) $tcp25  
 set tcp26 [new Agent/TCP]  
 $ns attach-agent $n(26) $tcp26  
 set tcp27 [new Agent/TCP]  
 $ns attach-agent $n(27) $tcp27  
 set tcp28 [new Agent/TCP]  
 $ns attach-agent $n(28) $tcp28  
 set tcp29 [new Agent/TCP]  
 $ns attach-agent $n(29) $tcp29  
 set tcp30 [new Agent/TCP]  
 $ns attach-agent $n(30) $tcp30  
 set tcp31 [new Agent/TCP]  
 $ns attach-agent $n(31) $tcp31  
 set tcp32 [new Agent/TCP]  
 $ns attach-agent $n(32) $tcp32  
 set tcp33 [new Agent/TCP]  
 $ns attach-agent $n(33) $tcp33  
 set tcp34 [new Agent/TCP]  
 $ns attach-agent $n(34) $tcp34  
 set tcp35 [new Agent/TCP]  
 $ns attach-agent $n(35) $tcp35  
 set tcp36 [new Agent/TCP]  
 $ns attach-agent $n(36) $tcp36  
 set tcp37 [new Agent/TCP]  
 $ns attach-agent $n(37) $tcp37  
 set tcp38 [new Agent/TCP]  
 $ns attach-agent $n(38) $tcp38  
 set tcp39 [new Agent/TCP]  
 $ns attach-agent $n(39) $tcp39  
 set tcp40 [new Agent/TCP]  
 $ns attach-agent $n(40) $tcp40  
 set tcp41 [new Agent/TCP]  
 $ns attach-agent $n(41) $tcp41  
 set tcp42 [new Agent/TCP]  
 $ns attach-agent $n(42) $tcp42  
 set tcp43 [new Agent/TCP]  
 $ns attach-agent $n(43) $tcp43  
 set tcp44 [new Agent/TCP]  
 $ns attach-agent $n(44) $tcp44  
 set tcp45 [new Agent/TCP]  
 $ns attach-agent $n(45) $tcp45  
 set tcp46 [new Agent/TCP]  
 $ns attach-agent $n(46) $tcp46  
 set tcp47 [new Agent/TCP]  
 $ns attach-agent $n(47) $tcp47  
 set tcp48 [new Agent/TCP]  
 $ns attach-agent $n(48) $tcp48  
 set tcp49 [new Agent/TCP]  
 $ns attach-agent $n(49) $tcp49  
 source umts  
 proc attach-CBR-traffic { node sink size interval } {  
   #Get an instance of the simulator  
   set ns [Simulator instance]  
   #Create a CBR agent and attach it to the node  
   set cbr [new Agent/CBR]  
   $ns attach-agent $node $cbr  
   $cbr set packetSize_ $size  
   $cbr set interval_ $interval  
   #Attach CBR source to sink;  
   $ns connect $cbr $sink  
   return $cbr  
  }  
 #======================================================================================  
 set cbr2112 [attach-CBR-traffic $n(0) $sink11 500 .03]  
 set cbr2113 [attach-CBR-traffic $n(14) $sink34 500 .03]  
 set cbr2114 [attach-CBR-traffic $n(44) $sink34 500 .03]  
 set cbr2115 [attach-CBR-traffic $n(17) $sink49 500 .03]  
 set cbr2116 [attach-CBR-traffic $n(32) $sink49 500 .03]  
 set cbr2117 [attach-CBR-traffic $n(31) $sink21 500 .03]  
 set cbr2118 [attach-CBR-traffic $n(29) $sink21 500 .03]  
 set cbr2119 [attach-CBR-traffic $n(47) $sink49 500 .03]  
 set cbr2120 [attach-CBR-traffic $n(36) $sink26 500 .03]  
 set cbr2121 [attach-CBR-traffic $n(46) $sink26 500 .03]  
 set cbr2122 [attach-CBR-traffic $n(30) $sink15 500 .03]  
 set cbr2123 [attach-CBR-traffic $n(20) $sink30 500 .03]  
 set cbr2124 [attach-CBR-traffic $n(42) $sink38 500 .03]  
 set cbr2125 [attach-CBR-traffic $n(13) $sink38 500 .03]  
 set cbr2126 [attach-CBR-traffic $n(41) $sink45 500 .03]  
 $ns at 0.1 "$cbr2112 start"  
 $ns at 0.192 "$cbr2113 start"  
 $ns at 0.167 "$cbr2114 start"  
 $ns at 0.1001 "$cbr2115 start"  
 $ns at 0.155 "$cbr2116 start"  
 $ns at 0.142 "$cbr2117 start"  
 $ns at 0.131 "$cbr2118 start"  
 $ns at 0.121 "$cbr2119 start"  
 $ns at 0.111 "$cbr2120 start"  
 $ns at 0.1911 "$cbr2121 start"  
 $ns at 0.2111 "$cbr2122 start"  
 $ns at 0.241 "$cbr2123 start"  
 $ns at 0.2 "$cbr2124 start"  
 $ns at 0.21 "$cbr2125 start"  
 $ns at 0.241 "$cbr2125 start"  
 #===================================================================================  
 $ns at 0.0 "$ftp0 start"  
 $ns at 16.0 "$ftp0 stop"  
 $ns at 16.401 "finish"  
 puts " Simulation is running ... please wait ..."  
 $ns run
