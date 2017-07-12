global opt
set opt(opt_conv) {
    { rs rand_seed }
    { phl ph_max_level }
    { phv ph_valid }
    { rd route_disc }
    { rr route_repair }
    { sd send_fant }
    { f F }
    { st sim_time }
    { nn number_nodes }
    { rate Rate }
    { pkt p_size }
    { X dimX }
    { Y dimY }
    { cen scenario }
    { ses sessions }
    { dlt delta }
    { el erro_ligacao }
    { phm ph_mod }
    { h do_help }
}

set opt(ph_mod) 3
set opt(route_disc) 0.5
set opt(route_repair) 0.2
set opt(send_fant) 1.0
set opt(do_help) 0
set opt(rand_seed) 0
set opt(F) 1
set opt(ph_max_level) 35
set opt(ph_valid) 1.0
set opt(sim_time) 100.0
set opt(number_nodes) 104
set opt(dimX) 1000.0
set opt(dimY) 1000.0
set opt(scenario) mesh-100N.V5.cen
# this simulation can hold only four simultaneous data transfer session maximum
set opt(sessions) 4
set opt(delta) 0.2
set opt(erro_ligacao) 3
set opt(Rate) 16384
set opt(p_size) 512

source getopt.tcl	
# read the argments passed by the command line
# to see which are the arguments do:
#    ns <tcl_file> -h 2
# the getopt.tcl file was written by Pedro Estrela
my_getopt $argv   	

if { $opt(do_help) } {
    do_help
    exit 
}


#Mac/802_11 set RTSThreshold_ 3000
set val(chan)       Channel/WirelessChannel    ;#tipo de canal
set val(prop)       Propagation/TwoRayGround   ;#radio-propagation model
set val(netif)      Phy/WirelessPhy            ;#tipo de interface de rede
set val(mac)        Mac/802_11                 ;#tipo MAC
set val(ifq)        Queue/DropTail/PriQueue    ;#tipo de fila de espera
set val(ll)         LL                         ;#tipo de link layer
set val(ant)        Antenna/OmniAntenna        ;#modelo da antena 
set val(ifqlen)     500                         ;#numero de pacotes na fila
set val(nn)         $opt(number_nodes)         ;#numero de nos moveis
set val(rp)         SARA                        ;#protocolo de encaminhamento
set val(x)          $opt(dimX)                 ;#dimensao X da topografia
set val(y)          $opt(dimY)                 ;#dimensao Y da topografia
set val(stop)       $opt(sim_time)              ;#tempo de fim de simulacao

set ns_ [new Simulator]
set tf [open cbr.tr w]
set nf [open cbr.nam w]
$ns_ trace-all $tf
$ns_ namtrace-all-wireless $nf $val(x) $val(y)

set color_ctl blue
set color_data red

$ns_ color fid_ctl Blue
$ns_ color fid_data Red

set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

set god_ [create-god $val(nn)]
Agent/SARA set F_ $opt(F)
Agent/SARA set ph_valid_ $opt(ph_valid)
Agent/SARA set ph_max_level_ $opt(ph_max_level)
Agent/SARA set rand_seed_ $opt(rand_seed)
Agent/SARA set rd_int_ $opt(route_disc)
Agent/SARA set rr_int_ $opt(route_repair)
Agent/SARA set sd_int_ $opt(send_fant)
Agent/SARA set delta_ $opt(delta)
Agent/SARA set retry_ $opt(erro_ligacao)
Agent/SARA set ph_mod_ $opt(ph_mod)

set tx_rate [expr 8.0*$opt(p_size)/$opt(Rate)]
Agent/TxCBR set packetSize_ $opt(p_size)
Agent/TxCBR set txInt_ $tx_rate

set chan_ [new $val(chan)]
$ns_ node-config -adhocRouting $val(rp) \
                -llType $val(ll) \
                -macType $val(mac) \
                -ifqType $val(ifq) \
                -ifqLen $val(ifqlen) \
                -antType $val(ant) \
                -propType $val(prop) \
                -phyType $val(netif) \
                -channel $chan_ \
                -topoInstance $topo \
                -agentTrace ON \
                -routerTrace OFF \
                -macTrace ON \
                -movementTrace OFF

for {set i 0} {$i < $val(nn)} {incr i} {
    set node_($i) [$ns_ node]
    $node_($i) random-motion 0
    $god_ new_node $node_($i)
}

$node_(100) set X_ 200.0
$node_(100) set Y_ 800.0
$node_(100) set Z_ 0.0
$node_(100) color red
$node_(100) shape box
[$node_(100) agent 255] if-queue [$node_(100) set ifq_(0)]
$ns_ initial_node_pos $node_(100) 40
$ns_ at $val(stop) "$node_(100) reset"

$node_(101) set X_ 800.0
$node_(101) set Y_ 800.0
$node_(101) set Z_ 0.0
$node_(101) color red
$node_(101) shape box
[$node_(101) agent 255] if-queue [$node_(101) set ifq_(0)]
$ns_ initial_node_pos $node_(101) 40
$ns_ at $val(stop) "$node_(101) reset"

$node_(102) set X_ 200.0
$node_(102) set Y_ 200.0
$node_(102) set Z_ 0.0
$node_(102) color green
$node_(102) shape box
[$node_(102) agent 255] if-queue [$node_(102) set ifq_(0)]
$ns_ initial_node_pos $node_(102) 40
$ns_ at $val(stop) "$node_(102) reset"

$node_(103) set X_ 800.0
$node_(103) set Y_ 200.0
$node_(103) set Z_ 0.0
$node_(103) color green
$node_(103) shape box
[$node_(103) agent 255] if-queue [$node_(103) set ifq_(0)]
$ns_ initial_node_pos $node_(103) 40
$ns_ at $val(stop) "$node_(103) reset"


source $opt(scenario)
for {set i 0} {$i < [expr $val(nn) - 4]} {incr i} {
    $ns_ initial_node_pos $node_($i) 40
    $ns_ at $val(stop) "$node_($i) reset"
    [$node_($i) agent 255] if-queue [$node_($i) set ifq_(0)]
}

set sim_st 1
for {set i 0} {$i < $opt(sessions)} {incr i} {
    set source [expr $opt(rand_seed) + $i]
    set ps($i) [new Agent/TxCBR]
    set pd($i) [new Agent/TxCBR]
    $ns_ attach-agent $node_($source) $ps($i)
    $ns_ attach-agent $node_([expr 100 + $i]) $pd($i)
    $ns_ connect $ps($i) $pd($i)
    $ns_ at 0.1 "$ps($i) destAddr [expr 100 + $i]"
    $ns_ at 0.1 "$pd($i) destAddr $source"
    $ns_ at $sim_st "$ps($i) start"
    $ns_ at [expr $val(stop)-5.0] "$ps($i) stop"
    $ns_ at $sim_st "$node_($source) label \"SRC\""
    $ns_ at $sim_st "$node_([expr 100 + $i]) label \"DST\""
    set sim_st [expr $sim_st + 5]
}


for {set i 0} {$i < $val(nn)} {incr i} {
	$ns_ at $val(stop) "[$node_($i) agent 255] stop"
	}
$ns_ at $val(stop) "stop"
$ns_ at $val(stop) "puts \"End of Simulation.\"; $ns_ halt"

proc stop {} {
    global ns_ tf nf
    $ns_ flush-trace
    close $tf
    close $nf
}

$ns_ run
