#  Clustering      http://www.linuxquestions.org/questions/showthread.php?p=5173494#post5173494
set val(chan)   Channel/WirelessChannel    ;# channel type
set val(prop)   Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)  Phy/WirelessPhy            ;# network interface type
set val(mac)    Mac/802_11                 ;# MAC type
set val(ifq)    Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)     LL                         ;# link layer type
set val(ant)    Antenna/OmniAntenna        ;# antenna model
set val(ifqlen) 500                         ;# max packet in ifq
set val(nn)     22                        ;# number of mobilenodes
set val(rp)     DSR                       ;# routing protocol
set val(x)      2000                       ;# X dimension of topography
set val(y)      2000                       ;# Y dimension of topography
set val(stop)   10.0                       ;# time of simulation end


set ns [new Simulator]


set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)
create-god $val(nn)


set tracefile [open out.tr w]
$ns trace-all $tracefile
$ns use-newtrace

set f0 [open througput.tr w]
set f1 [open delivryratio.tr w]
set f2 [open packtdelay.tr w]
set f3 [open packtdropped.tr w]
set f4 [open n4-delay1.tr w]
set f5 [open n5-delay2.tr w]
set f6 [open n6-packets_received.tr w]
set f7 [open n7-packets_received.tr w]
set f8 [open n8-packets_received.tr w]
set f9 [open n9-throughput.tr w]
set f10 [open n10-packets_received.tr w]
set f11 [open n11-packets_received.tr w]
set f12 [open n12-packets_received.tr w]
set f13 [open n13-packets_received.tr w]
set f14 [open n14-packets_received.tr w]
set f15 [open n15-packets_received.tr w]
set f16 [open n16-deliveryratio.tr w]

set namfile [open out.nam w]
$ns namtrace-all $namfile
$ns namtrace-all-wireless $namfile $val(x) $val(y)
set chan [new $val(chan)];#Create wireless channel


$ns node-config -llType        $val(ll) \
                -macType       $val(mac) \
                -ifqType       $val(ifq) \
                -ifqLen        $val(ifqlen) \
                -antType       $val(ant) \
                -propType      $val(prop) \
                -phyType       $val(netif) \
                -channel       $chan \
                -adhocRouting  AODV \
                -topoInstance  $topo \
                -agentTrace    ON \
                -routerTrace   ON \
                -macTrace      ON \
                -movementTrace ON

$ns color 0 blue
$ns color 1 darkgreen
$ns color 2 red
$ns color 3 brown
$ns color 4 gray
$ns color 5 black
$ns color 6 blue
$ns color 7 skyblue
$ns color 8 pink


