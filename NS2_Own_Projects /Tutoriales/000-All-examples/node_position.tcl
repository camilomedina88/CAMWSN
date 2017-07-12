# Smart meter
$n([expr $val(pu)+$val(nn)]) set X_ 4.5
$n([expr $val(pu)+$val(nn)]) set Y_ 1.0
$n([expr $val(pu)+$val(nn)]) set Z_ 0.0

# PU
if {$val(pu)==2} {
	$n(0) set X_ 2.0
	$n(0) set Y_ 8.5
	$n(0) set Z_ 0.0
	
	$n(1) set X_ 1.50
	$n(1) set Y_ 17.0
	$n(1) set Z_ 0.0
} elseif {$val(pu)==4} {
	$n(0) set X_ 2.0
	$n(0) set Y_ 8.5
	$n(0) set Z_ 0.0
	
	$n(1) set X_ 1.50
	$n(1) set Y_ 17.0
	$n(1) set Z_ 0.0

	$n(2) set X_ 4.5
	$n(2) set Y_ 7.0
	$n(2) set Z_ 0.0

	$n(3) set X_ 4.75
	$n(3) set Y_ 11.7
	$n(3) set Z_ 0.0
} elseif {$val(pu)==6} {
	$n(0) set X_ 2.0
	$n(0) set Y_ 8.5
	$n(0) set Z_ 0.0
	
	$n(1) set X_ 1.50
	$n(1) set Y_ 17.0
	$n(1) set Z_ 0.0

	$n(2) set X_ 4.5
	$n(2) set Y_ 7.0
	$n(2) set Z_ 0.0

	$n(3) set X_ 4.75
	$n(3) set Y_ 11.7
	$n(3) set Z_ 0.0

	$n(4) set X_ 4.0
	$n(4) set Y_ 18.0
	$n(4) set Z_ 0.0

	$n(5) set X_ 3.0
	$n(5) set Y_ 2.0
	$n(5) set Z_ 0.0
} elseif {$val(pu)==8} {
	$n(0) set X_ 2.0
	$n(0) set Y_ 8.5
	$n(0) set Z_ 0.0
	
	$n(1) set X_ 1.50
	$n(1) set Y_ 17.0
	$n(1) set Z_ 0.0

	$n(2) set X_ 4.5
	$n(2) set Y_ 7.0
	$n(2) set Z_ 0.0

	$n(3) set X_ 4.75
	$n(3) set Y_ 11.7
	$n(3) set Z_ 0.0

	$n(4) set X_ 4.0
	$n(4) set Y_ 18.0
	$n(4) set Z_ 0.0

	$n(5) set X_ 3.0
	$n(5) set Y_ 2.0
	$n(5) set Z_ 0.0

	$n(6) set X_ 4.0
	$n(6) set Y_ 5.0
	$n(6) set Z_ 0.0

	$n(7) set X_ 4.3
	$n(7) set Y_ 10.73
	$n(7) set Z_ 0.0
} elseif {$val(pu)==10} {
	$n(0) set X_ 2.0
	$n(0) set Y_ 8.5
	$n(0) set Z_ 0.0
	
	$n(1) set X_ 1.50
	$n(1) set Y_ 17.0
	$n(1) set Z_ 0.0

	$n(2) set X_ 4.5
	$n(2) set Y_ 7.0
	$n(2) set Z_ 0.0

	$n(3) set X_ 4.75
	$n(3) set Y_ 11.7
	$n(3) set Z_ 0.0

	$n(4) set X_ 4.0
	$n(4) set Y_ 18.0
	$n(4) set Z_ 0.0

	$n(5) set X_ 3.0
	$n(5) set Y_ 2.0
	$n(5) set Z_ 0.0

	$n(6) set X_ 4.0
	$n(6) set Y_ 5.0
	$n(6) set Z_ 0.0

	$n(7) set X_ 4.3
	$n(7) set Y_ 10.73
	$n(7) set Z_ 0.0

	$n(8) set X_ 4.21
	$n(8) set Y_ 8.99
	$n(8) set Z_ 0.0

	$n(9) set X_ 1.0
	$n(9) set Y_ 4.85
	$n(9) set Z_ 0.0
}

