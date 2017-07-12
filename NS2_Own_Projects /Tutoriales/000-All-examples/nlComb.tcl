# =     http://www.linuxquestions.org/questions/linux-software-2/patching-lte-in-ns2-33-a-4175486335/"16
# Define options
# ======================================================================
set opt(chan) Channel/WirelessChannel ;# channel type
set opt(prop) Propagation/TwoRayGround ;# radio-propagation model
set opt(netif) Phy/WirelessPhy ;# network interface type
set opt(mac) Mac/802_11 ;# MAC type
set opt(ifq) Queue/DropTail/PriQueue ;# interface queue type
set opt(ll) LL ;# link layer type
set opt(ant) Antenna/OmniAntenna ;# antenna model
set opt(ifqlen) 50 ;# max packet in ifq
set opt(nn) 3 ;# number of mobilenodes
set opt(adhocRouting) DSDV ;# routing protocol

set opt(cp) "" ;# connection pattern file(#cp file not used)
set opt(sc) "./scen-3-test"

set opt(x) 670 ;# x coordinate of topology
set opt(y) 670 ;# y coordinate of topology
set opt(seed) 0.0 ;# seed for random number gen.
set opt(stop) 250 ;# time to stop simulation

set opt(ftp-start) 3.4
set opt(cbr-start) 1.4

set num_wired_nodes 2
set num_bs_nodes 1

# ======================= =====================================================
# checking for boundary parameters and random seed
if { $opt(x) == 0 || $opt(y) == 0 } {
puts "No X-Y boundary values given for wireless topology\n"
}
if {$opt(seed) > 0} {
puts "Seeding Random number generator with $opt(seed)\n"
ns-random $opt(seed)
}

#simulator instance
set ns [new Simulator]

# set up for hierarchical routing(used for wireless cum wired tcl script)
$ns node-config -addressType hierarchical
AddrParams set domain_num_ 2 ;# number of domains
lappend cluster_num 2 1 ;# number of clusters in each domain
AddrParams set cluster_num_ $cluster_num
lappend eilastlevel 1 1 4 ;#(1 each w and 4 in wl)
AddrParams set nodes_num_ $eilastlevel ;

set tracefd [open wireless2-out.tr w]
set namtrace [open wireless2-out.nam w]
$ns trace-all $tracefd
$ns namtrace-all-wireless $namtrace $opt(x) $opt(y)

# Create topography object
set topo [new Topography]

# define topology
$topo load_flatgrid $opt(x) $opt(y)

# create God(opt is array so written like this)
create-god [expr $opt(nn) + $num_bs_nodes]

#------------------Creation of Wired Nodes------------------------------------------------------------#

set temp {0.0.0 0.0.0} ;# hierarchical addresses for wired domain
for {set i 0} {$i < $num_wired_nodes} {incr i} {
set aGW [$ns node [lindex $temp $i]]
$aGW label "aGW"

}


set temp {0.0.0 0.1.0} ;# hierarchical addresses for wired domain
for {set i 1} {$i < $num_wired_nodes} {incr i} {
set server [$ns node [lindex $temp $i]]
$server label "server"

}

#------------------------configure for base-station node------------------------------------------------#
$ns node-config -adhocRouting $opt(adhocRouting) \
-llType $opt(ll) \
-macType $opt(mac) \
-ifqType $opt(ifq) \
-ifqLen $opt(ifqlen) \
-antType $opt(ant) \
-propType $opt(prop) \
-phyType $opt(netif) \
-channelType $opt(chan) \
-topoInstance $topo \
-wiredRouting OFF \
-agentTrace ON \
-routerTrace ON \
-macTrace ON

#create base-station node
set temp {1.0.0 1.0.1 1.0.2 1.0.3} ;# hier address to be used for wireless
;# domain
set eNB [$ns node [lindex $temp 0]]
$eNB random-motion 0 ;# disable random motion

#provide some co-ord (fixed) to base station node
$eNB set X_ 1.0
$eNB set Y_ 2.0
$eNB set Z_ 0.0


#---------------------configuration of UE----------------------------------------------------------#
# create mobilenodes in the same domain as BS

#configure for mobilenodes
$ns node-config -wiredRouting ON

for {set j 0} {$j < $opt(nn)} {incr j} {
set UE($j) [ $ns node [lindex $temp \
[expr $j+1]] ]
$UE($j) base-station [AddrParams addr2id \
[$eNB node-addr]]

}
for { set i 0} {$i < $opt(nn)} {incr i} {
$ns simplex-link $UE($i) $eNB 500Mb 2ms LTEQueue/ULAirQueue
$ns simplex-link $eNB $UE($i) 1Gb 2ms LTEQueue/DLAirQueue

}
$UE(0) label "UE1"
$UE(1) label "UE2"
$UE(2) label "UE3"
#-----------------Orientation of links-------------------------------------------------------------#

#create links between wired and BS nodes

