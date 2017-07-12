# Tarcisio Coutinho
# Centro de Informática - UFPE
# 
# Redes de Computadores - 2011.2


# Cria um objeto simulator
set ns [new Simulator]

# Cores para os fluxos de dados ($ns color fid color) - fid: id do fluxo
$ns color 1 Blue
$ns color 2 Red

#Trace file
set tr [open out.tr w]
set nf [open out.nam w]

$ns trace-all $tr
# diz ao simulador para gravar os caminhos da simulação no formato de entrada do NAM
# $ns namtrace-all file-descriptor
$ns namtrace-all $nf


#Finish procedure
proc finish {} {
	global ns nf tr
	$ns flush-trace
	#Close file
	close $nf
	close $tr
	#Executa animador
	exec nam out.nam &
	exit 0
}

# Topology
#               n0 (tcp) (ftp)
# 2mbps, 10ms    \                           
#                 \     1.7 mbps, 20ms     (sink)
#                 n2 ----------------- n3 (null)
# 2mbps, 10ms     /
#                /
#               n1 (udp) (cbr) pkt size: 1kbyte, rate 1mbps
#             
#
#           +ftp                           -ftp
#    +cbr                                        -cbr
#  +--------+---------+----------+---------+-----+----+ 
#  0        1         2          3         4    4.5   5



set numNode 8
# Criação dos nós
for {set i 0} {$i < $numNode} {incr i} {
	set n($i) [$ns node]
}
# Criação dos enlaces
for {set i 0} {$i < $numNode} {incr i} {
	for {set j [expr ($i + 1)]} {$j < $numNode} {incr j} {
		$ns duplex-link $n($i) $n($j) 1Mb 10ms DropTail
	}
}


#Tamanho da Fila (n2-n3) ($ns queue-limit node1 node2 number)
$ns queue-limit $n2 $n3 10

#Monitor da fila (n2-n3)
$ns duplex-link-op $n2 $n3 queuePos 0.5

#Setup TCP
#Agente n0
set tcp [new Agent/TCP]
$tcp set class_ 2
$ns attach-agent $n0 $tcp
#Agente n3 (receiver)
set sink [new Agent/TCPSink]
# $ns attach-agent node agent
$ns attach-agent $n3 $sink
#Conexao entre eles ($ns connect agent1 agent2)
$ns connect $tcp $sink
$tcp set fid_ 1

#Setup FTP over TCP
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set type_ FTP
$ftp set packet_size_ 10000
$ftp set interval_ 0.0008

#Setup UDP 
set udp [new Agent/UDP]
$ns attach-agent $n1 $udp

set null [new Agent/Null]
$ns attach-agent $n3 $null

#Conxao entre eles
$ns connect $udp $null
$udp set fid_ 2

#Setup CBR(Constant bit-rate)  over UDP
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 100
$cbr set rate_ 1mb
$cbr set random_ false

#Programando eventos
$ns at 0.1 "$cbr start"
$ns at 1.0 "$ftp start"
$ns at 4.0 "$ftp stop"
$ns at 4.5 "$cbr stop"

#desligar agentes Tcp e Sink
$ns at 4.5 "$ns detach-agent $n0 $tcp ; $ns detach-agent $n3 $sink"

#chamar metodo finish
$ns at 5.0 "finish"

#Print CBR packet size and interval
puts "CBR packet size = [$cbr set packet_size_]"
puts "CBR interval = [$cbr set interval_]"

#Print FTP packet size and interval
puts "FTP packt size = [$ftp set packet_size_]"
puts "FTP packt size = [$ftp set interval_]"

set now [$ns now]
puts "Estatisticas:"
puts "Tempo Simulacao:  $now s"


#Executar simulacao
$ns run