proc record {} {

  global sink0 sink1 sink2 sink3 sink4 sink5 sink6 sink7 sink8 sink9 sink10 sink11 sink12 sink13 sink14 sink15 sink16 sink17 sink18 sink19 sink20 sink21 sink22 sink23 sink24 sink25 sink26 sink27 sink28 sink29 sink30 sink31 sink32   f0 f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12 f13 f14 f15 f16  
set ns [Simulator instance]
set time 0.05
   
   set bw0 [$sink0 set npkts_]
   set bw1 [$sink1 set npkts_]
   set bw2 [$sink2 set npkts_]
   set bw3 [$sink3 set npkts_]
   set bw4 [$sink4  set npkts_]
   set bw5 [$sink5 set npkts_]
   set bw6 [$sink6 set npkts_]
   set bw7 [$sink7 set npkts_]
   set bw8 [$sink8 set npkts_]
   set bw9 [$sink9 set npkts_]
   set bw10 [$sink10 set npkts_]
   set bw11 [$sink11 set npkts_]
   set bw12 [$sink12 set npkts_]
   set bw13 [$sink13 set npkts_]
   set bw14 [$sink14 set npkts_]
   set bw15 [$sink15 set npkts_]
   set bw16 [$sink16 set npkts_]
   set bw17 [$sink17 set npkts_]
   set bw18 [$sink18 set npkts_]
   set bw19 [$sink19 set npkts_]
   set bw20 [$sink20 set npkts_]
   set bw21 [$sink21 set npkts_]
   set bw22 [$sink22 set npkts_]
   set bw23 [$sink23 set npkts_]
   set bw24 [$sink24 set npkts_]
   set bw25 [$sink25 set npkts_]
   set bw26 [$sink26 set npkts_]
   set bw27 [$sink27 set npkts_]
   set bw28 [$sink28 set npkts_]
   set bw29 [$sink29 set npkts_]
   set bw30 [$sink30 set npkts_]
   set bw31 [$sink31 set npkts_]
   set bw32 [$sink32 set npkts_]
   set bw_21 [expr $bw21+11]
   set energy 10
   set Size 12
 
   puts "No of Packets in 0th node: $bw0"
   puts "No of Packets in 01th node: $bw1"
   puts "No of Packets in 02th node: $bw2"
   puts "No of Packets in 03th node: $bw3"
   puts "No of Packets in 04th node: $bw4"
   puts "No of Packets in 05th node: $bw5"
   puts "No of Packets in 06th node: $bw6"
   puts "No of Packets in 07th node: $bw7"
   puts "No of Packets in 08th node: $bw8"
   puts "No of Packets in 09th node: $bw9"
   puts "No of Packets in 10th node: $bw10"
   puts "No of Packets in 11th node: $bw11"
   puts "No of Packets in 12th node: $bw12"
   puts "No of Packets in 13th node: $bw13"
   puts "No of Packets in 14th node: $bw14"
   puts "No of Packets in 15th node: $bw15"
   puts "No of Packets in 16th node: $bw16"
   puts "No of Packets in 17th node: $bw17"
   puts "No of Packets in 18th node: $bw18"
   puts "No of Packets in 19th node: $bw19"
   puts "No of Packets in 20th node: $bw20"
   puts "No of Packets in 21th node: $bw21"
   puts "No of Packets in 22th node: $bw22"
   puts "No of Packets in 23th node: $bw23" 
   puts "No of Packets in 24th node: $bw24"
   puts "No of Packets in 25th node: $bw25"        
   puts "No of Packets in 26th node: $bw26"
   puts "No of Packets in 27th node: $bw27"
   puts "No of Packets in 28th node: $bw28"      
   puts "No of Packets in 29th node: $bw29"      
   puts "No of Packets in 30th node: $bw30"      
   puts "No of Packets in 31th node: $bw31"      
   puts "No of Packets in 32th node: $bw32"  
puts " *************************************************"
     set eg1 [expr $bw0]       
   set eg [expr $bw15]
   set band [expr $bw1]
   set estimate [expr $bw20]
   set simulate [expr $bw6]
   set bandwidth [expr $bw21]
   set ener [expr $bw11]
   set delay [expr $bw15]
   set datarate [expr $bw16]
   set through [expr $bw17]
   set pdr [expr $bw1*29.56]
   set enr [expr $bw1*7/.92]
   set econ  [expr $bw3+$bw1+$bw6+$bw3]
   set id [expr $bw9*10]
   
   set rmr1 [expr ($bw30*$energy)-$bw30]
   set rmr_1 [expr ($bw30*$energy)]
   set rmr_2 [expr ($bw32*$energy)]

   set rmr2 [expr ($bw32*$energy)-$bw32]
   set rmr3 [expr ($bw9*$energy)-$bw9]
   set id1 [expr $bw30*10]
   set id2 [expr $bw32*10]
   set membernodes1 0_2_3_4_6_9_10
   set membernodes2 12_14_16_17_18_29_30 
   set membernodes3 24_25_26_27_28_31_32
   set node0 [expr ($bw0*$energy)-$bw0]
   set node1 [expr ($bw1*$energy)-$bw1]
   set node2 [expr ($bw2*$energy)-$bw2]
   set node3 [expr ($bw3*$energy)-$bw3]
   set node4 [expr ($bw4*$energy)-$bw4]
   set node_0 [expr ($bw0*$energy)]
   set node_1 [expr ($bw1*$energy)]
   set node_2 [expr ($bw2*$energy)]
   set node_3 [expr ($bw3*$energy)]
   set node_4 [expr ($bw4*$energy)]

   #set node5 [expr ($bw5*$energy)-$bw5]
   set node6 [expr ($bw6*$energy)-$bw6]
   set node_6 [expr ($bw6*$energy)]

   #set node7 [expr ($bw7*$energy)-$bw7]
   #set node8 [expr ($bw8*$energy)-$bw8]
   set node9 [expr ($bw9*$energy)-$bw9] 
   set node_9 [expr ($bw9*$energy)]     
   set node11 [expr ($bw11*$energy)-$bw11]
   set node12 [expr ($bw12*$energy)-$bw12]
   set node_11 [expr ($bw11*$energy)]
   set node_12 [expr ($bw12*$energy)]
   #set node13 [expr ($bw13*$energy)-$bw13]
   set node14 [expr ($bw14*$energy)-$bw14]
    set node_14 [expr ($bw14*$energy)]

   #set node15 [expr ($bw15*$energy)-$bw15]
   set node16 [expr ($bw16*$energy)-$bw16]
   set node17 [expr ($bw17*$energy)-$bw17]
   set node18 [expr ($bw18*$energy)-$bw18]
   set node_16 [expr ($bw16*$energy)]
   set node_17 [expr ($bw17*$energy)]
   set node_18 [expr ($bw18*$energy)]

   #set node19 [expr ($bw19*$energy)-$bw19]
   set node29 [expr ($bw29*$energy)-$bw29]
   set node_29 [expr ($bw29*$energy)]

   set node20 [expr ($bw20*$energy)-$bw20]
   set node_20 [expr ($bw20*$energy)]
   #set node21 [expr ($bw21*$energy)-$bw11]
   #set node22 [expr ($bw22*$energy)-$bw12]
   #set node23 [expr ($bw23*$energy)-$bw13]
   set node24 [expr ($bw24*$energy)-$bw14]
   set node25 [expr ($bw25*$energy)-$bw15]
   set node26 [expr ($bw26*$energy)-$bw16]
   set node27 [expr ($bw27*$energy)-$bw17]
   set node28 [expr ($bw28*$energy)-$bw28]
   set node31 [expr ($bw31*$energy)-$bw31]
   set node_24 [expr ($bw24*$energy)]
   set node_25 [expr ($bw25*$energy)]
   set node_26 [expr ($bw26*$energy)]
   set node_27 [expr ($bw27*$energy)]
   set node_28 [expr ($bw28*$energy)]
   set node_31 [expr ($bw31*$energy)]

   set avg [expr ($node0+$node1+$node2+$node3+$node4+$node6+$node9)/10]
    set avg1 [expr ($node11+$node12+$node14+$node16+$node17+$node18+$rmr1+$node29)/11] 
     set avg2 [expr ($node20+$node24+$node25+$node26+$node27+$node28+$node31+$rmr2)/11]
   set edis  [expr (1040-$bw0)*150]
   
          set trust0 [expr ($node0+$node_0)*$bw0]
          set trust1 [expr ($node1+$node_1)*$bw1]
          set trust2 [expr ($node2+$node_2)*$bw2]
          set trust3 [expr ($node3+$node_3)*$bw3]
          set trust4 [expr ($node4+$node_4)*$bw4]
          set trust6 [expr ($node6+$node_6)*$bw6]
          set trust9 [expr ($node9+$node_9)*$bw9]

          set trust0 [expr ($node0+$node_0)*$bw0]
set trust11 [expr ($node11+$node_11)*$bw11]
set trust12 [expr ($node12+$node_12)*$bw12]
set trust14 [expr ($node14+$node_14)*$bw14]
set trust16 [expr ($node16+$node_16)*$bw16]
set trust17 [expr ($node17+$node_17)*$bw17]
set trust18 [expr ($node18+$node_18)*$bw18]
set trust29 [expr ($node29+$node_29)*$bw29]
set trust30 [expr ($rmr1+$rmr_1)*$bw30]

set trust20 [expr ($node20+$node_20)*$bw20]
set trust24 [expr ($node24+$node_24)*$bw24]
set trust25 [expr ($node25+$node_25)*$bw25]
set trust26 [expr ($node26+$node_26)*$bw26]
set trust27 [expr ($node27+$node_27)*$bw27]
set trust28 [expr ($node28+$node_28)*$bw28]
set trust31 [expr ($node31+$node_31)*$bw31]

              
   puts " *************************************************"
   
   puts " Energy of nodes in cluster_1 determined as"
   puts " Energy of node 0: $node0 joules "
   puts " Energy of node 1: $node1 joules "
   puts " Energy of node 2: $node2 joules "
   puts " Energy of node 3: $node3 joules "
   puts " Energy of node 4: $node4 joules "
   #puts " Energy of node 5: $node5 joules "
   puts " Energy of node 6: $node6 joules "
   #puts " Energy of node 7: $node7 joules "
   #puts " Energy of node 8: $node8 joules "
   puts " Energy of node 9: $node9 joules "

   puts " Energy Consumption of nodes in cluster_1 determined as"
   puts " Energy Consumption of node 0: $node_0 joules "
   puts " Energy Consumption of node 1: $node_1 joules "
   puts " Energy Consumption of node 2: $node_2 joules "
   puts " Energy Consumption of node 3: $node_3 joules "
   puts " Energy Consumption of node 4: $node_4 joules "
   #puts " Energy Consumption of node 5: $node5 joules "
   puts " Energy Consumption of node 6: $node_6 joules "
   #puts " Energy Consumption of node 7: $node7 joules "
   #puts " Energy Consumption of node 8: $node8 joules "
   puts " Energy Consumption of node 9: $node_9 joules "

   puts " single-path of node 0: $trust0 "
   puts " single-path of node 1: $trust1 "
   puts " single-path of node 2: $trust2 "
   puts " single-path of node 3: $trust3 "
   puts " single-path of node 4: $trust4 "
   puts " single-path of node 6: $trust6 "
   puts " single-path of node 9: $trust9 "


   puts " *************************************************"
   
   puts " Energy of nodes in cluster_2 determined as"
   puts " Energy of node 11: $node11 joules "
   puts " Energy of node 12: $node12 joules "
   #puts " Energy of node 13: $node13 joules "
   puts " Energy of node 14: $node14 joules "
   #puts " Energy of node 15: $node15 joules "
   puts " Energy of node 16: $node16 joules "
   puts " Energy of node 17: $node17 joules "
   puts " Energy of node 18: $node18 joules "
   #puts " Energy of node 19: $node19 joules "
   puts " Energy of node 29: $node29 joules "
   puts " Energy of node 30: $rmr1 joules "
   
   puts " Energy Consumption of nodes in cluster_2 determined as"
   puts " Energy Consumption of node 11: $node_11 joules "
   puts " Energy Consumption of node 12: $node_12 joules "
   #puts " Energy Consumption of node 13: $node_13 joules "
   puts " Energy Consumption of node 14: $node_14 joules "
   #puts " Energy Consumption of node 15: $node_15 joules "
   puts " Energy Consumption of node 16: $node_16 joules "
   puts " Energy Consumption of node 17: $node_17 joules "
   puts " Energy Consumption of node 18: $node_18 joules "
   #puts " Energy Consumption of node 19: $node_19 joules "
   puts " Energy Consumption of node 29: $node_29 joules "
   puts " Energy Consumption of node 30: $rmr_1 joules "

    puts " Trust value of node 11: $trust11 "
 puts " multi-path routing of node 12: $trust12 "
 puts " multi-path routing of node 14: $trust14 "
 puts " multi-path routing of node 16: $trust16 "
 puts " multi-path routing of node 17: $trust17 "
 puts " multi-path routing of node 18: $trust18 "
 puts " multi-path routing of node 29: $trust29 "
 puts " multi-path routing of node 30: $trust30 "

   puts " *************************************************"
   
   puts " Energy of nodes in cluster_3 determined as"
   puts " Energy of node 20: $node20 joules "
   #puts " Energy of node 21: 40 joules "
   #puts " Energy of node 22: $node22 joules "
   #puts " Energy of node 23: $node23 joules "
   puts " Energy of node 24: $node24 joules "
   puts " Energy of node 25: $node25 joules "
   puts " Energy of node 26: $node26 joules "
   puts " Energy of node 27: $node27 joules "
   puts " Energy of node 28: $node28 joules "
   puts " Energy of node 31: $node31 joules "
   #puts " Energy of node 32: $rmr2 joules "

   puts " Energy Consumption of nodes in cluster_3 determined as"
   puts " Energy Consumption of node 20: $node_20 joules "
   puts " Energy Consumption of node 24: $node_24 joules "
   puts " Energy Consumption of node 25: $node_25 joules "
   puts " Energy Consumption of node 26: $node_26 joules "
   puts " Energy Consumption of node 27: $node_27 joules "
   puts " Energy Consumption of node 28: $node_28 joules "
   puts " Energy Consumption of node 31: $node_31 joules "
   
   puts " Trust value of node 20: $trust20 "
   puts " Trust value of node 24: $trust24 "
puts " Trust value of node 25: $trust25 "
puts " Trust value of node 26: $trust26 "
puts " Trust value of node 27: $trust27 "
puts " Trust value of node 28: $trust28 "
puts " Trust value of node 31: $trust31 "


   puts " *************************************************" 
   puts " GROUPING TABLE INFORMATION OF EACH CLUSTER "
   puts " *************************************************" 
   puts " GROUPING TABLE INFORMATION OF FIRST CLUSTER "
   puts "  cluster_head id_no: 1 "
   puts " MEMBER NODES OF CLUSTER1 id_no:$membernodes1 "
   puts " DATA ROUTING INFORMATION:ROUTED FROM id_no:10"
   puts " DATA ROUTING INFORMATION:ROUTED TO id_no:25"
   puts " AVG ENERGY LEVEL OF NODES IN CLUSTER1:$avg joules "
   puts " HIGHEST TRUST VALUE OF NODE IN CLUSTER1:$trust1 node1 selected as cluster head "
   
   puts " *************************************************" 
   puts " GROUPING TABLE INFORMATION OF SECOND CLUSTER "
   puts " *************************************************" 
   puts " cluster_head id_no: 11 "
   puts " MEMBER NODES OF CLUSTER2 id_no:$membernodes2 "
   puts " DATA ROUTING INFORMATION:ROUTED FROM id_no:---"
   puts " DATA ROUTING INFORMATION:ROUTED TO id_no:---"
   puts " AVG ENERGY LEVEL OF NODES IN CLUSTER2:$avg1 joules "
    puts " HIGHEST TRUST LEVEL OF NODE IN CLUSTER2:$trust11 node11 selected as cluster head "
    puts " node 29 EXCEEDS TRUST VALUE BELOW THE THRESHOLD VALUE:$trust29 node29 act as malicious node "

   puts " *************************************************" 
   puts " GROUPING TABLE INFORMATION OF THIRD CLUSTER "
   puts " *************************************************" 
   puts " cluster_head id_no: 22 "
   puts " MEMBER NODES OF CLUSTER3 id_no:$membernodes3 "
   puts " DATA ROUTING INFORMATION:ROUTED FROM id_no:32 "
   puts " DATA ROUTING INFORMATION:ROUTED TO id_no:16 "
   puts " AVG ENERGY LEVEL OF NODES IN CLUSTER1:$avg2 joules"
    puts " HIGHEST ENERGY LEVEL OF NODE IN CLUSTER1:$trust20 node20 selected as cluster head "
   
 set now [$ns now]

   puts $f0 "$now [expr $bw0]"
   puts $f1 "$now [expr $bw1]"
   puts $f2 "$now [expr $bw2]"
   puts $f3 "$now [expr $bw3]"
   puts $f4 "$now [expr $bw4]"
   puts $f5 "$now [expr $bw5]"
   puts $f6 "$now [expr $bw6]"
   puts $f7 "$now [expr $bw7]" 
   puts $f8 "$now [expr $bw8]"
   puts $f9 "$now [expr $bw9]"
   puts $f10 "$now [expr $bw10]"
   puts $f11 "$now [expr $bw11]"
   puts $f12 "$now [expr $bw12]"
   puts $f13 "$now [expr $bw13]"
   puts $f14 "$now [expr $bw14]"
   puts $f15 "$now [expr $bw15]"
   puts $f16 "$now [expr $bw16]"

   $ns at [expr $now+$time] "record"

   
  }