# SU
if {$val(nn)==1} {
	$n([expr $val(pu)]) set X_ 2.5
	$n([expr $val(pu)]) set Y_ 17.85
	$n([expr $val(pu)]) set Z_ 0.0
} elseif {$val(nn)==2} {
	$n([expr $val(pu)]) set X_ 2.5
	$n([expr $val(pu)]) set Y_ 17.85
	$n([expr $val(pu)]) set Z_ 0.0

	$n([expr $val(pu)+1]) set X_ 0.67
	$n([expr $val(pu)+1]) set Y_ 2.0
	$n([expr $val(pu)+1]) set Z_ 0.0
} elseif {$val(nn)==3} {
	$n([expr $val(pu)]) set X_ 2.5
	$n([expr $val(pu)]) set Y_ 17.85
	$n([expr $val(pu)]) set Z_ 0.0

	$n([expr $val(pu)+1]) set X_ 0.67
	$n([expr $val(pu)+1]) set Y_ 2.0
	$n([expr $val(pu)+1]) set Z_ 0.0

	$n([expr $val(pu)+2]) set X_ 3.42
	$n([expr $val(pu)+2]) set Y_ 9.30
	$n([expr $val(pu)+2]) set Z_ 0.0
} elseif {$val(nn)==4} {
	$n([expr $val(pu)]) set X_ 2.5
	$n([expr $val(pu)]) set Y_ 17.85
	$n([expr $val(pu)]) set Z_ 0.0

	$n([expr $val(pu)+1]) set X_ 0.67
	$n([expr $val(pu)+1]) set Y_ 2.0
	$n([expr $val(pu)+1]) set Z_ 0.0

	$n([expr $val(pu)+2]) set X_ 3.42
	$n([expr $val(pu)+2]) set Y_ 9.30
	$n([expr $val(pu)+2]) set Z_ 0.0

	$n([expr $val(pu)+3]) set X_ 4.75
	$n([expr $val(pu)+3]) set Y_ 16.0
	$n([expr $val(pu)+3]) set Z_ 0.0
} elseif {$val(nn)==5} {
	$n([expr $val(pu)]) set X_ 2.5
	$n([expr $val(pu)]) set Y_ 17.85
	$n([expr $val(pu)]) set Z_ 0.0

	$n([expr $val(pu)+1]) set X_ 0.67
	$n([expr $val(pu)+1]) set Y_ 2.0
	$n([expr $val(pu)+1]) set Z_ 0.0

	$n([expr $val(pu)+2]) set X_ 3.42
	$n([expr $val(pu)+2]) set Y_ 9.30
	$n([expr $val(pu)+2]) set Z_ 0.0

	$n([expr $val(pu)+3]) set X_ 4.75
	$n([expr $val(pu)+3]) set Y_ 16.0
	$n([expr $val(pu)+3]) set Z_ 0.0

	$n([expr $val(pu)+4]) set X_ 2.0
	$n([expr $val(pu)+4]) set Y_ 11.7
	$n([expr $val(pu)+4]) set Z_ 0.0
} elseif {$val(nn)==6} {
	$n([expr $val(pu)]) set X_ 2.5
	$n([expr $val(pu)]) set Y_ 17.85
	$n([expr $val(pu)]) set Z_ 0.0

	$n([expr $val(pu)+1]) set X_ 0.67
	$n([expr $val(pu)+1]) set Y_ 2.0
	$n([expr $val(pu)+1]) set Z_ 0.0

	$n([expr $val(pu)+2]) set X_ 3.42
	$n([expr $val(pu)+2]) set Y_ 9.30
	$n([expr $val(pu)+2]) set Z_ 0.0

	$n([expr $val(pu)+3]) set X_ 4.75
	$n([expr $val(pu)+3]) set Y_ 16.0
	$n([expr $val(pu)+3]) set Z_ 0.0

	$n([expr $val(pu)+4]) set X_ 2.0
	$n([expr $val(pu)+4]) set Y_ 11.7
	$n([expr $val(pu)+4]) set Z_ 0.0

	$n([expr $val(pu)+5]) set X_ 4.76
	$n([expr $val(pu)+5]) set Y_ 2.19
	$n([expr $val(pu)+5]) set Z_ 0.0
} elseif {$val(nn)==7} {
	$n([expr $val(pu)]) set X_ 2.5
	$n([expr $val(pu)]) set Y_ 17.85
	$n([expr $val(pu)]) set Z_ 0.0

	$n([expr $val(pu)+1]) set X_ 0.67
	$n([expr $val(pu)+1]) set Y_ 2.0
	$n([expr $val(pu)+1]) set Z_ 0.0

	$n([expr $val(pu)+2]) set X_ 3.42
	$n([expr $val(pu)+2]) set Y_ 9.30
	$n([expr $val(pu)+2]) set Z_ 0.0

	$n([expr $val(pu)+3]) set X_ 4.75
	$n([expr $val(pu)+3]) set Y_ 16.0
	$n([expr $val(pu)+3]) set Z_ 0.0

	$n([expr $val(pu)+4]) set X_ 2.0
	$n([expr $val(pu)+4]) set Y_ 11.7
	$n([expr $val(pu)+4]) set Z_ 0.0

	$n([expr $val(pu)+5]) set X_ 4.76
	$n([expr $val(pu)+5]) set Y_ 2.19
	$n([expr $val(pu)+5]) set Z_ 0.0

	$n([expr $val(pu)+6]) set X_ 2.83
	$n([expr $val(pu)+6]) set Y_ 1.0
	$n([expr $val(pu)+6]) set Z_ 0.0
} elseif {$val(nn)==8} {
	$n([expr $val(pu)]) set X_ 2.5
	$n([expr $val(pu)]) set Y_ 17.85
	$n([expr $val(pu)]) set Z_ 0.0

	$n([expr $val(pu)+1]) set X_ 0.67
	$n([expr $val(pu)+1]) set Y_ 2.0
	$n([expr $val(pu)+1]) set Z_ 0.0

	$n([expr $val(pu)+2]) set X_ 3.42
	$n([expr $val(pu)+2]) set Y_ 9.30
	$n([expr $val(pu)+2]) set Z_ 0.0

	$n([expr $val(pu)+3]) set X_ 4.75
	$n([expr $val(pu)+3]) set Y_ 16.0
	$n([expr $val(pu)+3]) set Z_ 0.0

	$n([expr $val(pu)+4]) set X_ 2.0
	$n([expr $val(pu)+4]) set Y_ 11.7
	$n([expr $val(pu)+4]) set Z_ 0.0

	$n([expr $val(pu)+5]) set X_ 4.76
	$n([expr $val(pu)+5]) set Y_ 2.19
	$n([expr $val(pu)+5]) set Z_ 0.0

	$n([expr $val(pu)+6]) set X_ 2.83
	$n([expr $val(pu)+6]) set Y_ 1.0
	$n([expr $val(pu)+6]) set Z_ 0.0

	$n([expr $val(pu)+7]) set X_ 3.05
	$n([expr $val(pu)+7]) set Y_ 6.88
	$n([expr $val(pu)+7]) set Z_ 0.0
} elseif {$val(nn)==9} {
	$n([expr $val(pu)]) set X_ 2.5
	$n([expr $val(pu)]) set Y_ 17.85
	$n([expr $val(pu)]) set Z_ 0.0

	$n([expr $val(pu)+1]) set X_ 0.67
	$n([expr $val(pu)+1]) set Y_ 2.0
	$n([expr $val(pu)+1]) set Z_ 0.0

	$n([expr $val(pu)+2]) set X_ 3.42
	$n([expr $val(pu)+2]) set Y_ 9.30
	$n([expr $val(pu)+2]) set Z_ 0.0

	$n([expr $val(pu)+3]) set X_ 4.75
	$n([expr $val(pu)+3]) set Y_ 16.0
	$n([expr $val(pu)+3]) set Z_ 0.0

	$n([expr $val(pu)+4]) set X_ 2.0
	$n([expr $val(pu)+4]) set Y_ 11.7
	$n([expr $val(pu)+4]) set Z_ 0.0

	$n([expr $val(pu)+5]) set X_ 4.76
	$n([expr $val(pu)+5]) set Y_ 2.19
	$n([expr $val(pu)+5]) set Z_ 0.0

	$n([expr $val(pu)+6]) set X_ 2.83
	$n([expr $val(pu)+6]) set Y_ 1.0
	$n([expr $val(pu)+6]) set Z_ 0.0

	$n([expr $val(pu)+7]) set X_ 3.05
	$n([expr $val(pu)+7]) set Y_ 6.88
	$n([expr $val(pu)+7]) set Z_ 0.0

	$n([expr $val(pu)+8]) set X_ 2.46
	$n([expr $val(pu)+8]) set Y_ 15.5
	$n([expr $val(pu)+8]) set Z_ 0.0
} elseif {$val(nn)==10} {
	$n([expr $val(pu)]) set X_ 2.5
	$n([expr $val(pu)]) set Y_ 17.85
	$n([expr $val(pu)]) set Z_ 0.0

	$n([expr $val(pu)+1]) set X_ 0.67
	$n([expr $val(pu)+1]) set Y_ 2.0
	$n([expr $val(pu)+1]) set Z_ 0.0

	$n([expr $val(pu)+2]) set X_ 3.42
	$n([expr $val(pu)+2]) set Y_ 9.30
	$n([expr $val(pu)+2]) set Z_ 0.0

	$n([expr $val(pu)+3]) set X_ 4.75
	$n([expr $val(pu)+3]) set Y_ 16.0
	$n([expr $val(pu)+3]) set Z_ 0.0

	$n([expr $val(pu)+4]) set X_ 2.0
	$n([expr $val(pu)+4]) set Y_ 11.7
	$n([expr $val(pu)+4]) set Z_ 0.0

	$n([expr $val(pu)+5]) set X_ 4.76
	$n([expr $val(pu)+5]) set Y_ 2.19
	$n([expr $val(pu)+5]) set Z_ 0.0

	$n([expr $val(pu)+6]) set X_ 2.83
	$n([expr $val(pu)+6]) set Y_ 1.0
	$n([expr $val(pu)+6]) set Z_ 0.0

	$n([expr $val(pu)+7]) set X_ 3.05
	$n([expr $val(pu)+7]) set Y_ 6.88
	$n([expr $val(pu)+7]) set Z_ 0.0

	$n([expr $val(pu)+8]) set X_ 2.46
	$n([expr $val(pu)+8]) set Y_ 15.5
	$n([expr $val(pu)+8]) set Z_ 0.0

	$n([expr $val(pu)+9]) set X_ 4.17
	$n([expr $val(pu)+9]) set Y_ 2.34
	$n([expr $val(pu)+9]) set Z_ 0.0		
} elseif {$val(nn)==11} {
	$n([expr $val(pu)]) set X_ 2.5
	$n([expr $val(pu)]) set Y_ 17.85
	$n([expr $val(pu)]) set Z_ 0.0

	$n([expr $val(pu)+1]) set X_ 0.67
	$n([expr $val(pu)+1]) set Y_ 2.0
	$n([expr $val(pu)+1]) set Z_ 0.0

	$n([expr $val(pu)+2]) set X_ 3.42
	$n([expr $val(pu)+2]) set Y_ 9.30
	$n([expr $val(pu)+2]) set Z_ 0.0

	$n([expr $val(pu)+3]) set X_ 4.75
	$n([expr $val(pu)+3]) set Y_ 16.0
	$n([expr $val(pu)+3]) set Z_ 0.0

	$n([expr $val(pu)+4]) set X_ 2.0
	$n([expr $val(pu)+4]) set Y_ 11.7
	$n([expr $val(pu)+4]) set Z_ 0.0

	$n([expr $val(pu)+5]) set X_ 4.76
	$n([expr $val(pu)+5]) set Y_ 2.19
	$n([expr $val(pu)+5]) set Z_ 0.0

	$n([expr $val(pu)+6]) set X_ 2.83
	$n([expr $val(pu)+6]) set Y_ 1.0
	$n([expr $val(pu)+6]) set Z_ 0.0

	$n([expr $val(pu)+7]) set X_ 3.05
	$n([expr $val(pu)+7]) set Y_ 6.88
	$n([expr $val(pu)+7]) set Z_ 0.0

	$n([expr $val(pu)+8]) set X_ 2.46
	$n([expr $val(pu)+8]) set Y_ 15.5
	$n([expr $val(pu)+8]) set Z_ 0.0

	$n([expr $val(pu)+9]) set X_ 4.17
	$n([expr $val(pu)+9]) set Y_ 2.34
	$n([expr $val(pu)+9]) set Z_ 0.0

	$n([expr $val(pu)+10]) set X_ 1.03
	$n([expr $val(pu)+10]) set Y_ 8.03
	$n([expr $val(pu)+10]) set Z_ 0.0
} elseif {$val(nn)==12} {
	$n([expr $val(pu)]) set X_ 2.5
	$n([expr $val(pu)]) set Y_ 17.85
	$n([expr $val(pu)]) set Z_ 0.0

	$n([expr $val(pu)+1]) set X_ 0.67
	$n([expr $val(pu)+1]) set Y_ 2.0
	$n([expr $val(pu)+1]) set Z_ 0.0

	$n([expr $val(pu)+2]) set X_ 3.42
	$n([expr $val(pu)+2]) set Y_ 9.30
	$n([expr $val(pu)+2]) set Z_ 0.0

	$n([expr $val(pu)+3]) set X_ 4.75
	$n([expr $val(pu)+3]) set Y_ 16.0
	$n([expr $val(pu)+3]) set Z_ 0.0

	$n([expr $val(pu)+4]) set X_ 2.0
	$n([expr $val(pu)+4]) set Y_ 11.7
	$n([expr $val(pu)+4]) set Z_ 0.0

	$n([expr $val(pu)+5]) set X_ 4.76
	$n([expr $val(pu)+5]) set Y_ 2.19
	$n([expr $val(pu)+5]) set Z_ 0.0

	$n([expr $val(pu)+6]) set X_ 2.83
	$n([expr $val(pu)+6]) set Y_ 1.0
	$n([expr $val(pu)+6]) set Z_ 0.0

	$n([expr $val(pu)+7]) set X_ 3.05
	$n([expr $val(pu)+7]) set Y_ 6.88
	$n([expr $val(pu)+7]) set Z_ 0.0

	$n([expr $val(pu)+8]) set X_ 2.46
	$n([expr $val(pu)+8]) set Y_ 15.5
	$n([expr $val(pu)+8]) set Z_ 0.0

	$n([expr $val(pu)+9]) set X_ 4.17
	$n([expr $val(pu)+9]) set Y_ 2.34
	$n([expr $val(pu)+9]) set Z_ 0.0

	$n([expr $val(pu)+10]) set X_ 1.03
	$n([expr $val(pu)+10]) set Y_ 8.03
	$n([expr $val(pu)+10]) set Z_ 0.0

	$n([expr $val(pu)+11]) set X_ 4.52
	$n([expr $val(pu)+11]) set Y_ 8.75
	$n([expr $val(pu)+11]) set Z_ 0.0
} elseif {$val(nn)==13} {
	$n([expr $val(pu)]) set X_ 2.5
	$n([expr $val(pu)]) set Y_ 17.85
	$n([expr $val(pu)]) set Z_ 0.0

	$n([expr $val(pu)+1]) set X_ 0.67
	$n([expr $val(pu)+1]) set Y_ 2.0
	$n([expr $val(pu)+1]) set Z_ 0.0

	$n([expr $val(pu)+2]) set X_ 3.42
	$n([expr $val(pu)+2]) set Y_ 9.30
	$n([expr $val(pu)+2]) set Z_ 0.0

	$n([expr $val(pu)+3]) set X_ 4.75
	$n([expr $val(pu)+3]) set Y_ 16.0
	$n([expr $val(pu)+3]) set Z_ 0.0

	$n([expr $val(pu)+4]) set X_ 2.0
	$n([expr $val(pu)+4]) set Y_ 11.7
	$n([expr $val(pu)+4]) set Z_ 0.0

	$n([expr $val(pu)+5]) set X_ 4.76
	$n([expr $val(pu)+5]) set Y_ 2.19
	$n([expr $val(pu)+5]) set Z_ 0.0

	$n([expr $val(pu)+6]) set X_ 2.83
	$n([expr $val(pu)+6]) set Y_ 1.0
	$n([expr $val(pu)+6]) set Z_ 0.0

	$n([expr $val(pu)+7]) set X_ 3.05
	$n([expr $val(pu)+7]) set Y_ 6.88
	$n([expr $val(pu)+7]) set Z_ 0.0

	$n([expr $val(pu)+8]) set X_ 2.46
	$n([expr $val(pu)+8]) set Y_ 15.5
	$n([expr $val(pu)+8]) set Z_ 0.0

	$n([expr $val(pu)+9]) set X_ 4.17
	$n([expr $val(pu)+9]) set Y_ 2.34
	$n([expr $val(pu)+9]) set Z_ 0.0

	$n([expr $val(pu)+10]) set X_ 1.03
	$n([expr $val(pu)+10]) set Y_ 8.03
	$n([expr $val(pu)+10]) set Z_ 0.0

	$n([expr $val(pu)+11]) set X_ 4.52
	$n([expr $val(pu)+11]) set Y_ 8.75
	$n([expr $val(pu)+11]) set Z_ 0.0

	$n([expr $val(pu)+12]) set X_ 4.57
	$n([expr $val(pu)+12]) set Y_ 10.99
	$n([expr $val(pu)+12]) set Z_ 0.0
} elseif {$val(nn)==14} {
	$n([expr $val(pu)]) set X_ 2.5
	$n([expr $val(pu)]) set Y_ 17.85
	$n([expr $val(pu)]) set Z_ 0.0

	$n([expr $val(pu)+1]) set X_ 0.67
	$n([expr $val(pu)+1]) set Y_ 2.0
	$n([expr $val(pu)+1]) set Z_ 0.0

	$n([expr $val(pu)+2]) set X_ 3.42
	$n([expr $val(pu)+2]) set Y_ 9.30
	$n([expr $val(pu)+2]) set Z_ 0.0

	$n([expr $val(pu)+3]) set X_ 4.75
	$n([expr $val(pu)+3]) set Y_ 16.0
	$n([expr $val(pu)+3]) set Z_ 0.0

	$n([expr $val(pu)+4]) set X_ 2.0
	$n([expr $val(pu)+4]) set Y_ 11.7
	$n([expr $val(pu)+4]) set Z_ 0.0

	$n([expr $val(pu)+5]) set X_ 4.76
	$n([expr $val(pu)+5]) set Y_ 2.19
	$n([expr $val(pu)+5]) set Z_ 0.0

	$n([expr $val(pu)+6]) set X_ 2.83
	$n([expr $val(pu)+6]) set Y_ 1.0
	$n([expr $val(pu)+6]) set Z_ 0.0

	$n([expr $val(pu)+7]) set X_ 3.05
	$n([expr $val(pu)+7]) set Y_ 6.88
	$n([expr $val(pu)+7]) set Z_ 0.0

	$n([expr $val(pu)+8]) set X_ 2.46
	$n([expr $val(pu)+8]) set Y_ 15.5
	$n([expr $val(pu)+8]) set Z_ 0.0

	$n([expr $val(pu)+9]) set X_ 4.17
	$n([expr $val(pu)+9]) set Y_ 2.34
	$n([expr $val(pu)+9]) set Z_ 0.0

	$n([expr $val(pu)+10]) set X_ 1.03
	$n([expr $val(pu)+10]) set Y_ 8.03
	$n([expr $val(pu)+10]) set Z_ 0.0

	$n([expr $val(pu)+11]) set X_ 4.52
	$n([expr $val(pu)+11]) set Y_ 8.75
	$n([expr $val(pu)+11]) set Z_ 0.0

	$n([expr $val(pu)+12]) set X_ 4.57
	$n([expr $val(pu)+12]) set Y_ 10.99
	$n([expr $val(pu)+12]) set Z_ 0.0

	$n([expr $val(pu)+13]) set X_ 1.78
	$n([expr $val(pu)+13]) set Y_ 0.89
	$n([expr $val(pu)+13]) set Z_ 0.0
} elseif {$val(nn)==15} {
	$n([expr $val(pu)]) set X_ 2.5
	$n([expr $val(pu)]) set Y_ 17.85
	$n([expr $val(pu)]) set Z_ 0.0

	$n([expr $val(pu)+1]) set X_ 0.67
	$n([expr $val(pu)+1]) set Y_ 2.0
	$n([expr $val(pu)+1]) set Z_ 0.0

	$n([expr $val(pu)+2]) set X_ 3.42
	$n([expr $val(pu)+2]) set Y_ 9.30
	$n([expr $val(pu)+2]) set Z_ 0.0

	$n([expr $val(pu)+3]) set X_ 4.75
	$n([expr $val(pu)+3]) set Y_ 16.0
	$n([expr $val(pu)+3]) set Z_ 0.0

	$n([expr $val(pu)+4]) set X_ 2.0
	$n([expr $val(pu)+4]) set Y_ 11.7
	$n([expr $val(pu)+4]) set Z_ 0.0

	$n([expr $val(pu)+5]) set X_ 4.76
	$n([expr $val(pu)+5]) set Y_ 2.19
	$n([expr $val(pu)+5]) set Z_ 0.0

	$n([expr $val(pu)+6]) set X_ 2.83
	$n([expr $val(pu)+6]) set Y_ 1.0
	$n([expr $val(pu)+6]) set Z_ 0.0

	$n([expr $val(pu)+7]) set X_ 3.05
	$n([expr $val(pu)+7]) set Y_ 6.88
	$n([expr $val(pu)+7]) set Z_ 0.0

	$n([expr $val(pu)+8]) set X_ 2.46
	$n([expr $val(pu)+8]) set Y_ 15.5
	$n([expr $val(pu)+8]) set Z_ 0.0

	$n([expr $val(pu)+9]) set X_ 4.17
	$n([expr $val(pu)+9]) set Y_ 2.34
	$n([expr $val(pu)+9]) set Z_ 0.0

	$n([expr $val(pu)+10]) set X_ 1.03
	$n([expr $val(pu)+10]) set Y_ 8.03
	$n([expr $val(pu)+10]) set Z_ 0.0

	$n([expr $val(pu)+11]) set X_ 4.52
	$n([expr $val(pu)+11]) set Y_ 8.75
	$n([expr $val(pu)+11]) set Z_ 0.0

	$n([expr $val(pu)+12]) set X_ 4.57
	$n([expr $val(pu)+12]) set Y_ 10.99
	$n([expr $val(pu)+12]) set Z_ 0.0

	$n([expr $val(pu)+13]) set X_ 1.78
	$n([expr $val(pu)+13]) set Y_ 0.89
	$n([expr $val(pu)+13]) set Z_ 0.0

	$n([expr $val(pu)+14]) set X_ 9.0
	$n([expr $val(pu)+14]) set Y_ 2.5
	$n([expr $val(pu)+14]) set Z_ 0.0
}
