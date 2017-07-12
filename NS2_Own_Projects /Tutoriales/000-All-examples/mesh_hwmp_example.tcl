set MeshEdge 175.0
set MeshNumberOfEdge 5

# ======================================================================
# Define options
# ======================================================================
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)		Mac/802_11		;# MAC type
set val(ifq)		Queue/DropTail/PriQueue	;# interface queue type
set val(ll)		LL			;# link layer type
set val(an)		Antenna/OmniAntenna	;# antenna model
set val(ifqlen)		5000			;# max packet in ifq
set val(nn)		[expr ($MeshNumberOfEdge*$MeshNumberOfEdge)]
# number of mobilenodes
set val(rp)		HWMP			;# routing protocol

# ======================================================================
# Main Program
# ======================================================================


#
# Initialize Global Variables
#
#Propogation/Shadowing set pathlossExp_ 2.0

set ns_		[new Simulator]
set tracefd     [open tracefile.tr w]
set fout	[open speed.tr w]
$ns_ trace-all $tracefd

# set up topography object
set topo       [new Topography]

$topo load_flatgrid [expr ($MeshEdge*($MeshNumberOfEdge+2))] [expr ($MeshEdge*($MeshNumberOfEdge+2))]

set namtrace [open namout.nam w]           ;# for nam tracing
$ns_ namtrace-all-wireless $namtrace [expr ($MeshEdge*($MeshNumberOfEdge+2))] [expr ($MeshEdge*($MeshNumberOfEdge+2))]

#
# Create God
#
create-god $val(nn)

        $ns_ node-config -adhocRouting $val(rp) \
			 -llType $val(ll) \
			 -macType $val(mac) \
			 -ifqType $val(ifq) \
			 -ifqLen $val(ifqlen) \
			 -antType $val(an) \
			 -propType $val(prop) \
			 -phyType $val(netif) \
			 -channelType $val(chan) \
			 -topoInstance $topo \
			 -agentTrace ON \
			 -routerTrace ON \
			 -macTrace OFF \
			 -movementTrace ON			
			 
# The following strings organize a square mesh network:
for {set i 0} {$i < $MeshNumberOfEdge } {incr i} {
	for {set j 0} {$j < $MeshNumberOfEdge } {incr j} {
		set NodeCounter [expr ($i*$MeshNumberOfEdge+$j)]
		set node_($NodeCounter) [$ns_ node]
#		puts "i = $i; j = $j; NodeCounter = $NodeCounter"
		$node_($NodeCounter) set X_ [expr ($MeshEdge*($i+1))]
		$node_($NodeCounter) set Y_ [expr ($MeshEdge*($j+1))]
		$node_($NodeCounter) set Z_ 0.0
		$node_($NodeCounter) random-motion 0
		$ns_ at 0.0001 "$node_($NodeCounter) setdest 10.0 10.0 0.0"
	}
}

proc record {} { 
        global sink fout
        #Get an instance of the simulator
        set ns [Simulator instance]
        #Set the time after which the procedure should be called again
        set time 10.0
        #How many bytes have been received by the traffic sinks?
        set speed [$sink set bytes_]
        #Get the current time
        set now [$ns now]
        #Calculate the bandwidth (in MBit/s) and write it to the files
        puts $fout "$now [expr $speed/$time*8/(1024*1024)]"
        #Reset the bytes_ values on the traffic sinks
        $sink set bytes_ 0
        #Re-schedule the procedure
        $ns at [expr $now+$time] "record"
}
# The following strings organize a traffic from opposite cornes of
# left side to opposite cornes of roght side going through the center
# of mesh:
set tcp [new Agent/TCP]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns_ attach-agent $node_([expr $MeshNumberOfEdge*$MeshNumberOfEdge-1]) $tcp
$ns_ attach-agent $node_(0) $sink
$ns_ connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns_ at 0.0 "record"
$ns_ at 0.001 "$ftp start" 

#set tcp1 [new Agent/TCP]
#$tcp1 set class_ 1
#set sink1 [new Agent/TCPSink]
#$ns_ attach-agent $node_([expr ($MeshNumberOfEdge-1)]) $tcp1
##$ns_ attach-agent $node_([expr ($MeshNumberOfEdge-1)*$MeshNumberOfEdge]) $sink1
#$ns_ connect $tcp1 $sink1
#set ftp1 [new Application/FTP]
#$ftp1 attach-agent $tcp1
#$ns_ at 10.0 "$ftp1 start"

# Tell nodes when the simulation ends
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at 20.0 "$node_($i) reset";
}
$ns_ at 20.0 "stop"
$ns_ at 20.01 "puts \"Finishing Simulation...\" ; $ns_ halt"
proc stop {} {
	global ns_ tracefd namtrace fout
    $ns_ flush-trace
    close $tracefd
    close $fout
    close $namtrace
#    exec xgraph speed.tr -geometry 800x400 &
    exit 0
}

puts "Starting Simulation..."
$ns_ run

