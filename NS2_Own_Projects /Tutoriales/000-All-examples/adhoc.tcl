# ²ÉÓÃÁË²ÎÊý´«µÝµÄÐÎÊ½£¬¿ÉÒÔÖ±½ÓÍ¨¹ýÃüÁîÐÐ·½±ãµÄÄ£·Âad hocµÄËùÓÐÆ½ÃæÂ·ÓÉÐ­Òé 
if {$argc !=4} { 
        puts "Usage: ns adhoc.tcl  Routing_Protocol Traffic_Pattern Scene_Pattern Num_Of_Node" 
        puts "Example:ns adhoc.tcl AODV cbr-50-10-8 scene-50-0-20 50" 
        exit 
} 
 
set par1 [lindex $argv 0] 
set par2 [lindex $argv 1] 
set par3 [lindex $argv 2]  
set par4 [lindex $argv 3] 
# ====================================================================== 
# Define options 
# ====================================================================== 
set val(chan)           Channel/WirelessChannel    ;# channel type 
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model 
set val(netif)          Phy/WirelessPhy            ;# network interface type 
set val(mac)            Mac/802_11                 ;# MAC type 
if { $par1=="DSR"} { 
  set val(ifq) 		      CMUPriQueue  
  } else { 
  set val(ifq)          Queue/DropTail/PriQueue    ;# interface queue type 
 } 
set val(ll)             LL                         ;# link layer type 
set val(ant)            Antenna/OmniAntenna        ;# antenna model 
set val(ifqlen)         50                         ;# max packet in ifq 
set val(rp)             $par1                      ;# routing protocol 
set val(x) 		          1000 
set val(y)		          1000 
set val(seed)		        0.0 
set val(tr)		          $par1-$par3.tr 
set val(nam)		        $par1-$par3.nam 
set val(nn)		          $par4                         ;# number of mobilenodes 
set val(cp)		          "traffic/$par2" 
set val(sc)             "scenarios/$par3" 
set val(stop)		        100.0 
 
# ====================================================================== 
# Main Program 
# ====================================================================== 
 
 
# 
# Initialize Global Variables 
# 
set ns_		[new Simulator] 
set tracefd     [open $val(tr) w] 
$ns_ trace-all $tracefd 
set namtracefd [open $val(nam) w] 
$ns_ namtrace-all-wireless $namtracefd $val(x) $val(y) 
 
# set up topography object 
set topo       [new Topography] 
 
$topo load_flatgrid $val(x) $val(y) 
 
# 
# Create God 
# 
set god_ [create-god $val(nn)] 
 
# 
#  Create the specified number of mobilenodes [$val(nn)] and "attach" them 
#  to the channel.  
# configure node 
# set chan_1_ [new $val(chan)] 
        $ns_ node-config -adhocRouting $val(rp) \ 
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
			 -routerTrace ON \ 
			 -macTrace OFF \ 
			 -movementTrace OFF			 
			  
	for {set i 0} {$i < $val(nn) } {incr i} { 
		set node_($i) [$ns_ node]	 
		$node_($i) random-motion 0		;# disable random motion 
	} 
 
puts "Loading connection pattern..." 
source $val(cp) 
 
puts "Loading scenario file..." 
source $val(sc) 
  
for {set i 0} {$i < $val(nn) } {incr i} { 
    $ns_ initial_node_pos $node_($i) 20 
} 
 
# 
# Tell nodes when the simulation ends 
# 
for {set i 0} {$i < $val(nn) } {incr i} { 
    $ns_ at $val(stop).000000001 "$node_($i) reset"; 
} 
$ns_ at $val(stop).000000001 "finish" 
$ns_ at $val(stop).000000001 "puts \"NS EXITING...\"; $ns_ halt" 
proc finish {} { 
    global ns_ tracefd namtracefd 
    $ns_ flush-trace 
    close $tracefd 
    close $namtracefd 
   # exec nam adhoc.nam & 
	  exit 0  
} 
 
puts "Starting Simulation..." 
$ns_ run 
 

