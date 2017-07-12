# Sessioni

# creo una procedura per avviare le sessioni


proc INVITE {nt nr} {
    global ns sipU U m seed
    $sipU($nt) invite U($nr) proxy(10).com test accept

    set Ts [uniform 20 40] 
    set Tbye [$ns now]
    set Tbye2 [expr $Ts+$Tbye]
    #puts "Ts $Ts Tnow $Tbye Tbye $Tbye2 $nt bye $nr"
    $ns at $Tbye2 "BYE $nt $nr"

}



proc BYE {nt nr} {
    global ns sipU U seed 
    $sipU($nt) bye

    set Ti [exponential 10]
    set Tinv [$ns now]
    set Tinv2 [expr $Ti+$Tinv]
    #puts "Ti $Ti Tnow $Tinv Tinv $Tinv2 $nt invite $nr"
    $ns at $Tinv2 "INVITE $nt $nr"

}



proc INVITE_start0 {} {
    global ns sipU U seed m nr0
    for {set i 0} {$i < $m} {incr i} {
        set nt0 [expr 2 + $i]
        set nr0 [expr 1002 + $i]
        #$sipU($nt0) invite U($nr0) proxy(10).com test accept
        set T_now [$ns now]
        set Ts [uniform 0 10]
        set Tstart [expr $Ts+$T_now]
        #puts "Tstart $Tstart $nt0 invite $nr0"
        $ns at $Tstart "INVITE $nt0 $nr0"


    }
}


proc INVITE_start1 {} {
    global ns sipU U seed m nr1
    upvar nr0 nr0
    for {set i 0} {$i < $m} {incr i} {
        set nt1 [expr 102 + $i]
        set nr1 [expr $nr0 + 1 + $i]
        #$sipU($nt1) invite U($nr1) proxy(10).com test accept
        set T_now [$ns now]
        set Ts [uniform 0 10]
        set Tstart [expr $Ts+$T_now]
        #puts "Tstart $Tstart $nt1 invite $nr1"
        $ns at $Tstart "INVITE $nt1 $nr1"

    }
}

proc INVITE_start2 {} {
    global ns sipU U seed m nr2
    upvar nr1 nr1
    for {set i 0} {$i < $m} {incr i} {
        set nt2 [expr 202 + $i]
        set nr2 [expr $nr1+ 1 + $i]
        #$sipU($nt2) invite U($nr2) proxy(10).com test accept
        set T_now [$ns now]
        set Ts [uniform 0 10]
        set Tstart [expr $Ts+$T_now]
        #puts "Tstart $Tstart $nt2 invite $nr2"
        $ns at $Tstart "INVITE $nt2 $nr2"

    }
}

proc INVITE_start3 {} {
    global ns sipU U seed m nr3
    upvar nr2 nr2
    for {set i 0} {$i < $m} {incr i} {
        set nt3 [expr 302 + $i]
        set nr3 [expr $nr2+ 1 + $i]
        #$sipU($nt3) invite U($nr3) proxy(10).com test accept
        set T_now [$ns now]
        set Ts [uniform 0 10]
        set Tstart [expr $Ts+$T_now]
        #puts "Tstart $Tstart $nt3 invite $nr3"
        $ns at $Tstart "INVITE $nt3 $nr3"

    }
}

proc INVITE_start4 {} {
    global ns sipU U seed m nr4
    upvar nr3 nr3
    for {set i 0} {$i < $m} {incr i} {
        set nt4 [expr 402 + $i]
        set nr4 [expr $nr3 + 1 + $i]
        #$sipU($nt4) invite U($nr4) proxy(10).com test accept
        set T_now [$ns now]
        set Ts [uniform 0 10]
        set Tstart [expr $Ts+$T_now]
        #puts "Tstart $Tstart $nt4 invite $nr4"
        $ns at $Tstart "INVITE $nt4 $nr4"

    }
}

proc INVITE_start5 {} {
    global ns sipU U seed m nr5
    upvar nr4 nr4
    for {set i 0} {$i < $m} {incr i} {
        set nt5 [expr 502 + $i]
        set nr5 [expr $nr4 + 1 + $i]
        #$sipU($nt5) invite U($nr5) proxy(10).com test accept
        set T_now [$ns now]
        set Ts [uniform 0 10]
        set Tstart [expr $Ts+$T_now]
        #puts "Tstart $Tstart $nt5 invite $nr5"
        $ns at $Tstart "INVITE $nt5 $nr5"

    }
}

proc INVITE_start6 {} {
    global ns sipU U seed m nr6
    upvar nr5 nr5
    for {set i 0} {$i < $m} {incr i} {
        set nt6 [expr 602 + $i]
        set nr6 [expr $nr5 + 1 + $i]
        # $sipU($nt6) invite U($nr6) proxy(10).com test accept
        set T_now [$ns now]
        set Ts [uniform 0 10]
        set Tstart [expr $Ts+$T_now]
        #puts "Tstart $Tstart $nt6 invite $nr6"
        $ns at $Tstart "INVITE $nt6 $nr6"

    }
}

proc INVITE_start7 {} {
    global ns sipU U seed m nr7
    upvar nr6 nr6
    for {set i 0} {$i < $m} {incr i} {
        set nt7 [expr 702 + $i]
        set nr7 [expr $nr6 + 1 + $i]
        #$sipU($nt7) invite U($nr7) proxy(10).com test accept
        set T_now [$ns now]
        set Ts [uniform 0 10]
        set Tstart [expr $Ts+$T_now]
        #puts "Tstart $Tstart $nt7 invite $nr7"
        $ns at $Tstart "INVITE $nt7 $nr7"

    }
}

proc INVITE_start8 {} {
    global ns sipU U seed m nr8
    upvar nr7 nr7
    for {set i 0} {$i < $m} {incr i} {
        set nt8 [expr 802 + $i]
        set nr8 [expr $nr7 + 1 + $i]
        #$sipU($nt8) invite U($nr8) proxy(10).com test accept
        set T_now [$ns now]
        set Ts [uniform 0 10]
        set Tstart [expr $Ts+$T_now]
        #puts "Tstart $Tstart $nt8 invite $nr8"
        $ns at $Tstart "INVITE $nt8 $nr8"

    }
}

proc INVITE_start9 {} {
    global ns sipU U seed m nr9
    upvar nr8 nr8
    for {set i 0} {$i < $m} {incr i} {
        set nt9 [expr 902 + $i]
        set nr9 [expr $nr8 + 1 + $i]
        set T_now [$ns now]
        set Ts [uniform 0 10]
        set Tstart [expr $Ts+$T_now]
        #puts "Tstart $Tstart $nt9 invite $nr9"
        $ns at $Tstart "INVITE $nt9 $nr9"

    }
}



#finish procedure
proc finish {} {
    global ns tf nf FileRes
    $ns flush-trace
    close $FileRes
    puts "NS-simulation finished!"
    exit 0
}
