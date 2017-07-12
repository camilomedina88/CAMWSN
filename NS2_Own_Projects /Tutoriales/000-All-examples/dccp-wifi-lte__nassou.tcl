#     http://www.linuxquestions.org/questions/linux-newbie-8/problem-when-execute-file-tcl-4175523886/#3

# Define object Simulator
set ns [new Simulator ]

# Predefine tracing
set f [open dccp1.tr w]
$ns trace-all $f
set nf [open dccp1.nam w]
$ns namtrace-all $nf
#nbre des flux etablis entre les noeuds sans-fil
set nbr_f 20


#adressage heirarchique 
$ns node-config -addressType hierarchical
AddrParams set domain_num_  4                      ;# domain number
AddrParams set cluster_num_ {1 1 1 1}          ;# cluster number for each domain 
AddrParams set nodes_num_   {1 1 40 40}          ;# number of nodes for each cluster     
# dans ce cas j'ai besion d'utiliser 4 domaines , chaque demaine contient un seul cluster c'est pour ça cluster_num  prend ces valeurs {1 1 1 1} , les clusters du domaine 1 et 2  contient chacun un seul noeuds c'est pour ça que nodes_num {1 1 ...} pour les clusters du dommaine 3 et 4 j'ai besioon de 40 noeuds pour chacun d'eux {.. 40 40}  ==> nodes num  {1 1 40 40}

# bon courage et j'espere que j'ai pu te faire passer l'information 
#declaration des routeurs intermediaires
#declaration des routeurs intermediaires
set R1 [$ns node 0.0.0]
set R2 [$ns node 1.0.0]
$ns duplex-link $R1 $R2 5Mb 100ms DropTail 1000 
#$ns queue-limit $R1 $R2 25
#$ns queue-limit $R2 $R1 25
$ns duplex-link-op $R1 $R2 orient right
$ns duplex-link-op $R1 $R2 queuePos 0
$ns duplex-link-op $R2 $R1 queuePos 0


