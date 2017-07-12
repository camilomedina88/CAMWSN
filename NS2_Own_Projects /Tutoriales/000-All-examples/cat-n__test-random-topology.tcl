     1	# Copyright (c) 1997 Regents of the University of California.
     2	# All rights reserved.
     3	#
     4	# Redistribution and use in source and binary forms, with or without
     5	# modification, are permitted provided that the following conditions
     6	# are met:
     7	# 1. Redistributions of source code must retain the above copyright
     8	#    notice, this list of conditions and the following disclaimer.
     9	# 2. Redistributions in binary form must reproduce the above copyright
    10	#    notice, this list of conditions and the following disclaimer in the
    11	#    documentation and/or other materials provided with the distribution.
    12	# 3. All advertising materials mentioning features or use of this software
    13	#    must display the following acknowledgement:
    14	#      This product includes software developed by the Computer Systems
    15	#      Engineering Group at Lawrence Berkeley Laboratory.
    16	# 4. Neither the name of the University nor of the Laboratory may be used
    17	#    to endorse or promote products derived from this software without
    18	#    specific prior written permission.
    19	#
    20	# THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
    21	# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
    22	# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
    23	# ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
    24	# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
    25	# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
    26	# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
    27	# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    28	# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
    29	# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
    30	# SUCH DAMAGE.
    31	#
    32	# simple-wireless.tcl
    33	# A simple example for wireless simulation
    34	
    35	# ======================================================================
    36	# Define options
    37	# ======================================================================
    38	
    39	set val(chan)           Channel/WirelessChannel    ;# channel type
    40	set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
    41	set val(netif)          Phy/WirelessPhy            ;# network interface type
    42	set val(mac)            Mac/802_11                 ;# MAC type
    43	set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
    44	set val(ll)             LL                         ;# link layer type
    45	set val(ant)            Antenna/OmniAntenna        ;# antenna model
    46	set val(ifqlen)         500                        ;# max packet in ifq
    47	set val(nn)             50                          ;# number of mobilenodes
    48	set val(rp)             AODV                       ;# routing protocol
    49	
    50	
    51	set val(connection)     [lindex $argv 0]
    52	# set val(rate)    	[ expr [lindex $argv 1] * 1000 ]
    53	set val(rate)    	[ expr [lindex $argv 1] 1000 ]
    54	set val(seed)           [lindex $argv 2]
    55	
    56	# routing: 0 # XCHARM
    57	# routing: 1 # AODV-MR
    58	
    59	
    60	# ======================================================================
    61	# Main Program
    62	# ======================================================================
    63	
    64	
    65	#
    66	# Initialize Global Variables
    67	#
    68	set ns_		[new Simulator]
    69	set tracefd     [open simple.tr w]
    70	$ns_ trace-all $tracefd
    71	
    72	#set namtrace    [open $val(seed)".nam" w]
    73	#$ns_ namtrace-all-wireless $namtrace 1000 1000
    74	
    75	
    76	# set up topography object
    77	set topo       [new Topography]
    78	
    79	$topo load_flatgrid 1000 1000
    80	
    81	#
    82	# Create God
    83	#
    84	create-god $val(nn)
    85	
    86	#create PUMap
    87	set pumap [new PUMap]
    88	$pumap set_input_map "map.txt"
    89	#create Spectrum Map
    90	set smap [new SpectrumMap]
    91	$smap set_input_map "channel.txt"
    92	# Create cross-layer repository
    93	set repository [new CrossLayerRepository]
    94	
    95	
    96	
    97	
    98	#
    99	#  Create the specified number of mobilenodes [$val(nn)] and "attach" them
   100	#  to the channel. 
   101	#  Here two nodes are created : node(0) and node(1)
   102	
   103	#create channels
   104	set chan_0_ [new $val(chan)]
   105	set chan_1_ [new $val(chan)]
   106	set chan_2_ [new $val(chan)]
   107	set chan_3_ [new $val(chan)]
   108	set chan_4_ [new $val(chan)]
   109	set chan_5_ [new $val(chan)]
   110	set chan_6_ [new $val(chan)]
   111	set chan_7_ [new $val(chan)]
   112	set chan_8_ [new $val(chan)]
   113	set chan_9_ [new $val(chan)]
   114	set chan_10_ [new $val(chan)]
   115	
   116	# configure nodes
   117	
   118	        $ns_ node-config -adhocRouting $val(rp) \
   119				 -llType $val(ll) \
   120				 -macType $val(mac) \
   121				 -ifqType $val(ifq) \
   122				 -ifqLen $val(ifqlen) \
   123				 -antType $val(ant) \
   124				 -propType $val(prop) \
   125				 -phyType $val(netif) \
   126				 -topoInstance $topo \
   127				 -agentTrace ON \
   128				 -routerTrace OFF \
   129				 -macTrace ON \
   130				 -movementTrace OFF			
   131	
   132		$ns_ node-config -channel $chan_0_\
   133			         -channel2 $chan_1_\
   134				 -channel3 $chan_2_\
   135				 -channel4 $chan_3_\
   136				 -channel5 $chan_4_\
   137	  			 -channel6 $chan_5_\
   138				 -channel7 $chan_6_\
   139				 -channel8 $chan_7_\
   140				 -channel9 $chan_8_\
   141	  			 -channel10 $chan_9_\
   142			 	 -channel11 $chan_10_\
   143	
   144				 # Add Here more channels 
   145	
   146	
   147				 
   148		for {set i 0} {$i < $val(nn) } {incr i} {
   149			set node_($i) [$ns_ node]	
   150			$node_($i) random-motion 0		;# disable random motion
   151		    	#Cognitive Radio Environment
   152			$node_($i) node-CR-configure $pumap $repository $smap
   153		
   154		}
   155	
   156	
   157	
   158	
   159	
   160	
   161	ns-random $val(seed)
   162	
   163	
   164	set rng [new RNG]
   165	$rng seed $val(seed)
   166	
   167	set u [new RandomVariable/Uniform]
   168	$u set min_ 0
   169	$u set max_ 360
   170	$u use-rng $rng
   171	
   172	set distance 200
   173	
   174	#Topology Builder
   175	for {set i 0} {$i < $val(nn) } {incr i} {
   176	
   177		if {$i == 0} {
   178			$node_($i) set X_ 500
   179			$node_($i) set Y_ 500
   180			$node_($i) set Z_ 0.0
   181			set prev_x 500
   182			set prev_y 500
   183			
   184			set posX($i)  $prev_x
   185			set posY($i)  $prev_y
   186	
   187		} else {
   188			set angle [$u value]
   189			set new_x [expr cos($angle) * $distance +$prev_x]
   190			set new_y [expr sin($angle) * $distance +$prev_y]
   191			
   192			if {$new_x < 0} {
   193				set new_x 0
   194			}		
   195	
   196			if {$new_x >=1000} {
   197				set new_x 999
   198			}
   199	
   200			if {$new_y < 0} {
   201				set new_y 0	
   202			}
   203	
   204			if {$new_y >=1000} {
   205				set new_y 999
   206			}
   207	
   208			$node_($i) set X_ $new_x
   209			$node_($i) set Y_ $new_y
   210			$node_($i) set Z_ 0.0
   211	
   212			set posX($i)  $new_x
   213			set posY($i)  $new_y
   214		
   215	
   216			set prev_x $new_x
   217			set prev_y $new_y
   218			
   219		}
   220	}
   221	
   222	
   223	# Define connections among nodes
   224	
   225	set f [new RandomVariable/Uniform]
   226	
   227	$f set min_ 0
   228	$f set max_ 49
   229	$f use-rng $rng
   230	
   231	set g [new RandomVariable/Uniform]
   232	$g set min_ 0
   233	$g set max_ 100
   234	$g use-rng $rng
   235	
   236	set delay 3
   237	
   238	for {set i 0} {$i < $val(connection) } {incr i} {
   239		
   240		set ok 0
   241		
   242		while { $ok == 0 } {
   243	
   244			set source [$f value]
   245			set source [expr int($source)]
   246			set dest   [$f value]
   247			set dest [expr int($dest)]
   248		
   249			if { $source == $dest } {
   250				set dest [expr $source   + 1 ]
   251			}
   252	
   253			if { $dest > 49 } {
   254				set dest 0
   255			}
   256			
   257			set distance [expr ($posX($source) -  $posX($dest))* ($posX($source) -  $posX($dest)) + ($posY($source) -  $posY($dest))* ($posY($source) -  $posY($dest)) ]
   258			
   259			#Distance between source and nodes should be in range [300:400] meters
   260			set distance [expr sqrt($distance)] 
   261	
   262			if { ($distance > 300) && ($distance < 400) } {
   263				set ok 1
   264			}
   265				
   266			
   267		}
   268	
   269		set udp_($i) [new Agent/UDP]
   270		set sink_($i) [new Agent/Null]
   271		$ns_ attach-agent $node_($source) $udp_($i)
   272		
   273		$ns_ attach-agent $node_($dest) $sink_($i)
   274		$ns_ connect $udp_($i) $sink_($i)
   275		set cbr_($i) [new Application/Traffic/CBR]
   276		$cbr_($i) set packetSize_ 1000
   277		$cbr_($i) set rate_ $val(rate)
   278		$cbr_($i) attach-agent $udp_($i)
   279		
   280		$ns_ at $delay "$cbr_($i) start" 
   281		
   282		set delay   [expr $delay + 5]
   283	
   284	
   285	}
   286	
   287	
   288	for {set i 0} {$i < $val(nn)} {incr i} {
   289	
   290	    # 20 defines the node size in nam, must adjust it according to your scenario
   291	    # The function must be called after mobility model is defined
   292	
   293	    $ns_ initial_node_pos $node_($i) 20
   294	}
   295	
   296	
   297	#
   298	# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
   299	
   300	#
   301	# Tell nodes when the simulation ends
   302	#
   303	for {set i 0} {$i < $val(nn) } {incr i} {
   304	    $ns_ at 200.0 "$node_($i) reset";
   305	}
   306	
   307	$ns_ at 200.0 "stop"
   308	$ns_ at 200.01 "puts \"NS EXITING...\" ; $ns_ halt"
   309	proc stop {} {
   310	    global ns_ tracefd
   311	    $ns_ flush-trace
   312	    close $tracefd
   313	}
   314	
   315	puts "Starting Simulation..."
   316	$ns_ run
   317	
