#    http://www.linuxquestions.org/questions/linux-newbie-8/tcl-code-for-leach-and-spin-protocols-bad-4175502839/


 
#set val(ifqlen)         50                         
#set val(nn)             6                           
#set val(rp)             Protoname                   
#set val(chan)       	Channel/WirelessChannel 
#set val(prop)      	Propagation/TwoRayGround 
#set val(netif)     	Phy/WirelessPhy 
#set val(mac)       	Mac/802_11 
#set val(PROTOCOL)	Leach
#set val(ifq)       	Queue/DropTail/PriQueue 
#set val(ll)        	LL 
#set val(ant)        	Antenna/OmniAntenna 
#set val(stop)	    	10 

set ns [new Simulator]
global a i 
set a 10
set i 0
$ns color 1 Blue
$ns color 2 Blue
 
set nf [open out.nam w]
$ns namtrace-all $nf

set f [open out.tr w]
$ns trace-all $f

set f0 [open alivenodes_leach.tr w]
set f1 [open frames_leach.tr w]
set f2 [open bitsfromcluster_leach.tr w]

proc finish {} {
        global ns nf f0 f1 f2
        #$ns flush-trace
        #Close the NAM trace file        
	close $f0
	close $f1	
	close $f2	
	close $nf

        #Execute NAM on the trace file
exec xgraph alivenodes_leach.tr  -geometry 800x400 -t "alivenodes vs time" -x "time" -y "alivenodes" &
exec xgraph frames_leach.tr -geometry 800x400 -t "frames vs round number" -x "rounds" -y "frames" &
exec xgraph bitsfromcluster_leach.tr -geometry 800x400 -t "bits from cluster vs time" -x "time" -y "bits from cluster" &       


 exec nam out.nam &
        exit 0
}

#proc record {} { global ns f0 
#set time 0.05
#set now [$ns now]
#$ns at [expr $now+$time] "record" }


#Create nodes
set n0 [$ns node] 
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]
set n8 [$ns node]
set n9 [$ns node]
set n10 [$ns node]
set d 0
set nc0status 1
set nc1status 1
set nc2status 1
set nc3status 1
set nc4status 1
set nc5status 1
set nc6status 1
set nc7status 1
set nc8status 1
set nc9status 1


$ns at 0.0 "$n0 label N0"
$ns at 0.0 "$n1 label N1"
$ns at 0.0 "$n2 label N2"
$ns at 0.0 "$n3 label N3"
$ns at 0.0 "$n4 label N4"
$ns at 0.0 "$n5 label N5"
$ns at 0.0 "$n6 label N6"
$ns at 0.0 "$n7 label N7"
$ns at 0.0 "$n8 label N8"
$ns at 0.0 "$n9 label N9"
$ns at 0.0 "$n10 label BS"

