set opt(chan)     Channel/WirelessChannel   ;# channel type
set opt(prop)     Propagation/TwoRayGround   ;# radio-propagation model
set opt(netif)    Phy/WirelessPhy  ;# network interface type
set opt(mac)      Mac/802_11    ;# MAC type
set opt(ifq)      Queue/DropTail/PriQueue    ;# interface queue type
set opt(ll)       LL     ;# link layer type
set opt(ant)      Antenna/OmniAntenna    ;# antenna model

set opt(x)        1000       ;# X dimension of the topography
set opt(y)        1000       ;# Y dimension of the topography

set opt(ifqlen)   50 ;# max packet in ifq
set opt(nn)       20     ;# number of nodes
#set opt(seed)     12345
set opt(lm)       false      ;# log movement
set opt(run)      1
set opt(stop)     100     ;# simulation time
set opt(rp)       AgentJ     ;# Routing Protocol

LL set mindelay_   50us
LL set delay_      25us
LL set bandwidth_  0  ;# not used
Agent/Null set sport_    0
Agent/Null set dport_    0
Queue/DropTail/PriQueue set Prefer_Routing_Protocols    1

# unity gain, omni-directional antennas
# set up the antennas to be centered in the node 
# and 1.5 meters above itAntenna/OmniAntenna set X_ 0
Antenna/OmniAntenna set Y_ 0
Antenna/OmniAntenna set Z_ 1.5
Antenna/OmniAntenna set Gt_ 1.0
Antenna/OmniAntenna set Gr_ 1.0

Mac/802_11 set CWMin_               15
Mac/802_11 set CWMax_               1023
Mac/802_11 set ShortRetryLimit_     7
Mac/802_11 set LongRetryLimit_      4
Mac/802_11 set RTSThreshold_        2000
Mac/802_11 set SlotTime_          0.000020        ;# 20us
Mac/802_11 set SIFS_              0.000010        ;# 10us
Mac/802_11 set PreambleLength_    144             ;# 144 bit
Mac/802_11 set PLCPHeaderLength_  48              ;# 48 bits
Mac/802_11 set PLCPDataRate_      1.0e6           ;# 1Mbps
Mac/802_11 set dataRate_          11.0e6          ;# 11Mbps
Mac/802_11 set basicRate_         1.0e6           ;# 1Mbps
Phy/WirelessPhy set CPThresh_ 10.0
Phy/WirelessPhy set CSThresh_ 1.559e-11
Phy/WirelessPhy set RXThresh_ 3.652e-10  ;# = 250 m
Phy/WirelessPhy set Rb_ 2*1e6
Phy/WirelessPhy set Pt_ 0.2818
Phy/WirelessPhy set freq_ 2.4e+9
Phy/WirelessPhy set L_ 1.0
proc getopt {argc argv} {
  global opt
  lappend optlist cp nn seed stop tr x y

  for {set i 0} {$i < $argc} {incr i} {
    set arg [lindex $argv $i]
    if {[string range $arg 0 0] != "-"} continue

    set name [string range $arg 1 end]
    set opt($name) [lindex $argv [expr $i+1]]
  }
}

 # Timer Class copied from /tcl/mobility/timer.tcl
Class Timer
Timer instproc sched delay {
        global ns
        $self instvar id_
        $self cancel
        set id_ [$ns at [expr [$ns now] + $delay] "$self timeout"]
}
Timer instproc destroy {} {
        $self cancel
}
Timer instproc cancel {} {
        global ns
        $self instvar id_
        if [info exists id_] {
                $ns cancel $id_
                unset id_
        }
}
Timer instproc resched delay {
        $self sched $delay
}
Timer instproc expire {} {
        $self timeout
}
# end of Timer class

proc log-movement {} {
    global logtimer ns_ ns

    set ns $ns_
    Class LogTimer -superclass Timer
    LogTimer instproc timeout {} {
        global opt node_;
        for {set i 0} {$i < $opt(nn)} {incr i} {
            $node_($i) log-movement
        }
        $self sched 0.1
    }

    set logtimer [new LogTimer]
    $logtimer sched 0.1
}

proc create-god { nodes } {
  global ns_ god_ tracefd

  set god_ [new God]
  $god_ num_nodes $nodes
  $god_ on
}



# ===============================================================
getopt $argc $argv

if {$opt(run) < 1} {
   set opt(run) 1
}

if { $opt(x) == 0 || $opt(y) == 0 } {
  usage $argv0
  exit 1
}

if {[info exists opt(seed)] && $opt(seed) > 0} {
  puts "Seeding Random number generator with $opt(seed)\n"
  ns-random $opt(seed)
}


#
# Initialize Global Variables
#
set ns_            [new Simulator]
set chan           [new $opt(chan)]
set prop           [new $opt(prop)]
set topo           [new Topography]

#set nf [open JOLSRv2-$opt(nn)-$opt(run).nam w]
set f [open udprouting-$opt(nn)-$opt(run).tr w]

#$ns_ namtrace-all-wireless $nf $opt(x) $opt(y)
$ns_ trace-all $f
$ns_ use-newtrace

$topo load_flatgrid $opt(x) $opt(y)

$prop topography $topo

#
# Create God
#
create-god $opt(nn)
if { $opt(lm) == true } {
  log-movement
} else {
   puts "WARN: no logging of movements!!"
}

#
#  Create the specified number of nodes $opt(nn) and "attach" them
#  the channel.
#  Each routing protocol script is expected to have defined a proc
#  create-mobile-node that builds a mobile node and 
#  inserts it into the array global $node_($i)