set node_(0) [$ns node]
$node_(0) set X_ 299
$node_(0) set Y_ 248
$node_(0) set Z_ 0.0
$ns initial_node_pos $node_(0) 35
set node_(1) [$ns node]
$node_(1) set X_ 297
$node_(1) set Y_ 496
$node_(1) set Z_ 0.0
$ns initial_node_pos $node_(1) 35
set node_(2) [$ns node]
$node_(2) set X_ 297
$node_(2) set Y_ 496
$node_(2) set Z_ 0.0
$ns initial_node_pos $node_(2) 35
set node_(3) [$ns node]
$node_(3) set X_ 297
$node_(3) set Y_ 496
$node_(3) set Z_ 0.0
$ns initial_node_pos $node_(3) 35
set node_(4) [$ns node]
$node_(4) set X_ 297
$node_(4) set Y_ 496
$node_(4) set Z_ 0.0
$ns initial_node_pos $node_(4) 35
set node_(5) [$ns node]
$node_(5) set X_ 297
$node_(5) set Y_ 496
$node_(5) set Z_ 0.0
$ns initial_node_pos $node_(5) 35
set node_(6) [$ns node]
$node_(6) set X_ 296
$node_(6) set Y_ 495
$node_(6) set Z_ 0.0
$ns initial_node_pos $node_(6) 35
set node_(7) [$ns node]
$node_(7) set X_ 293
$node_(7) set Y_ 494
$node_(7) set Z_ 0.0
$ns initial_node_pos $node_(7) 35
set node_(8) [$ns node]
$node_(8) set X_ 297
$node_(8) set Y_ 495
$node_(8) set Z_ 0.0
$ns initial_node_pos $node_(8) 35
set node_(9) [$ns node]
$node_(9) set X_ 299
$node_(9) set Y_ 496
$node_(9) set Z_ 0.0
$ns initial_node_pos $node_(9) 35
set node_(10) [$ns node]
$node_(10) set X_ 300
$node_(10) set Y_ 496
$node_(10) set Z_ 0.0
$ns initial_node_pos $node_(10) 35
set node_(11) [$ns node]
$node_(11) set X_ 855
$node_(11) set Y_ 439
$node_(11) set Z_ 0.0
$ns initial_node_pos $node_(11) 35
set node_(12) [$ns node]
$node_(12) set X_ 904
$node_(12) set Y_ 497
$node_(12) set Z_ 0.0
$ns initial_node_pos $node_(12) 35
set node_(13) [$ns node]
$node_(13) set X_ 904
$node_(13) set Y_ 497
$node_(13) set Z_ 0.0
$ns initial_node_pos $node_(13) 35
set node_(14) [$ns node]
$node_(14) set X_ 904
$node_(14) set Y_ 497
$node_(14) set Z_ 0.0
$ns initial_node_pos $node_(14) 35
set node_(15) [$ns node]
$node_(15) set X_ 900
$node_(15) set Y_ 490
$node_(15) set Z_ 0.0
$ns initial_node_pos $node_(15) 35
set node_(16) [$ns node]
$node_(16) set X_ 904
$node_(16) set Y_ 497
$node_(16) set Z_ 0.0
$ns initial_node_pos $node_(16) 35
set node_(17) [$ns node]
$node_(17) set X_ 904
$node_(17) set Y_ 497
$node_(17) set Z_ 0.0
$ns initial_node_pos $node_(17) 35
set node_(18) [$ns node]
$node_(18) set X_ 904
$node_(18) set Y_ 497
$node_(18) set Z_ 0.0
$ns initial_node_pos $node_(18) 35
set node_(19) [$ns node]
$node_(19) set X_ 904
$node_(19) set Y_ 497
$node_(19) set Z_ 0.0
$ns initial_node_pos $node_(19) 35
set node_(20) [$ns node]
$node_(20) set X_ 0.0
$node_(20) set Y_ 0.0
$node_(20) set Z_ 0.0
$ns initial_node_pos $node_(20) 35
set node_(21) [$ns node]
$node_(21) set X_ 0.0
$node_(21) set Y_ 0.0
$node_(21) set Z_ 0.0
$ns initial_node_pos $node_(21) 0.1
set node_(22) [$ns node]
$node_(22) set X_ 0.0
$node_(22) set Y_ 0.0
$node_(22) set Z_ 0.0
$ns initial_node_pos $node_(22) 0.1
set node_(23) [$ns node]
$node_(23) set X_ 0.0
$node_(23) set Y_ 0.0
$node_(23) set Z_ 0.0
$ns initial_node_pos $node_(23) 0.1
set node_(24) [$ns node]
$node_(24) set X_ 0.0
$node_(24) set Y_ 0.0
$node_(24) set Z_ 0.0
$ns initial_node_pos $node_(24) 35
set node_(25) [$ns node]
$node_(25) set X_ 0.0
$node_(25) set Y_ 0.0
$node_(25) set Z_ 0.0
$ns initial_node_pos $node_(25) 35
set node_(26) [$ns node]
$node_(26) set X_ 0.0
$node_(26) set Y_ 0.0
$node_(26) set Z_ 0.0
$ns initial_node_pos $node_(26) 35
set node_(27) [$ns node]
$node_(27) set X_ 0.0
$node_(27) set Y_ 0.0
$node_(27) set Z_ 0.0
$ns initial_node_pos $node_(27) 35
set node_(28) [$ns node]
$node_(28) set X_ 726
$node_(28) set Y_ 204
$node_(28) set Z_ 0.0
$ns initial_node_pos $node_(28) 35
set node_(29) [$ns node]
$node_(29) set X_ 904
$node_(29) set Y_ 497
$node_(29) set Z_ 0.0
$ns initial_node_pos $node_(29) 35
set node_(30) [$ns node]
$node_(30) set X_ 904
$node_(30) set Y_ 497
$node_(30) set Z_ 0.0
$ns initial_node_pos $node_(30) 35
set node_(31) [$ns node]
$node_(31) set X_ 0.0
$node_(31) set Y_ 0.0
$node_(31) set Z_ 0.0
$ns initial_node_pos $node_(31) 35
set node_(32) [$ns node]
$node_(32) set X_ 0.0
$node_(32) set Y_ 0.0
$node_(32) set Z_ 0.0
$ns initial_node_pos $node_(32) 35

set node_(33) [$ns node]
$node_(33) set X_ 808.0
$node_(33) set Y_ 578.0
$node_(33) set Z_ 0.0
$ns initial_node_pos $node_(33) 5
set node_(34) [$ns node]
$node_(34) set X_ 808.0
$node_(34) set Y_ 578.0
$node_(34) set Z_ 0.0
$ns initial_node_pos $node_(34) 5

set node_(35) [$ns node]
$node_(35) set X_ 808.0
$node_(35) set Y_ 578.0
$node_(35) set Z_ 0.0
$ns initial_node_pos $node_(35) 5

set node_(36) [$ns node]
$node_(36) set X_ 808.0
$node_(36) set Y_ 578.0
$node_(36) set Z_ 0.0
$ns initial_node_pos $node_(36) 5
set node_(37) [$ns node]
$node_(37) set X_ 808.0
$node_(37) set Y_ 578.0
$node_(37) set Z_ 0.0
$ns initial_node_pos $node_(37) 5

set node_(38) [$ns node]
$node_(38) set X_ 808.0
$node_(38) set Y_ 578.0
$node_(38) set Z_ 0.0
$ns initial_node_pos $node_(38) 5
set node_(39) [$ns node]
$node_(39) set X_ 808.0
$node_(39) set Y_ 578.0
$node_(39) set Z_ 0.0
$ns initial_node_pos $node_(39) 5
set node_(40) [$ns node]
$node_(40) set X_ 808.0
$node_(40) set Y_ 578.0
$node_(40) set Z_ 0.0
$ns initial_node_pos $node_(40) 5
set node_(41) [$ns node]
$node_(41) set X_ 808.0
$node_(41) set Y_ 578.0
$node_(41) set Z_ 0.0
$ns initial_node_pos $node_(41) 5




set sink0 [new Agent/LossMonitor]
set sink1 [new Agent/LossMonitor]
set sink2 [new Agent/LossMonitor]
set sink3 [new Agent/LossMonitor]
set sink4 [new Agent/LossMonitor]
set sink5 [new Agent/LossMonitor]
set sink6 [new Agent/LossMonitor]
set sink7 [new Agent/LossMonitor]
set sink8 [new Agent/LossMonitor]
set sink9 [new Agent/LossMonitor]
set sink10 [new Agent/LossMonitor]
set sink11 [new Agent/LossMonitor]
set sink12 [new Agent/LossMonitor]
set sink13 [new Agent/LossMonitor]
set sink14 [new Agent/LossMonitor]
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




$ns attach-agent $node_(0) $sink0
$ns attach-agent $node_(1) $sink1
$ns attach-agent $node_(2) $sink2
$ns attach-agent $node_(3) $sink3
$ns attach-agent $node_(4) $sink4
$ns attach-agent $node_(5) $sink5
$ns attach-agent $node_(6) $sink6
$ns attach-agent $node_(7) $sink7
$ns attach-agent $node_(8) $sink8
$ns attach-agent $node_(9) $sink9
$ns attach-agent $node_(10) $sink10
$ns attach-agent $node_(11) $sink11
$ns attach-agent $node_(12) $sink12
$ns attach-agent $node_(13) $sink13
$ns attach-agent $node_(14) $sink14
$ns attach-agent $node_(15) $sink15
$ns attach-agent $node_(16) $sink16
$ns attach-agent $node_(17) $sink17
$ns attach-agent $node_(18) $sink18
$ns attach-agent $node_(19) $sink19
$ns attach-agent $node_(20) $sink20
$ns attach-agent $node_(21) $sink21
$ns attach-agent $node_(22) $sink22
$ns attach-agent $node_(23) $sink23
$ns attach-agent $node_(24) $sink24
$ns attach-agent $node_(25) $sink25
$ns attach-agent $node_(26) $sink26
$ns attach-agent $node_(27) $sink27
$ns attach-agent $node_(28) $sink28
$ns attach-agent $node_(29) $sink29
$ns attach-agent $node_(30) $sink30
$ns attach-agent $node_(31) $sink31
$ns attach-agent $node_(32) $sink32



