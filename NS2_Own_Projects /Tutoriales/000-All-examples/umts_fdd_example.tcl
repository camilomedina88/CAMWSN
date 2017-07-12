# Traffico da sorgente FTP
# Il traffico proviene da sorgenti poste su terminali fissi

ns-random 1973272912

# Extract command line arguments
foreach argument $argv {
    scan $argument "duration=%d" duration
    scan $argument "numnodes=%d" num_nodes
    scan $argument "outdir=%s" out_dir
}

# Define options
set opt(chan)    Channel/FddChannel;	# channel type
set opt(prop)    Propagation/UmtsFdd;	# radio propagation model
set opt(netif)   Phy/UmtsFddPhy;	# network interface type
set opt(macbs)   Mac/UmtsFdd/BS;	# BS MAC type
set opt(macms)   Mac/UmtsFdd/MS;	# MS MAC type
set opt(ifq)     Queue/MQ;		# interface queue type
set opt(ll)      LL/RLC;		# link layer type
set opt(ant)     Antenna/OmniAntenna;	# antenna model
set opt(ifqlen)  5000;			# max packets in ifq
set opt(adhocRouting) NOAH;		# routing protocol
set opt(x)	 2000;			# x coordinate of topology
set opt(y)       2000;			# y coordinate of topology
set opt(seed)    0.0;			# seed for random number generator

set opt(start)   0.1;			
set opt(stop)    $duration;		# time to stop simulation

set tot_nodes   [expr $num_nodes + 1];

set opt(tr)     "$out_dir/ftp_trace_$num_nodes.tr"
set mac_trace   "$out_dir/ftp_mac_$num_nodes.tr"
set opt(trtcp)  "$out_dir/ftp_tcp_$num_nodes.tr"

Mac/UmtsFdd set verbose_ 0;		# to include MAC verbose output
Mac/UmtsFdd set alloc_trace_ 0;		# trace allocated blocks
Mac/UmtsFdd set snr_trace_ 1;		# trace SNR
Mac/UmtsFdd set txpower_trace_ 1;	# trace tx power
Mac/UmtsFdd set DCH_UL_SF_ 128;		# uplink DCH SF
Mac/UmtsFdd set min_DSCH_SF_ 4;
Mac/UmtsFdd set mean_inter_ -75;
Mac/UmtsFdd set var_inter_ 0;
Phy/UmtsFddPhy set error_rate_ 0;
Phy/UmtsFddPhy set verbose_ 0;

LL/RLC set acked_      1 ;#1 if acked..0 if non-acked posto inizialmente a 1
LL/RLC set rlcfraged_  1 ;#1-frag.......0-nofrag posto inizialmente a 1
LL/RLC set rlculfragsz_  9 ;# RLC UL fragment size (in bytes)
LL/RLC set rlcdlfragsz_  9 ;# RLC DL fragment size (in bytes) 
LL/RLC set rlcverbose_ 0 ; #to include RLC verbose output
LL/RLC set ptimer_duration_ 0.021 ; # Poll timeout
LL/RLC set mrw_timer_duration_ 0.2 ; # MRW timeout
LL/RLC set MaxDAT_ 4 ;
LL/RLC set poll_SDU_ 2;
LL/RLC set buffer_size_ 600;
LL/RLC set window_ 600 ;

# ============================================================================
# check for boundary parameters and random seed
if { $opt(x) == 0 || $opt(y) == 0 } {
	puts "No X-Y boundary values given for wireless topology\n"
}
if {$opt(seed) > 0} {
	puts "Seeding Random number generator with $opt(seed)\n"
	ns-random $opt(seed)
} 

#remove extrapkt headers else each pkt takes up too much space.
remove-packet-header LDP MPLS Snoop
remove-packet-header Ping TFRC TFRC_ACK
remove-packet-header Diffusion RAP IMEP 
remove-packet-header AODV SR TORA IPinIP 
remove-packet-header MIP HttpInval
remove-packet-header MFTP SRMEXT SRM aSRM
remove-packet-header mcastCtrl CtrMcast IVS
remove-packet-header Resv UMP Flags

# create simulator instance
set ns_   [new Simulator]

# set up for hierarchical routing
$ns_ node-config -addressType hierarchical
AddrParams set domain_num_ 2  	   ;# number of domains
lappend cluster_num 1 1            ;# number of clusters in each domain
AddrParams set cluster_num_ $cluster_num
lappend eilastlevel $tot_nodes $tot_nodes   ;# number of nodes in each cluster 
AddrParams set nodes_num_ $eilastlevel	 ;# of each domain

set tracefd  [open $opt(tr) w]
$ns_ trace-all $tracefd

set tracetcp [open $opt(trtcp) w]

