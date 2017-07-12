global opt

ErrorModel set bandwidth_ 2Mb; # I can't do without it! --ke

set opt(errmodel)       "ON"            ;
#set opt(emtype)         ErrorModel/Weibull
ErrorModel/TwoStateMultiVar set rangeth_ 250; 
#the point to change the error model parameters
set opt(emtype)         ErrorModel/TwoStateMultiVar

set opt(tavgList) {2 0.01}
set opt(tparaList) {1 2 3 1 2 3} ;#used in weibull distribution.  a b scale a b scale.
set opt(tunit) "pkt"
set opt(tfileList) { cdf1 cdf2 }

set rv0 [new RandomVariable/Pareto]
set rv1 [new RandomVariable/Pareto]
set rv2 [new RandomVariable/Pareto]
set rv3 [new RandomVariable/Pareto]
$rv0 set avg_ 1
$rv1 set avg_ 1
$rv2 set avg_ 1
$rv3 set avg_ 1
$rv0 set shape_ 0.4289; #err-free, < range
$rv1 set shape_ 1.3876; #err, < range
$rv2 set shape_ 0.5940; #err-free, > range
$rv3 set shape_ 0.9141; #err, < range


set opt(trvlist) {$rv0 $rv1 $rv2 $rv3}

proc create-errmodel { etype {trate 0.5} } {
    global opt
    switch $etype {
	ErrorModel {
	    puts "test errmodel!\n"
	    set T [ new $etype ]
	    $T unit $opt(tunit);      # this value not binded to tcl, but used command
	    $T set rate_ $trate; # this value binded to tcl. WHY???
	    return $T
	}

	ErrorModel/Uniform {
	    return [ new $etype $trate $opt(tunit)]
	}

	ErrorModel/Expo {
	    return [ new $etype  $opt(tavgList) $opt(tunit)]
	}
	
	ErrorModel/TwoState {
	    return [ new $etype [lindex $opt(trvlist) 0] [lindex $opt(trvlist) 1]  $opt(tunit) ]
	}

	ErrorModel/TwoStateMultiVar {
	    return [ new $etype [lindex $opt(trvlist) 0] [lindex $opt(trvlist) 1] [lindex $opt(trvlist) 2] [lindex $opt(trvlist) 3]  $opt(tunit) ]
	}
	
	ErrorModel/Weibull {
	    return [ new $etype $opt(tparaList) $opt(tunit)]
	}

	ErrorModel/Empirical {
	    return [ new $etype  $opt(tfileList) $opt(tunit)]
	}

	default {
	    puts "error model type wrong! \n"
	}
    }
}