$ns duplex-link $aGW $server 5Mb 2ms LTEQueue/ULS1Queue
$ns simplex-link $aGW $eNB 5Gb 10ms LTEQueue/DLS1Queue

$ns duplex-link $aGW $server 5Mb 2ms DropTail



#-----------------------------TCP CONNECTIONS-----------------------------------------------------------#
set mproto DM
set mrthandle [$ns mrtproto $mproto {}]
set group [Node allocaddr]


for { set i 0 } { $i < $opt(nn) } {incr i} {
set s0($i) [new Session/RTP]
set s1($i) [new Session/RTP]
$s0($i) session_bw 12.2kb/s
$s1($i) session_bw 12.2kb/s
$s0($i) attach-node $UE($i)
$s1($i) attach-node $server
$ns at 0.7 "$s0($i) join-group $group"
$ns at 0.8 "$s0($i) start"
$ns at 0.9 "$s0($i) transmit 12.2kb/s"
$ns at 1.0 "$s1($i) join-group $group"
$ns at 1.1 "$s1($i) start"
$ns at 1.2 "$s1($i) transmit 12.2kb/s"
}

#create Null Agent for every UDP Agent in server
for { set i 0} {$i < $opt(nn)} {incr i} {
set udp($i) [new Agent/UDP]
$ns attach-agent $server $udp($i)
set null($i) [new Agent/Null]
$ns attach-agent $UE($i) $null($i)
$ns connect $udp($i) $null($i)
$udp($i) set class_ 1

set cbr($i) [new Application/Traffic/CBR]
$cbr($i) attach-agent $udp($i)
$cbr($i) set packetSize_ 1000
$cbr($i) set rate_ 0.01Mb
$cbr($i) set random_ false
$ns at 1.4 "$cbr($i) start"
}

# step 3.3 define the interactive traffic
$ns rtproto Session
set log [open "http.log" w]

# Care must be taken to make sure that every client sees the same set of pages as the servers to which they are attached.
set pgp [new PagePool/Math]
set tmp [new RandomVariable/Constant] ;# Size generator
$tmp set val_ 10240 ;# average page size
$pgp ranvar-size $tmp
set tmp [new RandomVariable/Exponential] ;# Age generator
$tmp set avg_ 4 ;# average page age
$pgp ranvar-age $tmp

set s [new Http/Server $ns $server]
$s set-page-generator $pgp
$s log $log

set cache [new Http/Cache $ns $aGW]
$cache log $log

for { set i 0} {$i<$opt(nn)} {incr i} {
set c($i) [new Http/Client $ns $UE($i)]
set ctmp($i) [new RandomVariable/Exponential] ;# Poisson process
$ctmp($i) set avg_ 1 ;# average request interval
$c($i) set-interval-generator $ctmp($i)
$c($i) set-page-generator $pgp
$c($i) log $log
}

$ns at 0.4 "start-connection"
proc start-connection {} {
global ns s cache c number
}
$cache connect $s
for { set i 0} { $i < $opt(nn) } {incr i} {
$c($i) connect $cache
$c($i) start-session $cache $s
}


for { set i 0} {$i < $opt(nn)} {incr i} {
set tcp($i) [new Agent/TCP]
$ns attach-agent $server $tcp($i)
set sink($i) [new Agent/TCPSink]
$ns attach-agent $UE($i) $sink($i)
$ns connect $tcp($i) $sink($i)
$tcp($i) set class_ 3
$tcp($i) set packetSize_ 0.5M

set ftp($i) [new Application/FTP]
$ftp($i) attach-agent $tcp($i)
$ns at 3.4 "$ftp($i) start"
}


#-----------------------------------------------------------------------------------------------------#


if { $opt(sc) == "" } {
puts "*** NOTE: no scenario file specified."
set opt(sc) "none"
} else {
puts "Loading scenario file..."
source $opt(sc)
puts "Load complete..."
}

#initial node position of wireless nodes in nam

for {set i 0} {$i < $opt(nn)} {incr i} {
$ns initial_node_pos $UE($i) 50
}


# Tell all nodes when the simulation ends
for {set i } {$i < $opt(nn) } {incr i} {
$ns at $opt(stop).0 "$UE($i) reset";
}
$ns at $opt(stop).0 "$eNB reset";

$ns at $opt(stop).0002 "puts \"NS EXITING...\" ; $ns halt"
$ns at $opt(stop).0001 "stop"
proc stop {} {
global ns_ tracefd namtrace
$ns flush-trace
close $tracefd
close $namtrace
exec nam wireless2-out.nam &
exit 0
}

# informative headers for CMUTracefile
puts $tracefd "M 0.0 nn $opt(nn) x $opt(x) y $opt(y) rp \
$opt(adhocRouting)"
puts $tracefd "M 0.0 sc $opt(sc) cp $opt(cp) seed $opt(seed)"
puts $tracefd "M 0.0 prop $opt(prop) ant $opt(ant)"

puts "Starting Simulation..."
$ns run 
