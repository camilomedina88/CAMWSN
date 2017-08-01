#include "connector.h"
class ARQTx;
enum ARQStatus {IDLE,SENT,ACKED,RTX,DROP};

class ARQHandler : public Handler {
public:
    ARQHandler(ARQTx& arq) : arq_tx_(arq) {};
    void handle(Event*);
private: 
    ARQTx& arq_tx_;
};

class ARQTx : public Connector { 
public:
    ARQTx();
    void recv(Packet*, Handler*);
    void nack(Packet*);
    void ack();
    void resume();
  protected:
    ARQHandler arqh_;
    Handler* handler_;
    Packet* pkt_;
    ARQStatus status_;
    int blocked_;
    int retry_limit_;
    int num_rtxs_;
};

class ARQRx : public Connector { 
public:
    ARQRx()  {arq_tx_=0; };
    int command(int argc, const char*const* argv); 
    virtual void recv(Packet*, Handler*);
  protected:
    ARQTx* arq_tx_;
    Packet *pkt_;       // for delay
    Handler *handler_;  // for delay
    double delay_;      // for delay
    Event event_;       // for delay
};

class ARQAcker : public ARQRx { 
public:
    ARQAcker() {};
    //virtual void recv(Packet*, Handler*);  // for NO delay
    virtual void handle(Event*);             // for delay
};

class ARQNacker : public ARQRx { 
public:
    ARQNacker() {};
    //virtual void recv(Packet*, Handler*);  // for NO delay
    virtual void handle(Event*);             // for delay
};





/*
#include "connector.h"

class ARQTx;

enum ARQStatus {IDLE,SENT,ACKED,RTX,DROP};


class ARQHandler : public Handler{
	public: 
		ARQHandler(ARQTx& arq) : arq_tx_(arq){};
		void handle(Event*);

	private:
		ARQTx& arq_tx_; // Referencia al objeto ARQTx.
		//Durante el proceso de callback, un objeto ARQHandler usa esta referencia
		//para decirle al ARQTx "resume" el proceso de transmision pendiente.

};

// ARQTx representa a los transmisores ARQ. Al ser derivado de la clase Connector, esta
// puede ser utilizada para conectar dos NsObjects
class ARQTx : public Connector{

public:
	ARQTx();
	void recv (Packet*, Handler*); //Recibe un paquete del objeto de arriba
	void nack (Packet*); // Procesa un mensaje NACK. Invocada por ARQNacker
	void ack(); //Procesa un mensaje ACK. Invocada por ARQAcker
	void resume(); //Comenzar la operacion desde el estado bloqueado. Invocado por el objeo LinkDelay

protected:
	ARQHandler arqh_; //Handler pasado al objeto de abajo (link???)
	Handler* handler_; //Handler al objeto de arriba (Queue??)
	Packet* pkt_; //Pointer a el paquete que esta siendo transmitido.
	ARQStatus status_; //Estado actual del objeto
	int blocked_; //Indica si el objeto ARQTX está bloqueado, si si no se tx ningun paquete
	int retry_limit_; //Limite de intentos
	int num_rtxs_; 	// numero actual de retransmisiones (es cero cuando llega un nuevo paquete)
};

class ARQRx : public Connector{
	public: 
		ARQRx(){arq_tx_=0;};
		int command(int argc, const char*const* argv);

	protected:
		ARQTx* arq_tx_;
};

class ARQAcker : public ARQRx{
	public: 
		ARQAcker(){};
		virtual void recv(Packet*, Handler*);
};

class ARQNacker : public ARQRx{

	public:
		ARQNacker(){};
		virtual void recv(Packet*, Handler*);
};



*/