$ns_ node-config \
                 -adhocRouting $opt(rp) \
                 -llType $opt(ll) \
                 -macType $opt(mac) \
                 -ifqType $opt(ifq) \
                 -ifqLen $opt(ifqlen) \
                 -antType $opt(ant) \
                 -propInstance $prop \
                 -phyType $opt(netif) \
                 -channel $chan \
                 -topoInstance $topo \
                 -wiredRouting OFF \
                 -agentTrace ON \
                 -routerTrace ON \
                 -macTrace ON \
                 -movementTrace $opt(lm)
$ns_ use-scheduler List

#enable node trace in nam

for {set i 0} {$i < $opt(nn)} {incr i} {
    set node_($i) [ $ns_ node ]
    $god_ new_node $node_($i)
    [$node_($i) set ragent_] attach-agentj agentj.examples.udprouting.Agent
    [$node_($i) set ragent_] agentj setRouterAgent Agent/AgentJRouter


    $ns_ at 0.0 "[$node_($i) set ragent_] agentj startProtocol"
    # reset nodes at the end of the simulation
    $ns_ at $opt(stop).000000003 "$node_($i) reset";
     # enable node trace
    $ns_ at 0.0 "$node_($i) log-movement"
    $ns_ at $opt(stop).0 "$node_($i) log-movement"
    $ns_ at $opt(stop).0 "[$node_($i) set ragent_] shutdown"
    $node_($i) random-motion 0
    $ns_ initial_node_pos $node_($i) 20
}

# $ns_ at $opt(stop).000000001 "puts \"Memory usage: \n[exec ps -C ns -o rss,vsz,pmem,pcpu]\""
$ns_ at $opt(stop).00000001 "puts \"NS EXITING...\" ; $ns_ halt; "


# Node Initial Positions
$node_(0) set X_ 360.769382421
$node_(0) set Y_ 767.159120968
$node_(0) set Z_ 0.000000000
$node_(1) set X_ 542.485330237
$node_(1) set Y_ 71.488695982
$node_(1) set Z_ 0.000000000
$node_(2) set X_ 580.617663590
$node_(2) set Y_ 127.517212157
$node_(2) set Z_ 0.000000000
$node_(3) set X_ 641.468191960
$node_(3) set Y_ 457.626078884
$node_(3) set Z_ 0.000000000
$node_(4) set X_ 461.751624969
$node_(4) set Y_ 996.965127051
$node_(4) set Z_ 0.000000000
$node_(5) set X_ 229.094446206
$node_(5) set Y_ 66.630563992
$node_(5) set Z_ 0.000000000
$node_(6) set X_ 590.281413612
$node_(6) set Y_ 879.884390919
$node_(6) set Z_ 0.000000000
$node_(7) set X_ 171.088277986
$node_(7) set Y_ 131.020177273
$node_(7) set Z_ 0.000000000
$node_(8) set X_ 254.834366584
$node_(8) set Y_ 481.965043557
$node_(8) set Z_ 0.000000000
$node_(9) set X_ 6.845268957
$node_(9) set Y_ 230.275818331
$node_(9) set Z_ 0.000000000
$node_(10) set X_ 309.217164863
$node_(10) set Y_ 757.404058462
$node_(10) set Z_ 0.000000000
$node_(11) set X_ 134.278080537
$node_(11) set Y_ 595.961131437
$node_(11) set Z_ 0.000000000
$node_(12) set X_ 623.367387384
$node_(12) set Y_ 919.350056822
$node_(12) set Z_ 0.000000000
$node_(13) set X_ 857.767721483
$node_(13) set Y_ 66.172419129
$node_(13) set Z_ 0.000000000
$node_(14) set X_ 498.817789758
$node_(14) set Y_ 63.931113409
$node_(14) set Z_ 0.000000000
$node_(15) set X_ 436.475854726
$node_(15) set Y_ 956.345807594
$node_(15) set Z_ 0.000000000
$node_(16) set X_ 526.106434903
$node_(16) set Y_ 989.012252765
$node_(16) set Z_ 0.000000000
$node_(17) set X_ 207.215350338
$node_(17) set Y_ 513.300292852
$node_(17) set Z_ 0.000000000
$node_(18) set X_ 679.016362476
$node_(18) set Y_ 991.839429282
$node_(18) set Z_ 0.000000000
$node_(19) set X_ 300.342471828
$node_(19) set Y_ 615.633908286
$node_(19) set Z_ 0.000000000

