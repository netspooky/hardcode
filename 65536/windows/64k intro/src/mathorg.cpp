#include <math.h>
#include "mathorg.h"

///////////////////////////////////////////////////////////////////////
// OŠpŠÖ”
float trigTbl[(1 << SIN_QUALITY) + SIN_COS];

void createTrigonometricTbl(void)
{
	for ( int i=0 ; i < (1 << SIN_QUALITY) + SIN_COS ; i++ ){
		trigTbl[i] = (float)sin(3.14159265358979323846 * 2 * i / (1 << SIN_QUALITY) );
	}
}
