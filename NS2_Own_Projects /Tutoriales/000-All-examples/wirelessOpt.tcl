ns-random 0; # no randomization, fixed seed if 0
# note -- sometimes we get "Event UID not valid !" for 'ns-random 10'
# this is a known bug, no fix is known so far
# seen in the default mac-802_11 code

set traceFile "out.tr"
#set traceFile "/dev/null"
set stopTime 152
set preStopTime $stopTime-1

set channelBandwidth 2.0e6
Mac/802_11 set basicRate_       $channelBandwidth
Mac/802_11 set dataRate_        $channelBandwidth
Mac/802_11 set ether_hdr_len_   52
Mac/802_11 set ether_rts_len_   26
Mac/802_11 set ether_cts_len_   20
Mac/802_11 set ether_ack_len_   20
Mac/802_11 set payloadSize_     200
Mac/802_11 set startStatTime_ 100;
Mac/802_11 set endStatTime_ 150;
Mac/802_11 set sinknode_ $sinknode
Mac/802_11 set maxSenders_ $numsources

Queue/DropTail/PriQueue set Prefer_Routing_Protocols    1

Antenna/OmniAntenna set X_ 0
Antenna/OmniAntenna set Y_ 0
Antenna/OmniAntenna set Z_ 1.5
Antenna/OmniAntenna set Gt_ 1.0
Antenna/OmniAntenna set Gr_ 1.0

Phy/WirelessPhy set CPThresh_ 10.0

#below gives 60m tx range, 90m cs thresh
Phy/WirelessPhy set CSThresh_ 2.17468e-08
Phy/WirelessPhy set RXThresh_ 5.34106e-08

Phy/WirelessPhy set Rb_ 2*1e6
Phy/WirelessPhy set Pt_ 0.2818
Phy/WirelessPhy set freq_ 914e+6 
Phy/WirelessPhy set L_ 1.0

set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(rp)             DSDV                       ;# routing protocol