# Node Movements
$ns_ at 0.000000000 "$node_(0) setdest 973.106039444 275.402203861 2.499549318"
$ns_ at 0.000000000 "$node_(1) setdest 351.951257155 281.289659907 2.819719978"
$ns_ at 0.000000000 "$node_(2) setdest 645.076130958 880.425889693 5.898585303"
$ns_ at 0.000000000 "$node_(3) setdest 356.105237739 420.931999537 4.917392318"
$ns_ at 60.691499476 "$node_(3) setdest 705.171234661 197.679738609 3.571218365"
$ns_ at 0.000000000 "$node_(4) setdest 124.710341958 600.855069347 7.380537678"
$ns_ at 74.783013367 "$node_(4) setdest 528.771936990 927.423078104 2.927959512"
$ns_ at 0.000000000 "$node_(5) setdest 350.288450091 917.802703328 2.403749711"
$ns_ at 0.000000000 "$node_(6) setdest 632.452024026 901.206761199 5.037893999"
$ns_ at 9.897693135 "$node_(6) setdest 707.765585204 224.313534658 2.918348801"
$ns_ at 0.000000000 "$node_(7) setdest 870.589116566 816.517180164 5.455885011"
$ns_ at 0.000000000 "$node_(8) setdest 373.761238186 209.473595980 4.411112421"
$ns_ at 69.622657157 "$node_(8) setdest 881.685275875 734.068713204 6.395668467"
$ns_ at 0.000000000 "$node_(9) setdest 59.386953472 730.395658831 2.142022010"
$ns_ at 0.000000000 "$node_(10) setdest 936.087225848 208.129872207 5.165297574"
$ns_ at 0.000000000 "$node_(11) setdest 592.707860594 787.251745265 2.626736116"
$ns_ at 0.000000000 "$node_(12) setdest 797.060568667 980.120931680 7.548000221"
$ns_ at 28.519895066 "$node_(12) setdest 227.877550912 230.755311693 3.050439995"
$ns_ at 0.000000000 "$node_(13) setdest 798.024296025 656.809040622 5.170431677"
$ns_ at 0.000000000 "$node_(14) setdest 503.034539103 317.633260446 7.782001201"
$ns_ at 35.904757230 "$node_(14) setdest 484.437778349 927.371117909 7.636675571"
$ns_ at 0.000000000 "$node_(15) setdest 699.399714190 840.531029175 3.075945085"
$ns_ at 94.632836294 "$node_(15) setdest 473.114810274 753.572701723 3.917477054"
$ns_ at 0.000000000 "$node_(16) setdest 383.464134597 592.906888380 4.175902327"
$ns_ at 0.000000000 "$node_(17) setdest 22.604300859 511.145856224 2.444651924"
$ns_ at 79.147333881 "$node_(17) setdest 831.129123801 191.443821003 4.158564504"
$ns_ at 0.000000000 "$node_(18) setdest 960.366934401 812.848589868 3.684380837"
$ns_ at 94.262484536 "$node_(18) setdest 184.479114212 918.732674477 3.441096124"
$ns_ at 0.000000000 "$node_(19) setdest 693.771803978 47.345660689 3.287419534"
#creating CBR agent (source) #0 for node 6
	 set udp_(0) [new Agent/UDP]
	 set cbr_(0) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(6) $udp_(0)
	 $cbr_(0) attach-agent $udp_(0)

#creating NULL agent (sink) #0 for node 13
	 set null_(0) [new Agent/Null]
	$ns_ attach-agent $node_(13) $null_(0)

# setting up CBR stream between nodes 6 and 13
	$ns_ at 10.149631805883 		"$cbr_(0) set packetSize_ 64.0; \
						 $cbr_(0) set interval_ 0.02; \
						 $cbr_(0) set random_ 1; \
						 $ns_ connect $udp_(0) $null_(0); \
						 $cbr_(0) start"
	$ns_ at 20.149631805883 		"$cbr_(0) stop; "

#creating CBR agent (source) #1 for node 11
	 set udp_(1) [new Agent/UDP]
	 set cbr_(1) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(11) $udp_(1)
	 $cbr_(1) attach-agent $udp_(1)

#creating NULL agent (sink) #1 for node 19
	 set null_(1) [new Agent/Null]
	$ns_ attach-agent $node_(19) $null_(1)

# setting up CBR stream between nodes 11 and 19
	$ns_ at 14.4989038390512 		"$cbr_(1) set packetSize_ 64.0; \
						 $cbr_(1) set interval_ 0.02; \
						 $cbr_(1) set random_ 1; \
						 $ns_ connect $udp_(1) $null_(1); \
						 $cbr_(1) start"
	$ns_ at 24.4989038390512 		"$cbr_(1) stop; "

#creating CBR agent (source) #2 for node 16
	 set udp_(2) [new Agent/UDP]
	 set cbr_(2) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(16) $udp_(2)
	 $cbr_(2) attach-agent $udp_(2)

#creating NULL agent (sink) #2 for node 6
	 set null_(2) [new Agent/Null]
	$ns_ attach-agent $node_(6) $null_(2)

# setting up CBR stream between nodes 16 and 6
	$ns_ at 14.6125260739821 		"$cbr_(2) set packetSize_ 64.0; \
						 $cbr_(2) set interval_ 0.02; \
						 $cbr_(2) set random_ 1; \
						 $ns_ connect $udp_(2) $null_(2); \
						 $cbr_(2) start"
	$ns_ at 24.6125260739821 		"$cbr_(2) stop; "

#creating CBR agent (source) #3 for node 7
	 set udp_(3) [new Agent/UDP]
	 set cbr_(3) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(7) $udp_(3)
	 $cbr_(3) attach-agent $udp_(3)

#creating NULL agent (sink) #3 for node 18
	 set null_(3) [new Agent/Null]
	$ns_ attach-agent $node_(18) $null_(3)

# setting up CBR stream between nodes 7 and 18
	$ns_ at 18.080276745054 		"$cbr_(3) set packetSize_ 64.0; \
						 $cbr_(3) set interval_ 0.02; \
						 $cbr_(3) set random_ 1; \
						 $ns_ connect $udp_(3) $null_(3); \
						 $cbr_(3) start"
	$ns_ at 28.080276745054 		"$cbr_(3) stop; "

#creating CBR agent (source) #4 for node 16
	 set udp_(4) [new Agent/UDP]
	 set cbr_(4) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(16) $udp_(4)
	 $cbr_(4) attach-agent $udp_(4)

#creating NULL agent (sink) #4 for node 18
	 set null_(4) [new Agent/Null]
	$ns_ attach-agent $node_(18) $null_(4)

# setting up CBR stream between nodes 16 and 18
	$ns_ at 21.7265215688693 		"$cbr_(4) set packetSize_ 64.0; \
						 $cbr_(4) set interval_ 0.02; \
						 $cbr_(4) set random_ 1; \
						 $ns_ connect $udp_(4) $null_(4); \
						 $cbr_(4) start"
	$ns_ at 31.7265215688693 		"$cbr_(4) stop; "

#creating CBR agent (source) #5 for node 15
	 set udp_(5) [new Agent/UDP]
	 set cbr_(5) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(15) $udp_(5)
	 $cbr_(5) attach-agent $udp_(5)

#creating NULL agent (sink) #5 for node 17
	 set null_(5) [new Agent/Null]
	$ns_ attach-agent $node_(17) $null_(5)

