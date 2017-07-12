set opt(chan)           Channel/WirelessChannel    ;# channel type
set opt(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set opt(netif)          Phy/WirelessPhy            ;# network interface type
set opt(mac)            Mac/802_11                 ;# MAC type
set opt(mac1)           Mac/802_3                  ;# MAC type
set opt(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set opt(ll)             LL                         ;# link layer type
set opt(ant)            Antenna/OmniAntenna        ;# antenna model
set opt(ifqlen)         50                         ;# max packet in ifq
set opt(nn)             3                          ;# number of mobilenodes
set opt(adhocRouting)   DSDV                       ;# routing protocol

set opt(cp)             ""                         ;# connection pattern file
set opt(sc)             "";# "/home/ns229/ns-allinone-2.29/ns-2.29/tcl/mobility/scene/scen-3-test"
;# node movement file.

set opt(x)      670                            ;# x coordinate of topology
set opt(y)      670                            ;# y coordinate of topology
set opt(seed)   0.0                            ;# seed for random number gen.
set opt(stop)   250                            ;# time to stop simulation

set opt(ftp1-start)      160.0

#jiangren delete
#set opt(ftp2-start)      170.0

set num_wired_nodes      2
set num_bs_nodes         1

# ============================================================================
# check for boundary parameters and random seed
if { $opt(x) == 0 || $opt(y) == 0 } {
 puts "No X-Y boundary values given for wireless topology\n"
}
if {$opt(seed) > 0} {
 puts "Seeding Random number generator with $opt(seed)\n"
 ns-random $opt(seed)
}

# create simulator instance
set ns_   [new Simulator]

# set up for hierarchical routing
$ns_ node-config -addressType hierarchical
AddrParams set domain_num_ 2           ;# number of domains
lappend cluster_num 2 1                ;# number of clusters in each domain

AddrParams set cluster_num_ $cluster_num
lappend eilastlevel 1 1 4              ;# number of nodes in each cluster
AddrParams set nodes_num_ $eilastlevel ;# of each domain

set tracefd  [open ./wireless-out.tr w]
set namtrace [open /home/ns229/te/wireless2-out.nam w]
set f0 [open /home/ns229/te/cwnd1.dat w]
set f1 [open /home/ns229/te/cwnd2.dat w]
$ns_ trace-all $tracefd
$ns_ namtrace-all-wireless $namtrace $opt(x) $opt(y)

# Create topography object
set topo   [new Topography]

# define topology
$topo load_flatgrid $opt(x) $opt(y)

# create God
create-god [expr $opt(nn) + $num_bs_nodes]

$ns_ node-config -macType $opt(mac1)

#create wired nodes
set temp {0.0.0 0.1.0}        ;# hierarchical addresses for wired domain
for {set i 0} {$i < $num_wired_nodes} {incr i} {
    set W($i) [$ns_ node [lindex $temp $i]]
}


#set node_(2) [$ns_ node [lindex 1.0.3]]


# configure for base-station node
$ns_ node-config -adhocRouting $opt(adhocRouting) \
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

#create base-station node
set temp {1.0.0 1.0.1 1.0.2 1.0.3}   ;# hier address to be used for wireless
                                     ;# domain
set BS(0) [$ns_ node [lindex $temp 0]]
$BS(0) random-motion 0               ;# disable random motion

#provide some co-ord (fixed) to base station node
$BS(0) set X_ 300
$BS(0) set Y_ 300
$BS(0) set Z_ 0.0

# create mobilenodes in the same domain as BS(0)
# note the position and movement of mobilenodes is as defined
# in $opt(sc)

#configure for mobilenodes
#$ns_ node-config -wiredRouting OFF




#{$j < $opt(nn)}
  for {set j 0} {$j < 2} {incr j} {
    set node_($j) [ $ns_ node [lindex $temp \
     [expr $j+1]] ]
    $node_($j) base-station [AddrParams addr2id \
     [$BS(0) node-addr]]
}

set node_(2) [$ns_ node [lindex 1.0.3]]

#$ns_ set-multihome-core $node_(2)

#provide some co-ord (fixed) to wireless node
$node_(0) set X_ 200
$node_(0) set Y_ 400
$node_(0) set Z_ 0


#create links between wired and BS nodes

$ns_ duplex-link $W(0) $W(1) 5Mb 200ms DropTail
$ns_ duplex-link $W(1) $BS(0) 5Mb 200ms DropTail
#$ns_ duplex-link $node_(2) $node_(1) 5Mb 200ms DropTail
#$ns_ duplex-link $node_(2) $node_(0) 5Mb 200ms DropTail

$ns_ duplex-link-op $W(1) $W(0) orient down
$ns_ duplex-link-op $BS(0) $W(1) orient left-down


$ns_ multihome-add-interface $node_(2) $node_(0)
$ns_ multihome-add-interface $node_(2) $node_(1)

# setup STCP connections
set sctp0 [new Agent/SCTP]

#$ns_ multihome-attach-agent $node_(2) $sctp0
$ns_ multihome-attach-agent $node_(2) $sctp0

$sctp0 set fid_ 0
$sctp0 set debugMask_ -1
$sctp0 set debugFileIndex_ 0
$sctp0 set mtu_ 1500
$sctp0 set dataChunkSize_ 1468
$sctp0 set numOutStreams_ 1
$sctp0 set oneHeartbeatTimer_ 0  # each dest0 has its own heartbeat timer

set trace_ch0 [open /home/ns229/te/trace0.sctp w]
$sctp0 set trace_all_ 1           # trace them all on oneline
$sctp0 trace cwnd_
$sctp0 trace rtt_
$sctp0 trace errorCount_
$sctp0 attach $trace_ch0

set sctp1 [new Agent/SCTP]
$ns_ attach-agent $W(0) $sctp1
$sctp1 set debugMask_ -1
$sctp1 set debugFileIndex_ 1
$sctp1 set mtu_ 1500
$sctp1 set initialRwnd_ 131072
$sctp1 set useDelayedSacks_ 1





#set sctp2 [new Agent/SCTP]
#$ns_ attach-agent $W(1) $sctp2
#$sctp2 set fid_ 0
#$sctp2 set debugMask_ -1
#$sctp2 set debugFileIndex_ 0
#$sctp2 set mtu_ 1500
#$sctp2 set dataChunkSize_ 1468
#$sctp2 set numOutStreams_ 1
#$sctp2 set oneHeartbeatTimer_ 0  # each dest0 has its own heartbeat timer


#set trace_ch1 [open /home/ns229/wlan-sctp/trace1.sctp w]
#$sctp2 set trace_all_ 1           # trace them all on oneline
#$sctp2 trace cwnd_
#$sctp2 trace rtt_
#$sctp2 trace errorCount_

#$sctp2 attach $trace_ch1


#set sctp3 [new Agent/SCTP]
#$ns_ attach-agent $node_(1) $sctp3
#$sctp3 set debugMask_ -1
#$sctp3 set debugFileIndex_ 1
#$sctp3 set mtu_ 1500
#$sctp3 set initialRwnd_ 131072
#$sctp3 set useDelayedSacks_ 1
$ns_ color 0 Red
$ns_ color 1 Blue

$ns_ connect $sctp1 $sctp0
#$ns_ connect $sctp2 $sctp3


set ftp1 [new Application/FTP]
$ftp1 attach-agent $sctp1
$ns_ at $opt(ftp1-start) "$ftp1 start"


#set ftp2 [new Application/FTP]
#$ftp2 attach-agent $sctp2
#$ns_ at $opt(ftp2-start) "$ftp2 start"


# source connection-pattern and node-movement scripts
if { $opt(cp) == "" } {
 puts "*** NOTE: no connection pattern specified."
        set opt(cp) "none"
} else {
 puts "Loading connection pattern..."
 source $opt(cp)
}
if { $opt(sc) == "" } {
 puts "*** NOTE: no scenario file specified."
        set opt(sc) "none"
} else {
 puts "Loading scenario file..."
 source $opt(sc)
 puts "Load complete..."
}

# Define initial node position in nam

for {set i 0} {$i < 2} {incr i} {

    # 20 defines the node size in nam, must adjust it according to your
    # scenario
    # The function must be called after mobility model is defined

    $ns_ initial_node_pos $node_($i) 20
}

# Tell all nodes when the simulation ends
for {set i } {$i < $opt(nn) } {incr i} {
    $ns_ at $opt(stop).0 "$node_($i) reset";
}
$ns_ at $opt(stop).0 "$BS(0) reset";

$ns_ at $opt(stop).0002 "puts \"NS EXITING...\" ; $ns_ halt"
$ns_ at $opt(stop).0001 "stop"
proc stop {} {
    global ns_ tracefd namtrace f0 f1
    $ns_ flush-trace
     close $f0
     close $f1
    close $tracefd
    close $namtrace
exec /home/ns229/ns-allinone-2.29/bin/xgraph /home/ns229/te/cwnd1.dat
/home/ns229/te/cwnd2.dat &
exec /home/ns229/ns-allinone-2.29/bin/nam  /home/ns229/te/wireless2-out.nam

exit 0
}

# informative headers for CMUTracefile
puts $tracefd "M 0.0 nn $opt(nn) x $opt(x) y $opt(y) rp \
 $opt(adhocRouting)"
puts $tracefd "M 0.0 sc $opt(sc) cp $opt(cp) seed $opt(seed)"
puts $tracefd "M 0.0 prop $opt(prop) ant $opt(ant)"


#$sctp0 force-source $node_(1)
$sctp1 set-primary-destination $node_(1)
#$sctp2 set-primary-destination $node_(1)


$ns_ at 0.0 "record"

#$ns_ at 185 "$sctp1 set-primary-destination $node_(1)"


$ns_ at 550.0 "stop"

proc record {} {
        global sctp0 ns_ xsctp f0 f1 cwnd0 cwnd_ trace_ch0 sctp2 cnd1
trace_ch1
 #Get an instance of the simulator
 set ns_ [Simulator instance]
 #Set the time after which the procedure should be called again
        set time 0.2
 #How many bytes have been received by the traffic sinks?
        set cwnd0 [$sctp0 set cwnd_]
 #      set cwnd1 [$sctp2 set cwnd_]
       #Get the current time
        set now [$ns_ now]
  #write cwnd to the files
        puts $f0 "$now $cwnd0"
        #puts $f1 "$now $cwnd1"
       # puts $trace_ch1 "time_now=$now"
        puts $trace_ch0 "time_now=$now "
#Re-schedule the procedure
        $ns_ at [expr $now+$time] "record"
}

puts "Starting Simulation..."
$ns_ run
