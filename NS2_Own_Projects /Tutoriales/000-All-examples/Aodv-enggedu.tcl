#       http://enggedu.com/ns2_simulator/ns2_wireless_network/Tcl_script_to_make_communication_between_nodes_using_AODV_routing_protocol_and_CBR_traffic/index.php

# Tcl script to make communication between nodes using AODV routing protocol and CBR traffic 
# Description:

#     Number of nodes (22) is fixed in the program. Nodes are configured with specific parameters of a mobile wireless node. After creating the nam file and trace file, we set up topography object. set node_ ($i) [$ns node] is used to create the nodes. Initial location of the nodes is fixed. Specific X, Y coordinates are assigned to every node. Nodes are given mobility with fixed speed and fixed destination location. Here we set the initial size for the every node by using initial_node_pos. AODV routing protocol is used here. $val(stop) specifies the end time of the simulation. UDP agent is attached to sender node. LossMonitor agent is attached to receiver node. Both the agents are connected and CBR traffic is attached to UDP agent. Now communication set up for nodes are established.

# File name: “Aodv.tcl”

### Setting The Simulator Objects
set val(chan)         Channel/WirelessChannel
set val(prop)         Propagation/TwoRayGround ;# radio-propagation model
set val(ant)          Antenna/OmniAntenna      ;# Antenna type
set val(ll)           LL
set val(ifqlen)       50
set val(netif)        Phy/WirelessPhy
set val(ifq)          Queue/DropTail/PriQueue
set val(mac)          Mac/802_11 
set val(rp)	       AODV
set val(x) 1800 					;
set val(y) 840 					; 
set val(nn) 22 					;
                
      set ns_ [new Simulator]
#create the nam and trace file:
      set tracefd [open Aodv-e.tr w]
      $ns_ trace-all $tracefd

      set namtrace [open Aodv-e.nam w]
      $ns_ namtrace-all-wireless $namtrace  $val(x) $val(y)


      set topo [new Topography]
      $topo load_flatgrid $val(x) $val(y)
      create-god $val(nn)
      set chan_1_ [new $val(chan)]
     
####  Setting The Distance Variables
                      

      # For model 'TwoRayGround'
      set dist(5m)  7.69113e-06
      set dist(9m)  2.37381e-06
      set dist(10m) 1.92278e-06
      set dist(11m) 1.58908e-06
      set dist(12m) 1.33527e-06
      set dist(13m) 1.13774e-06
      set dist(14m) 9.81011e-07
      set dist(15m) 8.54570e-07
      set dist(16m) 7.51087e-07
      set dist(20m) 4.80696e-07
      set dist(25m) 3.07645e-07
      set dist(30m) 2.13643e-07
      set dist(35m) 1.56962e-07
      set dist(40m) 1.56962e-10
      set dist(45m) 1.56962e-11
      set dist(50m) 1.20174e-13
      Phy/WirelessPhy set CSThresh_ $dist(50m)
      Phy/WirelessPhy set RXThresh_ $dist(50m)

#  Defining Node Configuration
                       
                  $ns_ node-config -adhocRouting $val(rp) \
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
                   -movementTrace ON \
                   -channel $chan_1_

###  Creating The WIRELESS NODES
                 
      set Server1 [$ns_ node]
      set Server2 [$ns_ node]
      set n2 [$ns_ node]
      set n3 [$ns_ node]
      set n4 [$ns_ node]
      set n5 [$ns_ node]
      set n6 [$ns_ node]
      set n7 [$ns_ node]
      set n8 [$ns_ node]
      set n9 [$ns_ node]
      set n10 [$ns_ node]
      set n11 [$ns_ node]
      set n12 [$ns_ node]
      set n13 [$ns_ node]
      set n14 [$ns_ node]
      set n15 [$ns_ node]
      set n16 [$ns_ node]
      set n17 [$ns_ node]
      set n18 [$ns_ node]
      set n19 [$ns_ node]
      set n20 [$ns_ node]
      set n21 [$ns_ node]
      set n22 [$ns_ node]
     
      set opt(seed) 0.1
      set a [ns-random $opt(seed)]
      set i 0
      while {$i < 5} {
      incr i
      }
           

