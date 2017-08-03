/*
###################################################
#        	Congestion Control WSN                #
#     Camilo ALejandro Medina Mondragón           #
#		medina.camilo@javeriana.edu.co            #
###################################################

*/

#include <string.h>
#include "queue.h"
#include "address.h"


class EcodaQueue : public Queue {
 public:
         EcodaQueue(int id) { 
		q1_ = new PacketQueue;
		q2_ = new PacketQueue;
		pq_ = q1_;
		deq_turn_ = 1;
		index = id;
		//printf("Nodo: %i - \n", index);
	}
		 //void    recv(Packet *p, Handler *h);

 protected:
     void enque(Packet*);
	 Packet* deque();
	 //void enqueA(Packet* p);
	 //void enqueB(Packet* p);

	 PacketQueue *q1_;   // First  FIFO queue
	 PacketQueue *q2_;   // Second FIFO queue
	 int deq_turn_;      // 1 for First queue 2 for Second
	 int index;
};