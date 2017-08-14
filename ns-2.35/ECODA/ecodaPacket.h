#ifndef ECODAPACKET_H
#define ECODAPACKET_H

#include <packet.h>

//extern packet_t PT_ECODA;

#define HDR_ECODA(p)      (hdr_ecoda::access(p))

typedef struct hdr_ecoda {

  // This members are always needed by NS 
  static int offset_;
  inline static int& offset() { return offset_; }
  inline static struct hdr_ecoda* access(const Packet* p) {
    return (struct hdr_ecoda*)p->access(offset_);
  }

  // My custom header fields go here:  
  double dynamicPriority;
  int staticPriority;
  

  double &getDinamicPriority(){return dynamicPriority;}
  int &getStaticPriority(){return staticPriority; }
  
}hdr_ecoda ;

#endif /* MYPACKET_H */