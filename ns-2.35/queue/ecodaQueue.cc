/*
###################################################
#         Congestion Control WSN                #
#     Camilo ALejandro Medina Mondragón           #
#   medina.camilo@javeriana.edu.co            #
###################################################

*/
#include "ecodaQueue.h"

/*
static class AODVclass : public TclClass {
public:
        AODVclass() : TclClass("Agent/AODV") {}
        TclObject* create(int argc, const char*const* argv) {
          assert(argc == 5);
          //return (new AODV((nsaddr_t) atoi(argv[4])));
    return (new AODV((nsaddr_t) Address::instance().str2addr(argv[4])));
        }
} class_rtProtoAODV;
*/


static class EcodaQueueClass : public TclClass {
public:
        EcodaQueueClass() : TclClass("Queue/Ecoda") {}
        TclObject* create(int argc, const char*const* argv) {
          //printf("El parametro recibido es %s\n", argv[4]);
	         return (new EcodaQueue(atoi(argv[4])));

	}
} class_dropt_tail_round_robin;


void EcodaQueue::enque(Packet* p)
{
  hdr_ip* iph = hdr_ip::access(p);
  hdr_cmn *ch = HDR_CMN(p);

  //printf("LO QUE ESTA ACA: %s\n", iph->saddr());
  
  if(iph->saddr() == index){
    printf("Queue: Nodo: %i Encolado en Q1 Origen: %i Destino %i \n",index,iph->saddr(), iph->daddr());
    q1_->enque(p);
    if ((q1_->length() + q2_->length()) > qlim_) {
      q1_->remove(p);
      drop(p);
    }
    
  }  else {
    printf("Queue: Nodo: %i Encolado en Q2 Origen: %i Destino %i \n",index,iph->saddr(), iph->daddr());
    q2_->enque(p);
    if ((q1_->length() + q2_->length()) > qlim_) {
      q2_->remove(p);
      drop(p);
    }
  }


  //iph->src_;
    //printf("Queue: Encolado\n");
    //printf("Paquete generado en nodo: %i, con destino: %i \n",iph->src(),iph->daddr());
  

    // if IPv6 priority = 15 enqueue to queue1
  /*
  if (iph->prio_ == 15) {
    printf("Queue: Encolado en Q1\n");
    q1_->enque(p);
    if ((q1_->length() + q2_->length()) > qlim_) {
      q1_->remove(p);
      drop(p);
    }
  }
  else {
    //printf("Queue: Encolado en Q2\n");
    q2_->enque(p);
    if ((q1_->length() + q2_->length()) > qlim_) {
      q2_->remove(p);
      drop(p);
    }
  }*/
}


Packet* EcodaQueue::deque()
{
  Packet *p;
  
  //printf("Queue: DEcolado\n");
  //printf("Saliendo de la cola.. Transmitiendo\n");

  if (deq_turn_ == 1) {
    
    p =  q1_->deque();
    
    
    if (p == 0) {
      p = q2_->deque();
      deq_turn_ = 1;
    }
    else {
      deq_turn_ = 2;
      //printf("DEQueue: Nodo: %i DEEncolado en Q1 \n",index);
    }
  }
  else {
    
    p =  q2_->deque();
    
    
    if (p == 0) {
      p = q1_->deque();
      deq_turn_ = 2;
    }
    else {
      deq_turn_ = 1;
      //printf("DEQueue: Nodo: %i DEEncolado en Q2 \n",index);
    }
  }
  
  return (p);
}


