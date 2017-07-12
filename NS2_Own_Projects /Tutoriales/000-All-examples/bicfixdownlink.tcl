#     https://groups.google.com/forum/?fromgroups=#!topic/ns-users/hHLAISWEyHw


set opt(chan)           Channel/WirelessChannel    	;# channel type
set opt(prop)           Propagation/TwoRayGround	;# radio-propagation model
set opt(netif)          Phy/WirelessPhy            	;# network interface type
set opt(mac)            Mac/802_11                 	;# MAC type
set opt(ifq)            Queue/LTEQueue/DLAirQueue    	;# interface queue type
set opt(ll)             LL                         	;# link layer type
set opt(ant)            Antenna/OmniAntenna        	;# antenna model
set opt(ifqlen)         50                         	;# max packet in ifq
set opt(nn)             5                          	;# number of mobilenodes
set opt(rp)   		DSDV                      	;# routing protocol
set opt(x)      	400                            	;# x coordinate of topology
set opt(y)      	400                            	;# y coordinate of topology
set opt(stop)   	300                            	;# time to stop simulation
set opt(ftp1-start) 	2.0
set opt(ftp2-start) 	3.0
set opt(ftp3-start) 	4.0
set opt(ftp4-start) 	1.0
set opt(ftp5-start) 	5.0
set num_wired_nodes 	2
set num_bs_nodes 	1

# Define options
set ns [new Simulator]
$ns use-newtrace
set tracefd [open fair-down.tr w]
set namtrace [open fair-down.nam w]
set window0 [open down0 w]
set window1 [open down1 w]
set window2 [open down2 w]
set window3 [open down3 w]
set window4 [open down4 w]
$ns trace-all $tracefd
$ns namtrace-all-wireless $namtrace $opt(x) $opt(y)

$ns node-config -addressType hierarchical
AddrParams set domain_num_ 2           	;# number of domains
lappend cluster_num 2 1                	;# number of clusters in each domain
AddrParams set cluster_num_ $cluster_num
lappend eilastlevel 1 1 6		;# number of nodes in each cluster of each domain
AddrParams set nodes_num_ $eilastlevel 		 
# set up for hierarchical routing
set topo [new Topography]
$topo load_flatgrid $opt(x) $opt(y)
# Create a topology object that keeps track of movements of nodes within the topological boundary
create-god [expr $opt(nn) + $num_bs_nodes]
# God object is used to store global information about the state of the environment, network or nodes
set temp {0.0.0 0.1.0}        ;# hierarchical addresses for wired domain
for {set i 0} {$i < $num_wired_nodes} {incr i} {
    set W($i) [$ns node [lindex $temp $i]]  
    $W($i) color Blue
}
#Create wired nodes
$ns node-config -adhocRouting $opt(rp) \
                -llType $opt(ll) \
                -macType $opt(mac) \
                -ifqType $opt(ifq) \
                -ifqLen $opt(ifqlen) \
                -antType $opt(ant) \
                -propType $opt(prop) \
                -phyType $opt(netif) \
                -channelType $opt(chan) \
		-topoInstance $topo \
                -wiredRouting ON \
		-agentTrace ON \
                -routerTrace OFF \
                -macTrace OFF 
# Configure for base-station node
set temp {1.0.0 1.0.1 1.0.2 1.0.3 1.0.4 1.0.5}  ;# hierarchical addresses to be used for wireless domain
set BS(0) [$ns node [lindex $temp 0]]
$BS(0) color Red
$BS(0) random-motion 0            ;# disable random motion
#create base-station node
$BS(0) set X_ 250.0
$BS(0) set Y_ 250.0
$BS(0) set Z_ 0.0
# provide some co-ord (fixed) to base-station node
$ns node-config -wiredRouting OFF
for {set j 0} {$j < $opt(nn)} {incr j} {
	set node_($j) [ $ns node [lindex $temp [expr $j+1]] ]
	$node_($j) base-station [AddrParams addr2id [$BS(0) node-addr]]
}

# create mobilenodes in the same domain as BS(0) and configure for mobilenodes
$ns duplex-link $W(0) $W(1) 1000Mb 2ms DropTail
$ns simplex-link $W(1) $BS(0) 200Mb 2ms LTEQueue/DLS1Queue
$ns simplex-link $BS(0) $W(1) 100Mb 2ms LTEQueue/ULS1Queue
#create links between wired and BS nodes
$ns duplex-link-op $W(0) $W(1) orient down
$ns duplex-link-op $W(1) $BS(0) orient left-down
#posisi awal
$node_(0) set X_ 120.0 
$node_(0) set Y_ 220.0
$node_(0) set Z_ 0.0
$node_(1) set X_ 260.0
$node_(1) set Y_ 260.0
$node_(1) set Z_ 0.0
$node_(2) set X_ 320.0
$node_(2) set Y_ 120.0
$node_(2) set Z_ 0.0
$node_(3) set X_ 300.0
$node_(3) set Y_ 350.0
$node_(3) set Z_ 0.0
$node_(4) set X_ 100.0
$node_(4) set Y_ 300.0
$node_(4) set Z_ 0.0
#movement
$ns at 10.0 "$node_(0) setdest 270.0 240.0 30.0"
$ns at 15.0 "$node_(1) setdest 350.0 300.0 20.0"
$ns at 5.0 "$node_(2) setdest 240.0 240.0 30.0"
$ns at 15.0 "$node_(3) setdest 200.0 250.0 20.0"
$ns at 5.0 "$node_(4) setdest 280.0 240.0 30.0"
#setup TCP Connection
set tcp1 [new Agent/TCP/Linux]
$tcp1 set window_ 48000
set sink1 [new Agent/TCPSink/Sack1]
$ns attach-agent $W(0) $tcp1
$ns attach-agent $node_(0) $sink1
$ns connect $tcp1 $sink1
$tcp1 set fid_ 1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ns at 0 "$tcp1 select_ca bic"
$ns at $opt(ftp1-start) "$ftp1 start"

