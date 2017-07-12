set val(chan)      Channel/WirelessChannel             ; #Channel Type
set val(prop)      Propagation/TwoRayGround     ; #Radio propagation model
set val(netif)     Phy/WirelessPhy       ; #Network interface type
set val(ant)       Antenna/OmniAntenna       ; #Antenna model
set val(rp)        AODV     ;#Routing Protocol
set val(ifq)       Queue/DropTail/PriQueue                  ;# interface queue type
set val(ifqlen)    50      ;# max packet in ifq
set val(mac)       Mac/Simple   ;#02.1 MAC type
set val(ll)        LL                         ;# link layer type
set val(nn)        26    ;# number of mobilenodes
set val(channum)        12          ;# number of channels per radio
set val(cp)        ./topo4-2.tcl     ;      # topology traffic file 
set val(stop)     100             ;# simulation time
# ==================================================================
# Main Program
# ======================================================================


# Initialize Global Variables
set ns_		[new Simulator]
set tracefd     [open mytest.tr w]
$ns_ trace-all $tracefd

# set up topography object
set topo       [new Topography]
$topo load_flatgrid 1000 1000

#create nam
set namtrace [open ./test.nam w]
$ns_ namtrace-all-wireless $namtrace 1000 1000

# Create God
set god_ [create-god $val(nn)]
# configure node
$ns_ node-config -adhocRouting $val(rp) -llType $val(ll) -macType $val(mac) -ifqType $val(ifq) -ifqLen $val(ifqlen) -antType $val(ant) -propType $val(prop) -phyType $val(netif) -topoInstance $topo -agentTrace OFF -routerTrace OFF -macTrace ON -movementTrace OFF


 for {set i 0} { $i < $val(channum)} {incr i} {
              set chan_($i) [new $val(chan)]
  }


for {set i 0} {$i < $val(channum) } {incr i} {
$ns_ add-channel $i $chan_($i)

}


#Configure for channels
$ns_ node-config -channel $chan_(0) -ChannelNum $val(channum)

for {set i 0} {$i < $val(nn) } {incr i} {
		set node_($i) [$ns_ node]
         $node_($i) set recordIfall 1
		$node_($i) random-motion 0		;# disable random motion
		$node_($i) set isprimaryuser 1
	#	$node_($i) set numberofchannels $val(channum)
		
}
#sending nodes with channels
#for {set i 0} {$i < $val(nn) /2 } {incr i} {

#	$node_($i) set chanis $i

#}

#$node_(0) set chanis 0
#$node_(1) set chanis 0

#$node_(2) set chanis 1
#$node_(3) set chanis 1

#$node_(4) set chanis 2
#$node_(5) set chanis 2

#$node_(6) set chanis 3
#$node_(7) set chanis 3

#$node_(8) set chanis 4
#$node_(9) set chanis 4

#$node_(10) set chanis 5
#$node_(11) set chanis 5

#$node_(12) set chanis 5
#$node_(13) set chanis 5
#$node_(0) MYCHAN_ 3

#$node_(14) set isprimaryuser 0
#$node_(15) set isprimaryuser 0
#sending nodes with channels
set j 0
for {set i 0} {$i < [expr $val(nn) -2] } {set i [expr $i +2]} {

	$node_($i) set chanis $j
puts $i
        $node_([expr $i+1]) set chanis $j 
#puts $i
incr j
}

$node_([expr $val(nn)-2]) set isprimaryuser 0
$node_([expr $val(nn)-1]) set isprimaryuser 0




source $val(cp)      ;    #source topology and traffic file generated by others
puts "hello"
#puts $node_(1) add-neighbors $node_(2)
#puts $node_(1) neighbors
# Tell nodes when the simulation ends
for {set i 0} {$i < $val(nn) } {incr i} {
      $ns_ at $val(stop).0 "$node_($i) reset"; 
}
$ns_ at  $val(stop).0002 "puts \"NS EXITING...\" ; $ns_ halt "
proc stop {} {
	 global ns_ tracefd
    $ns_ flush-trace
    close $tracefd
    exec nam ./test.nam &
    exit 0
}
puts "Starting Simulation..." 
$ns_ run 
