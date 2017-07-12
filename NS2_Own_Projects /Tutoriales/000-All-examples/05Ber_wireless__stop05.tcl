# ======================================================================
# Define options
# ======================================================================

set t0 [clock clicks -millisec]


set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             50                         ;# number of mobilenodes
set val(rp)             OLSR                       ;# routing protocol
set val(cp)		"cbr-50-test" 		;#movement pattern
set val(sc)		"./scen-670x670-50-600-20-0"     ;# scenario file
set val(seed)           1.0                      ;# seed for random number gen.
set val(x)		1000.0			   ;
set val(y)		1000.0			   ;
set val(simtime)	300.0			   ; #sim time
#set val(drate)		1.0e6			   ; #default datarate
set val(stop)           5.0                      ;# time to stop simulation

set opt(cbr-start)      1.0
#Mac set bandwidth_ 2Mb
# ======================================================================
# Main Program
# ======================================================================
#ErrorModel80211 noise1 -94
#ErrorModel80211 noise2 -91
#ErrorModel80211 noise55 -87
#ErrorModel80211 noise11 -82
#ErrorModel80211 shortpreamble	1
#ErrorModel80211 LoadBerSnrFile ber_snr.txt

Mac/802_11 set dataRate_ 2Mb
Mac/802_11 set basicRate_ 1Mb

if {$val(seed) > 0} {
    puts "Seeding Random number generator with $val(seed)\n"
    ns-random $val(seed)
}


set ns_		[new Simulator]

set tracefd     [open working_50_10connec.tr w]
$ns_ trace-all $tracefd

set namtrace [open working_50_10connec.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)
$ns_ use-newtrace


#proc finish {} {
	#global ns_ namtrace
	#$ns_ flush-trace 

	#close $namtrace

	#exec nam working_10.nam & 

	#exit 0

#}
 
 

set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)


# Create God
create-god $val(nn)

set god_ [ create-god $val(nn) ]


# Create channel
set chan_ [new $val(chan)]

# Create node(0) and node(1)

# configure node, please note the change below.
$ns_ node-config -adhocRouting $val(rp) \
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
		-macTrace OFF \
		-movementTrace OFF \
		-channel $chan_


#create   nodes
for {set i 0} {$i < 50 } {incr i} {
	set node_($i) [$ns_ node]
	
	$node_($i) random-motion 0
}

#added by Liu Jian for cross-layer
 # for {set i 0} {$i < 50} {incr i} {
 #  set rt($i) [$node_($i) agent 255] 
 # $rt($i) set-mac [$node_($i) set mac_(0)]
 # }

# 
# Define node movement model
#
puts "Loading connection pattern..."
source $val(cp)

# 
# Define traffic model
#
puts "Loading scenario file..."
source $val(sc)
 

for {set i 0} {$i < $val(nn)} {incr i} {

#$ns_ at 5.0 "[$node_($i) agent 255] print_rtable"
#$ns_ at 8.0 "[$node_($i) agent 255] print_rtable"
#$ns_ at 10.0 "[$node_($i) agent 255] print_rtable"
#$ns_ at 13.0 "[$node_($i) agent 255] print_rtable"
#$ns_ at 17.0 "[$node_($i) agent 255] print_rtable"
#$ns_ at 20.0 "[$node_($i) agent 255] print_rtable"
#$ns_ at 25.0 "[$node_($i) agent 255] print_rtable"
#$ns_ at 30.0 "[$node_($i) agent 255] print_rtable"
$ns_ at 35.0 "[$node_($i) agent 255] print_rtable"
$ns_ at 40.0 "[$node_($i) agent 255] print_rtable"
$ns_ at 41.0 "[$node_($i) agent 255] print_rtable"
$ns_ at 42.0 "[$node_($i) agent 255] print_rtable"
$ns_ at 43.0 "[$node_($i) agent 255] print_rtable"
$ns_ at 44.0 "[$node_($i) agent 255] print_rtable"
$ns_ at 45.0 "[$node_($i) agent 255] print_rtable"
#$ns_ at 15.0 "[$node_($i) agent 255] print_linkset"
#$ns_ at 20.0 "[$node_($i) agent 255] print_nbset"
#$ns_ at 5.0 "[$node_($i) agent 255] print_mprset"
#$ns_ at 10.0 "[$node_($i) agent 255] print_mprset"
#$ns_ at 15.0 "[$node_($i) agent 255] print_mprset"
#$ns_ at 25.0 "[$node_($i) agent 255] print_mprset"
$ns_ at 35.0 "[$node_($i) agent 255] print_mprset"
$ns_ at 40.0 "[$node_($i) agent 255] print_mprset"
$ns_ at 41.0 "[$node_($i) agent 255] print_mprset"
$ns_ at 42.0 "[$node_($i) agent 255] print_mprset"
$ns_ at 43.0 "[$node_($i) agent 255] print_mprset"
$ns_ at 44.0 "[$node_($i) agent 255] print_mprset"
$ns_ at 45.0 "[$node_($i) agent 255] print_mprset"
#$ns_ at 30.0 "[$node_($i) agent 255] print_nb2hopset"
#$ns_ at 40.0 "[$node_($i) agent 255] print_mprset"
#$ns_ at 35.0 "[$node_($i) agent 255] print_mprselset"
#$ns_ at 40.0 "[$node_($i) agent 255] print_topologyset"
#$ns_ at 50.0 "[$node_($i) agent 255] print_nbset"
#$ns_ at 80.0 "[$node_($i) agent 255] print_nbset"

}





#for {set i 0} {$i < 100 } {incr i} {
	 #set tr [open "| gawk -f genthroughput.awk working_currently_10.tr > my.txt" w]
	 #$ns_ trace-all $tr
	#}

# Tell nodes when the simulation ends
#
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $val(stop).0 "$node_($i) reset";
}

$ns_ at  $val(stop).0002 "puts \"NS EXITING...\" ; $ns_ halt"

puts $tracefd "M 0.0 nn $val(nn) x $val(x) y $val(y) rp $val(rp)"
puts $tracefd "M 0.0 sc $val(sc) cp $val(cp) seed $val(seed)"
puts $tracefd "M 0.0 prop $val(prop) ant $val(ant)"

puts "Starting Simulation..."
 #exec nam wireless1-out.nam &
$ns_ run


set tr [open "| awk -f delayanalysis.awk  working_50_10connec.tr > mythrough_1.txt" w]
#set tr [open "| awk -f genPDR.awk  working_20_4connec.tr > myPDR.txt" w]
$ns_ trace-all $tr

puts stderr "[expr ([clock clicks -millisec]-$t0)/1000.] sec" ;# RS
