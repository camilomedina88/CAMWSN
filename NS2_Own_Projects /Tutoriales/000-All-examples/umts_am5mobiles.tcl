global ns
remove-all-packet-headers
add-packet-header MPEG4 MAC_HS RLC LL Mac RTP TCP IP Common 

set ns [new Simulator]
set f [open traza_am1.tr w]
$ns trace-all $f

proc finish {} {
    global ns
    global f
    $ns flush-trace
    close $f
    puts " Simulación Terminada."
    exit 0
}

#Creo el Control de Radiofrecuencia
# Node = 0
$ns node-config -UmtsNodeType rnc
set rnc [$ns create-Umtsnode]

#Creo la Estacion Base
# Node = 1
$ns node-config -UmtsNodeType bs \
		-downlinkBW 32kbs \
		-downlinkTTI 10ms \
		-uplinkBW 32kbs \
		-uplinkTTI 10ms \
		-hs_downlinkTTI 2ms \
      	-hs_downlinkBW 64kbs

set bs [$ns create-Umtsnode]
#Enlace entre rnb y bs
$ns setup-Iub $bs $rnc 622Mbit 622Mbit 15ms 15ms DummyDropTail 2000

$ns node-config -UmtsNodeType ue \
		-baseStation $bs \
		-radioNetworkController $rnc

#Creo los Terminales
# Nodes from 2 to 6 
for {set i 1} {$i < 6} {incr i} {
	set ue($i) [$ns create-Umtsnode]
}
set ue(6) [$ns create-Umtsnode]
#Creo las puertas de enlace
#Node 7 and 8
set sgsn [$ns node]
set ggsn [$ns node]

#Creo los ISP
#Node 9 and 10
set node1 [$ns node]
set node2 [$ns node]

$ns duplex-link $node2 $node1	10Mbit   35ms DropTail 1000
$ns duplex-link $node1 $ggsn	10Mbit   15ms DropTail 1000
$ns duplex-link $ggsn $sgsn 	622Mbit  10ms DropTail 1000
$ns duplex-link $sgsn $rnc  	622Mbit 0.4ms DropTail 1000
$rnc add-gateway $sgsn

for {set i 1} {$i < 6} {incr i} {
set k [expr $i - 1]
	set tcp($i) [new Agent/TCP]
	#$tcp(1) set window_ 1
	$tcp($i) set packetSize_ 500
	$tcp($i) set fid_ $k
	$tcp($i) set prio_ 1
	$ns attach-agent $node2 $tcp($i)
		

	set sink($i) [new Agent/TCPSink]
	$sink($i) set fid_ $k
	$ns attach-agent $ue($i) $sink($i)
	$ns connect $tcp($i) $sink($i)
}

# Aplicacion FTP
for {set i 1} {$i < 6} {incr i} {
 	set ftp($i) [new Application/FTP]
	$ftp($i) attach-agent $tcp($i)
}

$ns node-config -llType UMTS/RLC/AM \
		-downlinkBW 32kbs \
		-downlinkTTI 10ms \
		-uplinkBW 32kbs \
		-uplinkTTI 10ms \

for {set i 1} {$i < 6} {incr i} {
	$ns attach-common $ue($i) $sink($i)			
}

$rnc trace-inlink-tcp $f 0
$bs trace-outlink $f 1
$bs trace-inlink $f 0

for {set i 1} {$i < 6} {incr i} {
	$ue($i) trace-inlink $f 1
	$ue($i) trace-outlink $f 0
	$ue($i) trace-inlink-tcp $f 2
}

for {set i 1} {$i < 6} {incr i} {
set k [expr $i * 10]
	$ns at $k.0 "$ftp($i) start"
	$ns at 200.0 "$ftp($i) stop"
}
$ns at 200.0 "finish"

puts " Ejecutandose la Simulación...."
$ns run
