# 15Feb03RT - non standard test style invokes single file test
# repeatedly using different macro delimiters
# Notice use of varying lengths and mismatched lengths.
# NOTE: hard to try >> here because of exec
puts "TESTING 9 PASSES OF DIFFERENT DELIMITERS"

puts "%%%%%%%%%%%%%%%%%%%% PASS -1 "
puts [exec tclsh tmac.test ]

puts "%%%%%%%%%%%%%%%%%%%% PASS -2 "
puts [exec tclsh tmac.test -delimiters |* *|]

puts "%%%%%%%%%%%%%%%%%%%% PASS -3 "
puts [exec tclsh tmac.test -delimiters % ~ ]

puts "%%%%%%%%%%%%%%%%%%%% PASS -4 "
puts [exec tclsh tmac.test -delimiters (* *)]

puts "%%%%%%%%%%%%%%%%%%%% PASS -5 "
puts [exec tclsh tmac.test -delimiters % ))))]

puts "%%%%%%%%%%%%%%%%%%%% PASS -6 "
puts [exec tclsh tmac.test -delimiters ((((( ~]

puts "%%%%%%%%%%%%%%%%%%%% PASS -7 "
puts [exec tclsh tmac.test -delimiters {[~} ))))))))) ]

puts "%%%%%%%%%%%%%%%%%%%% PASS -8 "
puts [exec tclsh tmac.test -delimiters {[-} {-]} ]

puts "%%%%%%%%%%%%%%%%%%%% PASS -9 "
puts [exec tclsh tmac.test -delimiters =-  -= ]