set udp0 [new Agent/UDP]
$udp0 set prio_ 1   
$ns attach-agent $node_(0) $udp0
set udp1 [new Agent/UDP]
$udp1 set prio_ 2
$ns attach-agent $node_(1) $udp1
set udp2 [new Agent/UDP]
$udp2 set prio_ 3
$ns attach-agent $node_(2) $udp2
set udp3 [new Agent/UDP]
$ns attach-agent $node_(3) $udp3
set udp4 [new Agent/UDP]
$udp4 set prio_ 4
$ns attach-agent $node_(4) $udp4
set udp5 [new Agent/UDP]
$ns attach-agent $node_(5) $udp5
set udp6 [new Agent/UDP]
$ns attach-agent $node_(6) $udp6
set udp7 [new Agent/UDP]
$ns attach-agent $node_(7) $udp7
set udp8 [new Agent/UDP]
$ns attach-agent $node_(8) $udp8
set udp9 [new Agent/UDP]
$ns attach-agent $node_(9) $udp9
set udp10 [new Agent/UDP]
$ns attach-agent $node_(10) $udp10
set udp11 [new Agent/UDP]
$udp11 set prio_ 5
$ns attach-agent $node_(11) $udp11
set udp12 [new Agent/UDP]
$udp12 set prio_ 6
$ns attach-agent $node_(12) $udp12
set udp13 [new Agent/UDP]
$udp13 set prio_ 7
$ns attach-agent $node_(13) $udp13
set udp14 [new Agent/UDP]
$udp14 set prio_ 8
$ns attach-agent $node_(14) $udp14
set udp15 [new Agent/UDP]
$ns attach-agent $node_(15) $udp15
set udp16 [new Agent/UDP]
$ns attach-agent $node_(16) $udp16
set udp17 [new Agent/UDP]
$ns attach-agent $node_(17) $udp17
set udp18 [new Agent/UDP]
$ns attach-agent $node_(18) $udp18
set udp19 [new Agent/UDP]
$ns attach-agent $node_(19) $udp19
set udp20 [new Agent/UDP]
$ns attach-agent $node_(20) $udp20
set udp21 [new Agent/UDP]
$ns attach-agent $node_(21) $udp21
set udp22 [new Agent/UDP]
$ns attach-agent $node_(22) $udp22
set udp23 [new Agent/UDP]
$ns attach-agent $node_(23) $udp23
set udp24 [new Agent/UDP]
$ns attach-agent $node_(24) $udp24
set udp25 [new Agent/UDP]
$ns attach-agent $node_(25) $udp25
set udp26 [new Agent/UDP]
$ns attach-agent $node_(26) $udp26
set udp27 [new Agent/UDP]
$ns attach-agent $node_(27) $udp27
set udp28 [new Agent/UDP]
$ns attach-agent $node_(28) $udp28
set udp29 [new Agent/UDP]
$ns attach-agent $node_(29) $udp29
set udp30 [new Agent/UDP]
$ns attach-agent $node_(30) $udp30
set udp31 [new Agent/UDP]
$ns attach-agent $node_(31) $udp31
set udp32 [new Agent/UDP]
$ns attach-agent $node_(32) $udp32

set threshold 500

for {set i 0} {$i <= 0  } { incr i } {
for {set j 0} {$j < 10 } { incr j } {
set x1 [$node_($i) set X_]
set y1 [$node_($i) set Y_]
set x2 [$node_($j) set X_]
set y2 [$node_($j) set Y_]
set distance [expr "sqrt(($x2-$x1)*($x2-$x1)+($y2-$y1)*($y2-$y1)+15)"]
}
}

for {set k 10} {$k <= 10  } { incr k } {
for {set l 10} {$l < 19 } { incr l } {
set x1 [$node_($k) set X_]
set y1 [$node_($k) set Y_]
set x2 [$node_($l) set X_]
set y2 [$node_($l) set Y_]
set distance1 [expr "sqrt(($x2-$x1)*($x2-$x1)+($y2-$y1)*($y2-$y1)+22)"]
}
}

for {set m 19} {$m <= 19  } { incr m } {
for {set n 19} {$n < 29 } { incr n } {
set x1 [$node_($m) set X_]
set y1 [$node_($m) set Y_]
set x2 [$node_($n) set X_]
set y2 [$node_($n) set Y_]
set distance2 [expr "sqrt(($x2-$x1)*($x2-$x1)+($y2-$y1)*($y2-$y1)+41)"]
}
}
set trust29 19
set trust1 4864
set trust11 3724
set trust20 6156

set trust9 2299
set trust30 3211
set trust27 5678

$ns at 1.01 "$ns trace-annotate \" cluster_head  node id_1first cluster distance range $distance \""
$ns at 1.03 "$ns trace-annotate \" cluster_head  node id_11second cluster distance range $distance1 \""
$ns at 1.06 "$ns trace-annotate \" cluster_head  node id_20third cluster distance range $distance2 \""
$ns at 0.0 "$ns trace-annotate \" Process started.....\""
$ns at 0.2 "$ns trace-annotate \" dummy packets are sended to all nodes of the cluster in order to calculate the trust value using QOS parameters .....\""




$ns at 1.10 "$node_(6)  label  SINK"
$ns at 1.11 "$node_(18)  label  SINK"
$ns at 1.13 "$node_(32)  label  SINK"
$ns at 7.5 "$node_(8)  label  SINK"

$node_(6) color blue
$ns at 1.10 "$node_(6) color blue"
$node_(18) color blue
$ns at 1.11 "$node_(18) color blue"
$node_(32) color blue
$ns at 1.13 "$node_(32) color blue"
$node_(15) color blue
$ns at 1.11 "$node_(15) color blue"
$node_(28) color blue
$ns at 1.13 "$node_(28) color blue"
$node_(8) color blue
$ns at 7.5 "$node_(8) color blue"
$node_(0) color blue
$ns at 7.5 "$node_(0) color blue"




$ns at 1.10 "$node_(1)  label  cluster_head"
$ns at 1.11 "$node_(11)  label  cluster_head"
$ns at 1.13 "$node_(20)  label  cluster_head"

$ns at 1.50 "$node_(1)  label  cluster_head"
$ns at 1.51 "$node_(11)  label  cluster_head"
$ns at 1.53 "$node_(20)  label cluster_head"

$ns at 7.10 "$node_(1)  label  100J"
$ns at 7.11 "$node_(11)  label  96J"
$ns at 7.13 "$node_(20)  label  125J"

$ns at 7.10 "$node_(9)  label  cluster_head"
$ns at 7.11 "$node_(30)  label  cluster_head"
$ns at 7.13 "$node_(27)  label  cluster_head"
$ns at 2.53 "$node_(10)  label  source"
$ns at 2.53 "$node_(25)  label  destination"

$ns at 3.9 "$node_(31)  label  source"
$ns at 3.9 "$node_(14)  label  destination"

$ns at 6.8 "$node_(31)  label  source"
$ns at 6.8 "$node_(14)  label  destination"


$node_(10) color brown
$ns at 2.53 "$node_(10) color brown"
$node_(25) color brown
$ns at 2.53 "$node_(25) color brown"
$node_(22) color brown
$ns at 2.53 "$node_(22) color brown"


$node_(31) color brown
$ns at 3.9 "$node_(31) color brown"
$node_(14) color brown
$ns at 3.9 "$node_(14) color brown"

$node_(31) color brown
$ns at 6.8 "$node_(31) color brown"
$node_(14) color brown
$ns at 6.8 "$node_(14) color brown"




$node_(10) color skyblue
$ns at 3.75 "$node_(10) color skyblue"
$node_(25) color red
$ns at 3.75 "$node_(25) color red"
$node_(22) color red
$ns at 3.75 "$node_(22) color red"


$ns at 3.75 "$node_(10)  label  92j"
$ns at 3.75 "$node_(25)  label  32j"

$ns at 6.02 "$node_(31)  label  63j"
$ns at 6.02 "$node_(14)  label  81j"

$node_(31) color red
$ns at 6.02 "$node_(31) color red"
$node_(14) color pink
$ns at 6.02 "$node_(14) color pink"


$node_(1) color darkgreen
$ns at 1.10 "$node_(1) color darkgreen"
$node_(11) color darkgreen
$ns at 1.11 "$node_(11) color darkgreen"
$node_(20) color darkgreen
$ns at 1.13 "$node_(20) color darkgreen"

$node_(1) color skyblue
$ns at 7.10 "$node_(1) color skyblue"
$node_(11) color pink
$ns at 7.11 "$node_(11) color pink"
$node_(20) color red
$ns at 7.13 "$node_(20) color red"

$node_(9) color darkgreen
$ns at 7.10 "$node_(9) color darkgreen"
$node_(30) color darkgreen
$ns at 7.11 "$node_(30) color darkgreen"
$node_(27) color darkgreen
$ns at 7.13 "$node_(27) color darkgreen"


$ns at 1.25 "$node_(0)  label  nodeid_no_0"
$ns at 1.26 "$node_(1)  label  nodeid_no_1"
$ns at 1.27 "$node_(2)  label  nodeid_no_2"
$ns at 1.28 "$node_(3)  label  nodeid_no_3"
$ns at 1.29 "$node_(4)  label  nodeid_no_4"
#$ns at 1.30 "$node_(5)  label  nodeid_no_5"
#$ns at 1.31 "$node_(6)  label  nodeid_no_6"
#$ns at 1.32 "$node_(7)  label  nodeid_no_7"
#$ns at 1.33 "$node_(8)  label  nodeid_no_8"
$ns at 1.34 "$node_(9)  label  nodeid_no_9"
$ns at 1.35 "$node_(10)  label  nodeid_no_10"
$ns at 1.36 "$node_(11)  label  nodeid_no_11"
$ns at 1.37 "$node_(12)  label  nodeid_no_12"
#$ns at 1.38 "$node_(13)  label  nodeid_no_13"
$ns at 1.39 "$node_(14)  label  nodeid_no_14"
#$ns at 1.40 "$node_(15)  label  nodeid_no_15"
$ns at 1.41 "$node_(16)  label  nodeid_no_16"
$ns at 1.42 "$node_(17)  label  nodeid_no_17"
#$ns at 1.43 "$node_(18)  label  nodeid_no_18"
#$ns at 1.44 "$node_(19)  label  nodeid_no_19"
$ns at 1.45 "$node_(29)  label  nodeid_no_29"
$ns at 1.46 "$node_(30)  label  nodeid_no_30"
$ns at 1.47 "$node_(20)  label  nodeid_no_20"
#$ns at 1.48 "$node_(21)  label  nodeid_no_21"
#$ns at 1.49 "$node_(22)  label  nodeid_no_22"
#$ns at 1.50 "$node_(23)  label  nodeid_no_23"
$ns at 1.51 "$node_(24)  label  nodeid_no_24"
$ns at 1.52 "$node_(25)  label  nodeid_no_25"

$ns at 1.53 "$node_(26)  label  nodeid_no_26"
$ns at 1.54 "$node_(27)  label  nodeid_no_27"
#$ns at 1.55 "$node_(28)  label  nodeid_no_28"
$ns at 1.56 "$node_(31)  label  nodeid_no_31"
#$ns at 1.57 "$node_(32)  label  nodeid_no_32"

