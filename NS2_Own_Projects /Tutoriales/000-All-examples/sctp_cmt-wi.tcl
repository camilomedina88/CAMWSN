#    https://groups.google.com/forum/#!msg/ns-users/oF7SGStJNUo/29vSZuc6Kh0J

# ======================================================================
# Define options
# ======================================================================
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(x)              670   ;# X dimension of the topography
set val(y)              670   ;# Y dimension of the topography
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             6                          ;# number of mobilenodes
set val(rp)             DSDV                       ;# routing protocol
set val(sc)             "./scen-3-test" ;
set val(stop)           400.0           ;# simulation time
set val(ftp1-start)     20              ;
set val(ftp2-start)     30              ;
# ======================================================================
# Main Program
# ======================================================================


#
# Initialize Global Variables
#
set ns	[new Simulator]
set tracefd     [open simple-wireless-sctp.tr w]
set namtrace    [open simple-wireless-sctp.nam w]
$ns use-newtrace
$ns trace-all $tracefd
$ns namtrace-all-wireless $namtrace $val(x) $val(y)



# set up topography object
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

#
# Create God
#
create-god $val(nn)

#
# Create channel
#
set chan_1 [new $val(chan)]
set chan_2 [new $val(chan)]

#
#  Create the specified number of mobilenodes [$val(nn)] and "attach" them
#  to the channel. 
#  Here two nodes are created : node(0) and node(1)

# configure node


$ns node-config -adhocRouting $val(rp) \
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
-movementTrace OFF\
-channel $chan_1 \
 
set node_(0) [$ns node]
set node_(1) [$ns node]

set node_(2) [$ns node]
set node_(4) [$ns node]


$ns node-config\
       -channel $chan_2 \

set node_(3) [$ns node]
set node_(5) [$ns node]



$node_(0) random-motion 0	;# disable random motion
$node_(2)  random-motion 0	;# disable random motion
$node_(3)  random-motion 0	;# disable random motion

$node_(1) random-motion 0	;# disable random motion
$node_(4)  random-motion 0	;# disable random motion
$node_(5)  random-motion 0	;# disable random motion



$ns multihome-add-interface $node_(0) $node_(2)
$ns multihome-add-interface $node_(0) $node_(3)

$ns multihome-add-interface $node_(1) $node_(4)
$ns multihome-add-interface $node_(1) $node_(5)

# size of the nodes
for {set i 0} {$i < $val(nn)} {incr i} {

    # 20 defines the node size in nam, must adjust it according to your scenario
    # The function must be called after mobility model is defined
    
    $ns initial_node_pos $node_($i) 20
 
}

# loading scenarios
if { $val(sc) == "" } {
puts "*** NOTE: no scenario file specified."
        set opt(sc) "none"
} else {
puts "Loading scenario file..."
source $val(sc)
puts "Load complete..."
}


#SCTP traffic
set sctp0 [new Agent/SCTP/CMT]
$ns multihome-attach-agent $node_(0) $sctp0
$sctp0 set fid_ 0 
$sctp0 set debugMask_ -1
$sctp0 set debugFileIndex_ 0
$sctp0 set mtu_ 1500
$sctp0 set dataChunkSize_ 1468
$sctp0 set numOutStreams_ 1
$sctp0 set useCmtReordering_ 1   # turn on Reordering algo.
$sctp0 set useCmtCwnd_ 1         # turn on CUC algo.
$sctp0 set useCmtDelAck_ 1       # turn on DAC algo.
$sctp0 set eCmtRtxPolicy_ 4      # rtx. policy : RTX_CWND

#set trace_ch [open trace.sctp w]
$sctp0 set trace_all_ 1          # trace them all on one line
$sctp0 trace cwnd_
$sctp0 trace rto_
$sctp0 trace errorCount
#######edit#### $sctp0 attach $trace_ch

set sctp1 [new Agent/SCTP/CMT]
$ns multihome-attach-agent $node_(1) $sctp1
$sctp1 set debugMask_ -1
$sctp1 set debugFileIndex_ 1
$sctp1 set mtu_ 1500
$sctp1 set initialRwnd_ 65536 
$sctp1 set useDelayedSacks_ 1
$sctp1 set useCmtDelAck_ 1



$ns connect $sctp0 $sctp1

set ftp0 [new Application/FTP]
$ftp0 attach-agent $sctp0


#
# Tell nodes when the simulation ends
#
$ns at $val(stop) "$node_(0) reset";
$ns at $val(stop) "$node_(2) reset";
$ns at $val(stop) "$node_(3) reset";
$ns at $val(stop) "$node_(1) reset";
$ns at $val(stop) "$node_(4) reset";
$ns at $val(stop) "$node_(5) reset";

$ns at 20 "$ftp0 start"
$ns at $val(stop) "finish"

$ns at 200.01 "puts \"NS EXITING...\" ; $ns halt"
proc finish {} {
    global ns tracefd 
    $ns flush-trace
    close $tracefd 
}

puts "Starting Simulation..."
$ns run 
