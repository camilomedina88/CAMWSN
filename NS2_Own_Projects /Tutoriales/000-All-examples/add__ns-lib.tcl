

blackholeAODV {
set ragent [$self create-blackholeaodv-agent $node]
}
Simulator instproc create-blackholeaodv-agent { node } {
set ragent [new Agent/blackholeAODV [$node no
de-addr]]
$self at 0.0 "$ragent start" # start BEACON/HELLO Messages
$node set ragent_ $ragent
return $ragent
}




















 
