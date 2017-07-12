
#       http://projectcodens2.googlecode.com/svn-history/r344/trunk/mytcl/test2Group.tcl


#===Define options
set val(chan)		Channel/WirelessChannel
set val(ant)		Antenna/OmniAntenna
set val(ifq)		Queue/DropTail/PriQueue
set val(ifqlen)		50
set val(ll)			LL
set val(mac)		Mac/802_11
set val(netif)		Phy/WirelessPhy
set val(nn)			10
set val(nbs) 		11
set val(prop)		Propagation/TwoRayGround
#set val(rp)			AODV
set val(rp)			DSDV
#set val(rp)			DSR
#===
set dsdv [new Agent/DSDV]
#+++main Program

#===Khoi tao moi truong gia lap
set ns_ [new Simulator]
set tracefd [open out.tr w]
$ns_ trace-all $tracefd 
#===

#===Cau hinh cau truc dia chi, do co Base Station(0.0.0)
$ns_ node-config -addressType hierarchical
AddrParams set domain_num_ 1
lappend cluster_num 1
AddrParams set cluster_num_ $cluster_num
lappend eilastlevel 10
AddrParams set nodes_num_ $eilastlevel
#===

#===Tao ranh gioi mo phong voi kich thuoc khong gian 2 chieu
set topo [new Topography]
$topo load_flatgrid 950 510
#===

#+++Create God doi tuong quan ly cac doi tuong ns-2

#===Tao ra so luong cac mobiles gia lap
create-god $val(nbs)
#===

#===Tao cau hinh mobile node 
$ns_ node-config -adhocRouting $val(rp) \
				 -llType $val(ll) \
				 -macType $val(mac) \
				 -ifqType $val(ifq) \
				 -ifqLen $val(ifqlen) \
				 -antType $val(ant) \
				 -propType $val(prop) \
				 -phyType $val(netif) \
				 -topoInstance $topo  \
				 -channelType $val(chan) \
				 -agentTrace ON  \
				 -routerTrace ON \
				 -macTrace OFF \
				 -movementTrace OFF
#===

#===Thiet lap cac mobile node 
$ns_ node-config -wiredRouting OFF

for {set i 1} {$i <= $val(nbs) } {incr i} {
		set node_($i) [$ns_ node 0.0.$i]
		$node_($i) random-motion 0
		set p_($i) [new Agent/Groupcaching [$node_($i) node-addr]] 
		$ns_ attach-agent $node_($i) $p_($i)
}

for {set i 1} {$i < $val(nbs)} {incr i} {
		set kq [expr $val(nbs)-1]
		if {$i == $kq} {
		break
		}
		for {set j [expr $i +1]} {$j <= $val(nbs)} {incr j} {
			$ns_ connect $p_($i) $p_($j)
		}
}


#===

#===Thiet lap toa do cho cac mobile node trong khong gian 2 chieu 
$node_(10) set X_ 559.0
$node_(10) set Y_ 109.0
$node_(10) set Z_ 0.0 

$node_(9) set X_ 894.0
$node_(9) set Y_ 454.0
$node_(9) set Z_ 0.0 

$node_(8) set X_ 302.0
$node_(8) set Y_ 116.0
$node_(8) set Z_ 0.0 

$node_(7) set X_ 551.0
$node_(7) set Y_ 430.0
$node_(7) set Z_ 0.0 

$node_(6) set X_ 384.0
$node_(6) set Y_ 268.0
$node_(6) set Z_ 0.0 

$node_(5) set X_ 687.0
$node_(5) set Y_ 138.0
$node_(5) set Z_ 0.0 

$node_(4) set X_ 790.0
$node_(4) set Y_ 281.0
$node_(4) set Z_ 0.0 

$node_(3) set X_ 647.0
$node_(3) set Y_ 351.0
$node_(3) set Z_ 0.0 

$node_(2) set X_ 357.0
$node_(2) set Y_ 430.0
$node_(2) set Z_ 0.0 

$node_(1) set X_ 252.0
$node_(1) set Y_ 220.0
$node_(1) set Z_ 0.0 
#===

#===Khoi tao toa do cho BS
$node_($val(nbs)) set X_ 200.0
$node_($val(nbs)) set Y_ 200.0
$node_($val(nbs)) set Z_ 0.0 
#===

