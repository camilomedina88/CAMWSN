proc define-UA {} {
    global n ns sipU serveraddrPR
    #UA del dominio 0
    for {set i 2} {$i < 100} {incr i} {
        set sipU($i) [new Agent/SIPUA U($i) proxy(0).com]
        $ns attach-agent $n($i) $sipU($i)
        $sipU($i) set-proxy $serveraddrPR(0)
    }
    
    #User Agent del dominio 1
    for {set i 102} {$i < 200} {incr i} {
        set sipU($i) [new Agent/SIPUA U($i) proxy(1).com]
        $ns attach-agent $n($i) $sipU($i)
        $sipU($i) set-proxy $serveraddrPR(1)
    }

    #User Agent del dominio 2
    for {set i 202} {$i < 300} {incr i} {
        set sipU($i) [new Agent/SIPUA U($i) proxy(2).com]
        $ns attach-agent $n($i) $sipU($i)
        $sipU($i) set-proxy $serveraddrPR(2)

    }

    #User Agent del dominio 3
    for {set i 302} {$i < 400} {incr i} {
        set sipU($i) [new Agent/SIPUA U($i) proxy(3).com]
        $ns attach-agent $n($i) $sipU($i)
        $sipU($i) set-proxy $serveraddrPR(3)
    }

    #User Agent del dominio 5
    for {set i 402} {$i < 500} {incr i} {
        set sipU($i) [new Agent/SIPUA U($i) proxy(4).com]
        $ns attach-agent $n($i) $sipU($i)
        $sipU($i) set-proxy $serveraddrPR(4)
    }

    #User Agent del dominio 6
    for {set i 502} {$i < 600} {incr i} {
        set sipU($i) [new Agent/SIPUA U($i) proxy(5).com]
        $ns attach-agent $n($i) $sipU($i)
        $sipU($i) set-proxy $serveraddrPR(5)
    }

    #User Agent del dominio 7
    for {set i 602} {$i < 700} {incr i} {
        set sipU($i) [new Agent/SIPUA U($i) proxy(6).com]
        $ns attach-agent $n($i) $sipU($i)
        $sipU($i) set-proxy $serveraddrPR(6)
    }

    #User Agent del dominio 8
    for {set i 702} {$i < 800} {incr i} {
        set sipU($i) [new Agent/SIPUA U($i) proxy(7).com]
        $ns attach-agent $n($i) $sipU($i)
        $sipU($i) set-proxy $serveraddrPR(7)
    }

    #User Agent del dominio 9
    for {set i 802} {$i < 900} {incr i} {
        set sipU($i) [new Agent/SIPUA U($i) proxy(8).com]
        $ns attach-agent $n($i) $sipU($i)
        $sipU($i) set-proxy $serveraddrPR(8)
    }

    #User Agent del dominio 10
    for {set i 902} {$i < 1000} {incr i} {
        set sipU($i) [new Agent/SIPUA U($i) proxy(9).com]
        $ns attach-agent $n($i) $sipU($i)
        $sipU($i) set-proxy $serveraddrPR(9)
    }

    #User Agent del dominio 11
    for {set i 1002} {$i < 1991} {incr i} {
        set sipU($i) [new Agent/SIPUA U($i) proxy(10).com]
        $ns attach-agent $n($i) $sipU($i)
        $sipU($i) set-proxy $serveraddrPR(10)
        #puts "sipU($i) n($i) $serveraddrPR(10)"
    }

}