# setting up CBR stream between nodes 15 and 17
	$ns_ at 24.9177157010068 		"$cbr_(5) set packetSize_ 64.0; \
						 $cbr_(5) set interval_ 0.02; \
						 $cbr_(5) set random_ 1; \
						 $ns_ connect $udp_(5) $null_(5); \
						 $cbr_(5) start"
	$ns_ at 34.9177157010068 		"$cbr_(5) stop; "

#creating CBR agent (source) #6 for node 7
	 set udp_(6) [new Agent/UDP]
	 set cbr_(6) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(7) $udp_(6)
	 $cbr_(6) attach-agent $udp_(6)

#creating NULL agent (sink) #6 for node 3
	 set null_(6) [new Agent/Null]
	$ns_ attach-agent $node_(3) $null_(6)

# setting up CBR stream between nodes 7 and 3
	$ns_ at 25.1145911033906 		"$cbr_(6) set packetSize_ 64.0; \
						 $cbr_(6) set interval_ 0.02; \
						 $cbr_(6) set random_ 1; \
						 $ns_ connect $udp_(6) $null_(6); \
						 $cbr_(6) start"
	$ns_ at 35.1145911033906 		"$cbr_(6) stop; "

#creating CBR agent (source) #7 for node 19
	 set udp_(7) [new Agent/UDP]
	 set cbr_(7) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(19) $udp_(7)
	 $cbr_(7) attach-agent $udp_(7)

#creating NULL agent (sink) #7 for node 16
	 set null_(7) [new Agent/Null]
	$ns_ attach-agent $node_(16) $null_(7)

# setting up CBR stream between nodes 19 and 16
	$ns_ at 25.2490957645195 		"$cbr_(7) set packetSize_ 64.0; \
						 $cbr_(7) set interval_ 0.02; \
						 $cbr_(7) set random_ 1; \
						 $ns_ connect $udp_(7) $null_(7); \
						 $cbr_(7) start"
	$ns_ at 35.2490957645195 		"$cbr_(7) stop; "

#creating CBR agent (source) #8 for node 2
	 set udp_(8) [new Agent/UDP]
	 set cbr_(8) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(2) $udp_(8)
	 $cbr_(8) attach-agent $udp_(8)

#creating NULL agent (sink) #8 for node 6
	 set null_(8) [new Agent/Null]
	$ns_ attach-agent $node_(6) $null_(8)

# setting up CBR stream between nodes 2 and 6
	$ns_ at 25.4593109659917 		"$cbr_(8) set packetSize_ 64.0; \
						 $cbr_(8) set interval_ 0.02; \
						 $cbr_(8) set random_ 1; \
						 $ns_ connect $udp_(8) $null_(8); \
						 $cbr_(8) start"
	$ns_ at 35.4593109659917 		"$cbr_(8) stop; "

#creating CBR agent (source) #9 for node 12
	 set udp_(9) [new Agent/UDP]
	 set cbr_(9) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(12) $udp_(9)
	 $cbr_(9) attach-agent $udp_(9)

#creating NULL agent (sink) #9 for node 11
	 set null_(9) [new Agent/Null]
	$ns_ attach-agent $node_(11) $null_(9)

# setting up CBR stream between nodes 12 and 11
	$ns_ at 27.0913089081662 		"$cbr_(9) set packetSize_ 64.0; \
						 $cbr_(9) set interval_ 0.02; \
						 $cbr_(9) set random_ 1; \
						 $ns_ connect $udp_(9) $null_(9); \
						 $cbr_(9) start"
	$ns_ at 37.0913089081662 		"$cbr_(9) stop; "

#creating CBR agent (source) #10 for node 2
	 set udp_(10) [new Agent/UDP]
	 set cbr_(10) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(2) $udp_(10)
	 $cbr_(10) attach-agent $udp_(10)

#creating NULL agent (sink) #10 for node 4
	 set null_(10) [new Agent/Null]
	$ns_ attach-agent $node_(4) $null_(10)

# setting up CBR stream between nodes 2 and 4
	$ns_ at 27.2345149081421 		"$cbr_(10) set packetSize_ 64.0; \
						 $cbr_(10) set interval_ 0.02; \
						 $cbr_(10) set random_ 1; \
						 $ns_ connect $udp_(10) $null_(10); \
						 $cbr_(10) start"
	$ns_ at 37.2345149081421 		"$cbr_(10) stop; "

#creating CBR agent (source) #11 for node 13
	 set udp_(11) [new Agent/UDP]
	 set cbr_(11) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(13) $udp_(11)
	 $cbr_(11) attach-agent $udp_(11)

#creating NULL agent (sink) #11 for node 9
	 set null_(11) [new Agent/Null]
	$ns_ attach-agent $node_(9) $null_(11)

# setting up CBR stream between nodes 13 and 9
	$ns_ at 28.5237754686116 		"$cbr_(11) set packetSize_ 64.0; \
						 $cbr_(11) set interval_ 0.02; \
						 $cbr_(11) set random_ 1; \
						 $ns_ connect $udp_(11) $null_(11); \
						 $cbr_(11) start"
	$ns_ at 38.5237754686116 		"$cbr_(11) stop; "

#creating CBR agent (source) #12 for node 12
	 set udp_(12) [new Agent/UDP]
	 set cbr_(12) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(12) $udp_(12)
	 $cbr_(12) attach-agent $udp_(12)

#creating NULL agent (sink) #12 for node 14
	 set null_(12) [new Agent/Null]
	$ns_ attach-agent $node_(14) $null_(12)

# setting up CBR stream between nodes 12 and 14
	$ns_ at 29.67498984271 		"$cbr_(12) set packetSize_ 64.0; \
						 $cbr_(12) set interval_ 0.02; \
						 $cbr_(12) set random_ 1; \
						 $ns_ connect $udp_(12) $null_(12); \
						 $cbr_(12) start"
	$ns_ at 39.67498984271 		"$cbr_(12) stop; "

