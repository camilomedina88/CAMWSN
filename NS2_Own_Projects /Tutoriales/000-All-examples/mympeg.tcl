set ns [new Simulator]
set packetSize  200

set s1 [$ns node]
set d1 [$ns node]
set r1 [$ns node]
set r2 [$ns node]

$ns simplex-link $s1 $r1 10Mb 1ms DropTail
$ns simplex-link $r1 $s1 10Mb 1ms DropTail
$ns simplex-link $r1 $r2 1.024Mb 1ms dsRED/core
$ns simplex-link $r2 $r1 1.024Mb 1ms DropTail
$ns simplex-link $r2 $d1 10Mb 1ms DropTail
$ns simplex-link $d1 $r2 10Mb 1ms DropTail

set q1 [[$ns link $r1 $r2] queue]
$q1 meanPktSize $packetSize
$q1 set numQueues_ 1
$q1 setNumPrec 3
$q1 set limit_ 10
$q1 addPHBEntry 10 0 0
$q1 addPHBEntry 11 0 1
$q1 addPHBEntry 12 0 2
$q1 configQ 0 0 6 8 0.025
$q1 configQ 0 1 4 6 0.05
$q1 configQ 0 2 2 4 0.10

set udp1 [new Agent/UDP]
$ns attach-agent $s1 $udp1
$udp1 set packetSize_ $packetSize
set null1 [new Agent/MyUdpSink] 
$ns attach-agent $d1 $null1
$ns connect $udp1 $null1

$null1 set_filename output_result_flow1.dat
set original_file_name Verbose_StarWarsIV.dat
set trace_file_name video1.dat
set original_file_id [open $original_file_name r]
set trace_file_id [open $trace_file_name w]

set frame_count 0

while {[eof $original_file_id] == 0} {

    gets $original_file_id current_line
    scan $current_line "%d%s%d%d" seq_ frametype_ nexttime_ length_

    # 25Frames/sec ( 1000/25 = 40ms = 40000 us)
    set time [expr 1000*40]

    if { $frametype_ == "I" } {
      set type_v 1
    }      

    if { $frametype_ == "P" } {
      set type_v 2
    }      

    if { $frametype_ == "B" } {
      set type_v 3
    }      

    puts $trace_file_id "$time $length_ $type_v $seq_"
    incr frame_count
}

close $original_file_id
close $trace_file_id
set end_sim_time [expr 1.0 * 40 * ($frame_count)  / 1000]
puts "$end_sim_time"

set trace_file [new Tracefile]
$trace_file filename $trace_file_name
set video1 [new Application/Traffic/myTrace]
$video1 attach-agent $udp1
$video1 attach-tracefile $trace_file

proc finish {} {
    global ns 
    exit 0
}

$ns at 0.0 "$video1 start"
$ns at $end_sim_time "$video1 stop"
$ns at $end_sim_time "$null1 closefile"
$ns at [expr $end_sim_time + 1.0] "finish"

$ns run
