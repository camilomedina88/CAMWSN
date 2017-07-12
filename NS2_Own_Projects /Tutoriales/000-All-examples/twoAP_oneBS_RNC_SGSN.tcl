#==================================================================
# Filename: 	twoAP_oneBS_RNC_SGSN.tcl
# Author: 	Huang Minghe <H.Minghe@gmail.com>
# Description:	See twoAP_oneBS_RNC_SGSN_instruction.txt
# You can:	Freely copy, distribute,and use under the following conditions
#		No direct commercial advantage is obtained
#		No liability is attributed to the author for any damages incurred.
# I hope:	When changes happen,let me know. thanks
#==================================================================*/
#检查输入
if {$argc != 0} {
	puts ""
	puts "Wrong Number of Arguments! No arguments in this topology"
	puts ""
	exit (1)
}
global ns

#定义结束过程
proc finish {} {
    global ns f
    $ns flush-trace
    close $f
    puts " Simulation ended."
    exit 0
}

# 当前路径
set output_dir .

#创建仿真实例
set ns [new Simulator]
#$ns use-newtrace

$ns color 1 Blue
$ns color 2 Red
#将仿真过程写入追踪文件
set f [open out.tr w]
$ns trace-all $f
set namfile [open out.nam w]
$ns namtrace-all-wireless $namfile 800 800 

# 配置 UMTS
$ns set hsdschEnabled_ 1addr
$ns set hsdsch_rlc_set_ 0
$ns set hsdsch_rlc_nif_ 0

# 配置层次结构（域：簇：ip号） (needed for routing over a basestation)
$ns node-config -addressType hierarchical
AddrParams set domain_num_  7                      			;# 域数目
AddrParams set cluster_num_ {1 1 1 1 1 1 1}            		;# 簇数目 
AddrParams set nodes_num_   {5 1 1 1 3 1 1}	      			;# 每个簇的节点数目             

#配置RNC 
puts "##############################################################"
puts "***********************Now, Creating RNC**********************"

$ns node-config -UmtsNodeType rnc 
set RNC [$ns create-Umtsnode 0.0.0] ;# node id is 0.
$RNC set X_ 200 
$RNC set Y_ 100
$RNC set Z_ 0
puts "RNC $RNC"


puts "***********************Completed successfully*****************"
puts "##############################################################"
puts ""
puts ""

# 配置UMTS基站

puts "##############################################################"
puts "***********************Now, Creating BS**********************"

$ns node-config -UmtsNodeType bs \
		-downlinkBW 384kbs \
		-downlinkTTI 10ms \
		-uplinkBW 384kbs \
		-uplinkTTI 10ms \
     		-hs_downlinkTTI 2ms \
      		-hs_downlinkBW 384kbs 

set BS [$ns create-Umtsnode 0.0.1] ;# node id is 1 基站和RNC处在同一个域
$BS set X_ 100 
$BS set Y_ 100 
$BS set Z_ 0
puts "BS $BS"

puts "***********************Completed successfully*****************"
puts "##############################################################"
puts ""
puts ""

#链接BS和RNC 
puts "##############################################################"
puts "***********************Now, Connecting RNC and BS*************"

$ns setup-Iub $BS $RNC 622Mbit 622Mbit 15ms 15ms DummyDropTail 2000

puts "***********************Completed successfully*****************"
puts "##############################################################"
puts ""
puts ""

#创建UMTS无线节点
puts "##############################################################"
puts "******Now, Creating UMTS UE(us as MultiFaceNode's NIC)*******"

$ns node-config -UmtsNodeType ue \
		-baseStation $BS \
		-radioNetworkController $RNC

#UMTS_UE0携带的是UMTS的网卡，可作为后面多面终端的网卡之一

set UMTS_UE0 [$ns create-Umtsnode 0.0.2] ;# node id is 2
$UMTS_UE0 set Y_ 50 
$UMTS_UE0 set X_ 100 
$UMTS_UE0 set Z_ 0
set UMTS_UE0_id [$UMTS_UE0 id]
puts "UMTS_UE0 created $UMTS_UE0_id" 

set UMTS_UE1 [$ns create-Umtsnode 0.0.3]
$UMTS_UE1 set Y_ 100
$UMTS_UE1 set X_ 50
$UMTS_UE1 set Z_ 0
set UMTS_UE1_id [$UMTS_UE1 id]
puts "UMTS_UE1 created $UMTS_UE1_id"
#创建一个虚假节点，只是仿真的顺利需要。
set dummy_node [$ns create-Umtsnode 0.0.3] ;# node id is 3
$dummy_node set Y_ 150
$dummy_node set X_ 100 
$dummy_node set Z_ 0
puts "Creating dummy node $dummy_node"

