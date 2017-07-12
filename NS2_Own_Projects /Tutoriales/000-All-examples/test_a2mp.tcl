set val(mac)            Mac/BNEP                 ;# MAC type
set val(nn)             6                        ;# number of mobilenodes
set val(numberOfMACs)   10                        ;# total number of MACs
set val(palType) PAL/802_11
set val(prop)   Propagation/TwoRayGround   ;# radio-propagation model
set val(chan)   Channel/WirelessChannel    ;# channel type


set StartTime [list 0.0 0.0006 0.1031 0.1134 0.3878 0.8531 0.6406 0.0627]

set ns_		[new Simulator]

set chan [new $val(chan)];#Create wireless channel
#Setup topography object
set topo       [new Topography]
$topo load_flatgrid 50 50

create-god $val(numberOfMACs)

set f [open a2mp.tr w]
$ns_ trace-all $f
#set nf [open a2mp.nam w]
#$ns_ namtrace-all $nf
#$ns_ namtrace-all-wireless $nf 7 7
#$ns_ node-config -macType $val(mac) 	;# set node type to BTNode

#Simulator set MacTrace_ ON
#Open file to collect statistics
set stat0 [open ./a2mp0.stat w]
set stat1 [open ./a2mp1.stat w]

$ns_ node-config -macType $val(mac) \
		-agentTrace    ON \
                -routerTrace   ON \
                -macTrace      ON \
                -movementTrace ON
		
for {set i 0} {$i < $val(nn) } {incr i} {
	set node($i) [$ns_ node $i ]
	$node($i) set X_ [expr 10*$i]
	$node($i) set Y 0
	$node($i) set Z 0
	$node($i) rt AODV
	$node($i) on
	[$node($i) set l2cap_] set ifq_limit_ 30 ;#set the size of the queue for the L2CAP layer
	
	if {$i > 0} {
		$node($i) inqscan 4096 2048 ;#are assigned values typical of inquiry
		$node($i) pagescan 4096 2048 ;#are assigned values typical of page
	}
	set bb($i) [$node($i) set bb_]
	#$bb($i) set energyMin_ 0.1
#	$node($i) set-rate 1	;# set 1mb high rate
    	$bb($i) set energy_ 3 ;# 3 watt hour
    	$bb($i) set activeEnrgConRate_ 1.667E-5 ;# 60 mwh
#	$bb($i) set ver_ 12
#	$ns_ at [lindex $StartTime $i] "$node($i) on"

}

	############# Add 802.11 PAL #####################
	$node(0) add-PAL $val(palType) $topo $chan $val(prop)
	$node(1) add-PAL $val(palType) $topo $chan $val(prop)
	$node(4) add-PAL $val(palType) $topo $chan $val(prop)
	$node(5) add-PAL $val(palType) $topo $chan $val(prop)
	##################################################

set ifq [new Queue/DropTail] ;#Declaration of the queue or buffer
$ifq set limit_ 20 ;#Limit the queue (packet)


#=========================================================================
# Configuration # of links, traffic and applications 
#=========================================================================

set tcp0 [new Agent/TCP] ;#Declaration of TCP traffic agent
$ns_ attach-agent $node(0) $tcp0 ;#Union agent with the node for (tx)
set ftp0 [new Application/FTP] ;#Declaration of new FTP application
$ftp0 attach-agent $tcp0 ;# union of the application agent Traffic


set null1 [new Agent/TCPSink] ;#Declaración del repositorio del agente de trafico TCP
$ns_ attach-agent $node(1) $null1 ;#Unión del repositorio con el nodo correspondiente (rx)
$ns_ connect $tcp0 $null1 ;#unión del agente de trafico con el repositorio

set tcp2 [new Agent/TCP] ;#Declaration of TCP traffic agent
$ns_ attach-agent $node(2) $tcp2 ;#Union agent with the node for (tx)
set ftp2 [new Application/FTP] ;#Declaration of new FTP application
$ftp2 attach-agent $tcp2 ;# union of the application agent Traffic
#$tcp2 set packetSize_ 30000

set null3 [new Agent/TCPSink] ;#Declaración del repositorio del agente de trafico TCP
$ns_ attach-agent $node(3) $null3 ;#Unión del repositorio con el nodo correspondiente (rx)
$ns_ connect $tcp2 $null3 ;#unión del agente de trafico con el repositorio