$ns at 0.1 "$node_(2) setdest 537.0 498.0 500.0"
$ns at 0.1 "$node_(3) setdest 304.0 733.0 500.0"
$ns at 0.1 "$node_(4) setdest 54.0 495.0 500.0"
$ns at 0.1 "$node_(5) setdest 54.0 495.0 500.0"
$ns at 0.1 "$node_(6) setdest 456.0 317.0 500.0"
$ns at 0.1 "$node_(7) setdest 536.0 498.0 500.0"
$ns at 0.1 "$node_(8) setdest 299.0 248.0 500.0"
$ns at 0.1 "$node_(9) setdest 404.0 445.0 500.0"
$ns at 0.1 "$node_(10) setdest 184.0 446.0 500.0"


$ns at 0.1 "$node_(12) setdest 706.0 499.0 500.0"
$ns at 0.1 "$node_(13) setdest 758.0 650.0 500.0"
$ns at 0.1 "$node_(14) setdest 899.0 706.0 500.0"
$ns at 0.1 "$node_(15) setdest 759.0 342.0 500.0"
$ns at 0.1 "$node_(16) setdest 758.0 651.0 500.0"
$ns at 0.1 "$node_(17) setdest 1039.0 664.0 500.0"


$ns at 0.1 "$node_(18) setdest 759.0 342.0 500.0"
$ns at 0.1 "$node_(19) setdest 1038.0 663.0 500.0"
$ns at 0.1 "$node_(29) setdest 808.0 578.0 500.0"
$ns at 0.1 "$node_(30) setdest 992.0 559.0 500.0"

$ns at 0.1 "$node_(21) setdest 778.0 21.0 1000.0"
$ns at 0.1 "$node_(22) setdest 537.0 11.0 1000.0"

$ns at 0.1 "$node_(20) setdest 642.0 109.0 1000.0"
$ns at 0.1 "$node_(23) setdest 628.0 270.0 1000.0"
$ns at 0.1 "$node_(24) setdest 630.0 271.0 1000.0"
$ns at 0.1 "$node_(25) setdest 539.0 12.0 1000.0"
$ns at 0.1 "$node_(26) setdest 778.0 21.0 1000.0"
$ns at 0.1 "$node_(27) setdest 548.0 202.0 1000.0"
$ns at 0.1 "$node_(31) setdest 646.0 17.0 1000.0"
$ns at 0.1 "$node_(32) setdest 726.0 204.0 1000.0"

$ns at 7.45 "$node_(6) setdest 544.0 120.0 700.0"
$node_(6) color red
$ns at 7.78 "$node_(6) color red"

$node_(6) color darkgreen
$ns at 7.9 "$node_(6) color darkgreen"

$node_(27) color red
$ns at 7.9 "$node_(27) color red"
$ns at 7.9 "$node_(27)  label  90j"


$ns at 7.9 "$node_(6)  label  cluster_head"


$ns at 1.85 "$node_(0)  label  45J"
$ns at 1.86 "$node_(1)  label  117J"
$ns at 1.87 "$node_(2)  label  90J"
$ns at 1.88 "$node_(3)  label  36J"
$ns at 1.89 "$node_(4)  label  63J"
#$ns at 1.90 "$node_(5)  label  nodeid_"
$ns at 7.3 "$node_(6)  label  90J"
#$ns at 1.92 "$node_(7)  label  nodeid_no_7"
#$ns at 1.93 "$node_(8)  label  nodeid_no_8"
$ns at 1.94 "$node_(9)  label  108J"
$ns at 1.95 "$node_(10)  label  92J"
$ns at 1.96 "$node_(11)  label  126J"
$ns at 1.97 "$node_(12)  label  108J"
#$ns at 1.98 "$node_(13)  label  nodeid_no_13"
$ns at 1.99 "$node_(14)  label  81J"
#$ns at 1.80 "$node_(15)  label  nodeid_no_15"
$ns at 1.81 "$node_(16)  label  81J"
$ns at 1.82 "$node_(17)  label  81J"
#$ns at 1.83 "$node_(18)  label  90J"
#$ns at 1.84 "$node_(19)  label  nodeid_no_19"
$ns at 1.85 "$node_(29)  label   9J"
$ns at 1.86 "$node_(30)  label  117J"
$ns at 1.87 "$node_(20)  label  162J"
#$ns at 1.88 "$node_(21)  label  nodeid_no_21"
#$ns at 1.89 "$node_(22)  label  nodeid_no_22"
#$ns at 1.90 "$node_(23)  label  nodeid_no_23"
$ns at 1.91 "$node_(24)  label  81J"
$ns at 1.92 "$node_(25)  label  32J"

$ns at 1.93 "$node_(26)  label  41J"
$ns at 1.94 "$node_(27)  label  161J"
$ns at 1.95 "$node_(28)  label  9J"
$ns at 1.96 "$node_(31)  label  63J"
#$ns at 1.97 "$node_(32)  label  50J"


$ns at 4.2 "$node_(33) setdest 777.0 20.0 800.0"
$ns at 4.24 "$node_(34) setdest 777.0 20.0 800.0"
$ns at 4.28 "$node_(35) setdest 777.0 20.0 800.0"
$ns at 4.32 "$node_(36) setdest 777.0 20.0 800.0"
$ns at 4.36 "$node_(37) setdest 777.0 20.0 800.0"

$ns at 5.0 "$node_(29) setdest 1407.0 581.0 800.0"
$ns at 5.0 "$node_(38) setdest 1407.0 581.0 800.0"
$ns at 5.0 "$node_(39) setdest 1407.0 581.0 800.0"
$ns at 5.0 "$node_(40) setdest 1407.0 581.0 800.0"
$ns at 5.0 "$node_(41) setdest 1407.0 581.0 800.0"

$ns at 6.0 "$node_(29) setdest 808.0 578.0 800.0"
$ns at 6.0 "$node_(38) setdest 808.0 578.0 800.0"
$ns at 6.0 "$node_(39) setdest 808.0 578.0 800.0"
$ns at 6.0 "$node_(40) setdest 808.0 578.0 800.0"
$ns at 6.0 "$node_(41) setdest 808.0 578.0 800.0"

$ns at 7.4 "$node_(38) setdest 777.0 20.0 800.0"
$ns at 7.44 "$node_(39) setdest 777.0 20.0 800.0"
$ns at 7.48 "$node_(40) setdest 777.0 20.0 800.0"
$ns at 7.52 "$node_(41) setdest 777.0 20.0 800.0"

$ns at 8.0 "$node_(29) setdest 1407.0 581.0 800.0"


$ns at 0.1 "$node_(33)  label  ."
$ns at 0.1 "$node_(34)  label  ."
$ns at 0.1 "$node_(35)  label  ."

$ns at 0.1 "$node_(36)  label  ."
$ns at 0.1 "$node_(37)  label  ."



$node_(38) color grey
$ns at 4.2 "$node_(38) color grey"
$node_(38) color grey
$ns at 4.2 "$node_(38) color grey"
$node_(39) color grey
$ns at 4.2 "$node_(39) color grey"
$node_(40) color grey
$ns at 4.2 "$node_(40) color grey"
$node_(41) color grey
$ns at 4.2 "$node_(41) color grey"




$node_(33) color pink
$ns at 0.13 "$node_(33) color pink"
$node_(34) color pink
$ns at 0.13 "$node_(34) color pink"
$node_(35) color pink
$ns at 0.13 "$node_(35) color pink"
$node_(36) color pink
$ns at 0.13 "$node_(36) color pink"
$node_(37) color pink
$ns at 0.13 "$node_(37) color pink"


$node_(38) color pink
$ns at 0.13 "$node_(38) color pink"
$node_(39) color pink
$ns at 0.13 "$node_(39) color pink"
$node_(40) color pink
$ns at 0.13 "$node_(40) color pink"
$node_(41) color pink
$ns at 0.13 "$node_(41) color pink"


$node_(33) color blue
$ns at 4.2 "$node_(33) color blue"
$node_(34) color blue
$ns at 4.22 "$node_(34) color blue"
$node_(35) color blue
$ns at 4.24 "$node_(35) color blue"
$node_(36) color blue
$ns at 4.26 "$node_(36) color blue"
$node_(37) color blue
$ns at 4.28 "$node_(37) color blue"

$node_(38) color blue
$ns at 7.4 "$node_(38) color blue"
$node_(39) color blue
$ns at 7.4 "$node_(39) color blue"
$node_(40) color blue
$ns at 7.4 "$node_(40) color blue"
$node_(41) color blue
$ns at 7.4 "$node_(41) color blue"

$node_(38) color red
$ns at 8.09 "$node_(38) color red"
$node_(39) color red
$ns at 8.13 "$node_(39) color red"
$node_(40) color red
$ns at 8.17 "$node_(40) color red"
$node_(41) color red
$ns at 8.21 "$node_(41) color red"



$node_(33) color red
$ns at 4.9 "$node_(33) color red"
$node_(34) color red
$ns at 4.94 "$node_(34) color red"
$node_(35) color red
$ns at 4.98 "$node_(35) color red"
$node_(36) color red
$ns at 5.02 "$node_(36) color red"
$node_(37) color red
$ns at 5.06 "$node_(37) color red"

for {set i 0} {$i <=10  } { incr i } {
	for {set j 0} {$j < $val(nn) } { incr j } {
$node_($i) color skyblue
$ns at 0.1 "$node_($i) color skyblue"
}
}

for {set i 11} {$i <=19  } { incr i } {
	for {set j 0} {$j < $val(nn) } { incr j } {
$node_($i) color  pink
$ns at 0.13 "$node_($i) color pink"
}
}

for {set i 20} {$i <=28  } { incr i } {
	for {set j 0} {$j < $val(nn) } { incr j } {
$node_($i) color  red
$ns at 0.16 "$node_($i) color red"
}
}

$node_(29) color  pink
$ns at 0.13 "$node_(29) color pink"
$node_(30) color  pink
$ns at 0.13 "$node_(30) color pink"

$node_(31) color  red
$ns at 0.16 "$node_(31) color red"
$node_(32) color  red
$ns at 0.16 "$node_(32) color red"

set tcp(1) [$ns create-connection TCP $node_(31) TCPSink $node_(20) 2]

set ftp(1) [$tcp(1) attach-app FTP]

set tcp(2) [$ns create-connection TCP $node_(20) TCPSink $node_(32) 2]

set ftp(2) [$tcp(2) attach-app FTP]

set tcp(3) [$ns create-connection TCP $node_(32) TCPSink $node_(18) 2]

set ftp(3) [$tcp(3) attach-app FTP]


set tcp(4) [$ns create-connection TCP $node_(18) TCPSink $node_(11) 2]
set ftp(4) [$tcp(4) attach-app FTP]

