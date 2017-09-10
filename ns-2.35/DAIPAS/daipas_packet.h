/*
###################################################
#         Congestion Control WSN               	  #
#     Camilo ALejandro Medina Mondragón           #
#   medina.camilo@javeriana.edu.co            	  #
###################################################

*/


#ifndef __daipas_packet_h__
#define __daipas_packet_h__

// ======================================================================
//  Packet Formats: Beacon, Data, Error
// ======================================================================
 
#define DAIPAS_BEACON	0x01
#define DAIPAS_ERROR	0x02
#define DAIPAS_ACK		0x03
#define DAIPAS_CONNECT	0x04
#define DAIPAS_HELLO	0x05


// ======================================================================
// Direct access to packet headers
// ======================================================================

#define HDR_DAIPAS(p)		((struct hdr_daipas*)hdr_daipas::access(p))
#define HDR_DAIPAS_BEACON(p)	((struct hdr_daipas_beacon*)hdr_daipas::access(p))
#define HDR_DAIPAS_ERROR(p)	((struct hdr_daipas_error*)hdr_daipas::access(p))
#define HDR_DAIPAS_ACK(p)	((struct hdr_daipas_ack*)hdr_daipas::access(p))
#define HDR_DAIPAS_CONNECT(p)	((struct hdr_daipas_connect*)hdr_daipas::access(p))
#define HDR_DAIPAS_HELLO(p)	((struct hdr_daipas_hello*)hdr_daipas::access(p))


// ======================================================================
// Default daipas packet
// ======================================================================

struct hdr_daipas {
	u_int8_t	pkt_type;
	//int pkt_type;
	// header access
	static int offset_;
	inline static int& offset() { return offset_;}
	inline static hdr_daipas* access(const Packet *p) {
		return (hdr_daipas*) p->access(offset_);
	}

};

// ======================================================================
// Beacon Packet Format  
// ======================================================================

struct hdr_daipas_beacon {

	u_int8_t	pkt_type;  // type of packet : Beacon or Error
	double		timestamp; // emission time
	nsaddr_t	beacon_src;
	float 		bufferOccupancy; 
	float 		remainingPower;
	int 		level;
	bool 		flag;



	inline int size() {
		int sz = 0;
		sz = sizeof(struct hdr_daipas_beacon);
		assert(sz>=0);
		return sz;
	}

	
/*
	u_int8_t 	pkt_type;    // type of packet : Beacon or Error
	u_int8_t	beacon_hops;  // hop count, increadecreases as beacon is forwarded
	u_int32_t	beacon_id;   // unique identifier for the beacon
	nsaddr_t	beacon_src;  // source address of beacon, this is sink address
	//u_int32_t	beacon_posx; // x position of beacon source, if available
	//u_int32_t	beacon_posy; // y position of beacon source, if available
	int level;


	
	int 	pkt_type;    // type of packet : Beacon or Error
	int	beacon_hops;  // hop count, increadecreases as beacon is forwarded
	int	beacon_id;   // unique identifier for the beacon
	nsaddr_t	beacon_src;  // source address of beacon, this is sink address
	int	beacon_posx; // x position of beacon source, if available
	int	beacon_posy; // y position of beacon source, if available

	double		timestamp;   // emission time of beacon message

	inline int size() {
		int sz = 0;
		sz = sizeof(struct hdr_daipas_beacon);
		assert(sz>=0);
		return sz;
	}*/
};


struct hdr_daipas_hello {


	u_int8_t 	pkt_type;    // type of packet : Beacon or Error
	u_int8_t	beacon_hops;  // hop count, increadecreases as beacon is forwarded
	//u_int32_t	beacon_id;   // unique identifier for the beacon
	nsaddr_t	beacon_src;  // source address of beacon, this is sink address
	//u_int32_t	beacon_posx; // x position of beacon source, if available
	//u_int32_t	beacon_posy; // y position of beacon source, if available
	int level;
	double		timestamp;   // emission time of beacon message

	inline int size() {
		int sz = 0;
		sz = sizeof(struct hdr_daipas_beacon);
		assert(sz>=0);
		return sz;
	}
};










struct hdr_daipas_ack {
	
	u_int8_t	pkt_type;  // type of packet : Beacon or Error
	double		timestamp; // emission time 
	int nodeId;
	bool nextPacket;
	float 		bufferOccupancy; 
	float 		remainingPower;
	int 		level;
	bool 		flag;



	inline int size() {
		int sz = 0;
		sz = sizeof(struct hdr_daipas_ack);
		assert(sz>=0);
		return sz;
	}
};


struct hdr_daipas_connect {

	u_int8_t	pkt_type;  // type of packet : Beacon or Error
	double		timestamp; // emission time
	nsaddr_t	beacon_src;
	float 		bufferOccupancy; 
	float 		remainingPower;
	int 		level;
	bool 		flag;



	inline int size() {
		int sz = 0;
		sz = sizeof(struct hdr_daipas_connect);
		assert(sz>=0);
		return sz;
	}
};



// =====================================================================
// Error Packet Format
// =====================================================================

struct hdr_daipas_error {
	u_int8_t	pkt_type;  // type of packet : Beacon or Error
	u_int8_t	reserved;  // reserved for future use
	nsaddr_t	error_src; // error packet source node;
	nsaddr_t	urch_dst;  // unreachable destination
	double		timestamp; // emission time 

	inline int size() {
		int sz = 0;
		sz = sizeof(struct hdr_daipas_error);
		assert(sz>=0);
		return sz;
	}
};


// For size calculation of header-space reservation
union hdr_all_daipas {
	hdr_daipas		daipas;
	hdr_daipas_beacon		beacon;
	hdr_daipas_error		error;
};

#endif /* __daipas_packet_h__ */
