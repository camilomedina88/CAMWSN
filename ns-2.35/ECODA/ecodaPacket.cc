#include "ecodaPacket.h"

packet_t PT_ECODA;

int hdr_ecoda::offset_;

static class EcodaClass : public PacketHeaderClass {
public:
  EcodaClass() : PacketHeaderClass("PacketHeader/Ecoda", sizeof(hdr_ecoda)) {
    this->bind();
    bind_offset(&hdr_ecoda::offset_);
    PT_ECODA = p_info::addPacket("Ecoda");
  }
} class_ecodahdr