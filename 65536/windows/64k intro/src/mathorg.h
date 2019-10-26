///////////////////////////////////////////////////////////////////////
// éOäpä÷êî trigonometric function
//
#define SIN_QUALITY	8
#define SIN_MUL		( (1 << SIN_QUALITY) / (3.141592 * 2) )
#define SIN_MASK		( (1 << SIN_QUALITY) - 1 )
#define SIN_COS		( (1 << SIN_QUALITY) / 4 )

extern float trigTbl[];

void createTrigonometricTbl(void);

#define ySin(r)		( trigTbl [   (int)( (r) * SIN_MUL ) & SIN_MASK             ] )
#define yCos(r)		( trigTbl [ ( (int)( (r) * SIN_MUL ) & SIN_MASK ) + SIN_COS ] )
