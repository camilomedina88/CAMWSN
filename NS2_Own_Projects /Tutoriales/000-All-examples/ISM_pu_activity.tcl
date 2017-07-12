# Modeling of PU activity according to Commercial area for ISM band
if {$val(pu)==2} {
	# For channel 0
	$ns_ at 0.0 "$ptraffic(0) start"
	$ns_ at 30.0 "$ptraffic(0) stop"
	$ns_ at 80.0 "$ptraffic(0) start"
	$ns_ at 90.0 "$ptraffic(0) stop"
} elseif {$val(pu)==4} {
	# For channel 0
	$ns_ at 0.0 "$ptraffic(0) start"
	$ns_ at 30.0 "$ptraffic(0) stop"
	$ns_ at 80.0 "$ptraffic(0) start"
	$ns_ at 90.0 "$ptraffic(0) stop"
	# For channel 1
	$ns_ at 100.0 "$ptraffic(1) start"
	$ns_ at 110.0 "$ptraffic(1) stop"
} elseif {$val(pu)==6} {
	# For channel 0
	$ns_ at 0.0 "$ptraffic(0) start"
	$ns_ at 30.0 "$ptraffic(0) stop"
	$ns_ at 80.0 "$ptraffic(0) start"
	$ns_ at 90.0 "$ptraffic(0) stop"

	# For channel 1
	$ns_ at 100.0 "$ptraffic(1) start"
	$ns_ at 110.0 "$ptraffic(1) stop"

	# For channel 2
	$ns_ at 90.0 "$ptraffic(2) start"
	$ns_ at 100.0 "$ptraffic(2) stop"
} elseif {$val(pu)==8} {
	# For channel 0
	$ns_ at 0.0 "$ptraffic(0) start"
	$ns_ at 30.0 "$ptraffic(0) stop"
	$ns_ at 80.0 "$ptraffic(0) start"
	$ns_ at 90.0 "$ptraffic(0) stop"
	# For channel 1
	$ns_ at 100.0 "$ptraffic(1) start"
	$ns_ at 110.0 "$ptraffic(1) stop"
	# For channel 2
	$ns_ at 90.0 "$ptraffic(2) start"
	$ns_ at 100.0 "$ptraffic(2) stop"
	# For channel 3
	# no activity
} elseif {$val(pu)==10} {
	# For channel 0
	$ns_ at 0.0 "$ptraffic(0) start"
	$ns_ at 30.0 "$ptraffic(0) stop"
	$ns_ at 80.0 "$ptraffic(0) start"
	$ns_ at 90.0 "$ptraffic(0) stop"
	# For channel 1
	$ns_ at 100.0 "$ptraffic(1) start"
	$ns_ at 110.0 "$ptraffic(1) stop"
	# For channel 2
	$ns_ at 90.0 "$ptraffic(2) start"
	$ns_ at 100.0 "$ptraffic(2) stop"
	# For channel 3
	# no activity
	# For channel 4
	# no activity
}


# For channel 5
#$ns_ at 19.0 "$ptraffic(5) start"
#$ns_ at 21.0 "$ptraffic(5) stop"

# For channel 6
#$ns_ at 0.0 "$ptraffic(6) start"
#$ns_ at 1.0 "$ptraffic(6) stop"
#$ns_ at 17.0 "$ptraffic(6) start"
#$ns_ at 18.0 "$ptraffic(6) stop"

# For channel 7
#$ns_ at 1.0 "$ptraffic(7) start"
#$ns_ at 3.0 "ptraffic(7) stop"

# For channel 8
#$ns_ at 20.0 "$ptraffic(8) start"
#$ns_ at 21.0 "$ptraffic(8) stop"

# For channel 9
#$ns_ at 4.0 "$ptraffic(9) start"
#$ns_ at 5.0 "$ptraffic(9) stop"