set tcp(5) [$ns create-connection TCP $node_(10) TCPSink $node_(1) 2]
set ftp(5) [$tcp(5) attach-app FTP]

set tcp(6) [$ns create-connection TCP $node_(1) TCPSink $node_(9) 2]
set ftp(6) [$tcp(6) attach-app FTP]

set tcp(7) [$ns create-connection TCP $node_(9) TCPSink $node_(6) 2]
set ftp(7) [$tcp(7) attach-app FTP]

set tcp(8) [$ns create-connection TCP $node_(6) TCPSink $node_(27) 2]
set ftp(8) [$tcp(8) attach-app FTP]

set tcp(9) [$ns create-connection TCP $node_(27) TCPSink $node_(20) 2]
set ftp(9) [$tcp(9) attach-app FTP]

set tcp(10) [$ns create-connection TCP $node_(20) TCPSink $node_(25) 2]
set ftp(10) [$tcp(10) attach-app FTP]

set tcp(11) [$ns create-connection TCP $node_(31) TCPSink $node_(20) 2]
set ftp(11) [$tcp(11) attach-app FTP]

set tcp(12) [$ns create-connection TCP $node_(20) TCPSink $node_(28) 2]
set ftp(12) [$tcp(12) attach-app FTP]

set tcp(13) [$ns create-connection TCP $node_(28) TCPSink $node_(18) 2]
set ftp(13) [$tcp(13) attach-app FTP]

set tcp(14) [$ns create-connection TCP $node_(18) TCPSink $node_(11) 2]
set ftp(14) [$tcp(14) attach-app FTP]

set tcp(15) [$ns create-connection TCP $node_(11) TCPSink $node_(29) 2]
set ftp(15) [$tcp(15) attach-app FTP]

set tcp(16) [$ns create-connection TCP $node_(11) TCPSink $node_(12) 2]
set ftp(16) [$tcp(16) attach-app FTP]

set tcp(17) [$ns create-connection TCP $node_(12) TCPSink $node_(16) 2]
set ftp(17) [$tcp(17) attach-app FTP]

set tcp(18) [$ns create-connection TCP $node_(16) TCPSink $node_(14) 2]
set ftp(18) [$tcp(18) attach-app FTP]

set tcp(19) [$ns create-connection TCP $node_(11) TCPSink $node_(30) 2]
set ftp(19) [$tcp(19) attach-app FTP]

set tcp(20) [$ns create-connection TCP $node_(30) TCPSink $node_(19) 2]
set ftp(20) [$tcp(20) attach-app FTP]

set tcp(21) [$ns create-connection TCP $node_(19) TCPSink $node_(14) 2]
set ftp(21) [$tcp(21) attach-app FTP]

set number_of_tcp 5




set inrtt 0.3
set inbw 0.5
set mypacketsize 1000
#set start_simulation 
set end_simulation 10.5 
set start_stats  0.1
set end_stats 10 

proc TCP_setup {} {
global ns tcp 

$tcp(1) set maxcwnd_ 7
$tcp(1) set ssthresh_ 4
$tcp(1) set packetSize_ 1000
$tcp(1) set fid_ 3

$tcp(2) set maxcwnd_ 7
$tcp(2) set ssthresh_ 4
$tcp(2) set packetSize_ 1000
$tcp(2) set fid_ 3

$tcp(3) set maxcwnd_ 7
$tcp(3) set ssthresh_ 4
$tcp(3) set packetSize_ 1000
$tcp(3) set fid_ 3

$tcp(4) set maxcwnd_ 7
$tcp(4) set ssthresh_ 4
$tcp(4) set packetSize_ 1000
$tcp(4) set fid_ 3

$tcp(5) set maxcwnd_ 7
$tcp(5) set ssthresh_ 4
$tcp(5) set packetSize_ 1000
$tcp(5) set fid_ 3

$tcp(6) set maxcwnd_ 7
$tcp(6) set ssthresh_ 4
$tcp(6) set packetSize_ 1000
$tcp(6) set fid_ 3

$tcp(7) set maxcwnd_ 7
$tcp(7) set ssthresh_ 4
$tcp(7) set packetSize_ 1000
$tcp(7) set fid_ 3

$tcp(8) set maxcwnd_ 7
$tcp(8) set ssthresh_ 4
$tcp(8) set packetSize_ 1000
$tcp(8) set fid_ 3

$tcp(9) set maxcwnd_ 7
$tcp(9) set ssthresh_ 4
$tcp(9) set packetSize_ 1000
$tcp(9) set fid_ 3

$tcp(10) set maxcwnd_ 7
$tcp(10) set ssthresh_ 4
$tcp(10) set packetSize_ 1000
$tcp(10) set fid_ 3

$tcp(11) set maxcwnd_ 7
$tcp(11) set ssthresh_ 4
$tcp(11) set packetSize_ 1000
$tcp(11) set fid_ 3

$tcp(12) set maxcwnd_ 7
$tcp(12) set ssthresh_ 4
$tcp(12) set packetSize_ 1000
$tcp(12) set fid_ 3

$tcp(13) set maxcwnd_ 7
$tcp(13) set ssthresh_ 4
$tcp(13) set packetSize_ 1000
$tcp(13) set fid_ 3

$tcp(14) set maxcwnd_ 7
$tcp(14) set ssthresh_ 4
$tcp(14) set packetSize_ 1000
$tcp(14) set fid_ 3

$tcp(15) set maxcwnd_ 7
$tcp(15) set ssthresh_ 4
$tcp(15) set packetSize_ 1000
$tcp(15) set fid_ 3

$tcp(16) set maxcwnd_ 7
$tcp(16) set ssthresh_ 4
$tcp(16) set packetSize_ 1000
$tcp(16) set fid_ 3

$tcp(17) set maxcwnd_ 7
$tcp(17) set ssthresh_ 4
$tcp(17) set packetSize_ 1000
$tcp(17) set fid_ 3

$tcp(18) set maxcwnd_ 7
$tcp(18) set ssthresh_ 4
$tcp(18) set packetSize_ 1000
$tcp(18) set fid_ 3

$tcp(19) set maxcwnd_ 7
$tcp(19) set ssthresh_ 4
$tcp(19) set packetSize_ 1000
$tcp(19) set fid_ 3

$tcp(20) set maxcwnd_ 7
$tcp(20) set ssthresh_ 4
$tcp(20) set packetSize_ 1000
$tcp(20) set fid_ 3

$tcp(21) set maxcwnd_ 7
$tcp(21) set ssthresh_ 4
$tcp(21) set packetSize_ 1000
$tcp(21) set fid_ 3



}
set stats_interv [expr $end_stats - $start_stats]

proc init_stats {} {
    global ns tcp inrtt start_stats number_of_tcp
    for {set x 1} {$x<[expr $number_of_tcp+1]} {incr x} {
      $tcp($x) set ndatapack_ 0
      $tcp($x) set ndatabytes_ 0
    }
    $ns at [expr $start_stats + $inrtt*2] "init_more_stats"
}

proc init_more_stats {} {
    global ns tcp number_of_tcp
    for {set x 1} {$x<[expr $number_of_tcp+1]} {incr x} {
      $tcp($x) set nackpack_ 0
    }
}



proc compute_stats {} {
    global ns tcp inrtt inbw mypacketsize stats_interv number_of_tcp
    set totndatabytes 0
    set totnackpack 0
    set totthruput 0
    set totnretxpack 0
    puts "\nSIMULATION REPORT \n"
    puts "#TCP\t\tTXbytes\t\tACK_pkt\t\tThruput\t\tLost_pkts"
      puts "0k"
    for {set x 1} {$x< [expr $number_of_tcp+1]} {incr x} {
      set temp [$tcp($x) set ndatapack_]
      set xndatabytes [expr $mypacketsize*$temp]
      set xnackpack  [$tcp($x) set nackpack_]
      set xnretxpack [$tcp($x) set nrexmitpack_]
      set xthruput [expr $xndatabytes/$stats_interv*8]
      set xgoodput [expr $xnackpack*$mypacketsize/$stats_interv*8]
      puts [format "%3d\t\t%1d\t\t%1d\t\t%3.2f\t%3.2f" $x $xndatabytes $xnackpack $xthruput  $xnretxpack]
      set totndatabytes [expr $totndatabytes + $xndatabytes]
      set totnackpack [expr $totnackpack + $xnackpack]
      set totthruput [expr $totthruput + $xthruput]
      set totnretxpack [expr $totnretxpack + $xnretxpack]
    }

    set totnackbytes [expr $totnackpack * $mypacketsize]
    puts "\nBw\tRTT\tTXbytes\t\tThruput\t\tLost_pkts"
    puts [format "$inbw\t$inrtt\t$totndatabytes\t\t%3.2f\t\t$totnretxpack\n" $totthruput]
    exit 0
}

puts "Starting Simulation..."

$ns at 6.8 "TCP_setup"
$ns at 6.8 "$ftp(1) start"

$ns at 6.83 "TCP_setup"
$ns at 6.83 "$ftp(2) start"


$ns at 6.86 "TCP_setup"
$ns at 6.86 "$ftp(3) start"

$ns at 6.89 "TCP_setup"
$ns at 6.89 "$ftp(4) start"

$ns at 3.1 "TCP_setup"
$ns at 3.1 "$ftp(5) start"
$ns at 3.7 "TCP_setup"
$ns at 3.7 "$ftp(5) stop"

$ns at 3.13 "TCP_setup"
$ns at 3.13 "$ftp(6) start"
$ns at 3.7 "TCP_setup"
$ns at 3.7 "$ftp(6) stop"

$ns at 3.16 "TCP_setup"
$ns at 3.16 "$ftp(7) start"
$ns at 3.7 "TCP_setup"
$ns at 3.7 "$ftp(7) stop"

$ns at 3.18 "TCP_setup"
$ns at 3.18 "$ftp(8) start"
$ns at 3.7 "TCP_setup"
$ns at 3.7 "$ftp(8) stop"

$ns at 3.22 "TCP_setup"
$ns at 3.22 "$ftp(9) start"
$ns at 3.7 "TCP_setup"
$ns at 3.7 "$ftp(9) stop"

$ns at 3.26 "TCP_setup"
$ns at 3.26 "$ftp(10) start"
$ns at 3.7 "TCP_setup"
$ns at 3.7 "$ftp(10) stop"

$ns at 3.9 "TCP_setup"
$ns at 3.9 "$ftp(11) start"
$ns at 5.7 "TCP_setup"
$ns at 5.7 "$ftp(11) stop"

