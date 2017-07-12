proc showAgent {arg1 arg2} {

   foreach cl [$arg1 info subclass] {

   set head |-

   for {set i 2} {$i <= $arg2} {incr i 1} {

      append head -

   }   append head $cl

   puts $head

   if {[$cl info subclass]!=""} {

      showAgent $cl [expr $arg2 + 1]

}

   }

}

set name [lindex $argv 0]

puts $name

showAgent $name 1