###  Setting The Initial Positions of Nodes

      $Server1 set X_ 513.0
      $Server1 set Y_ 517.0
      $Server1 set Z_ 0.0
     
      $Server2 set X_ 1445.0
      $Server2 set Y_ 474.0
      $Server2 set Z_ 0.0
     
      $n2 set X_ 36.0
      $n2 set Y_ 529.0
      $n2 set Z_ 0.0

      $n3 set X_ 143.0
      $n3 set Y_ 666.0
      $n3 set Z_ 0.0

      $n4 set X_ 201.0
      $n4 set Y_ 552.0
      $n4 set Z_ 0.0
     
      $n5 set X_ 147.0
      $n5 set Y_ 403.0
      $n5 set Z_ 0.0
     
      $n6 set X_ 230.0
      $n6 set Y_ 291.0
      $n6 set Z_ 0.0

      $n7 set X_ 295.0
      $n7 set Y_ 419.0
      $n7 set Z_ 0.0

      $n8 set X_ 363.0
      $n8 set Y_ 335.0
      $n8 set Z_ 0.0

      $n9 set X_ 334.0
      $n9 set Y_ 647.0
      $n9 set Z_ 0.0

      $n10 set X_ 304.0
      $n10 set Y_ 777.0
      $n10 set Z_ 0.0
     
      $n11 set X_ 412.0
      $n11 set Y_ 194.0
      $n11 set Z_ 0.0
     
      $n12 set X_ 519.0
      $n12 set Y_ 361.0
      $n12 set Z_ 0.0

      $n13 set X_ 569.0
      $n13 set Y_ 167.0
      $n13 set Z_ 0.0

      $n14 set X_ 349.0
      $n14 set Y_ 546.0
      $n14 set Z_ 0.0

      $n15 set X_ 466.0
      $n15 set Y_ 668.0
      $n15 set Z_ 0.0

      $n16 set X_ 489.0
      $n16 set Y_ 794.0
      $n16 set Z_ 0.0

      $n17 set X_ 606.0
      $n17 set Y_ 711.0
      $n17 set Z_ 0.0

      $n18 set X_ 630.0
      $n18 set Y_ 626.0
      $n18 set Z_ 0.0

      $n19 set X_ 666.0
      $n19 set Y_ 347.0
      $n19 set Z_ 0.0

      $n20 set X_ 741.0
      $n20 set Y_ 152.0
      $n20 set Z_ 0.0

      $n21 set X_ 882.0
      $n21 set Y_ 264.0
      $n21 set Z_ 0.0
     
      $n22 set X_ 761.0
      $n22 set Y_ 441.0
      $n22 set Z_ 0.0
     
      ## Giving Mobility to Nodes
     
      $ns_ at 0.75 "$n2 setdest 379.0 349.0 20.0"
      $ns_ at 0.75 "$n3 setdest 556.0 302.0 20.0"
      $ns_ at 0.20 "$n4 setdest 309.0 211.0 20.0"
      $ns_ at 1.25 "$n5 setdest 179.0 333.0 20.0"
      $ns_ at 0.75 "$n6 setdest 139.0 63.0 20.0"
      $ns_ at 0.75 "$n7 setdest 320.0 27.0 20.0"
      $ns_ at 1.50 "$n8 setdest 505.0 124.0 20.0"
      $ns_ at 1.25 "$n9 setdest 274.0 487.0 20.0"
      $ns_ at 1.25 "$n10 setdest 494.0 475.0 20.0"
      $ns_ at 1.25 "$n11 setdest 899.0 757.0 25.0"
      $ns_ at 0.50 "$n12 setdest 598.0 728.0 25.0"
      $ns_ at 0.25 "$n13 setdest 551.0 624.0 25.0"
      $ns_ at 1.25 "$n14 setdest 397.0 647.0 25.0"
      $ns_ at 1.25 "$n15 setdest 748.0 688.0 25.0"
      $ns_ at 1.25 "$n16 setdest 842.0 623.0 25.0"
      $ns_ at 1.25 "$n17 setdest 678.0 548.0 25.0"
      $ns_ at 0.75 "$n18 setdest 741.0 809.0 20.0"
      $ns_ at 0.75 "$n19 setdest 437.0 799.0 20.0"
      $ns_ at 0.20 "$n20 setdest 159.0 722.0 20.0"
      $ns_ at 1.25 "$n21 setdest 700.0 350.0 20.0"
      $ns_ at 0.75 "$n22 setdest 839.0 444.0 20.0"
           
      ## Setting The Node Size
                             
      $ns_ initial_node_pos $Server1 75
      $ns_ initial_node_pos $Server2 75
      $ns_ initial_node_pos $n2 40
      $ns_ initial_node_pos $n3 40
      $ns_ initial_node_pos $n4 40
      $ns_ initial_node_pos $n5 40
      $ns_ initial_node_pos $n6 40
      $ns_ initial_node_pos $n7 40
      $ns_ initial_node_pos $n8 40
      $ns_ initial_node_pos $n9 40
      $ns_ initial_node_pos $n10 40
      $ns_ initial_node_pos $n11 40
      $ns_ initial_node_pos $n12 40
      $ns_ initial_node_pos $n13 40
      $ns_ initial_node_pos $n14 40
      $ns_ initial_node_pos $n15 40
      $ns_ initial_node_pos $n16 40
      $ns_ initial_node_pos $n17 40
      $ns_ initial_node_pos $n18 40
      $ns_ initial_node_pos $n19 40
      $ns_ initial_node_pos $n20 40
      $ns_ initial_node_pos $n21 40
      $ns_ initial_node_pos $n22 40