$ns at 3.93 "TCP_setup"
$ns at 3.93 "$ftp(12) start"
$ns at 5.7 "TCP_setup"
$ns at 5.7 "$ftp(12) stop"

$ns at 3.98 "TCP_setup"
$ns at 3.98 "$ftp(13) start"
$ns at 5.7 "TCP_setup"
$ns at 5.7 "$ftp(13) stop"

$ns at 4.0 "TCP_setup"
$ns at 4.0 "$ftp(14) start"
$ns at 5.7 "TCP_setup"
$ns at 5.7 "$ftp(14) stop"

$ns at 4.04 "TCP_setup"
$ns at 4.04 "$ftp(15) start"
$ns at 4.07 "TCP_setup"
$ns at 4.07 "$ftp(15) stop"

$ns at 4.99 "TCP_setup"
$ns at 4.99 "$ftp(16) start"
$ns at 5.7 "TCP_setup"
$ns at 5.7 "$ftp(16) stop"

$ns at 5.04 "TCP_setup"
$ns at 5.04 "$ftp(17) start"
$ns at 5.7 "TCP_setup"
$ns at 5.7 "$ftp(17) stop"

$ns at 5.07 "TCP_setup"
$ns at 5.07 "$ftp(18) start"
$ns at 5.7 "TCP_setup"
$ns at 5.7 "$ftp(18) stop"

$ns at 6.91 "TCP_setup"
$ns at 6.91 "$ftp(19) start"

$ns at 8.2 "TCP_setup"
$ns at 8.2 "$ftp(20) start"

$ns at 8.23 "TCP_setup"
$ns at 8.23 "$ftp(21) start"



#set udp1 [$ns create-connection UDP $node_(10) LossMonitor $node_(1) 0]
#$udp1 set fid_ 1
#set cbr1 [$udp1 attach-app Traffic/CBR]
#$cbr1 set packetSize_ 1000
#$cbr1 set interval_ .07
#$ns at 3.1 "$cbr1 start"
#$ns at 3.7 "$cbr1 stop"

#set udp1 [$ns create-connection UDP $node_(1) LossMonitor $node_(9) 0]
#$udp1 set fid_ 1
#set cbr1 [$udp1 attach-app Traffic/CBR]
#$cbr1 set packetSize_ 1000
#$cbr1 set interval_ .07
#$ns at 3.13 "$cbr1 start"
#$ns at 3.7 "$cbr1 stop"

#set udp1 [$ns create-connection UDP $node_(9) LossMonitor $node_(6) 0]
#$udp1 set fid_ 1
#set cbr1 [$udp1 attach-app Traffic/CBR]
#$cbr1 set packetSize_ 1000
#$cbr1 set interval_ .07
#$ns at 3.16 "$cbr1 start"
#$ns at 3.7 "$cbr1 stop"

#set udp1 [$ns create-connection UDP $node_(6) LossMonitor $node_(27) 0]
#$udp1 set fid_ 1
#set cbr1 [$udp1 attach-app Traffic/CBR]
#$cbr1 set packetSize_ 1000
#$cbr1 set interval_ .07
#$ns at 3.19 "$cbr1 start"
#$ns at 3.7 "$cbr1 stop"

#set udp1 [$ns create-connection UDP $node_(27) LossMonitor $node_(20) 0]
#$udp1 set fid_ 1
#set cbr1 [$udp1 attach-app Traffic/CBR]
#$cbr1 set packetSize_ 1000
#$cbr1 set interval_ .07
#$ns at 3.21 "$cbr1 start"
#$ns at 3.7 "$cbr1 stop"

#set udp1 [$ns create-connection UDP $node_(20) LossMonitor $node_(25) 0]
#$udp1 set fid_ 1
#set cbr1 [$udp1 attach-app Traffic/CBR]
#$cbr1 set packetSize_ 1000
#$cbr1 set interval_ .05
#$ns at 3.26 "$cbr1 start"
#$ns at 3.7 "$cbr1 stop"

#set udp1 [$ns create-connection UDP $node_(31) LossMonitor $node_(20) 0]
#$udp1 set fid_ 1
#set cbr1 [$udp1 attach-app Traffic/CBR]
#$cbr1 set packetSize_ 1000
#$cbr1 set interval_ .05
#$ns at 3.9 "$cbr1 start"
#$ns at 5.7 "$cbr1 stop"

#set udp1 [$ns create-connection UDP $node_(20) LossMonitor $node_(28) 0]
#$udp1 set fid_ 1
#set cbr1 [$udp1 attach-app Traffic/CBR]
#$cbr1 set packetSize_ 1000
#$cbr1 set interval_ .05
#$ns at 3.93 "$cbr1 start"
#$ns at 5.7 "$cbr1 stop"

#set udp1 [$ns create-connection UDP $node_(28) LossMonitor $node_(18) 0]
#$udp1 set fid_ 1
#set cbr1 [$udp1 attach-app Traffic/CBR]
#$cbr1 set packetSize_ 750
#$cbr1 set interval_ .05
#$ns at 3.98 "$cbr1 start"
#$ns at 5.7 "$cbr1 stop"

#set udp1 [$ns create-connection UDP $node_(18) LossMonitor $node_(11) 0]
#$udp1 set fid_ 1
#set cbr1 [$udp1 attach-app Traffic/CBR]
#$cbr1 set packetSize_ 750
#$cbr1 set interval_ .05
#$ns at 4.0 "$cbr1 start"
#$ns at 5.7 "$cbr1 stop"

#set udp1 [$ns create-connection UDP $node_(11) LossMonitor $node_(29) 0]
#$udp1 set fid_ 1
#set cbr1 [$udp1 attach-app Traffic/CBR]
#$cbr1 set packetSize_ 512
#$cbr1 set interval_ .06
#$ns at 4.04 "$cbr1 start"
#$ns at 5.0 "$cbr1 stop"

#set udp1 [$ns create-connection UDP $node_(29) LossMonitor $node_(16) 0]
#$udp1 set fid_ 1
#set cbr1 [$udp1 attach-app Traffic/CBR]
#$cbr1 set packetSize_ 1000
#$cbr1 set interval_ .05
#$ns at 4.08 "$cbr1 start"
#$ns at 4.2 "$cbr1 stop"


#set udp1 [$ns create-connection UDP $node_(16) LossMonitor $node_(14) 0]
#$udp1 set fid_ 1
#set cbr1 [$udp1 attach-app Traffic/CBR]
#$cbr1 set packetSize_ 512
#$cbr1 set interval_ .5
#$ns at 4.08 "$cbr1 start"
#$ns at 4.22 "$cbr1 stop"

#set udp1 [$ns create-connection UDP $node_(11) LossMonitor $node_(12) 0]
#$udp1 set fid_ 1
#set cbr1 [$udp1 attach-app Traffic/CBR]
#$cbr1 set packetSize_ 512
#$cbr1 set interval_ .5
#$ns at 4.99 "$cbr1 start"
#$ns at 5.7 "$cbr1 stop"

#set udp1 [$ns create-connection UDP $node_(12) LossMonitor $node_(16) 0]
#$udp1 set fid_ 1
#set cbr1 [$udp1 attach-app Traffic/CBR]
#$cbr1 set packetSize_ 512
#$cbr1 set interval_ .5
#$ns at 5.03 "$cbr1 start"
#$ns at 5.7 "$cbr1 stop"

#set udp1 [$ns create-connection UDP $node_(16) LossMonitor $node_(14) 0]
#$udp1 set fid_ 1
#set cbr1 [$udp1 attach-app Traffic/CBR]
#$cbr1 set packetSize_ 512
#$cbr1 set interval_ .5
#$ns at 5.06 "$cbr1 start"
#$ns at 5.7 "$cbr1 stop"

#set udp1 [$ns create-connection UDP $node_(11) LossMonitor $node_(30) 0]
#$udp1 set fid_ 1
#set cbr1 [$udp1 attach-app Traffic/CBR]
#$cbr1 set packetSize_ 1000
#$cbr1 set interval_ .6
#$ns at 6.92 "$cbr1 start"

#set udp1 [$ns create-connection UDP $node_(30) LossMonitor $node_(29) 0]
#$udp1 set fid_ 1
#set cbr1 [$udp1 attach-app Traffic/CBR]
#$cbr1 set packetSize_ 1000
#$cbr1 set interval_ .6
#$ns at 6.95 "$cbr1 start"

#set udp1 [$ns create-connection UDP $node_(30) LossMonitor $node_(19) 0]
#$udp1 set fid_ 1
#set cbr1 [$udp1 attach-app Traffic/CBR]
#$cbr1 set packetSize_ 1000
#$cbr1 set interval_ .6
#$ns at 8.2 "$cbr1 start"

#set udp1 [$ns create-connection UDP $node_(19) LossMonitor $node_(14) 0]
#$udp1 set fid_ 1
#set cbr1 [$udp1 attach-app Traffic/CBR]
#$cbr1 set packetSize_ 1000
#$cbr1 set interval_ .6
#$ns at 6.95 "$cbr1 start"


proc cluster {} {

             
          

	if (ClusterHead())
	{       
                set $nsmsg*data=(msg*)pkt.data udp;
                set $nsmember_node = node_rep;
                set $cluster1.node_rep[11]=[0,1,2,3,4,5,6,7,8,9,10]
                set $cluster2.node_rep[11]=[11,12,13,14,15,16,17,18,19,29,30]
                set $cluster3.node_rep[11]=[20,21,22,23,24,25,26,27,28,31,32]		
                set int $energy_level;               
                set int $energy=10joules;
                set $clusterhead1=max_energy-level.cluster1.node_rep;
                set $clusterhead2=max_energy-level.cluster2.node_rep;
                set $clusterhead3=max_energy-level.cluster3.node_rep;
                set threshold_value=5.5
		config_.rp_dsr;
                set rt_upd=routing table_updation

               
               energy_level=(msg*data)*energy-(msg*data);
               
	}
	else
	{  
                begin()
             {
		int energy_level;
                
                cluster1.node_rep[11]=energy_level;

		if (cluster1.node_rep[11]=max_energy_level)
		{
			
			select clusterhead1=cluster1.node_rep->max_energy_level;	
			
                        cluster1.node_rep++;
		}
                  
                if (cluster2.node_rep[11]=max_energy_level)
		{
			
			select clusterhead2=cluster2.node_rep->max_energy_level;	
			
                        cluster2.node_rep++;
                        
		}
               else
  
                     {
                            clusterhead();
                   }
                 
                if (cluster3.node_rep[11]=max_energy_level)
		{
			
			select clusterhead3=cluster3.node_rep->max_energy_level;	
			
			cluster3.node_rep++;
		}
                  else
  
                     {
                            clusterhead();
                   }
}

		
                
                   

		
}
		
};proc attach-CBR-traffic { node sink size interval } {
   set ns [Simulator instance]
   set cbr [new Agent/CBR]
   $ns attach-agent $node $cbr
   $cbr set packetSize_ $size
   $cbr set interval_ $interval

   $ns connect $cbr $sink
   return $cbr
  }   

   set cbr4 [attach-CBR-traffic $node_(2) $sink9 1 .042]
