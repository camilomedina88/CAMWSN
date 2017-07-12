proc SetPositive {variable value } {
    upvar $variable myvar
    if {$value < 0} {
        set myvar [expr {-$value}]
    } else {
        set myvar $value
    }
    return $myvar
}

SetPositive x 5
SetPositive y -5

puts "X : $x    Y: $y\n"

proc two {y} {
    upvar 1 $y z                    ;# tie the calling value to variable z
    upvar 2 x a                     ;# Tie variable x two levels up  to a
    puts "two: Z: $z A: $a"         ;# Output the values, just to confirm
    set z 1                         ;# Set z, the passed variable to 1;
    set a 2                         ;# Set x, two layers up to 2;
}

proc one {y} {
    upvar $y z                      ;# This ties the calling value to variable z 
    puts "one: Z: $z"               ;# Output that value, to check it is 5
    two z                           ;# call proc two, which will change the value
}

one y                               ;# Call one, and output X and Y after the call.
puts "\nX: $x  Y: $y"


proc existence {variable} {
    upvar $variable testVar
    if { [info exists testVar] } {
        puts "$variable Exists"
    } else {
        puts "$variable Does Not Exist"
    }
}

set x 1
set y 2
for {set i 0} {$i < 5} {incr i} {
    set a($i) $i;
}

puts "\ntesting unsetting a simple variable"
# Confirm that x exists.
existence x
# Unset x
unset x
puts "x has been unset"
# Confirm that x no longer exists.
existence x