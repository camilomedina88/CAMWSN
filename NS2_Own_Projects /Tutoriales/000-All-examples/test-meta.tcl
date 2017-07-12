#!/home/jokulik/ns/monarch/ns-src/ns
source /homes/wendi/temp/meta/ns-key-meta.tcl
source /homes/wendi/temp/meta/new-key-set.tcl

set seta [new Set/KeySet]
set setb [new Set/KeySet]

$seta pp 
$setb pp

puts "Add test"

$seta add "a"
$seta pp "Set a"

puts "Set b is"
$setb pp

 $seta addlist [list "a" "b" "c"]
 puts "Set a is"
 $seta pp
 puts "Set b is"
 $setb pp

 $setb addlist [list "c" "d" "a"]

 puts "Set a is"
 $seta pp
 puts "Set b is"
 $setb pp

 puts "Union test"

 puts "Union of set a and b is"
 $seta union $setb
$seta pp "Union"

 puts "Set a is"
 $seta pp
 puts "Set b is"
 $setb pp

 puts "Intersection test"

 puts "Set a is"
 $seta pp
 puts "Set b is"
 $setb pp

  

 puts "Intersection of set a and b."
 $seta intersection $setb

 puts "Set a is"
 $seta pp

 puts "Copy test"
 $setb copy setc

 puts "Set a is"
 $seta pp
 puts "Set b is"
 $setb pp
 puts "Set c is"
 setc pp


puts "Test of variables"

 puts "This is a"
 $seta pp

 puts "Adding w to a"
 $seta add "w"

 puts "Copy test 2"
 set baz [$seta copy]

 puts "Set a is"
 $seta pp
 puts "Copy of $seta is"
 $baz pp


 puts "Subtraction test"
 puts "Set a is"
 $seta pp
 puts "Set b is"
 $setb pp

 puts "Subtraction of set be from set a."
 $seta subtract $setb

 puts "Set a is"
 $seta pp

set setb [new KeyMetaData]
$setb pp "B"

$setb add "alls"
$setb add "well"
$setb add "that"

set foo [new Set/KeySet]
$foo add "a" "1"
$foo add "b"
$foo pp

set l [$foo settolist]

set b [lindex $l 0]
set c [lindex $b 0]
puts "The list is $l, $b, $c"

set baz [new Set/KeySet]
set l [$baz settolist]
$baz pp "Baz"
puts "The list for baz is $l"
