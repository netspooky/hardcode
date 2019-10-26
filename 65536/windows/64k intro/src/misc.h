//#include <gl/gl.h>
//#include "common.h"


class cBlend{
public:
	cBlend(){}
	~cBlend(){}
	void on(int sFactor, int dFactor);
	void off(void);
};

#ifdef _DEBUG
void dp(char *error, ...);
#endif
