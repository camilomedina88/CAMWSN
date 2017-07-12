#
# A sample script implementing a 10-hop chain 
# scenario with a single TCP-AP flow.
# The simulation comprises of 2 batches, where
# the first batch is discarded as initial
# transient.
#

set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
#set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
#set val(ifq)            CMUPriQueue
set val(ifq)            COPE
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             11			   ;# number of mobilenodes
set val(rp)             DSR                        ;# routing protocol
set val(x)              2500
set val(y)              2500
# ======================================================================
# Main Program
# ======================================================================

# =====================
# Global Variables
# =====================

set ns_		[new Simulator -broadcast on]
$ns_ use-newtrace
set tracefd     [open tcp-ap_10hop_chain.tr w]
set namtrace    [open tcp-ap_10hop_chain.nam w]
set gptrace     [open tcp-ap_10hop_chain.gp w]

set j 50
set databytes 0
set rexbytes 0
set prevrex 0
set prevseq 0
set prevdatapacks 0
set prevseqR 0
set totcount 0
set gptime 0

$ns_ trace-all $tracefd
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y) 


Simulator set COPE          ON
COPE set txtime_factor_     32
COPE set gc_interval_       1.0

# set up topography object
set topo       [new Topography]

$topo load_flatgrid 2500 2500

#
# Create God
#
set god_ [create-god $val(nn)]

set chan_1_ [new $val(chan)]

# configure node

        $ns_ node-config -adhocRouting $val(rp) \
			 -llType $val(ll) \
			 -macType $val(mac) \
			 -ifqType $val(ifq) \
			 -ifqLen $val(ifqlen) \
			 -antType $val(ant) \
			 -propType $val(prop) \
			 -phyType $val(netif) \
			 -channel $chan_1_ \
			 -topoInstance $topo \
			 -agentTrace OFF \
			 -routerTrace OFF \
			 -macTrace ON \
			 -movementTrace OFF			
			 
	for {set i 0} {$i < $val(nn) } {incr i} {
		set node_($i) [$ns_ node]	
		$node_($i) random-motion 0
	#	$node_($i) start ;		
	}
for {set i 0} {$i < $val(nn) } {incr i} {
        $node_($i) radius 275

        $node_($i) set X_ $j
        $node_($i) set Y_ 250.0
        $node_($i) set Z_ 0.0

        set j [expr ($j+200)]
}

###################################################
# Set God for COPE----thie is necessary

for {set i 0} {$i < $val(nn) } {incr i} {
    #set node_($i) [$ns_ node]
    #$node_($i) random-motion 0 ;# disable random motion
    $god_ new_node $node_($i)
} 
###################################################
	
set tcp_(0) [new Agent/TCP/Newreno/AP]
set tcp_(2) [new Agent/TCPSink]

$tcp_(0) set window_ 64
$tcp_(0) set packetSize_ 1460

$ns_ attach-agent $node_(0) $tcp_(0)
$ns_ attach-agent $node_([expr ($val(nn) - 1)]) $tcp_(2)

$ns_ connect $tcp_(0) $tcp_(2)

set ftp [new Application/FTP]

$ftp attach-agent $tcp_(0)

for {set i 0} {$i < $val(nn)} {incr i} {

    # 20 defines the node size in nam, must adjust it according to your scenario
    # The function must be called after mobility model is defined
    
    $ns_ initial_node_pos $node_($i) 20
}

$ns_ at 0.0 "$ftp start"

$ns_ at 0.0 record

proc record {} {
        global tcp_ prevseqR totcount conftime \

        #Get an instance of the simulator
        set ns [Simulator instance]
        set time 0.1
	set now [$ns now]
    set seq [expr ([$tcp_(0) set t_seqno_] - $prevseqR)]
    if {$seq >= 300} {
		set prevseqR [$tcp_(0) set t_seqno_]
		incr totcount
		set now [$ns now]
		$ns at $now "succ"
	}
        $ns at [expr $now + $time] "record"
}

proc succ {} {
        global tcp_ databytes gptrace prevseq prevdatapacks totcount \
        prevseq prevdatapacks totcount gptime prevrex rexbytes \
     
     	set ns [Simulator instance]
	
	if {$totcount == 1} {
		puts "batch no $totcount (initial transient)"
	} else {
		puts "batch no $totcount"
	}
	
	set gp 0

	set datapacks 0

        set tp [expr ([$tcp_(0) set ndatabytes_] - $databytes)]
        set rx [expr ([$tcp_(0) set nrexmitbytes_] - $rexbytes)]
        set diff [expr ($tp - $rx)]
	set gptimenow [expr ([$ns now] - $gptime)]
	set gp [expr ((($diff/$gptimenow)*8)/1000)]
        set databytes [$tcp_(0) set ndatabytes_]
	set rexbytes [$tcp_(0) set nrexmitbytes_]
	set gptime [$ns now]

	set datapacks [expr ([$tcp_(0) set ndatapack_] - $prevdatapacks)]
	set nrx [expr ([$tcp_(0) set nrexmitpack_] - $prevrex)]
	set nrxp [expr (double(double($nrx)/double([expr ($datapacks - $nrx)])))]
	set prevrex [$tcp_(0) set nrexmitpack_]
	set prevdatapacks [$tcp_(0) set ndatapack_]


	if {$totcount > 1} {
		puts $gptrace "$gp"
		puts "goodput of batch $totcount: $gp Kbit/s"
	}
        set now [$ns now]
	if {$totcount == 8} {

		set tp [$tcp_(0) set ndatabytes_]
                set rx [$tcp_(0) set nrexmitbytes_]
                set diff [expr ($tp - $rx)]
                set now [$ns now]
                set gp [expr ((($diff/$now)*8)/1000)]

                $ns halt
       }

}
puts "Starting Simulation..."
$ns_ run