set tcp2 [new Agent/TCP/Linux]
$tcp2 set window_ 48000
$tcp2 set fid_ 1
$ns attach-agent $W(0) $tcp2
set sink2 [new Agent/TCPSink/Sack1]
$ns attach-agent $node_(1) $sink2
$ns connect $tcp2 $sink2
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2
$ns at 0 "$tcp2 select_ca bic"
$ns at $opt(ftp2-start) "$ftp2 start"

set tcp3 [new Agent/TCP/Linux]
$tcp3 set window_ 48000
$tcp3 set fid_ 1
$ns attach-agent $W(0) $tcp3
set sink3 [new Agent/TCPSink/Sack1]
$ns attach-agent $node_(2) $sink3
$ns connect $tcp3 $sink3
set ftp3 [new Application/FTP]
$ftp3 attach-agent $tcp3
$ns at 0 "$tcp3 select_ca bic"
$ns at $opt(ftp3-start) "$ftp3 start"

set tcp4 [new Agent/TCP/Linux]
$tcp4 set window_ 48000
$tcp4 set fid_ 1
$ns attach-agent $W(0) $tcp4
set sink4 [new Agent/TCPSink/Sack1]
$ns attach-agent $node_(3) $sink4
$ns connect $tcp4 $sink4
set ftp4 [new Application/FTP]
$ftp4 attach-agent $tcp4
$ns at 0 "$tcp4 select_ca bic"
$ns at $opt(ftp4-start) "$ftp4 start"

set tcp5 [new Agent/TCP/Linux]
$tcp5 set window_ 48000
$tcp5 set fid_ 1
$ns attach-agent $W(0) $tcp5
set sink5 [new Agent/TCPSink/Sack1]
$ns attach-agent $node_(4) $sink5
$ns connect $tcp5 $sink5
set ftp5 [new Application/FTP]
$ftp5 attach-agent $tcp5
$ns at 0 "$tcp5 select_ca bic"
$ns at $opt(ftp5-start) "$ftp5 start"

#loss module
set loss_module6 [new ErrorModel]
$loss_module6 set rate_ 0.002
$loss_module6 ranvar [new RandomVariable/Uniform]
$loss_module6 drop-target [new Agent/Null]
$ns lossmodel $loss_module6 $W(1) $BS(0)

set loss_module7 [new ErrorModel]
$loss_module7 set rate_ 0.0002
$loss_module7 ranvar [new RandomVariable/Uniform]
$loss_module7 drop-target [new Agent/Null]
$ns lossmodel $loss_module7 $W(0) $W(1)

# Movement
$node_(0) set X_ 120.0 
$node_(0) set Y_ 220.0
$node_(0) set Z_ 0.0
$node_(1) set X_ 200.0
$node_(1) set Y_ 250.0
$node_(1) set Z_ 0.0
$node_(2) set X_ 100.0
$node_(2) set Y_ 100.0
$node_(2) set Z_ 0.0
$node_(3) set X_ 140.0
$node_(3) set Y_ 150.0
$node_(3) set Z_ 0.0
$node_(4) set X_ 140.0
$node_(4) set Y_ 300.0
$node_(4) set Z_ 0.0
# node mendekati BS
$ns at 10.0 "$node_(0) setdest 260.0 260.0 30.0"
$ns at 15.0 "$node_(1) setdest 240.0 240.0 20.0"
$ns at 5.0 "$node_(2) setdest 270.0 250.0 30.0"
$ns at 8.0 "$node_(3) setdest 240.0 260.0 30.0"
$ns at 12.0 "$node_(4) setdest 260.0 240.0 30.0"
# node menjauhi BS
$ns at 30.0 "$node_(0) setdest 100.0 200.0 30.0"
$ns at 35.0 "$node_(1) setdest 120.0 140.0 20.0"
$ns at 25.0 "$node_(2) setdest 150.0 150.0 30.0"
$ns at 28.0 "$node_(3) setdest 160.0 130.0 30.0"
$ns at 32.0 "$node_(4) setdest 200.0 140.0 30.0"
# Generation of movements
for {set i } {$i < $opt(nn) } {incr i} {
    $ns at $opt(stop) "$node_($i) reset";
}
$ns at $opt(stop) "$BS(0) reset";
# Tell all nodes when the simulation ends
$ns at $opt(stop) "$ns nam-end-wireless $opt(stop)"
$ns at $opt(stop) "stop"

proc plotWindow {tcpSource file} {
global ns
set time 1
set now [$ns now]
set cwnd [$tcpSource set cwnd_]
puts $file "$now $cwnd"
$ns at [expr $now+$time] "plotWindow $tcpSource $file" }
$ns at 0.0 "plotWindow $tcp1 $window0"
$ns at 0.0 "plotWindow $tcp2 $window1"
$ns at 0.0 "plotWindow $tcp3 $window2"
$ns at 0.0 "plotWindow $tcp4 $window3"
$ns at 0.0 "plotWindow $tcp5 $window4"
proc stop {} {
    global ns tracefd namtrace
    $ns flush-trace
    close $tracefd
    close $namtrace
    exec nam fair-down.nam &
    exit 0
}
# ending nam and the simulation 
$ns run
