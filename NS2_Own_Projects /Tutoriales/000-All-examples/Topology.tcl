##################################################################################
# Topology.tcl script of 						         #
# Development of a simulation and performance analysis platform for LTE networks #
# Project done by MINERVE MAMPAKA 					         #
# December 2013								         #
##################################################################################



# create the nodes and links
#create process to set the topology
proc SetTopology {} {

#declare process varialbes
global ns node input_ UE NUMBER_OF_USERS	
global eNodeB SGW PGW SERVER

# create the nodes
set eNodeB [$ns node]	;#node with id 0 is the eNB
$eNodeB label "eNodeB"	;#name eNodeB  like eNodeB in the nam
$eNodeB shape square	;#make the shape of eNodeB a square

set SGW [$ns node]	;#node with id 1 is the SGW
$SGW label "SGW"	;#name SGW like SGW in the nam
$SGW shape hexagon	;#make the shape of SGW an hexagon in the nam

set PGW [$ns node]	;#node with id 2 is the PGW
$PGW label "PGW"	;#name PGW like PGW in the nam
$PGW shape hexagon	;#make the shape of PGW an hexagon in the nam

set SERVER [$ns node]   ;#node with id 3 is the SERVER
$SERVER label "SERVER"	;#name SERVER like SERVER in the nam

#loop to create a user defined number of UEs
for { set i 0} {$i<$NUMBER_OF_USERS} {incr i} {
	set UE($i) [$ns node]		;#node with id from 4 to (number+4) are UE's
        $UE($i) label "UE[expr {$i+1}]"	;#name UE's like UE1, UE2, UE3....UEnumber
}

#loop to create dual-simplex links between UE's and the eNodeB
for { set i 0} {$i < $NUMBER_OF_USERS} {incr i} {

#uplink AIR link from each UE to eNodeB with user defined bandwidth and delay 
$ns simplex-link $UE($i) $eNodeB $input_(UP_AIR_BANDWIDTH) $input_(UP_AIR_DELAY) $input_(UP_AIR_QUEUE)
$ns queue-limit $UE($i) $eNodeB $input_(QUEUE_LIMIT)

#downlink AIR link from each eNodeB to UE with user defined bandwidth and delay 
$ns simplex-link $eNodeB $UE($i) $input_(DOWN_AIR_BANDWIDTH) $input_(DOWN_AIR_DELAY) $input_(DOWN_AIR_QUEUE)
$ns queue-limit $eNodeB $UE($i) $input_(QUEUE_LIMIT)

}

#create dual-simplex links between eNodeB and the SGW
#uplink S1-U link from each eNB to SGW with user defined bandwidth and delay 
$ns simplex-link $eNodeB $SGW $input_(UP_S1_BANDWIDTH) $input_(UP_S1_DELAY) $input_(UP_S1_QUEUE)
$ns queue-limit $eNodeB $SGW $input_(QUEUE_LIMIT)

#downlink S1-U link from each SGW to eNB with user defined bandwidth and delay 
$ns simplex-link $SGW $eNodeB $input_(DOWN_S1_BANDWIDTH) $input_(DOWN_S1_DELAY) $input_(DOWN_S1_QUEUE)
$ns queue-limit $SGW $eNodeB $input_(QUEUE_LIMIT)

#create duplex link between SGW and PGW with user defined bandwidth and delay 
$ns duplex-link $SGW $PGW $input_(S5_BANDWIDTH) $input_(S5_DELAY) $input_(S5_QUEUE)
$ns queue-limit $SGW $PGW $input_(QUEUE_LIMIT)

#create duplex link between PGW and SERVER with user defined bandwidth and delay 
$ns duplex-link $PGW $SERVER $input_(SGI_BANDWIDTH) $input_(SGI_DELAY) $input_(SGI_QUEUE)
$ns queue-limit $PGW $SERVER $input_(QUEUE_LIMIT)

}





