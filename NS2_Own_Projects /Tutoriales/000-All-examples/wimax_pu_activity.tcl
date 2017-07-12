# Modeling of PU activity according to Commercial area for Wimax band
if {$val(pu)==1} {
	# chan 0
	$ns_ at 0.0 "$ptraffic(0) start"
	$ns_ at 10.0 "$ptraffic(0) stop"
	$ns_ at 210.0 "$ptraffic(0) start"
	$ns_ at 220.0 "$ptraffic(0) stop"
} elseif {$val(pu)==2} {
	# chan 0
	$ns_ at 0.0 "$ptraffic(0) start"
	$ns_ at 10.0 "$ptraffic(0) stop"
	$ns_ at 210.0 "$ptraffic(0) start"
	$ns_ at 220.0 "$ptraffic(0) stop"
	# chan 1
	$ns_ at 110.0 "$ptraffic(1) start"
	$ns_ at 120.0 "$ptraffic(1) stop"
} elseif {$val(pu)==3} {
	# chan 0
	$ns_ at 0.0 "$ptraffic(0) start"
	$ns_ at 10.0 "$ptraffic(0) stop"
	$ns_ at 210.0 "$ptraffic(0) start"
	$ns_ at 220.0 "$ptraffic(0) stop"
	# chan 1
	$ns_ at 110.0 "$ptraffic(1) start"
	$ns_ at 120.0 "$ptraffic(1) stop"
	# chan 2
	$ns_ at 60.0 "$ptraffic(2) start"
	$ns_ at 70.0 "$ptraffic(2) stop"
} elseif {$val(pu)==4} {
	# chan 0
	$ns_ at 00.0 "$ptraffic(0) start"
	$ns_ at 10.0 "$ptraffic(0) stop"
	$ns_ at 210.0 "$ptraffic(0) start"
	$ns_ at 220.0 "$ptraffic(0) stop"
	# chan 1
	$ns_ at 110.0 "$ptraffic(1) start"
	$ns_ at 120.0 "$ptraffic(1) stop"
	# chan 2
	$ns_ at 60.0 "$ptraffic(2) start"
	$ns_ at 70.0 "$ptraffic(2) stop"
	# chan 3
	# no activity 
} elseif {$val(pu)==5} {
	# chan 0
	$ns_ at 0.0 "$ptraffic(0) start"
	$ns_ at 10.0 "$ptraffic(0) stop"
	$ns_ at 210.0 "$ptraffic(0) start"
	$ns_ at 220.0 "$ptraffic(0) stop"
	# chan 1
	$ns_ at 110.0 "$ptraffic(1) start"
	$ns_ at 120.0 "$ptraffic(1) stop"
	# chan 2
	$ns_ at 60.0 "$ptraffic(2) start"
	$ns_ at 70.0 "$ptraffic(2) stop"
	# chan 3
	# no activity 
	# chan 4
	$ns_ at 10.0 "$ptraffic(4) start"
	$ns_ at 20.0 "$ptraffic(4) stop"
	$ns_ at 90.0 "$ptraffic(4) start"
	$ns_ at 100.0 "$ptraffic(4) stop"
	$ns_ at 240.0 "$ptraffic(4) start"
} elseif {$val(pu)==6} {
	# chan 0
	$ns_ at 00.0 "$ptraffic(0) start"
	$ns_ at 10.0 "$ptraffic(0) stop"
	$ns_ at 210.0 "$ptraffic(0) start"
	$ns_ at 220.0 "$ptraffic(0) stop"
	# chan 1
	$ns_ at 110.0 "$ptraffic(1) start"
	$ns_ at 120.0 "$ptraffic(1) stop"
	# chan 2
	$ns_ at 60.0 "$ptraffic(2) start"
	$ns_ at 70.0 "$ptraffic(2) stop"
	# chan 3
	# no activity 
	# chan 4
	$ns_ at 10.0 "$ptraffic(4) start"
	$ns_ at 20.0 "$ptraffic(4) stop"
	$ns_ at 90.0 "$ptraffic(4) start"
	$ns_ at 100.0 "$ptraffic(4) stop"
	$ns_ at 240.0 "$ptraffic(4) start"
	# chan 5
	$ns_ at 30.0 "$ptraffic(5) start"
	$ns_ at 40.0 "$ptraffic(5) stop"
} elseif {$val(pu)==7} {
	# chan 0
	$ns_ at 00.0 "$ptraffic(0) start"
	$ns_ at 10.0 "$ptraffic(0) stop"
	$ns_ at 210.0 "$ptraffic(0) start"
	$ns_ at 220.0 "$ptraffic(0) stop"
	# chan 1
	$ns_ at 110.0 "$ptraffic(1) start"
	$ns_ at 120.0 "$ptraffic(1) stop"
	# chan 2
	$ns_ at 60.0 "$ptraffic(2) start"
	$ns_ at 70.0 "$ptraffic(2) stop"
	# chan 3
	# no activity 
	# chan 4
	$ns_ at 10.0 "$ptraffic(4) start"
	$ns_ at 20.0 "$ptraffic(4) stop"
	$ns_ at 90.0 "$ptraffic(4) start"
	$ns_ at 100.0 "$ptraffic(4) stop"
	$ns_ at 240.0 "$ptraffic(4) start"
	# chan 5
	$ns_ at 30.0 "$ptraffic(5) start"
	$ns_ at 40.0 "$ptraffic(5) stop"
	# chan 6
	$ns_ at 30.0 "$ptraffic(6) start"
	$ns_ at 40.0 "$ptraffic(6) stop"
	$ns_ at 50.0 "$ptraffic(6) start"
	$ns_ at 60.0 "$ptraffic(9) stop"
} elseif {$val(pu)==8} {
	# chan 0
	$ns_ at 0.0 "$ptraffic(0) start"
	$ns_ at 10.0 "$ptraffic(0) stop"
	$ns_ at 210.0 "$ptraffic(0) start"
	$ns_ at 220.0 "$ptraffic(0) stop"
	# chan 1
	$ns_ at 110.0 "$ptraffic(1) start"
	$ns_ at 120.0 "$ptraffic(1) stop"
	# chan 2
	$ns_ at 60.0 "$ptraffic(2) start"
	$ns_ at 70.0 "$ptraffic(2) stop"
	# chan 3
	# no activity 
	# chan 4
	$ns_ at 10.0 "$ptraffic(4) start"
	$ns_ at 20.0 "$ptraffic(4) stop"
	$ns_ at 90.0 "$ptraffic(4) start"
	$ns_ at 100.0 "$ptraffic(4) stop"
	$ns_ at 240.0 "$ptraffic(4) start"
	# chan 5
	$ns_ at 30.0 "$ptraffic(5) start"
	$ns_ at 40.0 "$ptraffic(5) stop"
	# chan 6
	$ns_ at 30.0 "$ptraffic(6) start"
	$ns_ at 40.0 "$ptraffic(6) stop"
	$ns_ at 50.0 "$ptraffic(6) start"
	$ns_ at 60.0 "$ptraffic(6) stop"
	# chan 7
	$ns_ at 30.0 "$ptraffic(7) start"
	$ns_ at 40.0 "$ptraffic(7) stop"
} elseif {$val(pu)==9} {
	# chan 0
	$ns_ at 0.0 "$ptraffic(0) start"
	$ns_ at 10.0 "$ptraffic(0) stop"
	$ns_ at 210.0 "$ptraffic(0) start"
	$ns_ at 220.0 "$ptraffic(0) stop"
	# chan 1
	$ns_ at 110.0 "$ptraffic(1) start"
	$ns_ at 120.0 "$ptraffic(1) stop"
	# chan 2
	$ns_ at 60.0 "$ptraffic(2) start"
	$ns_ at 70.0 "$ptraffic(2) stop"
	# chan 3
	# no activity 
	# chan 4
	$ns_ at 10.0 "$ptraffic(4) start"
	$ns_ at 20.0 "$ptraffic(4) stop"
	$ns_ at 90.0 "$ptraffic(4) start"
	$ns_ at 100.0 "$ptraffic(4) stop"
	$ns_ at 240.0 "$ptraffic(4) start"
	# chan 5
	$ns_ at 30.0 "$ptraffic(5) start"
	$ns_ at 40.0 "$ptraffic(5) stop"
	# chan 6
	$ns_ at 30.0 "$ptraffic(6) start"
	$ns_ at 40.0 "$ptraffic(6) stop"
	$ns_ at 50.0 "$ptraffic(6) start"
	$ns_ at 60.0 "$ptraffic(6) stop"
	# chan 7
	$ns_ at 30.0 "$ptraffic(7) start"
	$ns_ at 40.0 "$ptraffic(7) stop"
	# chan 8
	# no activity
} elseif {$val(pu)==10} {
	# chan 0
	$ns_ at 0.0 "$ptraffic(0) start"
	$ns_ at 10.0 "$ptraffic(0) stop"
	$ns_ at 210.0 "$ptraffic(0) start"
	$ns_ at 220.0 "$ptraffic(0) stop"
	# chan 1
	$ns_ at 110.0 "$ptraffic(1) start"
	$ns_ at 120.0 "$ptraffic(1) stop"
	# chan 2
	$ns_ at 60.0 "$ptraffic(2) start"
	$ns_ at 70.0 "$ptraffic(2) stop"
	# chan 3
	# no activity 
	# chan 4
	$ns_ at 10.0 "$ptraffic(4) start"
	$ns_ at 20.0 "$ptraffic(4) stop"
	$ns_ at 90.0 "$ptraffic(4) start"
	$ns_ at 100.0 "$ptraffic(4) stop"
	$ns_ at 240.0 "$ptraffic(4) start"
	# chan 5
	$ns_ at 30.0 "$ptraffic(5) start"
	$ns_ at 40.0 "$ptraffic(5) stop"
	# chan 6
	$ns_ at 30.0 "$ptraffic(6) start"
	$ns_ at 40.0 "$ptraffic(6) stop"
	$ns_ at 50.0 "$ptraffic(6) start"
	$ns_ at 60.0 "$ptraffic(6) stop"
	# chan 7
	$ns_ at 30.0 "$ptraffic(7) start"
	$ns_ at 40.0 "$ptraffic(7) stop"
	# chan 8
	# no activity
	# chan 9
	$ns_ at 20.0 "$ptraffic(9) start"
	$ns_ at 30.0 "$ptraffic(9) stop"
}
