
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# PingAgent::recv call TCL proc Agent/Ping recv
# Amazingly, there was no proc called like this ...
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Agent/Ping instproc recv { src delay } {
   $self instvar node_
   set addr [AddrParams get-hieraddr $src]
   set a [split $addr]
   set addr [join $a .]
#   puts "PING [$node_ id] ([$node_ set address_]) - received ECHO from $addr at t=[[Simulator instance] now]  - Round Trip = $delay ms"
}

