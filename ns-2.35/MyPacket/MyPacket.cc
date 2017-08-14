#include "MyPacket.h"

static class MyHeaderClass : public PacketHeaderClass {
public:
	MyHeaderClass() : PacketHeaderClass("PacketHeader/MyHeader",sizeof(hdr_myHeader)) {
		bind_offset(&hdr_myHeader::offset_);
	}
} classMyHeader;

int hdr_myHeader::offset_;