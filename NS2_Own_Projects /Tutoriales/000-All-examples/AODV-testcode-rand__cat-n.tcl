     1	#     https://code.google.com/p/ns2-gators/wiki/AODVtestcode
     2	
     3	 
     4	# A 100-node example for ad-hoc simulation with AODV
     5	
     6	# Define options
     7	set val(chan)           Channel/WirelessChannel    ;# channel type
     8	set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
     9	set val(netif)          Phy/WirelessPhy            ;# network interface type
    10	
    11	set val(mac)            Mac/802_11                 ;# MAC type
    12	set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
    13	set val(ll)             LL                         ;# link layer type
    14	set val(ant)            Antenna/OmniAntenna        ;# antenna model
    15	set val(ifqlen)         50                         ;# max packet in ifq
    16	set val(nn)             100                        ;# number of mobilenodes
    17	set val(rp)             DSDV                       ;# routing protocol
    18	set val(x)              500                        ;# X dimension of topography
    19	set val(y)              400                        ;# Y dimension of topography
    20	set val(stop)           150                        ;# time of simulation end
    21	
    22	set ns          [new Simulator]
    23	set tracefd       [open testAODV.tr w]
    24	set windowVsTime2 [open win.tr w]
    25	set namtrace      [open testAODV.nam w]
    26	
    27	$ns trace-all $tracefd
    28	$ns namtrace-all-wireless $namtrace $val(x) $val(y)
    29	
    30	# set up topography object
    31	set topo       [new Topography]
    32	
    33	$topo load_flatgrid $val(x) $val(y)
    34	
    35	create-god $val(nn)
    36	
    37	#
    38	#  Create nn mobilenodes [$val(nn)] and attach them to the channel.
    39	#
    40	
    41	# configure the nodes
    42	        $ns node-config -adhocRouting $val(rp) \
    43	             -llType $val(ll) \
    44	             -macType $val(mac) \
    45	             -ifqType $val(ifq) \
    46	             -ifqLen $val(ifqlen) \
    47	             -antType $val(ant) \
    48	             -propType $val(prop) \
    49	             -phyType $val(netif) \
    50	             -channelType $val(chan) \
    51	             -topoInstance $topo \
    52	             -agentTrace ON \
    53	             -routerTrace ON \
    54	             -macTrace OFF \
    55	             -movementTrace ON
    56	
    57	    for {set i 0} {$i < $val(nn) } { incr i } {
    58	        set node_($i) [$ns node]
    59	        $node_($i) set X_ [ expr 10+round(rand()*480) ]
    60	        $node_($i) set Y_ [ expr 10+round(rand()*380) ]
    61	        $node_($i) set Z_ 0.0
    62	    }
    63	
    64	    for {set i 0} {$i < $val(nn) } { incr i } {
    65	        $ns at [ expr 15+round(rand()*60) ] "$node_($i) setdest [ expr 10+round(rand()*480) ] [ expr 10+round(rand()*380) ] [ expr 2+round(rand()*15) ]"
    66	        
    67	    }
    68	
    69	# Generation of movements
    70	# $ns at 10.0 "$node_(0) setdest 250.0 250.0 3.0"
    71	# $ns at 15.0 "$node_(1) setdest 45.0 285.0 5.0"
    72	# $ns at 70.0 "$node_(2) setdest 480.0 300.0 5.0"
    73	# $ns at 20.0 "$node_(3) setdest 200.0 200.0 5.0"
    74	# $ns at 25.0 "$node_(4) setdest 50.0 50.0 10.0"
    75	# $ns at 60.0 "$node_(5) setdest 150.0 70.0 2.0"
    76	# $ns at 90.0 "$node_(6) setdest 380.0 150.0 8.0"
    77	# $ns at 42.0 "$node_(7) setdest 200.0 100.0 15.0"
    78	# $ns at 55.0 "$node_(8) setdest 50.0 275.0 5.0"
    79	# $ns at 19.0 "$node_(9) setdest 250.0 250.0 7.0"
    80	# $ns at 90.0 "$node_(10) setdest 150.0 150.0 20.0"
    81	# $ns at 75.0 "$node_(11) setdest 75.0 100.0 5.0"
    82	
    83	# Set a TCP connection between node_(2) and node_(11)
    84	set tcp [new Agent/TCP/Newreno]
    85	$tcp set class_ 2
    86	set sink [new Agent/TCPSink]
    87	$ns attach-agent $node_(2) $tcp
    88	$ns attach-agent $node_(11) $sink
    89	$ns connect $tcp $sink
    90	set ftp [new Application/FTP]
    91	$ftp attach-agent $tcp
    92	$ns at 10.0 "$ftp start"
    93	
    94	# Printing the window size
    95	proc plotWindow {tcpSource file} {
    96	global ns
    97	set time 0.01
    98	set now [$ns now]
    99	set cwnd [$tcpSource set cwnd_]
   100	puts $file "$now $cwnd"
   101	$ns at [expr $now+$time] "plotWindow $tcpSource $file" }
   102	$ns at 10.1 "plotWindow $tcp $windowVsTime2"
   103	
   104	# Define node initial position in nam
   105	for {set i 0} {$i < $val(nn)} { incr i } {
   106	# 30 defines the node size for nam
   107	$ns initial_node_pos $node_($i) 30
   108	}
   109	
   110	# Telling nodes when the simulation ends
   111	for {set i 0} {$i < $val(nn) } { incr i } {
   112	    $ns at $val(stop) "$node_($i) reset";
   113	}
   114	
   115	# ending nam and the simulation
   116	$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
   117	$ns at $val(stop) "stop"
   118	$ns at 150.01 "puts \"end simulation\" ; $ns halt"
   119	proc stop {} {
   120	    global ns tracefd namtrace
   121	    $ns flush-trace
   122	    close $tracefd
   123	    close $namtrace
   124	}
   125	
   126	$ns run