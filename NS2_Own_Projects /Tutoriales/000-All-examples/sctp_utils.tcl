##--M.Fasciana
#--University of Palermo (Italy)
#-----------------------------------------------------------
#sctp_utils.c

set null_($from) [new Agent/Null]
$ns attach-agent $n_null_($from) $null_($from)
		
set null_($to) [new Agent/Null]
$ns attach-agent $n_null_($to) $null_($to)

#---------------------------------------------------------
Application/Traffic/SipSctp instproc start_call_ {num from to} {
    global ns call_time voice n_voice_ udp null_ voice_packet_size voice_burst_time voice_idle_time voice_rate 
    
		set udp($num.$from.$from) [new Agent/UDP]
		$ns attach-agent $n_voice_($from) $udp($num.$from.$from)		

		set udp($num.$to.$from) [new Agent/UDP]
		$ns attach-agent $n_voice_($to) $udp($num.$to.$from)

		$ns connect $udp($num.$from.$from) $null_($to)
		$ns connect $udp($num.$to.$from) $null_($from)

    
	    set voice($num.$from.$from) [new Application/Traffic/Exponential]
    		$voice($num.$from.$from) set packetSize_ $voice_packet_size            ;#132
    		$voice($num.$from.$from) set burst_time_ $voice_burst_time             ;#1000ms
    		$voice($num.$from.$from) set idle_time_ $voice_idle_time              ;#1300ms
    		$voice($num.$from.$from) set rate_ $voice_rate                ;#16k
	    set voice($num.$to.$from) [new Application/Traffic/Exponential]
    		$voice($num.$to.$from) set packetSize_ $voice_packet_size            ;#132
    		$voice($num.$to.$from) set burst_time_ $voice_burst_time             ;#1000ms
    		$voice($num.$to.$from) set idle_time_ $voice_idle_time              ;#1300ms
    		$voice($num.$to.$from) set rate_ $voice_rate                ;#16k
		
		$voice($num.$from.$from) attach-agent $udp($num.$from.$from)
		$voice($num.$to.$from) attach-agent $udp($num.$to.$from)    	

    		#puts "start number:$num\tfrom:$from\tto:$to\t"	
		$voice($num.$to.$from) start
		$voice($num.$from.$from) start
    			
}
    
Application/Traffic/SipSctp instproc stop_call_ {num from to} {
    global ns n_voice_ udp voice
	
	
	#set now [$ns now]
	$voice($num.$to.$from) stop
	$voice($num.$from.$from) stop

	#puts "time:$now\tstop number:$num\tfrom:$from\tto:$to\t"
	$ns detach-agent $n_voice_($to) $udp($num.$to.$from)
	$ns detach-agent $n_voice_($from) $udp($num.$from.$from)
}


