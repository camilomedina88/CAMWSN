
source $env(NS)/tcl/rpi/script-tools.tcl

puts -nonewline "script-tools.tcl Test:\t"

set n_tests 0
set n_tests_passed 0

# test list 
incr n_tests
set list { 0 9 8 -1 }
if { [list-min $list] == -1 } {
  incr n_tests_passed
} else {
  puts "FAIL!! list-min did not return the minimum of the list."
}

incr n_tests
if { [list-max $list] == 9 } {
  incr n_tests_passed
} else {
  puts "FAIL!! list-max did not return the minimum of the list."
}

incr n_tests
set m [list-mean $list]
if { $m == 4 } {
  incr n_tests_passed
} else {
    puts "FAIL!! list-mean did not return the mean (i..e, 4) of the list, but
          rather returned $m."       
}

# When dealing with entire population: Var[X] = E[X^2]-E[X]^2
# When dealing with samples, an unbiased estimator of variance
# is give by
#
#   v = 1/(n-1) Sum( (x_i - m)^2 )
#
# let m = sample mean
# let v = sample variance
# let n = number of samples
#
# v = 1/(n-1) [ x0^2 - 2 x0 m + m^2 + ... + xn^2 - 2 xn m + m^2 ]
#   = 1/(n-1) [ sumsq - 2 m sum(xi) + n m^2 ]
#   = 1/(n-1) [ sumsq - 2 sum(xi)^2 / n + sum(xi)^2 / n ]
# v = 1/(n-1) ( sumsq - sum * sum / n )
incr n_tests 
set lst { 1 2 -1 4 }
set v [list-variance $lst]
if { $v > 4.32 && $v < 4.34 } {
  incr n_tests_passed
} else {
  puts "FAIL!! list-variance did not return variance. Variance of
        $lst is 4.34, but list-variance returned $v."
}


incr n_tests
set sdev [list-stddev $lst]
if { $sdev > [expr sqrt(4.32)] && $sdev < [expr sqrt(4.34)] } {
  incr n_tests_passed
} else {
  puts "FAIL!! list-stddev did not return standard deviation of 4.25."
}

# sdev / mean = sqrt(4.33) / 1.5 = 1.39...
incr n_tests
set cov [list-cov $lst]
if { $cov > 1.38 && $cov < 1.40 } {
  incr n_tests_passed
} else {
  puts "FAIL!! list-cov did not return coefficient of variation.  We expected
    1.39, but we obtained $cov." 
}

# Test t2sec
#
# m = milliseconds
# s = seconds
# u = microseconds
# n = nanoseconds
# p = picoseconds
# h != hours.  h means nothing.
# d != days.   d means nohting.
# y != years

incr n_tests
set t [t2sec 12]
if { $t == "12" } {
  incr n_tests_passed
} else {
  puts "FAIL!! t2sec on \"12\" returned $t."
}

incr n_tests
set t [t2sec 12s]
if { $t == "12" } {
  incr n_tests_passed
} else {
  puts "FAIL!! t2sec on \"12s\" returned $t."
}

incr n_tests
set t [t2sec 5pacose]  ;# The characters after p are ignored.
if { $t > 4.9e-12 && $t < 5.1e-12 } {
  incr n_tests_passed
} else {
  puts "FAIL!! t2sec on \"5pacose\" returned $t rather than 5e-12."
}

incr n_tests
set t [t2sec 3NS]
if { $t > 2.9e-9 && $t < 3.1e-9 } {
  incr n_tests_passed
} else {
  puts "FAIL!! t2sec on \"3NS\" returned $t rather than 3e-9."
}

incr n_tests
set t [t2sec 3ns]
if { $t > 2.9e-9 && $t < 3.1e-9 } {
  incr n_tests_passed
} else {
  puts "FAIL!! t2sec on \"3ns\" returned $t rather than 3e-9."
}

incr n_tests
set bw [bw2bps 10]
if { $bw > 9.99 && $bw < 10.01 } {
  incr n_tests_passed
} else {
  puts "FAIL!! bw2bps on \"10\" returned $bw ratehr than 10."
}

incr n_tests
set bw [bw2bps 1M]
if { $bw > .99e6 && $bw < 1.01e6 } {
  incr n_tests_passed
} else {
  puts "FAIL!! bw2bps on \"1M\" returned $bw rather than 1e6."
}

incr n_tests
set bw [bw2bps 1m]
if { $bw > .99e6 && $bw < 1.01e6 } {
  incr n_tests_passed
} else {
  puts "FAIL!! bw2bps on \"1m\" returned $bw rather than 1e6."
}

incr n_tests
set bw [bw2bps 10K]
if { $bw > 9999 && $bw < 10000.1 } {
  incr n_tests_passed
} else {
  puts "FAIL!! bw2bps on \"10K\" returned $bw rather than 10000."
}

incr n_tests
set bw [bw2bps 2g]
if { $bw > 1.99e9 && $bw < 2.01e9 } {
  incr n_tests_passed
} else {
  puts "FAIL!! bw2bps on \"2g\" returned $bw rather than 2e9."
}

incr n_tests
set bw [bw2bps 2t]
if { $bw > 1.99e12 && $bw < 2.01e12 } {
  incr n_tests_passed
} else {
  puts "FAIL!! bw2bps on \"2t\" returned $bw rather than 2e12."
}

if { $n_tests_passed == $n_tests } {
  puts "PASSED all $n_tests tests."
} else {
  puts "FAILURE.  Passed only $n_tests_passed out of $n_tests script-tools.tcl tests."
}

