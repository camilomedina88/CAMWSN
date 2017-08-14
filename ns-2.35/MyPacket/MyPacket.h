#ifndef MYPACKET_H_
#define MYPACKET_H_

#include "packet.h"

struct hdr_myHeader {
	// your data fields
	int myData;
	int &getMyData() { return myData; }

	// necessary for access
	static int offset_;
	inline static int& offset() { return offset_; }
	inline static hdr_myHeader* access(const Packet* p) {
		return (hdr_myHeader*) p->access(offset_);
	}
};


#endif /*CLUSTERINGPACKET_H_*/