#===Thiet lap thuoc tinh cho BS(argv[2]: cacheSite; argv[3]:  Label)
$ns_  at 100.0 "$p_($val(nbs)) setAttribute 1000 -1 $val(nn)"
#===
set time 100.0
#===Thiet lap thuoc tinh cho MH  (argv[2]: cacheSite; argv[3]:  Label)
for {set i 1} {$i <= $val(nn) } {incr i} {
	#puts "Starting Simulation..."
	#$ns_  at 100.0 "$p_($i) setAttribute 100 $val(nbs)"
	set time [expr {$time + 25.0}]
	$ns_  at $time "$p_($i) setAttribute 50 $val(nbs) $val(nn)"
}
#===
$ns_ at $time "$p_($val(nbs)) setIdFileResult 2"
#+++Chuan bi du lieu mau dung de kiem chung tinh hieu qua cua kien truc

#===Thi: Doc Du lieu tu file "BS_data.txt" vao BS
for {set i 1} {$i <= $val(nn) } {incr i} {
	$ns_ at $time "puts MH:$i-additem"
	set file_name "mytcl/input/LocalTable$i"
	#set file_name "mytcl/BS_data.txt"
	set numline 0
	#open file
	set fp [open $file_name "r"]
	set time [expr {$time + 20.0}]
	if { [llength $fp] > 0 } { 
		gets $fp line
		while {-1 != [gets $fp line]} { # -1 when end of file
		#	puts "Du lieu them vao la '$line'."
			set time [expr {$time + 30.0}]
			#Cho cac MH
			$ns_  at $time "$p_($i) addItem $line"
			#Cho BS
			set time [expr {$time + 30.0}]
			$ns_  at $time "$p_($val(nbs)) addItem $line"
		}
	} else {
		puts "No file found"
	}
	# close file
	close $fp

}

#set time [expr {$time + 100.0}]
#for {set i 1} {$i <= $val(nn) } {incr i} {
#	set time [expr {$time + 50.0}]
#	$ns_  at $time "$p_($i) printLocalTable"
#	$ns_  at $time "$p_($i) printZoneTable"
#}
#===
set time [expr {$time + 100.0}]
$ns_ at $time "$p_($val(nbs)) resetFileResult"
set time [expr {$time + 500.0}]
	set file_name "mytcl/input/Search10"
	set numline 0
	#open file
	set fp [open $file_name "r"]
	set i 1
	set time [expr {$time + 50.0}]
	if { [llength $fp] > 0 } { 
		while {-1 != [gets $fp line]} { # -1 when end of file
		#	puts "Du lieu them vao la '$line'."
			set time [expr {$time + 50.0}]
			#Cho cac MH
			set i 0
			foreach partline $line {
				if {$i == 0 } { 
					set idmh $partline
				} else {
					set iddata $partline
				}
				set i [expr {$i + 1}]
			} 
			$ns_  at $time "$p_($idmh) searchItem $iddata"
		}
	} else {
		puts "No file found"
	}
	# close file
	close $fp
#+++Dua ra ket qua phan tich ve tinh hieu qua cua kien truc

#===Yeu cau tim kiem
#set time [expr {$time + 3200.0}]
#$ns_ at $time "$node_(1) setdest 700.0 350.0 15.0"
#$ns_  at $time "$p_(1) searchItem 12"
#set time [expr {$time + 1000.0}]
#$ns_ at $time "$dsdv displayrtable"
#===Phan nay cho tests
#$ns_  at [expr $val(nn)*1010] "$p_($val(nbs)) printLocalTable"

#set time [expr {$time + 200.0}]
#$ns_  at $time "$p_(1) join"
#set time [expr {$time + 20.0}]
#$ns_  at $time "$p_($val(nbs)) printHomeLocalCache"
#===Reset va ket thuc
set time [expr {$time + 1000.0}]
for {set i 1} {$i <= $val(nn) } {incr i} {
$ns_ at $time "$node_($i) reset"
}
$ns_ at $time "stop"
$ns_ at $time "puts \"NS EXITING...\"; $ns_ halt"
proc stop {} {
}
puts "Starting Simulation..."
$ns_ run
#===
