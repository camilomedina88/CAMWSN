# Tarcisio Coutinho
# Centro de Informática - UFPE
# 
# Redes de Computadores - 2011.2


# Parametros Camada Transporte
#
# packetSize: Tamanho pacote Bytes (TCP e UDP) 
# ttl: Time-to-live (TCP e UDP)
# windowSize: Janela de conexao TCP (Numero de pacotes)
# cwnd: Janela de congestionamento TCP (Numero de pacotes) 
# windowInit: Janela inicial de congestionamento TCP
# maxBurst: Numero maximo de pacotes que o emissor pode enviar ao responder a um ACK

set packetSize 7184

#set ttl 32
#set windowSize 10
#set cwnd 0
#set windowInit 1
#set maxBurst 10


# Parametros Camada Aplicacao
#
# rate: Taxa de envio de pacotes (CBR - Constant Bit Rate)
# interval: Intervalo de envio dos pacotes
# cbrPacketSize: Tamanho dos pacotes
# maxPackets: Numero maximo de pacotes gerados pela fonte (FTP)

set rate 448kb
set interval 0.005
set cbrPacketSize 500
set maxPackets 10000

# Cria um objeto simulator
set ns [new Simulator]

# Cores para os fluxos de dados ($ns color fid color) - fid: id do fluxo
$ns color 1 Blue
$ns color 2 Red

#Trace file
set tr [open out.tr w]
$ns trace-all $tr

# diz ao simulador para gravar os caminhos da simulação no formato de entrada do NAM
#set nf [open out.nam w]
#$ns namtrace-all $nf


#Finish procedure
proc finish {} {
	global ns tr
#	global nf
	$ns flush-trace
	
#	close $nf
	close $tr
	
#	global sink
#	puts "[expr 8 * [$sink set bytes_] / 40000]"
	#Executa animador
#	exec nam out.nam &
	exit 0
}

# Topology
#               
#                  10 mbps, 100ms    
#            n0 ----------------- n2  (sink) - Receiver TCP
#           (tcp) (ftp)
#   ++ftp                                 -ftp
#  +--------+---------+----------+---------+-----+ (s)
#  0        10       20         30        40    45   



#Create nodes
set n0 [$ns node]
set n1 [$ns node]

#Create links ($ns duplex-link node1 node2 bandwidth delay queue-type)
$ns duplex-link $n0 $n1 10.0Mb 50ms DropTail

$ns duplex-link-op $n0 $n1 orient right


#Tamanho da Fila (n1-n2) ($ns queue-limit node1 node2 number)
#$ns queue-limit $n1 $n2 10

#Setup TCP
set tcp [new Agent/TCP]

$tcp set class_ 2
$tcp set fid_ 1
$tcp set packetSize_ $packetSize
#$tcp set ttl_ $ttl
#$tcp set window_ $windowSize
#$tcp set cwnd_ $cwnd
#$tcp set windowInit_ $windowInit
#$tcp set maxburst_ $maxBurst

$ns attach-agent $n0 $tcp
#Agente n3 (receiver)
set sink [new Agent/TCPSink]
# $ns attach-agent node agent
$ns attach-agent $n1 $sink
#Conexao entre eles ($ns connect agent1 agent2)
$ns connect $tcp $sink

#Application

#Setup FTP over TCP
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set type_ FTP
$ftp set maxpkts_ $maxPackets

#Programando eventos
$ns at 0.1 "$ftp start"
$ns at 40.0 "$ftp stop"


#desligar agentes Tcp e Sink
$ns at 50.0 "$ns detach-agent $n0 $tcp ; $ns detach-agent $n1 $sink"

#chamar metodo finish
$ns at 50 "finish"

#Executar simulacao
$ns run
