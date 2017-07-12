# -*-	Mode:C++; c-basic-offset:4; tab-width:4; indent-tabs-mode:t -*-
#  Copyright (C) 2011 Kazuya Sakai. Allright Received.
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by 
#  the Free Software Foundation, either version 3 of the License or any
#  later version.
# 
#  This program is distributed in the hope that it will be useful,
#  but without any warranty, including any implied warranty for 
#  merchantability or fitness for a particular purpose. Under no
#  circumstances shall Kazuya Sakai be liable for any use of, misuse of,
#  or inability to use this software, including incidental and 
#  consequential damages.
# 
#  You should have received a copy of the GNU General Public License along
#  with this program; if not, see <http://www.gnu.org/licenses/>
# 
#  Author: Kazuya Sakai, The Ohio State University
#  
#  Greedy forwarding code for ns2 version 2.34
# 

# This script calculates distance between two ndoes and
# sets the the neighbors information.

# This procesure returns the distance between two nodes.
proc get-distance {n1x n1y n2x n2y} {
	set dx	[expr [expr $n1x - $n2x] * [expr $n1x - $n2x]]
	set dy	[expr [expr $n1y - $n2y] * [expr $n1y - $n2y]]
	set d	[expr sqrt([expr $dx + $dy])]
	return $d
}

for {set i 0} {$i < [expr $val(nn) - 1]} {incr i} {
	set ragent1 [$node_($i) get-ragent]
	for {set j [expr $i + 1]} {$j < $val(nn)} {incr j} {
		set ragent2 [$node_($j) get-ragent]
		set d [get-distance	[$node_($i) set X_] [$node_($i) set Y_] \
							[$node_($j) set X_] [$node_($j) set Y_]]
		if {$d <= $val(radius)} {
			$node_($i) set-nbr $j [$node_($j) set X_] [$node_($j) set Y_]
			$node_($j) set-nbr $i [$node_($i) set X_] [$node_($i) set Y_]
		}
	}
}
