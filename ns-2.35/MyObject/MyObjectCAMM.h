
#include "object.h"

//#ifndef _MyObject_
//#define _MyObject_

class MyObjectCAMM : public TclObject {
public:
  MyObjectCAMM();
  virtual ~MyObjectCAMM(){};
  int command(int argc, const char*const* argv);

private:
	int my_c_var_;
};

//#endif


