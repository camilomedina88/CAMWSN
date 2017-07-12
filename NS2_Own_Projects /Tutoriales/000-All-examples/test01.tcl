#Test network case
#7 CNs in ring; 7 attached ENs
#10 Gbit/s channels
#8 DCs; 2 CCs
#Other parameters initially taken from ranges used in version 0.6 test cases

StatCollector set debug_ 0
Classifier/BaseClassifier/EdgeClassifier set type_ 0
Classifier/BaseClassifier/CoreClassifier set type_ 1
# Per node bhp processing time is 1 micro-second
source ../lib/ns-obs-lib.tcl
source ../lib/ns-obs-defaults.tcl
source ../lib/ns-optic-link.tcl 

set ns [new Simulator]
set nf [open basic01.nam w]
set sc [new StatCollector]
set tf [open trace01.tr w]
set ndf [open ndtrace01.tr w]

# dump all the traces out to the nam file
$ns namtrace-all $nf

$ns trace-all $tf
$ns nodetrace-all $ndf


#====================================================================#
# constant definitions
#v6 uses 1 - 70 mu s for offset time
BurstManager offsettime 0.00004

#v6 uses 10000 - 70000 bytes
BurstManager maxburstsize 40000

#v6 uses 0.1 s to 1 s
BurstManager bursttimeout 0.5

# set the bhp processing time 1 microsecond (v6 test case not known)
# 1 mu s was in initial example file
Classifier/BaseClassifier/CoreClassifier set bhpProcTime 0.000001
Classifier/BaseClassifier/EdgeClassifier set bhpProcTime 0.000001

#assume 1 FDL per outgoing channel (on all links per node)
Classifier/BaseClassifier set nfdl 16
#v6 fdl prop delay not known; 100 mu s is of order of trans delay
Classifier/BaseClassifier set fdldelay 0.0001
Classifier/BaseClassifier set option 0
#v6 uses up to 10 FDL delays per node
Classifier/BaseClassifier set maxfdls 5
Classifier/BaseClassifier set ebufoption 0

#this is a fixed delay line present at the ingress of every node
OBSFiberDelayLink set FDLdelay 0.0

# total number of edge nodes
set edge_count 7
# total number of core routers
set core_count 7

# total bandwidth/channel (1mb = 1000000)
set bwpc 10000000000
#set bwpc 
# delay in milliseconds
set delay 1ms

# total number of channels per link
set maxch 10
# number of control channels per link
set ncc 2
# number of data-channels
set ndc 8

#====================================================================#
# support procedures

# finish procedure
proc finish {} {
    global ns nf sc tf ndf
    $ns flush-trace
    $ns flush-nodetrace
    close $nf
    close $tf
    close $ndf
    
    $sc display-sim-list

    #Execute NAM on the trace file
    #exec nam p2p.nam &

    puts "Simulation complete";
    exit 0
}




#create a edge-core-edge topology
Simulator instproc  create_topology { } {
    $self instvar Node_
    global E C 
    global edge_count core_count
    global bwpc maxch ncc ndc delay

    set i 0
    # set up the edge nodes
    while { $i < $edge_count } {
	set E($i) [$self create-edge-node $edge_count]
        set nid [$E($i) id]
        set string1 "E($i) node id:     $nid"
        puts $string1
	incr i
    }
    
    set i 0
    # set up the core nodes
    while { $i < $core_count } {
	set C($i) [$self create-core-node $core_count]
        set nid [$C($i) id]
        set string1 "C($i) node id:     $nid"
        puts $string1
	incr i
    }
    
    $self createDuplexFiberLink $E(0) $C(0) $bwpc $delay $ncc $ndc $maxch
    $self createDuplexFiberLink $E(1) $C(1) $bwpc $delay $ncc $ndc $maxch
    $self createDuplexFiberLink $E(2) $C(2) $bwpc $delay $ncc $ndc $maxch
    $self createDuplexFiberLink $E(3) $C(3) $bwpc $delay $ncc $ndc $maxch
    $self createDuplexFiberLink $E(4) $C(4) $bwpc $delay $ncc $ndc $maxch
    $self createDuplexFiberLink $E(5) $C(5) $bwpc $delay $ncc $ndc $maxch
    $self createDuplexFiberLink $E(6) $C(6) $bwpc $delay $ncc $ndc $maxch

    $self createDuplexFiberLink $C(0) $C(1) $bwpc $delay $ncc $ndc $maxch
    $self createDuplexFiberLink $C(1) $C(2) $bwpc $delay $ncc $ndc $maxch
    $self createDuplexFiberLink $C(2) $C(3) $bwpc $delay $ncc $ndc $maxch
    $self createDuplexFiberLink $C(3) $C(4) $bwpc $delay $ncc $ndc $maxch
    $self createDuplexFiberLink $C(4) $C(5) $bwpc $delay $ncc $ndc $maxch
    $self createDuplexFiberLink $C(5) $C(6) $bwpc $delay $ncc $ndc $maxch
    $self createDuplexFiberLink $C(6) $C(0) $bwpc $delay $ncc $ndc $maxch

    $self build-routing-table
   
}


#create a self-similar traffic-stream over a UDP agent
Simulator instproc  create_selfsim_connection { selfsim udp null src dest start0 stop0 } {
     upvar 1 $udp udpr
     upvar 1 $selfsim selfsimr
     upvar 1 $null nullr
     upvar 1 $src srcr
     upvar 1 $dest destr


     set udpr [ new Agent/UDP]
     $self attach-agent $srcr $udpr
     set selfsimr [ new Application/Traffic/SelfSimilar ]
     $selfsimr set starttime $start0
     $selfsimr set stoptime $stop0
     $selfsimr attach-agent $udpr
     set nullr [ new Agent/Null ]
     $self attach-agent $destr $nullr
     $self connect $udpr $nullr

     $self at $start0 "$selfsimr start"
     $self at $stop0 "$selfsimr stop"

     puts "traffic stream between $src = $srcr and $dest = $destr created"
     set psrcid [$udpr port]
     set psnkid [$nullr port]
     set string1 "$udp agent port id:  $psrcid"
     set string2 "$null agent port id:  $psrcid"
     puts $string1
     puts $string2
}

$ns create_topology

Agent/UDP set packetSize_ 2000
Application/Traffic/SelfSimilar set batchsize 2000
Application/Traffic/SelfSimilar set sb 0
Application/Traffic/SelfSimilar set Hb -0.5
Application/Traffic/SelfSimilar set rate 100000.0
Application/Traffic/SelfSimilar set std_dev_inter_batch_time 1.0e-5
Application/Traffic/SelfSimilar set Ht 0.5


#add traffic stream between every pair of edge nodes in both directions
set i 0
 while {$i < $edge_count} {
   set j 0
   while {$j < $edge_count} {
      if {$i != $j} {
         $ns  create_selfsim_connection  selfsim0($i:$j) udp0($i:$j) null($i:$j) E($i) E($j) 1.0 2.0
     }
     incr j
  }
    incr i
}

$ns at 2.1 "finish"
$ns run
