#    http://www.linuxquestions.org/questions/linux-newbie-8/i-am-trying-to-run-crcn-protocol-in-ns2-31-but-every-time-i-am-getting-this-error-4175529206/#9


 set val(chan)      Channel/WirelessChannel             ; #Channel Type
set val(prop)      Propagation/TwoRayGround     ; #Radio propagation model
set val(netif)     Phy/WirelessPhy       ; #Network interface type
set val(ant)       Antenna/OmniAntenna       ; #Antenna model
set val(rp)        AODV     ;#Routing Protocol
set val(ifq)       Queue/DropTail/PriQueue                  ;# interface queue type
set val(ifqlen)    50      ;# max packet in ifq
set val(mac)       Mac/802_11      ;# MAC type
set val(ll)        LL                         ;# link layer type
set val(nn)        20               ;# number of mobilenodes
set val(ni)        5               ;# number of interfaces
set val(cp)        ./random.tcl     ;      # topology traffic file 
set val(stop)      50                ;# simulation time
# ==================================================================
# Main Program
# ======================================================================


# Initialize Global Variables
set ns_		[new Simulator]
set tracefd     [open CRCN-H.tr w]
$ns_ trace-all $tracefd

# set up topography object
set topo       [new Topography]
$topo load_flatgrid 1000 1000

#create nam
set namtrace [open CRCN-H.nam w]
$ns_ namtrace-all-wireless $namtrace 1000 1000

# Create God
set god_ [create-god $val(nn)]
# configure node
$ns_ node-config -adhocRouting $val(rp) -llType $val(ll) -macType $val(mac) -ifqType $val(ifq) -ifqLen $val(ifqlen) -antType $val(ant) -propType $val(prop) -phyType $val(netif) -topoInstance $topo -agentTrace ON -routerTrace ON -macTrace ON -movementTrace ON


 for {set i 0} { $i < $val(ni)} {incr i} {
              set chan_($i) [new $val(chan)]
  }


#configure for interface and channel
$ns_ node-config -ifNum $val(ni) -channel $chan_(0)


for {set i 0} {$i < $val(ni) } {incr i} {
           $ns_ add-channel $i $chan_($i)
}

for {set i 0} {$i < $val(nn) } {incr i} {
		set node_($i) [$ns_ node]
         $node_($i) set recordIfall 1
		$node_($i) random-motion 0		;# disable random motion
}


source $val(cp)      ;    #source topology and traffic file generated by others

# Tell nodes when the simulation ends
for {set i 0} {$i < $val(nn) } {incr i} {
      $ns_ at $val(stop).0 "$node_($i) reset"; 
}
$ns_ at  $val(stop).0002 "puts \"NS EXITING...\" ; $ns_ halt "
proc stop {} {
	 global ns_ tracefd
    $ns_ flush-trace
    close $tracefd
    exec nam CRCN-H.nam &
    exit 0
}
puts "Starting Simulation..." 
$ns_ run
