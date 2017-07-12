# ====================================================================== 
# Main Program 
# ====================================================================== 
 
# Initialize Global Variables 
#------------------------------------------- 
set val(chan)           Channel/WirelessChannel    ;# channel type 
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model 
set val(netif)          Phy/WirelessPhy            ;# network interface type 
set val(mac)            Mac/802_11                 ;# MAC type 
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type 
set val(ll)             LL                         ;# link layer type 
set val(ant)            Antenna/OmniAntenna        ;# antenna model 
set val(ifqlen)         50                         ;# max packet in ifq 
set val(nn)             5                         ;# number of mobilenodes 
set val(rp)             AODV                       ;# routing protocol 
set val(x)              1200  			   ;# X dimension of topography 
set val(y)              1000   			   ;# Y dimension of topography   
set val(stop)		50			   ;# time of simulation end 
set val(err)        UniformErrorProc 
# Set up topography object 
#------------------------------------------- 
set ns		  [new Simulator] 
set tracefd       [open simple.tr w] 
set windowVsTime2 [open win.tr w]  
set namtrace      [open simwrls.nam w]  
$ns use-newtrace 
$ns trace-all $tracefd 
$ns namtrace-all-wireless $namtrace $val(x) $val(y) 
 
# set up topography object 
set topo       [new Topography] 
#puts "dfdfdf" 
#$ns node-config  
#puts "fdfdfdfd" 
$topo load_flatgrid $val(x) $val(y) 
 
 
#	ErrorModule set debug_ false         
#  ErrorModel set enable_ 1 
#  ErrorModel set markecn_ false 
#ErrorModule set debug_ false 
# 
#ErrorModel set enable_ 1 
#ErrorModel set markecn_ false 
#ErrorModel set bandwidth_ 2Mb 
#ErrorModel set rate_ 0.00001 
# 
#ErrorModel/Trace set good_ 123456789 
#ErrorModel/Trace set loss_ 0 
#ErrorModel/Periodic set period_ 3.0 
#ErrorModel/Periodic set offset_ 0.0 
#ErrorModel/Periodic set burstlen_ 0.0 
#ErrorModel/MultiState set curperiod_ 0.0 
#ErrorModel/MultiState set sttype_ pkt 
#ErrorModel/MultiState set texpired_ 0 
 
proc UniformErrorProc {} { 
	puts "dfdfad-----------------------------" 
	set err [new ErrorModel] 
	$err unit pkt 
	#$err FECstrength 1  
	#$err datapktsize 1000 
   	#$err cntrlpktsize 80 
	$err set rate_ 0.1 
	#$err drop-target [new Agent/Null] 
	return $err 
}	 
	 
# Create God 
#------------------------------------------- 
create-god $val(nn) 
 
# Configure node 
#------------------------------------------------- 
 
$ns node-config -adhocRouting $val(rp) \
			 -llType $val(ll) \
			 -macType $val(mac) \
			 -ifqType $val(ifq) \
			 -ifqLen $val(ifqlen) \
			 -antType $val(ant) \
			 -propType $val(prop) \
			 -phyType $val(netif) \
			 -channel [new $val(chan)] \
			 -topoInstance $topo \
			 -agentTrace ON \
			 -routerTrace OFF \
			 -macTrace OFF \
			 -movementTrace OFF \
			 -IncomingErrProc $val(err)\
			 -OutgoingErrProc $val(err)			  
 
#			 -IncomingErrorProc ($err) \
#			 -OutcomingErrorProc UniformErrorProc	 
  
for {set i 0} {$i < $val(nn)} { incr i } {
	set node_($i) [$ns node]	 
} 
 
 
# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes 
#--------------------------------------------------------------- 
$node_(0) set X_ 600.0 
$node_(0) set Y_ 500.0 
$node_(0) set Z_ 0.0 
 
$node_(1) set X_ 800.0 
$node_(1) set Y_ 400.0 
$node_(1) set Z_ 0.0 
 
$node_(2) set X_ 1000.0 
$node_(2) set Y_ 400.0 
$node_(2) set Z_ 0.0 
 
$node_(3) set X_ 800.0 
$node_(3) set Y_ 600.0 
$node_(3) set Z_ 0.0 
 
$node_(4) set X_ 1000.0 
$node_(4) set Y_ 600.0 
$node_(4) set Z_ 0.0 
 
# Now produce some simple node movements 
#--------------------------------------------------- 
#$ns at 10.0 "$node_(0) setdest 250.0 250.0 3.0" 
#$ns at 15.0 "$node_(1) setdest 45.0 285.0 5.0" 
#$ns at 110.0 "$node_(0) setdest 480.0 300.0 5.0"  
 
 
# Setup traffic flow between nodes 
#--------------------------------------------------- 
set tcp [new Agent/TCP/Newreno] 
$tcp set class_ 2 
set sink [new Agent/TCPSink] 
$ns attach-agent $node_(0) $tcp 
$ns attach-agent $node_(2) $sink 
$ns connect $tcp $sink 
set ftp [new Application/FTP] 
$ftp attach-agent $tcp 
$ns at 1.0 "$ftp start"  
 
set udp_(0) [new Agent/UDP] 
$udp_(0) set fid_ 1 
$ns attach-agent $node_(0) $udp_(0) 
set null_(0) [new Agent/Null] 
$ns attach-agent $node_(4) $null_(0) 
 
set cbr_(0) [new Application/Traffic/CBR] 
$cbr_(0) set packetSize_ 200 
$cbr_(0) set interval_ 0.01 
$cbr_(0) set random_ 1 
$cbr_(0) set maxpkts_ 10000 
$cbr_(0) attach-agent $udp_(0) 
 
$ns connect $udp_(0) $null_(0) 
$ns at 11.0 "$cbr_(0) start" 
# Printing the window size 
proc plotWindow {tcpSource file} { 
	global ns 
	set time 0.01 
	set now [$ns now] 
	set cwnd [$tcpSource set cwnd_] 
	puts $file "$now $cwnd" 
	$ns at [expr $now+$time] "plotWindow $tcpSource $file" } 
	$ns at 10.1 "plotWindow $tcp $windowVsTime2"   
 
# Define node initial position in nam 
for {set i 0} {$i < $val(nn)} { incr i } { 
# 30 defines the node size for nam 
	$ns initial_node_pos $node_($i) 30 
} 
 
# Telling nodes when the simulation ends 
for {set i 0} {$i  $val(nn) } { incr i } {
$ns at $val(stop) "$node_($i) reset"; 
} 
 
 
# Tell nodes when the simulation ends 
#--------------------------------------------------- 
$ns at $val(stop) "$ns nam-end-wireless $val(stop)" 
$ns at $val(stop) "stop" 
$ns at 50.01 "puts \"end simulation\" ; $ns halt" 
 
 
proc stop {} { 
    global ns tracefd namtrace 
    $ns flush-trace 
    close $tracefd 
    close $namtrace 
} 
 
	 
#set fh [open dyn.trc w]  
#proc my-dump-routes {node fh} { 
#		set dr [$node rtObject] 
#		$dr dump-routes $fh 
#	} 
#$ns at 5.0 "$node_(0) dump-routes $fh" 
 
$ns run 