#créations des stations de bases 
# parametres des noeuds sans-fil
set opt(chan)           Channel/WirelessChannel    ;# channel type
set opt(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set opt(netif)          Phy/WirelessPhy            ;# network interface type
set opt(mac)            Mac/802_11                 ;# MAC type
set opt(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set opt(ll)             LL                         ;# link layer type
set opt(ant)            Antenna/OmniAntenna        ;# antenna model
set opt(ifqlen)         50              	   ;# max packet in ifq
set opt(adhocRouting)   DSDV                       ;# routing protocol
set opt(x)		900			   ;# X dimension of the topography
set opt(y)		900			   ;# Y dimension of the topography


#creation de la topographie
set topo [new Topography]
$topo load_flatgrid $opt(x) $opt(y)
create-god [expr 2*$nbr_f + 2]	
Mac/802_11 set basicRate_ 25Mb
Mac/802_11 set dataRate_ 25Mb
Mac/802_11 set bandwidth_ 25Mb
Mac/802_11 set RTSThreshold_  30000
#definition de la couverture de point d'accés
Phy/WirelessPhy set Pt_ 0.025
Phy/WirelessPhy set RXThresh_ 2.025e-12
Phy/WirelessPhy set CSThresh_ [expr 0.9*[Phy/WirelessPhy set RXThresh_]]
#Mac/802_11 set debug_ 1


#configuration de noeud sans-fil 802.11

$ns node-config -adhocRouting $opt(adhocRouting) \
                 -llType $opt(ll) \
                 -macType $opt(mac) \
                 -ifqType $opt(ifq) \
                 -ifqLen $opt(ifqlen) \
                 -antType $opt(ant) \
                 -propType $opt(prop)    \
                 -phyType $opt(netif) \
                 -channel [new $opt(chan)] \
                 -topoInstance $topo \
                 -wiredRouting ON \
                 -agentTrace ON \
                 -routerTrace OFF \
                 -macTrace ON  \
                 -movementTrace OFF

#création de la station de base 
set PA [$ns node 2.0.0]  
$PA random-motion 0

#provide some co-ord (fixed) to base station node
$PA set X_ 250.0
$PA set Y_ 250.0
$PA set Z_ 0.0
set PAMac [$PA getMac 0]

set AP_ADDR_0 [$PAMac id]
$PAMac bss_id $AP_ADDR_0




$PAMac set-channel 1
$PAMac enable-beacon
[$PA set netif_(0)] setTechno 802.11
puts "le pt d'accées est créé"
$ns duplex-link $R1 $PA 100Mb 10ms DropTail 1000
puts "le lien est créé"


# création de noeud sans-fil
$ns node-config -wiredRouting OFF 
for {set i 0} {$i < $nbr_f} {incr i 1} {
        set wn($i) [$ns node 2.0.[expr $i + 1]] 	                	
	$wn($i) random-motion 0			
        puts "wn($i) créée"			         ;# information de debugage
	$wn($i) base-station [AddrParams addr2id [$PA node-addr]] 
 puts "wn($i) liée au PA"	            ;# information de debugage
	set move_X [new RandomVariable/Uniform]
        $move_X set min_ 240
        $move_X set max_ 260 
        set random_move_X [$move_X value]
        #génération du coordonnée Y
        set move_Y [new RandomVariable/Uniform]
        $move_Y set min_ 240
        $move_Y set max_ 260
        set random_move_Y [$move_Y value]
        #atribution des co-ordonnées
        $wn($i) set X_ $random_move_X
        $wn($i) set Y_ $random_move_Y
        $wn($i) set Z_ 0.0
        [$wn($i) set mac_(0)] set-channel 1
        [$wn($i) set netif_(0)] setTechno 802.11
puts "wn($i): tcl=$wn($i); id=[$wn($i) id]; addr=[$wn($i) node-addr]; x=$random_move_X ; y=$random_move_Y ; 0.0"
}

#creation of LTE nodes

#step 1: define the nodes, the order is fixed!!
set eNB [$ns node];#node id is 0
set aGW [$ns node];#node id is 1
for { set i 0} {$i<$number} {incr i} {
	set UE($i) [$ns node];#node id is > 2
}

# step 2: define the links to connect the nodes
for { set i 0} {$i<$number} {incr i} {
	$ns simplex-link $UE($i) $eNB 500Mb 2ms LTEQueue/ULAirQueue 
	$ns simplex-link $eNB $UE($i) 1000Mb 2ms LTEQueue/DLAirQueue 
}

$ns simplex-link $eNB $aGW 5000Mb 10ms LTEQueue/ULS1Queue 
$ns simplex-link $aGW $eNB 5000Mb 10ms LTEQueue/DLS1Queu

for {set i 0} {$i < $nbr_f} {incr i 1} {
#création de la connection DCCP
set dccp($i) [new Agent/DCCP/TCPlike]
$dccp($i) set timestamps_ true
$ns attach-agent $wn($i) $dccp($i)
$dccp($i) set window_ 100000
$dccp($i) set packetSize_ 1460
$dccp($i) set rate_ 25 000 000
set sink [new Agent/DCCP/TCPlike]
$sink($i) set ts_echo_rfc1323_ true
$ns attach-agent $UE$i) $sink($i)
$ns connect $dccp($i) $sink($i)
puts "la connection est etablite"

#configuration de la couche application en utilisant le protocole FTP 
set ftp($i) [new Application/FTP]
$ftp($i) attach-agent $dccp($i)
$ftp($i) set type_ FTP

$ns at 1.0 "$ftp($i) start"
$ns at 600.0 "$ftp($i) stop"

proc finish {} {
	#global ns f log
	global ns f nf
	$ns flush-trace
	close $f
	close $nf
	puts "running nam..."
	exec nam dccp1.nam &
	exit 0
}

$ns at 600 "finish"
$ns run 