#creating CBR agent (source) #13 for node 13
	 set udp_(13) [new Agent/UDP]
	 set cbr_(13) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(13) $udp_(13)
	 $cbr_(13) attach-agent $udp_(13)

#creating NULL agent (sink) #13 for node 17
	 set null_(13) [new Agent/Null]
	$ns_ attach-agent $node_(17) $null_(13)

# setting up CBR stream between nodes 13 and 17
	$ns_ at 31.7771849320459 		"$cbr_(13) set packetSize_ 64.0; \
						 $cbr_(13) set interval_ 0.02; \
						 $cbr_(13) set random_ 1; \
						 $ns_ connect $udp_(13) $null_(13); \
						 $cbr_(13) start"
	$ns_ at 41.7771849320459 		"$cbr_(13) stop; "

#creating CBR agent (source) #14 for node 2
	 set udp_(14) [new Agent/UDP]
	 set cbr_(14) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(2) $udp_(14)
	 $cbr_(14) attach-agent $udp_(14)

#creating NULL agent (sink) #14 for node 13
	 set null_(14) [new Agent/Null]
	$ns_ attach-agent $node_(13) $null_(14)

# setting up CBR stream between nodes 2 and 13
	$ns_ at 34.9228719734075 		"$cbr_(14) set packetSize_ 64.0; \
						 $cbr_(14) set interval_ 0.02; \
						 $cbr_(14) set random_ 1; \
						 $ns_ connect $udp_(14) $null_(14); \
						 $cbr_(14) start"
	$ns_ at 44.9228719734075 		"$cbr_(14) stop; "

#creating CBR agent (source) #15 for node 7
	 set udp_(15) [new Agent/UDP]
	 set cbr_(15) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(7) $udp_(15)
	 $cbr_(15) attach-agent $udp_(15)

#creating NULL agent (sink) #15 for node 16
	 set null_(15) [new Agent/Null]
	$ns_ attach-agent $node_(16) $null_(15)

# setting up CBR stream between nodes 7 and 16
	$ns_ at 37.7602367220717 		"$cbr_(15) set packetSize_ 64.0; \
						 $cbr_(15) set interval_ 0.02; \
						 $cbr_(15) set random_ 1; \
						 $ns_ connect $udp_(15) $null_(15); \
						 $cbr_(15) start"
	$ns_ at 47.7602367220717 		"$cbr_(15) stop; "

#creating CBR agent (source) #16 for node 18
	 set udp_(16) [new Agent/UDP]
	 set cbr_(16) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(18) $udp_(16)
	 $cbr_(16) attach-agent $udp_(16)

#creating NULL agent (sink) #16 for node 9
	 set null_(16) [new Agent/Null]
	$ns_ attach-agent $node_(9) $null_(16)

# setting up CBR stream between nodes 18 and 9
	$ns_ at 42.6786121642602 		"$cbr_(16) set packetSize_ 64.0; \
						 $cbr_(16) set interval_ 0.02; \
						 $cbr_(16) set random_ 1; \
						 $ns_ connect $udp_(16) $null_(16); \
						 $cbr_(16) start"
	$ns_ at 52.6786121642602 		"$cbr_(16) stop; "

#creating CBR agent (source) #17 for node 4
	 set udp_(17) [new Agent/UDP]
	 set cbr_(17) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(4) $udp_(17)
	 $cbr_(17) attach-agent $udp_(17)

#creating NULL agent (sink) #17 for node 13
	 set null_(17) [new Agent/Null]
	$ns_ attach-agent $node_(13) $null_(17)

# setting up CBR stream between nodes 4 and 13
	$ns_ at 43.3688038443268 		"$cbr_(17) set packetSize_ 64.0; \
						 $cbr_(17) set interval_ 0.02; \
						 $cbr_(17) set random_ 1; \
						 $ns_ connect $udp_(17) $null_(17); \
						 $cbr_(17) start"
	$ns_ at 53.3688038443268 		"$cbr_(17) stop; "

#creating CBR agent (source) #18 for node 4
	 set udp_(18) [new Agent/UDP]
	 set cbr_(18) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(4) $udp_(18)
	 $cbr_(18) attach-agent $udp_(18)

#creating NULL agent (sink) #18 for node 13
	 set null_(18) [new Agent/Null]
	$ns_ attach-agent $node_(13) $null_(18)

# setting up CBR stream between nodes 4 and 13
	$ns_ at 46.3186357870931 		"$cbr_(18) set packetSize_ 64.0; \
						 $cbr_(18) set interval_ 0.02; \
						 $cbr_(18) set random_ 1; \
						 $ns_ connect $udp_(18) $null_(18); \
						 $cbr_(18) start"
	$ns_ at 56.3186357870931 		"$cbr_(18) stop; "

#creating CBR agent (source) #19 for node 12
	 set udp_(19) [new Agent/UDP]
	 set cbr_(19) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(12) $udp_(19)
	 $cbr_(19) attach-agent $udp_(19)

#creating NULL agent (sink) #19 for node 14
	 set null_(19) [new Agent/Null]
	$ns_ attach-agent $node_(14) $null_(19)

# setting up CBR stream between nodes 12 and 14
	$ns_ at 46.5431384203564 		"$cbr_(19) set packetSize_ 64.0; \
						 $cbr_(19) set interval_ 0.02; \
						 $cbr_(19) set random_ 1; \
						 $ns_ connect $udp_(19) $null_(19); \
						 $cbr_(19) start"
	$ns_ at 56.5431384203564 		"$cbr_(19) stop; "

#creating CBR agent (source) #20 for node 1
	 set udp_(20) [new Agent/UDP]
	 set cbr_(20) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(1) $udp_(20)
	 $cbr_(20) attach-agent $udp_(20)

