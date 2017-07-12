# start with these lines :

set ns [new Simulator]
set nf [open out.nam w]
$ns namtrace-all $nf

proc finish {} {
        global ns nf
        $ns flush-trace
        close $nf
        exec nam out.nam &
        exit 0
}

#######################
#
#    Write all other commands here.
#
#######################

# end with :

$ns at 5.0 "finish"
$ns run