puts "***********************Completed successfully*****************"
puts "##############################################################"
puts ""
puts ""

#创建SGSN 和GGSN。处在不同的域里。Node id for SGSN0 and GGSN0 are 4 and 5, respectively.
puts "##############################################################"
puts "***********************Now, Creating GGSN and SGSN************"

set SGSN [$ns node 1.0.0]
set SGSN_id [$SGSN id]
puts "SGSN $SGSN"
puts "SGSN_id $SGSN_id"
$SGSN set X_ 300 
$SGSN set Y_ 100 
$SGSN set Z_ 0

set GGSN [$ns node 2.0.0]
$GGSN set X_ 400
$GGSN set Y_ 100 
$GGSN set Z_ 0
puts "GGSN $GGSN"
set GGSN_id [$GGSN id]
puts "GGSN_id $GGSN_id"

puts "***********************Completed successfully*****************"
puts "##############################################################"
puts ""
puts ""


#创建两个节点，在这里这两个节点我们可以这是核心网的节点。
puts "##############################################################"
puts "***********************Now, Creating CN_host1 and CN_host2****"

set CN_host0 [$ns node 3.0.0]
$CN_host0 set X_ 500
$CN_host0 set Y_ 100 
$CN_host0 set Z_ 0
puts "CN_host0 $CN_host0"
set CN_host0_id [$CN_host0 id]
puts "CN_host0_id $CN_host0_id"
puts "finished"
puts ""
# do the connections in the UMTS part
puts "Connecting RNC SGSN GGSN CN_host0 CN host1"

$ns duplex-link $RNC $SGSN 622Mbit 0.4ms DropTail 1000
$ns duplex-link $SGSN $GGSN 622MBit 10ms DropTail 1000
$ns duplex-link $GGSN $CN_host0 10MBit 15ms DropTail 1000

$RNC add-gateway $SGSN                                      		 ;#这一句应该放在链路搭建完成之后，一般情况放在这个位置
	
puts "***********************Completed successfully*****************"
puts "##############################################################"
puts ""
puts ""

#添加WLAN网络。 
puts "##############################################################"
puts "***********************Now, Creating WLAN*********************"

# parameter for wireless nodes
set opt(chan)           Channel/WirelessChannel   			;# channel type for 802.11
set opt(prop)           Propagation/TwoRayGround   			;# radio-propagation model 802.11
set opt(netif)          Phy/WirelessPhy            			;# network interface type 802.11
set opt(mac)            Mac/802_11                 			;# MAC type 802.11
set opt(ifq)            Queue/DropTail/PriQueue    			;# interface queue type 802.11
set opt(ll)             LL                         			;# link layer type 802.11
set opt(ant)            Antenna/OmniAntenna        			;# antenna model 802.11
set opt(ifqlen)         50              	   			;# max packet in ifq 802.11
set opt(adhocRouting)   DSDV                       			;# routing protocol 802.11
set opt(umtsRouting)    ""                         			;# routing for UMTS (to reset node config)

set opt(x)	   	1000 			   			;# X dimension of the topography
set opt(y)		1000			   			;# Y dimension of the topography

#配置WLAN的速率为11Mb 
Mac/802_11 set basicRate_ 11Mb
Mac/802_11 set dataRate_ 11Mb
Mac/802_11 set bandwidth_ 11Mb
Mac/802_11 set client_lifetime_ 10 					;#increase since iface 2 is not sending traffic for some time

#配置拓扑
puts "1 Creating topology"
puts ""
set topo [new Topography]
$topo load_flatgrid $opt(x) $opt(y)

puts "Topology created"
puts ""

# create God
set god [create-god 12]				                		;# give the number of nodes 

#创建多摸节点 
puts "2 Creating UE"
puts ""

$ns node-config  -multiIf ON                            		;#to create MultiFaceNode
set UE0 [$ns node 5.0.0] 
$UE0 set X_ 100
$UE0 set Y_ 100 
$UE0 set Z_ 0
set UE0_id [$UE0 id]
puts "UE0 $UE0_id"
set UE1 [$ns node 6.0.0]
$UE1 set X_ 200
$UE1 set Y_ 100
$UE1 set Z_ 0
set UE1_id [$UE1 id] 
puts "UE1 $UE1_id"
$ns node-config  -multiIf OFF                           		;#reset attribute

