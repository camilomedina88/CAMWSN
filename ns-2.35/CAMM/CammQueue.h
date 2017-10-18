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
#include "timer-handler.h"

class CammQueue;

class CammTimer : public TimerHandler{
public:
	CammTimer(CammQueue *eco) {camm_=eco;};
	virtual void expire (Event *e);
protected:
	CammQueue *camm_;
};


class CammQueue : public Queue {
	friend class CammTimer;
 public:
        CammQueue(int id): timer_(this) { 
		q1_ = new PacketQueue;
		q2_ = new PacketQueue;
		pq_ = q1_;
		deq_turn_ = 1;
		index = id;
		estadoBuffer=0;
		alpha=0.5;
		beta=0.02;
		}
 protected:
     void enque(Packet*);
     void sortQueue(PacketQueue*);
	 Packet* deque();
	 Packet* sendCamm();
	 //void enqueA(Packet* p);
	 //void enqueB(Packet* p);

	 PacketQueue *q1_;   // First  FIFO queue
	 PacketQueue *q2_;   // Second FIFO queue
	 //Packet *primerPaquete;

	 int deq_turn_;      // 1 for First queue 2 for Second
	 int index;
	 int estadoBuffer; //0 -> Accept State, 1 -> Filter State, 2 ->Reject State
	 float alpha;
	 float beta;
	 CammTimer timer_;
	
};