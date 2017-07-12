#Open the new simulator
set ns [new Simulator]

set nf [open out.nam w]
$ns namtrace-all $nf

#Open the output files
set f0 [open out.tr w]
#$ns trace-all $f0


#Define a 'finish' procedure
proc finish {} {
	global ns nf f0 f
        $ns flush-trace
        close $nf
        exec nam out.nam &
	#Close the output files
	close $f0
	#Call xgraph to display the results
	exec xgraph -x time -y throughput(mbps) out.tr -geometry 800x400 &

#for the RED function
    global tchan_
    set awkCode {
	{
	    if ($1 == "Q" && NF>2) {
		print $2, $3 >> "temp.q";
		set end $2
	    }
	    else if ($1 == "a" && NF>2)
	    print $2, $3 >> "temp.a";
	}
    }
    set f [open temp.queue w]
    puts $f "TitleText: red"
    puts $f "Device: Postscript"
    
    if { [info exists tchan_] } {
	close $tchan_
    }
    exec rm -f temp.q temp.a 
    exec touch temp.a temp.q
    
    exec awk $awkCode all.q
    
    puts $f \"queue
    exec cat temp.q >@ $f  
    puts $f \n\"ave_queue
    exec cat temp.a >@ $f
    close $f
    exec xgraph -bb -tk -x time -y queue temp.queue &
        exit 0
}


$ns rtproto DV
for {set i 0} {$i < 18} {incr i} {
    set n($i) [$ns node]
}

for {set i 2} {$i < 7} {incr i} {
    $ns duplex-link $n(1) $n($i) 10Mb 10ms DropTail
}

for {set i 7} {$i < 12} {incr i} {
    $ns duplex-link $n(0) $n($i) 10Mb 10ms DropTail
}

for {set i 13} {$i < 18} {incr i} {
    $ns duplex-link $n(12) $n($i) 10Mb 10ms DropTail
}

$ns duplex-link $n(0) $n(1) 10Mb 15ms DropTail
$ns duplex-link $n(0) $n(12) 10Mb 15ms DropTail

# node marking
# m -t 1 -s 0 -n m1 -c blue -h circle
# m -t 2 -s 1 -n m1 -c blue -h box 
# m -t 3 -s 12 -n m1 -c blue -h hexagon  

set tcp [new Agent/TCP]
$tcp set class_ 1
$ns attach-agent $n(7) $tcp

set sink [new Agent/TCPSink]
$ns attach-agent $n(3) $sink

set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 0.5 "$ftp start"

set tcp1 [new Agent/TCP]
$tcp1 set class_ 2
$ns attach-agent $n(13) $tcp1

set sink1 [new Agent/TCPSink]
$ns attach-agent $n(8) $sink1


set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ns at 1.0 "$ftp1 start"

set tcp2 [new Agent/TCP]
$tcp2 set class_ 3
$ns attach-agent $n(14) $tcp2

set sink2 [new Agent/TCPSink]
$ns attach-agent $n(6) $sink2


set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2
$ns at 10.0 "$ftp2 start"

$ns connect $tcp $sink
$ns connect $tcp1 $sink1
$ns connect $tcp2 $sink2

$ns color 1 Blue
$ns color 2 Red
$ns color 3 Black

#Define a procedure which periodically records the bandwidth received 
proc record {} {
        global sink f0 
	#Get an instance of the simulator
	set ns [Simulator instance]
	#Set the time after which the procedure should be called again
        set time 0.5
	#How many bytes have been received by the traffic sinks?
        set bw0 [$sink set bytes_]
	#Get the current time
        set now [$ns now]
	#Calculate the bandwidth (in MBit/s) and write it to the files
        puts $f0 "$now [expr $bw0/$time*8/261000]"
    	#Reset the bytes_ values on the traffic sinks
        $sink set bytes_ 0
	#Re-schedule the procedure
        $ns at [expr $now+$time] "record"
}




#Start logging the received bandwidth
$ns at 0.0 "record"
#Start the traffic sources
$ns at 0.5 "$ftp start"
$ns at 1.0 "$ftp1 start"
$ns at 10.0 "$ftp2 start"


#Stop the traffic sources
$ns at 19.5 "$ftp stop"
$ns at 19.5 "$ftp1 stop"
$ns at 19.5 "$ftp2 stop"


#Call the finish procedure after 60 seconds simulation time
$ns at 20.0 "finish"


#Run the simulation
$ns run


# Tracing a queue
$ns queue-limit $n(1) $n(3) 15
set redq [[$ns link $n(1) $n(3)] queue]
set tchan_ [open all.q w]
$redq trace curq_
$redq trace ave_
$redq attach $tchan_


#Run the simulation
$ns run

#......................

