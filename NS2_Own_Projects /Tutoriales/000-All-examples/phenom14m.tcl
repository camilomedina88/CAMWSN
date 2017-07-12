################################################################################
# AUTHOR: Ian Downard
# DATE: 15 APR 2003
# DESCRIPTION:
#
#   This simulation tests the scalability of sensor network simulations in ns2.
# 10 phenom nodes move according to the birds model through a field of 400
# sensor nodes, running AODV.  Other simulation parameters include:
#  grid width = grid heigth = 2000
#  simulation duration = 20
#  number of gateway nodes (sensor data sinks) = 1
#
################################################################################



#
# ======================================================================
# Define options
# ======================================================================
set val(prop)      Propagation/TwoRayGround ;# radio-propagation model
set val(netif)     Phy/WirelessPhy          ;# network interface type
set val(mac)       Mac/802_11               ;# MAC type
set val(PHENOMmac) Mac                      ;# MAC type for phenomena
set val(ifq)       Queue/DropTail/PriQueue  ;# interface queue type
set val(ll)        LL                       ;# link layer type
set val(ant)       Antenna/OmniAntenna      ;# antenna model
set val(ifqlen)    50                       ;# max packet in ifq
set val(nn)        410                      ;# number of mobilenodes
set val(rp)        AODV                     ;# routing protocol
set val(x)	     2000                       ;# grid width
set val(y)	     2000                      ;# grid hieght

Queue/DropTail/PriQueue set Prefer_Routing_Protocols    1
Phy/WirelessPhy set Pt_ 0.03
puts "This is a sensor network simulation."

# =====================================================================
# Main Program
# ======================================================================

set ns_		[new Simulator]
set tracefd [open simme.tr w]
set idstracefd [open idstrace14.tr w]
$ns_ trace-all $tracefd
set namtrace [open simme.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)
set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)
set god_ [create-god 411]
$god_ off
$god_ allow_to_stop
$god_ num_data_types 1

#configure phenomenon channel and data channel
set chan_1_ [new Channel/WirelessChannel]
set chan_2_ [new Channel/WirelessChannel]

# configure phenomenon node with the PHENOM routing protocol
$ns_ node-config \
   -adhocRouting PHENOM \
	 -llType $val(ll) \
	 -macType $val(PHENOMmac) \
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

	for {set i 0} {$i < 10} {incr i} {
    set node_($i) [$ns_ node $i]
   $node_($i) random-motion 0
   $god_ new_node $node_($i)
   $node_($i) namattach $namtrace
   $ns_ initial_node_pos $node_($i) 25
    [$node_($i) set ragent_] pulserate .09
    [$node_($i) set ragent_] phenomenon CO

	}

# configure sensor nodes
$ns_ node-config \
     -adhocRouting $val(rp) \
	   -channel $chan_2_ \
	   -macType $val(mac) \
	   -PHENOMmacType $val(PHENOMmac) \
     -PHENOMchannel $chan_1_ \
	 -ids MIUN_IDS

	for {set i 10} {$i < 410 } {incr i} {
		set node_($i) [$ns_ node]	
	   $node_($i) random-motion 1
     $god_ new_node $node_($i)
     $node_($i) namattach $namtrace
	}

# configure data collection point
$ns_ node-config \
     -adhocRouting $val(rp) \
	   -channel $chan_2_ \
     -PHENOMchannel "off"

	for {set i 410} {$i < 411 } {incr i} {
      set node_($i) [$ns_ node]
     $node_($i) random-motion 1
     $god_ new_node $node_($i)
     $node_($i) namattach $namtrace

	}

#
# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
#
$node_(10) set X_ 1
$node_(10) set Y_ 1
$node_(11) set X_ 105
$node_(11) set Y_ 1
$node_(12) set X_ 209
$node_(12) set Y_ 1
$node_(13) set X_ 313
$node_(13) set Y_ 1
$node_(14) set X_ 417
$node_(14) set Y_ 1
$node_(15) set X_ 521
$node_(15) set Y_ 1
$node_(16) set X_ 625
$node_(16) set Y_ 1
$node_(17) set X_ 729
$node_(17) set Y_ 1
$node_(18) set X_ 833
$node_(18) set Y_ 1
$node_(19) set X_ 937
$node_(19) set Y_ 1
$node_(20) set X_ 1041
$node_(20) set Y_ 1
$node_(21) set X_ 1145
$node_(21) set Y_ 1
$node_(22) set X_ 1249
$node_(22) set Y_ 1
$node_(23) set X_ 1353
$node_(23) set Y_ 1
$node_(24) set X_ 1457
$node_(24) set Y_ 1
$node_(25) set X_ 1561
$node_(25) set Y_ 1
$node_(26) set X_ 1665
$node_(26) set Y_ 1
$node_(27) set X_ 1769
$node_(27) set Y_ 1
$node_(28) set X_ 1873
$node_(28) set Y_ 1
$node_(29) set X_ 1977
$node_(29) set Y_ 1
$node_(30) set X_ 1
$node_(30) set Y_ 100
$node_(31) set X_ 105
$node_(31) set Y_ 100
$node_(32) set X_ 209
$node_(32) set Y_ 100
$node_(33) set X_ 313
$node_(33) set Y_ 100
$node_(34) set X_ 417
$node_(34) set Y_ 100
$node_(35) set X_ 521
$node_(35) set Y_ 100
$node_(36) set X_ 625
$node_(36) set Y_ 100
$node_(37) set X_ 729
$node_(37) set Y_ 100
$node_(38) set X_ 833
$node_(38) set Y_ 100
$node_(39) set X_ 937
$node_(39) set Y_ 100
$node_(40) set X_ 1041
$node_(40) set Y_ 100
$node_(41) set X_ 1145
$node_(41) set Y_ 100
$node_(42) set X_ 1249
$node_(42) set Y_ 100
$node_(43) set X_ 1353
$node_(43) set Y_ 100
$node_(44) set X_ 1457
$node_(44) set Y_ 100
$node_(45) set X_ 1561
$node_(45) set Y_ 100
$node_(46) set X_ 1665
$node_(46) set Y_ 100
$node_(47) set X_ 1769
$node_(47) set Y_ 100
$node_(48) set X_ 1873
$node_(48) set Y_ 100
$node_(49) set X_ 1977
$node_(49) set Y_ 100
$node_(50) set X_ 1
$node_(50) set Y_ 199
$node_(51) set X_ 105
$node_(51) set Y_ 199
$node_(52) set X_ 209
$node_(52) set Y_ 199
$node_(53) set X_ 313
$node_(53) set Y_ 199
$node_(54) set X_ 417
$node_(54) set Y_ 199
$node_(55) set X_ 521
$node_(55) set Y_ 199
$node_(56) set X_ 625
$node_(56) set Y_ 199
$node_(57) set X_ 729
$node_(57) set Y_ 199
$node_(58) set X_ 833
$node_(58) set Y_ 199
$node_(59) set X_ 937
$node_(59) set Y_ 199
$node_(60) set X_ 1041
$node_(60) set Y_ 199
$node_(61) set X_ 1145
$node_(61) set Y_ 199
$node_(62) set X_ 1249
$node_(62) set Y_ 199
$node_(63) set X_ 1353
$node_(63) set Y_ 199
$node_(64) set X_ 1457
$node_(64) set Y_ 199
$node_(65) set X_ 1561
$node_(65) set Y_ 199
$node_(66) set X_ 1665
$node_(66) set Y_ 199
$node_(67) set X_ 1769
$node_(67) set Y_ 199
$node_(68) set X_ 1873
$node_(68) set Y_ 199
$node_(69) set X_ 1977
$node_(69) set Y_ 199
$node_(70) set X_ 1
$node_(70) set Y_ 298
$node_(71) set X_ 105
$node_(71) set Y_ 298
$node_(72) set X_ 209
$node_(72) set Y_ 298
$node_(73) set X_ 313
$node_(73) set Y_ 298
$node_(74) set X_ 417
$node_(74) set Y_ 298
$node_(75) set X_ 521
$node_(75) set Y_ 298
$node_(76) set X_ 625
$node_(76) set Y_ 298
$node_(77) set X_ 729
$node_(77) set Y_ 298
$node_(78) set X_ 833
$node_(78) set Y_ 298
$node_(79) set X_ 937
$node_(79) set Y_ 298
$node_(80) set X_ 1041
$node_(80) set Y_ 298
$node_(81) set X_ 1145
$node_(81) set Y_ 298
$node_(82) set X_ 1249
$node_(82) set Y_ 298
$node_(83) set X_ 1353
$node_(83) set Y_ 298
$node_(84) set X_ 1457
$node_(84) set Y_ 298
$node_(85) set X_ 1561
$node_(85) set Y_ 298
$node_(86) set X_ 1665
$node_(86) set Y_ 298
$node_(87) set X_ 1769
$node_(87) set Y_ 298
$node_(88) set X_ 1873
$node_(88) set Y_ 298
$node_(89) set X_ 1977
$node_(89) set Y_ 298
$node_(90) set X_ 1
$node_(90) set Y_ 397
$node_(91) set X_ 105
$node_(91) set Y_ 397
$node_(92) set X_ 209
$node_(92) set Y_ 397
$node_(93) set X_ 313
$node_(93) set Y_ 397
$node_(94) set X_ 417
$node_(94) set Y_ 397
$node_(95) set X_ 521
$node_(95) set Y_ 397
$node_(96) set X_ 625
$node_(96) set Y_ 397
$node_(97) set X_ 729
$node_(97) set Y_ 397
$node_(98) set X_ 833
$node_(98) set Y_ 397
$node_(99) set X_ 937
$node_(99) set Y_ 397
$node_(100) set X_ 1041
$node_(100) set Y_ 397
$node_(101) set X_ 1145
$node_(101) set Y_ 397
$node_(102) set X_ 1249
$node_(102) set Y_ 397
$node_(103) set X_ 1353
$node_(103) set Y_ 397
$node_(104) set X_ 1457
$node_(104) set Y_ 397
$node_(105) set X_ 1561
$node_(105) set Y_ 397
$node_(106) set X_ 1665
$node_(106) set Y_ 397
$node_(107) set X_ 1769
$node_(107) set Y_ 397
$node_(108) set X_ 1873
$node_(108) set Y_ 397
$node_(109) set X_ 1977
$node_(109) set Y_ 397
$node_(110) set X_ 1
$node_(110) set Y_ 496
$node_(111) set X_ 105
$node_(111) set Y_ 496
$node_(112) set X_ 209
$node_(112) set Y_ 496
$node_(113) set X_ 313
$node_(113) set Y_ 496
$node_(114) set X_ 417
$node_(114) set Y_ 496
$node_(115) set X_ 521
$node_(115) set Y_ 496
$node_(116) set X_ 625
$node_(116) set Y_ 496
$node_(117) set X_ 729
$node_(117) set Y_ 496
$node_(118) set X_ 833
$node_(118) set Y_ 496
$node_(119) set X_ 937
$node_(119) set Y_ 496
$node_(120) set X_ 1041
$node_(120) set Y_ 496
$node_(121) set X_ 1145
$node_(121) set Y_ 496
$node_(122) set X_ 1249
$node_(122) set Y_ 496
$node_(123) set X_ 1353
$node_(123) set Y_ 496
$node_(124) set X_ 1457
$node_(124) set Y_ 496
$node_(125) set X_ 1561
$node_(125) set Y_ 496
$node_(126) set X_ 1665
$node_(126) set Y_ 496
$node_(127) set X_ 1769
$node_(127) set Y_ 496
$node_(128) set X_ 1873
$node_(128) set Y_ 496
$node_(129) set X_ 1977
$node_(129) set Y_ 496
$node_(130) set X_ 1
$node_(130) set Y_ 595
$node_(131) set X_ 105
$node_(131) set Y_ 595
$node_(132) set X_ 209
$node_(132) set Y_ 595
$node_(133) set X_ 313
$node_(133) set Y_ 595
$node_(134) set X_ 417
$node_(134) set Y_ 595
$node_(135) set X_ 521
$node_(135) set Y_ 595
$node_(136) set X_ 625
$node_(136) set Y_ 595
$node_(137) set X_ 729
$node_(137) set Y_ 595
$node_(138) set X_ 833
$node_(138) set Y_ 595
$node_(139) set X_ 937
$node_(139) set Y_ 595
$node_(140) set X_ 1041
$node_(140) set Y_ 595
$node_(141) set X_ 1145
$node_(141) set Y_ 595
$node_(142) set X_ 1249
$node_(142) set Y_ 595
$node_(143) set X_ 1353
$node_(143) set Y_ 595
$node_(144) set X_ 1457
$node_(144) set Y_ 595
$node_(145) set X_ 1561
$node_(145) set Y_ 595
$node_(146) set X_ 1665
$node_(146) set Y_ 595
$node_(147) set X_ 1769
$node_(147) set Y_ 595
$node_(148) set X_ 1873
$node_(148) set Y_ 595
$node_(149) set X_ 1977
$node_(149) set Y_ 595
$node_(150) set X_ 1
$node_(150) set Y_ 694
$node_(151) set X_ 105
$node_(151) set Y_ 694
$node_(152) set X_ 209
$node_(152) set Y_ 694
$node_(153) set X_ 313
$node_(153) set Y_ 694
$node_(154) set X_ 417
$node_(154) set Y_ 694
$node_(155) set X_ 521
$node_(155) set Y_ 694
$node_(156) set X_ 625
$node_(156) set Y_ 694
$node_(157) set X_ 729
$node_(157) set Y_ 694
$node_(158) set X_ 833
$node_(158) set Y_ 694
$node_(159) set X_ 937
$node_(159) set Y_ 694
$node_(160) set X_ 1041
$node_(160) set Y_ 694
$node_(161) set X_ 1145
$node_(161) set Y_ 694
$node_(162) set X_ 1249
$node_(162) set Y_ 694
$node_(163) set X_ 1353
$node_(163) set Y_ 694
$node_(164) set X_ 1457
$node_(164) set Y_ 694
$node_(165) set X_ 1561
$node_(165) set Y_ 694
$node_(166) set X_ 1665
$node_(166) set Y_ 694
$node_(167) set X_ 1769
$node_(167) set Y_ 694
$node_(168) set X_ 1873
$node_(168) set Y_ 694
$node_(169) set X_ 1977
$node_(169) set Y_ 694
$node_(170) set X_ 1
$node_(170) set Y_ 793
$node_(171) set X_ 105
$node_(171) set Y_ 793
$node_(172) set X_ 209
$node_(172) set Y_ 793
$node_(173) set X_ 313
$node_(173) set Y_ 793
$node_(174) set X_ 417
$node_(174) set Y_ 793
$node_(175) set X_ 521
$node_(175) set Y_ 793
$node_(176) set X_ 625
$node_(176) set Y_ 793
$node_(177) set X_ 729
$node_(177) set Y_ 793
$node_(178) set X_ 833
$node_(178) set Y_ 793
$node_(179) set X_ 937
$node_(179) set Y_ 793
$node_(180) set X_ 1041
$node_(180) set Y_ 793
$node_(181) set X_ 1145
$node_(181) set Y_ 793
$node_(182) set X_ 1249
$node_(182) set Y_ 793
$node_(183) set X_ 1353
$node_(183) set Y_ 793
$node_(184) set X_ 1457
$node_(184) set Y_ 793
$node_(185) set X_ 1561
$node_(185) set Y_ 793
$node_(186) set X_ 1665
$node_(186) set Y_ 793
$node_(187) set X_ 1769
$node_(187) set Y_ 793
$node_(188) set X_ 1873
$node_(188) set Y_ 793
$node_(189) set X_ 1977
$node_(189) set Y_ 793
$node_(190) set X_ 1
$node_(190) set Y_ 892
$node_(191) set X_ 105
$node_(191) set Y_ 892
$node_(192) set X_ 209
$node_(192) set Y_ 892
$node_(193) set X_ 313
$node_(193) set Y_ 892
$node_(194) set X_ 417
$node_(194) set Y_ 892
$node_(195) set X_ 521
$node_(195) set Y_ 892
$node_(196) set X_ 625
$node_(196) set Y_ 892
$node_(197) set X_ 729
$node_(197) set Y_ 892
$node_(198) set X_ 833
$node_(198) set Y_ 892
$node_(199) set X_ 937
$node_(199) set Y_ 892
$node_(200) set X_ 1041
$node_(200) set Y_ 892
$node_(201) set X_ 1145
$node_(201) set Y_ 892
$node_(202) set X_ 1249
$node_(202) set Y_ 892
$node_(203) set X_ 1353
$node_(203) set Y_ 892
$node_(204) set X_ 1457
$node_(204) set Y_ 892
$node_(205) set X_ 1561
$node_(205) set Y_ 892
$node_(206) set X_ 1665
$node_(206) set Y_ 892
$node_(207) set X_ 1769
$node_(207) set Y_ 892
$node_(208) set X_ 1873
$node_(208) set Y_ 892
$node_(209) set X_ 1977
$node_(209) set Y_ 892
$node_(210) set X_ 1
$node_(210) set Y_ 991
$node_(211) set X_ 105
$node_(211) set Y_ 991
$node_(212) set X_ 209
$node_(212) set Y_ 991
$node_(213) set X_ 313
$node_(213) set Y_ 991
$node_(214) set X_ 417
$node_(214) set Y_ 991
$node_(215) set X_ 521
$node_(215) set Y_ 991
$node_(216) set X_ 625
$node_(216) set Y_ 991
$node_(217) set X_ 729
$node_(217) set Y_ 991
$node_(218) set X_ 833
$node_(218) set Y_ 991
$node_(219) set X_ 937
$node_(219) set Y_ 991
$node_(220) set X_ 1041
$node_(220) set Y_ 991
$node_(221) set X_ 1145
$node_(221) set Y_ 991
$node_(222) set X_ 1249
$node_(222) set Y_ 991
$node_(223) set X_ 1353
$node_(223) set Y_ 991
$node_(224) set X_ 1457
$node_(224) set Y_ 991
$node_(225) set X_ 1561
$node_(225) set Y_ 991
$node_(226) set X_ 1665
$node_(226) set Y_ 991
$node_(227) set X_ 1769
$node_(227) set Y_ 991
$node_(228) set X_ 1873
$node_(228) set Y_ 991
$node_(229) set X_ 1977
$node_(229) set Y_ 991
$node_(230) set X_ 1
$node_(230) set Y_ 1090
$node_(231) set X_ 105
$node_(231) set Y_ 1090
$node_(232) set X_ 209
$node_(232) set Y_ 1090
$node_(233) set X_ 313
$node_(233) set Y_ 1090
$node_(234) set X_ 417
$node_(234) set Y_ 1090
$node_(235) set X_ 521
$node_(235) set Y_ 1090
$node_(236) set X_ 625
$node_(236) set Y_ 1090
$node_(237) set X_ 729
$node_(237) set Y_ 1090
$node_(238) set X_ 833
$node_(238) set Y_ 1090
$node_(239) set X_ 937
$node_(239) set Y_ 1090
$node_(240) set X_ 1041
$node_(240) set Y_ 1090
$node_(241) set X_ 1145
$node_(241) set Y_ 1090
$node_(242) set X_ 1249
$node_(242) set Y_ 1090
$node_(243) set X_ 1353
$node_(243) set Y_ 1090
$node_(244) set X_ 1457
$node_(244) set Y_ 1090
$node_(245) set X_ 1561
$node_(245) set Y_ 1090
$node_(246) set X_ 1665
$node_(246) set Y_ 1090
$node_(247) set X_ 1769
$node_(247) set Y_ 1090
$node_(248) set X_ 1873
$node_(248) set Y_ 1090
$node_(249) set X_ 1977
$node_(249) set Y_ 1090
$node_(250) set X_ 1
$node_(250) set Y_ 1189
$node_(251) set X_ 105
$node_(251) set Y_ 1189
$node_(252) set X_ 209
$node_(252) set Y_ 1189
$node_(253) set X_ 313
$node_(253) set Y_ 1189
$node_(254) set X_ 417
$node_(254) set Y_ 1189
$node_(255) set X_ 521
$node_(255) set Y_ 1189
$node_(256) set X_ 625
$node_(256) set Y_ 1189
$node_(257) set X_ 729
$node_(257) set Y_ 1189
$node_(258) set X_ 833
$node_(258) set Y_ 1189
$node_(259) set X_ 937
$node_(259) set Y_ 1189
$node_(260) set X_ 1041
$node_(260) set Y_ 1189
$node_(261) set X_ 1145
$node_(261) set Y_ 1189
$node_(262) set X_ 1249
$node_(262) set Y_ 1189
$node_(263) set X_ 1353
$node_(263) set Y_ 1189
$node_(264) set X_ 1457
$node_(264) set Y_ 1189
$node_(265) set X_ 1561
$node_(265) set Y_ 1189
$node_(266) set X_ 1665
$node_(266) set Y_ 1189
$node_(267) set X_ 1769
$node_(267) set Y_ 1189
$node_(268) set X_ 1873
$node_(268) set Y_ 1189
$node_(269) set X_ 1977
$node_(269) set Y_ 1189
$node_(270) set X_ 1
$node_(270) set Y_ 1288
$node_(271) set X_ 105
$node_(271) set Y_ 1288
$node_(272) set X_ 209
$node_(272) set Y_ 1288
$node_(273) set X_ 313
$node_(273) set Y_ 1288
$node_(274) set X_ 417
$node_(274) set Y_ 1288
$node_(275) set X_ 521
$node_(275) set Y_ 1288
$node_(276) set X_ 625
$node_(276) set Y_ 1288
$node_(277) set X_ 729
$node_(277) set Y_ 1288
$node_(278) set X_ 833
$node_(278) set Y_ 1288
$node_(279) set X_ 937
$node_(279) set Y_ 1288
$node_(280) set X_ 1041
$node_(280) set Y_ 1288
$node_(281) set X_ 1145
$node_(281) set Y_ 1288
$node_(282) set X_ 1249
$node_(282) set Y_ 1288
$node_(283) set X_ 1353
$node_(283) set Y_ 1288
$node_(284) set X_ 1457
$node_(284) set Y_ 1288
$node_(285) set X_ 1561
$node_(285) set Y_ 1288
$node_(286) set X_ 1665
$node_(286) set Y_ 1288
$node_(287) set X_ 1769
$node_(287) set Y_ 1288
$node_(288) set X_ 1873
$node_(288) set Y_ 1288
$node_(289) set X_ 1977
$node_(289) set Y_ 1288
$node_(290) set X_ 1
$node_(290) set Y_ 1387
$node_(291) set X_ 105
$node_(291) set Y_ 1387
$node_(292) set X_ 209
$node_(292) set Y_ 1387
$node_(293) set X_ 313
$node_(293) set Y_ 1387
$node_(294) set X_ 417
$node_(294) set Y_ 1387
$node_(295) set X_ 521
$node_(295) set Y_ 1387
$node_(296) set X_ 625
$node_(296) set Y_ 1387
$node_(297) set X_ 729
$node_(297) set Y_ 1387
$node_(298) set X_ 833
$node_(298) set Y_ 1387
$node_(299) set X_ 937
$node_(299) set Y_ 1387
$node_(300) set X_ 1041
$node_(300) set Y_ 1387
$node_(301) set X_ 1145
$node_(301) set Y_ 1387
$node_(302) set X_ 1249
$node_(302) set Y_ 1387
$node_(303) set X_ 1353
$node_(303) set Y_ 1387
$node_(304) set X_ 1457
$node_(304) set Y_ 1387
$node_(305) set X_ 1561
$node_(305) set Y_ 1387
$node_(306) set X_ 1665
$node_(306) set Y_ 1387
$node_(307) set X_ 1769
$node_(307) set Y_ 1387
$node_(308) set X_ 1873
$node_(308) set Y_ 1387
$node_(309) set X_ 1977
$node_(309) set Y_ 1387
$node_(310) set X_ 1
$node_(310) set Y_ 1486
$node_(311) set X_ 105
$node_(311) set Y_ 1486
$node_(312) set X_ 209
$node_(312) set Y_ 1486
$node_(313) set X_ 313
$node_(313) set Y_ 1486
$node_(314) set X_ 417
$node_(314) set Y_ 1486
$node_(315) set X_ 521
$node_(315) set Y_ 1486
$node_(316) set X_ 625
$node_(316) set Y_ 1486
$node_(317) set X_ 729
$node_(317) set Y_ 1486
$node_(318) set X_ 833
$node_(318) set Y_ 1486
$node_(319) set X_ 937
$node_(319) set Y_ 1486
$node_(320) set X_ 1041
$node_(320) set Y_ 1486
$node_(321) set X_ 1145
$node_(321) set Y_ 1486
$node_(322) set X_ 1249
$node_(322) set Y_ 1486
$node_(323) set X_ 1353
$node_(323) set Y_ 1486
$node_(324) set X_ 1457
$node_(324) set Y_ 1486
$node_(325) set X_ 1561
$node_(325) set Y_ 1486
$node_(326) set X_ 1665
$node_(326) set Y_ 1486
$node_(327) set X_ 1769
$node_(327) set Y_ 1486
$node_(328) set X_ 1873
$node_(328) set Y_ 1486
$node_(329) set X_ 1977
$node_(329) set Y_ 1486
$node_(330) set X_ 1
$node_(330) set Y_ 1585
$node_(331) set X_ 105
$node_(331) set Y_ 1585
$node_(332) set X_ 209
$node_(332) set Y_ 1585
$node_(333) set X_ 313
$node_(333) set Y_ 1585
$node_(334) set X_ 417
$node_(334) set Y_ 1585
$node_(335) set X_ 521
$node_(335) set Y_ 1585
$node_(336) set X_ 625
$node_(336) set Y_ 1585
$node_(337) set X_ 729
$node_(337) set Y_ 1585
$node_(338) set X_ 833
$node_(338) set Y_ 1585
$node_(339) set X_ 937
$node_(339) set Y_ 1585
$node_(340) set X_ 1041
$node_(340) set Y_ 1585
$node_(341) set X_ 1145
$node_(341) set Y_ 1585
$node_(342) set X_ 1249
$node_(342) set Y_ 1585
$node_(343) set X_ 1353
$node_(343) set Y_ 1585
$node_(344) set X_ 1457
$node_(344) set Y_ 1585
$node_(345) set X_ 1561
$node_(345) set Y_ 1585
$node_(346) set X_ 1665
$node_(346) set Y_ 1585
$node_(347) set X_ 1769
$node_(347) set Y_ 1585
$node_(348) set X_ 1873
$node_(348) set Y_ 1585
$node_(349) set X_ 1977
$node_(349) set Y_ 1585
$node_(350) set X_ 1
$node_(350) set Y_ 1684
$node_(351) set X_ 105
$node_(351) set Y_ 1684
$node_(352) set X_ 209
$node_(352) set Y_ 1684
$node_(353) set X_ 313
$node_(353) set Y_ 1684
$node_(354) set X_ 417
$node_(354) set Y_ 1684
$node_(355) set X_ 521
$node_(355) set Y_ 1684
$node_(356) set X_ 625
$node_(356) set Y_ 1684
$node_(357) set X_ 729
$node_(357) set Y_ 1684
$node_(358) set X_ 833
$node_(358) set Y_ 1684
$node_(359) set X_ 937
$node_(359) set Y_ 1684
$node_(360) set X_ 1041
$node_(360) set Y_ 1684
$node_(361) set X_ 1145
$node_(361) set Y_ 1684
$node_(362) set X_ 1249
$node_(362) set Y_ 1684
$node_(363) set X_ 1353
$node_(363) set Y_ 1684
$node_(364) set X_ 1457
$node_(364) set Y_ 1684
$node_(365) set X_ 1561
$node_(365) set Y_ 1684
$node_(366) set X_ 1665
$node_(366) set Y_ 1684
$node_(367) set X_ 1769
$node_(367) set Y_ 1684
$node_(368) set X_ 1873
$node_(368) set Y_ 1684
$node_(369) set X_ 1977
$node_(369) set Y_ 1684
$node_(370) set X_ 1
$node_(370) set Y_ 1783
$node_(371) set X_ 105
$node_(371) set Y_ 1783
$node_(372) set X_ 209
$node_(372) set Y_ 1783
$node_(373) set X_ 313
$node_(373) set Y_ 1783
$node_(374) set X_ 417
$node_(374) set Y_ 1783
$node_(375) set X_ 521
$node_(375) set Y_ 1783
$node_(376) set X_ 625
$node_(376) set Y_ 1783
$node_(377) set X_ 729
$node_(377) set Y_ 1783
$node_(378) set X_ 833
$node_(378) set Y_ 1783
$node_(379) set X_ 937
$node_(379) set Y_ 1783
$node_(380) set X_ 1041
$node_(380) set Y_ 1783
$node_(381) set X_ 1145
$node_(381) set Y_ 1783
$node_(382) set X_ 1249
$node_(382) set Y_ 1783
$node_(383) set X_ 1353
$node_(383) set Y_ 1783
$node_(384) set X_ 1457
$node_(384) set Y_ 1783
$node_(385) set X_ 1561
$node_(385) set Y_ 1783
$node_(386) set X_ 1665
$node_(386) set Y_ 1783
$node_(387) set X_ 1769
$node_(387) set Y_ 1783
$node_(388) set X_ 1873
$node_(388) set Y_ 1783
$node_(389) set X_ 1977
$node_(389) set Y_ 1783
$node_(390) set X_ 1
$node_(390) set Y_ 1882
$node_(391) set X_ 105
$node_(391) set Y_ 1882
$node_(392) set X_ 209
$node_(392) set Y_ 1882
$node_(393) set X_ 313
$node_(393) set Y_ 1882
$node_(394) set X_ 417
$node_(394) set Y_ 1882
$node_(395) set X_ 521
$node_(395) set Y_ 1882
$node_(396) set X_ 625
$node_(396) set Y_ 1882
$node_(397) set X_ 729
$node_(397) set Y_ 1882
$node_(398) set X_ 833
$node_(398) set Y_ 1882
$node_(399) set X_ 937
$node_(399) set Y_ 1882
$node_(400) set X_ 1041
$node_(400) set Y_ 1882
$node_(401) set X_ 1145
$node_(401) set Y_ 1882
$node_(402) set X_ 1249
$node_(402) set Y_ 1882
$node_(403) set X_ 1353
$node_(403) set Y_ 1882
$node_(404) set X_ 1457
$node_(404) set Y_ 1882
$node_(405) set X_ 1561
$node_(405) set Y_ 1882
$node_(406) set X_ 1665
$node_(406) set Y_ 1882
$node_(407) set X_ 1769
$node_(407) set Y_ 1882
$node_(408) set X_ 1873
$node_(408) set Y_ 1882
$node_(409) set X_ 1977
$node_(409) set Y_ 1882
$node_(410) set X_ 1
$node_(410) set Y_ 1981
#setdest format is "setdest <x> <y> <speed>"
$ns_ at 0.01 "$node_(10) setdest 1 1 50.0"
$ns_ at 0.01 "$node_(11) setdest 105 1 50.0"
$ns_ at 0.01 "$node_(12) setdest 209 1 50.0"
$ns_ at 0.01 "$node_(13) setdest 313 1 50.0"
$ns_ at 0.01 "$node_(14) setdest 417 1 50.0"
$ns_ at 0.01 "$node_(15) setdest 521 1 50.0"
$ns_ at 0.01 "$node_(16) setdest 625 1 50.0"
$ns_ at 0.01 "$node_(17) setdest 729 1 50.0"
$ns_ at 0.01 "$node_(18) setdest 833 1 50.0"
$ns_ at 0.01 "$node_(19) setdest 937 1 50.0"
$ns_ at 0.01 "$node_(20) setdest 1041 1 50.0"
$ns_ at 0.01 "$node_(21) setdest 1145 1 50.0"
$ns_ at 0.01 "$node_(22) setdest 1249 1 50.0"
$ns_ at 0.01 "$node_(23) setdest 1353 1 50.0"
$ns_ at 0.01 "$node_(24) setdest 1457 1 50.0"
$ns_ at 0.01 "$node_(25) setdest 1561 1 50.0"
$ns_ at 0.01 "$node_(26) setdest 1665 1 50.0"
$ns_ at 0.01 "$node_(27) setdest 1769 1 50.0"
$ns_ at 0.01 "$node_(28) setdest 1873 1 50.0"
$ns_ at 0.01 "$node_(29) setdest 1977 1 50.0"
$ns_ at 0.01 "$node_(30) setdest 1 100 50.0"
$ns_ at 0.01 "$node_(31) setdest 105 100 50.0"
$ns_ at 0.01 "$node_(32) setdest 209 100 50.0"
$ns_ at 0.01 "$node_(33) setdest 313 100 50.0"
$ns_ at 0.01 "$node_(34) setdest 417 100 50.0"
$ns_ at 0.01 "$node_(35) setdest 521 100 50.0"
$ns_ at 0.01 "$node_(36) setdest 625 100 50.0"
$ns_ at 0.01 "$node_(37) setdest 729 100 50.0"
$ns_ at 0.01 "$node_(38) setdest 833 100 50.0"
$ns_ at 0.01 "$node_(39) setdest 937 100 50.0"
$ns_ at 0.01 "$node_(40) setdest 1041 100 50.0"
$ns_ at 0.01 "$node_(41) setdest 1145 100 50.0"
$ns_ at 0.01 "$node_(42) setdest 1249 100 50.0"
$ns_ at 0.01 "$node_(43) setdest 1353 100 50.0"
$ns_ at 0.01 "$node_(44) setdest 1457 100 50.0"
$ns_ at 0.01 "$node_(45) setdest 1561 100 50.0"
$ns_ at 0.01 "$node_(46) setdest 1665 100 50.0"
$ns_ at 0.01 "$node_(47) setdest 1769 100 50.0"
$ns_ at 0.01 "$node_(48) setdest 1873 100 50.0"
$ns_ at 0.01 "$node_(49) setdest 1977 100 50.0"
$ns_ at 0.01 "$node_(50) setdest 1 199 50.0"
$ns_ at 0.01 "$node_(51) setdest 105 199 50.0"
$ns_ at 0.01 "$node_(52) setdest 209 199 50.0"
$ns_ at 0.01 "$node_(53) setdest 313 199 50.0"
$ns_ at 0.01 "$node_(54) setdest 417 199 50.0"
$ns_ at 0.01 "$node_(55) setdest 521 199 50.0"
$ns_ at 0.01 "$node_(56) setdest 625 199 50.0"
$ns_ at 0.01 "$node_(57) setdest 729 199 50.0"
$ns_ at 0.01 "$node_(58) setdest 833 199 50.0"
$ns_ at 0.01 "$node_(59) setdest 937 199 50.0"
$ns_ at 0.01 "$node_(60) setdest 1041 199 50.0"
$ns_ at 0.01 "$node_(61) setdest 1145 199 50.0"
$ns_ at 0.01 "$node_(62) setdest 1249 199 50.0"
$ns_ at 0.01 "$node_(63) setdest 1353 199 50.0"
$ns_ at 0.01 "$node_(64) setdest 1457 199 50.0"
$ns_ at 0.01 "$node_(65) setdest 1561 199 50.0"
$ns_ at 0.01 "$node_(66) setdest 1665 199 50.0"
$ns_ at 0.01 "$node_(67) setdest 1769 199 50.0"
$ns_ at 0.01 "$node_(68) setdest 1873 199 50.0"
$ns_ at 0.01 "$node_(69) setdest 1977 199 50.0"
$ns_ at 0.01 "$node_(70) setdest 1 298 50.0"
$ns_ at 0.01 "$node_(71) setdest 105 298 50.0"
$ns_ at 0.01 "$node_(72) setdest 209 298 50.0"
$ns_ at 0.01 "$node_(73) setdest 313 298 50.0"
$ns_ at 0.01 "$node_(74) setdest 417 298 50.0"
$ns_ at 0.01 "$node_(75) setdest 521 298 50.0"
$ns_ at 0.01 "$node_(76) setdest 625 298 50.0"
$ns_ at 0.01 "$node_(77) setdest 729 298 50.0"
$ns_ at 0.01 "$node_(78) setdest 833 298 50.0"
$ns_ at 0.01 "$node_(79) setdest 937 298 50.0"
$ns_ at 0.01 "$node_(80) setdest 1041 298 50.0"
$ns_ at 0.01 "$node_(81) setdest 1145 298 50.0"
$ns_ at 0.01 "$node_(82) setdest 1249 298 50.0"
$ns_ at 0.01 "$node_(83) setdest 1353 298 50.0"
$ns_ at 0.01 "$node_(84) setdest 1457 298 50.0"
$ns_ at 0.01 "$node_(85) setdest 1561 298 50.0"
$ns_ at 0.01 "$node_(86) setdest 1665 298 50.0"
$ns_ at 0.01 "$node_(87) setdest 1769 298 50.0"
$ns_ at 0.01 "$node_(88) setdest 1873 298 50.0"
$ns_ at 0.01 "$node_(89) setdest 1977 298 50.0"
$ns_ at 0.01 "$node_(90) setdest 1 397 50.0"
$ns_ at 0.01 "$node_(91) setdest 105 397 50.0"
$ns_ at 0.01 "$node_(92) setdest 209 397 50.0"
$ns_ at 0.01 "$node_(93) setdest 313 397 50.0"
$ns_ at 0.01 "$node_(94) setdest 417 397 50.0"
$ns_ at 0.01 "$node_(95) setdest 521 397 50.0"
$ns_ at 0.01 "$node_(96) setdest 625 397 50.0"
$ns_ at 0.01 "$node_(97) setdest 729 397 50.0"
$ns_ at 0.01 "$node_(98) setdest 833 397 50.0"
$ns_ at 0.01 "$node_(99) setdest 937 397 50.0"
$ns_ at 0.01 "$node_(100) setdest 1041 397 50.0"
$ns_ at 0.01 "$node_(101) setdest 1145 397 50.0"
$ns_ at 0.01 "$node_(102) setdest 1249 397 50.0"
$ns_ at 0.01 "$node_(103) setdest 1353 397 50.0"
$ns_ at 0.01 "$node_(104) setdest 1457 397 50.0"
$ns_ at 0.01 "$node_(105) setdest 1561 397 50.0"
$ns_ at 0.01 "$node_(106) setdest 1665 397 50.0"
$ns_ at 0.01 "$node_(107) setdest 1769 397 50.0"
$ns_ at 0.01 "$node_(108) setdest 1873 397 50.0"
$ns_ at 0.01 "$node_(109) setdest 1977 397 50.0"
$ns_ at 0.01 "$node_(110) setdest 1 496 50.0"
$ns_ at 0.01 "$node_(111) setdest 105 496 50.0"
$ns_ at 0.01 "$node_(112) setdest 209 496 50.0"
$ns_ at 0.01 "$node_(113) setdest 313 496 50.0"
$ns_ at 0.01 "$node_(114) setdest 417 496 50.0"
$ns_ at 0.01 "$node_(115) setdest 521 496 50.0"
$ns_ at 0.01 "$node_(116) setdest 625 496 50.0"
$ns_ at 0.01 "$node_(117) setdest 729 496 50.0"
$ns_ at 0.01 "$node_(118) setdest 833 496 50.0"
$ns_ at 0.01 "$node_(119) setdest 937 496 50.0"
$ns_ at 0.01 "$node_(120) setdest 1041 496 50.0"
$ns_ at 0.01 "$node_(121) setdest 1145 496 50.0"
$ns_ at 0.01 "$node_(122) setdest 1249 496 50.0"
$ns_ at 0.01 "$node_(123) setdest 1353 496 50.0"
$ns_ at 0.01 "$node_(124) setdest 1457 496 50.0"
$ns_ at 0.01 "$node_(125) setdest 1561 496 50.0"
$ns_ at 0.01 "$node_(126) setdest 1665 496 50.0"
$ns_ at 0.01 "$node_(127) setdest 1769 496 50.0"
$ns_ at 0.01 "$node_(128) setdest 1873 496 50.0"
$ns_ at 0.01 "$node_(129) setdest 1977 496 50.0"
$ns_ at 0.01 "$node_(130) setdest 1 595 50.0"
$ns_ at 0.01 "$node_(131) setdest 105 595 50.0"
$ns_ at 0.01 "$node_(132) setdest 209 595 50.0"
$ns_ at 0.01 "$node_(133) setdest 313 595 50.0"
$ns_ at 0.01 "$node_(134) setdest 417 595 50.0"
$ns_ at 0.01 "$node_(135) setdest 521 595 50.0"
$ns_ at 0.01 "$node_(136) setdest 625 595 50.0"
$ns_ at 0.01 "$node_(137) setdest 729 595 50.0"
$ns_ at 0.01 "$node_(138) setdest 833 595 50.0"
$ns_ at 0.01 "$node_(139) setdest 937 595 50.0"
$ns_ at 0.01 "$node_(140) setdest 1041 595 50.0"
$ns_ at 0.01 "$node_(141) setdest 1145 595 50.0"
$ns_ at 0.01 "$node_(142) setdest 1249 595 50.0"
$ns_ at 0.01 "$node_(143) setdest 1353 595 50.0"
$ns_ at 0.01 "$node_(144) setdest 1457 595 50.0"
$ns_ at 0.01 "$node_(145) setdest 1561 595 50.0"
$ns_ at 0.01 "$node_(146) setdest 1665 595 50.0"
$ns_ at 0.01 "$node_(147) setdest 1769 595 50.0"
$ns_ at 0.01 "$node_(148) setdest 1873 595 50.0"
$ns_ at 0.01 "$node_(149) setdest 1977 595 50.0"
$ns_ at 0.01 "$node_(150) setdest 1 694 50.0"
$ns_ at 0.01 "$node_(151) setdest 105 694 50.0"
$ns_ at 0.01 "$node_(152) setdest 209 694 50.0"
$ns_ at 0.01 "$node_(153) setdest 313 694 50.0"
$ns_ at 0.01 "$node_(154) setdest 417 694 50.0"
$ns_ at 0.01 "$node_(155) setdest 521 694 50.0"
$ns_ at 0.01 "$node_(156) setdest 625 694 50.0"
$ns_ at 0.01 "$node_(157) setdest 729 694 50.0"
$ns_ at 0.01 "$node_(158) setdest 833 694 50.0"
$ns_ at 0.01 "$node_(159) setdest 937 694 50.0"
$ns_ at 0.01 "$node_(160) setdest 1041 694 50.0"
$ns_ at 0.01 "$node_(161) setdest 1145 694 50.0"
$ns_ at 0.01 "$node_(162) setdest 1249 694 50.0"
$ns_ at 0.01 "$node_(163) setdest 1353 694 50.0"
$ns_ at 0.01 "$node_(164) setdest 1457 694 50.0"
$ns_ at 0.01 "$node_(165) setdest 1561 694 50.0"
$ns_ at 0.01 "$node_(166) setdest 1665 694 50.0"
$ns_ at 0.01 "$node_(167) setdest 1769 694 50.0"
$ns_ at 0.01 "$node_(168) setdest 1873 694 50.0"
$ns_ at 0.01 "$node_(169) setdest 1977 694 50.0"
$ns_ at 0.01 "$node_(170) setdest 1 793 50.0"
$ns_ at 0.01 "$node_(171) setdest 105 793 50.0"
$ns_ at 0.01 "$node_(172) setdest 209 793 50.0"
$ns_ at 0.01 "$node_(173) setdest 313 793 50.0"
$ns_ at 0.01 "$node_(174) setdest 417 793 50.0"
$ns_ at 0.01 "$node_(175) setdest 521 793 50.0"
$ns_ at 0.01 "$node_(176) setdest 625 793 50.0"
$ns_ at 0.01 "$node_(177) setdest 729 793 50.0"
$ns_ at 0.01 "$node_(178) setdest 833 793 50.0"
$ns_ at 0.01 "$node_(179) setdest 937 793 50.0"
$ns_ at 0.01 "$node_(180) setdest 1041 793 50.0"
$ns_ at 0.01 "$node_(181) setdest 1145 793 50.0"
$ns_ at 0.01 "$node_(182) setdest 1249 793 50.0"
$ns_ at 0.01 "$node_(183) setdest 1353 793 50.0"
$ns_ at 0.01 "$node_(184) setdest 1457 793 50.0"
$ns_ at 0.01 "$node_(185) setdest 1561 793 50.0"
$ns_ at 0.01 "$node_(186) setdest 1665 793 50.0"
$ns_ at 0.01 "$node_(187) setdest 1769 793 50.0"
$ns_ at 0.01 "$node_(188) setdest 1873 793 50.0"
$ns_ at 0.01 "$node_(189) setdest 1977 793 50.0"
$ns_ at 0.01 "$node_(190) setdest 1 892 50.0"
$ns_ at 0.01 "$node_(191) setdest 105 892 50.0"
$ns_ at 0.01 "$node_(192) setdest 209 892 50.0"
$ns_ at 0.01 "$node_(193) setdest 313 892 50.0"
$ns_ at 0.01 "$node_(194) setdest 417 892 50.0"
$ns_ at 0.01 "$node_(195) setdest 521 892 50.0"
$ns_ at 0.01 "$node_(196) setdest 625 892 50.0"
$ns_ at 0.01 "$node_(197) setdest 729 892 50.0"
$ns_ at 0.01 "$node_(198) setdest 833 892 50.0"
$ns_ at 0.01 "$node_(199) setdest 937 892 50.0"
$ns_ at 0.01 "$node_(200) setdest 1041 892 50.0"
$ns_ at 0.01 "$node_(201) setdest 1145 892 50.0"
$ns_ at 0.01 "$node_(202) setdest 1249 892 50.0"
$ns_ at 0.01 "$node_(203) setdest 1353 892 50.0"
$ns_ at 0.01 "$node_(204) setdest 1457 892 50.0"
$ns_ at 0.01 "$node_(205) setdest 1561 892 50.0"
$ns_ at 0.01 "$node_(206) setdest 1665 892 50.0"
$ns_ at 0.01 "$node_(207) setdest 1769 892 50.0"
$ns_ at 0.01 "$node_(208) setdest 1873 892 50.0"
$ns_ at 0.01 "$node_(209) setdest 1977 892 50.0"
$ns_ at 0.01 "$node_(210) setdest 1 991 50.0"
$ns_ at 0.01 "$node_(211) setdest 105 991 50.0"
$ns_ at 0.01 "$node_(212) setdest 209 991 50.0"
$ns_ at 0.01 "$node_(213) setdest 313 991 50.0"
$ns_ at 0.01 "$node_(214) setdest 417 991 50.0"
$ns_ at 0.01 "$node_(215) setdest 521 991 50.0"
$ns_ at 0.01 "$node_(216) setdest 625 991 50.0"
$ns_ at 0.01 "$node_(217) setdest 729 991 50.0"
$ns_ at 0.01 "$node_(218) setdest 833 991 50.0"
$ns_ at 0.01 "$node_(219) setdest 937 991 50.0"
$ns_ at 0.01 "$node_(220) setdest 1041 991 50.0"
$ns_ at 0.01 "$node_(221) setdest 1145 991 50.0"
$ns_ at 0.01 "$node_(222) setdest 1249 991 50.0"
$ns_ at 0.01 "$node_(223) setdest 1353 991 50.0"
$ns_ at 0.01 "$node_(224) setdest 1457 991 50.0"
$ns_ at 0.01 "$node_(225) setdest 1561 991 50.0"
$ns_ at 0.01 "$node_(226) setdest 1665 991 50.0"
$ns_ at 0.01 "$node_(227) setdest 1769 991 50.0"
$ns_ at 0.01 "$node_(228) setdest 1873 991 50.0"
$ns_ at 0.01 "$node_(229) setdest 1977 991 50.0"
$ns_ at 0.01 "$node_(230) setdest 1 1090 50.0"
$ns_ at 0.01 "$node_(231) setdest 105 1090 50.0"
$ns_ at 0.01 "$node_(232) setdest 209 1090 50.0"
$ns_ at 0.01 "$node_(233) setdest 313 1090 50.0"
$ns_ at 0.01 "$node_(234) setdest 417 1090 50.0"
$ns_ at 0.01 "$node_(235) setdest 521 1090 50.0"
$ns_ at 0.01 "$node_(236) setdest 625 1090 50.0"
$ns_ at 0.01 "$node_(237) setdest 729 1090 50.0"
$ns_ at 0.01 "$node_(238) setdest 833 1090 50.0"
$ns_ at 0.01 "$node_(239) setdest 937 1090 50.0"
$ns_ at 0.01 "$node_(240) setdest 1041 1090 50.0"
$ns_ at 0.01 "$node_(241) setdest 1145 1090 50.0"
$ns_ at 0.01 "$node_(242) setdest 1249 1090 50.0"
$ns_ at 0.01 "$node_(243) setdest 1353 1090 50.0"
$ns_ at 0.01 "$node_(244) setdest 1457 1090 50.0"
$ns_ at 0.01 "$node_(245) setdest 1561 1090 50.0"
$ns_ at 0.01 "$node_(246) setdest 1665 1090 50.0"
$ns_ at 0.01 "$node_(247) setdest 1769 1090 50.0"
$ns_ at 0.01 "$node_(248) setdest 1873 1090 50.0"
$ns_ at 0.01 "$node_(249) setdest 1977 1090 50.0"
$ns_ at 0.01 "$node_(250) setdest 1 1189 50.0"
$ns_ at 0.01 "$node_(251) setdest 105 1189 50.0"
$ns_ at 0.01 "$node_(252) setdest 209 1189 50.0"
$ns_ at 0.01 "$node_(253) setdest 313 1189 50.0"
$ns_ at 0.01 "$node_(254) setdest 417 1189 50.0"
$ns_ at 0.01 "$node_(255) setdest 521 1189 50.0"
$ns_ at 0.01 "$node_(256) setdest 625 1189 50.0"
$ns_ at 0.01 "$node_(257) setdest 729 1189 50.0"
$ns_ at 0.01 "$node_(258) setdest 833 1189 50.0"
$ns_ at 0.01 "$node_(259) setdest 937 1189 50.0"
$ns_ at 0.01 "$node_(260) setdest 1041 1189 50.0"
$ns_ at 0.01 "$node_(261) setdest 1145 1189 50.0"
$ns_ at 0.01 "$node_(262) setdest 1249 1189 50.0"
$ns_ at 0.01 "$node_(263) setdest 1353 1189 50.0"
$ns_ at 0.01 "$node_(264) setdest 1457 1189 50.0"
$ns_ at 0.01 "$node_(265) setdest 1561 1189 50.0"
$ns_ at 0.01 "$node_(266) setdest 1665 1189 50.0"
$ns_ at 0.01 "$node_(267) setdest 1769 1189 50.0"
$ns_ at 0.01 "$node_(268) setdest 1873 1189 50.0"
$ns_ at 0.01 "$node_(269) setdest 1977 1189 50.0"
$ns_ at 0.01 "$node_(270) setdest 1 1288 50.0"
$ns_ at 0.01 "$node_(271) setdest 105 1288 50.0"
$ns_ at 0.01 "$node_(272) setdest 209 1288 50.0"
$ns_ at 0.01 "$node_(273) setdest 313 1288 50.0"
$ns_ at 0.01 "$node_(274) setdest 417 1288 50.0"
$ns_ at 0.01 "$node_(275) setdest 521 1288 50.0"
$ns_ at 0.01 "$node_(276) setdest 625 1288 50.0"
$ns_ at 0.01 "$node_(277) setdest 729 1288 50.0"
$ns_ at 0.01 "$node_(278) setdest 833 1288 50.0"
$ns_ at 0.01 "$node_(279) setdest 937 1288 50.0"
$ns_ at 0.01 "$node_(280) setdest 1041 1288 50.0"
$ns_ at 0.01 "$node_(281) setdest 1145 1288 50.0"
$ns_ at 0.01 "$node_(282) setdest 1249 1288 50.0"
$ns_ at 0.01 "$node_(283) setdest 1353 1288 50.0"
$ns_ at 0.01 "$node_(284) setdest 1457 1288 50.0"
$ns_ at 0.01 "$node_(285) setdest 1561 1288 50.0"
$ns_ at 0.01 "$node_(286) setdest 1665 1288 50.0"
$ns_ at 0.01 "$node_(287) setdest 1769 1288 50.0"
$ns_ at 0.01 "$node_(288) setdest 1873 1288 50.0"
$ns_ at 0.01 "$node_(289) setdest 1977 1288 50.0"
$ns_ at 0.01 "$node_(290) setdest 1 1387 50.0"
$ns_ at 0.01 "$node_(291) setdest 105 1387 50.0"
$ns_ at 0.01 "$node_(292) setdest 209 1387 50.0"
$ns_ at 0.01 "$node_(293) setdest 313 1387 50.0"
$ns_ at 0.01 "$node_(294) setdest 417 1387 50.0"
$ns_ at 0.01 "$node_(295) setdest 521 1387 50.0"
$ns_ at 0.01 "$node_(296) setdest 625 1387 50.0"
$ns_ at 0.01 "$node_(297) setdest 729 1387 50.0"
$ns_ at 0.01 "$node_(298) setdest 833 1387 50.0"
$ns_ at 0.01 "$node_(299) setdest 937 1387 50.0"
$ns_ at 0.01 "$node_(300) setdest 1041 1387 50.0"
$ns_ at 0.01 "$node_(301) setdest 1145 1387 50.0"
$ns_ at 0.01 "$node_(302) setdest 1249 1387 50.0"
$ns_ at 0.01 "$node_(303) setdest 1353 1387 50.0"
$ns_ at 0.01 "$node_(304) setdest 1457 1387 50.0"
$ns_ at 0.01 "$node_(305) setdest 1561 1387 50.0"
$ns_ at 0.01 "$node_(306) setdest 1665 1387 50.0"
$ns_ at 0.01 "$node_(307) setdest 1769 1387 50.0"
$ns_ at 0.01 "$node_(308) setdest 1873 1387 50.0"
$ns_ at 0.01 "$node_(309) setdest 1977 1387 50.0"
$ns_ at 0.01 "$node_(310) setdest 1 1486 50.0"
$ns_ at 0.01 "$node_(311) setdest 105 1486 50.0"
$ns_ at 0.01 "$node_(312) setdest 209 1486 50.0"
$ns_ at 0.01 "$node_(313) setdest 313 1486 50.0"
$ns_ at 0.01 "$node_(314) setdest 417 1486 50.0"
$ns_ at 0.01 "$node_(315) setdest 521 1486 50.0"
$ns_ at 0.01 "$node_(316) setdest 625 1486 50.0"
$ns_ at 0.01 "$node_(317) setdest 729 1486 50.0"
$ns_ at 0.01 "$node_(318) setdest 833 1486 50.0"
$ns_ at 0.01 "$node_(319) setdest 937 1486 50.0"
$ns_ at 0.01 "$node_(320) setdest 1041 1486 50.0"
$ns_ at 0.01 "$node_(321) setdest 1145 1486 50.0"
$ns_ at 0.01 "$node_(322) setdest 1249 1486 50.0"
$ns_ at 0.01 "$node_(323) setdest 1353 1486 50.0"
$ns_ at 0.01 "$node_(324) setdest 1457 1486 50.0"
$ns_ at 0.01 "$node_(325) setdest 1561 1486 50.0"
$ns_ at 0.01 "$node_(326) setdest 1665 1486 50.0"
$ns_ at 0.01 "$node_(327) setdest 1769 1486 50.0"
$ns_ at 0.01 "$node_(328) setdest 1873 1486 50.0"
$ns_ at 0.01 "$node_(329) setdest 1977 1486 50.0"
$ns_ at 0.01 "$node_(330) setdest 1 1585 50.0"
$ns_ at 0.01 "$node_(331) setdest 105 1585 50.0"
$ns_ at 0.01 "$node_(332) setdest 209 1585 50.0"
$ns_ at 0.01 "$node_(333) setdest 313 1585 50.0"
$ns_ at 0.01 "$node_(334) setdest 417 1585 50.0"
$ns_ at 0.01 "$node_(335) setdest 521 1585 50.0"
$ns_ at 0.01 "$node_(336) setdest 625 1585 50.0"
$ns_ at 0.01 "$node_(337) setdest 729 1585 50.0"
$ns_ at 0.01 "$node_(338) setdest 833 1585 50.0"
$ns_ at 0.01 "$node_(339) setdest 937 1585 50.0"
$ns_ at 0.01 "$node_(340) setdest 1041 1585 50.0"
$ns_ at 0.01 "$node_(341) setdest 1145 1585 50.0"
$ns_ at 0.01 "$node_(342) setdest 1249 1585 50.0"
$ns_ at 0.01 "$node_(343) setdest 1353 1585 50.0"
$ns_ at 0.01 "$node_(344) setdest 1457 1585 50.0"
$ns_ at 0.01 "$node_(345) setdest 1561 1585 50.0"
$ns_ at 0.01 "$node_(346) setdest 1665 1585 50.0"
$ns_ at 0.01 "$node_(347) setdest 1769 1585 50.0"
$ns_ at 0.01 "$node_(348) setdest 1873 1585 50.0"
$ns_ at 0.01 "$node_(349) setdest 1977 1585 50.0"
$ns_ at 0.01 "$node_(350) setdest 1 1684 50.0"
$ns_ at 0.01 "$node_(351) setdest 105 1684 50.0"
$ns_ at 0.01 "$node_(352) setdest 209 1684 50.0"
$ns_ at 0.01 "$node_(353) setdest 313 1684 50.0"
$ns_ at 0.01 "$node_(354) setdest 417 1684 50.0"
$ns_ at 0.01 "$node_(355) setdest 521 1684 50.0"
$ns_ at 0.01 "$node_(356) setdest 625 1684 50.0"
$ns_ at 0.01 "$node_(357) setdest 729 1684 50.0"
$ns_ at 0.01 "$node_(358) setdest 833 1684 50.0"
$ns_ at 0.01 "$node_(359) setdest 937 1684 50.0"
$ns_ at 0.01 "$node_(360) setdest 1041 1684 50.0"
$ns_ at 0.01 "$node_(361) setdest 1145 1684 50.0"
$ns_ at 0.01 "$node_(362) setdest 1249 1684 50.0"
$ns_ at 0.01 "$node_(363) setdest 1353 1684 50.0"
$ns_ at 0.01 "$node_(364) setdest 1457 1684 50.0"
$ns_ at 0.01 "$node_(365) setdest 1561 1684 50.0"
$ns_ at 0.01 "$node_(366) setdest 1665 1684 50.0"
$ns_ at 0.01 "$node_(367) setdest 1769 1684 50.0"
$ns_ at 0.01 "$node_(368) setdest 1873 1684 50.0"
$ns_ at 0.01 "$node_(369) setdest 1977 1684 50.0"
$ns_ at 0.01 "$node_(370) setdest 1 1783 50.0"
$ns_ at 0.01 "$node_(371) setdest 105 1783 50.0"
$ns_ at 0.01 "$node_(372) setdest 209 1783 50.0"
$ns_ at 0.01 "$node_(373) setdest 313 1783 50.0"
$ns_ at 0.01 "$node_(374) setdest 417 1783 50.0"
$ns_ at 0.01 "$node_(375) setdest 521 1783 50.0"
$ns_ at 0.01 "$node_(376) setdest 625 1783 50.0"
$ns_ at 0.01 "$node_(377) setdest 729 1783 50.0"
$ns_ at 0.01 "$node_(378) setdest 833 1783 50.0"
$ns_ at 0.01 "$node_(379) setdest 937 1783 50.0"
$ns_ at 0.01 "$node_(380) setdest 1041 1783 50.0"
$ns_ at 0.01 "$node_(381) setdest 1145 1783 50.0"
$ns_ at 0.01 "$node_(382) setdest 1249 1783 50.0"
$ns_ at 0.01 "$node_(383) setdest 1353 1783 50.0"
$ns_ at 0.01 "$node_(384) setdest 1457 1783 50.0"
$ns_ at 0.01 "$node_(385) setdest 1561 1783 50.0"
$ns_ at 0.01 "$node_(386) setdest 1665 1783 50.0"
$ns_ at 0.01 "$node_(387) setdest 1769 1783 50.0"
$ns_ at 0.01 "$node_(388) setdest 1873 1783 50.0"
$ns_ at 0.01 "$node_(389) setdest 1977 1783 50.0"
$ns_ at 0.01 "$node_(390) setdest 1 1882 50.0"
$ns_ at 0.01 "$node_(391) setdest 105 1882 50.0"
$ns_ at 0.01 "$node_(392) setdest 209 1882 50.0"
$ns_ at 0.01 "$node_(393) setdest 313 1882 50.0"
$ns_ at 0.01 "$node_(394) setdest 417 1882 50.0"
$ns_ at 0.01 "$node_(395) setdest 521 1882 50.0"
$ns_ at 0.01 "$node_(396) setdest 625 1882 50.0"
$ns_ at 0.01 "$node_(397) setdest 729 1882 50.0"
$ns_ at 0.01 "$node_(398) setdest 833 1882 50.0"
$ns_ at 0.01 "$node_(399) setdest 937 1882 50.0"
$ns_ at 0.01 "$node_(400) setdest 1041 1882 50.0"
$ns_ at 0.01 "$node_(401) setdest 1145 1882 50.0"
$ns_ at 0.01 "$node_(402) setdest 1249 1882 50.0"
$ns_ at 0.01 "$node_(403) setdest 1353 1882 50.0"
$ns_ at 0.01 "$node_(404) setdest 1457 1882 50.0"
$ns_ at 0.01 "$node_(405) setdest 1561 1882 50.0"
$ns_ at 0.01 "$node_(406) setdest 1665 1882 50.0"
$ns_ at 0.01 "$node_(407) setdest 1769 1882 50.0"
$ns_ at 0.01 "$node_(408) setdest 1873 1882 50.0"
$ns_ at 0.01 "$node_(409) setdest 1977 1882 50.0"
$ns_ at 0.01 "$node_(410) setdest 1 1981 50.0"

$node_(0) set X_ 1780.000000
$node_(0) set Y_ 536.000000
$node_(0) set Z_ 0.000000
$node_(1) set X_ 948.000000
$node_(1) set Y_ 1616.000000
$node_(1) set Z_ 0.000000
$node_(2) set X_ 1688.000000
$node_(2) set Y_ 408.000000
$node_(2) set Z_ 0.000000
$node_(3) set X_ 424.000000
$node_(3) set Y_ 1420.000000
$node_(3) set Z_ 0.000000
$node_(4) set X_ 1964.000000
$node_(4) set Y_ 1440.000000
$node_(4) set Z_ 0.000000
$node_(5) set X_ 1616.000000
$node_(5) set Y_ 1920.000000
$node_(5) set Z_ 0.000000
$node_(6) set X_ 568.000000
$node_(6) set Y_ 1840.000000
$node_(6) set Z_ 0.000000
$node_(7) set X_ 1524.000000
$node_(7) set Y_ 1328.000000
$node_(7) set Z_ 0.000000
$node_(8) set X_ 1716.000000
$node_(8) set Y_ 1592.000000
$node_(8) set Z_ 0.000000
$node_(9) set X_ 144.000000
$node_(9) set Y_ 1060.000000
$node_(9) set Z_ 0.000000
$ns_ at 0.000000 "$node_(0) setdest 1560.327881 936.000000 1000.000000"
$ns_ at 0.000000 "$node_(1) setdest 1252.000000 1264.000000 1000.000000"
$ns_ at 0.000000 "$node_(2) setdest 1482.422363 808.000000 1000.000000"
$ns_ at 0.000000 "$node_(3) setdest 824.000000 1365.454590 1000.000000"
$ns_ at 0.000000 "$node_(4) setdest 1564.000000 1371.372559 1000.000000"
$ns_ at 0.000000 "$node_(5) setdest 1364.837158 1520.000000 1000.000000"
$ns_ at 0.000000 "$node_(6) setdest 968.000000 1519.120850 1000.000000"
$ns_ at 0.000000 "$node_(7) setdest 1304.000000 1080.000000 1000.000000"
$ns_ at 0.000000 "$node_(8) setdest 1316.000000 1365.913086 1000.000000"
$ns_ at 0.000000 "$node_(9) setdest 544.000000 1150.540527 1000.000000"
$ns_ at 0.066667 "$node_(0) setdest 1256.655762 1268.000000 1000.000000"
$ns_ at 0.066667 "$node_(1) setdest 1044.000000 1264.000000 779.999959"
$ns_ at 0.066667 "$node_(2) setdest 1188.844604 1156.000000 1000.000000"
$ns_ at 0.066667 "$node_(3) setdest 1052.000000 994.909119 1000.000000"
$ns_ at 0.066667 "$node_(4) setdest 1396.000000 998.745117 1000.000000"
$ns_ at 0.066667 "$node_(5) setdest 1257.674438 1316.000000 864.127591"
$ns_ at 0.066667 "$node_(6) setdest 1180.000000 1154.241699 1000.000000"
$ns_ at 0.066667 "$node_(7) setdest 1404.000000 936.000000 657.438149"
$ns_ at 0.066667 "$node_(8) setdest 1344.000000 1307.826050 241.812588"
$ns_ at 0.066667 "$node_(9) setdest 944.000000 1152.026245 1000.000000"
$ns_ at 0.133333 "$node_(0) setdest 1280.983643 1152.000000 444.463497"
$ns_ at 0.133333 "$node_(1) setdest 1052.000000 1380.000000 436.033236"
$ns_ at 0.133333 "$node_(2) setdest 1055.266968 884.000000 1000.000000"
$ns_ at 0.133333 "$node_(3) setdest 1164.000000 912.363647 521.745559"
$ns_ at 0.133333 "$node_(4) setdest 1296.000000 1030.117676 393.021391"
$ns_ at 0.133333 "$node_(5) setdest 1170.511597 1400.000000 453.941493"
$ns_ at 0.133333 "$node_(6) setdest 792.000000 1077.362671 1000.000000"
$ns_ at 0.133333 "$node_(7) setdest 1276.000000 1004.000000 543.530073"
$ns_ at 0.133333 "$node_(8) setdest 1416.000000 1117.739136 762.247141"
$ns_ at 0.133333 "$node_(9) setdest 1328.000000 1133.511963 1000.000000"
$ns_ at 0.200000 "$node_(0) setdest 953.311462 1388.000000 1000.000000"
$ns_ at 0.200000 "$node_(1) setdest 1156.000000 992.000000 1000.000000"
$ns_ at 0.200000 "$node_(2) setdest 973.689270 972.000000 449.983125"
$ns_ at 0.200000 "$node_(3) setdest 1104.000000 737.818176 692.137835"
$ns_ at 0.200000 "$node_(4) setdest 1164.000000 937.490173 604.714133"
$ns_ at 0.200000 "$node_(5) setdest 1163.348877 1020.000000 1000.000000"
$ns_ at 0.200000 "$node_(6) setdest 1060.000000 1168.483521 1000.000000"
$ns_ at 0.200000 "$node_(7) setdest 1312.000000 884.000000 469.813761"
$ns_ at 0.200000 "$node_(8) setdest 1216.000000 1067.652222 773.161371"
$ns_ at 0.200000 "$node_(9) setdest 1672.792236 1533.511963 1000.000000"
$ns_ at 0.266667 "$node_(0) setdest 1216.480835 988.000000 1000.000000"
$ns_ at 0.266667 "$node_(1) setdest 1124.000000 852.000000 538.539649"
$ns_ at 0.266667 "$node_(2) setdest 824.111572 1016.000000 584.681252"
$ns_ at 0.266667 "$node_(3) setdest 1104.000000 767.272705 110.454477"
$ns_ at 0.266667 "$node_(4) setdest 1144.000000 952.862732 94.594855"
$ns_ at 0.266667 "$node_(5) setdest 1184.186035 972.000000 196.228828"
$ns_ at 0.266667 "$node_(6) setdest 1000.000000 1107.604370 320.537722"
$ns_ at 0.266667 "$node_(7) setdest 1280.000000 968.000000 337.083046"
$ns_ at 0.266667 "$node_(8) setdest 1196.000000 1321.565186 955.122764"
$ns_ at 0.266667 "$node_(9) setdest 1276.008423 1133.511963 1000.000000"
$ns_ at 0.333333 "$node_(0) setdest 1039.650269 908.000000 727.819309"
$ns_ at 0.333333 "$node_(1) setdest 1180.000000 912.000000 307.774242"
$ns_ at 0.333333 "$node_(2) setdest 1132.677490 936.478394 1000.000000"
$ns_ at 0.333333 "$node_(3) setdest 1021.589600 367.272736 1000.000000"
$ns_ at 0.333333 "$node_(4) setdest 1048.000000 696.235291 1000.000000"
$ns_ at 0.333333 "$node_(5) setdest 901.023254 792.000000 1000.000000"
$ns_ at 0.333333 "$node_(6) setdest 752.000000 1502.725220 1000.000000"
$ns_ at 0.333333 "$node_(7) setdest 1328.000000 860.000000 443.198581"
$ns_ at 0.333333 "$node_(8) setdest 1008.000000 1067.478271 1000.000000"
$ns_ at 0.333333 "$node_(9) setdest 1255.224731 1165.511963 143.088991"
$ns_ at 0.400000 "$node_(0) setdest 810.819702 648.000000 1000.000000"
$ns_ at 0.400000 "$node_(1) setdest 1192.000000 644.000000 1000.000000"
$ns_ at 0.400000 "$node_(2) setdest 1077.243530 704.956787 892.745544"
$ns_ at 0.400000 "$node_(3) setdest 1005.466980 767.272705 1000.000000"
$ns_ at 0.400000 "$node_(4) setdest 856.000000 927.607849 1000.000000"
$ns_ at 0.400000 "$node_(5) setdest 753.860474 960.000000 837.526030"
$ns_ at 0.400000 "$node_(6) setdest 903.623962 1102.725220 1000.000000"
$ns_ at 0.400000 "$node_(7) setdest 960.000000 836.000000 1000.000000"
$ns_ at 0.400000 "$node_(8) setdest 1272.000000 941.391296 1000.000000"
$ns_ at 0.400000 "$node_(9) setdest 974.440979 797.511963 1000.000000"
$ns_ at 0.466667 "$node_(0) setdest 613.989075 444.000000 1000.000000"
$ns_ at 0.466667 "$node_(1) setdest 1164.000000 600.000000 195.576057"
$ns_ at 0.466667 "$node_(2) setdest 1173.809570 485.435181 899.333564"
$ns_ at 0.466667 "$node_(3) setdest 1113.344360 443.272736 1000.000000"
$ns_ at 0.466667 "$node_(4) setdest 648.000000 746.980408 1000.000000"
$ns_ at 0.466667 "$node_(5) setdest 770.697693 564.000000 1000.000000"
$ns_ at 0.466667 "$node_(6) setdest 875.247986 750.725281 1000.000000"
$ns_ at 0.466667 "$node_(7) setdest 992.000000 864.000000 159.452182"
$ns_ at 0.466667 "$node_(8) setdest 872.000000 755.727356 1000.000000"
$ns_ at 0.466667 "$node_(9) setdest 1097.657227 793.511963 462.304320"
$ns_ at 0.533333 "$node_(0) setdest 933.158447 476.000000 1000.000000"
$ns_ at 0.533333 "$node_(1) setdest 860.000000 444.000000 1000.000000"
$ns_ at 0.533333 "$node_(2) setdest 902.375549 513.913574 1000.000000"
$ns_ at 0.533333 "$node_(3) setdest 849.221741 487.272736 1000.000000"
$ns_ at 0.533333 "$node_(4) setdest 928.000000 446.352936 1000.000000"
$ns_ at 0.533333 "$node_(5) setdest 370.697662 512.649048 1000.000000"
$ns_ at 0.533333 "$node_(6) setdest 775.865784 350.725281 1000.000000"
$ns_ at 0.533333 "$node_(7) setdest 884.000000 588.000000 1000.000000"
$ns_ at 0.533333 "$node_(8) setdest 912.000000 614.063477 552.010374"
$ns_ at 0.533333 "$node_(9) setdest 1036.873413 597.511963 769.533136"
$ns_ at 0.600000 "$node_(0) setdest 972.327881 224.000000 956.347339"
$ns_ at 0.600000 "$node_(1) setdest 554.339600 44.000000 1000.000000"
$ns_ at 0.600000 "$node_(2) setdest 782.941528 414.391998 582.989643"
$ns_ at 0.600000 "$node_(3) setdest 553.099121 311.272736 1000.000000"
$ns_ at 0.600000 "$node_(4) setdest 920.000000 193.725494 947.827728"
$ns_ at 0.600000 "$node_(5) setdest 747.252991 384.434418 1000.000000"
$ns_ at 0.600000 "$node_(6) setdest 448.483551 586.725281 1000.000000"
$ns_ at 0.600000 "$node_(7) setdest 604.000000 360.000000 1000.000000"
$ns_ at 0.600000 "$node_(8) setdest 868.000000 548.399536 296.410230"
$ns_ at 0.600000 "$node_(9) setdest 904.089722 405.511932 875.410263"
$ns_ at 0.666667 "$node_(0) setdest 827.497253 52.000000 843.207392"
$ns_ at 0.666667 "$node_(1) setdest 664.679260 248.000000 869.731934"
$ns_ at 0.666667 "$node_(2) setdest 743.507568 306.870392 429.468018"
$ns_ at 0.666667 "$node_(3) setdest 304.976532 135.272720 1000.000000"
$ns_ at 0.666667 "$node_(4) setdest 768.000000 25.098040 851.334356"
$ns_ at 0.666667 "$node_(5) setdest 523.808350 164.219772 1000.000000"
$ns_ at 0.666667 "$node_(6) setdest 647.281677 186.725281 1000.000000"
$ns_ at 0.666667 "$node_(7) setdest 556.000000 484.000000 498.623059"
$ns_ at 0.666667 "$node_(8) setdest 572.000000 302.735596 1000.000000"
$ns_ at 0.666667 "$node_(9) setdest 611.305969 189.511932 1000.000000"
$ns_ at 0.733333 "$node_(0) setdest 666.666687 0.000100 702.386762"
$ns_ at 0.733333 "$node_(1) setdest 643.018860 100.000000 560.912389"
$ns_ at 0.733333 "$node_(2) setdest 492.073547 59.348778 1000.000000"
$ns_ at 0.733333 "$node_(3) setdest 372.853943 151.272720 261.516252"
$ns_ at 0.733333 "$node_(4) setdest 772.000000 0.000100 962.469814"
$ns_ at 0.733333 "$node_(5) setdest 708.363708 196.005142 702.271864"
$ns_ at 0.733333 "$node_(6) setdest 742.079712 190.725281 355.808926"
$ns_ at 0.733333 "$node_(7) setdest 514.974365 84.000000 1000.000000"
$ns_ at 0.733333 "$node_(8) setdest 684.000000 337.071686 439.293972"
$ns_ at 0.733333 "$node_(9) setdest 482.522217 293.511932 620.749651"
$ns_ at 0.800000 "$node_(0) setdest 749.836060 0.000100 346.081391"
$ns_ at 0.800000 "$node_(1) setdest 933.358521 0.000100 1000.000000"
$ns_ at 0.800000 "$node_(2) setdest 724.639526 0.000100 980.553995"
$ns_ at 0.800000 "$node_(3) setdest 364.731323 0.000100 750.618228"
$ns_ at 0.800000 "$node_(4) setdest 464.000000 0.000100 1000.000000"
$ns_ at 0.800000 "$node_(5) setdest 564.919067 19.790499 852.067006"
$ns_ at 0.800000 "$node_(6) setdest 582.887085 32.637321 841.322264"
$ns_ at 0.800000 "$node_(7) setdest 485.948730 180.000000 376.095008"
$ns_ at 0.800000 "$node_(8) setdest 768.000000 155.407761 750.541495"
$ns_ at 0.800000 "$node_(9) setdest 613.738464 109.511932 847.480901"
$ns_ at 0.866667 "$node_(0) setdest 973.005493 0.000100 1000.000000"
$ns_ at 0.866667 "$node_(1) setdest 583.698120 0.000100 1000.000000"
$ns_ at 0.866667 "$node_(2) setdest 1124.639526 0.000100 1000.000000"
$ns_ at 0.866667 "$node_(3) setdest 672.608704 0.000100 1000.000000"
$ns_ at 0.866667 "$node_(4) setdest 692.000000 0.000100 873.260205"
$ns_ at 0.866667 "$node_(5) setdest 421.474396 0.000100 631.495939"
$ns_ at 0.866667 "$node_(6) setdest 507.694427 0.000100 330.724365"
$ns_ at 0.866667 "$node_(7) setdest 532.923096 0.000100 858.271592"
$ns_ at 0.866667 "$node_(8) setdest 776.000000 0.000100 726.859036"
$ns_ at 0.866667 "$node_(9) setdest 622.977051 509.511932 1000.000000"
$ns_ at 0.933333 "$node_(0) setdest 712.174866 0.000100 1000.000000"
$ns_ at 0.933333 "$node_(1) setdest 582.037720 0.000100 75.258017"
$ns_ at 0.933333 "$node_(2) setdest 724.639526 0.000100 1000.000000"
$ns_ at 0.933333 "$node_(3) setdest 744.486145 0.000100 603.532931"
$ns_ at 0.933333 "$node_(4) setdest 1004.000000 0.000100 1000.000000"
$ns_ at 0.933333 "$node_(5) setdest 534.029724 0.000100 423.090970"
$ns_ at 0.933333 "$node_(6) setdest 764.501770 0.000100 963.054149"
$ns_ at 0.933333 "$node_(7) setdest 351.897430 0.000100 679.011920"
$ns_ at 0.933333 "$node_(8) setdest 876.000000 0.000100 448.618989"
$ns_ at 0.933333 "$node_(9) setdest 709.626526 109.511932 1000.000000"
$ns_ at 1.000000 "$node_(0) setdest 819.344238 100.000000 549.669599"
$ns_ at 1.000000 "$node_(1) setdest 336.377350 0.000100 927.190885"
$ns_ at 1.000000 "$node_(2) setdest 652.639526 0.000100 277.859788"
$ns_ at 1.000000 "$node_(3) setdest 700.363525 11.272727 870.862725"
$ns_ at 1.000000 "$node_(4) setdest 776.000000 0.000100 972.145678"
$ns_ at 1.000000 "$node_(5) setdest 754.585083 0.000100 1000.000000"
$ns_ at 1.000000 "$node_(6) setdest 733.309143 166.373459 677.346690"
$ns_ at 1.000000 "$node_(7) setdest 751.897461 0.000100 1000.000000"
$ns_ at 1.000000 "$node_(8) setdest 1080.000000 0.000100 813.346954"
$ns_ at 1.000000 "$node_(9) setdest 540.275940 189.511932 702.358266"
$ns_ at 1.066667 "$node_(0) setdest 794.513672 0.000100 386.387509"
$ns_ at 1.066667 "$node_(1) setdest 736.377380 59.729675 1000.000000"
$ns_ at 1.066667 "$node_(2) setdest 620.639526 214.642334 824.400916"
$ns_ at 1.066667 "$node_(3) setdest 536.240906 43.272728 627.049223"
$ns_ at 1.066667 "$node_(4) setdest 772.000000 0.000100 357.961445"
$ns_ at 1.066667 "$node_(5) setdest 687.140442 0.000100 678.125060"
$ns_ at 1.066667 "$node_(6) setdest 758.116516 456.285492 1000.000000"
$ns_ at 1.066667 "$node_(7) setdest 639.897461 14.290991 435.937134"
$ns_ at 1.066667 "$node_(8) setdest 680.000000 91.372917 1000.000000"
$ns_ at 1.066667 "$node_(9) setdest 762.925354 53.511932 978.374583"
$ns_ at 1.133333 "$node_(0) setdest 981.683044 96.000000 788.823640"
$ns_ at 1.133333 "$node_(1) setdest 792.377380 251.459351 749.026870"
$ns_ at 1.133333 "$node_(2) setdest 400.639526 596.141174 1000.000000"
$ns_ at 1.133333 "$node_(3) setdest 616.118286 235.272720 779.823205"
$ns_ at 1.133333 "$node_(4) setdest 908.000000 0.000100 532.270060"
$ns_ at 1.133333 "$node_(5) setdest 691.695740 42.717308 419.542987"
$ns_ at 1.133333 "$node_(6) setdest 674.923828 142.197556 1000.000000"
$ns_ at 1.133333 "$node_(7) setdest 539.897461 49.436485 397.485932"
$ns_ at 1.133333 "$node_(8) setdest 588.000000 0.000100 728.308716"
$ns_ at 1.133333 "$node_(9) setdest 957.574829 45.511932 730.551701"
$ns_ at 1.200000 "$node_(0) setdest 702.681519 186.233780 1000.000000"
$ns_ at 1.200000 "$node_(1) setdest 1100.377319 359.189026 1000.000000"
$ns_ at 1.200000 "$node_(2) setdest 719.652100 196.141159 1000.000000"
$ns_ at 1.200000 "$node_(3) setdest 411.995697 543.272705 1000.000000"
$ns_ at 1.200000 "$node_(4) setdest 652.000000 84.078430 1000.000000"
$ns_ at 1.200000 "$node_(5) setdest 892.251099 182.502670 916.738024"
$ns_ at 1.200000 "$node_(6) setdest 695.731201 196.109604 216.705082"
$ns_ at 1.200000 "$node_(7) setdest 759.897461 200.581985 1000.000000"
$ns_ at 1.200000 "$node_(8) setdest 692.000000 69.286789 681.264289"
$ns_ at 1.200000 "$node_(9) setdest 884.224243 53.511932 276.695838"
$ns_ at 1.266667 "$node_(0) setdest 587.680054 496.467560 1000.000000"
$ns_ at 1.266667 "$node_(1) setdest 720.377380 266.918701 1000.000000"
$ns_ at 1.266667 "$node_(2) setdest 679.122925 596.141174 1000.000000"
$ns_ at 1.266667 "$node_(3) setdest 675.873108 271.272736 1000.000000"
$ns_ at 1.266667 "$node_(4) setdest 598.218506 0.000100 1000.000000"
$ns_ at 1.266667 "$node_(5) setdest 756.806458 278.288025 622.094160"
$ns_ at 1.266667 "$node_(6) setdest 480.538544 322.021637 934.959420"
$ns_ at 1.266667 "$node_(7) setdest 835.897461 335.727478 581.435078"
$ns_ at 1.266667 "$node_(8) setdest 596.000000 306.243713 958.743618"
$ns_ at 1.266667 "$node_(9) setdest 786.873657 305.511932 1000.000000"
$ns_ at 1.333333 "$node_(0) setdest 501.161682 896.467529 1000.000000"
$ns_ at 1.333333 "$node_(1) setdest 684.377380 314.648376 224.189832"
$ns_ at 1.333333 "$node_(2) setdest 590.593750 324.141174 1000.000000"
$ns_ at 1.333333 "$node_(3) setdest 435.750488 311.272736 912.867918"
$ns_ at 1.333333 "$node_(4) setdest 597.230713 157.500748 1000.000000"
$ns_ at 1.333333 "$node_(5) setdest 789.361755 302.073395 151.194827"
$ns_ at 1.333333 "$node_(6) setdest 285.345886 563.933716 1000.000000"
$ns_ at 1.333333 "$node_(7) setdest 759.897461 430.872986 456.648793"
$ns_ at 1.333333 "$node_(8) setdest 196.000000 348.814972 1000.000000"
$ns_ at 1.333333 "$node_(9) setdest 881.523132 349.511932 391.413096"
$ns_ at 1.400000 "$node_(0) setdest 482.078339 496.467560 1000.000000"
$ns_ at 1.400000 "$node_(1) setdest 336.377350 642.378052 1000.000000"
$ns_ at 1.400000 "$node_(2) setdest 570.064514 552.141174 858.458818"
$ns_ at 1.400000 "$node_(3) setdest 498.660889 516.124023 803.601166"
$ns_ at 1.400000 "$node_(4) setdest 464.242920 501.500732 1000.000000"
$ns_ at 1.400000 "$node_(5) setdest 389.361786 460.636902 1000.000000"
$ns_ at 1.400000 "$node_(6) setdest 0.000100 629.845764 1000.000000"
$ns_ at 1.400000 "$node_(7) setdest 451.897430 506.018463 1000.000000"
$ns_ at 1.400000 "$node_(8) setdest 352.000000 407.386230 624.874101"
$ns_ at 1.400000 "$node_(9) setdest 481.523132 496.445160 1000.000000"
$ns_ at 1.466667 "$node_(0) setdest 526.994995 588.467529 383.921966"
$ns_ at 1.466667 "$node_(1) setdest 0.000100 988.797241 1000.000000"
$ns_ at 1.466667 "$node_(2) setdest 809.535339 872.141174 1000.000000"
$ns_ at 1.466667 "$node_(3) setdest 529.571289 768.975342 955.251224"
$ns_ at 1.466667 "$node_(4) setdest 347.255157 669.500732 767.698648"
$ns_ at 1.466667 "$node_(5) setdest 9.361782 491.200439 1000.000000"
$ns_ at 1.466667 "$node_(6) setdest 283.942688 635.699219 1000.000000"
$ns_ at 1.466667 "$node_(7) setdest 407.897430 545.163940 220.848201"
$ns_ at 1.466667 "$node_(8) setdest 0.000100 285.617371 1000.000000"
$ns_ at 1.466667 "$node_(9) setdest 613.523132 187.378418 1000.000000"
$ns_ at 1.533333 "$node_(0) setdest 567.911621 652.467529 284.856133"
$ns_ at 1.533333 "$node_(1) setdest 336.377350 642.889099 1000.000000"
$ns_ at 1.533333 "$node_(2) setdest 409.535339 709.022644 1000.000000"
$ns_ at 1.533333 "$node_(3) setdest 452.481750 745.826660 301.837905"
$ns_ at 1.533333 "$node_(4) setdest 214.267380 621.500732 530.194102"
$ns_ at 1.533333 "$node_(5) setdest 369.361786 701.763916 1000.000000"
$ns_ at 1.533333 "$node_(6) setdest 0.000100 557.886169 1000.000000"
$ns_ at 1.533333 "$node_(7) setdest 243.897430 172.309464 1000.000000"
$ns_ at 1.533333 "$node_(8) setdest 318.333313 685.617371 1000.000000"
$ns_ at 1.533333 "$node_(9) setdest 366.496552 587.378418 1000.000000"
$ns_ at 1.600000 "$node_(0) setdest 740.828247 408.467560 1000.000000"
$ns_ at 1.600000 "$node_(1) setdest 24.377359 436.980988 1000.000000"
$ns_ at 1.600000 "$node_(2) setdest 461.535339 729.904175 210.135158"
$ns_ at 1.600000 "$node_(3) setdest 591.392151 858.677979 671.150630"
$ns_ at 1.600000 "$node_(4) setdest 301.101135 618.255005 325.853960"
$ns_ at 1.600000 "$node_(5) setdest 377.361786 792.327454 340.935699"
$ns_ at 1.600000 "$node_(6) setdest 239.942688 740.073059 1000.000000"
$ns_ at 1.600000 "$node_(7) setdest 302.007477 572.309448 1000.000000"
$ns_ at 1.600000 "$node_(8) setdest 264.666626 681.617371 201.808294"
$ns_ at 1.600000 "$node_(9) setdest 675.469971 311.378418 1000.000000"
$ns_ at 1.666667 "$node_(0) setdest 497.744934 764.467529 1000.000000"
$ns_ at 1.666667 "$node_(1) setdest 424.377350 605.706238 1000.000000"
$ns_ at 1.666667 "$node_(2) setdest 477.535339 614.785645 435.844151"
$ns_ at 1.666667 "$node_(3) setdest 492.071594 656.328186 845.290331"
$ns_ at 1.666667 "$node_(4) setdest 0.000100 219.864899 1000.000000"
$ns_ at 1.666667 "$node_(5) setdest 357.792450 1192.327515 1000.000000"
$ns_ at 1.666667 "$node_(6) setdest 195.942688 954.259949 819.973483"
$ns_ at 1.666667 "$node_(7) setdest 0.000100 177.454773 1000.000000"
$ns_ at 1.666667 "$node_(8) setdest 350.999939 689.617371 325.136902"
$ns_ at 1.666667 "$node_(9) setdest 424.443420 683.378418 1000.000000"
$ns_ at 1.733333 "$node_(0) setdest 529.846375 1164.467529 1000.000000"
$ns_ at 1.733333 "$node_(1) setdest 116.377357 466.431519 1000.000000"
$ns_ at 1.733333 "$node_(2) setdest 361.535339 531.667175 535.143214"
$ns_ at 1.733333 "$node_(3) setdest 540.750977 785.978455 519.329254"
$ns_ at 1.733333 "$node_(4) setdest 171.668289 619.864929 1000.000000"
$ns_ at 1.733333 "$node_(5) setdest 135.560532 792.327454 1000.000000"
$ns_ at 1.733333 "$node_(6) setdest 231.942688 648.446838 1000.000000"
$ns_ at 1.733333 "$node_(7) setdest 153.487946 577.454773 1000.000000"
$ns_ at 1.733333 "$node_(8) setdest 421.333221 985.617371 1000.000000"
$ns_ at 1.733333 "$node_(9) setdest 365.416840 747.378418 326.489908"
$ns_ at 1.800000 "$node_(0) setdest 298.746765 764.467529 1000.000000"
$ns_ at 1.800000 "$node_(1) setdest 316.377350 747.156799 1000.000000"
$ns_ at 1.800000 "$node_(2) setdest 625.535339 640.548645 1000.000000"
$ns_ at 1.800000 "$node_(3) setdest 389.430420 603.628662 888.594543"
$ns_ at 1.800000 "$node_(4) setdest 154.235428 487.864899 499.298260"
$ns_ at 1.800000 "$node_(5) setdest 85.328606 1024.327515 890.159236"
$ns_ at 1.800000 "$node_(6) setdest 239.942688 1018.633789 1000.000000"
$ns_ at 1.800000 "$node_(7) setdest 0.000100 525.454773 661.349739"
$ns_ at 1.800000 "$node_(8) setdest 467.666534 725.617371 990.360552"
$ns_ at 1.800000 "$node_(9) setdest 294.390259 955.378418 824.222102"
$ns_ at 1.866667 "$node_(0) setdest 23.647148 1024.467529 1000.000000"
$ns_ at 1.866667 "$node_(1) setdest 28.377359 899.882019 1000.000000"
$ns_ at 1.866667 "$node_(2) setdest 369.535339 685.430176 974.641864"
$ns_ at 1.866667 "$node_(3) setdest 206.109833 681.278870 746.579608"
$ns_ at 1.866667 "$node_(4) setdest 456.802582 771.864929 1000.000000"
$ns_ at 1.866667 "$node_(5) setdest 207.096680 720.327454 1000.000000"
$ns_ at 1.866667 "$node_(6) setdest 279.942688 700.820679 1000.000000"
$ns_ at 1.866667 "$node_(7) setdest 316.448914 797.454773 1000.000000"
$ns_ at 1.866667 "$node_(8) setdest 601.999878 705.617371 509.302513"
$ns_ at 1.866667 "$node_(9) setdest 283.363678 727.378418 855.999253"
$ns_ at 1.933333 "$node_(0) setdest 324.547546 740.467529 1000.000000"
$ns_ at 1.933333 "$node_(1) setdest 324.377350 768.607300 1000.000000"
$ns_ at 1.933333 "$node_(2) setdest 614.189209 626.937012 943.309201"
$ns_ at 1.933333 "$node_(3) setdest 0.000100 441.709290 1000.000000"
$ns_ at 1.933333 "$node_(4) setdest 726.690796 905.874207 1000.000000"
$ns_ at 1.933333 "$node_(5) setdest 0.000100 706.157776 1000.000000"
$ns_ at 1.933333 "$node_(6) setdest 139.942688 607.007568 631.971212"
$ns_ at 1.933333 "$node_(7) setdest 423.929382 1109.454834 1000.000000"
$ns_ at 1.933333 "$node_(8) setdest 220.333160 801.617371 1000.000000"
$ns_ at 1.933333 "$node_(9) setdest 392.337128 815.378418 525.257236"
$ns_ at 2.000000 "$node_(0) setdest 569.447937 804.467529 949.218243"
$ns_ at 2.000000 "$node_(1) setdest 568.377380 873.332581 995.717760"
$ns_ at 2.000000 "$node_(2) setdest 423.142883 690.112793 754.578570"
$ns_ at 2.000000 "$node_(3) setdest 206.109833 677.135254 1000.000000"
$ns_ at 2.000000 "$node_(4) setdest 391.441345 766.570251 1000.000000"
$ns_ at 2.000000 "$node_(5) setdest 222.468872 726.178162 1000.000000"
$ns_ at 2.000000 "$node_(6) setdest 195.942688 489.194489 489.169038"
$ns_ at 2.000000 "$node_(7) setdest 305.608398 709.454773 1000.000000"
$ns_ at 2.000000 "$node_(8) setdest 118.666466 1045.617432 991.250215"
$ns_ at 2.000000 "$node_(9) setdest 289.310547 799.378418 390.980881"
$ns_ at 2.066667 "$node_(0) setdest 502.348328 728.467529 380.183353"
$ns_ at 2.066667 "$node_(1) setdest 500.377350 850.057861 269.523425"
$ns_ at 2.066667 "$node_(2) setdest 308.096588 729.288513 455.750518"
$ns_ at 2.066667 "$node_(3) setdest 0.000100 716.561157 956.495483"
$ns_ at 2.066667 "$node_(4) setdest 732.191833 795.266296 1000.000000"
$ns_ at 2.066667 "$node_(5) setdest 120.321159 710.198486 387.712706"
$ns_ at 2.066667 "$node_(6) setdest 383.942688 803.381409 1000.000000"
$ns_ at 2.066667 "$node_(7) setdest 299.287384 557.454773 570.492638"
$ns_ at 2.066667 "$node_(8) setdest 365.112549 756.423340 1000.000000"
$ns_ at 2.066667 "$node_(9) setdest 390.283966 763.378418 401.996334"
$ns_ at 2.133333 "$node_(0) setdest 499.248749 696.467529 120.561613"
$ns_ at 2.133333 "$node_(1) setdest 900.377380 1037.879150 1000.000000"
$ns_ at 2.133333 "$node_(2) setdest 393.050293 772.464233 357.358942"
$ns_ at 2.133333 "$node_(3) setdest 354.109833 719.301941 1000.000000"
$ns_ at 2.133333 "$node_(4) setdest 332.191864 718.874695 1000.000000"
$ns_ at 2.133333 "$node_(5) setdest 250.173447 878.218872 796.311966"
$ns_ at 2.133333 "$node_(6) setdest 599.942688 861.568298 838.875174"
$ns_ at 2.133333 "$node_(7) setdest 80.045143 157.454773 1000.000000"
$ns_ at 2.133333 "$node_(8) setdest 503.558624 699.229309 561.730356"
$ns_ at 2.133333 "$node_(9) setdest 499.257416 751.378418 411.120622"
$ns_ at 2.200000 "$node_(0) setdest 899.248718 610.156067 1000.000000"
$ns_ at 2.200000 "$node_(1) setdest 500.377350 711.406677 1000.000000"
$ns_ at 2.200000 "$node_(2) setdest 626.003967 815.640015 888.453723"
$ns_ at 2.200000 "$node_(3) setdest 338.109833 534.042725 697.308161"
$ns_ at 2.200000 "$node_(4) setdest 336.191864 534.483093 691.631148"
$ns_ at 2.200000 "$node_(5) setdest 544.025757 686.239197 1000.000000"
$ns_ at 2.200000 "$node_(6) setdest 828.415710 1261.568237 1000.000000"
$ns_ at 2.200000 "$node_(7) setdest 393.231659 557.454773 1000.000000"
$ns_ at 2.200000 "$node_(8) setdest 594.004700 810.035339 536.374140"
$ns_ at 2.200000 "$node_(9) setdest 456.230835 947.378418 752.501582"
$ns_ at 2.266667 "$node_(0) setdest 595.248718 783.844666 1000.000000"
$ns_ at 2.266667 "$node_(1) setdest 564.377380 800.934204 412.690523"
$ns_ at 2.266667 "$node_(2) setdest 754.957642 914.815735 610.051028"
$ns_ at 2.266667 "$node_(3) setdest 681.564636 796.156677 1000.000000"
$ns_ at 2.266667 "$node_(4) setdest 692.191833 806.091431 1000.000000"
$ns_ at 2.266667 "$node_(5) setdest 441.878021 478.259583 868.913739"
$ns_ at 2.266667 "$node_(6) setdest 690.897522 861.568298 1000.000000"
$ns_ at 2.266667 "$node_(7) setdest 606.418213 817.454773 1000.000000"
$ns_ at 2.266667 "$node_(8) setdest 796.450745 616.841309 1000.000000"
$ns_ at 2.266667 "$node_(9) setdest 289.204254 1163.378418 1000.000000"
$ns_ at 2.333333 "$node_(0) setdest 455.248749 689.533203 633.013311"
$ns_ at 2.333333 "$node_(1) setdest 264.377350 778.461670 1000.000000"
$ns_ at 2.333333 "$node_(2) setdest 657.744141 853.660767 430.685383"
$ns_ at 2.333333 "$node_(3) setdest 605.019409 866.270630 389.262580"
$ns_ at 2.333333 "$node_(4) setdest 648.191833 913.699829 435.961739"
$ns_ at 2.333333 "$node_(5) setdest 677.770142 878.259583 1000.000000"
$ns_ at 2.333333 "$node_(6) setdest 853.379272 885.568298 615.917555"
$ns_ at 2.333333 "$node_(7) setdest 643.604675 777.454773 204.807433"
$ns_ at 2.333333 "$node_(8) setdest 790.896851 743.647278 475.978235"
$ns_ at 2.333333 "$node_(9) setdest 689.204285 837.500488 1000.000000"
$ns_ at 2.400000 "$node_(0) setdest 679.248718 863.221741 1000.000000"
$ns_ at 2.400000 "$node_(1) setdest 664.377380 839.450684 1000.000000"
$ns_ at 2.400000 "$node_(2) setdest 268.530670 936.505798 1000.000000"
$ns_ at 2.400000 "$node_(3) setdest 640.262451 843.061035 158.246318"
$ns_ at 2.400000 "$node_(4) setdest 482.258514 1173.043213 1000.000000"
$ns_ at 2.400000 "$node_(5) setdest 405.662292 1154.259521 1000.000000"
$ns_ at 2.400000 "$node_(6) setdest 1130.377075 1053.797729 1000.000000"
$ns_ at 2.400000 "$node_(7) setdest 400.791229 613.454773 1000.000000"
$ns_ at 2.400000 "$node_(8) setdest 1117.342896 426.453247 1000.000000"
$ns_ at 2.400000 "$node_(9) setdest 681.204285 843.622559 37.776430"
$ns_ at 2.466667 "$node_(0) setdest 691.248718 976.910278 428.700320"
$ns_ at 2.466667 "$node_(1) setdest 632.377380 924.439758 340.551664"
$ns_ at 2.466667 "$node_(2) setdest 668.530701 922.292542 1000.000000"
$ns_ at 2.466667 "$node_(3) setdest 623.505432 931.851440 338.841773"
$ns_ at 2.466667 "$node_(4) setdest 592.952271 1022.456055 700.854799"
$ns_ at 2.466667 "$node_(5) setdest 537.554443 1002.259583 754.668463"
$ns_ at 2.466667 "$node_(6) setdest 730.377014 939.050171 1000.000000"
$ns_ at 2.466667 "$node_(7) setdest 717.977722 977.454773 1000.000000"
$ns_ at 2.466667 "$node_(8) setdest 753.642517 826.453247 1000.000000"
$ns_ at 2.466667 "$node_(9) setdest 727.134155 443.622528 1000.000000"
$ns_ at 2.533333 "$node_(0) setdest 791.248718 1170.598877 817.424884"
$ns_ at 2.533333 "$node_(1) setdest 448.377350 869.428772 720.177861"
$ns_ at 2.533333 "$node_(2) setdest 628.530701 856.079224 290.091118"
$ns_ at 2.533333 "$node_(3) setdest 502.748444 884.641846 486.214574"
$ns_ at 2.533333 "$node_(4) setdest 771.645996 1059.869019 684.631026"
$ns_ at 2.533333 "$node_(5) setdest 321.446594 1290.259521 1000.000000"
$ns_ at 2.533333 "$node_(6) setdest 774.377014 964.302551 190.243024"
$ns_ at 2.533333 "$node_(7) setdest 651.164246 1061.454834 402.493093"
$ns_ at 2.533333 "$node_(8) setdest 845.942139 854.453247 361.699486"
$ns_ at 2.533333 "$node_(9) setdest 694.690430 843.622559 1000.000000"
$ns_ at 2.600000 "$node_(0) setdest 591.248718 1044.287354 887.052165"
$ns_ at 2.600000 "$node_(1) setdest 336.377350 938.417786 493.285134"
$ns_ at 2.600000 "$node_(2) setdest 592.530701 929.865906 307.876466"
$ns_ at 2.600000 "$node_(3) setdest 297.991455 965.432190 825.447306"
$ns_ at 2.600000 "$node_(4) setdest 886.339722 1085.281860 440.532623"
$ns_ at 2.600000 "$node_(5) setdest 673.338745 1022.259583 1000.000000"
$ns_ at 2.600000 "$node_(6) setdest 878.377014 1057.554932 523.820144"
$ns_ at 2.600000 "$node_(7) setdest 676.350769 1081.454834 120.605558"
$ns_ at 2.600000 "$node_(8) setdest 734.241699 1098.453247 1000.000000"
$ns_ at 2.600000 "$node_(9) setdest 634.246765 879.622559 263.820863"
$ns_ at 2.666667 "$node_(0) setdest 283.248749 1137.975952 1000.000000"
$ns_ at 2.666667 "$node_(1) setdest 692.377380 1011.406860 1000.000000"
$ns_ at 2.666667 "$node_(2) setdest 300.530670 699.652649 1000.000000"
$ns_ at 2.666667 "$node_(3) setdest 673.234497 1034.222656 1000.000000"
$ns_ at 2.666667 "$node_(4) setdest 729.033447 1018.694702 640.571046"
$ns_ at 2.666667 "$node_(5) setdest 477.230896 1074.259521 760.818346"
$ns_ at 2.666667 "$node_(6) setdest 766.377014 1066.807373 421.430718"
$ns_ at 2.666667 "$node_(7) setdest 417.537292 1133.454834 989.946047"
$ns_ at 2.666667 "$node_(8) setdest 690.541321 1266.453247 650.965027"
$ns_ at 2.666667 "$node_(9) setdest 489.803009 755.622559 713.880177"
$ns_ at 2.733333 "$node_(0) setdest 331.248749 1071.664429 306.978620"
$ns_ at 2.733333 "$node_(1) setdest 364.377350 948.395874 1000.000000"
$ns_ at 2.733333 "$node_(2) setdest 520.530701 1085.439331 1000.000000"
$ns_ at 2.733333 "$node_(3) setdest 416.477478 959.013000 1000.000000"
$ns_ at 2.733333 "$node_(4) setdest 423.727173 988.107605 1000.000000"
$ns_ at 2.733333 "$node_(5) setdest 601.123047 1146.259521 537.353697"
$ns_ at 2.733333 "$node_(6) setdest 618.377014 948.059753 711.561833"
$ns_ at 2.733333 "$node_(7) setdest 479.751770 1052.535767 382.767114"
$ns_ at 2.733333 "$node_(8) setdest 626.840881 1166.453247 444.620109"
$ns_ at 2.733333 "$node_(9) setdest 357.359314 879.622559 680.367530"
$ns_ at 2.800000 "$node_(0) setdest 0.000100 1309.353027 1000.000000"
$ns_ at 2.800000 "$node_(1) setdest 224.377365 897.384888 558.764047"
$ns_ at 2.800000 "$node_(2) setdest 324.530670 1239.226074 934.242104"
$ns_ at 2.800000 "$node_(3) setdest 415.720490 875.803406 312.048867"
$ns_ at 2.800000 "$node_(4) setdest 238.420914 1117.520508 847.583841"
$ns_ at 2.800000 "$node_(5) setdest 465.015167 1302.259521 776.361883"
$ns_ at 2.800000 "$node_(6) setdest 522.377014 945.312134 360.147410"
$ns_ at 2.800000 "$node_(7) setdest 469.966278 1015.616882 143.226421"
$ns_ at 2.800000 "$node_(8) setdest 539.140503 1174.453247 330.241854"
$ns_ at 2.800000 "$node_(9) setdest 136.915588 831.622559 846.033853"
$ns_ at 2.866667 "$node_(0) setdest 181.081467 1122.237671 1000.000000"
$ns_ at 2.866667 "$node_(1) setdest 8.377358 1166.373901 1000.000000"
$ns_ at 2.866667 "$node_(2) setdest 328.530670 1209.012817 114.288334"
$ns_ at 2.866667 "$node_(3) setdest 166.963501 1148.593750 1000.000000"
$ns_ at 2.866667 "$node_(4) setdest 329.114655 1074.933350 375.730915"
$ns_ at 2.866667 "$node_(5) setdest 176.907333 1082.259521 1000.000000"
$ns_ at 2.866667 "$node_(6) setdest 218.377045 1062.564575 1000.000000"
$ns_ at 2.866667 "$node_(7) setdest 236.180740 778.697937 1000.000000"
$ns_ at 2.866667 "$node_(8) setdest 163.440094 1110.453247 1000.000000"
$ns_ at 2.866667 "$node_(9) setdest 116.471863 1203.622559 1000.000000"
$ns_ at 2.933333 "$node_(0) setdest 106.914207 1015.122437 488.572686"
$ns_ at 2.933333 "$node_(1) setdest 0.000100 1292.510498 1000.000000"
$ns_ at 2.933333 "$node_(2) setdest 620.530701 1546.799438 1000.000000"
$ns_ at 2.933333 "$node_(3) setdest 0.000100 1433.384155 1000.000000"
$ns_ at 2.933333 "$node_(4) setdest 175.808380 1120.346191 599.591300"
$ns_ at 2.933333 "$node_(5) setdest 172.799469 1086.259521 21.501123"
$ns_ at 2.933333 "$node_(6) setdest 270.377045 903.816895 626.427637"
$ns_ at 2.933333 "$node_(7) setdest 30.395222 1057.778931 1000.000000"
$ns_ at 2.933333 "$node_(8) setdest 307.739685 1202.453247 641.747270"
$ns_ at 2.933333 "$node_(9) setdest 36.824615 1603.622559 1000.000000"
$ns_ at 3.000000 "$node_(0) setdest 28.746948 1184.007080 697.864229"
$ns_ at 3.000000 "$node_(1) setdest 8.377358 1334.335449 1000.000000"
$ns_ at 3.000000 "$node_(2) setdest 220.530670 1389.975708 1000.000000"
$ns_ at 3.000000 "$node_(3) setdest 0.000100 1254.174561 677.664664"
$ns_ at 3.000000 "$node_(4) setdest 234.502121 1433.759155 1000.000000"
$ns_ at 3.000000 "$node_(5) setdest 258.968231 1486.259521 1000.000000"
$ns_ at 3.000000 "$node_(6) setdest 106.433861 1303.816895 1000.000000"
$ns_ at 3.000000 "$node_(7) setdest 108.609703 1232.859985 719.090043"
$ns_ at 3.000000 "$node_(8) setdest 44.039295 1358.453247 1000.000000"
$ns_ at 3.000000 "$node_(9) setdest 0.000100 1459.622559 762.740496"
$ns_ at 3.066667 "$node_(0) setdest 0.000100 980.891846 866.506589"
$ns_ at 3.066667 "$node_(1) setdest 0.000100 1452.160400 569.934853"
$ns_ at 3.066667 "$node_(2) setdest 440.530670 1621.151978 1000.000000"
$ns_ at 3.066667 "$node_(3) setdest 132.692535 1302.964966 581.685360"
$ns_ at 3.066667 "$node_(4) setdest 357.195862 1635.171997 884.402973"
$ns_ at 3.066667 "$node_(5) setdest 217.137009 1634.259521 576.742772"
$ns_ at 3.066667 "$node_(6) setdest 330.490692 1303.816895 840.213045"
$ns_ at 3.066667 "$node_(7) setdest 118.824181 1343.941040 418.311374"
$ns_ at 3.066667 "$node_(8) setdest 168.338898 1374.453247 469.969258"
$ns_ at 3.066667 "$node_(9) setdest 69.530121 1479.622559 665.562023"
$ns_ at 3.133333 "$node_(0) setdest 182.390350 1380.891846 1000.000000"
$ns_ at 3.133333 "$node_(1) setdest 140.377365 1453.985229 855.027364"
$ns_ at 3.133333 "$node_(2) setdest 216.530670 1444.328247 1000.000000"
$ns_ at 3.133333 "$node_(3) setdest 0.000100 1079.755371 1000.000000"
$ns_ at 3.133333 "$node_(4) setdest 379.889587 1636.584839 85.266233"
$ns_ at 3.133333 "$node_(5) setdest 183.305786 1818.259521 701.566278"
$ns_ at 3.133333 "$node_(6) setdest 654.547485 1211.816895 1000.000000"
$ns_ at 3.133333 "$node_(7) setdest 113.038658 1187.022095 588.845814"
$ns_ at 3.133333 "$node_(8) setdest 400.638489 1558.453247 1000.000000"
$ns_ at 3.133333 "$node_(9) setdest 149.882874 1575.622559 469.462914"
$ns_ at 3.200000 "$node_(0) setdest 362.201019 1352.891846 682.416251"
$ns_ at 3.200000 "$node_(1) setdest 308.377350 1455.810181 630.037103"
$ns_ at 3.200000 "$node_(2) setdest 156.530670 1147.504517 1000.000000"
$ns_ at 3.200000 "$node_(3) setdest 323.641815 1479.755371 1000.000000"
$ns_ at 3.200000 "$node_(4) setdest 426.583313 1769.997681 530.055400"
$ns_ at 3.200000 "$node_(5) setdest 318.704620 1418.259521 1000.000000"
$ns_ at 3.200000 "$node_(6) setdest 254.547516 1479.815063 1000.000000"
$ns_ at 3.200000 "$node_(7) setdest 335.253143 1498.103149 1000.000000"
$ns_ at 3.200000 "$node_(8) setdest 287.269287 1433.435059 632.874265"
$ns_ at 3.200000 "$node_(9) setdest 166.235626 1551.622559 108.905863"
$ns_ at 3.266667 "$node_(0) setdest 529.206787 1091.790894 1000.000000"
$ns_ at 3.266667 "$node_(1) setdest 504.377350 1357.635132 822.048698"
$ns_ at 3.266667 "$node_(2) setdest 374.797485 1547.504517 1000.000000"
$ns_ at 3.266667 "$node_(3) setdest 339.348114 1511.755371 133.675153"
$ns_ at 3.266667 "$node_(4) setdest 341.277069 1439.410645 1000.000000"
$ns_ at 3.266667 "$node_(5) setdest 294.103455 1058.259521 1000.000000"
$ns_ at 3.266667 "$node_(6) setdest 86.547508 1359.813110 774.213541"
$ns_ at 3.266667 "$node_(7) setdest 333.467621 1597.184204 371.614275"
$ns_ at 3.266667 "$node_(8) setdest 129.900116 1140.416748 1000.000000"
$ns_ at 3.266667 "$node_(9) setdest 442.588379 1667.622559 1000.000000"
$ns_ at 3.333334 "$node_(0) setdest 386.691589 1289.349121 913.491278"
$ns_ at 3.333334 "$node_(1) setdest 902.296814 957.635071 1000.000000"
$ns_ at 3.333334 "$node_(2) setdest 401.064331 1203.504517 1000.000000"
$ns_ at 3.333334 "$node_(3) setdest 288.079773 1111.755371 1000.000000"
$ns_ at 3.333334 "$node_(4) setdest 355.970795 1312.823486 477.889084"
$ns_ at 3.333334 "$node_(5) setdest 445.502258 1134.259521 635.263677"
$ns_ at 3.333334 "$node_(6) setdest 426.547516 1295.811279 1000.000000"
$ns_ at 3.333334 "$node_(7) setdest 277.490021 1197.184204 1000.000000"
$ns_ at 3.333334 "$node_(8) setdest 420.530914 1339.398560 1000.000000"
$ns_ at 3.333334 "$node_(9) setdest 351.495758 1267.622559 1000.000000"
$ns_ at 3.400000 "$node_(0) setdest 664.176453 1450.907471 1000.000000"
$ns_ at 3.400000 "$node_(1) setdest 502.296814 1072.383545 1000.000000"
$ns_ at 3.400000 "$node_(2) setdest 497.736206 977.906799 920.392236"
$ns_ at 3.400000 "$node_(3) setdest 208.689468 711.755371 1000.000000"
$ns_ at 3.400000 "$node_(4) setdest 386.664520 1358.236328 205.547580"
$ns_ at 3.400000 "$node_(5) setdest 732.901123 734.259583 1000.000000"
$ns_ at 3.400000 "$node_(6) setdest 718.547485 1107.809448 1000.000000"
$ns_ at 3.400000 "$node_(7) setdest 325.512451 853.184204 1000.000000"
$ns_ at 3.400000 "$node_(8) setdest 559.161743 1062.380249 1000.000000"
$ns_ at 3.400000 "$node_(9) setdest 388.403137 1255.622559 145.534522"
$ns_ at 3.466667 "$node_(0) setdest 580.303406 1050.907471 1000.000000"
$ns_ at 3.466667 "$node_(1) setdest 602.296814 731.131958 1000.000000"
$ns_ at 3.466667 "$node_(2) setdest 547.172852 938.724731 236.553857"
$ns_ at 3.466667 "$node_(3) setdest 525.296265 910.114136 1000.000000"
$ns_ at 3.466667 "$node_(4) setdest 544.801270 958.236328 1000.000000"
$ns_ at 3.466667 "$node_(5) setdest 524.299927 966.259583 1000.000000"
$ns_ at 3.466667 "$node_(6) setdest 1118.547485 1373.837280 1000.000000"
$ns_ at 3.466667 "$node_(7) setdest 193.534851 781.184204 563.774614"
$ns_ at 3.466667 "$node_(8) setdest 789.657837 1199.746460 1000.000000"
$ns_ at 3.466667 "$node_(9) setdest 581.310547 871.622559 1000.000000"
$ns_ at 3.533334 "$node_(0) setdest 843.742554 1450.907471 1000.000000"
$ns_ at 3.533334 "$node_(1) setdest 798.296814 633.880371 820.503631"
$ns_ at 3.533334 "$node_(2) setdest 720.609497 943.542664 650.638298"
$ns_ at 3.533334 "$node_(3) setdest 613.903015 808.472961 505.653565"
$ns_ at 3.533334 "$node_(4) setdest 686.938049 1006.236328 562.585744"
$ns_ at 3.533334 "$node_(5) setdest 527.698730 918.259583 180.450673"
$ns_ at 3.533334 "$node_(6) setdest 757.518555 973.837219 1000.000000"
$ns_ at 3.533334 "$node_(7) setdest 593.534851 874.973694 1000.000000"
$ns_ at 3.533334 "$node_(8) setdest 672.153870 853.112549 1000.000000"
$ns_ at 3.533334 "$node_(9) setdest 378.217926 675.622559 1000.000000"
$ns_ at 3.600000 "$node_(0) setdest 750.770325 1050.907471 1000.000000"
$ns_ at 3.600000 "$node_(1) setdest 874.296814 708.628845 399.745997"
$ns_ at 3.600000 "$node_(2) setdest 704.181763 852.231079 347.915851"
$ns_ at 3.600000 "$node_(3) setdest 594.509827 478.831787 1000.000000"
$ns_ at 3.600000 "$node_(4) setdest 821.074768 1342.236328 1000.000000"
$ns_ at 3.600000 "$node_(5) setdest 351.097595 1022.259583 768.557528"
$ns_ at 3.600000 "$node_(6) setdest 1060.489624 1145.837280 1000.000000"
$ns_ at 3.600000 "$node_(7) setdest 345.534851 708.763184 1000.000000"
$ns_ at 3.600000 "$node_(8) setdest 626.649963 686.478699 647.756905"
$ns_ at 3.600000 "$node_(9) setdest 729.165833 863.074219 1000.000000"
$ns_ at 3.666667 "$node_(0) setdest 785.798096 1266.907471 820.581393"
$ns_ at 3.666667 "$node_(1) setdest 1002.296814 571.377258 703.782140"
$ns_ at 3.666667 "$node_(2) setdest 763.753967 1016.919556 656.744179"
$ns_ at 3.666667 "$node_(3) setdest 681.997437 787.919434 1000.000000"
$ns_ at 3.666667 "$node_(4) setdest 730.261292 942.236328 1000.000000"
$ns_ at 3.666667 "$node_(5) setdest 751.097595 841.228699 1000.000000"
$ns_ at 3.666667 "$node_(6) setdest 660.489624 823.557434 1000.000000"
$ns_ at 3.666667 "$node_(7) setdest 745.534851 877.086792 1000.000000"
$ns_ at 3.666667 "$node_(8) setdest 380.326813 286.478699 1000.000000"
$ns_ at 3.666667 "$node_(9) setdest 712.113708 730.525879 501.152604"
$ns_ at 3.733334 "$node_(0) setdest 763.816589 866.907471 1000.000000"
$ns_ at 3.733334 "$node_(1) setdest 718.296814 774.125671 1000.000000"
$ns_ at 3.733334 "$node_(2) setdest 914.543030 1416.919556 1000.000000"
$ns_ at 3.733334 "$node_(3) setdest 544.691956 387.919434 1000.000000"
$ns_ at 3.733334 "$node_(4) setdest 783.447876 1294.236328 1000.000000"
$ns_ at 3.733334 "$node_(5) setdest 831.097595 772.197876 396.246622"
$ns_ at 3.733334 "$node_(6) setdest 388.489594 769.277649 1000.000000"
$ns_ at 3.733334 "$node_(7) setdest 641.534851 929.410339 436.577173"
$ns_ at 3.733334 "$node_(8) setdest 702.718628 686.478699 1000.000000"
$ns_ at 3.733334 "$node_(9) setdest 767.061646 797.977600 326.250212"
$ns_ at 3.800000 "$node_(0) setdest 826.017029 1266.907471 1000.000000"
$ns_ at 3.800000 "$node_(1) setdest 650.296814 828.874084 327.377112"
$ns_ at 3.800000 "$node_(2) setdest 753.442200 1016.919556 1000.000000"
$ns_ at 3.800000 "$node_(3) setdest 652.046997 787.919434 1000.000000"
$ns_ at 3.800000 "$node_(4) setdest 687.219482 894.236328 1000.000000"
$ns_ at 3.800000 "$node_(5) setdest 1231.097534 642.099487 1000.000000"
$ns_ at 3.800000 "$node_(6) setdest 752.489624 942.997925 1000.000000"
$ns_ at 3.800000 "$node_(7) setdest 417.534851 1093.734009 1000.000000"
$ns_ at 3.800000 "$node_(8) setdest 645.110474 654.478699 247.121846"
$ns_ at 3.800000 "$node_(9) setdest 678.009521 929.429260 595.409973"
$ns_ at 3.866667 "$node_(0) setdest 745.027405 866.907471 1000.000000"
$ns_ at 3.866667 "$node_(1) setdest 406.296814 659.622559 1000.000000"
$ns_ at 3.866667 "$node_(2) setdest 920.341370 1412.919556 1000.000000"
$ns_ at 3.866667 "$node_(3) setdest 534.513489 605.904724 812.491623"
$ns_ at 3.866667 "$node_(4) setdest 654.991150 934.236328 192.629775"
$ns_ at 3.866667 "$node_(5) setdest 831.097595 883.988770 1000.000000"
$ns_ at 3.866667 "$node_(6) setdest 816.489624 1080.718140 569.492253"
$ns_ at 3.866667 "$node_(7) setdest 809.534851 910.057556 1000.000000"
$ns_ at 3.866667 "$node_(8) setdest 767.502319 970.478699 1000.000000"
$ns_ at 3.866667 "$node_(9) setdest 278.009552 873.910034 1000.000000"
$ns_ at 3.933334 "$node_(0) setdest 536.037720 754.907471 889.158794"
$ns_ at 3.933334 "$node_(1) setdest 546.296814 886.370972 999.322877"
$ns_ at 3.933334 "$node_(2) setdest 679.012085 1012.919556 1000.000000"
$ns_ at 3.933334 "$node_(3) setdest 612.797668 886.776306 1000.000000"
$ns_ at 3.933334 "$node_(4) setdest 254.991165 864.976135 1000.000000"
$ns_ at 3.933334 "$node_(5) setdest 893.519775 483.988739 1000.000000"
$ns_ at 3.933334 "$node_(6) setdest 784.489624 1082.438354 120.173257"
$ns_ at 3.933334 "$node_(7) setdest 933.534851 810.381165 596.608169"
$ns_ at 3.933334 "$node_(8) setdest 673.894165 1098.478760 594.661815"
$ns_ at 3.933334 "$node_(9) setdest 678.009521 938.514587 1000.000000"
$ns_ at 4.000000 "$node_(0) setdest 667.048035 734.907471 496.980431"
$ns_ at 4.000000 "$node_(1) setdest 190.296799 793.119385 1000.000000"
$ns_ at 4.000000 "$node_(2) setdest 737.682800 980.919556 250.612608"
$ns_ at 4.000000 "$node_(3) setdest 391.081879 815.647827 873.171570"
$ns_ at 4.000000 "$node_(4) setdest 573.625610 890.333923 1000.000000"
$ns_ at 4.000000 "$node_(5) setdest 633.903503 883.988770 1000.000000"
$ns_ at 4.000000 "$node_(6) setdest 740.489624 804.158569 1000.000000"
$ns_ at 4.000000 "$node_(7) setdest 985.534851 690.704712 489.320443"
$ns_ at 4.000000 "$node_(8) setdest 584.286011 1078.478760 344.298631"
$ns_ at 4.000000 "$node_(9) setdest 709.765198 894.536560 203.417691"
$ns_ at 4.066667 "$node_(0) setdest 618.058350 470.907471 1000.000000"
$ns_ at 4.066667 "$node_(1) setdest 590.296814 832.736694 1000.000000"
$ns_ at 4.066667 "$node_(2) setdest 1128.353516 1228.919556 1000.000000"
$ns_ at 4.066667 "$node_(3) setdest 625.366028 836.519348 882.044918"
$ns_ at 4.066667 "$node_(4) setdest 260.260010 783.691711 1000.000000"
$ns_ at 4.066667 "$node_(5) setdest 602.287292 771.988770 436.413380"
$ns_ at 4.066667 "$node_(6) setdest 832.489624 801.878784 345.105897"
$ns_ at 4.066667 "$node_(7) setdest 585.534851 840.993652 1000.000000"
$ns_ at 4.066667 "$node_(8) setdest 590.677856 810.478699 1000.000000"
$ns_ at 4.066667 "$node_(9) setdest 673.520874 950.558533 250.215555"
$ns_ at 4.133334 "$node_(0) setdest 689.068665 870.907471 1000.000000"
$ns_ at 4.133334 "$node_(1) setdest 422.296814 720.354065 757.962588"
$ns_ at 4.133334 "$node_(2) setdest 728.353577 862.663635 1000.000000"
$ns_ at 4.133334 "$node_(3) setdest 523.650208 653.390930 785.552232"
$ns_ at 4.133334 "$node_(4) setdest 598.894409 881.049561 1000.000000"
$ns_ at 4.133334 "$node_(5) setdest 490.858154 415.662689 1000.000000"
$ns_ at 4.133334 "$node_(6) setdest 656.489624 811.598999 661.005787"
$ns_ at 4.133334 "$node_(7) setdest 313.534851 651.282593 1000.000000"
$ns_ at 4.133334 "$node_(8) setdest 293.069672 510.478699 1000.000000"
$ns_ at 4.133334 "$node_(9) setdest 705.276489 1166.580566 818.788562"
$ns_ at 4.200000 "$node_(0) setdest 484.079010 670.907471 1000.000000"
$ns_ at 4.200000 "$node_(1) setdest 453.148132 812.539062 364.539280"
$ns_ at 4.200000 "$node_(2) setdest 644.353577 724.407776 606.650817"
$ns_ at 4.200000 "$node_(3) setdest 449.757294 692.073303 312.770875"
$ns_ at 4.200000 "$node_(4) setdest 569.528870 1126.407349 926.658105"
$ns_ at 4.200000 "$node_(5) setdest 453.406036 637.063965 842.049765"
$ns_ at 4.200000 "$node_(6) setdest 612.489624 889.319214 334.915764"
$ns_ at 4.200000 "$node_(7) setdest 305.534851 677.571472 103.046910"
$ns_ at 4.200000 "$node_(8) setdest 0.000100 110.478706 1000.000000"
$ns_ at 4.200000 "$node_(9) setdest 492.328949 766.580566 1000.000000"
$ns_ at 4.266667 "$node_(0) setdest 466.898651 451.545319 825.127101"
$ns_ at 4.266667 "$node_(1) setdest 53.148132 961.934204 1000.000000"
$ns_ at 4.266667 "$node_(2) setdest 904.353577 594.151917 1000.000000"
$ns_ at 4.266667 "$node_(3) setdest 291.864349 462.755676 1000.000000"
$ns_ at 4.266667 "$node_(4) setdest 397.925812 726.407349 1000.000000"
$ns_ at 4.266667 "$node_(5) setdest 527.953918 602.465271 308.195613"
$ns_ at 4.266667 "$node_(6) setdest 456.489594 759.039429 762.171496"
$ns_ at 4.266667 "$node_(7) setdest 0.000100 447.860413 1000.000000"
$ns_ at 4.266667 "$node_(8) setdest 245.029297 510.478699 1000.000000"
$ns_ at 4.266667 "$node_(9) setdest 491.381409 742.580566 90.070112"
$ns_ at 4.333334 "$node_(0) setdest 335.857697 549.624878 613.802115"
$ns_ at 4.333334 "$node_(1) setdest 328.321503 561.934204 1000.000000"
$ns_ at 4.333334 "$node_(2) setdest 504.353546 564.414734 1000.000000"
$ns_ at 4.333334 "$node_(3) setdest 301.971405 341.438019 456.517272"
$ns_ at 4.333334 "$node_(4) setdest 206.322754 1018.407349 1000.000000"
$ns_ at 4.333334 "$node_(5) setdest 326.501740 399.866577 1000.000000"
$ns_ at 4.333334 "$node_(6) setdest 360.489594 940.759644 770.697801"
$ns_ at 4.333334 "$node_(7) setdest 333.534851 558.640198 1000.000000"
$ns_ at 4.333334 "$node_(8) setdest 0.000100 642.478699 1000.000000"
$ns_ at 4.333334 "$node_(9) setdest 302.433838 526.580566 1000.000000"
$ns_ at 4.400000 "$node_(0) setdest 100.816742 723.704468 1000.000000"
$ns_ at 4.400000 "$node_(1) setdest 19.494850 833.934204 1000.000000"
$ns_ at 4.400000 "$node_(2) setdest 572.353577 762.677490 785.999639"
$ns_ at 4.400000 "$node_(3) setdest 180.078445 392.120392 495.036881"
$ns_ at 4.400000 "$node_(4) setdest 262.719696 778.407349 924.514627"
$ns_ at 4.400000 "$node_(5) setdest 377.049622 357.267883 247.889944"
$ns_ at 4.400000 "$node_(6) setdest 300.489594 702.479858 921.441831"
$ns_ at 4.400000 "$node_(7) setdest 369.534851 637.419922 324.808113"
$ns_ at 4.400000 "$node_(8) setdest 148.392639 394.478699 1000.000000"
$ns_ at 4.400000 "$node_(9) setdest 429.486298 602.580566 555.181474"
$ns_ at 4.466667 "$node_(0) setdest 21.775791 457.784058 1000.000000"
$ns_ at 4.466667 "$node_(1) setdest 322.668213 577.934204 1000.000000"
$ns_ at 4.466667 "$node_(2) setdest 364.353546 752.940308 780.854261"
$ns_ at 4.466667 "$node_(3) setdest 174.185501 458.802765 251.033436"
$ns_ at 4.466667 "$node_(4) setdest 11.116661 874.407349 1000.000000"
$ns_ at 4.466667 "$node_(5) setdest 281.864227 578.886475 904.481459"
$ns_ at 4.466667 "$node_(6) setdest 128.489594 904.200073 994.104028"
$ns_ at 4.466667 "$node_(7) setdest 389.534851 620.199707 98.969860"
$ns_ at 4.466667 "$node_(8) setdest 0.000100 314.478699 829.820437"
$ns_ at 4.466667 "$node_(9) setdest 232.538727 622.580566 742.351703"
$ns_ at 4.533334 "$node_(0) setdest 122.734840 659.863647 847.109026"
$ns_ at 4.533334 "$node_(1) setdest 421.841583 417.934204 705.910512"
$ns_ at 4.533334 "$node_(2) setdest 288.353546 1039.203125 1000.000000"
$ns_ at 4.533334 "$node_(3) setdest 100.292557 621.485168 670.041469"
$ns_ at 4.533334 "$node_(4) setdest 139.513611 578.407349 1000.000000"
$ns_ at 4.533334 "$node_(5) setdest 518.678833 384.505066 1000.000000"
$ns_ at 4.533334 "$node_(6) setdest 0.000100 504.200104 1000.000000"
$ns_ at 4.533334 "$node_(7) setdest 229.534851 614.979431 600.319259"
$ns_ at 4.533334 "$node_(8) setdest 87.755981 462.478699 778.765371"
$ns_ at 4.533334 "$node_(9) setdest 595.591187 786.580566 1000.000000"
$ns_ at 4.600000 "$node_(0) setdest 376.603241 1059.863647 1000.000000"
$ns_ at 4.600000 "$node_(1) setdest 497.014923 433.934204 288.214516"
$ns_ at 4.600000 "$node_(2) setdest 255.865479 639.203125 1000.000000"
$ns_ at 4.600000 "$node_(3) setdest 150.399612 888.167480 1000.000000"
$ns_ at 4.600000 "$node_(4) setdest 319.910553 718.407349 856.306985"
$ns_ at 4.600000 "$node_(5) setdest 275.493439 638.123657 1000.000000"
$ns_ at 4.600000 "$node_(6) setdest 265.506744 688.200073 1000.000000"
$ns_ at 4.600000 "$node_(7) setdest 284.766785 536.531433 359.778338"
$ns_ at 4.600000 "$node_(8) setdest 0.000100 246.478699 909.528647"
$ns_ at 4.600000 "$node_(9) setdest 250.643616 562.580566 1000.000000"
$ns_ at 4.666667 "$node_(0) setdest 275.636078 659.863647 1000.000000"
$ns_ at 4.666667 "$node_(1) setdest 260.188293 697.934204 1000.000000"
$ns_ at 4.666667 "$node_(2) setdest 179.377396 591.203125 338.631975"
$ns_ at 4.666667 "$node_(3) setdest 20.506662 982.849854 602.770125"
$ns_ at 4.666667 "$node_(4) setdest 540.307495 1002.407349 1000.000000"
$ns_ at 4.666667 "$node_(5) setdest 464.308044 643.742310 708.368188"
$ns_ at 4.666667 "$node_(6) setdest 158.015305 948.200073 1000.000000"
$ns_ at 4.666667 "$node_(7) setdest 287.529144 674.610107 517.898628"
$ns_ at 4.666667 "$node_(8) setdest 256.213196 646.478699 1000.000000"
$ns_ at 4.666667 "$node_(9) setdest 253.411118 305.090363 965.643947"
$ns_ at 4.733334 "$node_(0) setdest 122.668922 823.863647 840.995020"
$ns_ at 4.733334 "$node_(1) setdest 407.361664 721.934204 559.190225"
$ns_ at 4.733334 "$node_(2) setdest 290.889313 811.203125 924.927473"
$ns_ at 4.733334 "$node_(3) setdest 314.613708 761.532227 1000.000000"
$ns_ at 4.733334 "$node_(4) setdest 220.704468 738.407349 1000.000000"
$ns_ at 4.733334 "$node_(5) setdest 789.122681 409.360901 1000.000000"
$ns_ at 4.733334 "$node_(6) setdest 42.523872 1196.200073 1000.000000"
$ns_ at 4.733334 "$node_(7) setdest 386.291473 336.688721 1000.000000"
$ns_ at 4.733334 "$node_(8) setdest 189.107330 246.478699 1000.000000"
$ns_ at 4.733334 "$node_(9) setdest 266.627686 701.224060 1000.000000"
$ns_ at 4.800000 "$node_(0) setdest 0.000100 879.863647 1000.000000"
$ns_ at 4.800000 "$node_(1) setdest 710.535034 481.934204 1000.000000"
$ns_ at 4.800000 "$node_(2) setdest 398.401245 827.203125 407.609890"
$ns_ at 4.800000 "$node_(3) setdest 448.720764 724.214600 522.008945"
$ns_ at 4.800000 "$node_(4) setdest 337.101440 690.407349 472.146496"
$ns_ at 4.800000 "$node_(5) setdest 389.122650 610.875061 1000.000000"
$ns_ at 4.800000 "$node_(6) setdest 250.245209 796.200073 1000.000000"
$ns_ at 4.800000 "$node_(7) setdest 502.504364 736.688721 1000.000000"
$ns_ at 4.800000 "$node_(8) setdest 330.042480 646.478699 1000.000000"
$ns_ at 4.800000 "$node_(9) setdest 0.000100 621.357727 1000.000000"
$ns_ at 4.866667 "$node_(0) setdest 173.701752 771.522766 1000.000000"
$ns_ at 4.866667 "$node_(1) setdest 310.535004 741.113525 1000.000000"
$ns_ at 4.866667 "$node_(2) setdest 245.913162 995.203125 850.817140"
$ns_ at 4.866667 "$node_(3) setdest 848.720764 843.135315 1000.000000"
$ns_ at 4.866667 "$node_(4) setdest 377.498383 574.407349 460.623212"
$ns_ at 4.866667 "$node_(5) setdest 457.122650 412.389221 786.790940"
$ns_ at 4.866667 "$node_(6) setdest 233.966553 912.200073 439.262415"
$ns_ at 4.866667 "$node_(7) setdest 786.717285 936.688721 1000.000000"
$ns_ at 4.866667 "$node_(8) setdest 290.977631 674.478699 180.236654"
$ns_ at 4.866667 "$node_(9) setdest 319.844238 725.405823 1000.000000"
$ns_ at 4.933334 "$node_(0) setdest 157.701752 767.181885 62.168988"
$ns_ at 4.933334 "$node_(1) setdest 520.286072 839.187012 868.300450"
$ns_ at 4.933334 "$node_(2) setdest 527.322449 796.016479 1000.000000"
$ns_ at 4.933334 "$node_(3) setdest 484.720764 710.056030 1000.000000"
$ns_ at 4.933334 "$node_(4) setdest 573.895325 766.407349 1000.000000"
$ns_ at 4.933334 "$node_(5) setdest 494.608215 812.389221 1000.000000"
$ns_ at 4.933334 "$node_(6) setdest 445.687897 980.200073 833.900198"
$ns_ at 4.933334 "$node_(7) setdest 442.930145 784.688721 1000.000000"
$ns_ at 4.933334 "$node_(8) setdest 499.912781 778.478699 875.204441"
$ns_ at 4.933334 "$node_(9) setdest 3.844239 617.453857 1000.000000"
$ns_ at 5.000000 "$node_(0) setdest 453.701752 814.841064 1000.000000"
$ns_ at 5.000000 "$node_(1) setdest 426.037140 933.260498 499.365437"
$ns_ at 5.000000 "$node_(2) setdest 676.731689 760.829895 575.612324"
$ns_ at 5.000000 "$node_(3) setdest 436.720764 496.976715 819.070659"
$ns_ at 5.000000 "$node_(4) setdest 690.292297 682.407349 538.281813"
$ns_ at 5.000000 "$node_(5) setdest 372.093781 716.389221 583.673771"
$ns_ at 5.000000 "$node_(6) setdest 401.409210 1148.200073 651.514344"
$ns_ at 5.000000 "$node_(7) setdest 399.143036 808.688721 187.248978"
$ns_ at 5.000000 "$node_(8) setdest 220.847931 818.478699 1000.000000"
$ns_ at 5.000000 "$node_(9) setdest 403.844238 796.692322 1000.000000"
$ns_ at 5.066667 "$node_(0) setdest 665.701782 814.500183 795.001103"
$ns_ at 5.066667 "$node_(1) setdest 543.788208 1051.333984 625.324827"
$ns_ at 5.066667 "$node_(2) setdest 486.483185 764.943909 713.598653"
$ns_ at 5.066667 "$node_(3) setdest 488.720764 863.897400 1000.000000"
$ns_ at 5.066667 "$node_(4) setdest 446.689240 830.407349 1000.000000"
$ns_ at 5.066667 "$node_(5) setdest 305.556122 316.389221 1000.000000"
$ns_ at 5.066667 "$node_(6) setdest 486.054779 769.944824 1000.000000"
$ns_ at 5.066667 "$node_(7) setdest 355.355927 812.688721 164.885365"
$ns_ at 5.066667 "$node_(8) setdest 221.783081 834.478699 60.102393"
$ns_ at 5.066667 "$node_(9) setdest 287.844238 707.930847 547.738810"
$ns_ at 5.133334 "$node_(0) setdest 413.593750 764.459351 963.848712"
$ns_ at 5.133334 "$node_(1) setdest 385.539276 713.407471 1000.000000"
$ns_ at 5.133334 "$node_(2) setdest 760.234680 593.057922 1000.000000"
$ns_ at 5.133334 "$node_(3) setdest 756.720764 1134.818115 1000.000000"
$ns_ at 5.133334 "$node_(4) setdest 579.086182 998.407349 802.122704"
$ns_ at 5.133334 "$node_(5) setdest 397.573029 716.389221 1000.000000"
$ns_ at 5.133334 "$node_(6) setdest 658.700317 903.689575 818.961997"
$ns_ at 5.133334 "$node_(7) setdest 327.568817 896.688721 331.787550"
$ns_ at 5.133334 "$node_(8) setdest 0.000100 1054.478760 1000.000000"
$ns_ at 5.133334 "$node_(9) setdest 390.715027 585.284546 600.287158"
$ns_ at 5.200000 "$node_(0) setdest 584.124023 1164.459351 1000.000000"
$ns_ at 5.200000 "$node_(1) setdest 503.290344 1075.480957 1000.000000"
$ns_ at 5.200000 "$node_(2) setdest 437.986176 945.171936 1000.000000"
$ns_ at 5.200000 "$node_(3) setdest 784.720764 949.738770 701.945135"
$ns_ at 5.200000 "$node_(4) setdest 607.483154 774.407349 846.722959"
$ns_ at 5.200000 "$node_(5) setdest 497.589935 1000.389221 1000.000000"
$ns_ at 5.200000 "$node_(6) setdest 703.345886 701.434326 776.715505"
$ns_ at 5.200000 "$node_(7) setdest 484.409760 893.283081 588.292148"
$ns_ at 5.200000 "$node_(8) setdest 302.718231 939.342896 1000.000000"
$ns_ at 5.200000 "$node_(9) setdest 493.585785 938.638245 1000.000000"
$ns_ at 5.266667 "$node_(0) setdest 774.654236 1240.459351 769.232386"
$ns_ at 5.266667 "$node_(1) setdest 698.550598 1475.480957 1000.000000"
$ns_ at 5.266667 "$node_(2) setdest 539.737671 1249.286011 1000.000000"
$ns_ at 5.266667 "$node_(3) setdest 604.720764 1068.659546 809.011074"
$ns_ at 5.266667 "$node_(4) setdest 859.880066 810.407349 956.067589"
$ns_ at 5.266667 "$node_(5) setdest 698.296936 1152.638550 944.695996"
$ns_ at 5.266667 "$node_(6) setdest 607.991455 1095.179077 1000.000000"
$ns_ at 5.266667 "$node_(7) setdest 673.250671 789.877441 807.370849"
$ns_ at 5.266667 "$node_(8) setdest 422.718231 1064.207153 649.422478"
$ns_ at 5.266667 "$node_(9) setdest 292.456573 755.991943 1000.000000"
$ns_ at 5.333334 "$node_(0) setdest 1005.184509 1504.459351 1000.000000"
$ns_ at 5.333334 "$node_(1) setdest 677.810852 1131.480957 1000.000000"
$ns_ at 5.333334 "$node_(2) setdest 701.489197 1169.400024 676.512073"
$ns_ at 5.333334 "$node_(3) setdest 728.720764 1015.580200 505.811150"
$ns_ at 5.333334 "$node_(4) setdest 665.858582 1210.407349 1000.000000"
$ns_ at 5.333334 "$node_(5) setdest 679.662476 1188.038086 150.017344"
$ns_ at 5.333334 "$node_(6) setdest 480.636993 968.923767 672.490733"
$ns_ at 5.333334 "$node_(7) setdest 874.091614 1078.471802 1000.000000"
$ns_ at 5.333334 "$node_(8) setdest 658.718262 1289.071411 1000.000000"
$ns_ at 5.333334 "$node_(9) setdest 656.237549 1155.991943 1000.000000"
$ns_ at 5.400000 "$node_(0) setdest 763.714722 1220.459351 1000.000000"
$ns_ at 5.400000 "$node_(1) setdest 713.071106 1211.480957 327.847063"
$ns_ at 5.400000 "$node_(2) setdest 687.240662 1313.514038 543.062525"
$ns_ at 5.400000 "$node_(3) setdest 844.720764 734.500916 1000.000000"
$ns_ at 5.400000 "$node_(4) setdest 751.837036 1230.407349 331.027376"
$ns_ at 5.400000 "$node_(5) setdest 589.028076 1287.437500 504.438946"
$ns_ at 5.400000 "$node_(6) setdest 681.282532 1134.668579 975.936762"
$ns_ at 5.400000 "$node_(7) setdest 1206.932495 911.066162 1000.000000"
$ns_ at 5.400000 "$node_(8) setdest 718.718262 1529.935547 930.842809"
$ns_ at 5.400000 "$node_(9) setdest 624.018494 991.991943 626.755739"
$ns_ at 5.466667 "$node_(0) setdest 1102.244995 1172.459351 1000.000000"
$ns_ at 5.466667 "$node_(1) setdest 952.331421 951.480957 1000.000000"
$ns_ at 5.466667 "$node_(2) setdest 797.549011 1134.666626 787.984902"
$ns_ at 5.466667 "$node_(3) setdest 809.932983 1034.496460 1000.000000"
$ns_ at 5.466667 "$node_(4) setdest 809.815491 1422.407349 752.111052"
$ns_ at 5.466667 "$node_(5) setdest 830.393616 1118.837036 1000.000000"
$ns_ at 5.466667 "$node_(6) setdest 457.928101 1380.413330 1000.000000"
$ns_ at 5.466667 "$node_(7) setdest 806.932556 1138.626709 1000.000000"
$ns_ at 5.466667 "$node_(8) setdest 714.718262 1182.799805 1000.000000"
$ns_ at 5.466667 "$node_(9) setdest 224.018524 677.336670 1000.000000"
$ns_ at 5.533334 "$node_(0) setdest 702.244995 1087.562988 1000.000000"
$ns_ at 5.533334 "$node_(1) setdest 1229.142456 551.480957 1000.000000"
$ns_ at 5.533334 "$node_(2) setdest 847.857361 1207.819214 332.932216"
$ns_ at 5.533334 "$node_(3) setdest 793.736572 700.009827 1000.000000"
$ns_ at 5.533334 "$node_(4) setdest 731.793945 1030.407349 1000.000000"
$ns_ at 5.533334 "$node_(5) setdest 1055.759155 1046.236450 887.890903"
$ns_ at 5.533334 "$node_(6) setdest 766.777222 1059.078125 1000.000000"
$ns_ at 5.533334 "$node_(7) setdest 1050.932495 1186.187378 932.219991"
$ns_ at 5.533334 "$node_(8) setdest 558.718262 1455.664062 1000.000000"
$ns_ at 5.533334 "$node_(9) setdest 624.018494 990.462280 1000.000000"
$ns_ at 5.600000 "$node_(0) setdest 826.244995 998.666687 572.149113"
$ns_ at 5.600000 "$node_(1) setdest 917.218933 951.480957 1000.000000"
$ns_ at 5.600000 "$node_(2) setdest 1118.165649 1232.971924 1000.000000"
$ns_ at 5.600000 "$node_(3) setdest 886.321777 899.687561 825.368228"
$ns_ at 5.600000 "$node_(4) setdest 585.772400 1222.407349 904.568778"
$ns_ at 5.600000 "$node_(5) setdest 1133.124756 857.635986 764.444349"
$ns_ at 5.600000 "$node_(6) setdest 899.626404 1197.743042 720.125561"
$ns_ at 5.600000 "$node_(7) setdest 966.932556 857.748047 1000.000000"
$ns_ at 5.600000 "$node_(8) setdest 841.006775 1055.664062 1000.000000"
$ns_ at 5.600000 "$node_(9) setdest 908.018494 903.587952 1000.000000"
$ns_ at 5.666667 "$node_(0) setdest 610.244995 1389.770386 1000.000000"
$ns_ at 5.666667 "$node_(1) setdest 1137.295410 963.480957 826.512694"
$ns_ at 5.666667 "$node_(2) setdest 936.473999 982.124573 1000.000000"
$ns_ at 5.666667 "$node_(3) setdest 830.906921 947.365295 274.134278"
$ns_ at 5.666667 "$node_(4) setdest 985.772400 991.285156 1000.000000"
$ns_ at 5.666667 "$node_(5) setdest 1294.490356 677.035461 908.207884"
$ns_ at 5.666667 "$node_(6) setdest 1032.475464 1112.407959 592.107608"
$ns_ at 5.666667 "$node_(7) setdest 990.932556 1053.308716 738.854389"
$ns_ at 5.666667 "$node_(8) setdest 441.006775 1311.060303 1000.000000"
$ns_ at 5.666667 "$node_(9) setdest 848.018494 664.713562 923.604249"
$ns_ at 5.733334 "$node_(0) setdest 911.368042 989.770325 1000.000000"
$ns_ at 5.733334 "$node_(1) setdest 1269.371948 739.480957 975.145747"
$ns_ at 5.733334 "$node_(2) setdest 862.782349 847.277222 576.260003"
$ns_ at 5.733334 "$node_(3) setdest 503.492126 911.043030 1000.000000"
$ns_ at 5.733334 "$node_(4) setdest 1009.772400 984.162964 93.879328"
$ns_ at 5.733334 "$node_(5) setdest 894.490295 981.302979 1000.000000"
$ns_ at 5.733334 "$node_(6) setdest 1209.324585 1439.072876 1000.000000"
$ns_ at 5.733334 "$node_(7) setdest 1062.932495 1180.869263 549.290914"
$ns_ at 5.733334 "$node_(8) setdest 841.006775 1049.639282 1000.000000"
$ns_ at 5.733334 "$node_(9) setdest 912.018494 877.839172 834.478411"
$ns_ at 5.800000 "$node_(0) setdest 848.491089 1045.770386 315.747254"
$ns_ at 5.800000 "$node_(1) setdest 941.448486 1039.480957 1000.000000"
$ns_ at 5.800000 "$node_(2) setdest 793.090698 492.429840 1000.000000"
$ns_ at 5.800000 "$node_(3) setdest 903.492126 972.724365 1000.000000"
$ns_ at 5.800000 "$node_(4) setdest 1409.772339 827.756531 1000.000000"
$ns_ at 5.800000 "$node_(5) setdest 846.490295 745.570496 902.136508"
$ns_ at 5.800000 "$node_(6) setdest 1010.470764 1039.072876 1000.000000"
$ns_ at 5.800000 "$node_(7) setdest 1142.932495 1240.429932 374.013814"
$ns_ at 5.800000 "$node_(8) setdest 557.006775 1284.218140 1000.000000"
$ns_ at 5.800000 "$node_(9) setdest 931.569946 699.066406 674.395145"
$ns_ at 5.866667 "$node_(0) setdest 629.614197 941.770325 908.731852"
$ns_ at 5.866667 "$node_(1) setdest 937.524963 891.480957 555.194978"
$ns_ at 5.866667 "$node_(2) setdest 926.936462 892.429871 1000.000000"
$ns_ at 5.866667 "$node_(3) setdest 723.492126 954.405762 678.486522"
$ns_ at 5.866667 "$node_(4) setdest 1009.772400 875.024780 1000.000000"
$ns_ at 5.866667 "$node_(5) setdest 606.490295 493.838013 1000.000000"
$ns_ at 5.866667 "$node_(6) setdest 1099.616821 1363.072876 1000.000000"
$ns_ at 5.866667 "$node_(7) setdest 905.566895 840.429932 1000.000000"
$ns_ at 5.866667 "$node_(8) setdest 928.768860 884.218140 1000.000000"
$ns_ at 5.866667 "$node_(9) setdest 928.501953 846.119629 551.569547"
$ns_ at 5.933334 "$node_(0) setdest 746.737244 845.770325 567.896661"
$ns_ at 5.933334 "$node_(1) setdest 781.601501 979.480957 671.408408"
$ns_ at 5.933334 "$node_(2) setdest 856.782227 844.429871 318.763602"
$ns_ at 5.933334 "$node_(3) setdest 667.492126 1068.087036 475.221781"
$ns_ at 5.933334 "$node_(4) setdest 1085.772339 902.292969 302.788852"
$ns_ at 5.933334 "$node_(5) setdest 830.649292 893.838013 1000.000000"
$ns_ at 5.933334 "$node_(6) setdest 874.882690 963.072876 1000.000000"
$ns_ at 5.933334 "$node_(7) setdest 996.201294 536.429932 1000.000000"
$ns_ at 5.933334 "$node_(8) setdest 1044.530884 748.218140 669.738258"
$ns_ at 5.933334 "$node_(9) setdest 817.434021 809.172913 438.944584"
$ns_ at 6.000000 "$node_(0) setdest 551.860291 657.770325 1000.000000"
$ns_ at 6.000000 "$node_(1) setdest 717.677979 1067.480957 407.875478"
$ns_ at 6.000000 "$node_(2) setdest 882.628052 652.429871 726.494198"
$ns_ at 6.000000 "$node_(3) setdest 735.492126 953.768433 498.802731"
$ns_ at 6.000000 "$node_(4) setdest 845.772400 809.561218 964.844806"
$ns_ at 6.000000 "$node_(5) setdest 894.808228 809.838013 396.372822"
$ns_ at 6.000000 "$node_(6) setdest 1098.148560 1319.072876 1000.000000"
$ns_ at 6.000000 "$node_(7) setdest 850.835693 880.429932 1000.000000"
$ns_ at 6.000000 "$node_(8) setdest 1040.292969 776.218140 106.195859"
$ns_ at 6.000000 "$node_(9) setdest 906.366028 608.226135 824.049182"
$ns_ at 6.066667 "$node_(0) setdest 884.983398 885.770325 1000.000000"
$ns_ at 6.066667 "$node_(1) setdest 849.754517 819.480957 1000.000000"
$ns_ at 6.066667 "$node_(2) setdest 816.473816 728.429871 377.846355"
$ns_ at 6.066667 "$node_(3) setdest 335.492126 1290.298828 1000.000000"
$ns_ at 6.066667 "$node_(4) setdest 593.772400 820.829407 945.944203"
$ns_ at 6.066667 "$node_(5) setdest 854.967163 817.838013 152.386185"
$ns_ at 6.066667 "$node_(6) setdest 874.766968 919.072876 1000.000000"
$ns_ at 6.066667 "$node_(7) setdest 633.470093 1080.429932 1000.000000"
$ns_ at 6.066667 "$node_(8) setdest 1324.055054 560.218140 1000.000000"
$ns_ at 6.066667 "$node_(9) setdest 835.969421 851.491577 949.674061"
$ns_ at 6.133334 "$node_(0) setdest 862.106445 1105.770386 829.448619"
$ns_ at 6.133334 "$node_(1) setdest 745.831055 895.480957 482.805551"
$ns_ at 6.133334 "$node_(2) setdest 742.319580 432.429840 1000.000000"
$ns_ at 6.133334 "$node_(3) setdest 735.492126 919.523132 1000.000000"
$ns_ at 6.133334 "$node_(4) setdest 788.085449 903.380981 791.705891"
$ns_ at 6.133334 "$node_(5) setdest 743.126160 905.838013 533.666068"
$ns_ at 6.133334 "$node_(6) setdest 1274.766968 881.033630 1000.000000"
$ns_ at 6.133334 "$node_(7) setdest 358.998718 1480.429932 1000.000000"
$ns_ at 6.133334 "$node_(8) setdest 924.055054 799.653809 1000.000000"
$ns_ at 6.133334 "$node_(9) setdest 989.572815 718.757080 761.281832"
$ns_ at 6.200000 "$node_(0) setdest 831.229553 893.770325 803.387962"
$ns_ at 6.200000 "$node_(1) setdest 557.907532 979.480957 771.910360"
$ns_ at 6.200000 "$node_(2) setdest 814.816711 832.429871 1000.000000"
$ns_ at 6.200000 "$node_(3) setdest 555.492126 1172.747437 1000.000000"
$ns_ at 6.200000 "$node_(4) setdest 654.398438 1105.932495 910.094385"
$ns_ at 6.200000 "$node_(5) setdest 699.285095 1045.838013 550.139666"
$ns_ at 6.200000 "$node_(6) setdest 874.766968 924.613159 1000.000000"
$ns_ at 6.200000 "$node_(7) setdest 698.586853 1080.429932 1000.000000"
$ns_ at 6.200000 "$node_(8) setdest 852.055054 875.089478 391.053980"
$ns_ at 6.200000 "$node_(9) setdest 809.953430 952.026367 1000.000000"
$ns_ at 6.266667 "$node_(0) setdest 876.352600 761.770325 523.122798"
$ns_ at 6.266667 "$node_(1) setdest 541.984070 1003.480957 108.007588"
$ns_ at 6.266667 "$node_(2) setdest 539.313782 796.429871 1000.000000"
$ns_ at 6.266667 "$node_(3) setdest 451.492126 1361.971802 809.703556"
$ns_ at 6.266667 "$node_(4) setdest 580.711487 1324.484009 864.897664"
$ns_ at 6.266667 "$node_(5) setdest 299.285095 1373.218262 1000.000000"
$ns_ at 6.266667 "$node_(6) setdest 934.766968 944.192688 236.676924"
$ns_ at 6.266667 "$node_(7) setdest 658.174988 1312.429932 883.100006"
$ns_ at 6.266667 "$node_(8) setdest 604.055054 930.525146 952.950962"
$ns_ at 6.266667 "$node_(9) setdest 534.333984 1057.295654 1000.000000"
$ns_ at 6.333334 "$node_(0) setdest 500.421234 1161.770386 1000.000000"
$ns_ at 6.333334 "$node_(1) setdest 450.060547 1067.480957 420.032365"
$ns_ at 6.333334 "$node_(2) setdest 423.810913 1096.429810 1000.000000"
$ns_ at 6.333334 "$node_(3) setdest 479.492126 1151.196045 797.352806"
$ns_ at 6.333334 "$node_(4) setdest 567.024536 1499.035522 656.577324"
$ns_ at 6.333334 "$node_(5) setdest 456.339630 1210.328491 848.521513"
$ns_ at 6.333334 "$node_(6) setdest 534.766968 1146.946167 1000.000000"
$ns_ at 6.333334 "$node_(7) setdest 913.763123 1628.429932 1000.000000"
$ns_ at 6.333334 "$node_(8) setdest 728.055054 913.960815 469.130463"
$ns_ at 6.333334 "$node_(9) setdest 566.714539 854.565002 769.876116"
$ns_ at 6.400000 "$node_(0) setdest 668.489868 1265.770386 741.164150"
$ns_ at 6.400000 "$node_(1) setdest 515.463684 1218.965698 618.752199"
$ns_ at 6.400000 "$node_(2) setdest 252.308014 904.429871 965.413577"
$ns_ at 6.400000 "$node_(3) setdest 267.492126 1056.420410 870.827305"
$ns_ at 6.400000 "$node_(4) setdest 521.337585 1217.587158 1000.000000"
$ns_ at 6.400000 "$node_(5) setdest 313.394196 1327.438721 692.971193"
$ns_ at 6.400000 "$node_(6) setdest 590.766968 1109.699707 252.208000"
$ns_ at 6.400000 "$node_(7) setdest 513.763123 1246.163452 1000.000000"
$ns_ at 6.400000 "$node_(8) setdest 624.055054 1101.396484 803.831764"
$ns_ at 6.400000 "$node_(9) setdest 522.714722 1254.564941 1000.000000"
$ns_ at 6.466667 "$node_(0) setdest 996.558533 1437.770386 1000.000000"
$ns_ at 6.466667 "$node_(1) setdest 184.866852 1314.450317 1000.000000"
$ns_ at 6.466667 "$node_(2) setdest 412.805115 1064.429810 849.847082"
$ns_ at 6.466667 "$node_(3) setdest 283.492126 1177.644775 458.533864"
$ns_ at 6.466667 "$node_(4) setdest 335.650574 1500.138672 1000.000000"
$ns_ at 6.466667 "$node_(5) setdest 393.596222 1179.113525 632.325235"
$ns_ at 6.466667 "$node_(6) setdest 710.766968 824.453186 1000.000000"
$ns_ at 6.466667 "$node_(7) setdest 529.763123 1583.897095 1000.000000"
$ns_ at 6.466667 "$node_(8) setdest 480.055054 1004.832214 650.175328"
$ns_ at 6.466667 "$node_(9) setdest 626.714905 1382.564941 618.466269"
$ns_ at 6.533334 "$node_(0) setdest 628.423645 1345.081909 1000.000000"
$ns_ at 6.533334 "$node_(1) setdest 334.270020 1269.935059 584.602173"
$ns_ at 6.533334 "$node_(2) setdest 581.302246 1164.429810 734.763470"
$ns_ at 6.533334 "$node_(3) setdest 175.492111 1402.869019 936.674317"
$ns_ at 6.533334 "$node_(4) setdest 517.963623 1286.690186 1000.000000"
$ns_ at 6.533334 "$node_(5) setdest 369.798248 1326.788330 560.925149"
$ns_ at 6.533334 "$node_(6) setdest 554.268555 1224.453125 1000.000000"
$ns_ at 6.533334 "$node_(7) setdest 509.763123 1261.630615 1000.000000"
$ns_ at 6.533334 "$node_(8) setdest 528.055054 1368.267822 1000.000000"
$ns_ at 6.533334 "$node_(9) setdest 882.715027 1730.564941 1000.000000"
$ns_ at 6.600000 "$node_(0) setdest 876.288757 1568.393433 1000.000000"
$ns_ at 6.600000 "$node_(1) setdest 283.673157 1169.419678 421.993853"
$ns_ at 6.600000 "$node_(2) setdest 510.419373 1405.508057 942.310875"
$ns_ at 6.600000 "$node_(3) setdest 375.492126 1488.093384 815.253711"
$ns_ at 6.600000 "$node_(4) setdest 508.276642 1293.241699 43.854151"
$ns_ at 6.600000 "$node_(5) setdest 0.000100 1316.066040 1000.000000"
$ns_ at 6.600000 "$node_(6) setdest 649.770142 1048.453125 750.904616"
$ns_ at 6.600000 "$node_(7) setdest 509.763123 1231.364258 113.498834"
$ns_ at 6.600000 "$node_(8) setdest 708.055054 1379.703491 676.360839"
$ns_ at 6.600000 "$node_(9) setdest 502.639740 1400.218994 1000.000000"
$ns_ at 6.666667 "$node_(0) setdest 476.288757 1312.701904 1000.000000"
$ns_ at 6.666667 "$node_(1) setdest 472.906616 1319.406616 905.493975"
$ns_ at 6.666667 "$node_(2) setdest 499.536530 1590.586304 695.242216"
$ns_ at 6.666667 "$node_(3) setdest 19.492117 1629.317749 1000.000000"
$ns_ at 6.666667 "$node_(4) setdest 486.286316 1315.872437 118.331638"
$ns_ at 6.666667 "$node_(5) setdest 369.798248 1316.923462 1000.000000"
$ns_ at 6.666667 "$node_(6) setdest 453.271729 1368.453125 1000.000000"
$ns_ at 6.666667 "$node_(7) setdest 549.168213 831.364197 1000.000000"
$ns_ at 6.666667 "$node_(8) setdest 440.055054 1319.139160 1000.000000"
$ns_ at 6.666667 "$node_(9) setdest 838.564453 1605.873047 1000.000000"
$ns_ at 6.733334 "$node_(0) setdest 628.288757 1349.010376 586.036346"
$ns_ at 6.733334 "$node_(1) setdest 398.140076 1309.393555 282.877707"
$ns_ at 6.733334 "$node_(2) setdest 432.653656 1355.664551 915.964231"
$ns_ at 6.733334 "$node_(3) setdest 419.492126 1405.922852 1000.000000"
$ns_ at 6.733334 "$node_(4) setdest 692.295959 1182.503296 920.296850"
$ns_ at 6.733334 "$node_(5) setdest 213.798248 1353.781006 601.106097"
$ns_ at 6.733334 "$node_(6) setdest 396.773315 1460.453125 404.862306"
$ns_ at 6.733334 "$node_(7) setdest 471.701355 1231.364258 1000.000000"
$ns_ at 6.733334 "$node_(8) setdest 384.055054 1118.574951 780.882871"
$ns_ at 6.733334 "$node_(9) setdest 438.564423 1394.146729 1000.000000"
$ns_ at 6.800000 "$node_(0) setdest 876.288757 1493.318726 1000.000000"
$ns_ at 6.800000 "$node_(1) setdest 639.373535 1263.380493 920.934457"
$ns_ at 6.800000 "$node_(2) setdest 409.770813 1320.742798 156.566569"
$ns_ at 6.800000 "$node_(3) setdest 331.492126 1550.527954 634.787946"
$ns_ at 6.800000 "$node_(4) setdest 442.305603 1213.134033 944.474667"
$ns_ at 6.800000 "$node_(5) setdest 0.000100 994.638550 1000.000000"
$ns_ at 6.800000 "$node_(6) setdest 432.274902 1376.453125 341.977826"
$ns_ at 6.800000 "$node_(7) setdest 334.234528 1055.364258 837.460913"
$ns_ at 6.800000 "$node_(8) setdest 440.055054 1306.010620 733.584041"
$ns_ at 6.800000 "$node_(9) setdest 597.690430 1475.813232 670.720790"
$ns_ at 6.866667 "$node_(0) setdest 476.288757 1301.699585 1000.000000"
$ns_ at 6.866667 "$node_(1) setdest 968.606995 1269.367310 1000.000000"
$ns_ at 6.866667 "$node_(2) setdest 310.887970 1377.821045 428.153149"
$ns_ at 6.866667 "$node_(3) setdest 394.092377 1594.157593 286.140875"
$ns_ at 6.866667 "$node_(4) setdest 580.910583 813.134033 1000.000000"
$ns_ at 6.866667 "$node_(5) setdest 373.798248 1263.877563 1000.000000"
$ns_ at 6.866667 "$node_(6) setdest 567.776489 1364.453125 510.119621"
$ns_ at 6.866667 "$node_(7) setdest 480.767700 1335.364258 1000.000000"
$ns_ at 6.866667 "$node_(8) setdest 444.055054 1161.446289 542.323695"
$ns_ at 6.866667 "$node_(9) setdest 439.864288 1282.978271 934.453076"
$ns_ at 6.933334 "$node_(0) setdest 680.288757 1362.080444 797.806164"
$ns_ at 6.933334 "$node_(1) setdest 568.606995 1247.991089 1000.000000"
$ns_ at 6.933334 "$node_(2) setdest 596.005127 1230.899292 1000.000000"
$ns_ at 6.933334 "$node_(3) setdest 572.692627 1205.787109 1000.000000"
$ns_ at 6.933334 "$node_(4) setdest 555.418152 1213.134033 1000.000000"
$ns_ at 6.933334 "$node_(5) setdest 0.000100 1256.914917 1000.000000"
$ns_ at 6.933334 "$node_(6) setdest 693.880554 1764.453125 1000.000000"
$ns_ at 6.933334 "$node_(7) setdest 317.924469 1735.364258 1000.000000"
$ns_ at 6.933334 "$node_(8) setdest 215.042496 970.701782 1000.000000"
$ns_ at 6.933334 "$node_(9) setdest 54.038113 1498.143188 1000.000000"
$ns_ at 7.000000 "$node_(0) setdest 367.137756 1411.320923 1000.000000"
$ns_ at 7.000000 "$node_(1) setdest 352.606995 1526.614868 1000.000000"
$ns_ at 7.000000 "$node_(2) setdest 353.122253 1491.977539 1000.000000"
$ns_ at 7.000000 "$node_(3) setdest 327.292908 1477.416748 1000.000000"
$ns_ at 7.000000 "$node_(4) setdest 521.925720 1201.134033 133.414800"
$ns_ at 7.000000 "$node_(5) setdest 373.798248 1414.983887 1000.000000"
$ns_ at 7.000000 "$node_(6) setdest 322.280670 1364.453125 1000.000000"
$ns_ at 7.000000 "$node_(7) setdest 367.081207 1343.364258 1000.000000"
$ns_ at 7.000000 "$node_(8) setdest 340.768555 1351.036743 1000.000000"
$ns_ at 7.000000 "$node_(9) setdest 420.211945 1393.308228 1000.000000"
$ns_ at 7.066667 "$node_(0) setdest 429.986786 1376.561279 269.328132"
$ns_ at 7.066667 "$node_(1) setdest 298.223694 1926.614868 1000.000000"
$ns_ at 7.066667 "$node_(2) setdest 281.885712 1891.977539 1000.000000"
$ns_ at 7.066667 "$node_(3) setdest 137.596176 1877.416748 1000.000000"
$ns_ at 7.066667 "$node_(4) setdest 897.655884 801.134033 1000.000000"
$ns_ at 7.066667 "$node_(5) setdest 269.798248 1681.052979 1000.000000"
$ns_ at 7.066667 "$node_(6) setdest 94.680771 1492.453125 979.214693"
$ns_ at 7.066667 "$node_(7) setdest 228.237961 1411.364258 579.753426"
$ns_ at 7.066667 "$node_(8) setdest 254.494644 1283.371704 411.163938"
$ns_ at 7.066667 "$node_(9) setdest 458.385773 1460.473145 289.707026"
$ns_ at 7.133334 "$node_(0) setdest 248.835785 1589.801758 1000.000000"
$ns_ at 7.133334 "$node_(1) setdest 459.840393 1618.614868 1000.000000"
$ns_ at 7.133334 "$node_(2) setdest 298.465118 1575.490845 1000.000000"
$ns_ at 7.133334 "$node_(3) setdest 195.899460 1769.416748 460.246959"
$ns_ at 7.133334 "$node_(4) setdest 607.381348 1201.134033 1000.000000"
$ns_ at 7.133334 "$node_(5) setdest 369.798248 1723.121948 406.832607"
$ns_ at 7.133334 "$node_(6) setdest 187.080872 1548.453125 405.169723"
$ns_ at 7.133334 "$node_(7) setdest 241.394714 1311.364258 378.231677"
$ns_ at 7.133334 "$node_(8) setdest 316.220703 1659.706665 1000.000000"
$ns_ at 7.133334 "$node_(9) setdest 576.559631 1179.638062 1000.000000"
$ns_ at 7.200000 "$node_(0) setdest 395.684814 1295.042114 1000.000000"
$ns_ at 7.200000 "$node_(1) setdest 481.457092 1494.614868 472.012858"
$ns_ at 7.200000 "$node_(2) setdest 383.044556 1375.004150 815.989910"
$ns_ at 7.200000 "$node_(3) setdest 254.202728 1609.416748 638.593907"
$ns_ at 7.200000 "$node_(4) setdest 369.106812 1505.134033 1000.000000"
$ns_ at 7.200000 "$node_(5) setdest 469.798248 1601.190918 591.349838"
$ns_ at 7.200000 "$node_(6) setdest 67.480965 1444.453125 594.349964"
$ns_ at 7.200000 "$node_(7) setdest 234.551453 1487.364258 660.498699"
$ns_ at 7.200000 "$node_(8) setdest 114.293655 1954.905762 1000.000000"
$ns_ at 7.200000 "$node_(9) setdest 526.733459 1386.803101 799.022785"
$ns_ at 7.266667 "$node_(0) setdest 234.533813 1088.282593 983.037592"
$ns_ at 7.266667 "$node_(1) setdest 367.073761 1514.614868 435.445009"
$ns_ at 7.266667 "$node_(2) setdest 455.623962 1306.517456 374.215374"
$ns_ at 7.266667 "$node_(3) setdest 216.506012 1741.416748 514.789669"
$ns_ at 7.266667 "$node_(4) setdest 210.832291 1505.134033 593.529422"
$ns_ at 7.266667 "$node_(5) setdest 385.798248 1603.260010 315.095542"
$ns_ at 7.266667 "$node_(6) setdest 35.881058 1428.453125 132.823813"
$ns_ at 7.266667 "$node_(7) setdest 59.708202 1335.364258 868.788140"
$ns_ at 7.266667 "$node_(8) setdest 264.340424 1621.058960 1000.000000"
$ns_ at 7.266667 "$node_(9) setdest 448.907288 1377.968018 293.722700"
$ns_ at 7.333334 "$node_(0) setdest 217.382828 1441.522949 1000.000000"
$ns_ at 7.333334 "$node_(1) setdest 508.690460 1398.614868 686.478274"
$ns_ at 7.333334 "$node_(2) setdest 172.203369 1402.030762 1000.000000"
$ns_ at 7.333334 "$node_(3) setdest 42.809292 1473.416748 1000.000000"
$ns_ at 7.333334 "$node_(4) setdest 392.557770 1649.134033 869.483769"
$ns_ at 7.333334 "$node_(5) setdest 357.798248 1481.328979 469.142451"
$ns_ at 7.333334 "$node_(6) setdest 208.281158 1476.453125 671.090663"
$ns_ at 7.333334 "$node_(7) setdest 0.000100 1095.364258 1000.000000"
$ns_ at 7.333334 "$node_(8) setdest 146.387177 1687.212280 507.141297"
$ns_ at 7.333334 "$node_(9) setdest 275.081116 1289.132935 732.040005"
$ns_ at 7.400000 "$node_(0) setdest 340.231842 1514.763428 536.342383"
$ns_ at 7.400000 "$node_(1) setdest 147.101517 1435.664551 1000.000000"
$ns_ at 7.400000 "$node_(2) setdest 0.000100 1161.544067 1000.000000"
$ns_ at 7.400000 "$node_(3) setdest 93.112572 1485.416748 193.930468"
$ns_ at 7.400000 "$node_(4) setdest 126.283226 1389.134033 1000.000000"
$ns_ at 7.400000 "$node_(5) setdest 321.798248 1407.398071 308.362640"
$ns_ at 7.400000 "$node_(6) setdest 156.681244 1568.453125 395.559233"
$ns_ at 7.400000 "$node_(7) setdest 186.021698 1423.364258 1000.000000"
$ns_ at 7.400000 "$node_(8) setdest 0.000100 1685.365601 637.362237"
$ns_ at 7.400000 "$node_(9) setdest 485.254974 1108.297974 1000.000000"
$ns_ at 7.466667 "$node_(0) setdest 655.080872 1604.003784 1000.000000"
$ns_ at 7.466667 "$node_(1) setdest 41.512562 1428.714111 396.815480"
$ns_ at 7.466667 "$node_(2) setdest 193.362198 1445.057495 1000.000000"
$ns_ at 7.466667 "$node_(3) setdest 211.415848 1289.416748 858.509744"
$ns_ at 7.466667 "$node_(4) setdest 0.000100 1101.134033 1000.000000"
$ns_ at 7.466667 "$node_(5) setdest 549.798218 1185.467041 1000.000000"
$ns_ at 7.466667 "$node_(6) setdest 77.081345 1640.453125 402.494724"
$ns_ at 7.466667 "$node_(7) setdest 95.178452 1339.364258 463.978133"
$ns_ at 7.466667 "$node_(8) setdest 162.480682 1367.518799 1000.000000"
$ns_ at 7.466667 "$node_(9) setdest 85.254967 1334.274902 1000.000000"
$ns_ at 7.533334 "$node_(0) setdest 255.080856 1352.774414 1000.000000"
$ns_ at 7.533334 "$node_(1) setdest 0.000100 1685.763794 1000.000000"
$ns_ at 7.533334 "$node_(2) setdest 373.941620 1672.570801 1000.000000"
$ns_ at 7.533334 "$node_(3) setdest 353.719116 1309.416748 538.881884"
$ns_ at 7.533334 "$node_(4) setdest 281.734161 1381.134033 1000.000000"
$ns_ at 7.533334 "$node_(5) setdest 373.798248 1247.536011 699.840280"
$ns_ at 7.533334 "$node_(6) setdest 257.481445 1288.453125 1000.000000"
$ns_ at 7.533334 "$node_(7) setdest 0.000100 1315.330322 1000.000000"
$ns_ at 7.533334 "$node_(8) setdest 0.000100 1480.866821 1000.000000"
$ns_ at 7.533334 "$node_(9) setdest 0.000100 1284.251831 1000.000000"
$ns_ at 7.600000 "$node_(0) setdest 0.000100 1618.929565 1000.000000"
$ns_ at 7.600000 "$node_(1) setdest 0.000100 1475.523804 1000.000000"
$ns_ at 7.600000 "$node_(2) setdest 0.000100 1380.084106 1000.000000"
$ns_ at 7.600000 "$node_(3) setdest 164.022400 1389.416748 772.034185"
$ns_ at 7.600000 "$node_(4) setdest 23.459633 1621.134033 1000.000000"
$ns_ at 7.600000 "$node_(5) setdest 137.798248 1401.605103 1000.000000"
$ns_ at 7.600000 "$node_(6) setdest 89.881538 1380.453125 716.963559"
$ns_ at 7.600000 "$node_(7) setdest 0.000100 1285.550171 648.787903"
$ns_ at 7.600000 "$node_(8) setdest 43.328606 1429.088257 584.411686"
$ns_ at 7.600000 "$node_(9) setdest 93.254967 1446.228882 1000.000000"
$ns_ at 7.666667 "$node_(0) setdest 0.000100 1773.084717 1000.000000"
$ns_ at 7.666667 "$node_(1) setdest 0.000100 1827.716064 1000.000000"
$ns_ at 7.666667 "$node_(2) setdest 0.000100 1457.201050 1000.000000"
$ns_ at 7.666667 "$node_(3) setdest 254.325684 1401.416748 341.614133"
$ns_ at 7.666667 "$node_(4) setdest 0.000100 1809.134033 802.570740"
$ns_ at 7.666667 "$node_(5) setdest 181.798248 1427.674072 191.785674"
$ns_ at 7.666667 "$node_(6) setdest 210.281631 1468.453125 559.242811"
$ns_ at 7.666667 "$node_(7) setdest 0.000100 1199.770142 975.460803"
$ns_ at 7.666667 "$node_(8) setdest 0.000100 1433.309814 1000.000000"
$ns_ at 7.666667 "$node_(9) setdest 0.000100 1456.205811 990.706735"
$ns_ at 7.733334 "$node_(0) setdest 0.000100 1579.239868 1000.000000"
$ns_ at 7.733334 "$node_(1) setdest 0.000100 1589.406372 1000.000000"
$ns_ at 7.733334 "$node_(2) setdest 0.000100 1382.317993 1000.000000"
$ns_ at 7.733334 "$node_(3) setdest 0.000100 1555.448853 1000.000000"
$ns_ at 7.733334 "$node_(4) setdest 0.000100 1569.134033 1000.000000"
$ns_ at 7.733334 "$node_(5) setdest 0.000100 1548.355713 1000.000000"
$ns_ at 7.733334 "$node_(6) setdest 0.000100 1575.996094 1000.000000"
$ns_ at 7.733334 "$node_(7) setdest 0.000100 1599.770142 1000.000000"
$ns_ at 7.733334 "$node_(8) setdest 0.000100 1033.309814 1000.000000"
$ns_ at 7.733334 "$node_(9) setdest 0.000100 1056.205811 1000.000000"
$ns_ at 7.800000 "$node_(0) setdest 0.000100 1405.395020 1000.000000"
$ns_ at 7.800000 "$node_(1) setdest 0.000100 1467.096680 1000.000000"
$ns_ at 7.800000 "$node_(2) setdest 0.000100 1295.434937 1000.000000"
$ns_ at 7.800000 "$node_(3) setdest 0.000100 1269.481079 1000.000000"
$ns_ at 7.800000 "$node_(4) setdest 0.000100 1361.134033 1000.000000"
$ns_ at 7.800000 "$node_(5) setdest 0.000100 1269.037476 1000.000000"
$ns_ at 7.800000 "$node_(6) setdest 0.000100 1319.539062 971.142833"
$ns_ at 7.800000 "$node_(7) setdest 0.000100 1307.770142 1000.000000"
$ns_ at 7.800000 "$node_(8) setdest 0.000100 1433.309814 1000.000000"
$ns_ at 7.800000 "$node_(9) setdest 0.000100 1448.205811 1000.000000"
$ns_ at 7.866667 "$node_(0) setdest 0.000100 1311.550171 1000.000000"
$ns_ at 7.866667 "$node_(1) setdest 0.000100 1532.786987 621.864592"
$ns_ at 7.866667 "$node_(2) setdest 0.000100 895.434937 1000.000000"
$ns_ at 7.866667 "$node_(3) setdest 0.000100 1255.513184 736.864032"
$ns_ at 7.866667 "$node_(4) setdest 0.000100 1113.134033 1000.000000"
$ns_ at 7.866667 "$node_(5) setdest 0.000100 1287.878418 646.346306"
$ns_ at 7.866667 "$node_(6) setdest 34.281639 1087.082031 1000.000000"
$ns_ at 7.866667 "$node_(7) setdest 0.000100 1239.770142 380.882329"
$ns_ at 7.866667 "$node_(8) setdest 0.000100 1413.309814 223.510139"
$ns_ at 7.866667 "$node_(9) setdest 0.000100 1472.205811 308.919366"
$ns_ at 7.933334 "$node_(0) setdest 0.000100 1237.705322 442.389742"
$ns_ at 7.933334 "$node_(1) setdest 0.000100 1132.786987 1000.000000"
$ns_ at 7.933334 "$node_(2) setdest 0.000100 1160.521484 1000.000000"
$ns_ at 7.933334 "$node_(3) setdest 0.000100 1233.545288 87.672110"
$ns_ at 7.933334 "$node_(4) setdest 0.000100 857.134033 1000.000000"
$ns_ at 7.933334 "$node_(5) setdest 0.000100 1430.719482 535.799189"
$ns_ at 7.933334 "$node_(6) setdest 0.000100 1194.625000 1000.000000"
$ns_ at 7.933334 "$node_(7) setdest 0.000100 991.770081 932.854966"
$ns_ at 7.933334 "$node_(8) setdest 0.000100 1085.309814 1000.000000"
$ns_ at 7.933334 "$node_(9) setdest 0.000100 1132.205811 1000.000000"
$ns_ at 8.000000 "$node_(0) setdest 315.080872 1245.011230 1000.000000"
$ns_ at 8.000000 "$node_(1) setdest 0.000100 1156.786987 170.174251"
$ns_ at 8.000000 "$node_(2) setdest 0.000100 1153.608032 65.361575"
$ns_ at 8.000000 "$node_(3) setdest 0.000100 1091.577515 716.817647"
$ns_ at 8.000000 "$node_(4) setdest 0.000100 984.721008 1000.000000"
$ns_ at 8.000000 "$node_(5) setdest 0.000100 1030.719482 1000.000000"
$ns_ at 8.000000 "$node_(6) setdest 0.000100 1310.167969 463.639788"
$ns_ at 8.000000 "$node_(7) setdest 0.000100 591.770081 1000.000000"
$ns_ at 8.000000 "$node_(8) setdest 111.699371 1061.309814 533.201609"
$ns_ at 8.000000 "$node_(9) setdest 159.230331 1076.205811 1000.000000"
$ns_ at 8.066667 "$node_(0) setdest 82.874466 993.736084 1000.000000"
$ns_ at 8.066667 "$node_(1) setdest 133.621887 1120.786987 1000.000000"
$ns_ at 8.066667 "$node_(2) setdest 0.000100 1330.694702 1000.000000"
$ns_ at 8.066667 "$node_(3) setdest 146.325684 1061.609619 951.658581"
$ns_ at 8.066667 "$node_(4) setdest 0.000100 936.308044 991.758447"
$ns_ at 8.066667 "$node_(5) setdest 60.438919 1122.719482 802.055985"
$ns_ at 8.066667 "$node_(6) setdest 90.281639 1007.262878 1000.000000"
$ns_ at 8.066667 "$node_(7) setdest 83.499100 991.770081 1000.000000"
$ns_ at 8.066667 "$node_(8) setdest 257.845612 1194.641113 741.855373"
$ns_ at 8.066667 "$node_(9) setdest 444.425415 1152.205811 1000.000000"
$ns_ at 8.133334 "$node_(0) setdest 446.668060 874.460999 1000.000000"
$ns_ at 8.133334 "$node_(1) setdest 533.621887 1460.735352 1000.000000"
$ns_ at 8.133334 "$node_(2) setdest 359.560974 1071.781250 1000.000000"
$ns_ at 8.133334 "$node_(3) setdest 546.325684 1177.327393 1000.000000"
$ns_ at 8.133334 "$node_(4) setdest 0.000100 823.895020 421.548821"
$ns_ at 8.133334 "$node_(5) setdest 309.522705 1350.719482 1000.000000"
$ns_ at 8.133334 "$node_(6) setdest 338.281647 1164.357788 1000.000000"
$ns_ at 8.133334 "$node_(7) setdest 351.472534 1079.770142 1000.000000"
$ns_ at 8.133334 "$node_(8) setdest 337.621063 1103.783936 453.411260"
$ns_ at 8.133334 "$node_(9) setdest 837.620483 1096.205811 1000.000000"
$ns_ at 8.200000 "$node_(0) setdest 758.461670 995.185913 1000.000000"
$ns_ at 8.200000 "$node_(1) setdest 661.621887 1080.683716 1000.000000"
$ns_ at 8.200000 "$node_(2) setdest 727.560974 1052.867798 1000.000000"
$ns_ at 8.200000 "$node_(3) setdest 628.175293 1148.904297 324.916031"
$ns_ at 8.200000 "$node_(4) setdest 336.086975 1005.156982 1000.000000"
$ns_ at 8.200000 "$node_(5) setdest 670.606445 1286.719482 1000.000000"
$ns_ at 8.200000 "$node_(6) setdest 686.281616 1437.452759 1000.000000"
$ns_ at 8.200000 "$node_(7) setdest 715.445984 1195.770142 1000.000000"
$ns_ at 8.200000 "$node_(8) setdest 713.396484 1160.926758 1000.000000"
$ns_ at 8.200000 "$node_(9) setdest 830.815552 1192.205811 360.903292"
$ns_ at 8.266667 "$node_(0) setdest 1038.255249 695.910828 1000.000000"
$ns_ at 8.266667 "$node_(1) setdest 825.621887 1008.632202 671.736053"
$ns_ at 8.266667 "$node_(2) setdest 955.560974 905.954346 1000.000000"
$ns_ at 8.266667 "$node_(3) setdest 758.024902 996.481201 750.878066"
$ns_ at 8.266667 "$node_(4) setdest 736.086975 1122.411377 1000.000000"
$ns_ at 8.266667 "$node_(5) setdest 835.690247 1250.719482 633.613038"
$ns_ at 8.266667 "$node_(6) setdest 794.281616 1318.547729 602.367236"
$ns_ at 8.266667 "$node_(7) setdest 650.658752 1595.770142 1000.000000"
$ns_ at 8.266667 "$node_(8) setdest 557.171936 1354.069580 931.558065"
$ns_ at 8.266667 "$node_(9) setdest 1096.010620 1308.205811 1000.000000"
$ns_ at 8.333334 "$node_(0) setdest 967.086853 1095.910767 1000.000000"
$ns_ at 8.333334 "$node_(1) setdest 797.621887 1080.580566 289.517655"
$ns_ at 8.333334 "$node_(2) setdest 1151.561035 1107.040894 1000.000000"
$ns_ at 8.333334 "$node_(3) setdest 1003.874573 1064.058105 956.130073"
$ns_ at 8.333334 "$node_(4) setdest 904.086975 951.665771 898.264399"
$ns_ at 8.333334 "$node_(5) setdest 808.773987 1334.719482 330.776436"
$ns_ at 8.333334 "$node_(6) setdest 982.281616 1151.642578 942.745236"
$ns_ at 8.333334 "$node_(7) setdest 926.758606 1195.770142 1000.000000"
$ns_ at 8.333334 "$node_(8) setdest 957.171936 1154.928711 1000.000000"
$ns_ at 8.333334 "$node_(9) setdest 1357.205688 1548.205811 1000.000000"
$ns_ at 8.400000 "$node_(0) setdest 1155.918335 971.910828 847.145761"
$ns_ at 8.400000 "$node_(1) setdest 1029.621948 1112.529053 878.210690"
$ns_ at 8.400000 "$node_(2) setdest 1551.561035 1076.681396 1000.000000"
$ns_ at 8.400000 "$node_(3) setdest 1381.724121 987.634949 1000.000000"
$ns_ at 8.400000 "$node_(4) setdest 1080.086914 1024.920166 714.885941"
$ns_ at 8.400000 "$node_(5) setdest 749.857788 1658.719482 1000.000000"
$ns_ at 8.400000 "$node_(6) setdest 1126.281616 1272.737549 705.558149"
$ns_ at 8.400000 "$node_(7) setdest 762.858398 1355.770142 858.932317"
$ns_ at 8.400000 "$node_(8) setdest 829.171936 1211.787964 525.227252"
$ns_ at 8.400000 "$node_(9) setdest 1117.571533 1148.205811 1000.000000"
$ns_ at 8.466667 "$node_(0) setdest 1280.749878 1091.910767 649.333901"
$ns_ at 8.466667 "$node_(1) setdest 1077.621948 1168.477417 276.439319"
$ns_ at 8.466667 "$node_(2) setdest 1151.561035 1191.888672 1000.000000"
$ns_ at 8.466667 "$node_(3) setdest 1107.573730 1227.211792 1000.000000"
$ns_ at 8.466667 "$node_(4) setdest 1056.086914 918.174561 410.288780"
$ns_ at 8.466667 "$node_(5) setdest 1095.174438 1258.719482 1000.000000"
$ns_ at 8.466667 "$node_(6) setdest 1094.500244 1672.737549 1000.000000"
$ns_ at 8.466667 "$node_(7) setdest 1162.858398 1304.297607 1000.000000"
$ns_ at 8.466667 "$node_(8) setdest 1221.171875 1188.647095 1000.000000"
$ns_ at 8.466667 "$node_(9) setdest 933.937317 848.205811 1000.000000"
$ns_ at 8.533334 "$node_(0) setdest 1677.581421 695.910828 1000.000000"
$ns_ at 8.533334 "$node_(1) setdest 917.621887 1088.425903 670.906986"
$ns_ at 8.533334 "$node_(2) setdest 1219.561035 975.096008 852.026494"
$ns_ at 8.533334 "$node_(3) setdest 1033.423462 1094.788696 569.137544"
$ns_ at 8.533334 "$node_(4) setdest 1128.086914 1243.428955 1000.000000"
$ns_ at 8.533334 "$node_(5) setdest 936.491028 1254.719482 595.251758"
$ns_ at 8.533334 "$node_(6) setdest 1142.205566 1272.737549 1000.000000"
$ns_ at 8.533334 "$node_(7) setdest 1078.858398 1328.825195 328.153965"
$ns_ at 8.533334 "$node_(8) setdest 1521.171875 1065.506226 1000.000000"
$ns_ at 8.533334 "$node_(9) setdest 1194.486694 1248.205811 1000.000000"
$ns_ at 8.600000 "$node_(0) setdest 1277.581421 1049.610229 1000.000000"
$ns_ at 8.600000 "$node_(1) setdest 1269.722412 1070.229492 1000.000000"
$ns_ at 8.600000 "$node_(2) setdest 1327.561035 810.303345 738.860569"
$ns_ at 8.600000 "$node_(3) setdest 1283.273071 1074.365601 940.060910"
$ns_ at 8.600000 "$node_(4) setdest 1242.807251 1036.622681 886.853897"
$ns_ at 8.600000 "$node_(5) setdest 1161.807617 978.719421 1000.000000"
$ns_ at 8.600000 "$node_(6) setdest 1125.910767 1252.737549 96.741309"
$ns_ at 8.600000 "$node_(7) setdest 1114.858398 1193.352783 525.652801"
$ns_ at 8.600000 "$node_(8) setdest 1193.171875 1078.365479 1000.000000"
$ns_ at 8.600000 "$node_(9) setdest 1152.478516 1648.205811 1000.000000"
$ns_ at 8.666667 "$node_(0) setdest 1677.581421 948.322571 1000.000000"
$ns_ at 8.666667 "$node_(1) setdest 1669.722412 931.191223 1000.000000"
$ns_ at 8.666667 "$node_(2) setdest 1391.561035 989.510681 713.597165"
$ns_ at 8.666667 "$node_(3) setdest 1683.273071 1034.128540 1000.000000"
$ns_ at 8.666667 "$node_(4) setdest 1345.527588 1045.816284 386.740989"
$ns_ at 8.666667 "$node_(5) setdest 1015.124268 990.719421 551.900167"
$ns_ at 8.666667 "$node_(6) setdest 1197.616089 1328.737549 391.828374"
$ns_ at 8.666667 "$node_(7) setdest 1178.858398 1229.880371 276.338725"
$ns_ at 8.666667 "$node_(8) setdest 1265.171875 1291.224609 842.649321"
$ns_ at 8.666667 "$node_(9) setdest 1216.624390 1248.205811 1000.000000"
$ns_ at 8.733334 "$node_(0) setdest 1453.581421 1043.034912 912.001372"
$ns_ at 8.733334 "$node_(1) setdest 1445.722412 1016.152893 898.392917"
$ns_ at 8.733334 "$node_(2) setdest 1467.561035 1052.718018 370.684528"
$ns_ at 8.733334 "$node_(3) setdest 1455.273071 1093.891479 883.883869"
$ns_ at 8.733334 "$node_(4) setdest 1300.247925 1051.010010 170.912080"
$ns_ at 8.733334 "$node_(5) setdest 1415.124268 1067.136719 1000.000000"
$ns_ at 8.733334 "$node_(6) setdest 1521.321411 1136.737549 1000.000000"
$ns_ at 8.733334 "$node_(7) setdest 1502.858398 1054.407959 1000.000000"
$ns_ at 8.733334 "$node_(8) setdest 1341.171875 1240.083740 343.516942"
$ns_ at 8.733334 "$node_(9) setdest 1336.770264 1292.205811 479.809974"
$ns_ at 8.800000 "$node_(0) setdest 1533.581421 745.747253 1000.000000"
$ns_ at 8.800000 "$node_(1) setdest 1377.722412 781.114624 917.539854"
$ns_ at 8.800000 "$node_(2) setdest 1455.561035 963.925293 335.999719"
$ns_ at 8.800000 "$node_(3) setdest 1667.273071 781.654358 1000.000000"
$ns_ at 8.800000 "$node_(4) setdest 1466.968262 920.203674 794.663502"
$ns_ at 8.800000 "$node_(5) setdest 1279.124268 1023.554138 535.547248"
$ns_ at 8.800000 "$node_(6) setdest 1825.026733 948.737549 1000.000000"
$ns_ at 8.800000 "$node_(7) setdest 1494.858398 1214.935547 602.725493"
$ns_ at 8.800000 "$node_(8) setdest 1337.171875 1120.942993 447.029520"
$ns_ at 8.800000 "$node_(9) setdest 1488.916138 1252.205811 589.935463"
$ns_ at 8.866667 "$node_(0) setdest 1621.581421 712.459534 352.820416"
$ns_ at 8.866667 "$node_(1) setdest 1505.722412 694.076294 580.459183"
$ns_ at 8.866667 "$node_(2) setdest 1743.868164 789.368469 1000.000000"
$ns_ at 8.866667 "$node_(3) setdest 1659.273071 1029.417236 929.594945"
$ns_ at 8.866667 "$node_(4) setdest 1553.688599 849.397400 419.831607"
$ns_ at 8.866667 "$node_(5) setdest 1576.476929 851.399231 1000.000000"
$ns_ at 8.866667 "$node_(6) setdest 1580.732056 1008.737549 943.331002"
$ns_ at 8.866667 "$node_(7) setdest 1726.858398 883.463074 1000.000000"
$ns_ at 8.866667 "$node_(8) setdest 1433.524780 720.942932 1000.000000"
$ns_ at 8.866667 "$node_(9) setdest 1547.230591 852.205811 1000.000000"
$ns_ at 8.933334 "$node_(0) setdest 1823.623901 312.459564 1000.000000"
$ns_ at 8.933334 "$node_(1) setdest 1596.662476 294.076294 1000.000000"
$ns_ at 8.933334 "$node_(2) setdest 1999.999900 495.654297 1000.000000"
$ns_ at 8.933334 "$node_(3) setdest 1690.963379 752.676147 1000.000000"
$ns_ at 8.933334 "$node_(4) setdest 1468.408813 722.591064 573.057030"
$ns_ at 8.933334 "$node_(5) setdest 1581.829468 739.244324 421.059558"
$ns_ at 8.933334 "$node_(6) setdest 1620.437378 944.737549 282.435307"
$ns_ at 8.933334 "$node_(7) setdest 1990.858398 819.990662 1000.000000"
$ns_ at 8.933334 "$node_(8) setdest 1449.877563 592.942932 483.901323"
$ns_ at 8.933334 "$node_(9) setdest 1529.544922 944.205811 351.316806"
$ns_ at 9.000000 "$node_(0) setdest 1749.666382 544.459534 913.136110"
$ns_ at 9.000000 "$node_(1) setdest 1783.602539 546.076294 1000.000000"
$ns_ at 9.000000 "$node_(2) setdest 1743.868164 512.277771 1000.000000"
$ns_ at 9.000000 "$node_(3) setdest 1999.999900 352.676178 1000.000000"
$ns_ at 9.000000 "$node_(4) setdest 1703.129150 459.784760 1000.000000"
$ns_ at 9.000000 "$node_(5) setdest 1791.182129 471.089386 1000.000000"
$ns_ at 9.000000 "$node_(6) setdest 1825.001587 544.737549 1000.000000"
$ns_ at 9.000000 "$node_(7) setdest 1726.858398 460.518250 1000.000000"
$ns_ at 9.000000 "$node_(8) setdest 1806.230469 488.942932 1000.000000"
$ns_ at 9.000000 "$node_(9) setdest 1739.091064 544.205811 1000.000000"
$ns_ at 9.066667 "$node_(0) setdest 1775.708740 604.459534 245.279919"
$ns_ at 9.066667 "$node_(1) setdest 1999.999900 614.076294 917.186117"
$ns_ at 9.066667 "$node_(2) setdest 1807.868164 408.901245 455.940547"
$ns_ at 9.066667 "$node_(3) setdest 1999.999900 168.676163 692.445566"
$ns_ at 9.066667 "$node_(4) setdest 1393.849487 176.978455 1000.000000"
$ns_ at 9.066667 "$node_(5) setdest 1936.534790 106.934479 1000.000000"
$ns_ at 9.066667 "$node_(6) setdest 1937.565796 488.737518 471.467661"
$ns_ at 9.066667 "$node_(7) setdest 1750.858398 281.045807 679.012606"
$ns_ at 9.066667 "$node_(8) setdest 1790.583252 336.942932 573.012170"
$ns_ at 9.066667 "$node_(9) setdest 1604.637085 532.205811 506.206543"
$ns_ at 9.133334 "$node_(0) setdest 1613.751221 516.459534 691.203768"
$ns_ at 9.133334 "$node_(1) setdest 1849.482544 330.076294 1000.000000"
$ns_ at 9.133334 "$node_(2) setdest 1707.868164 445.524750 399.357927"
$ns_ at 9.133334 "$node_(3) setdest 1999.999900 180.676163 112.534076"
$ns_ at 9.133334 "$node_(4) setdest 1793.849487 270.004120 1000.000000"
$ns_ at 9.133334 "$node_(5) setdest 1981.887329 0.000100 813.556037"
$ns_ at 9.133334 "$node_(6) setdest 1999.999900 544.737549 355.718289"
$ns_ at 9.133334 "$node_(7) setdest 1670.858398 9.573378 1000.000000"
$ns_ at 9.133334 "$node_(8) setdest 1922.936157 132.942932 911.900091"
$ns_ at 9.133334 "$node_(9) setdest 1838.183105 224.205826 1000.000000"
$ns_ at 9.200000 "$node_(0) setdest 1819.793579 188.459564 1000.000000"
$ns_ at 9.200000 "$node_(1) setdest 1884.422607 518.076294 717.072221"
$ns_ at 9.200000 "$node_(2) setdest 1719.767700 45.524734 1000.000000"
$ns_ at 9.200000 "$node_(3) setdest 1984.984863 184.676163 272.268348"
$ns_ at 9.200000 "$node_(4) setdest 1469.849487 391.029755 1000.000000"
$ns_ at 9.200000 "$node_(5) setdest 1855.239990 186.624664 1000.000000"
$ns_ at 9.200000 "$node_(6) setdest 1870.494263 144.737534 1000.000000"
$ns_ at 9.200000 "$node_(7) setdest 1366.858398 0.000100 1000.000000"
$ns_ at 9.200000 "$node_(8) setdest 1943.288940 0.000100 619.717795"
$ns_ at 9.200000 "$node_(9) setdest 1647.729248 324.205811 806.665550"
$ns_ at 9.266667 "$node_(0) setdest 1485.836060 308.459564 1000.000000"
$ns_ at 9.266667 "$node_(1) setdest 1686.832520 118.076286 1000.000000"
$ns_ at 9.266667 "$node_(2) setdest 1379.667236 0.000100 1000.000000"
$ns_ at 9.266667 "$node_(3) setdest 1888.490234 120.676163 434.210678"
$ns_ at 9.266667 "$node_(4) setdest 1721.849487 48.055412 1000.000000"
$ns_ at 9.266667 "$node_(5) setdest 1912.592651 366.469757 707.882215"
$ns_ at 9.266667 "$node_(6) setdest 1994.858398 244.737534 598.432758"
$ns_ at 9.266667 "$node_(7) setdest 1688.606812 102.100952 1000.000000"
$ns_ at 9.266667 "$node_(8) setdest 1691.641846 0.000100 944.153317"
$ns_ at 9.266667 "$node_(9) setdest 1685.398193 81.215370 922.098207"
$ns_ at 9.333334 "$node_(0) setdest 1723.878418 64.459564 1000.000000"
$ns_ at 9.333334 "$node_(1) setdest 1649.242310 414.076294 1000.000000"
$ns_ at 9.333334 "$node_(2) setdest 1735.566772 129.524734 1000.000000"
$ns_ at 9.333334 "$node_(3) setdest 1999.999900 348.676178 1000.000000"
$ns_ at 9.333334 "$node_(4) setdest 1725.849487 45.081062 18.692444"
$ns_ at 9.333334 "$node_(5) setdest 1561.945190 174.314835 1000.000000"
$ns_ at 9.333334 "$node_(6) setdest 1623.222534 76.737526 1000.000000"
$ns_ at 9.333334 "$node_(7) setdest 1578.355103 310.100952 882.799942"
$ns_ at 9.333334 "$node_(8) setdest 1671.994629 0.000100 222.549565"
$ns_ at 9.333334 "$node_(9) setdest 1611.067261 310.224915 902.889529"
$ns_ at 9.400000 "$node_(0) setdest 1973.920898 256.459564 1000.000000"
$ns_ at 9.400000 "$node_(1) setdest 1703.652222 190.076294 864.425309"
$ns_ at 9.400000 "$node_(2) setdest 1971.466309 173.524734 899.879561"
$ns_ at 9.400000 "$node_(3) setdest 1815.995605 252.755234 1000.000000"
$ns_ at 9.400000 "$node_(4) setdest 1773.849487 250.106720 789.635655"
$ns_ at 9.400000 "$node_(5) setdest 1691.297852 358.159912 842.967295"
$ns_ at 9.400000 "$node_(6) setdest 1423.586792 156.737534 806.506592"
$ns_ at 9.400000 "$node_(7) setdest 1368.103516 390.100952 843.589338"
$ns_ at 9.400000 "$node_(8) setdest 1700.347534 268.942932 1000.000000"
$ns_ at 9.400000 "$node_(9) setdest 1460.736206 391.234436 640.382791"
$ns_ at 9.466667 "$node_(0) setdest 1767.963379 432.459564 1000.000000"
$ns_ at 9.466667 "$node_(1) setdest 1494.062134 30.076288 988.806101"
$ns_ at 9.466667 "$node_(2) setdest 1763.365967 297.524750 908.411875"
$ns_ at 9.466667 "$node_(3) setdest 1999.999900 36.834312 1000.000000"
$ns_ at 9.466667 "$node_(4) setdest 1725.849487 335.132355 366.145916"
$ns_ at 9.466667 "$node_(5) setdest 1500.650513 418.005005 749.323157"
$ns_ at 9.466667 "$node_(6) setdest 1693.145752 358.651459 1000.000000"
$ns_ at 9.466667 "$node_(7) setdest 1493.851807 322.100952 536.087809"
$ns_ at 9.466667 "$node_(8) setdest 1711.785400 0.000100 1000.000000"
$ns_ at 9.466667 "$node_(9) setdest 1702.405273 344.243988 923.231687"
$ns_ at 9.533334 "$node_(0) setdest 1850.005737 484.459564 364.251232"
$ns_ at 9.533334 "$node_(1) setdest 1732.471924 262.076294 1000.000000"
$ns_ at 9.533334 "$node_(2) setdest 1899.265503 101.524734 894.394122"
$ns_ at 9.533334 "$node_(3) setdest 1675.995605 245.914566 1000.000000"
$ns_ at 9.533334 "$node_(4) setdest 1785.849487 336.158020 225.032861"
$ns_ at 9.533334 "$node_(5) setdest 1370.003052 525.850098 635.282789"
$ns_ at 9.533334 "$node_(6) setdest 1826.704834 456.565399 621.020418"
$ns_ at 9.533334 "$node_(7) setdest 1519.600220 302.100952 122.262691"
$ns_ at 9.533334 "$node_(8) setdest 1689.042603 268.942932 1000.000000"
$ns_ at 9.533334 "$node_(9) setdest 1732.074219 405.253540 254.404036"
$ns_ at 9.600001 "$node_(0) setdest 1820.048218 496.459564 121.018303"
$ns_ at 9.600001 "$node_(1) setdest 1702.881836 242.076294 133.931873"
$ns_ at 9.600001 "$node_(2) setdest 1887.165039 345.524750 916.124506"
$ns_ at 9.600001 "$node_(3) setdest 1883.995605 358.994812 887.817031"
$ns_ at 9.600001 "$node_(4) setdest 1748.113159 389.107178 243.826234"
$ns_ at 9.600001 "$node_(5) setdest 1770.003052 418.059692 1000.000000"
$ns_ at 9.600001 "$node_(6) setdest 1916.263794 814.479370 1000.000000"
$ns_ at 9.600001 "$node_(7) setdest 1393.348511 538.100952 1000.000000"
$ns_ at 9.600001 "$node_(8) setdest 1378.299805 76.942932 1000.000000"
$ns_ at 9.600001 "$node_(9) setdest 1473.743286 546.263062 1000.000000"
$ns_ at 9.666667 "$node_(0) setdest 1658.090576 732.459534 1000.000000"
$ns_ at 9.666667 "$node_(1) setdest 1441.291626 258.076294 982.796465"
$ns_ at 9.666667 "$node_(2) setdest 1783.064575 425.524750 492.335218"
$ns_ at 9.666667 "$node_(3) setdest 1779.995605 480.075043 598.550060"
$ns_ at 9.666667 "$node_(4) setdest 1682.376831 510.056366 516.220810"
$ns_ at 9.666667 "$node_(5) setdest 1698.003052 366.269257 332.594530"
$ns_ at 9.666667 "$node_(6) setdest 1657.822876 436.393280 1000.000000"
$ns_ at 9.666667 "$node_(7) setdest 1731.096924 478.100952 1000.000000"
$ns_ at 9.666667 "$node_(8) setdest 1691.557129 392.942932 1000.000000"
$ns_ at 9.666667 "$node_(9) setdest 1735.412354 491.272614 1000.000000"
$ns_ at 9.733334 "$node_(0) setdest 1688.133057 444.459564 1000.000000"
$ns_ at 9.733334 "$node_(1) setdest 1723.701538 514.076294 1000.000000"
$ns_ at 9.733334 "$node_(2) setdest 1969.979370 330.247070 786.740472"
$ns_ at 9.733334 "$node_(3) setdest 1999.999900 564.693481 1000.000000"
$ns_ at 9.733334 "$node_(4) setdest 1544.640381 779.005493 1000.000000"
$ns_ at 9.733334 "$node_(5) setdest 1678.003052 506.478851 531.108142"
$ns_ at 9.733334 "$node_(6) setdest 1399.381836 326.307220 1000.000000"
$ns_ at 9.733334 "$node_(7) setdest 1768.845215 542.100952 278.636184"
$ns_ at 9.733334 "$node_(8) setdest 1529.172119 0.000100 1000.000000"
$ns_ at 9.733334 "$node_(9) setdest 1725.081299 456.282166 136.813953"
$ns_ at 9.800001 "$node_(0) setdest 1650.175537 244.459564 763.387717"
$ns_ at 9.800001 "$node_(1) setdest 1726.111450 386.076294 480.085062"
$ns_ at 9.800001 "$node_(2) setdest 1767.624268 431.561829 848.629716"
$ns_ at 9.800001 "$node_(3) setdest 1779.995605 452.676605 1000.000000"
$ns_ at 9.800001 "$node_(4) setdest 1778.904053 379.954681 1000.000000"
$ns_ at 9.800001 "$node_(5) setdest 1326.003052 766.688416 1000.000000"
$ns_ at 9.800001 "$node_(6) setdest 1799.381836 459.699493 1000.000000"
$ns_ at 9.800001 "$node_(7) setdest 1747.016357 894.230408 1000.000000"
$ns_ at 9.800001 "$node_(8) setdest 1724.334961 392.942932 1000.000000"
$ns_ at 9.800001 "$node_(9) setdest 1750.750366 445.291687 104.711088"
$ns_ at 9.866667 "$node_(0) setdest 1300.217896 0.000100 1000.000000"
$ns_ at 9.866667 "$node_(1) setdest 1444.521240 306.076294 1000.000000"
$ns_ at 9.866667 "$node_(2) setdest 1705.269165 544.876587 485.018552"
$ns_ at 9.866667 "$node_(3) setdest 1863.995605 584.659729 586.674812"
$ns_ at 9.866667 "$node_(4) setdest 1789.167725 260.903839 448.096681"
$ns_ at 9.866667 "$node_(5) setdest 1726.003052 497.788055 1000.000000"
$ns_ at 9.866667 "$node_(6) setdest 1935.381836 673.091736 948.922241"
$ns_ at 9.866667 "$node_(7) setdest 1700.875366 562.983765 1000.000000"
$ns_ at 9.866667 "$node_(8) setdest 1499.713745 0.000100 1000.000000"
$ns_ at 9.866667 "$node_(9) setdest 1764.419312 450.301239 54.592539"
$ns_ at 9.933334 "$node_(0) setdest 1700.217896 339.164703 1000.000000"
$ns_ at 9.933334 "$node_(1) setdest 1690.931152 306.076294 924.037122"
$ns_ at 9.933334 "$node_(2) setdest 1626.914062 290.191376 999.247117"
$ns_ at 9.933334 "$node_(3) setdest 1907.995605 364.642853 841.400255"
$ns_ at 9.933334 "$node_(4) setdest 1695.431396 89.853020 731.441135"
$ns_ at 9.933334 "$node_(5) setdest 1494.003052 720.887695 1000.000000"
$ns_ at 9.933334 "$node_(6) setdest 1628.957764 273.091766 1000.000000"
$ns_ at 9.933334 "$node_(7) setdest 1638.734375 307.737091 985.132662"
$ns_ at 9.933334 "$node_(8) setdest 1679.092529 364.942932 1000.000000"
$ns_ at 9.933334 "$node_(9) setdest 1766.088379 443.310791 26.951035"
$ns_ at 10.000001 "$node_(0) setdest 1748.217896 273.869873 303.898443"
$ns_ at 10.000001 "$node_(1) setdest 1665.340942 186.076294 460.118384"
$ns_ at 10.000001 "$node_(2) setdest 1548.558838 463.506134 713.264829"
$ns_ at 10.000001 "$node_(3) setdest 1807.995605 256.625977 551.997499"
$ns_ at 10.000001 "$node_(4) setdest 1657.694946 10.802184 328.485300"
$ns_ at 10.000001 "$node_(5) setdest 1700.389038 320.887695 1000.000000"
$ns_ at 10.000001 "$node_(6) setdest 1246.533569 121.091766 1000.000000"
$ns_ at 10.000001 "$node_(7) setdest 1308.593506 188.490417 1000.000000"
$ns_ at 10.000001 "$node_(8) setdest 1438.471313 344.942932 905.441103"
$ns_ at 10.000001 "$node_(9) setdest 1703.757324 616.320312 689.607088"
$ns_ at 10.066667 "$node_(0) setdest 1776.217896 60.575005 806.718136"
$ns_ at 10.066667 "$node_(1) setdest 1447.750854 258.076294 859.473851"
$ns_ at 10.066667 "$node_(2) setdest 1288.801392 270.748474 1000.000000"
$ns_ at 10.066667 "$node_(3) setdest 1563.995605 148.609116 1000.000000"
$ns_ at 10.066667 "$node_(4) setdest 1563.958618 99.751350 484.584306"
$ns_ at 10.066667 "$node_(5) setdest 1574.775024 412.887695 583.879650"
$ns_ at 10.066667 "$node_(6) setdest 1488.109375 165.091766 920.812978"
$ns_ at 10.066667 "$node_(7) setdest 1226.452515 85.243744 494.758676"
$ns_ at 10.066667 "$node_(8) setdest 1201.850098 504.942932 1000.000000"
$ns_ at 10.066667 "$node_(9) setdest 1503.041504 216.320312 1000.000000"
$ns_ at 10.133334 "$node_(0) setdest 1376.217896 173.772614 1000.000000"
$ns_ at 10.133334 "$node_(1) setdest 1422.160767 238.076294 121.794341"
$ns_ at 10.133334 "$node_(2) setdest 1377.043823 173.990814 491.074937"
$ns_ at 10.133334 "$node_(3) setdest 1483.995605 144.592239 300.377925"
$ns_ at 10.133334 "$node_(4) setdest 1922.222290 0.000100 1000.000000"
$ns_ at 10.133334 "$node_(5) setdest 1401.161011 328.887695 723.252659"
$ns_ at 10.133334 "$node_(6) setdest 1601.685303 0.000100 915.149755"
$ns_ at 10.133334 "$node_(7) setdest 1364.311523 185.997070 640.320992"
$ns_ at 10.133334 "$node_(8) setdest 1381.228882 112.942932 1000.000000"
$ns_ at 10.133334 "$node_(9) setdest 1618.325684 356.320312 680.089553"
$ns_ at 10.200001 "$node_(0) setdest 1516.217896 0.000100 1000.000000"
$ns_ at 10.200001 "$node_(1) setdest 1508.570557 106.076286 591.628902"
$ns_ at 10.200001 "$node_(2) setdest 1521.286255 0.000100 890.854522"
$ns_ at 10.200001 "$node_(3) setdest 1383.995605 432.575378 1000.000000"
$ns_ at 10.200001 "$node_(4) setdest 1522.222290 87.336266 1000.000000"
$ns_ at 10.200001 "$node_(5) setdest 1607.546997 104.887695 1000.000000"
$ns_ at 10.200001 "$node_(6) setdest 1755.261108 0.000100 591.520469"
$ns_ at 10.200001 "$node_(7) setdest 1358.170532 234.750412 184.269667"
$ns_ at 10.200001 "$node_(8) setdest 1404.607666 28.942936 326.972620"
$ns_ at 10.200001 "$node_(9) setdest 1505.609741 44.320320 1000.000000"
$ns_ at 10.266667 "$node_(0) setdest 1616.217896 0.000100 1000.000000"
$ns_ at 10.266667 "$node_(1) setdest 1514.645142 71.959427 129.950388"
$ns_ at 10.266667 "$node_(2) setdest 1509.528687 76.475494 344.987880"
$ns_ at 10.266667 "$node_(3) setdest 1567.995605 188.558502 1000.000000"
$ns_ at 10.266667 "$node_(4) setdest 1750.222290 0.000100 1000.000000"
$ns_ at 10.266667 "$node_(5) setdest 1825.932861 116.887695 820.182338"
$ns_ at 10.266667 "$node_(6) setdest 1488.836914 153.091766 1000.000000"
$ns_ at 10.266667 "$node_(7) setdest 958.170593 625.504700 1000.000000"
$ns_ at 10.266667 "$node_(8) setdest 1004.607605 0.000100 1000.000000"
$ns_ at 10.266667 "$node_(9) setdest 1476.893921 0.000100 995.839296"
$ns_ at 10.333334 "$node_(0) setdest 1445.661987 0.000100 1000.000000"
$ns_ at 10.333334 "$node_(1) setdest 1472.719727 0.000100 686.192114"
$ns_ at 10.333334 "$node_(2) setdest 1453.771118 0.000100 709.357244"
$ns_ at 10.333334 "$node_(3) setdest 1403.995605 0.000100 1000.000000"
$ns_ at 10.333334 "$node_(4) setdest 1378.222290 0.000100 1000.000000"
$ns_ at 10.333334 "$node_(5) setdest 1472.270752 0.000100 1000.000000"
$ns_ at 10.333334 "$node_(6) setdest 1670.412842 441.091766 1000.000000"
$ns_ at 10.333334 "$node_(7) setdest 1255.068726 225.504730 1000.000000"
$ns_ at 10.333334 "$node_(8) setdest 1404.607666 0.000100 1000.000000"
$ns_ at 10.333334 "$node_(9) setdest 1612.121216 0.000100 1000.000000"
$ns_ at 10.400001 "$node_(0) setdest 1547.106079 0.000100 385.117930"
$ns_ at 10.400001 "$node_(1) setdest 1502.794312 0.000100 272.383247"
$ns_ at 10.400001 "$node_(2) setdest 1594.013672 0.000100 968.138187"
$ns_ at 10.400001 "$node_(3) setdest 1419.995605 0.000100 84.808090"
$ns_ at 10.400001 "$node_(4) setdest 1326.222290 0.000100 199.037022"
$ns_ at 10.400001 "$node_(5) setdest 1742.608643 23.398312 1000.000000"
$ns_ at 10.400001 "$node_(6) setdest 1468.603760 41.091763 1000.000000"
$ns_ at 10.400001 "$node_(7) setdest 1431.966797 5.504726 1000.000000"
$ns_ at 10.400001 "$node_(8) setdest 1372.607666 0.000100 808.833576"
$ns_ at 10.400001 "$node_(9) setdest 1498.045898 0.000100 1000.000000"
$ns_ at 10.466667 "$node_(0) setdest 1736.550171 80.167816 901.507025"
$ns_ at 10.466667 "$node_(1) setdest 1524.868896 0.000100 420.294406"
$ns_ at 10.466667 "$node_(2) setdest 1538.117065 0.000100 617.648760"
$ns_ at 10.466667 "$node_(3) setdest 1363.995605 0.000100 537.761679"
$ns_ at 10.466667 "$node_(4) setdest 1298.222290 0.000100 673.352931"
$ns_ at 10.466667 "$node_(5) setdest 1472.946533 0.000100 1000.000000"
$ns_ at 10.466667 "$node_(6) setdest 1630.794678 401.091766 1000.000000"
$ns_ at 10.466667 "$node_(7) setdest 1346.572754 405.504730 1000.000000"
$ns_ at 10.466667 "$node_(8) setdest 1016.880066 0.000100 1000.000000"
$ns_ at 10.466667 "$node_(9) setdest 1667.970459 0.000100 1000.000000"
$ns_ at 10.533334 "$node_(0) setdest 1377.994141 0.000100 1000.000000"
$ns_ at 10.533334 "$node_(1) setdest 1630.943481 95.491997 713.278218"
$ns_ at 10.533334 "$node_(2) setdest 1646.220581 0.000100 423.930823"
$ns_ at 10.533334 "$node_(3) setdest 1331.995605 0.000100 422.343184"
$ns_ at 10.533334 "$node_(4) setdest 1370.222290 0.000100 321.689942"
$ns_ at 10.533334 "$node_(5) setdest 1791.284302 0.000100 1000.000000"
$ns_ at 10.533334 "$node_(6) setdest 1446.446533 1.091763 1000.000000"
$ns_ at 10.533334 "$node_(7) setdest 1421.844604 5.504726 1000.000000"
$ns_ at 10.533334 "$node_(8) setdest 1288.067139 0.000100 1000.000000"
$ns_ at 10.533334 "$node_(9) setdest 1452.408081 0.000100 1000.000000"
$ns_ at 10.600001 "$node_(0) setdest 1411.438232 0.000100 173.577095"
$ns_ at 10.600001 "$node_(1) setdest 1825.017944 225.375137 875.723545"
$ns_ at 10.600001 "$node_(2) setdest 1466.324097 0.000100 994.711824"
$ns_ at 10.600001 "$node_(3) setdest 1051.995605 0.000100 1000.000000"
$ns_ at 10.600001 "$node_(4) setdest 1247.746826 0.000100 1000.000000"
$ns_ at 10.600001 "$node_(5) setdest 1429.622192 0.000100 1000.000000"
$ns_ at 10.600001 "$node_(6) setdest 1562.098511 137.091766 669.470867"
$ns_ at 10.600001 "$node_(7) setdest 1277.116333 25.504726 547.888613"
$ns_ at 10.600001 "$node_(8) setdest 1323.254272 0.000100 211.273001"
$ns_ at 10.600001 "$node_(9) setdest 1852.408081 0.000100 1000.000000"
$ns_ at 10.666667 "$node_(0) setdest 1280.882324 24.167816 516.641151"
$ns_ at 10.666667 "$node_(1) setdest 1425.017944 21.024963 1000.000000"
$ns_ at 10.666667 "$node_(2) setdest 1594.427490 0.000100 868.883526"
$ns_ at 10.666667 "$node_(3) setdest 1422.220825 7.872005 1000.000000"
$ns_ at 10.666667 "$node_(4) setdest 1370.230713 0.000100 1000.000000"
$ns_ at 10.666667 "$node_(5) setdest 1223.960083 96.419548 862.977231"
$ns_ at 10.666667 "$node_(6) setdest 1665.750366 237.091766 540.100337"
$ns_ at 10.666667 "$node_(7) setdest 1148.388062 37.504726 484.823888"
$ns_ at 10.666667 "$node_(8) setdest 1374.441406 0.000100 544.926996"
$ns_ at 10.666667 "$node_(9) setdest 1452.408081 0.000100 1000.000000"
$ns_ at 10.733334 "$node_(0) setdest 1362.326416 104.167816 428.110406"
$ns_ at 10.733334 "$node_(1) setdest 1521.017944 316.674805 1000.000000"
$ns_ at 10.733334 "$node_(2) setdest 1446.531006 0.000100 803.210350"
$ns_ at 10.733334 "$node_(3) setdest 1624.445923 131.269852 888.378192"
$ns_ at 10.733334 "$node_(4) setdest 1316.714722 0.000100 711.948701"
$ns_ at 10.733334 "$node_(5) setdest 1242.297974 87.674858 76.185733"
$ns_ at 10.733334 "$node_(6) setdest 1449.402222 1.091763 1000.000000"
$ns_ at 10.733334 "$node_(7) setdest 1379.659790 101.504723 899.864112"
$ns_ at 10.733334 "$node_(8) setdest 1273.628418 0.000100 464.565186"
$ns_ at 10.733334 "$node_(9) setdest 1552.408081 0.000100 724.781132"
$ns_ at 10.800001 "$node_(0) setdest 1371.029297 288.470825 691.906378"
$ns_ at 10.800001 "$node_(1) setdest 1325.017944 172.324615 912.822485"
$ns_ at 10.800001 "$node_(2) setdest 1510.634521 0.000100 474.418892"
$ns_ at 10.800001 "$node_(3) setdest 1398.671021 26.667702 933.109025"
$ns_ at 10.800001 "$node_(4) setdest 1259.198608 0.000100 932.215756"
$ns_ at 10.800001 "$node_(5) setdest 1060.635742 130.930176 700.278589"
$ns_ at 10.800001 "$node_(6) setdest 1849.402222 87.476784 1000.000000"
$ns_ at 10.800001 "$node_(7) setdest 1574.931519 181.504730 791.339280"
$ns_ at 10.800001 "$node_(8) setdest 1336.815552 0.000100 280.439171"
$ns_ at 10.800001 "$node_(9) setdest 1420.408081 78.137726 1000.000000"
$ns_ at 10.866667 "$node_(0) setdest 1400.869019 148.879761 535.292903"
$ns_ at 10.866667 "$node_(1) setdest 1261.017944 395.974457 872.350628"
$ns_ at 10.866667 "$node_(2) setdest 1498.737915 3.480161 582.703083"
$ns_ at 10.866667 "$node_(3) setdest 1504.896240 222.065552 834.019846"
$ns_ at 10.866667 "$node_(4) setdest 1321.682495 0.000100 1000.000000"
$ns_ at 10.866667 "$node_(5) setdest 1458.973633 146.185486 1000.000000"
$ns_ at 10.866667 "$node_(6) setdest 1449.402222 134.382812 1000.000000"
$ns_ at 10.866667 "$node_(7) setdest 1658.203247 197.504730 317.980998"
$ns_ at 10.866667 "$node_(8) setdest 1160.002686 0.000100 671.310619"
$ns_ at 10.866667 "$node_(9) setdest 1208.408081 0.000100 1000.000000"
$ns_ at 10.933334 "$node_(0) setdest 1166.708740 253.288712 961.436412"
$ns_ at 10.933334 "$node_(1) setdest 1389.017944 27.624277 1000.000000"
$ns_ at 10.933334 "$node_(2) setdest 1562.841431 0.000100 877.573025"
$ns_ at 10.933334 "$node_(3) setdest 1351.121338 49.463398 866.876519"
$ns_ at 10.933334 "$node_(4) setdest 1362.572876 58.093822 1000.000000"
$ns_ at 10.933334 "$node_(5) setdest 1605.311523 385.440796 1000.000000"
$ns_ at 10.933334 "$node_(6) setdest 1653.402222 341.288849 1000.000000"
$ns_ at 10.933334 "$node_(7) setdest 1337.475098 69.504723 1000.000000"
$ns_ at 10.933334 "$node_(8) setdest 1411.189819 104.579483 1000.000000"
$ns_ at 10.933334 "$node_(9) setdest 936.408142 0.000100 1000.000000"
$ns_ at 11.000001 "$node_(0) setdest 1040.548462 429.697662 813.296485"
$ns_ at 11.000001 "$node_(1) setdest 1441.017944 0.000100 322.058098"
$ns_ at 11.000001 "$node_(2) setdest 1458.944946 0.000100 750.112742"
$ns_ at 11.000001 "$node_(3) setdest 1233.346436 104.861244 488.074354"
$ns_ at 11.000001 "$node_(4) setdest 1383.463379 34.093822 119.319142"
$ns_ at 11.000001 "$node_(5) setdest 1275.649414 68.696098 1000.000000"
$ns_ at 11.000001 "$node_(6) setdest 1313.402222 36.194878 1000.000000"
$ns_ at 11.000001 "$node_(7) setdest 1248.746826 325.504730 1000.000000"
$ns_ at 11.000001 "$node_(8) setdest 1678.347412 504.579468 1000.000000"
$ns_ at 11.000001 "$node_(9) setdest 1284.472778 0.000100 1000.000000"
$ns_ at 11.066667 "$node_(0) setdest 1334.388184 202.106598 1000.000000"
$ns_ at 11.066667 "$node_(1) setdest 1721.017944 58.923931 1000.000000"
$ns_ at 11.066667 "$node_(2) setdest 1679.048340 40.274441 893.051501"
$ns_ at 11.066667 "$node_(3) setdest 1084.288818 310.551910 952.579830"
$ns_ at 11.066667 "$node_(4) setdest 1500.353760 150.093826 617.548395"
$ns_ at 11.066667 "$node_(5) setdest 1221.987183 279.951416 817.366176"
$ns_ at 11.066667 "$node_(6) setdest 1329.402222 183.100906 554.155340"
$ns_ at 11.066667 "$node_(7) setdest 1172.018555 513.504700 761.455153"
$ns_ at 11.066667 "$node_(8) setdest 1278.347412 207.787445 1000.000000"
$ns_ at 11.066667 "$node_(9) setdest 1256.537476 215.349487 891.178447"
$ns_ at 11.133334 "$node_(0) setdest 1600.227783 246.515549 1000.000000"
$ns_ at 11.133334 "$node_(1) setdest 1321.017944 304.121796 1000.000000"
$ns_ at 11.133334 "$node_(2) setdest 1323.151855 311.205872 1000.000000"
$ns_ at 11.133334 "$node_(3) setdest 1308.754028 285.181458 847.104047"
$ns_ at 11.133334 "$node_(4) setdest 1410.953857 242.548782 482.283529"
$ns_ at 11.133334 "$node_(5) setdest 988.657349 407.627228 997.414804"
$ns_ at 11.133334 "$node_(6) setdest 1453.402222 0.000100 1000.000000"
$ns_ at 11.133334 "$node_(7) setdest 1407.290283 253.504730 1000.000000"
$ns_ at 11.133334 "$node_(8) setdest 1078.347412 0.000100 1000.000000"
$ns_ at 11.133334 "$node_(9) setdest 904.602112 0.000100 1000.000000"
$ns_ at 11.200001 "$node_(0) setdest 1318.067505 158.924500 1000.000000"
$ns_ at 11.200001 "$node_(1) setdest 1073.017944 397.319641 993.501154"
$ns_ at 11.200001 "$node_(2) setdest 1075.255371 430.137299 1000.000000"
$ns_ at 11.200001 "$node_(3) setdest 1061.219238 311.811035 933.611421"
$ns_ at 11.200001 "$node_(4) setdest 1285.553833 227.003754 473.849434"
$ns_ at 11.200001 "$node_(5) setdest 1157.722778 227.023178 927.705869"
$ns_ at 11.200001 "$node_(6) setdest 1166.358032 226.006943 1000.000000"
$ns_ at 11.200001 "$node_(7) setdest 1242.562012 277.504730 624.252802"
$ns_ at 11.200001 "$node_(8) setdest 1402.347412 210.203400 1000.000000"
$ns_ at 11.200001 "$node_(9) setdest 1272.666748 207.349487 1000.000000"
$ns_ at 11.266667 "$node_(0) setdest 1471.076294 43.977600 717.657071"
$ns_ at 11.266667 "$node_(1) setdest 869.018005 702.517456 1000.000000"
$ns_ at 11.266667 "$node_(2) setdest 1011.358765 605.068726 698.384306"
$ns_ at 11.266667 "$node_(3) setdest 1069.684448 438.440613 475.920786"
$ns_ at 11.266667 "$node_(4) setdest 1046.812622 451.098145 1000.000000"
$ns_ at 11.266667 "$node_(5) setdest 902.788208 358.419128 1000.000000"
$ns_ at 11.266667 "$node_(6) setdest 975.313904 294.006927 760.444640"
$ns_ at 11.266667 "$node_(7) setdest 1313.833862 165.504730 497.828210"
$ns_ at 11.266667 "$node_(8) setdest 1286.347412 385.411377 787.980496"
$ns_ at 11.266667 "$node_(9) setdest 1028.731445 207.349487 914.757338"
$ns_ at 11.333334 "$node_(0) setdest 1080.368286 384.729828 1000.000000"
$ns_ at 11.333334 "$node_(1) setdest 1021.018005 407.715332 1000.000000"
$ns_ at 11.333334 "$node_(2) setdest 891.462280 948.000122 1000.000000"
$ns_ at 11.333334 "$node_(3) setdest 1214.149536 553.070190 691.568491"
$ns_ at 11.333334 "$node_(4) setdest 908.071472 607.192505 783.153665"
$ns_ at 11.333334 "$node_(5) setdest 1022.655029 456.830963 581.587914"
$ns_ at 11.333334 "$node_(6) setdest 760.269775 190.006943 895.771075"
$ns_ at 11.333334 "$node_(7) setdest 949.105530 505.504730 1000.000000"
$ns_ at 11.333334 "$node_(8) setdest 1042.347412 292.619324 978.932139"
$ns_ at 11.333334 "$node_(9) setdest 944.796082 227.349487 323.569691"
$ns_ at 11.400001 "$node_(0) setdest 1157.584106 394.850616 292.035984"
$ns_ at 11.400001 "$node_(1) setdest 777.018005 592.913208 1000.000000"
$ns_ at 11.400001 "$node_(2) setdest 878.133728 548.000122 1000.000000"
$ns_ at 11.400001 "$node_(3) setdest 1006.614746 635.699768 837.672514"
$ns_ at 11.400001 "$node_(4) setdest 878.378113 542.315918 267.558389"
$ns_ at 11.400001 "$node_(5) setdest 1186.521729 491.242798 627.903524"
$ns_ at 11.400001 "$node_(6) setdest 898.461792 590.006958 1000.000000"
$ns_ at 11.400001 "$node_(7) setdest 1260.377319 273.504730 1000.000000"
$ns_ at 11.400001 "$node_(8) setdest 974.347473 647.827332 1000.000000"
$ns_ at 11.400001 "$node_(9) setdest 868.860779 579.349487 1000.000000"
$ns_ at 11.466667 "$node_(0) setdest 986.222534 602.300903 1000.000000"
$ns_ at 11.466667 "$node_(1) setdest 429.018005 642.111023 1000.000000"
$ns_ at 11.466667 "$node_(2) setdest 660.805237 344.000153 1000.000000"
$ns_ at 11.466667 "$node_(3) setdest 1391.079956 786.329346 1000.000000"
$ns_ at 11.466667 "$node_(4) setdest 792.684753 369.439331 723.562107"
$ns_ at 11.466667 "$node_(5) setdest 958.388550 605.654602 957.057045"
$ns_ at 11.466667 "$node_(6) setdest 800.653748 490.006927 524.550048"
$ns_ at 11.466667 "$node_(7) setdest 931.649048 661.504700 1000.000000"
$ns_ at 11.466667 "$node_(8) setdest 1150.347412 703.035278 691.708738"
$ns_ at 11.466667 "$node_(9) setdest 744.925415 443.349487 689.999678"
$ns_ at 11.533334 "$node_(0) setdest 694.860901 421.751190 1000.000000"
$ns_ at 11.533334 "$node_(1) setdest 780.035461 603.364868 1000.000000"
$ns_ at 11.533334 "$node_(2) setdest 651.476746 548.000122 765.799273"
$ns_ at 11.533334 "$node_(3) setdest 991.079956 662.578308 1000.000000"
$ns_ at 11.533334 "$node_(4) setdest 930.991455 516.562744 757.221812"
$ns_ at 11.533334 "$node_(5) setdest 826.255310 528.066467 574.608563"
$ns_ at 11.533334 "$node_(6) setdest 782.845764 450.006927 164.193655"
$ns_ at 11.533334 "$node_(7) setdest 902.920837 833.504700 653.934941"
$ns_ at 11.533334 "$node_(8) setdest 750.347473 592.854126 1000.000000"
$ns_ at 11.533334 "$node_(9) setdest 800.990051 343.349487 429.914910"
$ns_ at 11.600001 "$node_(0) setdest 499.499298 109.201469 1000.000000"
$ns_ at 11.600001 "$node_(1) setdest 535.934875 702.633362 988.175302"
$ns_ at 11.600001 "$node_(2) setdest 578.148254 528.000122 285.026335"
$ns_ at 11.600001 "$node_(3) setdest 843.079956 366.827271 1000.000000"
$ns_ at 11.600001 "$node_(4) setdest 809.298096 515.686157 456.361918"
$ns_ at 11.600001 "$node_(5) setdest 814.122070 478.478302 191.441135"
$ns_ at 11.600001 "$node_(6) setdest 657.037781 734.006958 1000.000000"
$ns_ at 11.600001 "$node_(7) setdest 726.192566 489.504730 1000.000000"
$ns_ at 11.600001 "$node_(8) setdest 846.347473 898.672974 1000.000000"
$ns_ at 11.600001 "$node_(9) setdest 685.054749 543.349487 866.899006"
$ns_ at 11.666667 "$node_(0) setdest 594.433350 509.201477 1000.000000"
$ns_ at 11.666667 "$node_(1) setdest 439.834351 653.901794 404.062736"
$ns_ at 11.666667 "$node_(2) setdest 344.819733 540.000122 876.138336"
$ns_ at 11.666667 "$node_(3) setdest 851.079956 275.076233 345.371772"
$ns_ at 11.666667 "$node_(4) setdest 775.604736 554.809509 193.620562"
$ns_ at 11.666667 "$node_(5) setdest 785.988892 460.890137 124.419730"
$ns_ at 11.666667 "$node_(6) setdest 443.229767 842.006958 898.262854"
$ns_ at 11.666667 "$node_(7) setdest 653.464294 453.504730 304.314321"
$ns_ at 11.666667 "$node_(8) setdest 612.726624 541.696228 1000.000000"
$ns_ at 11.666667 "$node_(9) setdest 589.119385 699.349487 686.768153"
$ns_ at 11.733334 "$node_(0) setdest 249.367371 321.201477 1000.000000"
$ns_ at 11.733334 "$node_(1) setdest 379.733795 333.170288 1000.000000"
$ns_ at 11.733334 "$node_(2) setdest 559.491211 568.000122 811.836792"
$ns_ at 11.733334 "$node_(3) setdest 483.079926 611.325195 1000.000000"
$ns_ at 11.733334 "$node_(4) setdest 965.911377 541.932922 715.281621"
$ns_ at 11.733334 "$node_(5) setdest 625.855652 583.301941 755.858077"
$ns_ at 11.733334 "$node_(6) setdest 405.421753 670.006958 660.398792"
$ns_ at 11.733334 "$node_(7) setdest 556.736084 493.504730 392.522114"
$ns_ at 11.733334 "$node_(8) setdest 779.105835 364.719513 910.893412"
$ns_ at 11.733334 "$node_(9) setdest 797.184021 907.349487 1000.000000"
$ns_ at 11.800001 "$node_(0) setdest 488.301392 557.201477 1000.000000"
$ns_ at 11.800001 "$node_(1) setdest 571.633240 580.438782 1000.000000"
$ns_ at 11.800001 "$node_(2) setdest 750.162720 440.000153 861.191495"
$ns_ at 11.800001 "$node_(3) setdest 363.079926 655.574158 479.618543"
$ns_ at 11.800001 "$node_(4) setdest 565.911377 531.150635 1000.000000"
$ns_ at 11.800001 "$node_(5) setdest 881.722412 677.713806 1000.000000"
$ns_ at 11.800001 "$node_(6) setdest 86.091293 1023.807739 1000.000000"
$ns_ at 11.800001 "$node_(7) setdest 792.007812 177.504730 1000.000000"
$ns_ at 11.800001 "$node_(8) setdest 536.329285 691.463745 1000.000000"
$ns_ at 11.800001 "$node_(9) setdest 534.179260 507.349487 1000.000000"
$ns_ at 11.866667 "$node_(0) setdest 387.235443 433.201477 599.886615"
$ns_ at 11.866667 "$node_(1) setdest 771.532715 763.707214 1000.000000"
$ns_ at 11.866667 "$node_(2) setdest 492.834229 660.000122 1000.000000"
$ns_ at 11.866667 "$node_(3) setdest 87.079926 727.823120 1000.000000"
$ns_ at 11.866667 "$node_(4) setdest 885.911377 472.368317 1000.000000"
$ns_ at 11.866667 "$node_(5) setdest 481.722412 621.821045 1000.000000"
$ns_ at 11.866667 "$node_(6) setdest 486.091278 665.020813 1000.000000"
$ns_ at 11.866667 "$node_(7) setdest 566.613342 565.904114 1000.000000"
$ns_ at 11.866667 "$node_(8) setdest 565.552734 930.207947 901.972800"
$ns_ at 11.866667 "$node_(9) setdest 815.174438 275.349487 1000.000000"
$ns_ at 11.933334 "$node_(0) setdest 402.169464 541.201477 408.853605"
$ns_ at 11.933334 "$node_(1) setdest 507.432190 606.975708 1000.000000"
$ns_ at 11.933334 "$node_(2) setdest 599.505737 912.000122 1000.000000"
$ns_ at 11.933334 "$node_(3) setdest 487.079926 650.970520 1000.000000"
$ns_ at 11.933334 "$node_(4) setdest 485.911407 655.752136 1000.000000"
$ns_ at 11.933334 "$node_(5) setdest 557.722412 693.928284 392.864235"
$ns_ at 11.933334 "$node_(6) setdest 495.803528 921.758606 963.455264"
$ns_ at 11.933334 "$node_(7) setdest 953.218872 414.303497 1000.000000"
$ns_ at 11.933334 "$node_(8) setdest 552.923218 635.117493 1000.000000"
$ns_ at 11.933334 "$node_(9) setdest 415.174408 532.050049 1000.000000"
$ns_ at 12.000001 "$node_(0) setdest 113.103493 337.201477 1000.000000"
$ns_ at 12.000001 "$node_(1) setdest 655.331665 678.244202 615.656458"
$ns_ at 12.000001 "$node_(2) setdest 526.177246 656.000122 998.606477"
$ns_ at 12.000001 "$node_(3) setdest 299.079926 806.117920 914.067488"
$ns_ at 12.000001 "$node_(4) setdest 565.911377 659.135986 300.268119"
$ns_ at 12.000001 "$node_(5) setdest 529.722412 698.035522 106.123633"
$ns_ at 12.000001 "$node_(6) setdest 541.515808 654.496460 1000.000000"
$ns_ at 12.000001 "$node_(7) setdest 553.218872 679.483398 1000.000000"
$ns_ at 12.000001 "$node_(8) setdest 632.293640 652.027100 304.318870"
$ns_ at 12.000001 "$node_(9) setdest 60.501751 132.050079 1000.000000"
$ns_ at 12.066667 "$node_(0) setdest 404.037537 573.201477 1000.000000"
$ns_ at 12.066667 "$node_(1) setdest 771.231079 537.512634 683.673899"
$ns_ at 12.066667 "$node_(2) setdest 300.848724 488.000153 1000.000000"
$ns_ at 12.066667 "$node_(3) setdest 371.079926 489.265289 1000.000000"
$ns_ at 12.066667 "$node_(4) setdest 609.911377 786.519836 505.383198"
$ns_ at 12.066667 "$node_(5) setdest 425.722412 702.142761 390.303992"
$ns_ at 12.066667 "$node_(6) setdest 567.228027 559.234253 370.016994"
$ns_ at 12.066667 "$node_(7) setdest 481.218872 588.663330 434.616486"
$ns_ at 12.066667 "$node_(8) setdest 232.293655 520.940735 1000.000000"
$ns_ at 12.066667 "$node_(9) setdest 353.393005 532.050049 1000.000000"
$ns_ at 12.133334 "$node_(0) setdest 526.971558 665.201477 575.802353"
$ns_ at 12.133334 "$node_(1) setdest 411.130554 576.781128 1000.000000"
$ns_ at 12.133334 "$node_(2) setdest 79.520218 348.000153 982.086932"
$ns_ at 12.133334 "$node_(3) setdest 311.079926 164.412689 1000.000000"
$ns_ at 12.133334 "$node_(4) setdest 829.911377 925.903687 976.641718"
$ns_ at 12.133334 "$node_(5) setdest 361.722412 1094.250000 1000.000000"
$ns_ at 12.133334 "$node_(6) setdest 680.940308 523.972046 446.453281"
$ns_ at 12.133334 "$node_(7) setdest 461.218872 697.843262 416.237447"
$ns_ at 12.133334 "$node_(8) setdest 224.293655 509.854401 51.267698"
$ns_ at 12.133334 "$node_(9) setdest 206.284271 344.050079 895.182105"
$ns_ at 12.200001 "$node_(0) setdest 341.905579 577.201477 768.461054"
$ns_ at 12.200001 "$node_(1) setdest 471.029999 592.049561 231.805460"
$ns_ at 12.200001 "$node_(2) setdest 294.191711 628.000122 1000.000000"
$ns_ at 12.200001 "$node_(3) setdest 479.079926 495.560089 1000.000000"
$ns_ at 12.200001 "$node_(4) setdest 429.911407 639.726135 1000.000000"
$ns_ at 12.200001 "$node_(5) setdest 369.777557 694.250000 1000.000000"
$ns_ at 12.200001 "$node_(6) setdest 322.652557 596.709839 1000.000000"
$ns_ at 12.200001 "$node_(7) setdest 737.218872 763.023193 1000.000000"
$ns_ at 12.200001 "$node_(8) setdest 384.293671 598.768066 686.420481"
$ns_ at 12.200001 "$node_(9) setdest 399.175537 636.050049 1000.000000"
$ns_ at 12.266667 "$node_(0) setdest 188.839615 329.201477 1000.000000"
$ns_ at 12.266667 "$node_(1) setdest 870.929443 555.318054 1000.000000"
$ns_ at 12.266667 "$node_(2) setdest 59.334339 615.361877 881.989357"
$ns_ at 12.266667 "$node_(3) setdest 703.079956 258.707458 1000.000000"
$ns_ at 12.266667 "$node_(4) setdest 721.911377 725.548584 1000.000000"
$ns_ at 12.266667 "$node_(5) setdest 437.832672 946.250000 978.854090"
$ns_ at 12.266667 "$node_(6) setdest 348.364807 621.447632 133.800824"
$ns_ at 12.266667 "$node_(7) setdest 377.218872 644.203125 1000.000000"
$ns_ at 12.266667 "$node_(8) setdest 452.293671 551.681702 310.166600"
$ns_ at 12.266667 "$node_(9) setdest 436.066772 724.050049 357.824717"
$ns_ at 12.333334 "$node_(0) setdest 543.773621 621.201477 1000.000000"
$ns_ at 12.333334 "$node_(1) setdest 470.929474 572.216492 1000.000000"
$ns_ at 12.333334 "$node_(2) setdest 408.062164 584.787720 1000.000000"
$ns_ at 12.333334 "$node_(3) setdest 473.038605 597.513916 1000.000000"
$ns_ at 12.333334 "$node_(4) setdest 621.911377 655.371033 458.127971"
$ns_ at 12.333334 "$node_(5) setdest 492.929138 546.250000 1000.000000"
$ns_ at 12.333334 "$node_(6) setdest 0.000100 738.375610 1000.000000"
$ns_ at 12.333334 "$node_(7) setdest 0.000100 959.085449 1000.000000"
$ns_ at 12.333334 "$node_(8) setdest 262.340698 371.462830 981.905543"
$ns_ at 12.333334 "$node_(9) setdest 148.958038 896.050049 1000.000000"
$ns_ at 12.400001 "$node_(0) setdest 402.707672 837.201477 967.438953"
$ns_ at 12.400001 "$node_(1) setdest 130.929459 629.114929 1000.000000"
$ns_ at 12.400001 "$node_(2) setdest 20.789988 750.213562 1000.000000"
$ns_ at 12.400001 "$node_(3) setdest 73.038612 676.746765 1000.000000"
$ns_ at 12.400001 "$node_(4) setdest 325.911407 833.193481 1000.000000"
$ns_ at 12.400001 "$node_(5) setdest 196.025604 766.250000 1000.000000"
$ns_ at 12.400001 "$node_(6) setdest 0.000100 867.303528 501.973660"
$ns_ at 12.400001 "$node_(7) setdest 281.218872 741.967712 1000.000000"
$ns_ at 12.400001 "$node_(8) setdest 248.872650 611.819336 902.750712"
$ns_ at 12.400001 "$node_(9) setdest 237.480148 723.540100 727.111778"
$ns_ at 12.466667 "$node_(0) setdest 29.641714 813.201477 1000.000000"
$ns_ at 12.466667 "$node_(1) setdest 0.000100 270.013397 1000.000000"
$ns_ at 12.466667 "$node_(2) setdest 0.000100 823.639404 657.683910"
$ns_ at 12.466667 "$node_(3) setdest 0.000100 439.979584 1000.000000"
$ns_ at 12.466667 "$node_(4) setdest 317.911407 1083.015869 937.314099"
$ns_ at 12.466667 "$node_(5) setdest 59.122063 990.250000 984.463068"
$ns_ at 12.466667 "$node_(6) setdest 0.000100 752.231506 479.905790"
$ns_ at 12.466667 "$node_(7) setdest 37.218861 880.849976 1000.000000"
$ns_ at 12.466667 "$node_(8) setdest 43.404583 724.175903 878.181793"
$ns_ at 12.466667 "$node_(9) setdest 26.002264 859.030151 941.843270"
$ns_ at 12.533334 "$node_(0) setdest 0.000100 645.201477 767.866304"
$ns_ at 12.533334 "$node_(1) setdest 0.000100 670.013367 1000.000000"
$ns_ at 12.533334 "$node_(2) setdest 0.000100 785.463867 150.658371"
$ns_ at 12.533334 "$node_(3) setdest 0.000100 839.979614 1000.000000"
$ns_ at 12.533334 "$node_(4) setdest 0.000100 814.699585 1000.000000"
$ns_ at 12.533334 "$node_(5) setdest 218.218521 1306.250000 1000.000000"
$ns_ at 12.533334 "$node_(6) setdest 0.000100 461.159454 1000.000000"
$ns_ at 12.533334 "$node_(7) setdest 329.218872 983.732300 1000.000000"
$ns_ at 12.533334 "$node_(8) setdest 443.404572 594.538513 1000.000000"
$ns_ at 12.533334 "$node_(9) setdest 426.002258 1079.614746 1000.000000"
$ns_ at 12.600001 "$node_(0) setdest 311.509766 409.201477 1000.000000"
$ns_ at 12.600001 "$node_(1) setdest 192.332413 426.013397 1000.000000"
$ns_ at 12.600001 "$node_(2) setdest 120.481461 803.288330 1000.000000"
$ns_ at 12.600001 "$node_(3) setdest 151.371017 859.979614 1000.000000"
$ns_ at 12.600001 "$node_(4) setdest 245.911392 902.383240 1000.000000"
$ns_ at 12.600001 "$node_(5) setdest 173.762634 906.250000 1000.000000"
$ns_ at 12.600001 "$node_(6) setdest 151.711807 861.159424 1000.000000"
$ns_ at 12.600001 "$node_(7) setdest 45.218861 758.614563 1000.000000"
$ns_ at 12.600001 "$node_(8) setdest 285.415039 994.538513 1000.000000"
$ns_ at 12.600001 "$node_(9) setdest 118.002266 828.199341 1000.000000"
$ns_ at 12.666667 "$node_(0) setdest 253.874863 767.850769 1000.000000"
$ns_ at 12.666667 "$node_(1) setdest 273.033875 786.013367 1000.000000"
$ns_ at 12.666667 "$node_(2) setdest 0.000100 403.288330 1000.000000"
$ns_ at 12.666667 "$node_(3) setdest 0.000100 791.979614 823.597255"
$ns_ at 12.666667 "$node_(4) setdest 481.911407 974.066895 924.924783"
$ns_ at 12.666667 "$node_(5) setdest 221.306747 1198.250000 1000.000000"
$ns_ at 12.666667 "$node_(6) setdest 55.058804 845.159424 367.381391"
$ns_ at 12.666667 "$node_(7) setdest 277.218872 681.496887 916.805086"
$ns_ at 12.666667 "$node_(8) setdest 475.425476 826.538513 951.110867"
$ns_ at 12.666667 "$node_(9) setdest 0.000100 996.783936 1000.000000"
$ns_ at 12.733334 "$node_(0) setdest 132.239960 918.500000 726.089821"
$ns_ at 12.733334 "$node_(1) setdest 149.735352 954.013367 781.463659"
$ns_ at 12.733334 "$node_(2) setdest 86.955055 784.970093 1000.000000"
$ns_ at 12.733334 "$node_(3) setdest 0.000100 715.979614 310.459626"
$ns_ at 12.733334 "$node_(4) setdest 113.911400 865.750610 1000.000000"
$ns_ at 12.733334 "$node_(5) setdest 168.850845 814.250000 1000.000000"
$ns_ at 12.733334 "$node_(6) setdest 118.405807 809.159424 273.231769"
$ns_ at 12.733334 "$node_(7) setdest 397.218872 340.379150 1000.000000"
$ns_ at 12.733334 "$node_(8) setdest 121.435928 902.538513 1000.000000"
$ns_ at 12.733334 "$node_(9) setdest 218.002258 849.368530 1000.000000"
$ns_ at 12.800001 "$node_(0) setdest 89.985413 1161.693848 925.640153"
$ns_ at 12.800001 "$node_(1) setdest 198.198151 1354.013428 1000.000000"
$ns_ at 12.800001 "$node_(2) setdest 0.000100 498.651855 1000.000000"
$ns_ at 12.800001 "$node_(3) setdest 144.869629 775.979614 910.123797"
$ns_ at 12.800001 "$node_(4) setdest 0.000100 941.434265 623.357988"
$ns_ at 12.800001 "$node_(5) setdest 200.394958 718.250000 378.936147"
$ns_ at 12.800001 "$node_(6) setdest 0.000100 665.159424 714.218636"
$ns_ at 12.800001 "$node_(7) setdest 152.231110 740.379150 1000.000000"
$ns_ at 12.800001 "$node_(8) setdest 15.446380 1086.538452 796.288105"
$ns_ at 12.800001 "$node_(9) setdest 222.002258 953.953125 392.478941"
$ns_ at 12.866667 "$node_(0) setdest 83.103172 1013.501709 556.319475"
$ns_ at 12.866667 "$node_(1) setdest 81.793541 954.013367 1000.000000"
$ns_ at 12.866667 "$node_(2) setdest 62.735115 898.651855 1000.000000"
$ns_ at 12.866667 "$node_(3) setdest 260.035828 663.979614 602.423827"
$ns_ at 12.866667 "$node_(4) setdest 93.911400 981.117920 502.539055"
$ns_ at 12.866667 "$node_(5) setdest 199.939072 838.250000 450.003238"
$ns_ at 12.866667 "$node_(6) setdest 93.099815 1033.159424 1000.000000"
$ns_ at 12.866667 "$node_(7) setdest 35.243359 792.379150 480.089811"
$ns_ at 12.866667 "$node_(8) setdest 0.000100 1486.538452 1000.000000"
$ns_ at 12.866667 "$node_(9) setdest 622.002258 1056.939575 1000.000000"
$ns_ at 12.933334 "$node_(0) setdest 73.743263 1280.047607 1000.000000"
$ns_ at 12.933334 "$node_(1) setdest 117.388939 1326.013428 1000.000000"
$ns_ at 12.933334 "$node_(2) setdest 5.604712 978.651855 368.643932"
$ns_ at 12.933334 "$node_(3) setdest 164.732391 1063.979614 1000.000000"
$ns_ at 12.933334 "$node_(4) setdest 49.911400 1252.801636 1000.000000"
$ns_ at 12.933334 "$node_(5) setdest 599.939087 782.635742 1000.000000"
$ns_ at 12.933334 "$node_(6) setdest 180.446823 1037.159424 327.894528"
$ns_ at 12.933334 "$node_(7) setdest 194.255615 1072.379150 1000.000000"
$ns_ at 12.933334 "$node_(8) setdest 123.823761 1086.538452 1000.000000"
$ns_ at 12.933334 "$node_(9) setdest 222.002258 1050.262817 1000.000000"
$ns_ at 13.000001 "$node_(0) setdest 228.383362 1182.593384 685.449164"
$ns_ at 13.000001 "$node_(1) setdest 176.984329 1382.013428 306.666768"
$ns_ at 13.000001 "$node_(2) setdest 240.474304 1226.651855 1000.000000"
$ns_ at 13.000001 "$node_(3) setdest 29.428940 919.979614 740.974006"
$ns_ at 13.000001 "$node_(4) setdest 0.000100 1280.485229 682.936499"
$ns_ at 13.000001 "$node_(5) setdest 213.470230 1182.635742 1000.000000"
$ns_ at 13.000001 "$node_(6) setdest 75.793823 653.159424 1000.000000"
$ns_ at 13.000001 "$node_(7) setdest 309.267853 984.379150 543.061781"
$ns_ at 13.000001 "$node_(8) setdest 0.000100 1229.654541 1000.000000"
$ns_ at 13.000001 "$node_(9) setdest 346.002258 983.586060 527.962047"
$ns_ at 13.066667 "$node_(0) setdest 0.000100 1265.139282 1000.000000"
$ns_ at 13.066667 "$node_(1) setdest 36.579731 1278.013428 655.225434"
$ns_ at 13.066667 "$node_(2) setdest 67.343903 1118.651855 765.203379"
$ns_ at 13.066667 "$node_(3) setdest 102.125488 1143.979614 883.129245"
$ns_ at 13.066667 "$node_(4) setdest 69.911400 1104.168945 999.833513"
$ns_ at 13.066667 "$node_(5) setdest 463.001404 1542.635742 1000.000000"
$ns_ at 13.066667 "$node_(6) setdest 89.915718 1053.159424 1000.000000"
$ns_ at 13.066667 "$node_(7) setdest 16.280107 1132.379150 1000.000000"
$ns_ at 13.066667 "$node_(8) setdest 0.000100 1052.770508 1000.000000"
$ns_ at 13.066667 "$node_(9) setdest 46.002262 1132.909302 1000.000000"
$ns_ at 13.133334 "$node_(0) setdest 0.000100 1665.139282 1000.000000"
$ns_ at 13.133334 "$node_(1) setdest 0.000100 1678.013428 1000.000000"
$ns_ at 13.133334 "$node_(2) setdest 174.213501 1378.651855 1000.000000"
$ns_ at 13.133334 "$node_(3) setdest 362.822052 1491.979614 1000.000000"
$ns_ at 13.133334 "$node_(4) setdest 81.911400 1291.852661 705.251047"
$ns_ at 13.133334 "$node_(5) setdest 76.532555 1242.635742 1000.000000"
$ns_ at 13.133334 "$node_(6) setdest 300.037628 893.159424 990.392023"
$ns_ at 13.133334 "$node_(7) setdest 0.000100 992.379150 622.079855"
$ns_ at 13.133334 "$node_(8) setdest 0.000100 1287.886597 884.869434"
$ns_ at 13.133334 "$node_(9) setdest 222.002258 1134.232544 660.018619"
$ns_ at 13.200001 "$node_(0) setdest 0.000100 1456.779907 1000.000000"
$ns_ at 13.200001 "$node_(1) setdest 92.774803 1385.761230 1000.000000"
$ns_ at 13.200001 "$node_(2) setdest 333.083099 1434.651855 631.689115"
$ns_ at 13.200001 "$node_(3) setdest 39.518589 1387.979614 1000.000000"
$ns_ at 13.200001 "$node_(4) setdest 78.808716 1279.196533 48.865855"
$ns_ at 13.200001 "$node_(5) setdest 18.063713 1298.635742 303.601926"
$ns_ at 13.200001 "$node_(6) setdest 135.644135 1293.159424 1000.000000"
$ns_ at 13.200001 "$node_(7) setdest 73.702156 1392.379150 1000.000000"
$ns_ at 13.200001 "$node_(8) setdest 0.000100 1411.002686 485.441354"
$ns_ at 13.200001 "$node_(9) setdest 146.002258 1299.555908 682.333224"
$ns_ at 13.266667 "$node_(0) setdest 0.000100 1856.779907 1000.000000"
$ns_ at 13.266667 "$node_(1) setdest 159.714890 1713.509155 1000.000000"
$ns_ at 13.266667 "$node_(2) setdest 89.295769 1415.390015 917.051535"
$ns_ at 13.266667 "$node_(3) setdest 0.000100 1655.979614 1000.000000"
$ns_ at 13.266667 "$node_(4) setdest 106.256584 1383.454224 404.288443"
$ns_ at 13.266667 "$node_(5) setdest 0.000100 1026.635742 1000.000000"
$ns_ at 13.266667 "$node_(6) setdest 447.250641 961.159424 1000.000000"
$ns_ at 13.266667 "$node_(7) setdest 112.111954 1448.379150 254.649912"
$ns_ at 13.266667 "$node_(8) setdest 0.000100 1378.118652 144.331619"
$ns_ at 13.266667 "$node_(9) setdest 434.002258 992.879150 1000.000000"
$ns_ at 13.333334 "$node_(0) setdest 43.890999 1456.779907 1000.000000"
$ns_ at 13.333334 "$node_(1) setdest 262.654968 1393.256958 1000.000000"
$ns_ at 13.333334 "$node_(2) setdest 109.508446 1452.128296 157.243244"
$ns_ at 13.333334 "$node_(3) setdest 52.911690 1543.979614 492.710813"
$ns_ at 13.333334 "$node_(4) setdest 184.980988 1108.225586 1000.000000"
$ns_ at 13.333334 "$node_(5) setdest 116.145470 1426.635742 1000.000000"
$ns_ at 13.333334 "$node_(6) setdest 129.393021 1361.159424 1000.000000"
$ns_ at 13.333334 "$node_(7) setdest 248.810242 1457.709717 513.811314"
$ns_ at 13.333334 "$node_(8) setdest 0.000100 1108.468262 1000.000000"
$ns_ at 13.333334 "$node_(9) setdest 104.325096 1392.879150 1000.000000"
$ns_ at 13.400001 "$node_(0) setdest 0.000100 1492.779907 1000.000000"
$ns_ at 13.400001 "$node_(1) setdest 657.595032 1333.004883 1000.000000"
$ns_ at 13.400001 "$node_(2) setdest 125.721115 1428.866455 106.328460"
$ns_ at 13.400001 "$node_(3) setdest 0.000100 1911.979614 1000.000000"
$ns_ at 13.400001 "$node_(4) setdest 114.797249 1308.739746 796.658207"
$ns_ at 13.400001 "$node_(5) setdest 48.696068 1522.635742 439.972979"
$ns_ at 13.400001 "$node_(6) setdest 247.535400 1105.159424 1000.000000"
$ns_ at 13.400001 "$node_(7) setdest 145.249954 1395.184570 453.643460"
$ns_ at 13.400001 "$node_(8) setdest 0.000100 1304.799194 1000.000000"
$ns_ at 13.400001 "$node_(9) setdest 246.647934 1316.879150 605.038859"
$ns_ at 13.466667 "$node_(0) setdest 46.585346 1628.779907 1000.000000"
$ns_ at 13.466667 "$node_(1) setdest 257.595062 1427.101074 1000.000000"
$ns_ at 13.466667 "$node_(2) setdest 173.933792 1617.604614 730.495281"
$ns_ at 13.466667 "$node_(3) setdest 119.414528 1511.979614 1000.000000"
$ns_ at 13.466667 "$node_(4) setdest 60.613518 1325.254028 212.416824"
$ns_ at 13.466667 "$node_(5) setdest 25.246662 1574.635742 213.910278"
$ns_ at 13.466667 "$node_(6) setdest 160.294983 1505.159424 1000.000000"
$ns_ at 13.466667 "$node_(7) setdest 505.689667 1260.659424 1000.000000"
$ns_ at 13.466667 "$node_(8) setdest 51.823761 1429.130127 562.677182"
$ns_ at 13.466667 "$node_(9) setdest 540.970764 972.879150 1000.000000"
$ns_ at 13.533334 "$node_(0) setdest 0.000100 1708.779907 400.246790"
$ns_ at 13.533334 "$node_(1) setdest 657.595032 1259.112305 1000.000000"
$ns_ at 13.533334 "$node_(2) setdest 538.146484 1526.342896 1000.000000"
$ns_ at 13.533334 "$node_(3) setdest 433.220825 1683.979614 1000.000000"
$ns_ at 13.533334 "$node_(4) setdest 202.429779 1273.768311 565.773324"
$ns_ at 13.533334 "$node_(5) setdest 137.797256 1634.635742 478.292402"
$ns_ at 13.533334 "$node_(6) setdest 417.054565 1337.159424 1000.000000"
$ns_ at 13.533334 "$node_(7) setdest 285.122284 1416.984009 1000.000000"
$ns_ at 13.533334 "$node_(8) setdest 287.823761 1429.461060 885.000812"
$ns_ at 13.533334 "$node_(9) setdest 302.074249 1372.879150 1000.000000"
$ns_ at 13.600001 "$node_(0) setdest 375.932526 1534.784424 1000.000000"
$ns_ at 13.600001 "$node_(1) setdest 401.595062 1543.123535 1000.000000"
$ns_ at 13.600001 "$node_(2) setdest 938.146484 1515.198486 1000.000000"
$ns_ at 13.600001 "$node_(3) setdest 523.027100 1755.979614 431.643826"
$ns_ at 13.600001 "$node_(4) setdest 208.246048 1134.282471 523.526431"
$ns_ at 13.600001 "$node_(5) setdest 478.347839 1486.635742 1000.000000"
$ns_ at 13.600001 "$node_(6) setdest 421.814178 1193.159424 540.294886"
$ns_ at 13.600001 "$node_(7) setdest 484.554901 1525.308594 851.073030"
$ns_ at 13.600001 "$node_(8) setdest 0.000100 1213.250854 1000.000000"
$ns_ at 13.600001 "$node_(9) setdest 35.222248 972.879150 1000.000000"
$ns_ at 13.666667 "$node_(0) setdest 271.932526 1340.788940 825.428080"
$ns_ at 13.666667 "$node_(1) setdest 389.595062 1311.134766 871.120903"
$ns_ at 13.666667 "$node_(2) setdest 538.146484 1366.435547 1000.000000"
$ns_ at 13.666667 "$node_(3) setdest 441.272125 1355.979614 1000.000000"
$ns_ at 13.666667 "$node_(4) setdest 454.062317 1342.796753 1000.000000"
$ns_ at 13.666667 "$node_(5) setdest 486.898438 1874.635742 1000.000000"
$ns_ at 13.666667 "$node_(6) setdest 438.573761 1333.159424 528.748427"
$ns_ at 13.666667 "$node_(7) setdest 487.987518 1649.633057 466.394381"
$ns_ at 13.666667 "$node_(8) setdest 287.823761 1293.119507 1000.000000"
$ns_ at 13.666667 "$node_(9) setdest 435.222260 1327.564697 1000.000000"
$ns_ at 13.733334 "$node_(0) setdest 0.000100 1491.136963 1000.000000"
$ns_ at 13.733334 "$node_(1) setdest 221.595047 1339.145996 638.697019"
$ns_ at 13.733334 "$node_(2) setdest 890.146484 1577.672485 1000.000000"
$ns_ at 13.733334 "$node_(3) setdest 627.517151 1627.979614 1000.000000"
$ns_ at 13.733334 "$node_(4) setdest 647.878601 1511.311035 963.113658"
$ns_ at 13.733334 "$node_(5) setdest 471.583954 1474.635742 1000.000000"
$ns_ at 13.733334 "$node_(6) setdest 591.333374 1357.159424 579.875363"
$ns_ at 13.733334 "$node_(7) setdest 467.420135 1421.957642 857.259420"
$ns_ at 13.733334 "$node_(8) setdest 3.823762 1072.988159 1000.000000"
$ns_ at 13.733334 "$node_(9) setdest 211.222244 1158.250244 1000.000000"
$ns_ at 13.800001 "$node_(0) setdest 271.932526 1404.702271 1000.000000"
$ns_ at 13.800001 "$node_(1) setdest 381.595062 1499.157349 848.558248"
$ns_ at 13.800001 "$node_(2) setdest 490.146454 1421.455811 1000.000000"
$ns_ at 13.800001 "$node_(3) setdest 473.762177 1599.979614 586.063812"
$ns_ at 13.800001 "$node_(4) setdest 909.694824 1723.825317 1000.000000"
$ns_ at 13.800001 "$node_(5) setdest 532.269470 1562.635742 400.859564"
$ns_ at 13.800001 "$node_(6) setdest 572.092957 1257.159424 381.878022"
$ns_ at 13.800001 "$node_(7) setdest 522.852783 1334.282227 388.984660"
$ns_ at 13.800001 "$node_(8) setdest 403.823761 1398.535645 1000.000000"
$ns_ at 13.800001 "$node_(9) setdest 427.222260 1428.935669 1000.000000"
$ns_ at 13.866667 "$node_(0) setdest 191.932526 1430.267456 314.945939"
$ns_ at 13.866667 "$node_(1) setdest 333.595062 1655.168579 612.106387"
$ns_ at 13.866667 "$node_(2) setdest 730.146484 1549.239014 1000.000000"
$ns_ at 13.866667 "$node_(3) setdest 804.007202 1627.979614 1000.000000"
$ns_ at 13.866667 "$node_(4) setdest 711.511108 1652.339478 790.058400"
$ns_ at 13.866667 "$node_(5) setdest 220.954971 1438.635742 1000.000000"
$ns_ at 13.866667 "$node_(6) setdest 912.852539 1249.159424 1000.000000"
$ns_ at 13.866667 "$node_(7) setdest 598.285400 1546.606689 844.972070"
$ns_ at 13.866667 "$node_(8) setdest 359.823761 1324.083130 324.308350"
$ns_ at 13.866667 "$node_(9) setdest 491.222260 1491.621216 335.943843"
$ns_ at 13.933334 "$node_(0) setdest 423.932526 1631.832764 1000.000000"
$ns_ at 13.933334 "$node_(1) setdest 555.269653 1526.143433 961.837413"
$ns_ at 13.933334 "$node_(2) setdest 778.146484 1361.022339 728.403244"
$ns_ at 13.933334 "$node_(3) setdest 606.252258 1491.979614 900.023528"
$ns_ at 13.933334 "$node_(4) setdest 953.327393 1916.853760 1000.000000"
$ns_ at 13.933334 "$node_(5) setdest 620.954956 1545.128540 1000.000000"
$ns_ at 13.933334 "$node_(6) setdest 512.852539 1548.740845 1000.000000"
$ns_ at 13.933334 "$node_(7) setdest 941.718018 1554.931274 1000.000000"
$ns_ at 13.933334 "$node_(8) setdest 467.823761 1389.630615 473.755335"
$ns_ at 13.933334 "$node_(9) setdest 359.886688 1305.576538 853.993219"
$ns_ at 14.000001 "$node_(0) setdest 119.932518 1941.398071 1000.000000"
$ns_ at 14.000001 "$node_(1) setdest 712.944214 1701.118164 883.261654"
$ns_ at 14.000001 "$node_(2) setdest 694.146484 1596.805542 938.622159"
$ns_ at 14.000001 "$node_(3) setdest 864.497253 1463.979614 974.094264"
$ns_ at 14.000001 "$node_(4) setdest 671.680359 1516.853760 1000.000000"
$ns_ at 14.000001 "$node_(5) setdest 716.954956 1527.621460 365.937319"
$ns_ at 14.000001 "$node_(6) setdest 480.852509 1672.322388 478.715061"
$ns_ at 14.000001 "$node_(7) setdest 725.150635 1647.255859 882.846348"
$ns_ at 14.000001 "$node_(8) setdest 723.823792 1571.178101 1000.000000"
$ns_ at 14.000001 "$node_(9) setdest 603.239075 1488.371216 1000.000000"
$ns_ at 14.066667 "$node_(0) setdest 519.932495 1743.728394 1000.000000"
$ns_ at 14.066667 "$node_(1) setdest 858.618835 1999.999900 1000.000000"
$ns_ at 14.066667 "$node_(2) setdest 846.146484 1768.588867 860.161298"
$ns_ at 14.066667 "$node_(3) setdest 590.742310 1723.979614 1000.000000"
$ns_ at 14.066667 "$node_(4) setdest 774.033386 1436.853760 487.155736"
$ns_ at 14.066667 "$node_(5) setdest 732.954956 1358.114258 638.477407"
$ns_ at 14.066667 "$node_(6) setdest 508.852509 1571.903809 390.934390"
$ns_ at 14.066667 "$node_(7) setdest 784.583252 1699.580322 296.939491"
$ns_ at 14.066667 "$node_(8) setdest 799.823792 1496.725586 398.968542"
$ns_ at 14.066667 "$node_(9) setdest 342.591492 1659.166016 1000.000000"
$ns_ at 14.133334 "$node_(0) setdest 815.932495 1974.058594 1000.000000"
$ns_ at 14.133334 "$node_(1) setdest 707.765381 1656.093018 1000.000000"
$ns_ at 14.133334 "$node_(2) setdest 694.146484 1656.372070 708.507978"
$ns_ at 14.133334 "$node_(3) setdest 428.987335 1959.979614 1000.000000"
$ns_ at 14.133334 "$node_(4) setdest 680.386353 1656.853760 896.632472"
$ns_ at 14.133334 "$node_(5) setdest 716.954956 1732.607178 1000.000000"
$ns_ at 14.133334 "$node_(6) setdest 520.852539 1451.485229 453.806310"
$ns_ at 14.133334 "$node_(7) setdest 708.015869 1679.904907 296.456064"
$ns_ at 14.133334 "$node_(8) setdest 1080.430420 1096.725586 1000.000000"
$ns_ at 14.133334 "$node_(9) setdest 742.591492 1668.905151 1000.000000"
$ns_ at 14.200001 "$node_(0) setdest 707.932495 1596.388916 1000.000000"
$ns_ at 14.200001 "$node_(1) setdest 760.911987 1648.093018 201.545023"
$ns_ at 14.200001 "$node_(2) setdest 614.146484 1624.155273 323.412678"
$ns_ at 14.200001 "$node_(3) setdest 791.232361 1595.979614 1000.000000"
$ns_ at 14.200001 "$node_(4) setdest 525.043457 1646.812622 583.751534"
$ns_ at 14.200001 "$node_(5) setdest 664.954956 1995.099976 1000.000000"
$ns_ at 14.200001 "$node_(6) setdest 672.852539 1515.066650 617.858359"
$ns_ at 14.200001 "$node_(7) setdest 671.448486 1992.229492 1000.000000"
$ns_ at 14.200001 "$node_(8) setdest 835.949707 1496.725586 1000.000000"
$ns_ at 14.200001 "$node_(9) setdest 675.592651 1999.999900 1000.000000"
$ns_ at 14.266667 "$node_(0) setdest 514.849854 1996.388916 1000.000000"
$ns_ at 14.266667 "$node_(1) setdest 894.058533 1940.093018 1000.000000"
$ns_ at 14.266667 "$node_(2) setdest 679.124512 1775.575073 617.898241"
$ns_ at 14.266667 "$node_(3) setdest 809.477417 1827.979614 872.686112"
$ns_ at 14.266667 "$node_(4) setdest 666.181885 1754.592896 665.945915"
$ns_ at 14.266667 "$node_(5) setdest 668.954956 1817.592896 665.820488"
$ns_ at 14.266667 "$node_(6) setdest 496.852509 1814.648193 1000.000000"
$ns_ at 14.266667 "$node_(7) setdest 1002.881104 1984.553955 1000.000000"
$ns_ at 14.266667 "$node_(8) setdest 687.468872 1760.725586 1000.000000"
$ns_ at 14.266667 "$node_(9) setdest 836.593811 1780.905151 1000.000000"
$ns_ at 14.333334 "$node_(0) setdest 665.767151 1999.999900 1000.000000"
$ns_ at 14.333334 "$node_(1) setdest 875.205078 1999.999900 1000.000000"
$ns_ at 14.333334 "$node_(2) setdest 672.102478 1878.994873 388.717183"
$ns_ at 14.333334 "$node_(3) setdest 1127.722412 1999.999900 1000.000000"
$ns_ at 14.333334 "$node_(4) setdest 731.320251 1830.373291 374.731302"
$ns_ at 14.333334 "$node_(5) setdest 752.954956 1999.999900 1000.000000"
$ns_ at 14.333334 "$node_(6) setdest 616.852539 1999.999900 860.476640"
$ns_ at 14.333334 "$node_(7) setdest 698.313721 1972.878540 1000.000000"
$ns_ at 14.333334 "$node_(8) setdest 630.988098 1948.725586 736.128692"
$ns_ at 14.333334 "$node_(9) setdest 873.594971 1832.905151 239.327733"
$ns_ at 14.400001 "$node_(0) setdest 716.684448 1999.999900 217.906011"
$ns_ at 14.400001 "$node_(1) setdest 1080.351685 1999.999900 810.461040"
$ns_ at 14.400001 "$node_(2) setdest 797.080505 1999.999900 1000.000000"
$ns_ at 14.400001 "$node_(3) setdest 911.043884 1999.999900 813.228794"
$ns_ at 14.400001 "$node_(4) setdest 1048.458618 1746.153564 1000.000000"
$ns_ at 14.400001 "$node_(5) setdest 1068.954956 1999.999900 1000.000000"
$ns_ at 14.400001 "$node_(6) setdest 720.852539 1999.999900 1000.000000"
$ns_ at 14.400001 "$node_(7) setdest 741.746338 1999.999900 1000.000000"
$ns_ at 14.400001 "$node_(8) setdest 826.507324 1999.999900 1000.000000"
$ns_ at 14.400001 "$node_(9) setdest 790.596130 1999.999900 1000.000000"
$ns_ at 14.466667 "$node_(0) setdest 608.854553 1999.999900 1000.000000"
$ns_ at 14.466667 "$node_(1) setdest 1113.490479 1999.999900 656.715798"
$ns_ at 14.466667 "$node_(2) setdest 982.509644 1999.999900 842.709001"
$ns_ at 14.466667 "$node_(3) setdest 1194.365356 1999.999900 1000.000000"
$ns_ at 14.466667 "$node_(4) setdest 975.973999 1999.999900 1000.000000"
$ns_ at 14.466667 "$node_(5) setdest 888.954956 1999.999900 734.917564"
$ns_ at 14.466667 "$node_(6) setdest 792.852539 1999.999900 436.857754"
$ns_ at 14.466667 "$node_(7) setdest 665.178955 1999.999900 818.248344"
$ns_ at 14.466667 "$node_(8) setdest 1042.026489 1999.999900 867.414048"
$ns_ at 14.466667 "$node_(9) setdest 903.597229 1928.905151 1000.000000"
$ns_ at 14.533334 "$node_(0) setdest 953.024658 1999.999900 1000.000000"
$ns_ at 14.533334 "$node_(1) setdest 1238.629395 1999.999900 541.326285"
$ns_ at 14.533334 "$node_(2) setdest 948.376160 1999.999900 980.900408"
$ns_ at 14.533334 "$node_(3) setdest 1017.686768 1999.999900 666.406997"
$ns_ at 14.533334 "$node_(4) setdest 891.489380 1999.999900 364.380579"
$ns_ at 14.533334 "$node_(5) setdest 828.954956 1999.999900 763.265436"
$ns_ at 14.533334 "$node_(6) setdest 820.852539 1999.999900 129.953778"
$ns_ at 14.533334 "$node_(7) setdest 1000.611572 1999.999900 1000.000000"
$ns_ at 14.533334 "$node_(8) setdest 1141.545776 1999.999900 498.172906"
$ns_ at 14.533334 "$node_(9) setdest 955.054688 1999.999900 1000.000000"
$ns_ at 14.600001 "$node_(0) setdest 781.194763 1999.999900 1000.000000"
$ns_ at 14.600001 "$node_(1) setdest 1018.375854 1999.999900 994.286104"
$ns_ at 14.600001 "$node_(2) setdest 858.242615 1999.999900 514.208595"
$ns_ at 14.600001 "$node_(3) setdest 1341.008179 1999.999900 1000.000000"
$ns_ at 14.600001 "$node_(4) setdest 939.004761 1999.999900 223.548792"
$ns_ at 14.600001 "$node_(5) setdest 1040.954956 1999.999900 1000.000000"
$ns_ at 14.600001 "$node_(6) setdest 748.852539 1999.999900 276.250148"
$ns_ at 14.600001 "$node_(7) setdest 1008.044189 1938.176758 1000.000000"
$ns_ at 14.600001 "$node_(8) setdest 1333.064941 1999.999900 898.558112"
$ns_ at 14.600001 "$node_(9) setdest 990.512085 1999.999900 585.303123"
$ns_ at 14.666667 "$node_(0) setdest 948.522461 1999.999900 1000.000000"
$ns_ at 14.666667 "$node_(1) setdest 1342.122314 1860.790161 1000.000000"
$ns_ at 14.666667 "$node_(2) setdest 788.109131 1999.999900 925.636663"
$ns_ at 14.666667 "$node_(3) setdest 964.329651 1999.999900 1000.000000"
$ns_ at 14.666667 "$node_(4) setdest 1006.520203 1922.153564 834.341940"
$ns_ at 14.666667 "$node_(5) setdest 1104.954956 1999.999900 835.848555"
$ns_ at 14.666667 "$node_(6) setdest 1032.852539 1999.999900 1000.000000"
$ns_ at 14.666667 "$node_(7) setdest 1031.898682 1999.999900 711.054917"
$ns_ at 14.666667 "$node_(8) setdest 976.584167 1999.999900 1000.000000"
$ns_ at 14.666667 "$node_(9) setdest 1033.969604 1999.999900 265.815368"
$ns_ at 14.733334 "$node_(0) setdest 819.850220 1999.999900 1000.000000"
$ns_ at 14.733334 "$node_(1) setdest 973.868835 1999.999900 1000.000000"
$ns_ at 14.733334 "$node_(2) setdest 525.975586 1999.999900 1000.000000"
$ns_ at 14.733334 "$node_(3) setdest 719.651123 1770.609741 1000.000000"
$ns_ at 14.733334 "$node_(4) setdest 1038.035645 1702.153564 833.421950"
$ns_ at 14.733334 "$node_(5) setdest 1500.954956 1995.042847 1000.000000"
$ns_ at 14.733334 "$node_(6) setdest 1068.852539 1999.999900 163.125979"
$ns_ at 14.733334 "$node_(7) setdest 1151.753174 1886.393311 1000.000000"
$ns_ at 14.733334 "$node_(8) setdest 1024.103394 1999.999900 785.480191"
$ns_ at 14.733334 "$node_(9) setdest 1105.427002 1999.999900 282.675376"
$ns_ at 14.800001 "$node_(0) setdest 907.710571 1999.999900 1000.000000"
$ns_ at 14.800001 "$node_(1) setdest 895.701172 1625.178589 1000.000000"
$ns_ at 14.800001 "$node_(2) setdest 925.975586 1924.977905 1000.000000"
$ns_ at 14.800001 "$node_(3) setdest 834.972534 1999.999900 1000.000000"
$ns_ at 14.800001 "$node_(4) setdest 964.814514 1906.689819 814.677558"
$ns_ at 14.800001 "$node_(5) setdest 1100.954956 1934.100830 1000.000000"
$ns_ at 14.800001 "$node_(6) setdest 948.852539 1871.299805 1000.000000"
$ns_ at 14.800001 "$node_(7) setdest 1167.607544 1846.501587 160.975519"
$ns_ at 14.800001 "$node_(8) setdest 1179.622681 1812.725586 1000.000000"
$ns_ at 14.800001 "$node_(9) setdest 1460.884399 1999.999900 1000.000000"
$ns_ at 14.866667 "$node_(0) setdest 1167.570923 1944.388916 1000.000000"
$ns_ at 14.866667 "$node_(1) setdest 1109.533569 1901.178589 1000.000000"
$ns_ at 14.866667 "$node_(2) setdest 729.975586 1761.143677 957.959125"
$ns_ at 14.866667 "$node_(3) setdest 970.294006 1968.819824 680.472644"
$ns_ at 14.866667 "$node_(4) setdest 835.593506 1759.226196 735.263862"
$ns_ at 14.866667 "$node_(5) setdest 1200.954956 1999.999900 478.035768"
$ns_ at 14.866667 "$node_(6) setdest 1040.852539 1862.881226 346.441394"
$ns_ at 14.866667 "$node_(7) setdest 1223.462036 1606.609863 923.655977"
$ns_ at 14.866667 "$node_(8) setdest 1071.141846 1740.725586 488.250707"
$ns_ at 14.866667 "$node_(9) setdest 1132.954956 1924.905151 1000.000000"
$ns_ at 14.933334 "$node_(0) setdest 1435.431396 1856.388916 1000.000000"
$ns_ at 14.933334 "$node_(1) setdest 1251.365967 1797.178589 659.535622"
$ns_ at 14.933334 "$node_(2) setdest 1009.975586 1749.309448 1000.000000"
$ns_ at 14.933334 "$node_(3) setdest 821.615479 1871.924927 665.494789"
$ns_ at 14.933334 "$node_(4) setdest 934.372437 1643.762451 569.816808"
$ns_ at 14.933334 "$node_(5) setdest 1032.954956 1712.216919 1000.000000"
$ns_ at 14.933334 "$node_(6) setdest 972.852539 1999.999900 748.224010"
$ns_ at 14.933334 "$node_(7) setdest 1199.316528 1478.718140 488.066457"
$ns_ at 14.933334 "$node_(8) setdest 1178.661011 1684.725586 454.607196"
$ns_ at 14.933334 "$node_(9) setdest 1249.025635 1936.905151 437.584997"
$ns_ at 15.000001 "$node_(0) setdest 1139.731201 1704.908691 1000.000000"
$ns_ at 15.000001 "$node_(1) setdest 1149.198242 1701.178589 525.725929"
$ns_ at 15.000001 "$node_(2) setdest 1205.975586 1837.475342 805.937878"
$ns_ at 15.000001 "$node_(3) setdest 1072.936890 1515.029907 1000.000000"
$ns_ at 15.000001 "$node_(4) setdest 1089.151367 1648.298706 580.670212"
$ns_ at 15.000001 "$node_(5) setdest 868.954956 1675.274902 630.409551"
$ns_ at 15.000001 "$node_(6) setdest 1192.852539 1654.044189 1000.000000"
$ns_ at 15.000001 "$node_(7) setdest 1167.170898 1734.826538 967.942149"
$ns_ at 15.000001 "$node_(8) setdest 1358.221436 1810.670166 822.473216"
$ns_ at 15.000001 "$node_(9) setdest 1149.096191 1672.905151 1000.000000"
$ns_ at 15.066667 "$node_(0) setdest 1156.031006 1789.428345 322.788861"
$ns_ at 15.066667 "$node_(1) setdest 1247.030640 1805.178589 535.438758"
$ns_ at 15.066667 "$node_(2) setdest 1253.975586 1793.641113 243.762662"
$ns_ at 15.066667 "$node_(3) setdest 940.258362 1234.135010 1000.000000"
$ns_ at 15.066667 "$node_(4) setdest 851.930359 1352.835083 1000.000000"
$ns_ at 15.066667 "$node_(5) setdest 1198.223022 1614.526855 1000.000000"
$ns_ at 15.066667 "$node_(6) setdest 1248.852539 1457.625610 765.920923"
$ns_ at 15.066667 "$node_(7) setdest 1175.025391 1698.934814 137.779148"
$ns_ at 15.066667 "$node_(8) setdest 1186.893555 1635.055298 920.041074"
$ns_ at 15.066667 "$node_(9) setdest 1069.166870 1588.905151 434.817244"
$ns_ at 15.133334 "$node_(0) setdest 1032.330933 1877.948120 570.412530"
$ns_ at 15.133334 "$node_(1) setdest 1212.863037 1817.178589 135.801008"
$ns_ at 15.133334 "$node_(2) setdest 1109.975586 1473.806885 1000.000000"
$ns_ at 15.133334 "$node_(3) setdest 1159.579834 1553.239990 1000.000000"
$ns_ at 15.133334 "$node_(4) setdest 1182.709351 1541.371338 1000.000000"
$ns_ at 15.133334 "$node_(5) setdest 1207.490967 1821.778809 777.971494"
$ns_ at 15.133334 "$node_(6) setdest 1464.852539 1149.207031 1000.000000"
$ns_ at 15.133334 "$node_(7) setdest 1118.879883 1847.043091 593.974140"
$ns_ at 15.133334 "$node_(8) setdest 1219.565674 1651.440552 137.064621"
$ns_ at 15.133334 "$node_(9) setdest 1123.435059 1515.559570 342.147371"
$ns_ at 15.200001 "$node_(0) setdest 1249.433594 1639.181641 1000.000000"
$ns_ at 15.200001 "$node_(1) setdest 1242.695435 1629.178589 713.820840"
$ns_ at 15.200001 "$node_(2) setdest 790.561218 1073.806885 1000.000000"
$ns_ at 15.200001 "$node_(3) setdest 1002.901245 1420.345093 770.433157"
$ns_ at 15.200001 "$node_(4) setdest 1101.488281 1377.907593 684.488032"
$ns_ at 15.200001 "$node_(5) setdest 1148.759033 1999.999900 1000.000000"
$ns_ at 15.200001 "$node_(6) setdest 1278.234131 1549.207031 1000.000000"
$ns_ at 15.200001 "$node_(7) setdest 1146.734253 1811.151367 170.370618"
$ns_ at 15.200001 "$node_(8) setdest 1284.237671 1763.825684 486.241868"
$ns_ at 15.200001 "$node_(9) setdest 861.703247 1542.213989 986.570726"
$ns_ at 15.266667 "$node_(0) setdest 1038.536255 1384.415039 1000.000000"
$ns_ at 15.266667 "$node_(1) setdest 1032.527710 1341.178589 1000.000000"
$ns_ at 15.266667 "$node_(2) setdest 999.181519 1473.806885 1000.000000"
$ns_ at 15.266667 "$node_(3) setdest 1044.289551 1555.107178 528.654357"
$ns_ at 15.266667 "$node_(4) setdest 980.267212 1242.443970 681.684973"
$ns_ at 15.266667 "$node_(5) setdest 1084.821289 1761.030762 1000.000000"
$ns_ at 15.266667 "$node_(6) setdest 1031.615723 1517.207031 932.571782"
$ns_ at 15.266667 "$node_(7) setdest 1026.588745 1539.259644 1000.000000"
$ns_ at 15.266667 "$node_(8) setdest 1200.909790 1528.210938 937.183751"
$ns_ at 15.266667 "$node_(9) setdest 461.703247 1713.018555 1000.000000"
$ns_ at 15.333334 "$node_(0) setdest 866.746948 984.415039 1000.000000"
$ns_ at 15.333334 "$node_(1) setdest 910.360107 1121.178589 943.666600"
$ns_ at 15.333334 "$node_(2) setdest 731.801758 1173.806885 1000.000000"
$ns_ at 15.333334 "$node_(3) setdest 721.677795 1469.869263 1000.000000"
$ns_ at 15.333334 "$node_(4) setdest 867.046143 1446.980225 876.682961"
$ns_ at 15.333334 "$node_(5) setdest 856.883423 1421.030762 1000.000000"
$ns_ at 15.333334 "$node_(6) setdest 1048.997192 1541.207031 111.123792"
$ns_ at 15.333334 "$node_(7) setdest 998.443176 1647.368042 418.920457"
$ns_ at 15.333334 "$node_(8) setdest 993.581909 1416.596069 882.985450"
$ns_ at 15.333334 "$node_(9) setdest 861.703247 1432.371948 1000.000000"
$ns_ at 15.400001 "$node_(0) setdest 918.957703 1104.415039 490.748208"
$ns_ at 15.400001 "$node_(1) setdest 780.192444 1257.178589 705.952970"
$ns_ at 15.400001 "$node_(2) setdest 580.422058 1249.806885 635.199647"
$ns_ at 15.400001 "$node_(3) setdest 399.066040 1320.631470 1000.000000"
$ns_ at 15.400001 "$node_(4) setdest 577.825134 1347.516479 1000.000000"
$ns_ at 15.400001 "$node_(5) setdest 540.945618 1277.030762 1000.000000"
$ns_ at 15.400001 "$node_(6) setdest 1046.378784 1317.207031 840.057348"
$ns_ at 15.400001 "$node_(7) setdest 799.956421 1247.368042 1000.000000"
$ns_ at 15.400001 "$node_(8) setdest 1106.254028 1372.981201 453.071742"
$ns_ at 15.400001 "$node_(9) setdest 685.703247 1707.725220 1000.000000"
$ns_ at 15.466667 "$node_(0) setdest 823.168396 988.415039 564.142484"
$ns_ at 15.466667 "$node_(1) setdest 778.024841 1277.178589 75.439192"
$ns_ at 15.466667 "$node_(2) setdest 657.042358 1145.806885 484.413332"
$ns_ at 15.466667 "$node_(3) setdest 656.454285 1283.393555 975.255038"
$ns_ at 15.466667 "$node_(4) setdest 592.604065 1412.052856 248.276068"
$ns_ at 15.466667 "$node_(5) setdest 413.007812 1409.030762 689.348337"
$ns_ at 15.466667 "$node_(6) setdest 646.378845 1294.378662 1000.000000"
$ns_ at 15.466667 "$node_(7) setdest 1037.469604 1335.368042 949.842518"
$ns_ at 15.466667 "$node_(8) setdest 706.253967 1302.746826 1000.000000"
$ns_ at 15.466667 "$node_(9) setdest 625.936829 1307.725220 1000.000000"
$ns_ at 15.533334 "$node_(0) setdest 635.379150 1264.415039 1000.000000"
$ns_ at 15.533334 "$node_(1) setdest 903.857178 1225.178589 510.575611"
$ns_ at 15.533334 "$node_(2) setdest 635.138550 745.806946 1000.000000"
$ns_ at 15.533334 "$node_(3) setdest 621.842529 1198.155640 344.989310"
$ns_ at 15.533334 "$node_(4) setdest 651.383057 1208.589111 794.190003"
$ns_ at 15.533334 "$node_(5) setdest 677.070007 1197.030762 1000.000000"
$ns_ at 15.533334 "$node_(6) setdest 650.378845 1511.550415 814.532161"
$ns_ at 15.533334 "$node_(7) setdest 637.469604 1230.675781 1000.000000"
$ns_ at 15.533334 "$node_(8) setdest 1070.254028 1640.512451 1000.000000"
$ns_ at 15.533334 "$node_(9) setdest 554.170410 1703.725220 1000.000000"
$ns_ at 15.600001 "$node_(0) setdest 691.589844 1504.415039 924.355096"
$ns_ at 15.600001 "$node_(1) setdest 734.226501 1298.477051 692.961294"
$ns_ at 15.600001 "$node_(2) setdest 687.003723 1145.806885 1000.000000"
$ns_ at 15.600001 "$node_(3) setdest 447.230835 1240.917847 674.143718"
$ns_ at 15.600001 "$node_(4) setdest 622.161987 1241.125366 163.994599"
$ns_ at 15.600001 "$node_(5) setdest 725.132202 1165.030762 216.527169"
$ns_ at 15.600001 "$node_(6) setdest 759.087646 1111.550415 1000.000000"
$ns_ at 15.600001 "$node_(7) setdest 473.469604 1429.983521 967.903697"
$ns_ at 15.600001 "$node_(8) setdest 670.253967 1268.073242 1000.000000"
$ns_ at 15.600001 "$node_(9) setdest 598.403931 1419.725220 1000.000000"
$ns_ at 15.666667 "$node_(0) setdest 651.800598 1308.415039 749.992293"
$ns_ at 15.666667 "$node_(1) setdest 1028.595825 1503.775513 1000.000000"
$ns_ at 15.666667 "$node_(2) setdest 578.868958 937.806946 879.109852"
$ns_ at 15.666667 "$node_(3) setdest 608.619080 1271.679932 616.101919"
$ns_ at 15.666667 "$node_(4) setdest 576.940918 981.661682 987.655855"
$ns_ at 15.666667 "$node_(5) setdest 805.194397 933.030823 920.347490"
$ns_ at 15.666667 "$node_(6) setdest 551.796448 1331.550415 1000.000000"
$ns_ at 15.666667 "$node_(7) setdest 73.469597 1675.023438 1000.000000"
$ns_ at 15.666667 "$node_(8) setdest 878.253967 1055.634033 1000.000000"
$ns_ at 15.666667 "$node_(9) setdest 554.637512 1631.725220 811.764522"
$ns_ at 15.733334 "$node_(0) setdest 764.011292 1272.415039 441.915470"
$ns_ at 15.733334 "$node_(1) setdest 628.595764 1249.056274 1000.000000"
$ns_ at 15.733334 "$node_(2) setdest 626.441467 1244.368408 1000.000000"
$ns_ at 15.733334 "$node_(3) setdest 470.007355 1234.442017 538.224536"
$ns_ at 15.733334 "$node_(4) setdest 611.592041 1216.133057 888.817417"
$ns_ at 15.733334 "$node_(5) setdest 593.256592 1301.030762 1000.000000"
$ns_ at 15.733334 "$node_(6) setdest 496.034515 1547.810547 837.500452"
$ns_ at 15.733334 "$node_(7) setdest 473.469604 1364.554199 1000.000000"
$ns_ at 15.733334 "$node_(8) setdest 574.253967 1283.194824 1000.000000"
$ns_ at 15.733334 "$node_(9) setdest 622.100830 1231.725220 1000.000000"
$ns_ at 15.800001 "$node_(0) setdest 1164.011230 1372.982056 1000.000000"
$ns_ at 15.800001 "$node_(1) setdest 1004.595764 1226.337036 1000.000000"
$ns_ at 15.800001 "$node_(2) setdest 942.014038 1134.929932 1000.000000"
$ns_ at 15.800001 "$node_(3) setdest 70.007347 1121.822876 1000.000000"
$ns_ at 15.800001 "$node_(4) setdest 710.243103 998.604370 895.698749"
$ns_ at 15.800001 "$node_(5) setdest 665.318787 1313.030762 273.954349"
$ns_ at 15.800001 "$node_(6) setdest 534.164490 1352.379883 746.683635"
$ns_ at 15.800001 "$node_(7) setdest 73.469597 1591.503540 1000.000000"
$ns_ at 15.800001 "$node_(8) setdest 470.253967 1262.755493 397.460469"
$ns_ at 15.800001 "$node_(9) setdest 721.564148 1143.725220 498.015664"
$ns_ at 15.866667 "$node_(0) setdest 764.011292 1331.219727 1000.000000"
$ns_ at 15.866667 "$node_(1) setdest 672.595764 1299.617798 1000.000000"
$ns_ at 15.866667 "$node_(2) setdest 801.586609 1029.491455 658.518929"
$ns_ at 15.866667 "$node_(3) setdest 470.007355 1181.149292 1000.000000"
$ns_ at 15.866667 "$node_(4) setdest 668.894165 1109.075684 442.335411"
$ns_ at 15.866667 "$node_(5) setdest 845.380981 1369.030762 707.134973"
$ns_ at 15.866667 "$node_(6) setdest 688.294495 1528.949341 878.915760"
$ns_ at 15.866667 "$node_(7) setdest 473.469604 1344.253174 1000.000000"
$ns_ at 15.866667 "$node_(8) setdest 514.253967 1358.316284 394.514674"
$ns_ at 15.866667 "$node_(9) setdest 657.027466 1031.725220 484.737085"
$ns_ at 15.933334 "$node_(0) setdest 796.011292 1289.457275 197.297835"
$ns_ at 15.933334 "$node_(1) setdest 948.595764 1352.898560 1000.000000"
$ns_ at 15.933334 "$node_(2) setdest 809.159119 1224.052856 730.157623"
$ns_ at 15.933334 "$node_(3) setdest 454.007355 1180.475708 60.053140"
$ns_ at 15.933334 "$node_(4) setdest 431.545258 1055.546997 912.412958"
$ns_ at 15.933334 "$node_(5) setdest 541.443176 1269.030762 1000.000000"
$ns_ at 15.933334 "$node_(6) setdest 662.092712 1255.764648 1000.000000"
$ns_ at 15.933334 "$node_(7) setdest 377.469604 1597.002808 1000.000000"
$ns_ at 15.933334 "$node_(8) setdest 518.253967 1437.877075 298.729776"
$ns_ at 15.933334 "$node_(9) setdest 684.490845 1295.725220 995.342279"
$ns_ at 16.000001 "$node_(0) setdest 796.011292 1431.694824 533.390780"
$ns_ at 16.000001 "$node_(1) setdest 548.595764 1331.465210 1000.000000"
$ns_ at 16.000001 "$node_(2) setdest 836.731689 1222.614380 103.537754"
$ns_ at 16.000001 "$node_(3) setdest 514.007324 1199.802124 236.384084"
$ns_ at 16.000001 "$node_(4) setdest 626.196289 1366.018311 1000.000000"
$ns_ at 16.000001 "$node_(5) setdest 293.505371 1009.030823 1000.000000"
$ns_ at 16.000001 "$node_(6) setdest 829.931335 928.416809 1000.000000"
$ns_ at 16.000001 "$node_(7) setdest 621.469604 1281.752563 1000.000000"
$ns_ at 16.000001 "$node_(8) setdest 190.253967 1793.437866 1000.000000"
$ns_ at 16.000001 "$node_(9) setdest 895.954163 1179.725220 904.463378"
$ns_ at 16.066668 "$node_(0) setdest 936.011292 1433.932373 525.067035"
$ns_ at 16.066668 "$node_(1) setdest 544.595764 1394.031982 235.104377"
$ns_ at 16.066668 "$node_(2) setdest 617.229553 1252.667847 830.812411"
$ns_ at 16.066668 "$node_(3) setdest 398.007355 1007.128479 843.367609"
$ns_ at 16.066668 "$node_(4) setdest 596.847412 1404.489624 181.454992"
$ns_ at 16.066668 "$node_(5) setdest 665.567566 1305.030762 1000.000000"
$ns_ at 16.066668 "$node_(6) setdest 569.769897 1321.068970 1000.000000"
$ns_ at 16.066668 "$node_(7) setdest 621.469604 1126.502197 582.188843"
$ns_ at 16.066668 "$node_(8) setdest 504.502350 1393.437866 1000.000000"
$ns_ at 16.066668 "$node_(9) setdest 559.417480 1271.725220 1000.000000"
$ns_ at 16.133334 "$node_(0) setdest 540.011292 1292.169922 1000.000000"
$ns_ at 16.133334 "$node_(1) setdest 400.595795 1720.598755 1000.000000"
$ns_ at 16.133334 "$node_(2) setdest 848.878967 990.331604 1000.000000"
$ns_ at 16.133334 "$node_(3) setdest 618.007324 1358.454834 1000.000000"
$ns_ at 16.133334 "$node_(4) setdest 662.711121 1627.389282 871.600983"
$ns_ at 16.133334 "$node_(5) setdest 1065.567505 1340.113770 1000.000000"
$ns_ at 16.133334 "$node_(6) setdest 617.608459 1425.721191 431.504494"
$ns_ at 16.133334 "$node_(7) setdest 729.469604 1031.251831 540.008212"
$ns_ at 16.133334 "$node_(8) setdest 242.750732 1565.437866 1000.000000"
$ns_ at 16.133334 "$node_(9) setdest 526.880798 1043.725220 863.661988"
$ns_ at 16.200001 "$node_(0) setdest 548.011292 1214.407593 293.147835"
$ns_ at 16.200001 "$node_(1) setdest 646.814941 1377.402344 1000.000000"
$ns_ at 16.200001 "$node_(2) setdest 638.984558 1390.331543 1000.000000"
$ns_ at 16.200001 "$node_(3) setdest 650.007324 1377.781250 140.187328"
$ns_ at 16.200001 "$node_(4) setdest 653.777039 1486.945679 527.728015"
$ns_ at 16.200001 "$node_(5) setdest 665.567566 1377.481201 1000.000000"
$ns_ at 16.200001 "$node_(6) setdest 517.447083 1446.373413 383.506288"
$ns_ at 16.200001 "$node_(7) setdest 633.649170 1431.251831 1000.000000"
$ns_ at 16.200001 "$node_(8) setdest 642.750732 1388.124146 1000.000000"
$ns_ at 16.200001 "$node_(9) setdest 642.344116 1279.725220 985.242640"
$ns_ at 16.266668 "$node_(0) setdest 224.723434 814.407532 1000.000000"
$ns_ at 16.266668 "$node_(1) setdest 737.034180 1406.205933 355.146113"
$ns_ at 16.266668 "$node_(2) setdest 637.090088 1390.331543 7.104263"
$ns_ at 16.266668 "$node_(3) setdest 624.912231 1408.621948 149.102575"
$ns_ at 16.266668 "$node_(4) setdest 784.842896 1538.502197 528.155681"
$ns_ at 16.266668 "$node_(5) setdest 881.567566 1306.848511 852.207368"
$ns_ at 16.266668 "$node_(6) setdest 182.055252 1709.851807 1000.000000"
$ns_ at 16.266668 "$node_(7) setdest 509.828766 1631.251831 882.099220"
$ns_ at 16.266668 "$node_(8) setdest 510.750732 1498.810425 645.996117"
$ns_ at 16.266668 "$node_(9) setdest 537.807434 1039.725220 981.668879"
$ns_ at 16.333334 "$node_(0) setdest 428.791412 1214.407593 1000.000000"
$ns_ at 16.333334 "$node_(1) setdest 427.253326 1483.009521 1000.000000"
$ns_ at 16.333334 "$node_(2) setdest 627.195618 1250.331543 526.309520"
$ns_ at 16.333334 "$node_(3) setdest 883.817078 1643.462646 1000.000000"
$ns_ at 16.333334 "$node_(4) setdest 459.908783 1350.058594 1000.000000"
$ns_ at 16.333334 "$node_(5) setdest 481.567566 1373.546143 1000.000000"
$ns_ at 16.333334 "$node_(6) setdest 465.710846 1417.500122 1000.000000"
$ns_ at 16.333334 "$node_(7) setdest 510.008331 1455.251831 660.000309"
$ns_ at 16.333334 "$node_(8) setdest 558.750732 1497.496704 180.067396"
$ns_ at 16.333334 "$node_(9) setdest 617.270813 1255.725220 863.073933"
$ns_ at 16.400001 "$node_(0) setdest 48.859371 1018.407532 1000.000000"
$ns_ at 16.400001 "$node_(1) setdest 233.472519 1723.813110 1000.000000"
$ns_ at 16.400001 "$node_(2) setdest 1009.301208 1050.331543 1000.000000"
$ns_ at 16.400001 "$node_(3) setdest 483.817078 1377.662964 1000.000000"
$ns_ at 16.400001 "$node_(4) setdest 210.974655 1161.615112 1000.000000"
$ns_ at 16.400001 "$node_(5) setdest 349.567566 1276.243896 614.951102"
$ns_ at 16.400001 "$node_(6) setdest 409.366455 1749.148560 1000.000000"
$ns_ at 16.400001 "$node_(7) setdest 562.187927 1843.251831 1000.000000"
$ns_ at 16.400001 "$node_(8) setdest 594.750732 1520.182983 159.569756"
$ns_ at 16.400001 "$node_(9) setdest 648.734131 1287.725220 168.288537"
$ns_ at 16.466668 "$node_(0) setdest 392.282349 1418.407593 1000.000000"
$ns_ at 16.466668 "$node_(1) setdest 223.691711 1324.616699 1000.000000"
$ns_ at 16.466668 "$node_(2) setdest 609.301208 1271.052124 1000.000000"
$ns_ at 16.466668 "$node_(3) setdest 223.817078 1547.863403 1000.000000"
$ns_ at 16.466668 "$node_(4) setdest 390.040527 1293.171509 833.240103"
$ns_ at 16.466668 "$node_(5) setdest 417.567566 1222.941528 324.003937"
$ns_ at 16.466668 "$node_(6) setdest 253.646210 1349.148560 1000.000000"
$ns_ at 16.466668 "$node_(7) setdest 393.095276 1443.251831 1000.000000"
$ns_ at 16.466668 "$node_(8) setdest 338.750732 1394.869263 1000.000000"
$ns_ at 16.466668 "$node_(9) setdest 372.197449 1431.725220 1000.000000"
$ns_ at 16.533334 "$node_(0) setdest 599.705322 1562.407593 946.904934"
$ns_ at 16.533334 "$node_(1) setdest 0.000100 1164.558472 1000.000000"
$ns_ at 16.533334 "$node_(2) setdest 277.301178 1323.772705 1000.000000"
$ns_ at 16.533334 "$node_(3) setdest 151.817078 1418.063843 556.618280"
$ns_ at 16.533334 "$node_(4) setdest 538.132935 893.171509 1000.000000"
$ns_ at 16.533334 "$node_(5) setdest 249.567551 1353.639160 798.194119"
$ns_ at 16.533334 "$node_(6) setdest 141.925964 1193.148560 719.544888"
$ns_ at 16.533334 "$node_(7) setdest 604.002686 1639.251831 1000.000000"
$ns_ at 16.533334 "$node_(8) setdest 622.750732 1437.555542 1000.000000"
$ns_ at 16.533334 "$node_(9) setdest 407.660767 1391.725220 200.463599"
$ns_ at 16.600001 "$node_(0) setdest 279.128326 1190.407593 1000.000000"
$ns_ at 16.600001 "$node_(1) setdest 223.691711 1280.735352 1000.000000"
$ns_ at 16.600001 "$node_(2) setdest 573.301208 1408.493286 1000.000000"
$ns_ at 16.600001 "$node_(3) setdest 183.817078 1508.264160 358.906470"
$ns_ at 16.600001 "$node_(4) setdest 396.181976 1184.164917 1000.000000"
$ns_ at 16.600001 "$node_(5) setdest 221.567551 1660.336792 1000.000000"
$ns_ at 16.600001 "$node_(6) setdest 142.205719 1249.148560 210.002607"
$ns_ at 16.600001 "$node_(7) setdest 282.910034 1251.251831 1000.000000"
$ns_ at 16.600001 "$node_(8) setdest 314.750732 1320.241821 1000.000000"
$ns_ at 16.600001 "$node_(9) setdest 534.032410 1581.991821 856.537812"
$ns_ at 16.666668 "$node_(0) setdest 474.551300 1114.407593 786.303880"
$ns_ at 16.666668 "$node_(1) setdest 183.691711 1404.912231 489.226201"
$ns_ at 16.666668 "$node_(2) setdest 229.301193 1381.213867 1000.000000"
$ns_ at 16.666668 "$node_(3) setdest 83.817070 1634.464600 603.814628"
$ns_ at 16.666668 "$node_(4) setdest 574.231018 1115.158203 716.077042"
$ns_ at 16.666668 "$node_(5) setdest 293.567566 1327.034424 1000.000000"
$ns_ at 16.666668 "$node_(6) setdest 0.000100 979.813660 1000.000000"
$ns_ at 16.666668 "$node_(7) setdest 425.817383 1015.251831 1000.000000"
$ns_ at 16.666668 "$node_(8) setdest 554.750732 1254.928101 932.731942"
$ns_ at 16.666668 "$node_(9) setdest 305.066254 1395.216675 1000.000000"
$ns_ at 16.733334 "$node_(0) setdest 197.974274 1134.407593 1000.000000"
$ns_ at 16.733334 "$node_(1) setdest 0.000100 1233.089111 944.070805"
$ns_ at 16.733334 "$node_(2) setdest 161.301193 1181.934326 789.607274"
$ns_ at 16.733334 "$node_(3) setdest 241.496613 1234.464600 1000.000000"
$ns_ at 16.733334 "$node_(4) setdest 307.103424 1159.183105 1000.000000"
$ns_ at 16.733334 "$node_(5) setdest 329.567566 1473.732056 566.438626"
$ns_ at 16.733334 "$node_(6) setdest 142.205719 1126.998779 1000.000000"
$ns_ at 16.733334 "$node_(7) setdest 352.724762 1059.251831 319.928639"
$ns_ at 16.733334 "$node_(8) setdest 210.750732 1161.614380 1000.000000"
$ns_ at 16.733334 "$node_(9) setdest 260.100098 1080.441406 1000.000000"
$ns_ at 16.800001 "$node_(0) setdest 0.000100 1038.407593 1000.000000"
$ns_ at 16.800001 "$node_(1) setdest 0.000100 1269.265991 455.663829"
$ns_ at 16.800001 "$node_(2) setdest 0.000100 1330.616211 1000.000000"
$ns_ at 16.800001 "$node_(3) setdest 105.168373 1634.464600 1000.000000"
$ns_ at 16.800001 "$node_(4) setdest 431.975830 1307.208008 726.227780"
$ns_ at 16.800001 "$node_(5) setdest 41.567554 1216.429688 1000.000000"
$ns_ at 16.800001 "$node_(6) setdest 34.205711 1010.183899 596.588542"
$ns_ at 16.800001 "$node_(7) setdest 383.632141 987.251831 293.825497"
$ns_ at 16.800001 "$node_(8) setdest 486.750732 1284.300659 1000.000000"
$ns_ at 16.800001 "$node_(9) setdest 159.133942 1137.666260 435.207602"
$ns_ at 16.866668 "$node_(0) setdest 76.820236 1286.407593 1000.000000"
$ns_ at 16.866668 "$node_(1) setdest 63.691704 1253.442871 677.602981"
$ns_ at 16.866668 "$node_(2) setdest 105.301186 1235.298096 1000.000000"
$ns_ at 16.866668 "$node_(3) setdest 52.248867 1234.464600 1000.000000"
$ns_ at 16.866668 "$node_(4) setdest 31.975843 1271.966431 1000.000000"
$ns_ at 16.866668 "$node_(5) setdest 0.000100 1167.127319 801.612126"
$ns_ at 16.866668 "$node_(6) setdest 0.000100 1169.369019 721.364899"
$ns_ at 16.866668 "$node_(7) setdest 2.539505 1295.251831 1000.000000"
$ns_ at 16.866668 "$node_(8) setdest 86.750725 1255.816895 1000.000000"
$ns_ at 16.866668 "$node_(9) setdest 468.312622 737.666260 1000.000000"
$ns_ at 16.933334 "$node_(0) setdest 237.388870 1388.291748 713.118115"
$ns_ at 16.933334 "$node_(1) setdest 179.691711 1209.619751 465.007042"
$ns_ at 16.933334 "$node_(2) setdest 333.301178 1135.980103 932.597589"
$ns_ at 16.933334 "$node_(3) setdest 59.329357 1166.464600 256.378599"
$ns_ at 16.933334 "$node_(4) setdest 3.975844 1308.724854 173.280092"
$ns_ at 16.933334 "$node_(5) setdest 61.567554 1161.824951 855.231126"
$ns_ at 16.933334 "$node_(6) setdest 0.000100 796.554138 1000.000000"
$ns_ at 16.933334 "$node_(7) setdest 0.000100 1355.251831 975.402896"
$ns_ at 16.933334 "$node_(8) setdest 74.750725 1239.333130 76.459039"
$ns_ at 16.933334 "$node_(9) setdest 68.312622 1126.326782 1000.000000"
$ns_ at 17.000001 "$node_(0) setdest 0.000100 1158.175903 1000.000000"
$ns_ at 17.000001 "$node_(1) setdest 507.691711 1189.796631 1000.000000"
$ns_ at 17.000001 "$node_(2) setdest 0.000100 1145.444092 1000.000000"
$ns_ at 17.000001 "$node_(3) setdest 194.409851 1194.464600 517.319786"
$ns_ at 17.000001 "$node_(4) setdest 19.346407 1204.787842 394.002694"
$ns_ at 17.000001 "$node_(5) setdest 93.567558 1104.522583 246.120059"
$ns_ at 17.000001 "$node_(6) setdest 0.000100 1173.502197 1000.000000"
$ns_ at 17.000001 "$node_(7) setdest 68.354248 1163.251831 1000.000000"
$ns_ at 17.000001 "$node_(8) setdest 392.774872 1639.333130 1000.000000"
$ns_ at 17.000001 "$node_(9) setdest 192.312622 1042.987305 560.263910"
$ns_ at 17.066668 "$node_(0) setdest 242.526169 1192.060181 970.486743"
$ns_ at 17.066668 "$node_(1) setdest 203.691711 1217.973511 1000.000000"
$ns_ at 17.066668 "$node_(2) setdest 49.301189 1110.908203 453.869710"
$ns_ at 17.066668 "$node_(3) setdest 261.490326 1210.464600 258.608366"
$ns_ at 17.066668 "$node_(4) setdest 50.716969 1380.850952 670.635131"
$ns_ at 17.066668 "$node_(5) setdest 181.567551 1287.220337 760.450304"
$ns_ at 17.066668 "$node_(6) setdest 0.000100 1134.450317 307.157920"
$ns_ at 17.066668 "$node_(7) setdest 0.000100 1070.117798 989.526850"
$ns_ at 17.066668 "$node_(8) setdest 256.856201 1239.333130 1000.000000"
$ns_ at 17.066668 "$node_(9) setdest 140.312622 923.647827 488.161729"
$ns_ at 17.133334 "$node_(0) setdest 319.604004 792.060120 1000.000000"
$ns_ at 17.133334 "$node_(1) setdest 339.691711 1010.150330 931.378507"
$ns_ at 17.133334 "$node_(2) setdest 221.301193 1136.372314 652.030186"
$ns_ at 17.133334 "$node_(3) setdest 204.570831 1118.464600 405.690859"
$ns_ at 17.133334 "$node_(4) setdest 0.000100 1204.913940 713.770543"
$ns_ at 17.133334 "$node_(5) setdest 0.000100 1485.917969 1000.000000"
$ns_ at 17.133334 "$node_(6) setdest 74.205711 1083.398438 601.291091"
$ns_ at 17.133334 "$node_(7) setdest 60.512997 1139.872070 933.823079"
$ns_ at 17.133334 "$node_(8) setdest 551.272583 1639.333130 1000.000000"
$ns_ at 17.133334 "$node_(9) setdest 0.000100 1316.308350 1000.000000"
$ns_ at 17.200001 "$node_(0) setdest 244.268936 1192.060181 1000.000000"
$ns_ at 17.200001 "$node_(1) setdest 343.691711 1142.327271 495.890439"
$ns_ at 17.200001 "$node_(2) setdest 377.079254 1208.476440 643.710275"
$ns_ at 17.200001 "$node_(3) setdest 339.651306 1142.464600 514.484856"
$ns_ at 17.200001 "$node_(4) setdest 133.458099 1300.977051 685.010455"
$ns_ at 17.200001 "$node_(5) setdest 105.567558 1344.615601 778.252447"
$ns_ at 17.200001 "$node_(6) setdest 82.205711 1060.346436 91.502669"
$ns_ at 17.200001 "$node_(7) setdest 159.563309 1061.626465 473.352474"
$ns_ at 17.200001 "$node_(8) setdest 260.823639 1239.333130 1000.000000"
$ns_ at 17.200001 "$node_(9) setdest 284.312622 1156.968872 1000.000000"
$ns_ at 17.266668 "$node_(0) setdest 396.933868 1096.060181 676.275638"
$ns_ at 17.266668 "$node_(1) setdest 627.691711 1138.504150 1000.000000"
$ns_ at 17.266668 "$node_(2) setdest 264.857330 1280.580566 500.210698"
$ns_ at 17.266668 "$node_(3) setdest 598.731812 1150.464600 972.014872"
$ns_ at 17.266668 "$node_(4) setdest 0.000100 1337.040039 793.962552"
$ns_ at 17.266668 "$node_(5) setdest 0.000100 1539.313232 834.921870"
$ns_ at 17.266668 "$node_(6) setdest 246.205719 1189.294556 782.336786"
$ns_ at 17.266668 "$node_(7) setdest 0.000100 795.380798 1000.000000"
$ns_ at 17.266668 "$node_(8) setdest 330.374695 1299.333130 344.456416"
$ns_ at 17.266668 "$node_(9) setdest 276.312622 897.629395 972.985560"
$ns_ at 17.333334 "$node_(0) setdest 553.598816 1188.060181 681.302912"
$ns_ at 17.333334 "$node_(1) setdest 259.691711 1162.680908 1000.000000"
$ns_ at 17.333334 "$node_(2) setdest 296.635406 1328.684570 216.197851"
$ns_ at 17.333334 "$node_(3) setdest 265.812286 1162.464600 1000.000000"
$ns_ at 17.333334 "$node_(4) setdest 324.828644 1163.402710 1000.000000"
$ns_ at 17.333334 "$node_(5) setdest 326.859161 1139.313232 1000.000000"
$ns_ at 17.333334 "$node_(6) setdest 38.205711 1162.242676 786.569097"
$ns_ at 17.333334 "$node_(7) setdest 247.028824 1087.730713 1000.000000"
$ns_ at 17.333334 "$node_(8) setdest 461.307098 1699.333130 1000.000000"
$ns_ at 17.333334 "$node_(9) setdest 356.312622 1026.289917 568.140820"
$ns_ at 17.400001 "$node_(0) setdest 522.263733 1408.060181 833.326277"
$ns_ at 17.400001 "$node_(1) setdest 187.691711 1486.857788 1000.000000"
$ns_ at 17.400001 "$node_(2) setdest 360.413483 1240.788696 407.239073"
$ns_ at 17.400001 "$node_(3) setdest 120.892792 1406.464600 1000.000000"
$ns_ at 17.400001 "$node_(4) setdest 332.828644 1433.765381 1000.000000"
$ns_ at 17.400001 "$node_(5) setdest 348.150787 1367.313232 858.719914"
$ns_ at 17.400001 "$node_(6) setdest 414.205719 1259.190796 1000.000000"
$ns_ at 17.400001 "$node_(7) setdest 67.444000 912.080627 942.016533"
$ns_ at 17.400001 "$node_(8) setdest 368.664429 1299.333130 1000.000000"
$ns_ at 17.400001 "$node_(9) setdest 352.312622 1262.950439 887.603656"
$ns_ at 17.466668 "$node_(0) setdest 922.263733 1720.619019 1000.000000"
$ns_ at 17.466668 "$node_(1) setdest 0.000100 1723.034668 1000.000000"
$ns_ at 17.466668 "$node_(2) setdest 280.191559 1008.892822 920.174284"
$ns_ at 17.466668 "$node_(3) setdest 331.973297 1378.464600 798.485657"
$ns_ at 17.466668 "$node_(4) setdest 199.089813 1833.765381 1000.000000"
$ns_ at 17.466668 "$node_(5) setdest 225.442413 1655.313232 1000.000000"
$ns_ at 17.466668 "$node_(6) setdest 442.205719 1248.138916 112.883343"
$ns_ at 17.466668 "$node_(7) setdest 264.760132 1312.080566 1000.000000"
$ns_ at 17.466668 "$node_(8) setdest 388.021790 1451.333130 574.603585"
$ns_ at 17.466668 "$node_(9) setdest 284.312622 1055.610962 818.270717"
$ns_ at 17.533334 "$node_(0) setdest 522.263733 1605.997681 1000.000000"
$ns_ at 17.533334 "$node_(1) setdest 235.691711 1590.742920 1000.000000"
$ns_ at 17.533334 "$node_(2) setdest 322.282928 1408.892822 1000.000000"
$ns_ at 17.533334 "$node_(3) setdest 227.053772 1682.464600 1000.000000"
$ns_ at 17.533334 "$node_(4) setdest 337.350983 1649.765381 863.087952"
$ns_ at 17.533334 "$node_(5) setdest 358.734009 1507.313232 746.905936"
$ns_ at 17.533334 "$node_(6) setdest 778.205688 1569.086914 1000.000000"
$ns_ at 17.533334 "$node_(7) setdest 50.076256 1128.080566 1000.000000"
$ns_ at 17.533334 "$node_(8) setdest 575.379089 1419.333130 712.763978"
$ns_ at 17.533334 "$node_(9) setdest 325.083160 1455.610962 1000.000000"
$ns_ at 17.600001 "$node_(0) setdest 922.263733 1813.212036 1000.000000"
$ns_ at 17.600001 "$node_(1) setdest 15.691706 1826.451050 1000.000000"
$ns_ at 17.600001 "$node_(2) setdest 396.374298 1392.892822 284.247279"
$ns_ at 17.600001 "$node_(3) setdest 330.134277 1694.464600 389.162358"
$ns_ at 17.600001 "$node_(4) setdest 423.612122 1861.765381 858.291162"
$ns_ at 17.600001 "$node_(5) setdest 448.025635 1567.313232 403.416918"
$ns_ at 17.600001 "$node_(6) setdest 378.205719 1535.704224 1000.000000"
$ns_ at 17.600001 "$node_(7) setdest 403.129150 1528.080566 1000.000000"
$ns_ at 17.600001 "$node_(8) setdest 518.736450 1435.333130 220.721457"
$ns_ at 17.600001 "$node_(9) setdest 37.853680 1463.610962 1000.000000"
$ns_ at 17.666668 "$node_(0) setdest 522.263733 1737.866455 1000.000000"
$ns_ at 17.666668 "$node_(1) setdest 415.691711 1705.838867 1000.000000"
$ns_ at 17.666668 "$node_(2) setdest 290.465698 1436.892822 430.068432"
$ns_ at 17.666668 "$node_(3) setdest 1.214754 1994.464600 1000.000000"
$ns_ at 17.666668 "$node_(4) setdest 389.873291 1685.765381 672.017406"
$ns_ at 17.666668 "$node_(5) setdest 399.600464 1708.937378 561.278600"
$ns_ at 17.666668 "$node_(6) setdest 298.205719 1458.321411 417.381885"
$ns_ at 17.666668 "$node_(7) setdest 468.182068 1440.080566 410.378873"
$ns_ at 17.666668 "$node_(8) setdest 442.093811 1747.333130 1000.000000"
$ns_ at 17.666668 "$node_(9) setdest 437.853668 1726.105713 1000.000000"
$ns_ at 17.733334 "$node_(0) setdest 894.263733 1834.520874 1000.000000"
$ns_ at 17.733334 "$node_(1) setdest 295.691711 1689.226685 454.291454"
$ns_ at 17.733334 "$node_(2) setdest 176.557068 1716.892822 1000.000000"
$ns_ at 17.733334 "$node_(3) setdest 401.214752 1670.671875 1000.000000"
$ns_ at 17.733334 "$node_(4) setdest 320.134430 1625.765381 344.989968"
$ns_ at 17.733334 "$node_(5) setdest 363.175293 1706.561523 136.884635"
$ns_ at 17.733334 "$node_(6) setdest 334.205719 1588.938599 508.077938"
$ns_ at 17.733334 "$node_(7) setdest 609.234985 1420.080566 534.239131"
$ns_ at 17.733334 "$node_(8) setdest 721.451111 1999.999900 1000.000000"
$ns_ at 17.733334 "$node_(9) setdest 653.853699 1936.600464 1000.000000"
$ns_ at 17.800001 "$node_(0) setdest 518.263733 1759.175293 1000.000000"
$ns_ at 17.800001 "$node_(1) setdest 515.691711 1916.614502 1000.000000"
$ns_ at 17.800001 "$node_(2) setdest 298.648438 1884.892822 778.793809"
$ns_ at 17.800001 "$node_(3) setdest 633.214783 1814.879272 1000.000000"
$ns_ at 17.800001 "$node_(4) setdest 610.395569 1825.765381 1000.000000"
$ns_ at 17.800001 "$node_(5) setdest 486.750122 1840.185669 682.522109"
$ns_ at 17.800001 "$node_(6) setdest 606.205688 1775.555908 1000.000000"
$ns_ at 17.800001 "$node_(7) setdest 574.287842 1808.080566 1000.000000"
$ns_ at 17.800001 "$node_(8) setdest 548.808472 1727.333130 1000.000000"
$ns_ at 17.800001 "$node_(9) setdest 1005.044250 1999.999900 1000.000000"
$ns_ at 17.866668 "$node_(0) setdest 411.445892 1663.258423 538.358088"
$ns_ at 17.866668 "$node_(1) setdest 411.528748 1999.999900 1000.000000"
$ns_ at 17.866668 "$node_(2) setdest 524.739807 1999.999900 1000.000000"
$ns_ at 17.866668 "$node_(3) setdest 1005.214783 1999.999900 1000.000000"
$ns_ at 17.866668 "$node_(4) setdest 884.656738 1999.999900 1000.000000"
$ns_ at 17.866668 "$node_(5) setdest 422.324951 1999.999900 1000.000000"
$ns_ at 17.866668 "$node_(6) setdest 750.205688 1999.999900 1000.000000"
$ns_ at 17.866668 "$node_(7) setdest 719.340759 1999.999900 1000.000000"
$ns_ at 17.866668 "$node_(8) setdest 712.165833 1999.999900 1000.000000"
$ns_ at 17.866668 "$node_(9) setdest 608.234802 1940.600464 1000.000000"
$ns_ at 17.933334 "$node_(0) setdest 639.239685 1999.999900 1000.000000"
$ns_ at 17.933334 "$node_(1) setdest 625.751038 1999.999900 904.674864"
$ns_ at 17.933334 "$node_(2) setdest 230.831192 1999.999900 1000.000000"
$ns_ at 17.933334 "$node_(3) setdest 757.214783 1999.999900 934.419831"
$ns_ at 17.933334 "$node_(4) setdest 662.917908 1999.999900 833.682475"
$ns_ at 17.933334 "$node_(5) setdest 822.324951 1999.999900 1000.000000"
$ns_ at 17.933334 "$node_(6) setdest 1094.205688 1880.790283 1000.000000"
$ns_ at 17.933334 "$node_(7) setdest 1004.393677 1988.080566 1000.000000"
$ns_ at 17.933334 "$node_(8) setdest 851.523132 1827.333130 1000.000000"
$ns_ at 17.933334 "$node_(9) setdest 587.425354 1940.600464 78.035427"
$ns_ at 18.000001 "$node_(0) setdest 673.656799 1663.258423 1000.000000"
$ns_ at 18.000001 "$node_(1) setdest 575.973389 1978.724976 871.273625"
$ns_ at 18.000001 "$node_(2) setdest 630.831177 1999.999900 1000.000000"
$ns_ at 18.000001 "$node_(3) setdest 1157.214722 1999.999900 1000.000000"
$ns_ at 18.000001 "$node_(4) setdest 805.179077 1999.999900 563.027715"
$ns_ at 18.000001 "$node_(5) setdest 766.324951 1982.687866 1000.000000"
$ns_ at 18.000001 "$node_(6) setdest 834.205688 1923.407593 988.010965"
$ns_ at 18.000001 "$node_(7) setdest 1081.446533 1999.999900 959.539440"
$ns_ at 18.000001 "$node_(8) setdest 1054.880493 1999.999900 1000.000000"
$ns_ at 18.000001 "$node_(9) setdest 838.615906 1976.600464 951.589287"
$ns_ at 18.066668 "$node_(0) setdest 980.073914 1999.999900 1000.000000"
$ns_ at 18.066668 "$node_(1) setdest 975.973389 1975.935181 1000.000000"
$ns_ at 18.066668 "$node_(2) setdest 638.831177 1841.383423 734.692631"
$ns_ at 18.066668 "$node_(3) setdest 1245.214722 1999.999900 339.789058"
$ns_ at 18.066668 "$node_(4) setdest 787.440247 1999.999900 366.094217"
$ns_ at 18.066668 "$node_(5) setdest 946.324951 1999.999900 719.513016"
$ns_ at 18.066668 "$node_(6) setdest 1038.205688 1878.024780 783.701493"
$ns_ at 18.066668 "$node_(7) setdest 798.499451 1999.999900 1000.000000"
$ns_ at 18.066668 "$node_(8) setdest 890.237854 1871.333130 925.901880"
$ns_ at 18.066668 "$node_(9) setdest 977.806458 1999.999900 617.533232"
$ns_ at 18.133334 "$node_(0) setdest 1380.073853 1984.042603 1000.000000"
$ns_ at 18.133334 "$node_(1) setdest 1375.973389 1816.301514 1000.000000"
$ns_ at 18.133334 "$node_(2) setdest 1038.831177 1981.427490 1000.000000"
$ns_ at 18.133334 "$node_(3) setdest 981.214783 1936.072632 1000.000000"
$ns_ at 18.133334 "$node_(4) setdest 833.701355 1999.999900 239.415981"
$ns_ at 18.133334 "$node_(5) setdest 1002.324951 1951.566040 421.839673"
$ns_ at 18.133334 "$node_(6) setdest 1054.205688 1788.642090 340.512897"
$ns_ at 18.133334 "$node_(7) setdest 667.552368 1999.999900 493.109124"
$ns_ at 18.133334 "$node_(8) setdest 529.595154 1811.333130 1000.000000"
$ns_ at 18.133334 "$node_(9) setdest 984.997070 1999.999900 30.856120"
$ns_ at 18.200001 "$node_(0) setdest 980.073914 1999.999900 1000.000000"
$ns_ at 18.200001 "$node_(1) setdest 975.973389 1894.327026 1000.000000"
$ns_ at 18.200001 "$node_(2) setdest 1254.831177 1999.999900 880.476391"
$ns_ at 18.200001 "$node_(3) setdest 989.214783 1849.665527 325.412447"
$ns_ at 18.200001 "$node_(4) setdest 907.962524 1981.765381 744.077071"
$ns_ at 18.200001 "$node_(5) setdest 1054.324951 1898.005127 279.941239"
$ns_ at 18.200001 "$node_(6) setdest 1262.205688 1487.259277 1000.000000"
$ns_ at 18.200001 "$node_(7) setdest 1067.552368 1875.248535 1000.000000"
$ns_ at 18.200001 "$node_(8) setdest 929.595154 1861.385986 1000.000000"
$ns_ at 18.200001 "$node_(9) setdest 970.968689 1999.999900 1000.000000"
$ns_ at 18.266668 "$node_(0) setdest 1035.336060 1999.999900 1000.000000"
$ns_ at 18.266668 "$node_(1) setdest 1095.973389 1852.352539 476.734833"
$ns_ at 18.266668 "$node_(2) setdest 1058.831177 1877.515381 1000.000000"
$ns_ at 18.266668 "$node_(3) setdest 1177.214722 1771.258423 763.856180"
$ns_ at 18.266668 "$node_(4) setdest 662.264771 1999.999900 1000.000000"
$ns_ at 18.266668 "$node_(5) setdest 1034.324951 1999.999900 942.136067"
$ns_ at 18.266668 "$node_(6) setdest 1093.127563 1887.259277 1000.000000"
$ns_ at 18.266668 "$node_(7) setdest 1043.552368 1999.999900 618.463350"
$ns_ at 18.266668 "$node_(8) setdest 529.595154 1696.620117 1000.000000"
$ns_ at 18.266668 "$node_(9) setdest 1046.658813 1999.999900 1000.000000"
$ns_ at 18.333334 "$node_(0) setdest 921.387817 1999.999900 1000.000000"
$ns_ at 18.333334 "$node_(1) setdest 1099.973389 1814.378052 143.192146"
$ns_ at 18.333334 "$node_(2) setdest 922.831177 1813.559448 563.578462"
$ns_ at 18.333334 "$node_(3) setdest 953.214783 1952.851318 1000.000000"
$ns_ at 18.333334 "$node_(4) setdest 876.462097 1999.999900 1000.000000"
$ns_ at 18.333334 "$node_(5) setdest 1250.324951 1999.999900 1000.000000"
$ns_ at 18.333334 "$node_(6) setdest 1488.049561 1527.259277 1000.000000"
$ns_ at 18.333334 "$node_(7) setdest 1283.552368 1999.999900 909.611044"
$ns_ at 18.333334 "$node_(8) setdest 929.595154 1999.999900 1000.000000"
$ns_ at 18.333334 "$node_(9) setdest 894.348999 1999.999900 571.198853"
$ns_ at 18.400001 "$node_(0) setdest 1211.439575 1979.289307 1000.000000"
$ns_ at 18.400001 "$node_(1) setdest 1043.973389 1776.403564 253.730150"
$ns_ at 18.400001 "$node_(2) setdest 1062.831177 1977.603394 808.735214"
$ns_ at 18.400001 "$node_(3) setdest 1237.214722 1558.444214 1000.000000"
$ns_ at 18.400001 "$node_(4) setdest 894.659485 1999.999900 69.704179"
$ns_ at 18.400001 "$node_(5) setdest 1168.095215 1999.999900 1000.000000"
$ns_ at 18.400001 "$node_(6) setdest 1134.202393 1927.259277 1000.000000"
$ns_ at 18.400001 "$node_(7) setdest 1255.552368 1999.999900 115.501271"
$ns_ at 18.400001 "$node_(8) setdest 1029.595215 1888.949219 632.531515"
$ns_ at 18.400001 "$node_(9) setdest 886.039185 1999.999900 457.573533"
$ns_ at 18.466668 "$node_(0) setdest 1087.742554 1891.715088 568.347043"
$ns_ at 18.466668 "$node_(1) setdest 1059.973389 1646.429077 491.083463"
$ns_ at 18.466668 "$node_(2) setdest 754.831177 1885.647461 1000.000000"
$ns_ at 18.466668 "$node_(3) setdest 1083.365845 1958.444214 1000.000000"
$ns_ at 18.466668 "$node_(4) setdest 948.856812 1999.999900 216.910918"
$ns_ at 18.466668 "$node_(5) setdest 1153.865479 1999.999900 587.428635"
$ns_ at 18.466668 "$node_(6) setdest 1240.355225 1751.259277 770.754278"
$ns_ at 18.466668 "$node_(7) setdest 1447.552368 1999.999900 790.727765"
$ns_ at 18.466668 "$node_(8) setdest 1013.595154 1829.113892 232.266056"
$ns_ at 18.466668 "$node_(9) setdest 1145.729370 1851.578491 1000.000000"
$ns_ at 18.533334 "$node_(0) setdest 1260.045532 1752.140747 831.530756"
$ns_ at 18.533334 "$node_(1) setdest 1139.973389 1728.454712 429.668890"
$ns_ at 18.533334 "$node_(2) setdest 1154.831177 1881.769043 1000.000000"
$ns_ at 18.533334 "$node_(3) setdest 1177.517090 1999.999900 463.310256"
$ns_ at 18.533334 "$node_(4) setdest 1107.054199 1866.623047 933.526048"
$ns_ at 18.533334 "$node_(5) setdest 1094.598999 1850.883179 1000.000000"
$ns_ at 18.533334 "$node_(6) setdest 1070.508179 1903.259277 854.736913"
$ns_ at 18.533334 "$node_(7) setdest 1047.552368 1852.986938 1000.000000"
$ns_ at 18.533334 "$node_(8) setdest 613.595154 1779.228149 1000.000000"
$ns_ at 18.533334 "$node_(9) setdest 1065.419556 1933.314697 429.706027"
$ns_ at 18.600001 "$node_(0) setdest 1599.144897 1457.991943 1000.000000"
$ns_ at 18.600001 "$node_(1) setdest 1214.900757 1328.454712 1000.000000"
$ns_ at 18.600001 "$node_(2) setdest 1278.831177 1673.890625 907.697020"
$ns_ at 18.600001 "$node_(3) setdest 1419.668213 1999.999900 1000.000000"
$ns_ at 18.600001 "$node_(4) setdest 1141.251465 1790.412598 313.242514"
$ns_ at 18.600001 "$node_(5) setdest 1079.332520 1818.883179 132.956679"
$ns_ at 18.600001 "$node_(6) setdest 1008.661011 1999.259277 428.240668"
$ns_ at 18.600001 "$node_(7) setdest 1011.552368 1754.053589 394.798716"
$ns_ at 18.600001 "$node_(8) setdest 1013.595154 1786.890381 1000.000000"
$ns_ at 18.600001 "$node_(9) setdest 1058.608276 1793.754150 523.974925"
$ns_ at 18.666668 "$node_(0) setdest 1322.922119 1678.622437 1000.000000"
$ns_ at 18.666668 "$node_(1) setdest 1284.135254 1728.454712 1000.000000"
$ns_ at 18.666668 "$node_(2) setdest 1238.831177 1718.012085 223.328250"
$ns_ at 18.666668 "$node_(3) setdest 1343.324341 1999.999900 1000.000000"
$ns_ at 18.666668 "$node_(4) setdest 1247.448853 1850.202271 457.018523"
$ns_ at 18.666668 "$node_(5) setdest 1312.066040 1674.883179 1000.000000"
$ns_ at 18.666668 "$node_(6) setdest 1326.813843 1663.259277 1000.000000"
$ns_ at 18.666668 "$node_(7) setdest 1323.552368 1703.120117 1000.000000"
$ns_ at 18.666668 "$node_(8) setdest 1233.595215 1690.552734 900.632296"
$ns_ at 18.666668 "$node_(9) setdest 963.796936 1882.193726 486.210969"
$ns_ at 18.733334 "$node_(0) setdest 1574.699341 1607.252930 981.364123"
$ns_ at 18.733334 "$node_(1) setdest 1349.369873 1824.454712 435.251347"
$ns_ at 18.733334 "$node_(2) setdest 1182.831177 1826.133667 456.611972"
$ns_ at 18.733334 "$node_(3) setdest 1342.980591 1754.444214 1000.000000"
$ns_ at 18.733334 "$node_(4) setdest 1233.646240 1741.991943 409.076450"
$ns_ at 18.733334 "$node_(5) setdest 1312.799683 1466.883179 780.004823"
$ns_ at 18.733334 "$node_(6) setdest 1480.966675 1539.259277 741.885070"
$ns_ at 18.733334 "$node_(7) setdest 1359.552368 1736.186768 183.305702"
$ns_ at 18.733334 "$node_(8) setdest 1093.595215 1586.215088 654.762692"
$ns_ at 18.733334 "$node_(9) setdest 1363.796875 1719.263916 1000.000000"
$ns_ at 18.800001 "$node_(0) setdest 1446.476685 1667.883423 531.880389"
$ns_ at 18.800001 "$node_(1) setdest 1410.604370 1960.454712 559.311704"
$ns_ at 18.800001 "$node_(2) setdest 1422.831177 1566.255249 1000.000000"
$ns_ at 18.800001 "$node_(3) setdest 1298.636841 1950.444214 753.576125"
$ns_ at 18.800001 "$node_(4) setdest 971.843567 1797.781494 1000.000000"
$ns_ at 18.800001 "$node_(5) setdest 1297.533203 1534.883179 261.347423"
$ns_ at 18.800001 "$node_(6) setdest 1547.119629 1411.259277 540.315142"
$ns_ at 18.800001 "$node_(7) setdest 1247.552368 1833.253418 555.784063"
$ns_ at 18.800001 "$node_(8) setdest 1358.420166 1604.017334 995.334840"
$ns_ at 18.800001 "$node_(9) setdest 1407.796875 1992.334106 1000.000000"
$ns_ at 18.866668 "$node_(0) setdest 1810.253906 1920.514038 1000.000000"
$ns_ at 18.866668 "$node_(1) setdest 1362.192139 1809.632202 594.007213"
$ns_ at 18.866668 "$node_(2) setdest 1510.831177 1830.376831 1000.000000"
$ns_ at 18.866668 "$node_(3) setdest 1302.292969 1818.444214 495.189832"
$ns_ at 18.866668 "$node_(4) setdest 1371.843628 1779.663574 1000.000000"
$ns_ at 18.866668 "$node_(5) setdest 1298.266724 1734.883179 750.004996"
$ns_ at 18.866668 "$node_(6) setdest 1379.249023 1732.097778 1000.000000"
$ns_ at 18.866668 "$node_(7) setdest 895.552368 1999.999900 1000.000000"
$ns_ at 18.866668 "$node_(8) setdest 1295.245117 1497.819458 463.380351"
$ns_ at 18.866668 "$node_(9) setdest 1343.796875 1999.999900 364.257097"
$ns_ at 18.933334 "$node_(0) setdest 1410.253906 1887.167114 1000.000000"
$ns_ at 18.933334 "$node_(1) setdest 1281.779907 1998.809692 770.843885"
$ns_ at 18.933334 "$node_(2) setdest 1722.831177 1974.498413 961.310298"
$ns_ at 18.933334 "$node_(3) setdest 1125.949219 1978.444214 892.918349"
$ns_ at 18.933334 "$node_(4) setdest 1287.843628 1857.545776 429.561402"
$ns_ at 18.933334 "$node_(5) setdest 1387.000366 1774.883179 364.997702"
$ns_ at 18.933334 "$node_(6) setdest 1443.378540 1564.936401 671.402057"
$ns_ at 18.933334 "$node_(7) setdest 1295.552368 1929.493652 1000.000000"
$ns_ at 18.933334 "$node_(8) setdest 1240.070068 1887.621704 1000.000000"
$ns_ at 18.933334 "$node_(9) setdest 1379.796875 1886.474487 684.432757"
$ns_ at 19.000001 "$node_(0) setdest 1810.253906 1999.999900 1000.000000"
$ns_ at 19.000001 "$node_(1) setdest 1350.642944 1924.506958 379.899482"
$ns_ at 19.000001 "$node_(2) setdest 1322.831177 1892.704346 1000.000000"
$ns_ at 19.000001 "$node_(3) setdest 1401.605347 1902.444214 1000.000000"
$ns_ at 19.000001 "$node_(4) setdest 1011.843567 1731.427856 1000.000000"
$ns_ at 19.000001 "$node_(5) setdest 1574.489624 1374.883179 1000.000000"
$ns_ at 19.000001 "$node_(6) setdest 1355.423828 1943.687378 1000.000000"
$ns_ at 19.000001 "$node_(7) setdest 1047.552368 1999.999900 1000.000000"
$ns_ at 19.000001 "$node_(8) setdest 840.070068 1798.224854 1000.000000"
$ns_ at 19.000001 "$node_(9) setdest 1443.796875 1831.544678 316.276057"
$ns_ at 19.066668 "$node_(0) setdest 1410.253906 1867.440918 1000.000000"
$ns_ at 19.066668 "$node_(1) setdest 1179.505981 1890.204346 654.528374"
$ns_ at 19.066668 "$node_(2) setdest 1262.831177 1774.910278 495.730164"
$ns_ at 19.066668 "$node_(3) setdest 1409.261597 1922.444214 80.307644"
$ns_ at 19.066668 "$node_(4) setdest 1335.843628 1601.309937 1000.000000"
$ns_ at 19.066668 "$node_(5) setdest 1306.404541 1774.883179 1000.000000"
$ns_ at 19.066668 "$node_(6) setdest 1483.469238 1999.999900 1000.000000"
$ns_ at 19.066668 "$node_(7) setdest 1323.552368 1771.841064 1000.000000"
$ns_ at 19.066668 "$node_(8) setdest 1240.070068 1809.372437 1000.000000"
$ns_ at 19.066668 "$node_(9) setdest 1283.796875 1772.614868 639.402146"
$ns_ at 19.133334 "$node_(0) setdest 1810.253906 1999.999900 1000.000000"
$ns_ at 19.133334 "$node_(1) setdest 1032.369019 1999.999900 1000.000000"
$ns_ at 19.133334 "$node_(2) setdest 1166.831177 1985.116333 866.587441"
$ns_ at 19.133334 "$node_(3) setdest 1512.917725 1999.999900 818.226829"
$ns_ at 19.133334 "$node_(4) setdest 1391.843628 1355.192139 946.531227"
$ns_ at 19.133334 "$node_(5) setdest 1426.319336 1762.883179 451.926446"
$ns_ at 19.133334 "$node_(6) setdest 1333.896240 1842.438354 1000.000000"
$ns_ at 19.133334 "$node_(7) setdest 1275.552368 1767.014648 180.907636"
$ns_ at 19.133334 "$node_(8) setdest 1204.070068 1704.519897 415.726926"
$ns_ at 19.133334 "$node_(9) setdest 1311.796875 1773.685059 105.076663"
$ns_ at 19.200001 "$node_(0) setdest 1410.253906 1883.100220 1000.000000"
$ns_ at 19.200001 "$node_(1) setdest 1421.232056 1801.599121 1000.000000"
$ns_ at 19.200001 "$node_(2) setdest 1234.831177 1955.322266 278.402724"
$ns_ at 19.200001 "$node_(3) setdest 1344.573975 1810.444214 1000.000000"
$ns_ at 19.200001 "$node_(4) setdest 1372.327393 1755.192139 1000.000000"
$ns_ at 19.200001 "$node_(5) setdest 1733.420288 1452.372437 1000.000000"
$ns_ at 19.200001 "$node_(6) setdest 1436.184448 1999.999900 911.761160"
$ns_ at 19.200001 "$node_(7) setdest 1336.274536 1848.430298 380.873174"
$ns_ at 19.200001 "$node_(8) setdest 948.070068 1571.667358 1000.000000"
$ns_ at 19.200001 "$node_(9) setdest 1366.295532 1850.955200 354.583808"
$ns_ at 19.266668 "$node_(0) setdest 1798.253906 1999.999900 1000.000000"
$ns_ at 19.266668 "$node_(1) setdest 1778.094971 1551.296509 1000.000000"
$ns_ at 19.266668 "$node_(2) setdest 1038.831177 1999.999900 850.671285"
$ns_ at 19.266668 "$node_(3) setdest 1352.230225 1734.444214 286.442513"
$ns_ at 19.266668 "$node_(4) setdest 1436.811157 1519.192139 917.441549"
$ns_ at 19.266668 "$node_(5) setdest 1369.946411 1741.770020 1000.000000"
$ns_ at 19.266668 "$node_(6) setdest 1392.526123 1849.849976 815.948367"
$ns_ at 19.266668 "$node_(7) setdest 1292.996704 1929.845947 345.762960"
$ns_ at 19.266668 "$node_(8) setdest 1348.070068 1725.818604 1000.000000"
$ns_ at 19.266668 "$node_(9) setdest 1372.794189 1999.999900 785.141275"
$ns_ at 19.333334 "$node_(0) setdest 1402.253906 1794.668457 1000.000000"
$ns_ at 19.333334 "$node_(1) setdest 1402.958008 1868.993774 1000.000000"
$ns_ at 19.333334 "$node_(2) setdest 1438.831177 1845.882080 1000.000000"
$ns_ at 19.333334 "$node_(3) setdest 1243.886353 1410.444214 1000.000000"
$ns_ at 19.333334 "$node_(4) setdest 1477.294922 1871.192139 1000.000000"
$ns_ at 19.333334 "$node_(5) setdest 1292.979126 1341.770020 1000.000000"
$ns_ at 19.333334 "$node_(6) setdest 1352.168091 1852.067749 151.570951"
$ns_ at 19.333334 "$node_(7) setdest 1421.718872 1671.261597 1000.000000"
$ns_ at 19.333334 "$node_(8) setdest 1044.070068 1391.969849 1000.000000"
$ns_ at 19.333334 "$node_(9) setdest 1455.292847 1969.495605 459.859376"
$ns_ at 19.400001 "$node_(0) setdest 1170.327637 1394.668457 1000.000000"
$ns_ at 19.400001 "$node_(1) setdest 1139.821045 1634.691162 1000.000000"
$ns_ at 19.400001 "$node_(2) setdest 1194.831177 1602.236084 1000.000000"
$ns_ at 19.400001 "$node_(3) setdest 1351.542603 1446.444214 425.684745"
$ns_ at 19.400001 "$node_(4) setdest 1341.778809 1615.192139 1000.000000"
$ns_ at 19.400001 "$node_(5) setdest 1292.089478 1628.722168 1000.000000"
$ns_ at 19.400001 "$node_(6) setdest 1309.827271 1658.789917 741.979541"
$ns_ at 19.400001 "$node_(7) setdest 1579.289673 1704.022095 603.526408"
$ns_ at 19.400001 "$node_(8) setdest 1344.070068 1638.120972 1000.000000"
$ns_ at 19.400001 "$node_(9) setdest 1272.521973 1569.495605 1000.000000"
$ns_ at 19.466668 "$node_(0) setdest 994.401367 1302.668457 744.486427"
$ns_ at 19.466668 "$node_(1) setdest 776.684082 1560.388550 1000.000000"
$ns_ at 19.466668 "$node_(2) setdest 794.831177 1568.511230 1000.000000"
$ns_ at 19.466668 "$node_(3) setdest 1368.936401 1046.444214 1000.000000"
$ns_ at 19.466668 "$node_(4) setdest 1398.262573 1455.192139 636.290155"
$ns_ at 19.466668 "$node_(5) setdest 1195.199829 1451.674438 756.845301"
$ns_ at 19.466668 "$node_(6) setdest 1247.486450 1585.512207 360.780411"
$ns_ at 19.466668 "$node_(7) setdest 1329.335938 1539.813232 1000.000000"
$ns_ at 19.466668 "$node_(8) setdest 1436.070068 1788.272217 660.355648"
$ns_ at 19.466668 "$node_(9) setdest 1277.751099 1649.495605 300.640167"
$ns_ at 19.533334 "$node_(0) setdest 1090.475098 1422.668457 576.453923"
$ns_ at 19.533334 "$node_(1) setdest 1053.322021 1431.471802 1000.000000"
$ns_ at 19.533334 "$node_(2) setdest 1134.831177 1390.786255 1000.000000"
$ns_ at 19.533334 "$node_(3) setdest 1059.115845 1446.444214 1000.000000"
$ns_ at 19.533334 "$node_(4) setdest 1170.746338 1283.192139 1000.000000"
$ns_ at 19.533334 "$node_(5) setdest 850.310120 1122.626587 1000.000000"
$ns_ at 19.533334 "$node_(6) setdest 1647.486450 1952.681274 1000.000000"
$ns_ at 19.533334 "$node_(7) setdest 1111.382202 1295.604370 1000.000000"
$ns_ at 19.533334 "$node_(8) setdest 1172.070068 1482.423462 1000.000000"
$ns_ at 19.533334 "$node_(9) setdest 1042.980225 1369.495605 1000.000000"
$ns_ at 19.600001 "$node_(0) setdest 962.548767 1582.668457 768.202303"
$ns_ at 19.600001 "$node_(1) setdest 689.960022 1666.555054 1000.000000"
$ns_ at 19.600001 "$node_(2) setdest 1162.831177 1433.061401 190.150799"
$ns_ at 19.600001 "$node_(3) setdest 753.295349 1662.444214 1000.000000"
$ns_ at 19.600001 "$node_(4) setdest 1223.230103 1079.192139 789.911858"
$ns_ at 19.600001 "$node_(5) setdest 1145.420410 1401.578735 1000.000000"
$ns_ at 19.600001 "$node_(6) setdest 1274.887573 1552.681274 1000.000000"
$ns_ at 19.600001 "$node_(7) setdest 1121.428467 1163.395508 497.212518"
$ns_ at 19.600001 "$node_(8) setdest 1156.070068 1484.574585 60.539836"
$ns_ at 19.600001 "$node_(9) setdest 780.209290 1157.495605 1000.000000"
$ns_ at 19.666668 "$node_(0) setdest 926.622498 1386.668457 747.245196"
$ns_ at 19.666668 "$node_(1) setdest 971.342712 1381.058105 1000.000000"
$ns_ at 19.666668 "$node_(2) setdest 894.831177 1411.336548 1000.000000"
$ns_ at 19.666668 "$node_(3) setdest 971.474854 1370.444214 1000.000000"
$ns_ at 19.666668 "$node_(4) setdest 883.713989 1475.192139 1000.000000"
$ns_ at 19.666668 "$node_(5) setdest 1072.530762 1208.530884 773.812940"
$ns_ at 19.666668 "$node_(6) setdest 1038.288696 1512.681274 899.836074"
$ns_ at 19.666668 "$node_(7) setdest 947.474731 1411.186646 1000.000000"
$ns_ at 19.666668 "$node_(8) setdest 1384.070068 1602.725830 962.981479"
$ns_ at 19.666668 "$node_(9) setdest 961.438416 1465.495605 1000.000000"
$ns_ at 19.733334 "$node_(0) setdest 658.696228 1306.668457 1000.000000"
$ns_ at 19.733334 "$node_(1) setdest 980.725403 1275.561157 397.175110"
$ns_ at 19.733334 "$node_(2) setdest 690.831177 1253.611572 966.985080"
$ns_ at 19.733334 "$node_(3) setdest 917.654358 1242.444214 520.705349"
$ns_ at 19.733334 "$node_(4) setdest 732.197754 1419.192139 605.751712"
$ns_ at 19.733334 "$node_(5) setdest 983.641113 1467.483032 1000.000000"
$ns_ at 19.733334 "$node_(6) setdest 1221.689819 1612.681274 783.345868"
$ns_ at 19.733334 "$node_(7) setdest 957.520935 1294.977783 437.408587"
$ns_ at 19.733334 "$node_(8) setdest 984.070068 1426.786743 1000.000000"
$ns_ at 19.733334 "$node_(9) setdest 922.667480 1429.495605 198.402475"
$ns_ at 19.800001 "$node_(0) setdest 838.210754 1329.576294 678.638442"
$ns_ at 19.800001 "$node_(1) setdest 786.108093 1338.064331 766.529177"
$ns_ at 19.800001 "$node_(2) setdest 690.831177 1275.886719 83.531795"
$ns_ at 19.800001 "$node_(3) setdest 1051.526611 842.444214 1000.000000"
$ns_ at 19.800001 "$node_(4) setdest 516.681580 1619.192139 1000.000000"
$ns_ at 19.800001 "$node_(5) setdest 1198.751465 1626.435181 1000.000000"
$ns_ at 19.800001 "$node_(6) setdest 821.689819 1314.826782 1000.000000"
$ns_ at 19.800001 "$node_(7) setdest 821.493286 1327.593506 524.561950"
$ns_ at 19.800001 "$node_(8) setdest 1384.070068 1609.369995 1000.000000"
$ns_ at 19.800001 "$node_(9) setdest 1035.896606 1513.495605 528.694583"
$ns_ at 19.866668 "$node_(0) setdest 1145.725342 1448.484009 1000.000000"
$ns_ at 19.866668 "$node_(1) setdest 979.490784 1476.567383 891.995269"
$ns_ at 19.866668 "$node_(2) setdest 686.831177 1306.161865 114.518417"
$ns_ at 19.866668 "$node_(3) setdest 955.795105 1242.444214 1000.000000"
$ns_ at 19.866668 "$node_(4) setdest 916.681580 1385.533325 1000.000000"
$ns_ at 19.866668 "$node_(5) setdest 901.861755 1649.387451 1000.000000"
$ns_ at 19.866668 "$node_(6) setdest 881.689819 1424.972412 470.353121"
$ns_ at 19.866668 "$node_(7) setdest 793.465637 1340.209106 115.260044"
$ns_ at 19.866668 "$node_(8) setdest 984.070068 1419.937744 1000.000000"
$ns_ at 19.866668 "$node_(9) setdest 1013.125732 1493.495605 113.651148"
$ns_ at 19.933334 "$node_(0) setdest 1173.239868 1431.391846 121.467069"
$ns_ at 19.933334 "$node_(1) setdest 1100.873535 1579.070557 595.774238"
$ns_ at 19.933334 "$node_(2) setdest 770.831177 1352.437012 359.636317"
$ns_ at 19.933334 "$node_(3) setdest 1199.860352 842.444214 1000.000000"
$ns_ at 19.933334 "$node_(4) setdest 732.681580 1147.874512 1000.000000"
$ns_ at 19.933334 "$node_(5) setdest 772.972107 1500.339600 738.928890"
$ns_ at 19.933334 "$node_(6) setdest 1053.689819 1455.117920 654.831471"
$ns_ at 19.933334 "$node_(7) setdest 943.439026 1460.031860 719.858456"
$ns_ at 19.933334 "$node_(8) setdest 872.070068 1210.505371 890.622321"
$ns_ at 19.933334 "$node_(9) setdest 914.354797 1405.495605 496.074059"

$ns_ at 0.01 "$node_(0) color blue"
$ns_ at 0.01 "$node_(1) color blue"
$ns_ at 0.01 "$node_(2) color blue"
$ns_ at 0.01 "$node_(3) color blue"
$ns_ at 0.01 "$node_(4) color blue"
$ns_ at 0.01 "$node_(5) color blue"
$ns_ at 0.01 "$node_(6) color blue"
$ns_ at 0.01 "$node_(7) color blue"
$ns_ at 0.01 "$node_(8) color blue"
$ns_ at 0.01 "$node_(9) color blue"

###############################################################################
# Attach the sensor agent to the sensor node, and build a conduit thru which
# recieved PHENOM packets will reach the sensor agent's recv routine.

# attach a Sensor Agent (i.e. sensor agent) to sensor node
for {set i 10} {$i < 410 } {incr i} {
  set sensor_($i) [new Agent/SensorAgent]
  $ns_ attach-agent $node_($i) $sensor_($i)
  # specify the sensor agent as the up-target for the sensor node's link layer
  # configured on the PHENOM interface, so that the sensor agent handles the
  # received PHENOM packets instead of any other agent attached to the node.
  #
  [$node_($i) set ll_(1)] up-target $sensor_($i)
}

###############################################################################
# setup UDP connections to data collection point, and attach sensor apps
set sink_0 [new Agent/UDP/MIUN_WSN]
$ns_ attach-agent $node_(410) $sink_0
$ns_ set_sinknode $node_(410)
for {set i 10} {$i < 410} {incr i} {
  set src0_($i) [new Agent/UDP/MIUN_WSN]
  $ns_ attach-agent $node_($i) $src0_($i)
  $ns_ connect $src0_($i) $sink_0
  set app0_($i) [new Application/SensorApp]
  $app0_($i) attach-agent $src0_($i)
  $ns_ at 5.0 "$app0_($i) start $sensor_($i)"
}

#set the IDS state.
$ns_ at 5.0 "$ns_ set_ids_state training"
$ns_ at 20.0 "$ns_ set_ids_state detecting"

#Tell nodes when the simulation ends
#
for {set i 0} {$i < $val(nn) } {incr i} {
  $ns_ at 30.0 "$node_($i) reset";
}
$ns_ at 30.1 "stop"
$ns_ at 30.1 "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd namtrace idstracefd
    $ns_ flush-trace
    close $tracefd
    close $namtrace
	close $idstracefd
}

#Begin command line parsing
puts "Starting Simulation..."
$ns_ run
