###   Ref. http://read.pudn.com/downloads181/sourcecode/others/842314/blackhole20.tcl__.htm


#define options 
set val(chan)    Channel/WirelessChannel 
set val(prop)    Propagation/TwoRayGround 
set val(netif)   Phy/WirelessPhy 
set val(mac)     Mac/802_11  
set val(ifq)     Queue/DropTail/PriQueue 
set val(ant)     Antenna/OmniAntenna 
set val(ll)      LL  	 ;# link layer type
set val(ifqlen)  150 
set val(nn)      21 
set val(nnaodv)  19 
set val(rp)      AODV 
set val(brp)     blackholeAODV 
set val(X)       700 
set val(Y)       700 
set val(cstop)   450 
set val(stop)    500 
set val(cp)      "scen-20" 
#set val(cc)      "scenearios/vbr-20" 
# Initialize Global Variables 
set ns_ [new Simulator] 
 
set tracefd  [open BlackHole20.tr w] 
$ns_ trace-all $tracefd  
set namtrace [open BlackHole20.nam w] 
$ns_ namtrace-all-wireless $namtrace $val(X)  $val(Y) 
#set up top 
set topo [new Topography] 
$topo load_flatgrid $val(X) $val(Y) 
# Create God 
set god_  [create-god  $val(nn)] 
#create channel 
set chan_1_ [new $val(chan)] 
set chan_2_ [new $val(chan)] 
#configure nodes 
$ns_  node-config  -adhocRouting $val(rp) \
                  -llType       $val(ll) \
                  -macType      $val(mac) \
                  -ifqType      $val(ifq) \
                  -ifqLen       $val(ifqlen) \
                  -antType      $val(ant) \
                  -propType     $val(prop) \
                  -phyType      $val(netif) \
                  -topoInstance $topo \
                  -agentTrace   ON \
                  -routerTrace  ON \
                  -macTrace     ON \
                  -movementTrace ON \
                  -channel      $chan_1_ 
# create nodes 
for {set i 0} {$i < $val(nnaodv)} {incr i} { 
	 set node_($i) [$ns_ node]	 
   $node_($i) random-motion 0; 
} 
 
# $ns_  node-config  -adhocRouting $val(brp) 
for {set i $val(nnaodv) } {$i<$val(nn) } {incr i} { 
     set node_($i) [$ns_ node] 
     $node_($i) random-motion 0; 
     $ns_ at 0.01 "$node_($i) label \"blackhole node\"" 
}  
   
puts "loading random connection pattern..." 
 
#source $val(cp) 
source ./scen-20
 
 set j 0 
 for {set i 0} {$i<18} {incr i} { 
        set udp_($j) [new Agent/UDP] 
        $ns_ attach-agent $node_($i) $udp_($j) 
        set null_($j) [new Agent/Null] 
        $ns_ attach-agent $node_([expr $i+1]) $null_($j) 
          
         set cbr_($j) [new Application/Traffic/CBR] 
         puts "cbr_($j) has been created over udp_($j)" 
         $cbr_($j) set packet_size_ 512 
         $cbr_($j) set interval_ 1 
         $cbr_($j) set rate_ 10kb 
         $cbr_($j) set ransom_ flase 
         $cbr_($j) attach-agent $udp_($j) 
         $ns_ connect $udp_($j) $null_($j) 
         puts "$udp_($j) and $null_($j) agents has been connected each other" 
         $ns_ at 1.0  "$cbr_($j)  start" 
          
         set j [expr $j+1] 
         set i [expr $i+1] 
 } 
 #Define initial node position  
 for { set i 0} {$i<$val(nn)} {incr i} { 
         $ns_ initial_node_pos  $node_($i) 30 
     } 
 for {set i 0} {$i<9} {incr i} { 
    $ns_ at $val(cstop) "$cbr_($i) stop"         
 }     
 for {set i 0} {$i<$val(nn)} {incr i} { 
      $ns_ at $val(stop).000000001 "$node_($i) reset";  
 } 
  
$ns_ at $val(stop) "finish" 
$ns_ at $val(stop).0 "$ns_ trace-annotate \"Simulation has ended\"" 
$ns_ at $val(stop).00000001 "puts \"NS exiting...\"; $ns_ halt" 
proc finish {} { 
    global ns_ tracefd namtrace 
    $ns_ flush-trace 
    close $tracefd 
    close $namtrace 
   # exec nam BLACKhole20.nam & 
    exit 0 
} 
 puts "Starting simulation..." 
 $ns_ run
