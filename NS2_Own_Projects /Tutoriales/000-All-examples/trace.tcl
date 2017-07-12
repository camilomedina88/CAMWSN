set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagationmodel
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
#set val(ifq)        	CMUPriQueue 
set val(ifq)           Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             30                          ;# number of mobilenodes
set val(seed)           1.0
set val(rp)             DSDV                      ;# routing protocol
set val(x)              500    ;# X dimension of the topography
set val(y)              300     ;# Y dimension of the topography 
set val(nn)		30
set val(stop)           800.0           ;# simulation time
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(sc)             "./scenweiliang" 
set val(cp)		"./movementweiliang"

set ns_  [new Simulator] 		;# create a ns simulator instance

set topo [new Topography] 		; #create a topology and
$topo load_flatgrid $val(x) $val(y)	; #define it in 670x670 area 

#Define standard ns/nam trace
set tracefd  [open 694demo.tr w] 
$ns_ use-newtrace
$ns_ trace-all $tracefd	

set namtrace [open 694demo.nam w] 
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)   	

create-god $val(nn)
set god_ [God instance]
set chan_1_ [new $val(chan)]

#Define how a mobile node should be created 

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
                         -agentTrace ON \
                         -routerTrace ON \
                         -macTrace ON \
                         -movementTrace ON 

#Define how a mobile node should be created 


#Create a mobile node and attach it to the channel 
for {set i  0} {$i< $val(nn)} {incr i} {
    set node_($i) [$ns_ node]
    $node_($i) random-motion 0 	;# disable random motion
}

puts "Loading scenario file..."
source $val(sc) 

puts "Loading connection pattern..."
source $val(cp)


for {set i 0} {$i < $val(nn)} {incr i} {

    # 20 defines the node size in nam, must adjust it according to your scenario
    # The function must be called after mobility model is defined
    $ns_ initial_node_pos $node_($i) 30
}



#Tell ns/nam the simulation stop time 

$ns_  at 800.0 "$ns_ nam-end-wireless $val(stop)"
$ns_ at  800.0 "$ns_ halt"

#Start your simulation 
$ns_  run