#set tcp3 [new Agent/TCP] ;#Declaration of TCP traffic agent
#$ns_ attach-agent $node(4) $tcp3 ;#Union agent with the node for (tx)
#set ftp3 [new Application/FTP] ;#Declaration of new FTP application
#$ftp3 attach-agent $tcp3 ;# union of the application agent Traffic
##$tcp2 set packetSize_ 30000
#
#set null3 [new Agent/TCPSink] ;#Declaración del repositorio del agente de trafico TCP
#$ns_ attach-agent $node(5) $null3 ;#Unión del repositorio con el nodo correspondiente (rx)
#$ns_ connect $tcp3 $null3 ;#unión del agente de trafico con el repositorio
#set ifq [new Queue/DropTail] ;#Declaration of the queue or buffer
#$ifq set limit_ 20 ;#Limit the queue (packet)


#=========================================================================
# Event Organizer *
#=========================================================================
$ns_ at 0.000001 "$ns_ trace-annotate \" BEGIN SIMULATION \""
$ns_ at 0.1 "$node(0) make-hs-connection $node(1)"
#$ns_ at 0.1 "$node(4) make-hs-connection $node(5)"
#$ns_ at 0.1 "$node(0) make-bnep-connection $node(1) DH5 DH5 noqos $ifq"
$ns_ at 0.1 "$node(2) make-bnep-connection $node(3) DH5 DH5 noqos $ifq"
#$ns_ at 0.1 "$node(0) make-bnep-connection $node(1)"

#$ns_ at 10.0 "$ftp2 send 4000000000"
$ns_ at 1.0 "$ftp0 send 100000000"
#$ns_ at 50.0 "$ftp0 stop"
$ns_ at 1.0 "$ftp2 send 100000000"
#$ns_ at 50.0 "$ftp2 stop"
#$ns_ at 1.0 "$ftp3 start"
#$ns_ at 50.0 "$ftp3 stop"

#=========================================================================
# Procedure to call the function which will record the charge 
# calculation of the power and the signal to noise
#=========================================================================
#For 4.0 seconds the call record function
$ns_ at 0.0 "record"
#=========================================================================
# Procedimiento record *
#=========================================================================
proc record {} {
	global node tcp0 null1 tcp2 null3 stat0 stat1
	set ns [Simulator instance]
	set time 1
	set now [$ns now]

	set bb [$node(0) set bb_]
#	set btdataRecieved 0 
#	set energy [$bb set energy_]
#	set hsdataSent [$tcp0 set bytes_]
	set hsdataRecieved [$null1 set bytes_]
#	set btdataSent [$tcp2 set bytes_]
	set btdataRecieved [$null3 set bytes_]
	if {$btdataRecieved >= 100000000} {	
		finish
	}
	puts $stat0 "$now $hsdataRecieved"
	puts $stat1 "$now $btdataRecieved" 
#	puts $stat0 "$now $hsdataSent $hsdataRecieved $btdataSent $btdataRecieved"
	#puts $pot1 "$now " ;# data in MB
	$ns at [expr $now+$time] "record"
}
#===================================
#        Termination        
#===================================
#Define a 'finish' procedure
proc finish {} {
	global ns_ node f ;#nf
	$ns_ flush-trace
	close $f
#	close $nf
	$node(0) print-all-stat
	$node(1) print-all-stat
	$node(2) print-all-stat
	$node(3) print-all-stat
	$node(4) print-all-stat
	$node(5) print-all-stat
	exec xgraph a2mp0.stat -t "Data Flow HS" -x "Time (sec)" -y "Data (bytes)" & 
	exec xgraph a2mp1.stat -t "Data Flow BT" -x "Time (sec)" -y "Data (bytes)" &
#	exec nam a2mp.nam &
	exit 0
}

#$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
#$ns at $val(stop) "finish"
#$ns at $val(stop) "puts \"done\" ; $ns halt"
#$ns run

#$ns_ at 1 "$node(0) make-hs-connection $node(1)"
#$ns_ at 1 "$a2mp0 discover $node(6)"
#$ns_ at 5 "$a2mp0 discover $node(1)"
#$ns_ at 10 "$a2mp0 discover $node(5)"
#$ns_ at 200 "finish"

$ns_ run

