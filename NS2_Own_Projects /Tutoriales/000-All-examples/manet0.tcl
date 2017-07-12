#   Based on  http://www.star.uclan.ac.uk/~mb/manet.html
#
#------------------------------------------------------------------------------
# Marco Fiore's Patch
# ------------------------------------------------------------------------------
#remove-all-packet-headers ;# removes all except common
#add-packet-header IP LL Mac AODV AOMDV ATR DSDV DSR OLSR UDP TCP CBR FTP ;# needed headers
Mac/802_11 set CWMin_ 31
Mac/802_11 set CWMax_ 1023
Mac/802_11 set SlotTime_ 0.000020 ;# 20us
Mac/802_11 set SIFS_ 0.000010 ;# 10us
Mac/802_11 set PreambleLength_ 144 ;# 144 bit
Mac/802_11 set ShortPreambleLength_ 72 ;# 72 bit
Mac/802_11 set PreambleDataRate_ 1.0e6 ;# 1Mbps
Mac/802_11 set PLCPHeaderLength_ 48 ;# 48 bits
Mac/802_11 set PLCPDataRate_ 1.0e6 ;# 1Mbps
Mac/802_11 set ShortPLCPDataRate_ 2.0e6 ;# 2Mbps
Mac/802_11 set RTSThreshold_ 3000 ;# bytes
Mac/802_11 set ShortRetryLimit_ 7 ;# retransmissions
Mac/802_11 set LongRetryLimit_ 4 ;# retransmissions
Mac/802_11 set newchipset_ false ;# use new chipset, allowing a more recent packet to be correctly received in place of the first sensed packet
Mac/802_11 set dataRate_ 11Mb ;# 802.11 data transmission rate
Mac/802_11 set basicRate_ 1Mb ;# 802.11 basic transmission rate
Mac/802_11 set aarf_ false ;# 802.11 Auto Rate Fallback

#------------------------------------------------------------------------------
# Defining options
# ------------------------------------------------------------------------------
set val(chan) Channel/WirelessChannel ;# channel type
set val(ant) Antenna/OmniAntenna ;# antenna type
set val(propagation) TwoRay ;# propagation model
set val(netif) Phy/WirelessPhy ;# network interface type
set val(ll) LL ;# link layer type
set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ifqlen) 50 ;# max packet in ifq
set val(mac) Mac/802_11 ;# MAC type
set val(rp) AOMDV ;# routing protocol
set val(nn) 16.0 ;# node number
set val(stop) 600.0 ;# simulation time [s]
set val(seed) 1 ;# general pseudo-random sequence generator
set val(x) 1000
set val(y) 1000
set val(log) log1
set val(cp) cp-file
set val(sc) scen

# ------------------------------------------------------------------------------
# Fixing DSR bug
# ------------------------------------------------------------------------------
if {$val(rp) == "DSR"} {
    set val(ifq) CMUPriQueue
}

# ------------------------------------------------------------------------------
# Channel model
# ------------------------------------------------------------------------------
Antenna/OmniAntenna set X_ 0
Antenna/OmniAntenna set Y_ 0
Antenna/OmniAntenna set Z_ 1.5
Antenna/OmniAntenna set Gt_ 1 ;# transmitter antenna gain
Antenna/OmniAntenna set Gr_ 1 ;# receiver antenna gain
Phy/WirelessPhy set L_ 1.0 ;# system loss factor (mostly 1.0)
if {$val(propagation) == "TwoRay"} { ;# range tx = 250m

    set val(prop) Propagation/TwoRayGround
    set prop [new $val(prop)]
    Phy/WirelessPhy set CPThresh_ 10.0 ;# capture threshold in Watt
    Phy/WirelessPhy set CSThresh_ 1.559e-11 ;# Carrier Sensing threshold
    Phy/WirelessPhy set RXThresh_ 3.652e-10 ;# receiver signal threshold
    Phy/WirelessPhy set freq_ 2.4e9 ;# channel frequency (Hz)
    Phy/WirelessPhy set Pt_ 0.28 ;# transmitter signal power (Watt)

}
if {$val(propagation) == "Shado"} {

    set val(prop) Propagation/Shadowing
    set prop [new $val(prop)]
    $prop set pathlossExp_ 3.8 ;# path loss exponent
    $prop set std_db_ 2.0 ;# shadowing deviation (dB)
    $prop set seed_ 1 ;# seed for RNG
    $prop set dist0_ 1.0 ;# reference distance (m)
    $prop set CPThresh_ 10.0 ;# capture threshold in Watt
    $prop set RXThresh_ 2.37e-13 ;# receiver signal threshold
    $prop set CSThresh_ [expr 2.37e-13 * 0.0427] ;# Carrier Sensing threshold
    $prop set freq_ 2.4e9 ;# channel frequency (Hz)
    Phy/WirelessPhy set Pt_ 0.28

}



proc getopt {argc argv} {

    global val
    lappend optlist nn seed mc rate type

    for {set i 0} {$i < $argc} {incr i} {

        set arg [lindex $argv $i]
        if {[string range $arg 0 0] != "-"} continue

        set name [string range $arg 1 end]
        set val($name) [lindex $argv [expr $i+1]]
        puts "$name $val($name)"

    }

}

getopt $argc $argv

# ------------------------------------------------------------------------------
# General definition
# ------------------------------------------------------------------------------
;#Instantiate the simulator
set ns_ [new Simulator]
;#Define topology
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)
;#Create channel
set chan [new $val(chan)]
$prop topography $topo
create-god $val(nn)

$ns_ node-config -adhocRouting $val(rp) \
    -llType $val(ll) \
    -macType $val(mac) \
    -ifqType $val(ifq) \
    -ifqLen $val(ifqlen) \
    -antType $val(ant) \
    -propInstance $prop \
    -phyType $val(netif) \
    -channel $chan \
    -topoInstance $topo \
    -agentTrace ON \
    -routerTrace ON \
    -macTrace OFF \
    -movementTrace OFF


# ------------------------------------------------------------------------------
# Trace file definition
# ------------------------------------------------------------------------------

#New format for wireless traces
$ns_ use-newtrace

#Create trace object for ns, nam, monitor and Inspect
set nsTrc [open $val(log) w]
$ns_ trace-all $nsTrc


# ------------------------------------------------------------------------------
# Nodes definition
# ------------------------------------------------------------------------------
;# Create the specified number of nodes [$val(nn)] and "attach" them to the channel.
for {set i 0} {$i < $val(nn) } {incr i} {
	set node_($i) [$ns_ node]
	$node_($i) random-motion 0 ;# disable random motion
}

# Define node movement model
source $val(cp) ; # connection pattern

# Define traffic model
source $val(sc)

for {set i 0} {$i < $val(nn) } {incr i} {

    $ns_ at $val(stop) "$node_($i) reset";

}

$ns_ at $val(stop) "$ns_ halt"

$ns_ run
