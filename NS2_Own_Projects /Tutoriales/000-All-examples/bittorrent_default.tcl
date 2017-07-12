# BitTorrent parameters:

# done_=1 -> App can be deleted from tcl
BitTorrentApp set done_ -1

# stores the propagation delay of first hop for analysis only
BitTorrentApp set delay -1

# indicates when peer leaves the network after completing the download
#	-1	=	not leaving
#	0	=	immediate leaving (0.0)
#	>0	=	following an exponential distribution with mu = LEAVE_PARAM
BitTorrentApp set leave_option 0

# default number of unchoked connections in BitTorrent (includes the optimistic unchoke)
BitTorrentApp set unchokes 4

# time interval of unchoking [sec]
BitTorrentApp set choking_interval 10.0

# choose a choking algorithm
#	0 = BitTorrent
BitTorrentApp set choking_algorithm 0

# Number of request in the pipe (defaults to 5)
BitTorrentApp set pipelined_requests 5

# number of peer addresses requested from tracker:
# BT wiki: default is 50, each peer can specify wanted number with numwant option
##BitTorrentApp set num_from_tracker 50
BitTorrentApp set num_from_tracker 25

# minimum number of peers to not do rerequesting at tracker
#BitTorrentApp set min_peers 20
BitTorrentApp set min_peers 10

# number of peers at which to stop initiating new connections
#BitTorrentApp set max_initiate 40
BitTorrentApp set max_initiate 20

# maximum number of open connections
BitTorrentApp set max_open_cons 1000

# switch to enable super_seeding
BitTorrentApp set super_seeding 0

# For reusing nodes: BitTorrent running or not
Node set AppRunning_ -1