#设置节点之间的最小跳数，减少计算时间。
$god set-dist 1 2 1 
$god set-dist 0 2 2 
$god set-dist 0 1 1 
set god [God instance]


puts "finished"
puts ""

#配置接入点AP 
puts "3 Creating AP"
puts ""

puts "coverge:20m"

Phy/WirelessPhy set Pt_ 0.025
Phy/WirelessPhy set RXThresh_ 2.025e-12
Phy/WirelessPhy set CSThresh_ [expr 0.9*[Phy/WirelessPhy set RXThresh_]]

$ns node-config  -adhocRouting $opt(adhocRouting) \
                 -llType $opt(ll) \
                 -macType $opt(mac) \
                 -channel [new $opt(chan)] \
                 -ifqType $opt(ifq) \
                 -ifqLen $opt(ifqlen) \
                 -antType $opt(ant) \
                 -propType $opt(prop)    \
                 -phyType $opt(netif) \
                 -topoInstance $topo \
                 -wiredRouting ON \
                 -agentTrace OFF\
                 -routerTrace OFF \
                 -macTrace ON  \
                 -movementTrace OFF	

# configure Base station 802.11
set AP0 [$ns node 4.0.0]

set AP0_id [$AP0 id]
puts "AP0_id $AP0_id"

$AP0 set X_ [expr 200]
$AP0 set Y_ 50.0
$AP0 set Z_ 0.0
[$AP0 set mac_(0)] bss_id [[$AP0 set mac_(0)] id]
[$AP0 set mac_(0)] enable-beacon
[$AP0 set mac_(0)] set-channel 1
puts "AP0 created"


# creation of the wireless interface 802.11
puts "5 Creating 2 WLAN UEs"
puts ""
$ns node-config -wiredRouting OFF \
                -macTrace ON 				
set WLAN_UE0 [$ns node 4.0.1] 	                                   		;# create the node with given @.	
$WLAN_UE0 random-motion 0
set WLAN_UE0_id [$WLAN_UE0 id]
puts "WLAN_UE0_id $WLAN_UE0_id connet to AP0"			                          	;# disable random motion
$WLAN_UE0 base-station [AddrParams addr2id [$AP0 node-addr]] 			;#attach mn to basestation

$WLAN_UE0 set X_ [expr 200.0]
$WLAN_UE0 set Y_ 50.0
$WLAN_UE0 set Z_ 0.0
[$WLAN_UE0 set mac_(0)] set-channel 1
$ns at 0.0 "$WLAN_UE0 setdest 750.0 100.0 50.0"

set WLAN_UE1 [$ns node 4.0.2] 	                                   		;# create the node with given @.	
$WLAN_UE0 random-motion 0
set WLAN_UE1_id [$WLAN_UE1 id]
puts "WLAN_UE1_id $WLAN_UE1_id connect to AP0"			                          	;# disable random motion
$WLAN_UE1 base-station [AddrParams addr2id [$AP0 node-addr]] 			;#attach mn to basestation

$WLAN_UE1 set X_ [expr 250.0]
$WLAN_UE1 set Y_ 50.0
$WLAN_UE1 set Z_ 0.0
[$WLAN_UE1 set mac_(0)] set-channel 1

$ns at 0.0 "$WLAN_UE1 setdest 850.0 100.0 50.0"
# add link to backbone
puts "5 Connecting AP0 to RNC and Connecting AP1 to SGSN"
puts ""
$ns duplex-link $AP0 $RNC 10MBit 15ms DropTail 1000
# add interfaces to MultiFaceNode
$UE0 add-interface-node $WLAN_UE0
$UE0 add-interface-node $UMTS_UE0
$UE1 add-interface-node $WLAN_UE0
$UE1 add-interface-node $UMTS_UE1
puts "***********************Completed successfully*****************"
puts "##############################################################"
puts ""
puts ""

# create a TCP agent and attach it to multi-interface node
puts "##############################################################"
puts "***************Generating traffic: using TcpApp***************"
puts ""
puts "1 Generating traffic between CN_host0 and mutilFacenNode0"