set cbr3 [attach-CBR-traffic $node_(6) $sink9 1 .042]
set cbr5 [attach-CBR-traffic $node_(0) $sink9 1 .042]
set cbr6 [attach-CBR-traffic $node_(10) $sink1 1 .042]
set cbr7 [attach-CBR-traffic $node_(4) $sink5 1 .042]

$ns at 0.5 "$cbr4 start"
$ns at 0.61 "$cbr4 stop"
$ns at 0.65 "$cbr3 start"
$ns at 0.75 "$cbr3 stop"
$ns at 0.58 "$cbr5 start"
$ns at 0.8 "$cbr5 stop"
$ns at 0.19 "$cbr6 start"
$ns at 0.9 "$cbr6 stop"
$ns at 0.62 "$cbr7 start"
$ns at 0.8 "$cbr7 stop"

proc ids {malicious_node} {

     if(node_(29).drop_pkt_udp=true)
{
       update_routing_table<<next_hop node id_no=12
       update_routing_table<<destination id_no=14
       select timer "";
       select "node_() add-mark .white square"
       select node_()malicious_node;
}
  else
{ 
   update routing_table "";
}
 if(node_(29).drop_pkt=false)
{
       update_routing_table<<next_hop node id_no=16
       update_routing_table<<destination id_no=14
       select timer "";
       select route (msg*data)
}
  else
{ 
   update routing_table "";
}  



    };proc attach-CBR-traffic { node sink size interval } {
   set ns [Simulator instance]
   set cbr [new Agent/CBR]
   $ns attach-agent $node $cbr
   $cbr set packetSize_ $size
   $cbr set interval_ $interval

   $ns connect $cbr $sink
   return $cbr
  }   




set cbr8 [attach-CBR-traffic $node_(30) $sink14 1 .042]
set cbr9 [attach-CBR-traffic $node_(30) $sink11 1 .041]
set cbr10 [attach-CBR-traffic $node_(16) $sink14 1 .042] 
set cbr11 [attach-CBR-traffic $node_(25) $sink22 1 .042]
set cbr12 [attach-CBR-traffic $node_(31) $sink25 1 .042]
set cbr13 [attach-CBR-traffic $node_(26) $sink24 1 .042]
set cbr14 [attach-CBR-traffic $node_(23) $sink27 1 .042]

set cbr15 [attach-CBR-traffic $node_(7) $sink2 1 .042]
set cbr16 [attach-CBR-traffic $node_(5) $sink3 1 .042]
set cbr17 [attach-CBR-traffic $node_(10) $sink4 1 .042]
set cbr18 [attach-CBR-traffic $node_(9) $sink6 1 .042]
set cbr19 [attach-CBR-traffic $node_(3) $sink7 1 .042]                       
set cbr20 [attach-CBR-traffic $node_(10) $sink8 1 .042]
set cbr21 [attach-CBR-traffic $node_(1) $sink10 1 .042]
set cbr40 [attach-CBR-traffic $node_(11) $sink29 1 .042]
set cbr22 [attach-CBR-traffic $node_(29) $sink17 1 .042]
set cbr23 [attach-CBR-traffic $node_(29) $sink12 1 .042]
set cbr24 [attach-CBR-traffic $node_(19) $sink13 1 .042]
set cbr25 [attach-CBR-traffic $node_(17) $sink30 1 .042]
set cbr26 [attach-CBR-traffic $node_(12) $sink29 1 .042]
set cbr27 [attach-CBR-traffic $node_(8) $sink15 1 .042]
set cbr28 [attach-CBR-traffic $node_(29) $sink16 1 .042]

set cbr29 [attach-CBR-traffic $node_(15) $sink18 1 .042]
set cbr30 [attach-CBR-traffic $node_(13) $sink19 1 .042]
set cbr41 [attach-CBR-traffic $node_(30) $sink29 1 .042]


set cbr31 [attach-CBR-traffic $node_(31) $sink20 1 .042]
set cbr32 [attach-CBR-traffic $node_(27) $sink21 1 .042]
set cbr33 [attach-CBR-traffic $node_(28) $sink23 1 .042]
set cbr34 [attach-CBR-traffic $node_(24) $sink26 1 .042]
set cbr35 [attach-CBR-traffic $node_(21) $sink27 1 .042]
set cbr36 [attach-CBR-traffic $node_(32) $sink28 1 .042]
set cbr37 [attach-CBR-traffic $node_(25) $sink31 1 .042]
set cbr38 [attach-CBR-traffic $node_(20) $sink32 1 .042]
set cbr39 [attach-CBR-traffic $node_(8) $sink0 1 .042]



$ns at 0.0 "record"

$ns at 0.64 "$cbr8 start"
$ns at 0.8 "$cbr8 stop"

$ns at 0.25 "$cbr9 start"
$ns at 0.8 "$cbr9 stop"

$ns at 0.4 "$cbr10 start"
$ns at 0.6 "$cbr10 stop"
$ns at 0.23 "$cbr11 start"
$ns at 0.9 "$cbr11 stop"
$ns at 0.65 "$cbr12 start"
$ns at 0.8 "$cbr12 stop"
$ns at 0.22 "$cbr13 start"
$ns at 0.58 "$cbr13 stop"
$ns at 0.24 "$cbr14 start"
$ns at 0.65 "$cbr14 stop"

$ns at 0.1 "$cbr15 start"
$ns at 0.5 "$cbr15 stop"
$ns at 0.15 "$cbr16 start"
$ns at 0.68 "$cbr16 stop"
$ns at 0.18 "$cbr17 start"
$ns at 0.5 "$cbr17 stop"
$ns at 0.23 "$cbr18 start"
$ns at 0.58 "$cbr18 stop"
$ns at 0.27 "$cbr19 start"
$ns at 0.39 "$cbr19 stop"
$ns at 0.13 "$cbr20 start"
$ns at 0.3 "$cbr20 stop"
$ns at 0.29 "$cbr21 start"
$ns at 0.9 "$cbr21 stop"

$ns at 0.1 "$cbr22 start"
$ns at 0.46 "$cbr22 stop"
$ns at 0.1 "$cbr23 start"
$ns at 0.6 "$cbr23 stop"
$ns at 0.1 "$cbr24 start"
$ns at 0.3 "$cbr24 stop"
$ns at 0.1 "$cbr25 start"
$ns at 0.61 "$cbr25 stop"
$ns at 0.1 "$cbr26 start"
$ns at 0.15 "$cbr26 stop"
$ns at 0.1 "$cbr27 start"
$ns at 0.4 "$cbr27 stop"
$ns at 0.1 "$cbr28 start"
$ns at 0.45 "$cbr28 stop"
$ns at 0.1 "$cbr29 start"
$ns at 0.48 "$cbr29 stop"
$ns at 0.1 "$cbr30 start"
$ns at 0.5 "$cbr30 stop"
$ns at 4.04 "$cbr40 start"
$ns at 5.0 "$cbr40 stop"
$ns at 6.95 "$cbr41 start"

$ns at 0.1 "$cbr31 start"
$ns at 0.85 "$cbr31 stop"
$ns at 0.12 "$cbr32 start"
$ns at 0.3 "$cbr32 stop"
$ns at 0.13 "$cbr33 start"
$ns at 0.3 "$cbr33 stop"
$ns at 0.16 "$cbr34 start"
$ns at 0.35 "$cbr34 stop"
$ns at 0.17 "$cbr35 start"
$ns at 0.45 "$cbr35 stop"
$ns at 0.18 "$cbr36 start"
$ns at 0.55 "$cbr36 stop"
$ns at 0.19 "$cbr37 start"
$ns at 0.45 "$cbr37 stop"
$ns at 0.15 "$cbr38 start"
$ns at 0.4 "$cbr38 stop"

$ns at 0.11 "$cbr39 start"
$ns at 0.35 "$cbr39 stop"




#Define a 'finish' procedure
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam out.nam &
 exec xgraph dsr1.tr securedsr1.tr sink1.tr   -geometry 800x400 -t "For Packet Delivery Ratio" -x "Time" -y "No.of Packets" -bg white &
 exec xgraph sink2.tr  securedsr2.tr dsr2.tr -geometry 800x400 -t "For Packet Loss" -x "Time" -y "No.of Packets" -bg white &
exec xgraph  dsr3.tr sink3.tr  securedsr3.tr -geometry 800x400 -t "Throughput" -x "Time" -y "No.of Packets" -bg white &
   

	exec xgraph dsr_routing_1.tr  -x "Successfull Response" -y "Trust Value" -t "Performance Level single-path vs successfull response " -geometry 800x400 -bg white &
	exec xgraph dsr_routing_3.tr  -x "Failure Rate" -y "Trust Value" -t "Performance Level single-path vs Failture rate" -geometry 800x400 -bg white &
	exec xgraph dsr_routing_2.tr  -x "Mobility m/s" -y "Trust Value" -t "Performance Level multi-path routing vs Mobility" -geometry 800x400 -bg white &
	exec xgraph dsr_routing_4.tr  -x "Trust Value" -y "Node battery power" -t "Performance Level multi-path routing vs Battery power" -geometry 800x400 -bg white &
	exec xgraph dsr_routing_5.tr  -x "Trust Value" -y "Band width m/s" -t "Performance Level Trust value vs Bandwidth" -geometry 800x400 -bg white &
	exec xgraph dsr_routing_6.tr  -x "Trust Value" -y "recommendation value" -t "Performance Level Trust value vs Recommendation" -geometry 800x400 -bg white &
	exec xgraph dsr_routing_7.tr  -x "Trust Value" -y "Availablity power" -t "Performance Level Trust value vs Availablity power" -geometry 800x400 -bg white &
exec xgraph througput.tr packtdropped.tr delivryratio.tr n4-delay1.tr n5-delay2.tr -geometry  800x400 -t " routing performance" -x "no of nodes" -y "transmission range" &
         exit 0
}
for {set i 0} {$i < 42 } { incr i } {
    $ns at $val(stop) "\$node_($i) reset"
}
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"done\" ; $ns halt"
$ns run
