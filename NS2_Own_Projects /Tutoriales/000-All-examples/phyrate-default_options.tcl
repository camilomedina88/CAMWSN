# ======================================================================
# Define options
# ======================================================================
set val(chan)          	Channel/WirelessChannel    	;# channel type
set val(prop)          	Propagation/TwoRayGround   	;# radio-propagation model
set val(netif)          Phy/WirelessPhy            	;# network interface type
set val(mac)            Mac/802_11                	;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    	;# interface queue type
set val(ll)             LL                         	;# link layer type
set val(ant)            Antenna/OmniAntenna        	;# antenna model
set val(rp)             DumbAgent                  	;# routing protocol
set val(start)          0.0
set val(tr)             "trace"
set val(X)              100
set val(Y)              100
set val(UPDpacketsize)  65536
set val(RTSThreshold)   65536



set val(ShortRetryLimit) 4
set val(LongRetryLimit)  4
set val(CWmin)          16
set val(CWmax)          1024
set val(SlotTime)       0.000009
set val(SIFS)           0.000016

set 		rng 		[new RNG]
$rng 		seed 	0
set 		ss 		[$rng next-random]
#puts 		"random number for ns is: $ss"
set 		opt(seed) 			$ss	

