/* 
 * Copyright (c) 2010, Elmurod A. Talipov, Yonsei University
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 * derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */



#ifndef __ecoda_packet_h__
#define __ecoda_packet_h__

// ======================================================================
//  Packet Formats: Beacon, Data, Error
// ======================================================================
 
#define ECODA_BEACON	0x01
#define ECODA_ERROR	0x02


// ======================================================================
// Direct access to packet headers
// ======================================================================

#define HDR_ECODA(p)		((struct hdr_ecoda*)hdr_ecoda::access(p))
#define HDR_ECODA_BEACON(p)	((struct hdr_ecoda_beacon*)hdr_ecoda::access(p))
#define HDR_ECODA_ERROR(p)	((struct hdr_ecoda_error*)hdr_ecoda::access(p))


// ======================================================================
// Default ecoda packet
// ======================================================================

struct hdr_ecoda {
	u_int8_t	pkt_type;
	//int pkt_type;
	// header access
	static int offset_;
	inline static int& offset() { return offset_;}
	inline static hdr_ecoda* access(const Packet *p) {
		return (hdr_ecoda*) p->access(offset_);
	}

};

// ======================================================================
// Beacon Packet Format  
// ======================================================================

struct hdr_ecoda_beacon {


	u_int8_t 	pkt_type;    // type of packet : Beacon or Error
	u_int8_t	beacon_hops;  // hop count, increadecreases as beacon is forwarded
	u_int32_t	beacon_id;   // unique identifier for the beacon
	nsaddr_t	beacon_src;  // source address of beacon, this is sink address
	u_int32_t	beacon_posx; // x position of beacon source, if available
	u_int32_t	beacon_posy; // y position of beacon source, if available


	/*
	int 	pkt_type;    // type of packet : Beacon or Error
	int	beacon_hops;  // hop count, increadecreases as beacon is forwarded
	int	beacon_id;   // unique identifier for the beacon
	nsaddr_t	beacon_src;  // source address of beacon, this is sink address
	int	beacon_posx; // x position of beacon source, if available
	int	beacon_posy; // y position of beacon source, if available
*/
	double		timestamp;   // emission time of beacon message

	inline int size() {
		int sz = 0;
		sz = sizeof(struct hdr_ecoda_beacon);
		assert(sz>=0);
		return sz;
	}
};

// =====================================================================
// Error Packet Format
// =====================================================================

struct hdr_ecoda_error {
	u_int8_t	pkt_type;  // type of packet : Beacon or Error
	u_int8_t	reserved;  // reserved for future use
	nsaddr_t	error_src; // error packet source node;
	nsaddr_t	urch_dst;  // unreachable destination
	double		timestamp; // emission time 

	inline int size() {
		int sz = 0;
		sz = sizeof(struct hdr_ecoda_error);
		assert(sz>=0);
		return sz;
	}
};


// For size calculation of header-space reservation
union hdr_all_ecoda {
	hdr_ecoda		ecoda;
	hdr_ecoda_beacon		beacon;
	hdr_ecoda_error		error;
};

#endif /* __ecoda_packet_h__ */
