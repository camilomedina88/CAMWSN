# Copyright(c)2001 David Harrison. 
# Copyright(c)2005 David Harrison
# Licensed according to the terms of the GNU Public License.
##
# tools for handling files via TCL.
#
#  create-tmp-directory  creates a unique directory in /tmp.
#  file-max              returns max value in ith column in ws delimited file.
#  file-min              returns min value in ith column in ws delimited file.
#  file-var              returns variance of ith column in ws delimited file.
#  file-stddev           returns standard deviation of ith column " " " file.
#
# Author: D. Harrison
#


# If more than "warning_tmp_directory_cnt_" /tmp/expXX directories then 
# create-tmp-directory prints a warning telling user how to eliminate
# temp directories.  If "warning_requires_user_hit_return_" is true
# then create-tmp-directory will pause the simulation until the user
# hits return before running the simulation when either 
# warning_tmp_directory_cnt_ warnings are printed.
#
# I wanted to print out a low-disk space warning, but there doesn't
# appear to be an easy, cross-platform mechanism in TCL to determine
# diskspace without intentionally using up all diskspace just to see
# how much space there is (not a viable solution).
# 
# Gang Wang and Yong Xia
# Create data and graph directories to store results seperately.

set warning_tmp_directory_cnt_ 1000 
set warning_requires_user_hit_return_ true


# Creates a directory in /tmp that has a unique name and
# returns the directory's name including /tmp. Ex:
# It might return /tmp/exp23
# If an error occurs this returns the empty string, i.e., "".
proc create-tmp-directory {} {
  global warning_tmp_directory_cnt_ ;#low_disk_space_warning_
  global warning_requires_user_hit_return_

  set warned false
  for { set i 0 } { 1 } { incr i } {
    if { $i > $warning_tmp_directory_cnt_ && $warned == "false" } {
      puts "

You have more than $warning_tmp_directory_cnt_\
directories in /tmp.  The RPI graph package outputs 
temporary files in /tmp/expX where X is increment with each simulation.
You may want to delete some of these old directories."

      if { $warning_requires_user_hit_return_ } {
        puts "

Hit return to continue simulation."
        gets stdin
      }

      set warned true
    }
  
    if { ![ file exists "/tmp/exp$i"] } {
      file mkdir "/tmp/exp$i"
      file mkdir "/tmp/exp$i/data"
      file mkdir "/tmp/exp$i/figure"
      return "/tmp/exp$i"
    }
  }
}


# returns maximum value for the given column
# among the files in the passed filelist. The files in the
# filelist must be tab-delimited text. Column numbers start
# from zero.
proc file-max { column filelist } {
  set INFINITY 1e32
  set max [expr -1.0 * $INFINITY]
  set column [expr $column + 1]  ;# use awk's column numbering scheme.
  for { set i 0 } { $i < [llength $filelist] } { incr i } {
    set file_max [exec awk "
      BEGIN { x=[expr -1.0 * $INFINITY] }
        {
          if ( \$$column > x ) x = \$$column
        }
      END { printf \"%f\\n\", x }
    " [lindex $filelist $i]]
    if { $file_max > $max } {
      set max $file_max 
    }
  }
  return $max
}

proc file-min { column filelist } {
  set INFINITY 1e32
  set min $INFINITY
  set column [expr $column + 1]  ;# use awk's column numbering scheme.
  for { set i 0 } { $i < [llength $filelist] } { incr i } {
    set file_min [exec awk "
      BEGIN { x=$INFINITY }
        {
          if ( \$$column < x ) x = \$$column
        }
      END { printf \"%f\\n\", x }
    " [lindex $filelist $i]]
    if { $file_min < $min } {
      set min $file_min 
    }
  }
  return $min
}

# returns the mean of all entries in the specified column in the passed
# filelist. Column numbers start from zero (i.e., leftmost columns is zero).
# Each entry is equally weighted in the mean which file contains the
# entry and the number of entries in each file are ignored.
proc file-mean { column filelist } {
  set sum 0.0
  set n 0
  set column [expr $column + 1]  ;# use awk's column numbering scheme.
  for { set i 0 } { $i < [llength $filelist] } { incr i } {
    set sum_n [exec awk "
      BEGIN { sum=0.0; n=0.0 }
        {
          sum = sum + \$$column
          n = n + 1.0
        }
      END { printf \"%f %f\\n\", sum, n }
    " [lindex $filelist $i]]
    set sum [expr $sum + [lindex $sum_n 0]]
    puts "file-mean: sum_n=\"$sum_n\""
    set n [expr $n + [lindex $sum_n 1]]
  }
  return [expr $sum / $n]
}

# returns sum across all entries in the specified column in the passed filess
proc file-sum { column filelist } { 
  set sum 0.0
  set n 0
  set column [expr $column + 1]  ;# use awk's column numbering scheme.
  for { set i 0 } { $i < [llength $filelist] } { incr i } {
    set sum_n [exec awk "
      BEGIN { sum=0.0 }
        {
          sum = sum + \$$column
        }
      END { printf \"%f\\n\", sum }
    " [lindex $filelist $i]]
    set sum [expr $sum + [lindex $sum_n 0]]
  }
  return $sum
}

# Returns sample variance of the values in the ith column across all of the
# files in the passed filelist, where i is specified in the $column argument.
# Column 0 is the leftmost column.  The same result would be eachieved by 
# concatenating the files and then running file-var on the concatenated file. 
#
# When dealing with entire population: 
#    Var[X] = E[X^2]-E[X]^2                              (1)
#
# Unfortunately, when given a sample, we do not know the population mean.
# We only know the sample mean.  Although the sample mean will approach
# the population mean for large samples, the sample mean and population
# mean will almost always be different values, and this difference
# will be in a direction that reduces a variance computed by directly
# applying equation (1), i.e.,
# 
#   sample variance != 1/n Sum(x_i^2) - m^2              (2)
#
# where m = Sum(x_i)
#
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
#
# This function returns v.
proc file-var { column filelist } {
  set sum 0.0
  set sqsum 0.0
  set n 0
  set column [expr $column + 1]  ;# use awk's column numbering scheme.
  for { set i 0 } { $i < [llength $filelist] } { incr i } {
    set returned_string [exec awk "
      BEGIN { sum=0.0; sqsum = 0.0; n = 0.0 }
        {
          sum = sum + \$$column
          n = n + 1.0
          sqsum = sqsum + (sum*sum) 
        }
      END { print \"%f %f %f\", n, sum, sqsum }
    " [lindex $filelist $i]]

    set n [expr $n + [lindex $returned_string 0]]
    set sum [expr $sum + [lindex $returned_string 1]]
    set sqsum [expr $sqsum + [lindex $returned_string 2]]
  }
  return [expr 1/($n-1) ( $sumsq - $sum * $sum / $n )]
}

# Returns the square root of the variance estimate returned from
# file-var.  (see file-var above)
proc file-stddev { column filelist } {
  set stddev [file-stddev $column $filelist]

  return [expr sqrt([file-var $column $filelist])]
}
