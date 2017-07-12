   #xxxxxxxxxxxxxxxxx#
   # PENGATURAN AWAL #
   #xxxxxxxxxxxxxxxxx#

 #Membuat sebuah objek simulasi
 set os [new Simulator]

 #Mengatur routing hierarchical
 $os node-config -addressType hierarchical

 #FHMIPv6
 Node set useFhmip_ true

 AddrParams set domain_num_ 5 		;# jumlah domain
 lappend cluster_num 2 1 1 2 2 	;# jumlah cluster pada masing-masing domain
 AddrParams set cluster_num_ $cluster_num
 lappend eilastlevel 1 1 2 1 1 1 1 1  ;# jumlah titik pada masing-masing cluster
 AddrParams set nodes_num_ $eilastlevel	;# pendefinisian titik

 set tf [open finale.tr w]
 $os trace-all $tf

 set nf [open finale.nam w]
 $os namtrace-all $nf

 set topo [new Topography]
 $topo load_flatgrid 800 800
 set god_ [create-god 1]


   #xxxxxxxxxxxxxxxxxx#
   # NODE SETUP #
   #xxxxxxxxxxxxxxxxxx#

 # titik yang terhubung dengan kabel: CH, MAP, N1, N2, N3

 #CH - 0
 set CN [$os node 0.0.0]

 #MAP - 1
 set MAP [$os node 2.0.0]

 #N1 - 2
 set N1 [$os node 0.1.0]

 #N2 - 3
 set N2 [$os node 3.0.0]

 #N3 - 4
 set N3 [$os node 4.0.0]

 #N4 - 5
 set N4 [$os node 5.0.0]

 #N5 - 6
# set N5 [$os node 6.0.0]

 # titik NOAH (dengan kabel + tanpa kabel): HA, PAR, NAR
 # MD (Mobile Device)

 Phy/WirelessPhy set CSThresh_ 1.20174e-07
 Phy/WirelessPhy set RXThresh_ 9.49522e-08
 Phy/WirelessPhy set bandwidth_ 2e6
 Phy/WirelessPhy set Pt_ 0.28183815
 Phy/WirelessPhy set freq_ 914e+06
 Phy/WirelessPhy set L_ 1.0  

 set chan_ [new Channel/WirelessChannel]
 $os node-config -mobileIP ON \
                   -adhocRouting NOAH \
                   -llType LL \
                   -macType Mac/802_11 \
                   -ifqType Queue/DropTail/PriQueue \
                   -ifqLen 50 \
                   -antType Antenna/OmniAntenna \
                   -propType Propagation/TwoRayGround \
                   -phyType Phy/WirelessPhy \
                   -channel $chan_ \
           		-topoInstance $topo \
                   -wiredRouting ON \
           		-agentTrace ON \
                   -routerTrace OFF \
                   -macTrace ON


 #HA - 5
 set HA [$os node 1.0.0]
 [$HA set regagent_] priority 3

 #MD - 6
 $os node-config -wiredRouting OFF
 set MD [$os node 1.0.1]
 [$MD set regagent_] set home_agent_ [AddrParams addr2id [$HA node-addr]]
 $os node-config -wiredRouting ON

 #W1 - 7
# set W1 [$os node 3.1.0 2.0.0]
# [$W1 set regagent_] priority 3

 #W2 - 8
# set W2 [$os node 4.1.0 2.0.0]
# [$W2 set regagent_] priority 4

 #W3 - 9
# set W3 [$os node 5.1.0 2.0.0]
# [$W3 set regagent_] priority 3

 #W4 - 10
# set W4 [$os node 6.1.0 2.0.0]
# [$W4 set regagent_] priority 4

   #xxxxxxxxxxxxxxxxx#
   # PELETAKAN TITIK #
   #xxxxxxxxxxxxxxxxx#

 $HA set X_ 710.0
 $HA set Y_ 600.0
 $HA label "HA"

 $CN set X_ 510.0
 $CN set Y_ 390.0
 $CN label "CN"

 $N1 set X_ 376.0
 $N1 set Y_ 525.0
 $N1 label "N1"

 $MAP set X_ 110.0
 $MAP set Y_ 100.0
 $MAP label "MAP"

 $N2 set X_ 161.0
 $N2 set Y_ 600.0
 $N2 label "N2"

# $W1 set X_ 210.0
# $W1 set Y_ 665.0
# $W1 label "W1"

 $N3 set X_ 060.0
 $N3 set Y_ 600.0
 $N3 label "N3"

# $W2 set X_ 025.0
# $W2 set Y_ 665.0
# $W2 label "W2"

# $N4 set X_ 060.0
# $N4 set Y_ 480.0
# $N4 label "N4"

# $W3 set X_ 025.0
# $W3 set Y_ 425.0
# $W3 label "W3"

# $N5 set X_ 155.0
# $N5 set Y_ 480.0
# $N5 label "N5"

# $W4 set X_ 190.0
# $W4 set Y_ 425.0
# $W4 label "W4"

 $MD set X_ 215.0
 $MD set Y_ 702.0
 $MD label "MD"

   #xxxxxxxxxxxxxxxxxxxxx#
   # PENGATURAN JARINGAN # NETWORK SETTINGS #
   #xxxxxxxxxxxxxxxxxxxxx#

#  droptail = (FIFO), RED = Random Early Detection
 $os duplex-link $CN $N1 100Mb 2ms RED
 $os duplex-link $HA $N1 100Mb 2ms RED
 $os duplex-link $MAP $N1 10Mb 50ms RED
 $os duplex-link $N2 $MAP 10Mb 2ms RED
 $os duplex-link $N3 $MAP 10Mb 2ms RED
# $os duplex-link $N4 $MAP 10Mb 2ms RED
# $os duplex-link $N5 $MAP 10Mb 2ms RED
# $os duplex-link $W1 $N2 1000Kb 2ms DropTail
# $os duplex-link $W2 $N3 1000Kb 2ms DropTail
# $os duplex-link $W3 $N4 1000Kb 2ms DropTail
# $os duplex-link $W4 $N5 1000Kb 2ms DropTail


   #xxxxxxxxxxxxxxxxxxxxx#
   # PENGATURAN APLIKASI #
   #xxxxxxxxxxxxxxxxxxxxx#


 $os attach-mapagent $MAP

 set udp0 [new Agent/UDP]
 $os attach-agent $CN $udp0
 set null0 [new Agent/Null]
 $os attach-agent $MD $null0
 $os connect $udp0 $null0

 set cbr0 [new Application/Traffic/CBR]
 $cbr0 attach-agent $udp0
 $cbr0 set packetSize_ 1000
 $cbr0 set rate_ 1.0Mb
 $cbr0 set random_ null

 $os at 5.0 "$cbr0 start"
 $os at 80.0 "$cbr0 stop"

 proc selesai {} {
     global os tf nf
     close $tf
     close $nf
     exec nam finale.nam &     
}

   #xxxxxxxxxx#
   # SKENARIO #
   #xxxxxxxxxx#

 $os at 10.0 "$MD setdest 160.0 135.1 1"

 for {set t 10} {$t < 80} {incr t 10} {
     $os at $t "puts stderr \"completed through $t/80 secs...\""
 }



 $os at 10.0 "selesai"

 $os run