# Create wired nodes
set temp ""
for {set i 0} {$i <= $num_nodes} {incr i} {
	lappend temp 0.0.$i
}
set GW(0) [$ns_ node [lindex $temp 0]]
for {set i 0} {$i < $num_nodes} {incr i} {
    set W($i) [$ns_ node [lindex $temp [expr $i+1]]]
    $ns_ duplex-link $GW(0) $W($i) 40Mb 50ms DropTail
#    $ns_ duplex-link-op $GW(0) $W($i) orient [expr 20*$i]deg
}

# Create topography object
set topo   [new Topography]

# define topology
$topo load_flatgrid $opt(x) $opt(y)

# create God
create-god [expr $num_nodes+1]

#set chan according to new ns
set chan1 [new $opt(chan)]  

# configure for base-station node
$ns_ node-config -adhocRouting $opt(adhocRouting) \
                 -llType $opt(ll) \
		 -macType $opt(macbs) \
                 -ifqType $opt(ifq) \
                 -ifqLen $opt(ifqlen) \
                 -antType $opt(ant) \
                 -propType $opt(prop) \
                 -phyType $opt(netif) \
		 -topoInstance $topo \
                 -wiredRouting ON \
		 -agentTrace ON \
                 -routerTrace OFF \
                 -macTrace OFF  \
		 -movementTrace OFF \
		 -channel $chan1  

# hier address to be used for wireless domain
set temp ""
for {set i 0} {$i <= $num_nodes} {incr i} {
	lappend temp 1.0.$i
}

# VARP table
set varp [new UmtsVARPTable]

#create base-station node
set BS(0) [$ns_ node [lindex $temp 0] $varp]
$BS(0) random-motion 0               ;# disable random motion

#provide some co-ord (centre of square) to base station node
$BS(0) set X_ [expr $opt(x)/2]
$BS(0) set Y_ [expr $opt(y)/2]
$BS(0) set Z_ 0.0

# create link between BS and GW
$ns_ duplex-link $BS(0) $GW(0) 200Mb 10ms DropTail

# create mobilenodes in the same domain as BS(0)  
#configure for mobilenodes
$ns_ node-config -wiredRouting OFF \
                 -macType $opt(macms) 

set rng [new RNG]
$rng seed 0

for {set j 0} {$j < $num_nodes} {incr j} {
    set node_($j) [ $ns_ node [lindex $temp [expr $j+1]] $varp ]
    $node_($j) base-station [AddrParams addr2id [$BS(0) node-addr]]
    [$BS(0) set mac_(0)] add_mobile [[$node_($j) set mac_(0)] id]
#   [$node_($j) set mac_(0)] bsmac [$BS(0) set mac_(0)]
    $node_($j) random-motion 1
}

set mac_trace_file [open $mac_trace w];	# MAC trace file
[$BS(0) set mac_(0)] trace_file $mac_trace_file

# FTP traffic is used here. Can use UDP/CBR instead.
for {set j 0} {$j < $num_nodes} {incr j} {

    [$node_($j) set mac_(0)] trace_file $mac_trace_file

    set s($j) [new Agent/TCP]
    $ns_ attach-agent $W($j) $s($j)  
    #$ns_ attach-agent $node_($j) $s($j)  
    $s($j) set packetSize_ 1000
    $s($j) set window_ 10
    
    $ns_ add-agent-trace $s($j) s($j)
    $ns_ monitor-agent-trace $s($j)
    $s($j) attach $tracetcp
    $s($j) trace cwnd_
    $s($j) trace rtt_
    $s($j) trace rttvar_
    
    set null($j) [new Agent/TCPSink]
    $ns_ attach-agent $node_($j) $null($j) 
    #$ns_ attach-agent $W($j) $null($j) 
    $null($j) set packetSize_ 40
    
    $ns_ connect $s($j) $null($j)
    
    set ftp($j) [new Application/FTP]
    
    $ftp($j) attach-agent $s($j) 
    
    $ns_ at $opt(start) "$node_($j) start"
    $ns_ at $opt(start) "$ftp($j) start"   
    $ns_ at $opt(stop) "$ftp($j) stop"
}

# Tell all nodes when the simulation ends
for {set i 0} {$i < $num_nodes} {incr i} {
    $ns_ at $opt(stop).0 "$node_($i) reset";
    $ns_ at $opt(stop).0 "$W($i) reset";
}
$ns_ at $opt(stop).0 "$GW(0) reset";
$ns_ at $opt(stop).0 "$BS(0) reset";

# $ns_ at $opt(stop).0002 "puts \" \" ; $ns_ halt" 
$ns_ at $opt(stop).0002 "$ns_ halt"
$ns_ at $opt(stop).0001 "stop"
proc stop {} {
    global ns_ tracefd tracetcp mac_trace_file
    $ns_ flush-trace
    close $tracefd
    close $tracetcp
    close $mac_trace_file
}

puts "Starting Simulation..."
$ns_ run