set udp(0) [new Agent/UDP]
$UE0 attach-agent $udp(0) $UMTS_UE0                   ;# new command: the interface is used for sending
set null(0) [new Agent/Null]
$ns attach-agent $CN_host0 $null(0)
$ns connect $udp(0) $null(0)
set cbr(0) [new Application/Traffic/CBR]
$cbr(0) attach-agent $udp(0)
$cbr(0) set type_ CBR 
$cbr(0) set packet_size_ 500
$cbr(0) set rate_ 1mb
$cbr(0) set random_ false
$ns at 0.0 "$cbr(0) start"

puts ""
puts "2 Generating traffic between CN_host1 and WLAN_UE1"
set udp(1) [new Agent/UDP]
$UE1 attach-agent $udp(1) $UMTS_UE0                   ;# new command: the interface is used for sending
set null(1) [new Agent/Null] 
$ns attach-agent $CN_host0 $null(1)
$ns connect $udp(1) $null(1)
set cbr(1) [new Application/Traffic/CBR]
$cbr(1) attach-agent $udp(1)
$cbr(1) set type_ CBR 
$cbr(1) set packet_size_ 1000
$cbr(1) set rate_ 1mb
$cbr(1) set random_ false
$ns at 1.0 "$cbr(1) start"
puts "finished"    
puts ""



# connect both TCP agent
puts "3 Connecting send agent and recieve agent"
#$UE0 connect-agent $tcp_(0) $tcp_(1) $UMTS_UE0 ;# new command: specify the interface to use
#$tcp_(0) listen


puts "finished"
puts ""

# do some kind of registration in UMTS
puts "****************************************************************"
puts "do some kind of registration in UMTS......"
$ns node-config -llType UMTS/RLC/AM \
		-downlinkBW 384kbs \
		-uplinkBW 384kbs \
		-downlinkTTI 20ms \
		-uplinkTTI 20ms \
   		-hs_downlinkTTI 2ms \
    		-hs_downlinkBW 384kbs

# for the first HS-DSCH, we must create. If any other, then use attach-hsdsch
puts "Creating HS-DSCH for data transfering......"

$ns create-hsdsch $UMTS_UE0 $udp(0)
#$ns attach-hsdsch $UMTS_UE1 $udp(1)
# we must set the trace for the environment. If not, then bandwidth is reduced and
# packets are not sent the same way (it looks like they are queued, but TBC)
puts "set trace for the environment......"

$BS setErrorTrace 0 "idealtrace"
#$BS setErrorTrace 1 "idealtrace"

# load the CQI (Channel Quality Indication)
puts "loading Channel Quality Indication......"
$BS loadSnrBlerMatrix "SNRBLERMatrix"

puts "finished"
puts "****************************************************************"
puts "################################################################"
# we cannot start the connect right away. Give time to routing algorithm to run
#$ns at 0.5 "$app_(1) connect $app_(0)"


# install a procedure to print out the received data
Application/TcpApp instproc recv {data} {
    global ns
    $ns trace-annotate "$self received data \"$data\""
    puts "$self received data \"$data\""
}

# function to redirect traffic from WLAN_UE0 to WLAN_UE0
proc redirectTraffic {} {
	puts ""
	puts "************it is time for handovering*********"
	puts ""
    global UE0 WLAN_UE0 UE1 WLAN_UE1  udp null
    $UE0 attach-agent $udp(0) $WLAN_UE0 					;# the interface is used for sending
    $UE0 connect-agent $udp(0) $null(0) $WLAN_UE0 				;# the interface is used for receiving
    $UE1 attach-agent $udp(1) $WLAN_UE1
    $UE1 connect-agent $udp(1) $null(1) $WLAN_UE1
}

# send a message via TcpApp
# The string will be interpreted by the receiver as Tcl code.
#for { set i 1 } { $i < 10 } { incr i} {
 #   	$ns at [expr $i + 0.5] "$app_(1) send 100 {$app_(0) recv {my message $i}}"
#}

#record the position of node
proc record {} {
  global WLAN_UE0
   set ns [Simulator instance]
   set time 1.0;# record 0.5 second
   set WLAN_UE0_x [$WLAN_UE0 set X_]
   set WLAN_UE0_y [$WLAN_UE0 set Y_]
   set now [$ns now]

   puts "$WLAN_UE0_x\t$WLAN_UE0_y"
   $ns at [expr $now + $time] "record"
}
$ns at 0.0 "record"


# call to redirect traffic
$ns at 1 "redirectTraffic"
$ns at 1 "$ns trace-annotate \"Redirecting traffic\""

$ns at 2 "finish"

puts " Simulation is running ... please wait ..."
$ns run
