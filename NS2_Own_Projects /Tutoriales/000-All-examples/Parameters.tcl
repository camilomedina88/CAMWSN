##################################################################################
# Parameters.tcl script of 						         #
# Development of a simulation and performance analysis platform for LTE networks #
# Project done by MINERVE MAMPAKA 					         #
# December 2013								         #
##################################################################################


#declare global variables
global input_  

#switch the cache memory on or off
set CACHE OFF;
#set CACHE ON;


# simulation time, trace filename and Nam filename
set input_(TIME_SIMULATION) 30.0
set input_(TRACES_FILENAME) Traces.tr
set input_(ANIMATOR_NAME) Animator.nam

#input users number based on different traffic
set input_(RTP_USERS) 5
set input_(CBR_USERS) 5
set input_(HTTP_USERS) 5
set input_(FTP_USERS) 5

#set the limited size of the queues
set input_(QUEUE_LIMIT) 20


#Air (LTE-UU) interface parameters configuration
set input_(UP_AIR_BANDWIDTH) 100Mb
set input_(UP_AIR_DELAY) 2ms
set input_(UP_AIR_QUEUE) DropTail

set input_(DOWN_AIR_BANDWIDTH) 100Mb
set input_(DOWN_AIR_DELAY) 2ms
set input_(DOWN_AIR_QUEUE) DropTail


#S1-U interface parameters configuration
set input_(UP_S1_BANDWIDTH) 100Mb
set input_(UP_S1_DELAY) 2ms
set input_(UP_S1_QUEUE) DropTail

set input_(DOWN_S1_BANDWIDTH) 100Mb
set input_(DOWN_S1_DELAY) 2ms
set input_(DOWN_S1_QUEUE) DropTail


#S5 interface parameters configuration
set input_(S5_BANDWIDTH) 1Gb
set input_(S5_DELAY) 2ms
set input_(S5_QUEUE) DropTail


#SGi interface parameters configuration
set input_(SGI_BANDWIDTH) 10Gb
set input_(SGI_DELAY) 2ms
set input_(SGI_QUEUE) DropTail

# RTP parameters
set input_(UP_SESSION_BANDWIDTH) 67.6kb/s
set input_(DOWN_SESSION_BANDWIDTH) 67.6kb/s
set input_(UE_RTP_GROUP_TIME) 0.4
set input_(UE_RTP_START_TIME) 0.5
set input_(UE_RTP_TRANSMIT_TIME) 0.6
set input_(SERVER_RTP_GROUP_TIME) 0.7
set input_(SERVER_RTP_START_TIME) 0.8
set input_(SERVER_RTP_TRANSMIT_TIME) 0.9

# CBR parameters
set input_(CBR_PACKET_SIZE) 1024
set input_(CBR_RATE) 2Mb 
set input_(CBR_START_TIME) 0.5

# HTTP parameters
set input_(AVERAGE_PAGE_SIZE) 327680
set input_(AVERAGE_PAGE_AGE) 4
set input_(AVERAGE_REQ_INTERVAL) 1
set input_(HTTP_START_TIME) 0.5

# FTP parameters
set input_(FTP_PACKET_SIZE) 1024
set input_(FTP_START_TIME) 0.5

# Initialize the Hitrate for CBR and FTP
set input_(CBR_HIT_RATE) 0
set input_(FTP_HIT_RATE) 0


# If the cache memory is switched on, configure the hitrate
#the hitrate value is in percentage
if {$CACHE=="ON"} {
	set input_(CBR_HIT_RATE) 40
	set input_(FTP_HIT_RATE) 40
}

#calculate the number of users using cache memory
set input_(CBR_CACHE_USERS) [expr {int($input_(CBR_USERS)*$input_(CBR_HIT_RATE)/100)}]
set input_(FTP_CACHE_USERS) [expr {int($input_(FTP_USERS)*$input_(FTP_HIT_RATE)/100)}]

















