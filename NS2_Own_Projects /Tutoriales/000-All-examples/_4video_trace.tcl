  # video_trace.tcl
  set ns [new Simulator]
  $ns color 1 Blue
  set nf [open out.nam w]
  $ns namtrace-all $nf
  # define the trace format:
  Agent/UDP set nam_tracevar_ true
  Agent/UDP set tracevar_ true
  # generate the sending node:
  set send_node [$ns node]
  # generate the routers:
  set router_node_1 [$ns node]
  $router_node_1 shape "box"
  set router_node_2 [$ns node]
  $router_node_2 shape "box"
  # generate the receiving node:
  set recv_node [$ns node]
  # define the links between the nodes:
  $ns duplex-link $send_node $router_node_1 1Mb 10ms DropTail
  $ns duplex-link $router_node_1 $router_node_2 1Mb 10ms DropTail
  $ns duplex-link $router_node_2 $recv_node 1Mb 10ms DropTail
  # orientation of the links:
  $ns duplex-link-op $send_node $router_node_1 orient down
  $ns duplex-link-op $router_node_1 $router_node_2 orient right
  $ns duplex-link-op $router_node_2 $recv_node orient up
  $ns duplex-link-op $router_node_1 $router_node_2 queuePos 0.5
  $ns duplex-link-op $router_node_2 $recv_node queuePos 0.5
  # set the maximal queue lengths of the routers:
  $ns queue-limit $router_node_1 $router_node_2 10 42
  $ns queue-limit $router_node_2 $recv_node 10
  # define the source and the source model:
  set udp [new Agent/UDP]
  $udp set fid_ 1
  $ns attach-agent $send_node $udp
  #$ns add-agent-trace $udp udp
  #$ns monitor-agent-trace $udp
  # define the destination:
  set snk [new Agent/Null]
  $snk set fid_ 1
  $ns attach-agent $recv_node $snk
  $ns connect $udp $snk
  # generate the video trace file ("Verbose_Jurassic_64.dat" is only an
  example):
  set original_file_name Verbose_Jurassic_64.dat
  set trace_file_name video.dat
  set original_file_id [open $original_file_name r]
  set trace_file_id [open $trace_file_name w]
  set last_time 0
  while {[eof $original_file_id] == 0} {
  gets $original_file_id current_line
  if {[string length $current_line] == 0 ||
  [string compare [string index $current_line 0] "#"] == 0} {
  continue
  }
  scan $current_line "%d%s%d" next_time type length
  set time [expr 1000*($next_time-$last_time)]
  set last_time $next_time
  puts -nonewline $trace_file_id [binary format "II" $time $length]
  }
  close $original_file_id
  close $trace_file_id
  # set the simulation end time:
  set end_sim_time [expr 1.0*$last_time/1000+0.001]
  # read the video trace file:
  set trace_file [new Tracefile]
  $trace_file filename $trace_file_name
  set video [new Application/Traffic/Trace]
  $video attach-agent $udp
  43
  $video attach-tracefile $trace_file
  # start the simulation:
  $ns at 0.0 {
  $send_node label "VIDEO-SERVER"
  $router_node_1 label "IP-ROUTER 1"
  $router_node_2 label "IP-ROUTER 2"
  $recv_node label "VIDEO-CLIENT"
  $video start
  }
  # stop the simulation:
  $ns at $end_sim_time {
  finish
  }
  proc finish {} {
  global ns nf
  $ns flush-trace
  close $nf
  exec nam out.nam &
  exit 0
  }
  $ns run

