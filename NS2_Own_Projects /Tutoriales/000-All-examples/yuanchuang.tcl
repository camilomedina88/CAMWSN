#     http://www.osedu.net/yuanchuang-article/ns2/2011-07-22/273.html


set ns [new Simulator]

#  1、拓扑结构和流量源
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]

$ns duplex-link $n0 $n3 1Mb 100ms DropTail
$ns duplex-link $n1 $n3 1Mb 100ms DropTail
$ns duplex-link $n2 $n3 1Mb 100ms DropTail
$ns duplex-link $n3 $n4 1Mb 100ms DropTail

#  2、在向节点添加流量源之前，首先编写一个添加源和发生器的代码
proc attach-expoo-traffic { node sink size burst idle rate } {
    #Get an instance of the simulator
    set ns [Simulator instance]

    #Create a UDP agent and attach it to the node
    set source [new Agent/UDP]
    $ns attach-agent $node $source

    #Create an Expoo traffic agent and set its configuration parameters
    set traffic [new Application/Traffic/Exponential]
    $traffic set packetSize_ $size
    $traffic set burst_time_ $burst
    $traffic set idle_time_ $idle
    $traffic set rate_ $rate
       
        # Attach traffic source to the traffic generator
        $traffic attach-agent $source
    #Connect the source and the sink
    $ns connect $source $sink
    return $traffic
}
## 该过程中有6个参数：节点，前面创建的sink，流量源的数据包大小，burst和idle时间(用于指数增长)和 peak rate。

## 首先创建一个流量源并附加到一个节点，接着创建一个Traffic/Expoo object，设置参数并附加到流量源，然后连接sink和源。最终，返回流量源的句柄。该过程可以用于重复把一个流量源附加到多个节点。例如，下面在节点n4附加三个流量sink，并把附加到节点n0,n1,n2的peak rate流量源连接到这三个sink。

set sink0 [new Agent/LossMonitor]
set sink1 [new Agent/LossMonitor]
set sink2 [new Agent/LossMonitor]
$ns attach-agent $n4 $sink0
$ns attach-agent $n4 $sink1
$ns attach-agent $n4 $sink2

set source0 [attach-expoo-traffic $n0 $sink0 200 2s 1s 100k]
set source1 [attach-expoo-traffic $n1 $sink1 200 2s 1s 200k]
set source2 [attach-expoo-traffic $n2 $sink2 200 2s 1s 300k]

#  3、在输出文件中记录数据
## 首先打开三个输出文件。
set f0 [open out0.tr w]
set f1 [open out1.tr w]
set f2 [open out2.tr w]

## 创建一个finish过程，关闭这些文件。同时，调用xgraph显示结果。并设置窗口大小(800x400)。

proc finish {} {
        global f0 f1 f2
        #Close the output files
        close $f0
        close $f1
        close $f2
        #Call xgraph to display the results
        exec xgraph out0.tr out1.tr out2.tr -geometry 800x400 &
        exit 0
}


## 下面是实际向文件中添加记录的过程
proc record {} {
        global sink0 sink1 sink2 f0 f1 f2
        #Get an instance of the simulator
        set ns [Simulator instance]
        #Set the time after which the procedure should be called again
        set time 0.5
        #How many bytes have been received by the traffic sinks?
        set bw0 [$sink0 set bytes_]
        set bw1 [$sink1 set bytes_]
        set bw2 [$sink2 set bytes_]
        #Get the current time
        set now [$ns now]
        #Calculate the bandwidth (in MBit/s) and write it to the files
        puts $f0 "$now [expr $bw0/$time*8/1000000]"
        puts $f1 "$now [expr $bw1/$time*8/1000000]"
        puts $f2 "$now [expr $bw2/$time*8/1000000]"
        #Reset the bytes_ values on the traffic sinks
        $sink0 set bytes_ 0
        $sink1 set bytes_ 0
        $sink2 set bytes_ 0
        #Re-schedule the procedure
        $ns at [expr $now+$time] "record"
}
## 该过程读取接收的流量sink的字节数目。然后计算带宽并向输出文件中写入结果和当前时间，重设bytes_，最后重新调用record过程。

#  4、运行仿真

$ns at 0.0 "record"
$ns at 10.0 "$source0 start"
$ns at 10.0 "$source1 start"
$ns at 10.0 "$source2 start"
$ns at 50.0 "$source0 stop"
$ns at 50.0 "$source1 stop"
$ns at 50.0 "$source2 stop"
$ns at 60.0 "finish"


$ns run

## 首先调用record过程，并且该过程会每隔0.5秒钟重新调用自身。最后，调用finish过程。 