#creating NULL agent (sink) #20 for node 10
	 set null_(20) [new Agent/Null]
	$ns_ attach-agent $node_(10) $null_(20)

# setting up CBR stream between nodes 1 and 10
	$ns_ at 47.3970437023866 		"$cbr_(20) set packetSize_ 64.0; \
						 $cbr_(20) set interval_ 0.02; \
						 $cbr_(20) set random_ 1; \
						 $ns_ connect $udp_(20) $null_(20); \
						 $cbr_(20) start"
	$ns_ at 57.3970437023866 		"$cbr_(20) stop; "

#creating CBR agent (source) #21 for node 5
	 set udp_(21) [new Agent/UDP]
	 set cbr_(21) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(5) $udp_(21)
	 $cbr_(21) attach-agent $udp_(21)

#creating NULL agent (sink) #21 for node 3
	 set null_(21) [new Agent/Null]
	$ns_ attach-agent $node_(3) $null_(21)

# setting up CBR stream between nodes 5 and 3
	$ns_ at 47.4256417967663 		"$cbr_(21) set packetSize_ 64.0; \
						 $cbr_(21) set interval_ 0.02; \
						 $cbr_(21) set random_ 1; \
						 $ns_ connect $udp_(21) $null_(21); \
						 $cbr_(21) start"
	$ns_ at 57.4256417967663 		"$cbr_(21) stop; "

#creating CBR agent (source) #22 for node 2
	 set udp_(22) [new Agent/UDP]
	 set cbr_(22) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(2) $udp_(22)
	 $cbr_(22) attach-agent $udp_(22)

#creating NULL agent (sink) #22 for node 16
	 set null_(22) [new Agent/Null]
	$ns_ attach-agent $node_(16) $null_(22)

# setting up CBR stream between nodes 2 and 16
	$ns_ at 50.00057127851 		"$cbr_(22) set packetSize_ 64.0; \
						 $cbr_(22) set interval_ 0.02; \
						 $cbr_(22) set random_ 1; \
						 $ns_ connect $udp_(22) $null_(22); \
						 $cbr_(22) start"
	$ns_ at 60.00057127851 		"$cbr_(22) stop; "

#creating CBR agent (source) #23 for node 7
	 set udp_(23) [new Agent/UDP]
	 set cbr_(23) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(7) $udp_(23)
	 $cbr_(23) attach-agent $udp_(23)

#creating NULL agent (sink) #23 for node 18
	 set null_(23) [new Agent/Null]
	$ns_ attach-agent $node_(18) $null_(23)

# setting up CBR stream between nodes 7 and 18
	$ns_ at 52.5335680312443 		"$cbr_(23) set packetSize_ 64.0; \
						 $cbr_(23) set interval_ 0.02; \
						 $cbr_(23) set random_ 1; \
						 $ns_ connect $udp_(23) $null_(23); \
						 $cbr_(23) start"
	$ns_ at 62.5335680312443 		"$cbr_(23) stop; "

#creating CBR agent (source) #24 for node 10
	 set udp_(24) [new Agent/UDP]
	 set cbr_(24) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(10) $udp_(24)
	 $cbr_(24) attach-agent $udp_(24)

#creating NULL agent (sink) #24 for node 13
	 set null_(24) [new Agent/Null]
	$ns_ attach-agent $node_(13) $null_(24)

# setting up CBR stream between nodes 10 and 13
	$ns_ at 55.4956760753125 		"$cbr_(24) set packetSize_ 64.0; \
						 $cbr_(24) set interval_ 0.02; \
						 $cbr_(24) set random_ 1; \
						 $ns_ connect $udp_(24) $null_(24); \
						 $cbr_(24) start"
	$ns_ at 65.4956760753125 		"$cbr_(24) stop; "

#creating CBR agent (source) #25 for node 17
	 set udp_(25) [new Agent/UDP]
	 set cbr_(25) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(17) $udp_(25)
	 $cbr_(25) attach-agent $udp_(25)

#creating NULL agent (sink) #25 for node 12
	 set null_(25) [new Agent/Null]
	$ns_ attach-agent $node_(12) $null_(25)

# setting up CBR stream between nodes 17 and 12
	$ns_ at 57.0987089296715 		"$cbr_(25) set packetSize_ 64.0; \
						 $cbr_(25) set interval_ 0.02; \
						 $cbr_(25) set random_ 1; \
						 $ns_ connect $udp_(25) $null_(25); \
						 $cbr_(25) start"
	$ns_ at 67.0987089296715 		"$cbr_(25) stop; "

#creating CBR agent (source) #26 for node 4
	 set udp_(26) [new Agent/UDP]
	 set cbr_(26) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(4) $udp_(26)
	 $cbr_(26) attach-agent $udp_(26)

#creating NULL agent (sink) #26 for node 10
	 set null_(26) [new Agent/Null]
	$ns_ attach-agent $node_(10) $null_(26)

# setting up CBR stream between nodes 4 and 10
	$ns_ at 57.9557827911707 		"$cbr_(26) set packetSize_ 64.0; \
						 $cbr_(26) set interval_ 0.02; \
						 $cbr_(26) set random_ 1; \
						 $ns_ connect $udp_(26) $null_(26); \
						 $cbr_(26) start"
	$ns_ at 67.9557827911707 		"$cbr_(26) stop; "

#creating CBR agent (source) #27 for node 7
	 set udp_(27) [new Agent/UDP]
	 set cbr_(27) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(7) $udp_(27)
	 $cbr_(27) attach-agent $udp_(27)

#creating NULL agent (sink) #27 for node 12
	 set null_(27) [new Agent/Null]
	$ns_ attach-agent $node_(12) $null_(27)