$n4 shape square

	set e0 2
	set e1 2
	set e2 2
	set e3 2
        set e4 2
	set e5 2
	set e6 2
	set e7 2
	set e8 2
	set e9 2
	set ch 0		
			
	set d01 12.00
	set d02 15.00
	set d03 17.00
	set d04 11.00
	set d05 12.00
	set d06 13.00
	set d07 14.00
	set d08 15.00
	set d09 16.00

	set d10 12.00
	set d12 15.00
	set d13 19.00
	set d14 11.00
	set d15 22.00
	set d16 23.00
	set d17 14.00
	set d18 17.00
	set d19 16.00
	
	set d20 15.00
	set d21 15.00
	set d23 23.00
	set d24 11.00
	set d25 12.00
	set d26 13.00
	set d27 24.00
	set d28 18.00
	set d29 26.00
	
	set d30 17.00
	set d31 19.00
	set d32 23.00
	set d34 11.00
	set d35 17.00
	set d36 13.00
	set d37 15.00
	set d38 19.00
	set d39 14.00

	set d40 11.00
	set d41 11.00
	set d42 11.00
	set d43 11.00
	set d45 19.00
	set d46 12.00
	set d47 9.00
	set d48 15.00
	set d49 16.00

	set d50 12.00
	set d51 22.00
	set d52 12.00
	set d53 17.00
	set d54 19.00
	set d56 20.00
	set d57 26.00 
	set d58 17.00
	set d59 9.00

	set d60 13.00
	set d61 23.00
	set d62 13.00
	set d63 13.00
	set d64 12.00
	set d65 20.00
	set d67 19.00	
	set d68 11.00
	set d69 10.00
	
	set d70 14.00
	set d71 14.00
	set d72 24.00
	set d73 15.00
	set d74 9.00
	set d75 26.00
	set d76 19.00
	set d78 23.00
	set d79 16.00

	set d80 15.00
	set d81 17.00
	set d82 18.00
	set d83 19.00
	set d84 15.00
	set d85 17.00
	set d86 11.00
	set d87 23.00
	set d89 13.00

	set d90 16.00
	set d91 16.00
	set d92 26.00
	set d93 14.00
	set d94 16.00
	set d95 9.00
	set d96 10.00
	set d97 16.00
	set d98 13.00
	
	#set k 4000
	#set Eelect 50*0.000000001
	set Eelec 50*0.000000001
	set Efs 10*0.000000000001
	set Emp 0.0013*0.000000000001	
	set dist4mBS2node 200
	set Ech 50*0.000000001
	set Ecri 0.00
	set EDA 5*0.000000001
	set cntrpackt 4000
	set packlen 4000
	set N 225
	set bitsfromclust 0	
	#set d0 [expr (sqrt($Efs/$Emp))]        
	
	puts " Distance 0-1 = $d01"
	puts " Distance 0-2 = $d02"
	puts " Distance 0-3 = $d03"
	puts " Distance 0-4 = $d04"
	puts " Distance 0-5 = $d05"
	puts " Distance 0-6 = $d06"
	puts " Distance 0-7 = $d07"
	puts " Distance 0-8 = $d08"
	puts " Distance 0-9 = $d09"
	puts " Distance 1-0 = $d10"
	puts " Distance 1-2 = $d12"
	puts " Distance 1-3 = $d13"
	puts " Distance 1-4 = $d14"
	puts " Distance 1-5 = $d15"
	puts " Distance 1-6 = $d16"
	puts " Distance 1-7 = $d17"
	puts " Distance 1-8 = $d18"
	puts " Distance 1-9 = $d19"
	puts " Distance 2-0 = $d20"
	puts " Distance 2-1 = $d21"
	puts " Distance 2-3 = $d23"
	puts " Distance 2-4 = $d24"
	puts " Distance 2-5 = $d25"
	puts " Distance 2-6 = $d26"
	puts " Distance 2-7 = $d27"
	puts " Distance 2-8 = $d28"
	puts " Distance 2-9 = $d29"
	puts " Distance 3-0 = $d30"
	puts " Distance 3-1 = $d31"
	puts " Distance 3-2 = $d32"
	puts " Distance 3-4 = $d34"
	puts " Distance 3-5 = $d35"
	puts " Distance 3-6 = $d36"
	puts " Distance 3-7 = $d37"
	puts " Distance 3-8 = $d38"
	puts " Distance 3-9 = $d39"
	puts " Distance 4-0 = $d40"
	puts " Distance 4-1 = $d41"
	puts " Distance 4-2 = $d42"
	puts " Distance 4-3 = $d43"
	puts " Distance 4-5 = $d45"
	puts " Distance 4-6 = $d46"
	puts " Distance 4-7 = $d47"
	puts " Distance 4-8 = $d48"
	puts " Distance 4-9 = $d49"
	puts " Distance 5-0 = $d50"
	puts " Distance 5-1 = $d51"
	puts " Distance 5-2 = $d52"
	puts " Distance 5-3 = $d53"
	puts " Distance 5-4 = $d54"
	puts " Distance 5-6 = $d56"
	puts " Distance 5-7 = $d57"
	puts " Distance 5-8 = $d58"
	puts " Distance 5-9 = $d59"
	puts " Distance 6-0 = $d60"
	puts " Distance 6-1 = $d61"
	puts " Distance 6-2 = $d62"
	puts " Distance 6-3 = $d63"
	puts " Distance 6-4 = $d64"
	puts " Distance 6-5 = $d65"
	puts " Distance 6-7 = $d67"
	puts " Distance 6-8 = $d68"
	puts " Distance 6-9 = $d69"
	puts " Distance 7-0 = $d70"
	puts " Distance 7-1 = $d71"
	puts " Distance 7-2 = $d72"
	puts " Distance 7-3 = $d73"
	puts " Distance 7-4 = $d74"
	puts " Distance 7-5 = $d75"
	puts " Distance 7-6 = $d76"
	puts " Distance 7-8 = $d78"
	puts " Distance 7-9 = $d79"
	puts " Distance 8-0 = $d80"
	puts " Distance 8-1 = $d81"
	puts " Distance 8-2 = $d82"
	puts " Distance 8-3 = $d83"
	puts " Distance 8-4 = $d84"
	puts " Distance 8-5 = $d85"
	puts " Distance 8-6 = $d86"
	puts " Distance 8-7 = $d87"
	puts " Distance 8-9 = $d89"
	puts " Distance 9-0 = $d90"
	puts " Distance 9-1 = $d91"
	puts " Distance 9-2 = $d92"
	puts " Distance 9-3 = $d93"
	puts " Distance 9-4 = $d94"
	puts " Distance 9-5 = $d95"
	puts " Distance 9-6 = $d96"
	puts " Distance 9-7 = $d97"
	puts " Distance 9-8 = $d98"


        #Create links between the nodes
	$ns duplex-link $n0 $n1 10Mb 10ms DropTail
	$ns duplex-link $n0 $n2 10Mb 10ms DropTail
	$ns duplex-link $n0 $n3 10Mb 10ms DropTail
	$ns duplex-link $n0 $n4 10Mb 10ms DropTail
	$ns duplex-link $n0 $n5 10Mb 10ms DropTail
	$ns duplex-link $n0 $n6 10Mb 10ms DropTail
	$ns duplex-link $n0 $n7 10Mb 10ms DropTail
	$ns duplex-link $n0 $n8 10Mb 10ms DropTail
	$ns duplex-link $n0 $n9 10Mb 10ms DropTail
	$ns duplex-link $n1 $n2 10Mb 10ms DropTail
	$ns duplex-link $n1 $n3 10Mb 10ms DropTail
	$ns duplex-link $n1 $n4 10Mb 10ms DropTail
	$ns duplex-link $n1 $n5 10Mb 10ms DropTail
	$ns duplex-link $n1 $n6 10Mb 10ms DropTail
	$ns duplex-link $n1 $n7 10Mb 10ms DropTail
	$ns duplex-link $n1 $n8 10Mb 10ms DropTail
	$ns duplex-link $n1 $n9 10Mb 10ms DropTail
	$ns duplex-link $n2 $n3 10Mb 10ms DropTail
	$ns duplex-link $n2 $n4 10Mb 10ms DropTail
	$ns duplex-link $n2 $n5 10Mb 10ms DropTail
	$ns duplex-link $n2 $n6 10Mb 10ms DropTail
	$ns duplex-link $n2 $n7 10Mb 10ms DropTail
	$ns duplex-link $n2 $n8 10Mb 10ms DropTail
	$ns duplex-link $n2 $n9 10Mb 10ms DropTail
	$ns duplex-link $n3 $n4 10Mb 10ms DropTail
	$ns duplex-link $n3 $n5 10Mb 10ms DropTail
	$ns duplex-link $n3 $n6 10Mb 10ms DropTail
	$ns duplex-link $n3 $n7 10Mb 10ms DropTail
	$ns duplex-link $n3 $n8 10Mb 10ms DropTail
	$ns duplex-link $n3 $n9 10Mb 10ms DropTail
	$ns duplex-link $n4 $n5 10Mb 10ms DropTail
	$ns duplex-link $n4 $n6 10Mb 10ms DropTail
	$ns duplex-link $n4 $n7 10Mb 10ms DropTail
	$ns duplex-link $n4 $n8 10Mb 10ms DropTail
	$ns duplex-link $n4 $n9 10Mb 10ms DropTail
	$ns duplex-link $n5 $n6 10Mb 10ms DropTail
	$ns duplex-link $n5 $n7 10Mb 10ms DropTail
	$ns duplex-link $n5 $n8 10Mb 10ms DropTail
	$ns duplex-link $n5 $n9 10Mb 10ms DropTail
	$ns duplex-link $n6 $n7 10Mb 10ms DropTail
	$ns duplex-link $n6 $n8 10Mb 10ms DropTail
	$ns duplex-link $n6 $n9 10Mb 10ms DropTail
	$ns duplex-link $n7 $n8 10Mb 10ms DropTail
	$ns duplex-link $n7 $n9 10Mb 10ms DropTail
	$ns duplex-link $n8 $n9 10Mb 10ms DropTail
	$ns duplex-link $n0 $n10 10Mb 10ms DropTail
	$ns duplex-link $n1 $n10 10Mb 10ms DropTail
	$ns duplex-link $n2 $n10 10Mb 10ms DropTail
	$ns duplex-link $n3 $n10 10Mb 10ms DropTail
	$ns duplex-link $n4 $n10 10Mb 10ms DropTail
	$ns duplex-link $n5 $n10 10Mb 10ms DropTail
	$ns duplex-link $n6 $n10 10Mb 10ms DropTail
	$ns duplex-link $n7 $n10 10Mb 10ms DropTail
	$ns duplex-link $n8 $n10 10Mb 10ms DropTail
	$ns duplex-link $n9 $n10 10Mb 10ms DropTail	
	
	
	
	#Give node position (for NAM)
	$ns duplex-link-op $n0 $n2 orient right-down
	$ns duplex-link-op $n1 $n2 orient right-up
	$ns duplex-link-op $n2 $n3 orient right
	$ns duplex-link-op $n3 $n2 orient left
	$ns duplex-link-op $n3 $n4 orient right-up
	
	#Monitor the queue for links. (for NAM)

	
	$ns duplex-link-op $n0 $n1 color "default"
	$ns duplex-link-op $n0 $n2 color "default"
	$ns duplex-link-op $n0 $n3 color "default"
	$ns duplex-link-op $n0 $n4 color "default"
	$ns duplex-link-op $n0 $n5 color "default"
	$ns duplex-link-op $n0 $n6 color "default"
	$ns duplex-link-op $n0 $n7 color "default"
	$ns duplex-link-op $n0 $n8 color "default"
	$ns duplex-link-op $n0 $n9 color "default"
	$ns duplex-link-op $n1 $n2 color "default"
	$ns duplex-link-op $n1 $n3 color "default"
	$ns duplex-link-op $n1 $n4 color "default"
	$ns duplex-link-op $n1 $n5 color "default"
	$ns duplex-link-op $n1 $n6 color "default"
	$ns duplex-link-op $n1 $n7 color "default"
	$ns duplex-link-op $n1 $n8 color "default"
	$ns duplex-link-op $n1 $n9 color "default"
	$ns duplex-link-op $n2 $n3 color "default"
	$ns duplex-link-op $n2 $n4 color "default"
	$ns duplex-link-op $n2 $n5 color "default"
	$ns duplex-link-op $n2 $n6 color "default"
	$ns duplex-link-op $n2 $n7 color "default"
	$ns duplex-link-op $n2 $n8 color "default"
	$ns duplex-link-op $n2 $n9 color "default"
	$ns duplex-link-op $n3 $n4 color "default"
	$ns duplex-link-op $n3 $n5 color "default"
	$ns duplex-link-op $n3 $n6 color "default"
	$ns duplex-link-op $n3 $n7 color "default"
	$ns duplex-link-op $n3 $n8 color "default"
	$ns duplex-link-op $n3 $n9 color "default"
	$ns duplex-link-op $n4 $n5 color "default"
	$ns duplex-link-op $n4 $n6 color "default"
	$ns duplex-link-op $n4 $n7 color "default"
	$ns duplex-link-op $n4 $n8 color "default"
	$ns duplex-link-op $n4 $n9 color "default"
	$ns duplex-link-op $n5 $n6 color "default"
	$ns duplex-link-op $n5 $n7 color "default"
	$ns duplex-link-op $n5 $n8 color "default"
	$ns duplex-link-op $n5 $n9 color "default"
	$ns duplex-link-op $n6 $n7 color "default"
	$ns duplex-link-op $n6 $n8 color "default"
	$ns duplex-link-op $n6 $n9 color "default"
	$ns duplex-link-op $n7 $n8 color "default"
	$ns duplex-link-op $n7 $n9 color "default"
	$ns duplex-link-op $n8 $n9 color "default"
	$ns duplex-link-op $n0 $n10 color "default"
	$ns duplex-link-op $n1 $n10 color "default"
	$ns duplex-link-op $n2 $n10 color "default"
	$ns duplex-link-op $n3 $n10 color "default"
	$ns duplex-link-op $n4 $n10 color "default"
	$ns duplex-link-op $n5 $n10 color "default"
	$ns duplex-link-op $n6 $n10 color "default"
	$ns duplex-link-op $n7 $n10 color "default"
	$ns duplex-link-op $n8 $n10 color "default"
	$ns duplex-link-op $n9 $n10 color "default"
	



	for {set i 0} {$i < 1000 && $a != 0} {incr i} {
	
	set t [expr ($i*20)]	
	puts " Round Number = $i"
        puts " Node 0 Energy  = $e0"
	puts " Node 1 Energy  = $e1"
	puts " Node 2 Energy  = $e2"
	puts " Node 3 Energy  = $e3"
	puts " Node 4 Energy  = $e4"
	puts " Node 5 Energy  = $e5"
	puts " Node 6 Energy  = $e6"
	puts " Node 7 Energy  = $e7"
	puts " Node 8 Energy  = $e8"
	puts " Node 9 Energy  = $e9"
	
	set sdis0 0
	set sdis1 0
	set sdis2 0
	set sdis3 0
        set sdis4 0
	set sdis5 0
	set sdis6 0
	set sdis7 0
	set sdis8 0
	set sdis9 0


	if {$nc0status == 1} { if {$nc1status == 1} { set sdis0 [expr ($sdis0 + $d01)] } 
	if {$nc2status == 1} { set sdis0 [expr ($sdis0 + $d02)] }
	if {$nc3status == 1} { set sdis0 [expr ($sdis0 + $d03)] } 
        if {$nc4status == 1} { set sdis0 [expr ($sdis0 + $d04)] } 
        if {$nc5status == 1} { set sdis0 [expr ($sdis0 + $d05)] } 
        if {$nc6status == 1} { set sdis0 [expr ($sdis0 + $d06)] } 
        if {$nc7status == 1} { set sdis0 [expr ($sdis0 + $d07)] } 
        if {$nc8status == 1} { set sdis0 [expr ($sdis0 + $d08)] } 
        if {$nc9status == 1} { set sdis0 [expr ($sdis0 + $d09)] } }
        

        if {$nc1status == 1} { if {$nc0status == 1} { set sdis1 [expr ($sdis1 + $d10)] } 
	if {$nc2status == 1} { set sdis1 [expr ($sdis1 + $d12)] }
	if {$nc3status == 1} { set sdis1 [expr ($sdis1 + $d13)] } 
        if {$nc4status == 1} { set sdis1 [expr ($sdis1 + $d14)] } 
        if {$nc5status == 1} { set sdis1 [expr ($sdis1 + $d15)] } 
        if {$nc6status == 1} { set sdis1 [expr ($sdis1 + $d16)] } 
        if {$nc7status == 1} { set sdis1 [expr ($sdis1 + $d17)] } 
        if {$nc8status == 1} { set sdis1 [expr ($sdis1 + $d18)] } 
        if {$nc9status == 1} { set sdis1 [expr ($sdis1 + $d19)] }}
      
	
        if {$nc2status == 1} { if {$nc0status == 1} { set sdis2 [expr ($sdis2 + $d20)] } 
	if {$nc1status == 1} { set sdis2 [expr ($sdis2 + $d21)] }
	if {$nc3status == 1} { set sdis2 [expr ($sdis2 + $d23)] } 
        if {$nc4status == 1} { set sdis2 [expr ($sdis2 + $d24)] } 
        if {$nc5status == 1} { set sdis2 [expr ($sdis2 + $d25)] } 
        if {$nc6status == 1} { set sdis2 [expr ($sdis2 + $d26)] } 
        if {$nc7status == 1} { set sdis2 [expr ($sdis2 + $d27)] } 
        if {$nc8status == 1} { set sdis2 [expr ($sdis2 + $d28)] } 
        if {$nc9status == 1} { set sdis2 [expr ($sdis2 + $d29)] }} 
      
	
	if {$nc3status == 1} { if {$nc0status == 1} { set sdis3 [expr ($sdis3 + $d30)] } 
	if {$nc1status == 1} { set sdis3 [expr ($sdis3 + $d31)] }
	if {$nc2status == 1} { set sdis3 [expr ($sdis3 + $d32)] } 
        if {$nc4status == 1} { set sdis3 [expr ($sdis3 + $d34)] } 
        if {$nc5status == 1} { set sdis3 [expr ($sdis3 + $d35)] } 
        if {$nc6status == 1} { set sdis3 [expr ($sdis3 + $d36)] } 
        if {$nc7status == 1} { set sdis3 [expr ($sdis3 + $d37)] } 
        if {$nc8status == 1} { set sdis3 [expr ($sdis3 + $d38)] } 
        if {$nc9status == 1} { set sdis3 [expr ($sdis3 + $d39)] }} 
      

        if {$nc4status == 1} { if {$nc0status == 1} { set sdis4 [expr ($sdis4 + $d40)] } 
	if {$nc1status == 1} { set sdis4 [expr ($sdis4 + $d41)] }
	if {$nc2status == 1} { set sdis4 [expr ($sdis4 + $d42)] } 
        if {$nc3status == 1} { set sdis4 [expr ($sdis4 + $d43)] } 
        if {$nc5status == 1} { set sdis4 [expr ($sdis4 + $d45)] } 
        if {$nc6status == 1} { set sdis4 [expr ($sdis4 + $d46)] } 
        if {$nc7status == 1} { set sdis4 [expr ($sdis4 + $d47)] } 
        if {$nc8status == 1} { set sdis4 [expr ($sdis4 + $d48)] } 
        if {$nc9status == 1} { set sdis4 [expr ($sdis4 + $d49)] }} 
     

        if {$nc5status == 1} { if {$nc0status == 1} { set sdis5 [expr ($sdis5 + $d50)] } 
	if {$nc1status == 1} { set sdis5 [expr ($sdis5 + $d51)] }
	if {$nc2status == 1} { set sdis5 [expr ($sdis5 + $d52)] } 
        if {$nc3status == 1} { set sdis5 [expr ($sdis5 + $d53)] } 
        if {$nc4status == 1} { set sdis5 [expr ($sdis5 + $d54)] } 
        if {$nc6status == 1} { set sdis5 [expr ($sdis5 + $d56)] } 
        if {$nc7status == 1} { set sdis5 [expr ($sdis5 + $d57)] } 
        if {$nc8status == 1} { set sdis5 [expr ($sdis5 + $d58)] } 
        if {$nc9status == 1} { set sdis5 [expr ($sdis5 + $d59)] }} 
      

        if {$nc6status == 1} { if {$nc0status == 1} { set sdis6 [expr ($sdis6 + $d60)] } 
	if {$nc1status == 1} { set sdis6 [expr ($sdis6 + $d61)] }
	if {$nc2status == 1} { set sdis6 [expr ($sdis6 + $d62)] } 
        if {$nc3status == 1} { set sdis6 [expr ($sdis6 + $d63)] } 
        if {$nc4status == 1} { set sdis6 [expr ($sdis6 + $d64)] } 
        if {$nc5status == 1} { set sdis6 [expr ($sdis6 + $d65)] } 
        if {$nc7status == 1} { set sdis6 [expr ($sdis6 + $d67)] } 
        if {$nc8status == 1} { set sdis6 [expr ($sdis6 + $d68)] } 
        if {$nc9status == 1} { set sdis6 [expr ($sdis6 + $d69)] }} 
      

        if {$nc7status == 1} { if {$nc0status == 1} { set sdis7 [expr ($sdis7 + $d70)] } 
	if {$nc1status == 1} { set sdis7 [expr ($sdis7 + $d71)] }
	if {$nc2status == 1} { set sdis7 [expr ($sdis7 + $d72)] } 
        if {$nc3status == 1} { set sdis7 [expr ($sdis7 + $d73)] } 
        if {$nc4status == 1} { set sdis7 [expr ($sdis7 + $d74)] } 
        if {$nc5status == 1} { set sdis7 [expr ($sdis7 + $d75)] } 
        if {$nc6status == 1} { set sdis7 [expr ($sdis7 + $d76)] } 
        if {$nc8status == 1} { set sdis7 [expr ($sdis7 + $d78)] } 
        if {$nc9status == 1} { set sdis7 [expr ($sdis7 + $d79)] }} 
    

        if {$nc8status == 1} { if {$nc0status == 1} { set sdis8 [expr ($sdis8 + $d80)] } 
	if {$nc1status == 1} { set sdis8 [expr ($sdis8 + $d81)] }
	if {$nc2status == 1} { set sdis8 [expr ($sdis8 + $d82)] } 
        if {$nc3status == 1} { set sdis8 [expr ($sdis8 + $d83)] } 
        if {$nc4status == 1} { set sdis8 [expr ($sdis8 + $d84)] } 
        if {$nc5status == 1} { set sdis8 [expr ($sdis8 + $d85)] } 
        if {$nc6status == 1} { set sdis8 [expr ($sdis8 + $d86)] } 
        if {$nc7status == 1} { set sdis8 [expr ($sdis8 + $d87)] } 
        if {$nc9status == 1} { set sdis8 [expr ($sdis8 + $d89)] }} 
   

        if {$nc9status == 1} { if {$nc0status == 1} { set sdis9 [expr ($sdis9 + $d90)] } 
	if {$nc1status == 1} { set sdis9 [expr ($sdis9 + $d91)] }
	if {$nc2status == 1} { set sdis9 [expr ($sdis9 + $d92)] } 
        if {$nc3status == 1} { set sdis9 [expr ($sdis9 + $d93)] } 
        if {$nc4status == 1} { set sdis9 [expr ($sdis9 + $d94)] } 
        if {$nc5status == 1} { set sdis9 [expr ($sdis9 + $d95)] } 
        if {$nc6status == 1} { set sdis9 [expr ($sdis9 + $d96)] } 
        if {$nc7status == 1} { set sdis9 [expr ($sdis9 + $d97)] } 
        if {$nc8status == 1} { set sdis9 [expr ($sdis9 + $d98)] }} 
      
	
	if {$nc0status == 1 && $a != 0} { set sdis0 [expr ($sdis0)/$a] }
	if {$nc1status == 1 && $a != 0} { set sdis1 [expr ($sdis1)/$a] }
	if {$nc2status == 1 && $a != 0} { set sdis2 [expr ($sdis2)/$a] }
	if {$nc3status == 1 && $a != 0} { set sdis3 [expr ($sdis3)/$a] }
	if {$nc4status == 1 && $a != 0} { set sdis4 [expr ($sdis4)/$a] }
	if {$nc5status == 1 && $a != 0} { set sdis5 [expr ($sdis5)/$a] }
	if {$nc6status == 1 && $a != 0} { set sdis6 [expr ($sdis6)/$a] }
	if {$nc7status == 1 && $a != 0} { set sdis7 [expr ($sdis7)/$a] }
        if {$nc8status == 1 && $a != 0} { set sdis8 [expr ($sdis8)/$a] }
	if {$nc9status == 1 && $a != 0} { set sdis9 [expr ($sdis9)/$a] }
	
	
	if {$nc0status == 1 && $sdis0 != 0} { set nc0 [expr $e0/($sdis0*$sdis0)] } else { set ch 0}
	if {$nc1status == 1 && $sdis1 != 0} { set nc1 [expr $e1/($sdis1*$sdis1)] } else { set ch 0}
	if {$nc2status == 1 && $sdis2 != 0} { set nc2 [expr $e2/($sdis2*$sdis2)] } else { set ch 0}
	if {$nc3status == 1 && $sdis3 != 0} { set nc3 [expr $e3/($sdis3*$sdis3)] } else { set ch 0}
	if {$nc4status == 1 && $sdis4 != 0} { set nc4 [expr $e4/($sdis4*$sdis4)] } else { set ch 0}
	if {$nc5status == 1 && $sdis5 != 0} { set nc5 [expr $e5/($sdis5*$sdis5)] } else { set ch 0}
	if {$nc6status == 1 && $sdis6 != 0} { set nc6 [expr $e6/($sdis6*$sdis6)] } else { set ch 0}
	if {$nc7status == 1 && $sdis7 != 0} { set nc7 [expr $e7/($sdis7*$sdis7)] } else { set ch 0}
	if {$nc8status == 1 && $sdis8 != 0} { set nc8 [expr $e8/($sdis8*$sdis8)] } else { set ch 0}
	if {$nc9status == 1 && $sdis9 != 0} { set nc9 [expr $e9/($sdis9*$sdis9)] } else { set ch 0}

	set threshold [expr (($nc0 + $nc1 + $nc2 + $nc3 + $nc4 + $nc5 + $nc6 + $nc7 + $nc8 + $nc9)/$a)]
	set avgtotal [expr (($e0 + $e1 + $e2 + $e3 + $e4 + $e5 + $e6 + $e7 + $e8 + $e9)/$a)]
 

	puts " the Distance Mean of Node0 = $sdis0"
	puts " the Distance Mean of Node1 = $sdis1"
	puts " the Distance Mean of Node2 = $sdis2"
	puts " the Distance Mean of Node3 = $sdis3"
        puts " the Distance Mean of Node4 = $sdis4"
	puts " the Distance Mean of Node5 = $sdis5"
	puts " the Distance Mean of Node6 = $sdis6"
	puts " the Distance Mean of Node7 = $sdis7"
	puts " the Distance Mean of Node8 = $sdis8"
	puts " the Distance Mean of Node9 = $sdis9"
	        
	set sdisrat [expr ($sdis0 + $sdis1 + $sdis2 +$sdis3 + $sdis4 + $sdis5 + $sdis6 + $sdis7 + $sdis8 + $sdis9)/10]
	set erat [expr ($e0 + $e1 + $e2 + $e3 + $e4 + $e5 + $e6 + $e7 + $e8 + $e9)/10]
	
	puts " The Threshold Value - Node 0 = $nc0"
	puts " The Threshold Value - Node 1 = $nc1"
	puts " The Threshold Value - Node 2 = $nc2"
	puts " The Threshold Value - Node 3 = $nc3"
	puts " The Threshold Value - Node 4 = $nc4"
	puts " The Threshold Value - Node 5 = $nc5"
	puts " The Threshold Value - Node 6 = $nc6"
	puts " The Threshold Value - Node 7 = $nc7"
	puts " The Threshold Value - Node 8 = $nc8"
	puts " The Threshold Value - Node 9 = $nc9"
	
	if {$i == 0} { if {$ch == 0} { 
	if {$nc0 > $nc1 && $nc0 > $nc2 && $nc0 > $nc3 && $nc0 > $nc4 && $nc0 > $nc5 && 
            $nc0 > $nc6 && $nc0 > $nc7 && $nc0 > $nc8 && $nc0 > $nc9} { set ch $nc0
	set pcn 0}
	if {$nc1 > $nc0 && $nc1 > $nc2 && $nc1 > $nc3 && $nc1 > $nc4 && $nc1 > $nc5 &&
            $nc1 > $nc6 && $nc1 > $nc7 && $nc1 > $nc8 && $nc1 > $nc9} { set ch $nc1 
	set pcn 1}
	if {$nc2 > $nc0 && $nc2 > $nc1 && $nc2 > $nc3 && $nc2 > $nc4 && $nc2 > $nc5 &&
            $nc2 > $nc6 && $nc2 > $nc7 && $nc2 > $nc8 && $nc2 > $nc9} { set ch $nc2 
	set pcn 2}
	if {$nc3 > $nc0 && $nc3 > $nc1 && $nc3 > $nc2 && $nc3 > $nc4 && $nc3 > $nc5 &&
            $nc3 > $nc6 && $nc3 > $nc7 && $nc3 > $nc8 && $nc3 > $nc9} { set ch $nc3 
	set pcn 3}
	if {$nc4 > $nc0 && $nc4 > $nc1 && $nc4 > $nc2 && $nc4 > $nc3 && $nc4 > $nc5 && 
            $nc4 > $nc6 && $nc4 > $nc7 && $nc4 > $nc8 && $nc4 > $nc9} { set ch $nc4 
	set pcn 4}
	if {$nc5 > $nc0 && $nc5 > $nc1 && $nc5 > $nc2 && $nc5 > $nc3 && $nc5 > $nc4 && 
            $nc5 > $nc6 && $nc5 > $nc7 && $nc5 > $nc8 && $nc5 > $nc9} { set ch $nc5 
	set pcn 5}
	if {$nc6 > $nc0 && $nc6 > $nc1 && $nc6 > $nc2 && $nc6 > $nc3 && $nc6 > $nc4 && 
            $nc6 > $nc5 && $nc6 > $nc7 && $nc6 > $nc8 && $nc6 > $nc9} { set ch $nc6 
	set pcn 6}
	if {$nc7 > $nc0 && $nc7 > $nc1 && $nc7 > $nc2 && $nc7 > $nc3 && $nc7 > $nc4 && 
            $nc7 > $nc5 && $nc7 > $nc6 && $nc7 > $nc8 && $nc7 > $nc9} { set ch $nc7 
	set pcn 7}
	if {$nc8 > $nc0 && $nc8 > $nc1 && $nc8 > $nc2 && $nc8 > $nc3 && $nc8 > $nc4 && 
            $nc8 > $nc5 && $nc8 > $nc6 && $nc8 > $nc7 && $nc8 > $nc9} { set ch $nc8 
	set pcn 8}
	if {$nc9 > $nc0 && $nc9 > $nc1 && $nc9 > $nc2 && $nc9 > $nc3 && $nc9 > $nc4 && 
            $nc9 > $nc5 && $nc9 > $nc6 && $nc9 > $nc7 && $nc9 > $nc8} { set ch $nc9 
	set pcn 9} } }

	
	if {$pcn == 0} { set ch $nc0}
	if {$pcn == 1} { set ch $nc1}
	if {$pcn == 2} { set ch $nc2}
	if {$pcn == 3} { set ch $nc3}
	if {$pcn == 4} { set ch $nc4}
	if {$pcn == 5} { set ch $nc5}
	if {$pcn == 6} { set ch $nc6}
	if {$pcn == 7} { set ch $nc7}
	if {$pcn == 8} { set ch $nc8}
	if {$pcn == 9} { set ch $nc9}


	if {$i != 0 && $ch < $threshold} { 
	if {$nc0 > $nc1 && $nc0 > $nc2 && $nc0 > $nc3 && $nc0 > $nc4 && $nc0 > $nc5 && 
            $nc0 > $nc6 && $nc0 > $nc7 && $nc0 > $nc8 && $nc0 > $nc9} { set ch $nc0 
	set pcn 0}
	if {$nc1 > $nc0 && $nc1 > $nc2 && $nc1 > $nc3 && $nc1 > $nc4 && $nc1 > $nc5 &&
            $nc1 > $nc6 && $nc1 > $nc7 && $nc1 > $nc8 && $nc1 > $nc9} { set ch $nc1 
	set pcn 1}
	if {$nc2 > $nc0 && $nc2 > $nc1 && $nc2 > $nc3 && $nc2 > $nc4 && $nc2 > $nc5 &&
            $nc2 > $nc6 && $nc2 > $nc7 && $nc2 > $nc8 && $nc2 > $nc9} { set ch $nc2 
	set pcn 2}
	if {$nc3 > $nc0 && $nc3 > $nc1 && $nc3 > $nc2 && $nc3 > $nc4 && $nc3 > $nc5 &&
            $nc3 > $nc6 && $nc3 > $nc7 && $nc3 > $nc8 && $nc3 > $nc9} { set ch $nc3 
	set pcn 3}
	if {$nc4 > $nc0 && $nc4 > $nc1 && $nc4 > $nc2 && $nc4 > $nc3 && $nc4 > $nc5 && 
            $nc4 > $nc6 && $nc4 > $nc7 && $nc4 > $nc8 && $nc4 > $nc9} { set ch $nc4 
	set pcn 4}
	if {$nc5 > $nc0 && $nc5 > $nc1 && $nc5 > $nc2 && $nc5 > $nc3 && $nc5 > $nc4 && 
            $nc5 > $nc6 && $nc5 > $nc7 && $nc5 > $nc8 && $nc5 > $nc9} { set ch $nc5 
	set pcn 5}
	if {$nc6 > $nc0 && $nc6 > $nc1 && $nc6 > $nc2 && $nc6 > $nc3 && $nc6 > $nc4 && 
            $nc6 > $nc5 && $nc6 > $nc7 && $nc6 > $nc8 && $nc6 > $nc9} { set ch $nc6 
	set pcn 6}
	if {$nc7 > $nc0 && $nc7 > $nc1 && $nc7 > $nc2 && $nc7 > $nc3 && $nc7 > $nc4 && 
            $nc7 > $nc5 && $nc7 > $nc6 && $nc7 > $nc8 && $nc7 > $nc9} { set ch $nc7 
	set pcn 7}
	if {$nc8 > $nc0 && $nc8 > $nc1 && $nc8 > $nc2 && $nc8 > $nc3 && $nc8 > $nc4 && 
            $nc8 > $nc5 && $nc8 > $nc6 && $nc8 > $nc7 && $nc8 > $nc9} { set ch $nc8 
	set pcn 8}
	if {$nc9 > $nc0 && $nc9 > $nc1 && $nc9 > $nc2 && $nc9 > $nc3 && $nc9 > $nc4 && 
            $nc9 > $nc5 && $nc9 > $nc6 && $nc9 > $nc7 && $nc9 > $nc8} { set ch $nc9
	set pcn 9} }
	
	
	puts "The Cluster Head value is = $ch"
	
	if {$ch == $nc0} {puts "the Cluster Head is Node 0"}
	if {$ch == $nc1} {puts "the Cluster Head is Node 1"}
	if {$ch == $nc2} {puts "the Cluster Head is Node 2"}
	if {$ch == $nc3} {puts "the Cluster Head is Node 3"}
	if {$ch == $nc4} {puts "the Cluster Head is Node 4"}
	if {$ch == $nc5} {puts "the Cluster Head is Node 5"}
	if {$ch == $nc6} {puts "the Cluster Head is Node 6"}
	if {$ch == $nc7} {puts "the Cluster Head is Node 7"}
	if {$ch == $nc8} {puts "the Cluster Head is Node 8"}
	if {$ch == $nc9} {puts "the Cluster Head is Node 9"}
	
	
	
	#for node0
        if {$ch == $nc0} { $n0 color green	
	set tcp1 [$ns create-connection TCP $n1 TCPSink $n0 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 10
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n2 TCPSink $n0 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 10
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"
	
	set tcp1 [$ns create-connection TCP $n3 TCPSink $n0 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"
	
	set tcp1 [$ns create-connection TCP $n4 TCPSink $n0 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 10
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n5 TCPSink $n0 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 10
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n6 TCPSink $n0 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 10
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n7 TCPSink $n0 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 10
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n8 TCPSink $n0 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 10
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n9 TCPSink $n0 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 10
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"
	
        set dtr [expr ($sdisrat *100 + $sdisrat *100)]
	set tcp1 [$ns create-connection TCP $n0 TCPSink $n10 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ $dtr
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"
	
	#Setup a TCP connection
	set tcp [new Agent/TCP]
	$tcp set class_ 2
	$ns attach-agent $n1 $tcp
	$ns attach-agent $n2 $tcp
	$ns attach-agent $n3 $tcp
	$ns attach-agent $n4 $tcp
	$ns attach-agent $n5 $tcp
	$ns attach-agent $n6 $tcp
	$ns attach-agent $n7 $tcp
	$ns attach-agent $n8 $tcp
	$ns attach-agent $n9 $tcp
	set sink [new Agent/TCPSink]
	$ns attach-agent $n0 $sink
	$ns connect $tcp $sink
	$tcp set fid_ 1 
	
	#Setup a FTP over TCP connection
	set ftp [new Application/FTP]
	$ftp attach-agent $tcp
	$ftp set type_ FTP
	
	
	#Setup a UDP connection
	set udp [new Agent/UDP]
	$ns attach-agent $n1 $udp
	$ns attach-agent $n2 $udp
	$ns attach-agent $n3 $udp
	$ns attach-agent $n4 $udp
	$ns attach-agent $n5 $udp
	$ns attach-agent $n6 $udp
	$ns attach-agent $n7 $udp
	$ns attach-agent $n8 $udp
	$ns attach-agent $n9 $udp
	set null [new Agent/Null]
	$ns attach-agent $n0 $null
	$ns connect $udp $null
	$udp set fid_ 2
	
	if {$i != 0} { 
	set N [expr (($avgtotal*225)/2)]
	#set N [expr (($e0*50)/2)]
	set N [expr (round($N))]
	if {$N == 0} { set N 1} }
	puts "the value N is =$N"
	
	if {$nc1status != 0} { set e1 [expr ($e1-($N*(($packlen*$Eelec)+($packlen*$Efs*$d10*$d10)))-($cntrpackt*$Ech))] }
	if {$nc2status != 0} { set e2 [expr ($e2-($N*(($packlen*$Eelec)+($packlen*$Efs*$d20*$d20)))-($cntrpackt*$Ech))] }
	if {$nc3status != 0} { set e3 [expr ($e3-($N*(($packlen*$Eelec)+($packlen*$Efs*$d30*$d30)))-($cntrpackt*$Ech))] }
	if {$nc4status != 0} { set e4 [expr ($e4-($N*(($packlen*$Eelec)+($packlen*$Efs*$d40*$d40)))-($cntrpackt*$Ech))] }
	if {$nc5status != 0} { set e5 [expr ($e5-($N*(($packlen*$Eelec)+($packlen*$Efs*$d50*$d50)))-($cntrpackt*$Ech))] }
	if {$nc6status != 0} { set e6 [expr ($e6-($N*(($packlen*$Eelec)+($packlen*$Efs*$d60*$d60)))-($cntrpackt*$Ech))] }
	if {$nc7status != 0} { set e7 [expr ($e7-($N*(($packlen*$Eelec)+($packlen*$Efs*$d70*$d70)))-($cntrpackt*$Ech))] }
	if {$nc8status != 0} { set e8 [expr ($e8-($N*(($packlen*$Eelec)+($packlen*$Efs*$d80*$d80)))-($cntrpackt*$Ech))] }
	if {$nc9status != 0} { set e9 [expr ($e9-($N*(($packlen*$Eelec)+($packlen*$Efs*$d90*$d90)))-($cntrpackt*$Ech))] }
	if {$nc0status != 0} { set e0 [expr ($e0-($N*(($Eelec)*($cntrpackt)*($a-1)+ $Efs*$cntrpackt*($dist4mBS2node*$dist4mBS2node)+($a*$cntrpackt*$EDA)+($Eelec*$cntrpackt)))-((2*($a-1)+1)*$cntrpackt*$Ech))] }
	#if {$nc1status != 0} { set e1 [expr ($e1-($k*$Eelect+$k*$Efs*$d10*$d10+20*$Ech))] }
	#if {$nc2status != 0} { set e2 [expr ($e2-($k*$Eelect+$k*$Efs*$d20*$d20+20*$Ech))] }
	#if {$nc3status != 0} { set e3 [expr ($e3-($k*$Eelect+$k*$Efs*$d30*$d30+20*$Ech))] }
	#if {$nc4status != 0} { set e4 [expr ($e4-($k*$Eelect+$k*$Efs*$d40*$d40+20*$Ech))] }
	#if {$nc5status != 0} { set e5 [expr ($e5-($k*$Eelect+$k*$Efs*$d50*$d50+20*$Ech))] }
	#if {$nc6status != 0} { set e6 [expr ($e6-($k*$Eelect+$k*$Efs*$d60*$d60+20*$Ech))] }
	#if {$nc7status != 0} { set e7 [expr ($e7-($k*$Eelect+$k*$Efs*$d70*$d70+20*$Ech))] }
	#if {$nc8status != 0} { set e8 [expr ($e8-($k*$Eelect+$k*$Efs*$d80*$d80+20*$Ech))] }
	#if {$nc9status != 0} { set e9 [expr ($e9-($k*$Eelect+$k*$Efs*$d90*$d90+20*$Ech))] }
	#if {$nc0status != 0} { set e0 [expr ($e0-(9*($k*$Eelect)+20*$Ech))] }
	#if {$nc0status != 0} { set e0 [expr ($e0-($k*$Eelect+$k*$Efs*$dist4mBS2node*$dist4mBS2node+20*$Ech+$EDA))] }
	#if {$sdis0 != 0} { set ch [expr ($e0/($sdis0*$sdis0))] }

	if {$nc0status == 1 && $e0 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc0status 0
	set e0 0
	set nc0 0 }
	if {$nc1status == 1 && $e1 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc1status 0
	set e1 0
	set nc1 0 }
	if {$nc2status == 1 && $e2 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc2status 0
	set e2 0
	set nc2 0 }
	if {$nc3status == 1 && $e3 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc3status 0
	set e3 0
	set nc3 0 }
	if {$nc4status == 1 && $e4 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc4status 0
	set e4 0
	set nc4 0 }
	if {$nc5status == 1 && $e5 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc5status 0
	set e5 0
	set nc5 0 }
	if {$nc6status == 1 && $e6 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc6status 0
	set e6 0	
	set nc6 0 }
	if {$nc7status == 1 && $e7 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc7status 0
	set e7 0
	set nc7 0 }
	if {$nc8status == 1 && $e8 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc8status 0
	set e8 0
	set nc8 0 }
	if {$nc9status == 1 && $e9 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc9status 0
	set e9 0
	set nc9 0 }
	puts $f0 "$t $a"
	puts $f1 "$i $N" }
        
        #for node1
	if {$ch == $nc1} { $n1 color green	
	set tcp1 [$ns create-connection TCP $n0 TCPSink $n1 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 10
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n2 TCPSink $n1 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 10
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"
	
	set tcp1 [$ns create-connection TCP $n3 TCPSink $n1 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 10
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n4 TCPSink $n1 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 10
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n5 TCPSink $n1 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 10
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n6 TCPSink $n1 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 10
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n7 TCPSink $n1 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 10
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n8 TCPSink $n1 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 10
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n9 TCPSink $n1 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 10
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"
	
        set dtr [expr ($sdisrat *100 + $sdisrat *100)]
	set tcp1 [$ns create-connection TCP $n1 TCPSink $n10 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"
	
	#Setup a TCP connection
	set tcp [new Agent/TCP]
	$tcp set class_ 2
	$ns attach-agent $n0 $tcp
	$ns attach-agent $n2 $tcp
	$ns attach-agent $n3 $tcp
	$ns attach-agent $n4 $tcp
	$ns attach-agent $n5 $tcp
	$ns attach-agent $n6 $tcp
	$ns attach-agent $n7 $tcp
	$ns attach-agent $n8 $tcp
	$ns attach-agent $n9 $tcp
	set sink [new Agent/TCPSink]
	$ns attach-agent $n1 $sink
	$ns connect $tcp $sink
	$tcp set fid_ 1 
	
	#Setup a FTP over TCP connection
	set ftp [new Application/FTP]
	$ftp attach-agent $tcp
	$ftp set type_ FTP
	
	
	#Setup a UDP connection
	set udp [new Agent/UDP]
	$ns attach-agent $n0 $udp
	$ns attach-agent $n2 $udp
	$ns attach-agent $n3 $udp
	$ns attach-agent $n4 $udp
	$ns attach-agent $n5 $udp
	$ns attach-agent $n6 $udp
	$ns attach-agent $n7 $udp
	$ns attach-agent $n8 $udp
	$ns attach-agent $n9 $udp
	set null [new Agent/Null]
	$ns attach-agent $n1 $null
	$ns connect $udp $null
	$udp set fid_ 2 
	
	if {$i != 0} { 
	set N [expr (($avgtotal*225)/2)]
	#set N [expr (($e1*50)/2)]
	set N [expr (round($N))]
	if {$N == 0} { set N 1} }
	puts "the value N is =$N"

	if {$nc0status != 0} { set e0 [expr ($e0-($N*(($packlen*$Eelec)+($packlen*$Efs*$d01*$d01)))-($cntrpackt*$Ech))] }
	if {$nc2status != 0} { set e2 [expr ($e2-($N*(($packlen*$Eelec)+($packlen*$Efs*$d21*$d21)))-($cntrpackt*$Ech))] }
	if {$nc3status != 0} { set e3 [expr ($e3-($N*(($packlen*$Eelec)+($packlen*$Efs*$d31*$d31)))-($cntrpackt*$Ech))] }
	if {$nc4status != 0} { set e4 [expr ($e4-($N*(($packlen*$Eelec)+($packlen*$Efs*$d41*$d41)))-($cntrpackt*$Ech))] }
	if {$nc5status != 0} { set e5 [expr ($e5-($N*(($packlen*$Eelec)+($packlen*$Efs*$d51*$d51)))-($cntrpackt*$Ech))] }
	if {$nc6status != 0} { set e6 [expr ($e6-($N*(($packlen*$Eelec)+($packlen*$Efs*$d61*$d61)))-($cntrpackt*$Ech))] }
	if {$nc7status != 0} { set e7 [expr ($e7-($N*(($packlen*$Eelec)+($packlen*$Efs*$d71*$d71)))-($cntrpackt*$Ech))] }
	if {$nc8status != 0} { set e8 [expr ($e8-($N*(($packlen*$Eelec)+($packlen*$Efs*$d81*$d81)))-($cntrpackt*$Ech))] }
	if {$nc9status != 0} { set e9 [expr ($e9-($N*(($packlen*$Eelec)+($packlen*$Efs*$d91*$d91)))-($cntrpackt*$Ech))] }
	if {$nc1status != 0} { set e1 [expr ($e1-($N*(($Eelec)*($cntrpackt)*($a-1)+ $Efs*$cntrpackt*($dist4mBS2node*$dist4mBS2node)+($a*$cntrpackt*$EDA)+($Eelec*$cntrpackt)))-((2*($a-1)+1)*$cntrpackt*$Ech))] }
	#if {$nc0status != 0} { set e0 [expr ($e0-($k*$Eelect+$k*$Efs*$d01*$d01+20*$Ech))] }
	#if {$nc2status != 0} { set e2 [expr ($e2-($k*$Eelect+$k*$Efs*$d21*$d21+20*$Ech))] }
	#if {$nc3status != 0} { set e3 [expr ($e3-($k*$Eelect+$k*$Efs*$d31*$d31+20*$Ech))] }
	#if {$nc4status != 0} { set e4 [expr ($e4-($k*$Eelect+$k*$Efs*$d41*$d41+20*$Ech))] }
	#if {$nc5status != 0} { set e5 [expr ($e5-($k*$Eelect+$k*$Efs*$d51*$d51+20*$Ech))] }
	#if {$nc6status != 0} { set e6 [expr ($e6-($k*$Eelect+$k*$Efs*$d61*$d61+20*$Ech))] }
	#if {$nc7status != 0} { set e7 [expr ($e7-($k*$Eelect+$k*$Efs*$d71*$d71+20*$Ech))] }
	#if {$nc8status != 0} { set e8 [expr ($e8-($k*$Eelect+$k*$Efs*$d81*$d81+20*$Ech))] }
	#if {$nc9status != 0} { set e9 [expr ($e9-($k*$Eelect+$k*$Efs*$d91*$d91+20*$Ech))] }
	#if {$nc1status != 0} { set e1 [expr ($e1-(9*($k*$Eelect)+20*$Ech))] }
	#if {$nc1status != 0} { set e1 [expr ($e1-($k*$Eelect+$k*$Efs*$dist4mBS2node*$dist4mBS2node+20*$Ech+$EDA))] }
	#if {$sdis1 != 0} { set ch [expr ($e1/($sdis1*$sdis1))] }

	if {$nc0status == 1 && $e0 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc0status 0
	set e0 0
	set nc0 0 }
	if {$nc1status == 1 && $e1 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc1status 0
	set e1 0
	set nc1 0 }
	if {$nc2status == 1 && $e2 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc2status 0
	set e2 0
	set nc2 0 }
	if {$nc3status == 1 && $e3 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc3status 0
	set e3 0
	set nc3 0 }
	if {$nc4status == 1 && $e4 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc4status 0
	set e4 0
	set nc4 0 }
	if {$nc5status == 1 && $e5 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc5status 0
	set e5 0
	set nc5 0 }
	if {$nc6status == 1 && $e6 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc6status 0
	set e6 0
	set nc6 0 }
	if {$nc7status == 1 && $e7 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc7status 0
	set e7 0
	set nc7 0 }
	if {$nc8status == 1 && $e8 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc8status 0
	set e8 0
	set nc8 0 }
	if {$nc9status == 1 && $e9 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc9status 0
	set e9 0
	set nc9 0 }
	puts $f0 "$t $a"
	puts $f1 "$i $N" }

         
        #for node2
	if {$ch == $nc2} { $n2 color green	
	set tcp1 [$ns create-connection TCP $n0 TCPSink $n2 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 10
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n1 TCPSink $n2 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 10
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"
	
	set tcp1 [$ns create-connection TCP $n3 TCPSink $n2 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n4 TCPSink $n2 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n5 TCPSink $n2 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n6 TCPSink $n2 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n7 TCPSink $n2 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n8 TCPSink $n2 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n9 TCPSink $n2 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"
	
        set dtr [expr ($sdisrat *100 + $sdisrat *100)]
	set tcp1 [$ns create-connection TCP $n2 TCPSink $n10 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ $dtr
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"
	
	#Setup a TCP connection
	set tcp [new Agent/TCP]
	$tcp set class_ 2
	$ns attach-agent $n0 $tcp
	$ns attach-agent $n1 $tcp
	$ns attach-agent $n3 $tcp
	$ns attach-agent $n4 $tcp
	$ns attach-agent $n5 $tcp
	$ns attach-agent $n6 $tcp
	$ns attach-agent $n7 $tcp
	$ns attach-agent $n8 $tcp
	$ns attach-agent $n9 $tcp
	set sink [new Agent/TCPSink]
	$ns attach-agent $n2 $sink
	$ns connect $tcp $sink
	$tcp set fid_ 1	

	#Setup a FTP over TCP connection
	set ftp [new Application/FTP]
	$ftp attach-agent $tcp
	$ftp set type_ FTP
	
	
	#Setup a UDP connection
	set udp [new Agent/UDP]
	$ns attach-agent $n0 $udp
	$ns attach-agent $n1 $udp
	$ns attach-agent $n3 $udp
	$ns attach-agent $n4 $udp
	$ns attach-agent $n5 $udp
	$ns attach-agent $n6 $udp
	$ns attach-agent $n7 $udp
	$ns attach-agent $n8 $udp
	$ns attach-agent $n9 $udp
	set null [new Agent/Null]
	$ns attach-agent $n2 $null
	$ns connect $udp $null
	$udp set fid_ 2 
	
	if {$i != 0} { 
	set N [expr (($avgtotal*225)/2)]
	#set N [expr (($e2*50)/2)]
	set N [expr (round($N))]
	if {$N == 0} { set N 1} }
	puts "the value N is =$N"

	if {$nc0status != 0} { set e0 [expr ($e0-($N*(($packlen*$Eelec)+($packlen*$Efs*$d02*$d02)))-($cntrpackt*$Ech))] }
	if {$nc1status != 0} { set e1 [expr ($e1-($N*(($packlen*$Eelec)+($packlen*$Efs*$d12*$d12)))-($cntrpackt*$Ech))] }
	if {$nc3status != 0} { set e3 [expr ($e3-($N*(($packlen*$Eelec)+($packlen*$Efs*$d32*$d32)))-($cntrpackt*$Ech))] }
	if {$nc4status != 0} { set e4 [expr ($e4-($N*(($packlen*$Eelec)+($packlen*$Efs*$d42*$d42)))-($cntrpackt*$Ech))] }
	if {$nc5status != 0} { set e5 [expr ($e5-($N*(($packlen*$Eelec)+($packlen*$Efs*$d52*$d52)))-($cntrpackt*$Ech))] }
	if {$nc6status != 0} { set e6 [expr ($e6-($N*(($packlen*$Eelec)+($packlen*$Efs*$d62*$d62)))-($cntrpackt*$Ech))] }
	if {$nc7status != 0} { set e7 [expr ($e7-($N*(($packlen*$Eelec)+($packlen*$Efs*$d72*$d72)))-($cntrpackt*$Ech))] }
	if {$nc8status != 0} { set e8 [expr ($e8-($N*(($packlen*$Eelec)+($packlen*$Efs*$d82*$d82)))-($cntrpackt*$Ech))] }
	if {$nc9status != 0} { set e9 [expr ($e9-($N*(($packlen*$Eelec)+($packlen*$Efs*$d92*$d92)))-($cntrpackt*$Ech))] }
	if {$nc2status != 0} { set e2 [expr ($e2-($N*(($Eelec)*($cntrpackt)*($a-1)+ $Efs*$cntrpackt*($dist4mBS2node*$dist4mBS2node)+($a*$cntrpackt*$EDA)+($Eelec*$cntrpackt)))-((2*($a-1)+1)*$cntrpackt*$Ech))] }
	#if {$nc0status != 0} { set e0 [expr ($e0-($k*$Eelect+$k*$Efs*$d02*$d02+20*$Ech))] }
	#if {$nc1status != 0} { set e1 [expr ($e1-($k*$Eelect+$k*$Efs*$d12*$d12+20*$Ech))] }
	#if {$nc3status != 0} { set e3 [expr ($e3-($k*$Eelect+$k*$Efs*$d32*$d32+20*$Ech))] }
	#if {$nc4status != 0} { set e4 [expr ($e4-($k*$Eelect+$k*$Efs*$d42*$d42+20*$Ech))] }
	#if {$nc5status != 0} { set e5 [expr ($e5-($k*$Eelect+$k*$Efs*$d52*$d52+20*$Ech))] }
	#if {$nc6status != 0} { set e6 [expr ($e6-($k*$Eelect+$k*$Efs*$d62*$d62+20*$Ech))] }
	#if {$nc7status != 0} { set e7 [expr ($e7-($k*$Eelect+$k*$Efs*$d72*$d72+20*$Ech))] }
	#if {$nc8status != 0} { set e8 [expr ($e8-($k*$Eelect+$k*$Efs*$d82*$d82+20*$Ech))] }
	#if {$nc9status != 0} { set e9 [expr ($e9-($k*$Eelect+$k*$Efs*$d92*$d92+20*$Ech))] }
	#if {$nc2status != 0} { set e2 [expr ($e2-(9*($k*$Eelect)+20*$Ech))] }
	#if {$nc2status != 0} { set e2 [expr ($e2-($k*$Eelect+$k*$Efs*$dist4mBS2node*$dist4mBS2node+20*$Ech+$EDA))] }
	#if {$sdis2 != 0} { set ch [expr ($e2/($sdis2*$sdis2))] }

	if {$nc0status == 1 && $e0 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc0status 0
	set e0 0
	set nc0 0 }
	if {$nc1status == 1 && $e1 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc1status 0
	set e1 0
	set nc1 0 }
	if {$nc2status == 1 && $e2 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc2status 0
	set e2 0
	set nc2 0 }
	if {$nc3status == 1 && $e3 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc3status 0
	set e3 0
	set nc3 0 }
	if {$nc4status == 1 && $e4 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc4status 0
	set e4 0
	set nc4 0 }
	if {$nc5status == 1 && $e5 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc5status 0
	set e5 0
	set nc5 0 }
	if {$nc6status == 1 && $e6 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc6status 0
	set e6 0
	set nc6 0 }
	if {$nc7status == 1 && $e7 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc7status 0
	set e7 0
	set nc7 0 }
	if {$nc8status == 1 && $e8 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc8status 0
	set e8 0
	set nc8 0 }
	if {$nc9status == 1 && $e9 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc9status 0
	set e9 0
	set nc9 0 }
	puts $f0 "$t $a"
	puts $f1 "$i $N" }

        #for node3
	if {$ch == $nc3} { $n3 color green	
	set tcp1 [$ns create-connection TCP $n0 TCPSink $n3 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 10
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n1 TCPSink $n3 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 10
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"
	
	set tcp1 [$ns create-connection TCP $n2 TCPSink $n3 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n4 TCPSink $n3 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n5 TCPSink $n3 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n6 TCPSink $n3 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n7 TCPSink $n3 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n8 TCPSink $n3 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n9 TCPSink $n3 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"
	
        set dtr [expr ($sdisrat *100 + $sdisrat *100)]
	set tcp1 [$ns create-connection TCP $n3 TCPSink $n10 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ $dtr
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"
	
	#Setup a TCP connection
	set tcp [new Agent/TCP]
	$tcp set class_ 2
	$ns attach-agent $n0 $tcp
	$ns attach-agent $n1 $tcp
	$ns attach-agent $n2 $tcp
	$ns attach-agent $n4 $tcp
	$ns attach-agent $n5 $tcp
	$ns attach-agent $n6 $tcp
	$ns attach-agent $n7 $tcp
	$ns attach-agent $n8 $tcp
	$ns attach-agent $n9 $tcp
	set sink [new Agent/TCPSink]
	$ns attach-agent $n3 $sink
	$ns connect $tcp $sink
	$tcp set fid_ 1	

	#Setup a FTP over TCP connection
	set ftp [new Application/FTP]
	$ftp attach-agent $tcp
	$ftp set type_ FTP
	
	
	#Setup a UDP connection
	set udp [new Agent/UDP]
	$ns attach-agent $n0 $udp
	$ns attach-agent $n1 $udp
	$ns attach-agent $n2 $udp
	$ns attach-agent $n4 $udp
	$ns attach-agent $n5 $udp
	$ns attach-agent $n6 $udp
	$ns attach-agent $n7 $udp
	$ns attach-agent $n8 $udp
	$ns attach-agent $n9 $udp
	set null [new Agent/Null]
	$ns attach-agent $n3 $null
	$ns connect $udp $null
	$udp set fid_ 2 
	
	if {$i != 0} { 
	set N [expr (($avgtotal*225)/2)]
	#set N [expr (($e3*50)/2)]
	set N [expr (round($N))]
	if {$N == 0} { set N 1} }
	puts "the value N is =$N"
	
	if {$nc0status != 0} { set e0 [expr ($e0-($N*(($packlen*$Eelec)+($packlen*$Efs*$d03*$d03)))-($cntrpackt*$Ech))] }
	if {$nc1status != 0} { set e1 [expr ($e1-($N*(($packlen*$Eelec)+($packlen*$Efs*$d13*$d13)))-($cntrpackt*$Ech))] }
	if {$nc2status != 0} { set e2 [expr ($e2-($N*(($packlen*$Eelec)+($packlen*$Efs*$d23*$d23)))-($cntrpackt*$Ech))] }
	if {$nc4status != 0} { set e4 [expr ($e4-($N*(($packlen*$Eelec)+($packlen*$Efs*$d43*$d43)))-($cntrpackt*$Ech))] }
	if {$nc5status != 0} { set e5 [expr ($e5-($N*(($packlen*$Eelec)+($packlen*$Efs*$d53*$d53)))-($cntrpackt*$Ech))] }
	if {$nc6status != 0} { set e6 [expr ($e6-($N*(($packlen*$Eelec)+($packlen*$Efs*$d63*$d63)))-($cntrpackt*$Ech))] }
	if {$nc7status != 0} { set e7 [expr ($e7-($N*(($packlen*$Eelec)+($packlen*$Efs*$d73*$d73)))-($cntrpackt*$Ech))] }
	if {$nc8status != 0} { set e8 [expr ($e8-($N*(($packlen*$Eelec)+($packlen*$Efs*$d83*$d83)))-($cntrpackt*$Ech))] }
	if {$nc9status != 0} { set e9 [expr ($e9-($N*(($packlen*$Eelec)+($packlen*$Efs*$d93*$d93)))-($cntrpackt*$Ech))] }
	if {$nc3status != 0} { set e3 [expr ($e3-($N*(($Eelec)*($cntrpackt)*($a-1)+ $Efs*$cntrpackt*($dist4mBS2node*$dist4mBS2node)+($a*$cntrpackt*$EDA)+($Eelec*$cntrpackt)))-((2*($a-1)+1)*$cntrpackt*$Ech))] }
	#if {$nc0status != 0} { set e0 [expr ($e0-($k*$Eelect+$k*$Efs*$d03*$d03+20*$Ech))] }
	#if {$nc1status != 0} { set e1 [expr ($e1-($k*$Eelect+$k*$Efs*$d13*$d13+20*$Ech))] }
	#if {$nc2status != 0} { set e2 [expr ($e2-($k*$Eelect+$k*$Efs*$d23*$d23+20*$Ech))] }
	#if {$nc4status != 0} { set e4 [expr ($e4-($k*$Eelect+$k*$Efs*$d43*$d43+20*$Ech))] }
	#if {$nc5status != 0} { set e5 [expr ($e5-($k*$Eelect+$k*$Efs*$d53*$d53+20*$Ech))] }
	#if {$nc6status != 0} { set e6 [expr ($e6-($k*$Eelect+$k*$Efs*$d63*$d63+20*$Ech))] }
	#if {$nc7status != 0} { set e7 [expr ($e7-($k*$Eelect+$k*$Efs*$d73*$d73+20*$Ech))] }
	#if {$nc8status != 0} { set e8 [expr ($e8-($k*$Eelect+$k*$Efs*$d83*$d83+20*$Ech))] }
	#if {$nc9status != 0} { set e9 [expr ($e9-($k*$Eelect+$k*$Efs*$d93*$d93+20*$Ech))] }
	#if {$nc3status != 0} { set e3 [expr ($e3-(9*($k*$Eelect)+20*$Ech))] }
	#if {$nc3status != 0} { set e3 [expr ($e3-($k*$Eelect+$k*$Efs*$dist4mBS2node*$dist4mBS2node+20*$Ech+$EDA))] }
	#if {$sdis3 != 0} { set ch [expr ($e3/($sdis3*$sdis3))] }

	if {$nc0status == 1 && $e0 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc0status 0
	set e0 0
	set nc0 0 }
	if {$nc1status == 1 && $e1 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc1status 0
	set e1 0
	set nc1 0 }
	if {$nc2status == 1 && $e2 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc2status 0
	set e2 0
	set nc2 0 }
	if {$nc3status == 1 && $e3 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc3status 0
	set e3 0
	set nc3 0 }
	if {$nc4status == 1 && $e4 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc4status 0
	set e4 0
	set nc4 0 }
	if {$nc5status == 1 && $e5 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc5status 0
	set e5 0
	set nc5 0 }
	if {$nc6status == 1 && $e6 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc6status 0
	set e6 0
	set nc6 0 }
	if {$nc7status == 1 && $e7 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc7status 0
	set e7 0
	set nc7 0 }
	if {$nc8status == 1 && $e8 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc8status 0
	set e8 0
	set nc8 0 }
	if {$nc9status == 1 && $e9 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc9status 0
	set e9 0
	set nc9 0 }
	puts $f0 "$t $a"
	puts $f1 "$i $N" }

        #for node4
	if {$ch == $nc4} { $n4 color green	
	set tcp1 [$ns create-connection TCP $n0 TCPSink $n4 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 10
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n1 TCPSink $n4 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 10
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"
	
	set tcp1 [$ns create-connection TCP $n2 TCPSink $n4 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n3 TCPSink $n4 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n5 TCPSink $n4 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n6 TCPSink $n4 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n7 TCPSink $n4 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n8 TCPSink $n4 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n9 TCPSink $n4 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"
	
        set dtr [expr ($sdisrat *100 + $sdisrat *100)]
	set tcp1 [$ns create-connection TCP $n4 TCPSink $n10 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ $dtr
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"
	
	#Setup a TCP connection
	set tcp [new Agent/TCP]
	$tcp set class_ 2
	$ns attach-agent $n0 $tcp
	$ns attach-agent $n1 $tcp
	$ns attach-agent $n2 $tcp
	$ns attach-agent $n3 $tcp
	$ns attach-agent $n5 $tcp
	$ns attach-agent $n6 $tcp
	$ns attach-agent $n7 $tcp
	$ns attach-agent $n8 $tcp
	$ns attach-agent $n9 $tcp
	set sink [new Agent/TCPSink]
	$ns attach-agent $n4 $sink
	$ns connect $tcp $sink
	$tcp set fid_ 1 
	
	#Setup a FTP over TCP connection
	set ftp [new Application/FTP]
	$ftp attach-agent $tcp
	$ftp set type_ FTP
	
	
	#Setup a UDP connection
	set udp [new Agent/UDP]
	$ns attach-agent $n0 $udp
	$ns attach-agent $n1 $udp
	$ns attach-agent $n2 $udp
	$ns attach-agent $n3 $udp
	$ns attach-agent $n5 $udp
	$ns attach-agent $n6 $udp
	$ns attach-agent $n7 $udp
	$ns attach-agent $n8 $udp
	$ns attach-agent $n9 $udp
	set null [new Agent/Null]
	$ns attach-agent $n4 $null
	$ns connect $udp $null
	$udp set fid_ 2
	
	if {$i != 0} { 
	set N [expr (($avgtotal*225)/2)]
	#set N [expr (($e4*50)/2)]
	set N [expr (round($N))]
	if {$N == 0} { set N 1} }
	puts "the value N is =$N"
	
	if {$nc0status != 0} { set e0 [expr ($e0-($N*(($packlen*$Eelec)+($packlen*$Efs*$d04*$d04)))-($cntrpackt*$Ech))] }
	if {$nc1status != 0} { set e1 [expr ($e1-($N*(($packlen*$Eelec)+($packlen*$Efs*$d14*$d14)))-($cntrpackt*$Ech))] }
	if {$nc2status != 0} { set e2 [expr ($e2-($N*(($packlen*$Eelec)+($packlen*$Efs*$d24*$d24)))-($cntrpackt*$Ech))] }
	if {$nc3status != 0} { set e3 [expr ($e3-($N*(($packlen*$Eelec)+($packlen*$Efs*$d34*$d34)))-($cntrpackt*$Ech))] }
	if {$nc5status != 0} { set e5 [expr ($e5-($N*(($packlen*$Eelec)+($packlen*$Efs*$d54*$d54)))-($cntrpackt*$Ech))] }
	if {$nc6status != 0} { set e6 [expr ($e6-($N*(($packlen*$Eelec)+($packlen*$Efs*$d64*$d64)))-($cntrpackt*$Ech))] }
	if {$nc7status != 0} { set e7 [expr ($e7-($N*(($packlen*$Eelec)+($packlen*$Efs*$d74*$d74)))-($cntrpackt*$Ech))] }
	if {$nc8status != 0} { set e8 [expr ($e8-($N*(($packlen*$Eelec)+($packlen*$Efs*$d84*$d84)))-($cntrpackt*$Ech))] }
	if {$nc9status != 0} { set e9 [expr ($e9-($N*(($packlen*$Eelec)+($packlen*$Efs*$d94*$d94)))-($cntrpackt*$Ech))] }
	if {$nc4status != 0} { set e4 [expr ($e4-($N*(($Eelec)*($cntrpackt)*($a-1)+ $Efs*$cntrpackt*($dist4mBS2node*$dist4mBS2node)+($a*$cntrpackt*$EDA)+($Eelec*$cntrpackt)))-((2*($a-1)+1)*$cntrpackt*$Ech))] }
	#if {$nc0status != 0} { set e0 [expr ($e0-($k*$Eelect+$k*$Efs*$d04*$d04+20*$Ech))] }
	#if {$nc1status != 0} { set e1 [expr ($e1-($k*$Eelect+$k*$Efs*$d14*$d14+20*$Ech))] }
	#if {$nc2status != 0} { set e2 [expr ($e2-($k*$Eelect+$k*$Efs*$d24*$d24+20*$Ech))] }
	#if {$nc3status != 0} { set e3 [expr ($e3-($k*$Eelect+$k*$Efs*$d34*$d34+20*$Ech))] }
	#if {$nc5status != 0} { set e5 [expr ($e5-($k*$Eelect+$k*$Efs*$d54*$d54+20*$Ech))] }
	#if {$nc6status != 0} { set e6 [expr ($e6-($k*$Eelect+$k*$Efs*$d64*$d64+20*$Ech))] }
	#if {$nc7status != 0} { set e7 [expr ($e7-($k*$Eelect+$k*$Efs*$d74*$d74+20*$Ech))] }
	#if {$nc8status != 0} { set e8 [expr ($e8-($k*$Eelect+$k*$Efs*$d84*$d84+20*$Ech))] }
	#if {$nc9status != 0} { set e9 [expr ($e9-($k*$Eelect+$k*$Efs*$d94*$d94+20*$Ech))] }
	#if {$nc4status != 0} { set e4 [expr ($e4-(9*($k*$Eelect)+20*$Ech))] }
	#if {$nc4status != 0} { set e4 [expr ($e4-($k*$Eelect+$k*$Efs*$dist4mBS2node*$dist4mBS2node+20*$Ech+$EDA))] }
	#if {$sdis4 != 0} { set ch [expr ($e4/($sdis4*$sdis4))] }

	if {$nc0status == 1 && $e0 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc0status 0
	set e0 0
	set nc0 0 }
	if {$nc1status == 1 && $e1 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc1status 0
	set e1 0
	set nc1 0 }
	if {$nc2status == 1 && $e2 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc2status 0
	set e2 0
	set nc2 0 }
	if {$nc3status == 1 && $e3 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc3status 0
	set e3 0
	set nc3 0 }
	if {$nc4status == 1 && $e4 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc4status 0
	set e4 0
	set nc4 0 }
	if {$nc5status == 1 && $e5 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc5status 0
	set e5 0
	set nc5 0 }
	if {$nc6status == 1 && $e6 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc6status 0
	set e6 0
	set nc6 0 }
	if {$nc7status == 1 && $e7 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc7status 0
	set e7 0
	set nc7 0 }
	if {$nc8status == 1 && $e8 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc8status 0
	set e8 0
	set nc8 0 }
	if {$nc9status == 1 && $e9 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc9status 0
	set e9 0
	set nc9 0 }
	puts $f0 "$t $a"
	puts $f1 "$i $N" }

        #for node5
	if {$ch == $nc5} { $n5 color green	
	set tcp1 [$ns create-connection TCP $n0 TCPSink $n5 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 10
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n1 TCPSink $n5 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 10
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"
	
	set tcp1 [$ns create-connection TCP $n2 TCPSink $n5 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n3 TCPSink $n5 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n4 TCPSink $n5 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n6 TCPSink $n5 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n7 TCPSink $n5 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n8 TCPSink $n5 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n9 TCPSink $n5 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"
	
        set dtr [expr ($sdisrat *100 + $sdisrat *100)]
	set tcp1 [$ns create-connection TCP $n5 TCPSink $n10 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ $dtr
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"
	
	#Setup a TCP connection
	set tcp [new Agent/TCP]
	$tcp set class_ 2
	$ns attach-agent $n0 $tcp
	$ns attach-agent $n1 $tcp
	$ns attach-agent $n2 $tcp
	$ns attach-agent $n3 $tcp
	$ns attach-agent $n4 $tcp
	$ns attach-agent $n6 $tcp
	$ns attach-agent $n7 $tcp
	$ns attach-agent $n8 $tcp
	$ns attach-agent $n9 $tcp
	set sink [new Agent/TCPSink]
	$ns attach-agent $n5 $sink
	$ns connect $tcp $sink
	$tcp set fid_ 1 
	
	#Setup a FTP over TCP connection
	set ftp [new Application/FTP]
	$ftp attach-agent $tcp
	$ftp set type_ FTP
	
	
	#Setup a UDP connection
	set udp [new Agent/UDP]
	$ns attach-agent $n0 $udp
	$ns attach-agent $n1 $udp
	$ns attach-agent $n2 $udp
	$ns attach-agent $n3 $udp
	$ns attach-agent $n4 $udp
	$ns attach-agent $n6 $udp
	$ns attach-agent $n7 $udp
	$ns attach-agent $n8 $udp
	$ns attach-agent $n9 $udp
	set null [new Agent/Null]
	$ns attach-agent $n5 $null
	$ns connect $udp $null
	$udp set fid_ 2
	
	if {$i != 0} { 
	set N [expr (($avgtotal*225)/2)]
	#set N [expr (($e5*50)/2)]
	set N [expr (round($N))]
	if {$N == 0} { set N 1} }
	puts "the value N is =$N"

	if {$nc0status != 0} { set e0 [expr ($e0-($N*(($packlen*$Eelec)+($packlen*$Efs*$d05*$d05)))-($cntrpackt*$Ech))] }
	if {$nc1status != 0} { set e1 [expr ($e1-($N*(($packlen*$Eelec)+($packlen*$Efs*$d15*$d15)))-($cntrpackt*$Ech))] }
	if {$nc2status != 0} { set e2 [expr ($e2-($N*(($packlen*$Eelec)+($packlen*$Efs*$d25*$d25)))-($cntrpackt*$Ech))] }
	if {$nc3status != 0} { set e3 [expr ($e3-($N*(($packlen*$Eelec)+($packlen*$Efs*$d35*$d35)))-($cntrpackt*$Ech))] }
	if {$nc4status != 0} { set e4 [expr ($e4-($N*(($packlen*$Eelec)+($packlen*$Efs*$d45*$d45)))-($cntrpackt*$Ech))] }
	if {$nc6status != 0} { set e6 [expr ($e6-($N*(($packlen*$Eelec)+($packlen*$Efs*$d65*$d65)))-($cntrpackt*$Ech))] }
	if {$nc7status != 0} { set e7 [expr ($e7-($N*(($packlen*$Eelec)+($packlen*$Efs*$d75*$d75)))-($cntrpackt*$Ech))] }
	if {$nc8status != 0} { set e8 [expr ($e8-($N*(($packlen*$Eelec)+($packlen*$Efs*$d85*$d85)))-($cntrpackt*$Ech))] }
	if {$nc9status != 0} { set e9 [expr ($e9-($N*(($packlen*$Eelec)+($packlen*$Efs*$d95*$d95)))-($cntrpackt*$Ech))] }
	if {$nc5status != 0} { set e5 [expr ($e5-($N*(($Eelec)*($cntrpackt)*($a-1)+ $Efs*$cntrpackt*($dist4mBS2node*$dist4mBS2node)+($a*$cntrpackt*$EDA)+($Eelec*$cntrpackt)))-((2*($a-1)+1)*$cntrpackt*$Ech))] }
	#if {$nc0status != 0} { set e0 [expr ($e0-($k*$Eelect+$k*$Efs*$d05*$d05+20*$Ech))] }
	#if {$nc1status != 0} { set e1 [expr ($e1-($k*$Eelect+$k*$Efs*$d15*$d15+20*$Ech))] }
	#if {$nc2status != 0} { set e2 [expr ($e2-($k*$Eelect+$k*$Efs*$d25*$d25+20*$Ech))] }
	#if {$nc3status != 0} { set e3 [expr ($e3-($k*$Eelect+$k*$Efs*$d35*$d35+20*$Ech))] }
	#if {$nc4status != 0} { set e4 [expr ($e4-($k*$Eelect+$k*$Efs*$d45*$d45+20*$Ech))] }
	#if {$nc6status != 0} { set e6 [expr ($e6-($k*$Eelect+$k*$Efs*$d65*$d65+20*$Ech))] }
	#if {$nc7status != 0} { set e7 [expr ($e7-($k*$Eelect+$k*$Efs*$d75*$d75+20*$Ech))] }
	#if {$nc8status != 0} { set e8 [expr ($e8-($k*$Eelect+$k*$Efs*$d85*$d85+20*$Ech))] }
	#if {$nc9status != 0} { set e9 [expr ($e9-($k*$Eelect+$k*$Efs*$d95*$d95+20*$Ech))] }
	#if {$nc5status != 0} { set e5 [expr ($e5-(9*($k*$Eelect)+20*$Ech))] }
	#if {$nc5status != 0} { set e5 [expr ($e5-($k*$Eelect+$k*$Efs*$dist4mBS2node*$dist4mBS2node+20*$Ech+$EDA))] }
	#if {$sdis5 != 0} { set ch [expr ($e5/($sdis5*$sdis5))] }

	if {$nc0status == 1 && $e0 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc0status 0
	set e0 0
	set nc0 0 }
	if {$nc1status == 1 && $e1 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc1status 0
	set e1 0
	set nc1 0 }
	if {$nc2status == 1 && $e2 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc2status 0
	set e2 0
	set nc2 0 }
	if {$nc3status == 1 && $e3 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc3status 0
	set e3 0
	set nc3 0 }
	if {$nc4status == 1 && $e4 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc4status 0
	set e4 0
	set nc4 0 }
	if {$nc5status == 1 && $e5 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc5status 0
	set e5 0
	set nc5 0 }
	if {$nc6status == 1 && $e6 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc6status 0
	set e6 0
	set nc6 0 }
	if {$nc7status == 1 && $e7 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc7status 0
	set e7 0
	set nc7 0 }
	if {$nc8status == 1 && $e8 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc8status 0
	set e8 0
	set nc8 0 }
	if {$nc9status == 1 && $e9 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc9status 0
	set e9 0
	set nc9 0 }
	puts $f0 "$t $a"
	puts $f1 "$i $N" }

        #for node6
	if {$ch == $nc6} { $n6 color green	
	set tcp1 [$ns create-connection TCP $n0 TCPSink $n6 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 10
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n1 TCPSink $n6 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 10
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"
	
	set tcp1 [$ns create-connection TCP $n2 TCPSink $n6 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n3 TCPSink $n6 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n4 TCPSink $n6 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n5 TCPSink $n6 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n7 TCPSink $n6 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n8 TCPSink $n6 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n9 TCPSink $n6 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"
	
        set dtr [expr ($sdisrat *100 + $sdisrat *100)]
	set tcp1 [$ns create-connection TCP $n6 TCPSink $n10 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ $dtr
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"
	
	#Setup a TCP connection
	set tcp [new Agent/TCP]
	$tcp set class_ 2
	$ns attach-agent $n0 $tcp
	$ns attach-agent $n1 $tcp
	$ns attach-agent $n2 $tcp
	$ns attach-agent $n3 $tcp
	$ns attach-agent $n4 $tcp
	$ns attach-agent $n5 $tcp
	$ns attach-agent $n7 $tcp
	$ns attach-agent $n8 $tcp
	$ns attach-agent $n9 $tcp
	set sink [new Agent/TCPSink]
	$ns attach-agent $n6 $sink
	$ns connect $tcp $sink
	$tcp set fid_ 1 
	
	#Setup a FTP over TCP connection
	set ftp [new Application/FTP]
	$ftp attach-agent $tcp
	$ftp set type_ FTP
	
	
	#Setup a UDP connection
	set udp [new Agent/UDP]
	$ns attach-agent $n0 $udp
	$ns attach-agent $n1 $udp
	$ns attach-agent $n2 $udp
	$ns attach-agent $n3 $udp
	$ns attach-agent $n4 $udp
	$ns attach-agent $n5 $udp
	$ns attach-agent $n7 $udp
	$ns attach-agent $n8 $udp
	$ns attach-agent $n9 $udp
	set null [new Agent/Null]
	$ns attach-agent $n6 $null
	$ns connect $udp $null
	$udp set fid_ 2
	
	if {$i != 0} { 
	set N [expr (($avgtotal*225)/2)]
	#set N [expr (($e6*50)/2)]
	set N [expr (round($N))]
	if {$N == 0} { set N 1} }
	puts "the value N is =$N"

	if {$nc0status != 0} { set e0 [expr ($e0-($N*(($packlen*$Eelec)+($packlen*$Efs*$d06*$d06)))-($cntrpackt*$Ech))] }
	if {$nc1status != 0} { set e1 [expr ($e1-($N*(($packlen*$Eelec)+($packlen*$Efs*$d16*$d16)))-($cntrpackt*$Ech))] }
	if {$nc2status != 0} { set e2 [expr ($e2-($N*(($packlen*$Eelec)+($packlen*$Efs*$d26*$d26)))-($cntrpackt*$Ech))] }
	if {$nc3status != 0} { set e3 [expr ($e3-($N*(($packlen*$Eelec)+($packlen*$Efs*$d36*$d36)))-($cntrpackt*$Ech))] }
	if {$nc4status != 0} { set e4 [expr ($e4-($N*(($packlen*$Eelec)+($packlen*$Efs*$d46*$d46)))-($cntrpackt*$Ech))] }
	if {$nc5status != 0} { set e5 [expr ($e5-($N*(($packlen*$Eelec)+($packlen*$Efs*$d56*$d56)))-($cntrpackt*$Ech))] }
	if {$nc7status != 0} { set e7 [expr ($e7-($N*(($packlen*$Eelec)+($packlen*$Efs*$d76*$d76)))-($cntrpackt*$Ech))] }
	if {$nc8status != 0} { set e8 [expr ($e8-($N*(($packlen*$Eelec)+($packlen*$Efs*$d86*$d86)))-($cntrpackt*$Ech))] }
	if {$nc9status != 0} { set e9 [expr ($e9-($N*(($packlen*$Eelec)+($packlen*$Efs*$d96*$d96)))-($cntrpackt*$Ech))] }
	if {$nc6status != 0} { set e6 [expr ($e6-($N*(($Eelec)*($cntrpackt)*($a-1)+ $Efs*$cntrpackt*($dist4mBS2node*$dist4mBS2node)+($a*$cntrpackt*$EDA)+($Eelec*$cntrpackt)))-((2*($a-1)+1)*$cntrpackt*$Ech))] }
	#if {$nc0status != 0} { set e0 [expr ($e0-($k*$Eelect+$k*$Efs*$d06*$d06+20*$Ech))] }
	#if {$nc1status != 0} { set e1 [expr ($e1-($k*$Eelect+$k*$Efs*$d16*$d16+20*$Ech))] }
	#if {$nc2status != 0} { set e2 [expr ($e2-($k*$Eelect+$k*$Efs*$d26*$d26+20*$Ech))] }
	#if {$nc3status != 0} { set e3 [expr ($e3-($k*$Eelect+$k*$Efs*$d36*$d36+20*$Ech))] }
	#if {$nc4status != 0} { set e4 [expr ($e4-($k*$Eelect+$k*$Efs*$d46*$d46+20*$Ech))] }
	#if {$nc5status != 0} { set e5 [expr ($e5-($k*$Eelect+$k*$Efs*$d56*$d56+20*$Ech))] }
	#if {$nc7status != 0} { set e7 [expr ($e7-($k*$Eelect+$k*$Efs*$d76*$d76+20*$Ech))] }
	#if {$nc8status != 0} { set e8 [expr ($e8-($k*$Eelect+$k*$Efs*$d86*$d86+20*$Ech))] }
	#if {$nc9status != 0} { set e9 [expr ($e9-($k*$Eelect+$k*$Efs*$d96*$d96+20*$Ech))] }
	#if {$nc6status != 0} { set e6 [expr ($e6-(9*($k*$Eelect)+20*$Ech))] }
	#if {$nc6status != 0} { set e6 [expr ($e6-($k*$Eelect+$k*$Efs*$dist4mBS2node*$dist4mBS2node+20*$Ech+$EDA))] }
	#if {$sdis6 != 0} { set ch [expr ($e6/($sdis6*$sdis6))] }

	if {$nc0status == 1 && $e0 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc0status 0
	set e0 0
	set nc0 0 }
	if {$nc1status == 1 && $e1 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc1status 0
	set e1 0
	set nc1 0 }
	if {$nc2status == 1 && $e2 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc2status 0
	set e2 0
	set nc2 0 }
	if {$nc3status == 1 && $e3 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc3status 0
	set e3 0
	set nc3 0 }
	if {$nc4status == 1 && $e4 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc4status 0
	set e4 0
	set nc4 0 }
	if {$nc5status == 1 && $e5 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc5status 0
	set e5 0
	set nc5 0 }
	if {$nc6status == 1 && $e6 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc6status 0
	set e6 0
	set nc6 0 }
	if {$nc7status == 1 && $e7 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc7status 0
	set e7 0
	set nc7 0 }
	if {$nc8status == 1 && $e8 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc8status 0
	set e8 0
	set nc8 0 }
	if {$nc9status == 1 && $e9 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc9status 0
	set e9 0
	set nc9 0 }
	puts $f0 "$t $a"
	puts $f1 "$i $N" }

        #for node7
	if {$ch == $nc7} { $n7 color green	
	set tcp1 [$ns create-connection TCP $n0 TCPSink $n7 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 10
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n1 TCPSink $n7 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 10
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"
	
	set tcp1 [$ns create-connection TCP $n2 TCPSink $n7 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n3 TCPSink $n7 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n4 TCPSink $n7 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n5 TCPSink $n7 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n6 TCPSink $n7 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n8 TCPSink $n7 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n9 TCPSink $n7 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"
	
        set dtr [expr ($sdisrat *100 + $sdisrat *100)]
	set tcp1 [$ns create-connection TCP $n7 TCPSink $n10 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ $dtr
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"
	
	#Setup a TCP connection
	set tcp [new Agent/TCP]
	$tcp set class_ 2
	$ns attach-agent $n0 $tcp
	$ns attach-agent $n1 $tcp
	$ns attach-agent $n2 $tcp
	$ns attach-agent $n3 $tcp
	$ns attach-agent $n4 $tcp
	$ns attach-agent $n5 $tcp
	$ns attach-agent $n6 $tcp
	$ns attach-agent $n8 $tcp
	$ns attach-agent $n9 $tcp
	set sink [new Agent/TCPSink]
	$ns attach-agent $n7 $sink
	$ns connect $tcp $sink
	$tcp set fid_ 1 
	
	#Setup a FTP over TCP connection
	set ftp [new Application/FTP]
	$ftp attach-agent $tcp
	$ftp set type_ FTP
	
	
	#Setup a UDP connection
	set udp [new Agent/UDP]
	$ns attach-agent $n0 $udp
	$ns attach-agent $n1 $udp
	$ns attach-agent $n2 $udp
	$ns attach-agent $n3 $udp
	$ns attach-agent $n4 $udp
	$ns attach-agent $n5 $udp
	$ns attach-agent $n6 $udp
	$ns attach-agent $n8 $udp
	$ns attach-agent $n9 $udp
	set null [new Agent/Null]
	$ns attach-agent $n7 $null
	$ns connect $udp $null
	$udp set fid_ 2
	

	if {$i != 0} { 
	set N [expr (($avgtotal*225)/2)]
	#set N [expr (($e7*50)/2)]
	set N [expr (round($N))]
	if {$N == 0} { set N 1} }
	puts "the value N is =$N"

	if {$nc0status != 0} { set e0 [expr ($e0-($N*(($packlen*$Eelec)+($packlen*$Efs*$d07*$d07)))-($cntrpackt*$Ech))] }
	if {$nc1status != 0} { set e1 [expr ($e1-($N*(($packlen*$Eelec)+($packlen*$Efs*$d17*$d17)))-($cntrpackt*$Ech))] }
	if {$nc2status != 0} { set e2 [expr ($e2-($N*(($packlen*$Eelec)+($packlen*$Efs*$d27*$d27)))-($cntrpackt*$Ech))] }
	if {$nc3status != 0} { set e3 [expr ($e3-($N*(($packlen*$Eelec)+($packlen*$Efs*$d37*$d37)))-($cntrpackt*$Ech))] }
	if {$nc4status != 0} { set e4 [expr ($e4-($N*(($packlen*$Eelec)+($packlen*$Efs*$d47*$d47)))-($cntrpackt*$Ech))] }
	if {$nc5status != 0} { set e5 [expr ($e5-($N*(($packlen*$Eelec)+($packlen*$Efs*$d57*$d57)))-($cntrpackt*$Ech))] }
	if {$nc6status != 0} { set e6 [expr ($e6-($N*(($packlen*$Eelec)+($packlen*$Efs*$d67*$d67)))-($cntrpackt*$Ech))] }
	if {$nc8status != 0} { set e8 [expr ($e8-($N*(($packlen*$Eelec)+($packlen*$Efs*$d87*$d87)))-($cntrpackt*$Ech))] }
	if {$nc9status != 0} { set e9 [expr ($e9-($N*(($packlen*$Eelec)+($packlen*$Efs*$d97*$d97)))-($cntrpackt*$Ech))] }
	if {$nc7status != 0} { set e7 [expr ($e7-($N*(($Eelec)*($cntrpackt)*($a-1)+ $Efs*$cntrpackt*($dist4mBS2node*$dist4mBS2node)+($a*$cntrpackt*$EDA)+($Eelec*$cntrpackt)))-((2*($a-1)+1)*$cntrpackt*$Ech))] }
	#if {$nc0status != 0} { set e0 [expr ($e0-($k*$Eelect+$k*$Efs*$d07*$d07+20*$Ech))] }
	#if {$nc1status != 0} { set e1 [expr ($e1-($k*$Eelect+$k*$Efs*$d17*$d17+20*$Ech))] }
	#if {$nc2status != 0} { set e2 [expr ($e2-($k*$Eelect+$k*$Efs*$d27*$d27+20*$Ech))] }
	#if {$nc3status != 0} { set e3 [expr ($e3-($k*$Eelect+$k*$Efs*$d37*$d37+20*$Ech))] }
	#if {$nc4status != 0} { set e4 [expr ($e4-($k*$Eelect+$k*$Efs*$d47*$d47+20*$Ech))] }
	#if {$nc5status != 0} { set e5 [expr ($e5-($k*$Eelect+$k*$Efs*$d57*$d57+20*$Ech))] }
	#if {$nc6status != 0} { set e6 [expr ($e6-($k*$Eelect+$k*$Efs*$d67*$d67+20*$Ech))] }
	#if {$nc8status != 0} { set e8 [expr ($e8-($k*$Eelect+$k*$Efs*$d87*$d87+20*$Ech))] }
	#if {$nc9status != 0} { set e9 [expr ($e9-($k*$Eelect+$k*$Efs*$d97*$d97+20*$Ech))] }
	#if {$nc7status != 0} { set e7 [expr ($e7-(9*($k*$Eelect)+20*$Ech))] }
	#if {$nc7status != 0} { set e7 [expr ($e7-($k*$Eelect+$k*$Efs*$dist4mBS2node*$dist4mBS2node+20*$Ech+$EDA))] }
	#if {$sdis7 != 0} { set ch [expr ($e7/($sdis7*$sdis7))] }

	if {$nc0status == 1 && $e0 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc0status 0
	set e0 0
	set nc0 0 }
	if {$nc1status == 1 && $e1 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc1status 0
	set e1 0
	set nc1 0 }
	if {$nc2status == 1 && $e2 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc2status 0
	set e2 0
	set nc2 0 }
	if {$nc3status == 1 && $e3 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc3status 0
	set e3 0
	set nc3 0 }
	if {$nc4status == 1 && $e4 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc4status 0
	set e4 0
	set nc4 0 }
	if {$nc5status == 1 && $e5 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc5status 0
	set e5 0
	set nc5 0 }
	if {$nc6status == 1 && $e6 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc6status 0
	set e6 0
	set nc6 0 }
	if {$nc7status == 1 && $e7 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc7status 0
	set e7 0
	set nc7 0 }
	if {$nc8status == 1 && $e8 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc8status 0
	set e8 0
	set nc8 0 }
	if {$nc9status == 1 && $e9 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc9status 0
	set e9 0
	set nc9 0 }
	puts $f0 "$t $a"
	puts $f1 "$i $N" }

        #for node8
	if {$ch == $nc8} { $n8 color green	
	set tcp1 [$ns create-connection TCP $n0 TCPSink $n8 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 10
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n1 TCPSink $n8 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 10
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"
	
	set tcp1 [$ns create-connection TCP $n2 TCPSink $n8 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n3 TCPSink $n8 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n4 TCPSink $n8 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n5 TCPSink $n8 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n6 TCPSink $n8 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n7 TCPSink $n8 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n9 TCPSink $n8 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"
	
        set dtr [expr ($sdisrat *100 + $sdisrat *100)]
	set tcp1 [$ns create-connection TCP $n8 TCPSink $n10 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ $dtr
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"
	
	#Setup a TCP connection
	set tcp [new Agent/TCP]
	$tcp set class_ 2
	$ns attach-agent $n0 $tcp
	$ns attach-agent $n1 $tcp
	$ns attach-agent $n2 $tcp
	$ns attach-agent $n3 $tcp
	$ns attach-agent $n4 $tcp
	$ns attach-agent $n5 $tcp
	$ns attach-agent $n6 $tcp
	$ns attach-agent $n7 $tcp
	$ns attach-agent $n9 $tcp
	set sink [new Agent/TCPSink]
	$ns attach-agent $n8 $sink
	$ns connect $tcp $sink
	$tcp set fid_ 1 
	
	#Setup a FTP over TCP connection
	set ftp [new Application/FTP]
	$ftp attach-agent $tcp
	$ftp set type_ FTP
	
	
	#Setup a UDP connection
	set udp [new Agent/UDP]
	$ns attach-agent $n0 $udp
	$ns attach-agent $n1 $udp
	$ns attach-agent $n2 $udp
	$ns attach-agent $n3 $udp
	$ns attach-agent $n4 $udp
	$ns attach-agent $n5 $udp
	$ns attach-agent $n6 $udp
	$ns attach-agent $n7 $udp
	$ns attach-agent $n9 $udp
	set null [new Agent/Null]
	$ns attach-agent $n8 $null
	$ns connect $udp $null
	$udp set fid_ 2
	

	if {$i != 0} { 
	set N [expr (($avgtotal*225)/2)]
	#set N [expr (($e8*50)/2)]
	set N [expr (round($N))]
	if {$N == 0} { set N 1} }
	puts "the value N is =$N"

	if {$nc0status != 0} { set e0 [expr ($e0-($N*(($packlen*$Eelec)+($packlen*$Efs*$d08*$d08)))-($cntrpackt*$Ech))] }
	if {$nc1status != 0} { set e1 [expr ($e1-($N*(($packlen*$Eelec)+($packlen*$Efs*$d18*$d18)))-($cntrpackt*$Ech))] }
	if {$nc2status != 0} { set e2 [expr ($e2-($N*(($packlen*$Eelec)+($packlen*$Efs*$d28*$d28)))-($cntrpackt*$Ech))] }
	if {$nc3status != 0} { set e3 [expr ($e3-($N*(($packlen*$Eelec)+($packlen*$Efs*$d38*$d38)))-($cntrpackt*$Ech))] }
	if {$nc4status != 0} { set e4 [expr ($e4-($N*(($packlen*$Eelec)+($packlen*$Efs*$d48*$d48)))-($cntrpackt*$Ech))] }
	if {$nc5status != 0} { set e5 [expr ($e5-($N*(($packlen*$Eelec)+($packlen*$Efs*$d58*$d58)))-($cntrpackt*$Ech))] }
	if {$nc6status != 0} { set e6 [expr ($e6-($N*(($packlen*$Eelec)+($packlen*$Efs*$d68*$d68)))-($cntrpackt*$Ech))] }
	if {$nc7status != 0} { set e7 [expr ($e7-($N*(($packlen*$Eelec)+($packlen*$Efs*$d78*$d78)))-($cntrpackt*$Ech))] }
	if {$nc9status != 0} { set e9 [expr ($e9-($N*(($packlen*$Eelec)+($packlen*$Efs*$d90*$d90)))-($cntrpackt*$Ech))] }
	if {$nc8status != 0} { set e8 [expr ($e8-($N*(($Eelec)*($cntrpackt)*($a-1)+ $Efs*$cntrpackt*($dist4mBS2node*$dist4mBS2node)+($a*$cntrpackt*$EDA)+($Eelec*$cntrpackt)))-((2*($a-1)+1)*$cntrpackt*$Ech))] }
	#if {$nc0status != 0} { set e0 [expr ($e0-($k*$Eelect+$k*$Efs*$d08*$d08+20*$Ech))] }
	#if {$nc1status != 0} { set e1 [expr ($e1-($k*$Eelect+$k*$Efs*$d18*$d18+20*$Ech))] }
	#if {$nc2status != 0} { set e2 [expr ($e2-($k*$Eelect+$k*$Efs*$d28*$d28+20*$Ech))] }
	#if {$nc3status != 0} { set e3 [expr ($e3-($k*$Eelect+$k*$Efs*$d38*$d38+20*$Ech))] }
	#if {$nc4status != 0} { set e4 [expr ($e4-($k*$Eelect+$k*$Efs*$d48*$d48+20*$Ech))] }
	#if {$nc5status != 0} { set e5 [expr ($e5-($k*$Eelect+$k*$Efs*$d58*$d58+20*$Ech))] }
	#if {$nc6status != 0} { set e6 [expr ($e6-($k*$Eelect+$k*$Efs*$d68*$d68+20*$Ech))] }
	#if {$nc7status != 0} { set e7 [expr ($e7-($k*$Eelect+$k*$Efs*$d78*$d78+20*$Ech))] }
	#if {$nc9status != 0} { set e9 [expr ($e9-($k*$Eelect+$k*$Efs*$d98*$d98+20*$Ech))] }
	#if {$nc8status != 0} { set e8 [expr ($e8-(9*($k*$Eelect)+20*$Ech))] }
	#if {$nc8status != 0} { set e8 [expr ($e8-($k*$Eelect+$k*$Efs*$dist4mBS2node*$dist4mBS2node+20*$Ech+$EDA))] }
	#if {$sdis8 != 0} { set ch [expr ($e8/($sdis8*$sdis8))] }

	if {$nc0status == 1 && $e0 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc0status 0
	set e0 0
	set nc0 0 }
	if {$nc1status == 1 && $e1 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc1status 0
	set e1 0
	set nc1 0 }
	if {$nc2status == 1 && $e2 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc2status 0
	set e2 0
	set nc2 0 }
	if {$nc3status == 1 && $e3 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc3status 0
	set e3 0
	set nc3 0 }
	if {$nc4status == 1 && $e4 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc4status 0
	set e4 0
	set nc4 0 }
	if {$nc5status == 1 && $e5 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc5status 0
	set e5 0
	set nc5 0 }
	if {$nc6status == 1 && $e6 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc6status 0
	set e6 0
	set nc6 0 }
	if {$nc7status == 1 && $e7 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc7status 0
	set e7 0
	set nc7 0 }
	if {$nc8status == 1 && $e8 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc8status 0
	set e8 0
	set nc8 0 }
	if {$nc9status == 1 && $e9 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc9status 0
	set e9 0
	set nc9 0 }
	puts $f0 "$t $a"
	puts $f1 "$i $N" }

        #for node9
        if {$ch == $nc9} { $n9 color green	
	set tcp1 [$ns create-connection TCP $n0 TCPSink $n9 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 10
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n1 TCPSink $n9 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 10
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"
	
	set tcp1 [$ns create-connection TCP $n2 TCPSink $n9 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n3 TCPSink $n9 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n4 TCPSink $n9 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n5 TCPSink $n9 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n6 TCPSink $n9 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n7 TCPSink $n9 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"

	set tcp1 [$ns create-connection TCP $n8 TCPSink $n9 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ 100
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"
	
        set dtr [expr ($sdisrat *100 + $sdisrat *100)]
	set tcp1 [$ns create-connection TCP $n9 TCPSink $n10 1]
	$tcp1 set class_ 1
	$tcp1 set maxcwnd_ 16
	$tcp1 set packetsize_ $dtr
	$tcp1 set fid_ 1
	set ftp1 [$tcp1 attach-app FTP]
	$ftp1 set interval_ 1
	$ns at 0.2 "$ftp1 start"
	$ns at 4.0 "$ftp1 stop"
	
	#Setup a TCP connection
	set tcp [new Agent/TCP]
	$tcp set class_ 2
	$ns attach-agent $n0 $tcp
	$ns attach-agent $n1 $tcp
	$ns attach-agent $n2 $tcp
	$ns attach-agent $n3 $tcp
	$ns attach-agent $n4 $tcp
	$ns attach-agent $n5 $tcp
	$ns attach-agent $n6 $tcp
	$ns attach-agent $n7 $tcp
	$ns attach-agent $n8 $tcp
	set sink [new Agent/TCPSink]
	$ns attach-agent $n9 $sink
	$ns connect $tcp $sink
	$tcp set fid_ 1 
	
	#Setup a FTP over TCP connection
	set ftp [new Application/FTP]
	$ftp attach-agent $tcp
	$ftp set type_ FTP
	
	
	#Setup a UDP connection
	set udp [new Agent/UDP]
	$ns attach-agent $n0 $udp
	$ns attach-agent $n1 $udp
	$ns attach-agent $n2 $udp
	$ns attach-agent $n3 $udp
	$ns attach-agent $n4 $udp
	$ns attach-agent $n5 $udp
	$ns attach-agent $n6 $udp
	$ns attach-agent $n7 $udp
	$ns attach-agent $n8 $udp
	set null [new Agent/Null]
	$ns attach-agent $n9 $null
	$ns connect $udp $null
	$udp set fid_ 2
	
	if {$i != 0} { 
	set N [expr (($avgtotal*225)/2)]
	#set N [expr (($e9*50)/2)]
	set N [expr (round($N))]
	if {$N == 0} { set N 1} }
	puts "the value N is =$N"

	if {$nc0status != 0} { set e0 [expr ($e0-($N*(($packlen*$Eelec)+($packlen*$Efs*$d09*$d09)))-($cntrpackt*$Ech))] }
	if {$nc1status != 0} { set e1 [expr ($e1-($N*(($packlen*$Eelec)+($packlen*$Efs*$d19*$d19)))-($cntrpackt*$Ech))] }
	if {$nc2status != 0} { set e2 [expr ($e2-($N*(($packlen*$Eelec)+($packlen*$Efs*$d29*$d29)))-($cntrpackt*$Ech))] }
	if {$nc3status != 0} { set e3 [expr ($e3-($N*(($packlen*$Eelec)+($packlen*$Efs*$d39*$d39)))-($cntrpackt*$Ech))] }
	if {$nc4status != 0} { set e4 [expr ($e4-($N*(($packlen*$Eelec)+($packlen*$Efs*$d49*$d49)))-($cntrpackt*$Ech))] }
	if {$nc5status != 0} { set e5 [expr ($e5-($N*(($packlen*$Eelec)+($packlen*$Efs*$d59*$d59)))-($cntrpackt*$Ech))] }
	if {$nc6status != 0} { set e6 [expr ($e6-($N*(($packlen*$Eelec)+($packlen*$Efs*$d69*$d69)))-($cntrpackt*$Ech))] }
	if {$nc7status != 0} { set e7 [expr ($e7-($N*(($packlen*$Eelec)+($packlen*$Efs*$d79*$d79)))-($cntrpackt*$Ech))] }
	if {$nc8status != 0} { set e8 [expr ($e8-($N*(($packlen*$Eelec)+($packlen*$Efs*$d89*$d89)))-($cntrpackt*$Ech))] }
	if {$nc9status != 0} { set e9 [expr ($e9-($N*(($Eelec)*($cntrpackt)*($a-1)+ $Efs*$cntrpackt*($dist4mBS2node*$dist4mBS2node)+($a*$cntrpackt*$EDA)+($Eelec*$cntrpackt)))-((2*($a-1)+1)*$cntrpackt*$Ech))] }
	#if {$nc0status != 0} { set e0 [expr ($e0-($k*$Eelect+$k*$Efs*$d09*$d09+20*$Ech))] }
	#if {$nc1status != 0} { set e1 [expr ($e1-($k*$Eelect+$k*$Efs*$d19*$d19+20*$Ech))] }
	#if {$nc2status != 0} { set e2 [expr ($e2-($k*$Eelect+$k*$Efs*$d29*$d29+20*$Ech))] }
	#if {$nc3status != 0} { set e3 [expr ($e3-($k*$Eelect+$k*$Efs*$d39*$d39+20*$Ech))] }
	#if {$nc4status != 0} { set e4 [expr ($e4-($k*$Eelect+$k*$Efs*$d49*$d49+20*$Ech))] }
	#if {$nc5status != 0} { set e5 [expr ($e5-($k*$Eelect+$k*$Efs*$d59*$d59+20*$Ech))] }
	#if {$nc6status != 0} { set e6 [expr ($e6-($k*$Eelect+$k*$Efs*$d69*$d69+20*$Ech))] }
	#if {$nc7status != 0} { set e7 [expr ($e7-($k*$Eelect+$k*$Efs*$d79*$d79+20*$Ech))] }
	#if {$nc8status != 0} { set e8 [expr ($e8-($k*$Eelect+$k*$Efs*$d89*$d89+20*$Ech))] }
	#if {$nc9status != 0} { set e9 [expr ($e9-(9*($k*$Eelect+20)*$Ech))] }
	#if {$nc9status != 0} { set e9 [expr ($e9-($k*$Eelect+$k*$Efs*$dist4mBS2node*$dist4mBS2node+20*$Ech+$EDA))] }
	#if {$sdis9 != 0} { set ch [expr ($e9/($sdis9*$sdis9))] }

	if {$nc0status == 1 && $e0 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc0status 0
	set e0 0
	set nc0 0 }
	if {$nc1status == 1 && $e1 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc1status 0
	set e1 0
	set nc1 0 }
	if {$nc2status == 1 && $e2 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc2status 0
	set e2 0
	set nc2 0 }
	if {$nc3status == 1 && $e3 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc3status 0
	set e3 0
	set nc3 0 }
	if {$nc4status == 1 && $e4 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc4status 0
	set e4 0
	set nc4 0 }
	if {$nc5status == 1 && $e5 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc5status 0
	set e5 0
	set nc5 0 }
	if {$nc6status == 1 && $e6 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc6status 0
	set e6 0
	set nc6 0 }
	if {$nc7status == 1 && $e7 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc7status 0
	set e7 0
	set nc7 0 }
	if {$nc8status == 1 && $e8 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc8status 0
	set e8 0
	set nc8 0 }
	if {$nc9status == 1 && $e9 < $Ecri} { incr d
	set a [expr ($a-1)]
	set nc9status 0
	set e9 0
	set nc9 0 }
	puts $f0 "$t $a"
	puts $f1 "$i $N" }

	
	puts $f2 "$t $bitsfromclust"	
	set bitsfromclust [expr ($bitsfromclust+($N*4000))]

        #Setup a CBR over UDP connection
	set cbr [new Application/Traffic/CBR]
	$cbr attach-agent $udp
	$cbr set type_ CBR
	$cbr set packet_size_ 11
	$cbr set rate_ 1kb
	$cbr set random_ false


	#Schedule events for the CBR and FTP agents
	#$ns at 0.0 "record"	
	$ns at 0.1 "$cbr start"
	$ns at 0.1 "$ftp start"
	$ns at 1.0 "$ftp stop"
	$ns at 1.0 "$cbr stop"
	

	#Call the finish procedure after 5 seconds of simulation time
	$ns at 5.0 "finish"
        
        
	#Print CBR packet size and interval
	puts "CBR packet size = [$cbr set packet_size_]"
	puts "CBR interval = [$cbr set interval_]"
	#Run the simulation

	puts "The number of alive nodes after $i round=$a"
	puts "The number of dead nodes after $i round=$d"


	
}

	$ns run

