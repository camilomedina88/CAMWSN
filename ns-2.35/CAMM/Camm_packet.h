/*
###################################################
#         Congestion Control WSN               	  #
#     Camilo ALejandro Medina Mondragón           #
#   medina.camilo@javeriana.edu.co            	  #
###################################################

*/


#ifndef __camm_packet_h__
#define __camm_packet_h__

// ======================================================================
//  Packet Formats: Beacon, Data, Error
// ======================================================================
 
#define CAMM_BEACON	0x01
//#define CAMM_ERROR	0x02
#define CAMM_ACK		0x03
//#define CAMM_CONNECT	0x04
//#define CAMM_HELLO	0x05


// ======================================================================
// Direct access to packet headers
// ======================================================================

#define HDR_CAMM(p)		((struct hdr_camm*)hdr_camm::access(p))
#define HDR_CAMM_BEACON(p)	((struct hdr_camm_beacon*)hdr_camm::access(p))
#define HDR_CAMM_ERROR(p)	((struct hdr_camm_error*)hdr_camm::access(p))
#define HDR_CAMM_ACK(p)	((struct hdr_camm_ack*)hdr_camm::access(p))
#define HDR_CAMM_CONNECT(p)	((struct hdr_camm_connect*)hdr_camm::access(p))
#define HDR_CAMM_HELLO(p)	((struct hdr_camm_hello*)hdr_camm::access(p))


// ======================================================================
// Default camm packet
// ======================================================================

struct hdr_camm {
	u_int8_t	pkt_type;
	//int pkt_type;
	// header access
	static int offset_;
	inline static int& offset() { return offset_;}
	inline static hdr_camm* access(const Packet *p) {
		return (hdr_camm*) p->access(offset_);
	}

};

// ======================================================================
// Beacon Packet Format  
// ======================================================================

struct hdr_camm_beacon {

	u_int8_t	pkt_type;  // type of packet : Beacon or Error
	double		timestamp; // emission time
	nsaddr_t	beacon_src;
	float 		bufferOccupancy; 
	float 		remainingPower;
	int 		level;
	bool 		flag;



	inline int size() {
		int sz = 0;
		sz = sizeof(struct hdr_camm_beacon);
		assert(sz>=0);
		return sz;
	}

	
};


struct hdr_camm_hello {


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
		sz = sizeof(struct hdr_camm_beacon);
		assert(sz>=0);
		return sz;
	}
};










struct hdr_camm_ack {
	
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
		sz = sizeof(struct hdr_camm_ack);
		assert(sz>=0);
		return sz;
	}
};


struct hdr_camm_connect {

	u_int8_t	pkt_type;  // type of packet : Beacon or Error
	double		timestamp; // emission time
	nsaddr_t	beacon_src;
	float 		bufferOccupancy; 
	float 		remainingPower;
	int 		level;
	bool 		flag;



	inline int size() {
		int sz = 0;
		sz = sizeof(struct hdr_camm_connect);
		assert(sz>=0);
		return sz;
	}
};



// =====================================================================
// Error Packet Format
// =====================================================================

struct hdr_camm_error {
	u_int8_t	pkt_type;  // type of packet : Beacon or Error
	u_int8_t	reserved;  // reserved for future use
	nsaddr_t	error_src; // error packet source node;
	nsaddr_t	urch_dst;  // unreachable destination
	double		timestamp; // emission time 

	inline int size() {
		int sz = 0;
		sz = sizeof(struct hdr_camm_error);
		assert(sz>=0);
		return sz;
	}
};


// For size calculation of header-space reservation
union hdr_all_camm {
	hdr_camm		camm;
	hdr_camm_beacon		beacon;
	hdr_camm_error		error;
};

#endif /* __camm_packet_h__ */