# setting up CBR stream between nodes 7 and 12
	$ns_ at 59.5690701401522 		"$cbr_(27) set packetSize_ 64.0; \
						 $cbr_(27) set interval_ 0.02; \
						 $cbr_(27) set random_ 1; \
						 $ns_ connect $udp_(27) $null_(27); \
						 $cbr_(27) start"
	$ns_ at 69.5690701401522 		"$cbr_(27) stop; "

#creating CBR agent (source) #28 for node 5
	 set udp_(28) [new Agent/UDP]
	 set cbr_(28) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(5) $udp_(28)
	 $cbr_(28) attach-agent $udp_(28)

#creating NULL agent (sink) #28 for node 6
	 set null_(28) [new Agent/Null]
	$ns_ attach-agent $node_(6) $null_(28)

# setting up CBR stream between nodes 5 and 6
	$ns_ at 60.9838367676729 		"$cbr_(28) set packetSize_ 64.0; \
						 $cbr_(28) set interval_ 0.02; \
						 $cbr_(28) set random_ 1; \
						 $ns_ connect $udp_(28) $null_(28); \
						 $cbr_(28) start"
	$ns_ at 70.9838367676729 		"$cbr_(28) stop; "

#creating CBR agent (source) #29 for node 14
	 set udp_(29) [new Agent/UDP]
	 set cbr_(29) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(14) $udp_(29)
	 $cbr_(29) attach-agent $udp_(29)

#creating NULL agent (sink) #29 for node 6
	 set null_(29) [new Agent/Null]
	$ns_ attach-agent $node_(6) $null_(29)

# setting up CBR stream between nodes 14 and 6
	$ns_ at 61.1862246587403 		"$cbr_(29) set packetSize_ 64.0; \
						 $cbr_(29) set interval_ 0.02; \
						 $cbr_(29) set random_ 1; \
						 $ns_ connect $udp_(29) $null_(29); \
						 $cbr_(29) start"
	$ns_ at 71.1862246587403 		"$cbr_(29) stop; "

#creating CBR agent (source) #30 for node 9
	 set udp_(30) [new Agent/UDP]
	 set cbr_(30) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(9) $udp_(30)
	 $cbr_(30) attach-agent $udp_(30)

#creating NULL agent (sink) #30 for node 5
	 set null_(30) [new Agent/Null]
	$ns_ attach-agent $node_(5) $null_(30)

# setting up CBR stream between nodes 9 and 5
	$ns_ at 61.314314275553 		"$cbr_(30) set packetSize_ 64.0; \
						 $cbr_(30) set interval_ 0.02; \
						 $cbr_(30) set random_ 1; \
						 $ns_ connect $udp_(30) $null_(30); \
						 $cbr_(30) start"
	$ns_ at 71.314314275553 		"$cbr_(30) stop; "

#creating CBR agent (source) #31 for node 18
	 set udp_(31) [new Agent/UDP]
	 set cbr_(31) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(18) $udp_(31)
	 $cbr_(31) attach-agent $udp_(31)

#creating NULL agent (sink) #31 for node 9
	 set null_(31) [new Agent/Null]
	$ns_ attach-agent $node_(9) $null_(31)

# setting up CBR stream between nodes 18 and 9
	$ns_ at 63.0006031781862 		"$cbr_(31) set packetSize_ 64.0; \
						 $cbr_(31) set interval_ 0.02; \
						 $cbr_(31) set random_ 1; \
						 $ns_ connect $udp_(31) $null_(31); \
						 $cbr_(31) start"
	$ns_ at 73.0006031781862 		"$cbr_(31) stop; "

#creating CBR agent (source) #32 for node 6
	 set udp_(32) [new Agent/UDP]
	 set cbr_(32) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(6) $udp_(32)
	 $cbr_(32) attach-agent $udp_(32)

#creating NULL agent (sink) #32 for node 3
	 set null_(32) [new Agent/Null]
	$ns_ attach-agent $node_(3) $null_(32)

# setting up CBR stream between nodes 6 and 3
	$ns_ at 64.2916970706411 		"$cbr_(32) set packetSize_ 64.0; \
						 $cbr_(32) set interval_ 0.02; \
						 $cbr_(32) set random_ 1; \
						 $ns_ connect $udp_(32) $null_(32); \
						 $cbr_(32) start"
	$ns_ at 74.2916970706411 		"$cbr_(32) stop; "

#creating CBR agent (source) #33 for node 9
	 set udp_(33) [new Agent/UDP]
	 set cbr_(33) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(9) $udp_(33)
	 $cbr_(33) attach-agent $udp_(33)

#creating NULL agent (sink) #33 for node 15
	 set null_(33) [new Agent/Null]
	$ns_ attach-agent $node_(15) $null_(33)

# setting up CBR stream between nodes 9 and 15
	$ns_ at 65.5397702378403 		"$cbr_(33) set packetSize_ 64.0; \
						 $cbr_(33) set interval_ 0.02; \
						 $cbr_(33) set random_ 1; \
						 $ns_ connect $udp_(33) $null_(33); \
						 $cbr_(33) start"
	$ns_ at 75.5397702378403 		"$cbr_(33) stop; "

#creating CBR agent (source) #34 for node 10
	 set udp_(34) [new Agent/UDP]
	 set cbr_(34) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(10) $udp_(34)
	 $cbr_(34) attach-agent $udp_(34)

#creating NULL agent (sink) #34 for node 6
	 set null_(34) [new Agent/Null]
	$ns_ attach-agent $node_(6) $null_(34)

# setting up CBR stream between nodes 10 and 6
	$ns_ at 65.7642862625895 		"$cbr_(34) set packetSize_ 64.0; \
						 $cbr_(34) set interval_ 0.02; \
						 $cbr_(34) set random_ 1; \
						 $ns_ connect $udp_(34) $null_(34); \
						 $cbr_(34) start"
	$ns_ at 75.7642862625895 		"$cbr_(34) stop; "

