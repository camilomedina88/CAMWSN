
# ############################################################### 
# Thierry Ernst 1999/2000
# INRIA Rhone-Alpes Grenoble FRANCE - MOTOROLA Labs Paris FRANCE 
# 
# Tools for traffic generation 
# ############################################################### 

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 23/04/01
# Set ping traffic between 2 nodes at regular time interval 
# Same as set-ping-traffic but params are objects instead of ids.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc set-ping-int { interval src dst start stop } {
   global ns
   set sp [new Agent/Ping]
   set rp [new Agent/Ping]
   $ns attach-agent $src $sp 
   $ns attach-agent $dst $rp
   $ns connect $sp $rp   
   $ns at $start "send-ping-packet $sp $start $stop $interval"	
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 30/08/01
# Set ping traffic between 2 nodes at regular time interval
# Same as set-ping-int but do not start sending immediately.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc set-ping-int-wait { interval wait src dst start stop } {
   global ns
   set sp [new Agent/Ping]
   set rp [new Agent/Ping]
   $ns attach-agent $src $sp
   $ns attach-agent $dst $rp
   $ns connect $sp $rp
   set time [expr int($start) + $wait]
   $ns at $time "send-ping-packet $sp $time $stop $interval"
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 01/01
# Schedule traffic between 2 nodes at regular time interval 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc send-ping-packet { sp time stop interval } { 
   global ns

   if { $time < $stop } {
	# puts "send ping at $time"
        $sp send
	set time [expr $time + $interval] 
	$ns at $time "send-ping-packet $sp $time $stop $interval"	
   }
}

