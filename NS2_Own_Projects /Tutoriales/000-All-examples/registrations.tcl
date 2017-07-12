proc REGISTRAZIONI {} {
    global sipU ns
    # Register nodes at proxy0
    for {set i 2} {$i < 100} {incr i} {
        $sipU($i) register
    }
    # Register nodes at proxy1
    for {set i 102} {$i < 200} {incr i} {
        $sipU($i) register
    }
    # Register nodes at proxy2
    for {set i 202} {$i < 300} {incr i} {
        $sipU($i) register
    }
    # Register nodes at proxy3
    for {set i 302} {$i < 400} {incr i} {
        $sipU($i) register
    }

    # Register nodes at proxy4
    for {set i 402} {$i < 500} {incr i} {
        $sipU($i) register
    }
    # Register nodes at proxy5
    for {set i 502} {$i < 600} {incr i} {
        $sipU($i) register
    }
    # Register nodes at proxy6
    for {set i 602} {$i < 700} {incr i} {
        $sipU($i) register
    }
    # Register nodes at proxy7
    for {set i 702} {$i < 800} {incr i} {
        $sipU($i) register
    }

    # Register nodes at proxy8
    for {set i 802} {$i < 900} {incr i} {
        $sipU($i) register
    }
    # Register nodes at proxy9
    for {set i 902} {$i < 1000} {incr i} {
        $sipU($i) register
    }
}


proc REGISTRAZIONED11_1 {} {
    # Register nodes at proxy10
    global ns sipU
    for {set i 1002} {$i < 1101} {incr i} {
        $sipU($i) register
        #puts "sipU($i) register"
    }
}

proc REGISTRAZIONED11_2 {} {
    global ns sipU
    # Register nodes at proxy10
    for {set i 1101} {$i < 1200} {incr i} {
        $sipU($i) register
        #puts "sipU($i) register"
    }
}

proc REGISTRAZIONED11_3 {} {
    # Register nodes at proxy10
    global ns sipU
    for {set i 1200} {$i < 1299} {incr i} {
        $sipU($i) register

        #puts "sipU($i) register"
    }
}

proc REGISTRAZIONED11_4 {} {
    global ns sipU
    # Register nodes at proxy10
    for {set i 1299} {$i < 1398} {incr i} {
        $sipU($i) register
        #puts "sipU($i) register"
    }
}

proc REGISTRAZIONED11_5 {} {
    # Register nodes at proxy10
    global ns sipU
    for {set i 1398} {$i < 1497} {incr i} {
        $sipU($i) register
        #puts "sipU($i) register"
    }
}

proc REGISTRAZIONED11_6 {} {
    global ns sipU
    # Register nodes at proxy10
    for {set i 1497} {$i < 1596} {incr i} {
        $sipU($i) register
        #puts "sipU($i) register"
    }
}

proc REGISTRAZIONED11_7 {} {
    # Register nodes at proxy10
    global ns sipU
    for {set i 1596} {$i < 1695} {incr i} {
        $sipU($i) register
        #puts "sipU($i) register"
    }
}

proc REGISTRAZIONED11_8 {} {
    global ns sipU
    # Register nodes at proxy10
    for {set i 1695} {$i < 1794} {incr i} {
        $sipU($i) register
        #puts "sipU($i) register"
    }
}


proc REGISTRAZIONED11_9 {} {
    # Register nodes at proxy10
    global ns sipU
    for {set i 1794} {$i < 1893} {incr i} {
        $sipU($i) register
        #puts "sipU($i) register"
    }
}

proc REGISTRAZIONED11_10 {} {
    global ns sipU
    # Register nodes at proxy10
    for {set i 1893} {$i < 1991} {incr i} {
        $sipU($i) register
        #puts "sipU($i) register"
    }
}