#creating CBR agent (source) #35 for node 14
	 set udp_(35) [new Agent/UDP]
	 set cbr_(35) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(14) $udp_(35)
	 $cbr_(35) attach-agent $udp_(35)

#creating NULL agent (sink) #35 for node 9
	 set null_(35) [new Agent/Null]
	$ns_ attach-agent $node_(9) $null_(35)

# setting up CBR stream between nodes 14 and 9
	$ns_ at 72.1969517550513 		"$cbr_(35) set packetSize_ 64.0; \
						 $cbr_(35) set interval_ 0.02; \
						 $cbr_(35) set random_ 1; \
						 $ns_ connect $udp_(35) $null_(35); \
						 $cbr_(35) start"
	$ns_ at 82.1969517550513 		"$cbr_(35) stop; "

#creating CBR agent (source) #36 for node 11
	 set udp_(36) [new Agent/UDP]
	 set cbr_(36) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(11) $udp_(36)
	 $cbr_(36) attach-agent $udp_(36)

#creating NULL agent (sink) #36 for node 5
	 set null_(36) [new Agent/Null]
	$ns_ attach-agent $node_(5) $null_(36)

# setting up CBR stream between nodes 11 and 5
	$ns_ at 76.8624001627765 		"$cbr_(36) set packetSize_ 64.0; \
						 $cbr_(36) set interval_ 0.02; \
						 $cbr_(36) set random_ 1; \
						 $ns_ connect $udp_(36) $null_(36); \
						 $cbr_(36) start"
	$ns_ at 86.8624001627765 		"$cbr_(36) stop; "

#creating CBR agent (source) #37 for node 19
	 set udp_(37) [new Agent/UDP]
	 set cbr_(37) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(19) $udp_(37)
	 $cbr_(37) attach-agent $udp_(37)

#creating NULL agent (sink) #37 for node 1
	 set null_(37) [new Agent/Null]
	$ns_ attach-agent $node_(1) $null_(37)

# setting up CBR stream between nodes 19 and 1
	$ns_ at 77.0959489616567 		"$cbr_(37) set packetSize_ 64.0; \
						 $cbr_(37) set interval_ 0.02; \
						 $cbr_(37) set random_ 1; \
						 $ns_ connect $udp_(37) $null_(37); \
						 $cbr_(37) start"
	$ns_ at 87.0959489616567 		"$cbr_(37) stop; "

#creating CBR agent (source) #38 for node 18
	 set udp_(38) [new Agent/UDP]
	 set cbr_(38) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(18) $udp_(38)
	 $cbr_(38) attach-agent $udp_(38)

#creating NULL agent (sink) #38 for node 5
	 set null_(38) [new Agent/Null]
	$ns_ attach-agent $node_(5) $null_(38)

# setting up CBR stream between nodes 18 and 5
	$ns_ at 80.1704065700815 		"$cbr_(38) set packetSize_ 64.0; \
						 $cbr_(38) set interval_ 0.02; \
						 $cbr_(38) set random_ 1; \
						 $ns_ connect $udp_(38) $null_(38); \
						 $cbr_(38) start"
	$ns_ at 90.1704065700815 		"$cbr_(38) stop; "

#creating CBR agent (source) #39 for node 13
	 set udp_(39) [new Agent/UDP]
	 set cbr_(39) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(13) $udp_(39)
	 $cbr_(39) attach-agent $udp_(39)

#creating NULL agent (sink) #39 for node 19
	 set null_(39) [new Agent/Null]
	$ns_ attach-agent $node_(19) $null_(39)

# setting up CBR stream between nodes 13 and 19
	$ns_ at 80.8914389921433 		"$cbr_(39) set packetSize_ 64.0; \
						 $cbr_(39) set interval_ 0.02; \
						 $cbr_(39) set random_ 1; \
						 $ns_ connect $udp_(39) $null_(39); \
						 $cbr_(39) start"
	$ns_ at 90.8914389921433 		"$cbr_(39) stop; "

#creating CBR agent (source) #40 for node 17
	 set udp_(40) [new Agent/UDP]
	 set cbr_(40) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(17) $udp_(40)
	 $cbr_(40) attach-agent $udp_(40)

#creating NULL agent (sink) #40 for node 6
	 set null_(40) [new Agent/Null]
	$ns_ attach-agent $node_(6) $null_(40)

# setting up CBR stream between nodes 17 and 6
	$ns_ at 82.18389982489 		"$cbr_(40) set packetSize_ 64.0; \
						 $cbr_(40) set interval_ 0.02; \
						 $cbr_(40) set random_ 1; \
						 $ns_ connect $udp_(40) $null_(40); \
						 $cbr_(40) start"
	$ns_ at 92.18389982489 		"$cbr_(40) stop; "

#creating CBR agent (source) #41 for node 6
	 set udp_(41) [new Agent/UDP]
	 set cbr_(41) [new Application/Traffic/CBR]
	 $ns_ attach-agent $node_(6) $udp_(41)
	 $cbr_(41) attach-agent $udp_(41)

#creating NULL agent (sink) #41 for node 13
	 set null_(41) [new Agent/Null]
	$ns_ attach-agent $node_(13) $null_(41)

# setting up CBR stream between nodes 6 and 13
	$ns_ at 84.29720515883 		"$cbr_(41) set packetSize_ 64.0; \
						 $cbr_(41) set interval_ 0.02; \
						 $cbr_(41) set random_ 1; \
						 $ns_ connect $udp_(41) $null_(41); \
						 $cbr_(41) start"
	$ns_ at 94.29720515883 		"$cbr_(41) stop; "

puts "Starting Simulation..."
flush stdout
set startTime_ [clock seconds]
puts "\nSimulation time: [time {$ns_ run}]"
