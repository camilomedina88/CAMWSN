proc stampa_coda {interval} {
    global ns queue1_2 FileRes sipPR
    set invQueue [$sipPR(10) invStatus]
    set queue [$sipPR(10) status]
    set iRate [$sipPR(10) set iRate_]
    set sent [$sipPR(10) set count503_]
    set avg [$sipPR(10) set iAvg_]
    set iCount [$sipPR(10) set iCount_]

    set p_coda [$queue1_2 set pkts_ ]
    set ric [$queue1_2 set parrivals_ ]
    set trasm [$queue1_2 set pdepartures_ ]
    set now [$ns now]
    set drop [$queue1_2 set pdrops_]
    puts $FileRes "$now $queue $invQueue $iRate $avg $iCount $sent"
    $ns at [expr $now + $interval] "stampa_coda $interval" 
}