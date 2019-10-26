#include <windows.h>
#include <GL/gl.h>
#include <GL/glu.h>
#include <dsound.h>
extern "C" int _fltused = 0x9875;

#define WIDTH 800
#define HEIGHT 600

//const float PI2 = 6.2831853f;

GLUtriangulatorObj * tess;
double * tessvx;
unsigned int tessidx=0;

GLUquadric* quadric;

GLuint texid[2];

/////////////////////////// VIRTUAL MACHINE ////////////////////////////


//program counter
unsigned char * PC;
//codeword
unsigned char CW;
//subprogram banks
//unsigned char **SUB;

//stacks
float * FSTACK;
float * FSPx[3]; //points to the last element on the stack
            //empty stack: FSP =(=) FSTACK-1
char astack=0;
float * FSP;

int * INTSTACK;
int * INTSP;

//vector register:
float * VREG;

const unsigned char V_A = 0;
const unsigned char V_B = 1;
const unsigned char V_C = 2;
const unsigned char V_D = 3;
const unsigned char V_E = 4;
const unsigned char V_F = 5;
const unsigned char V_G = 6;
const unsigned char V_H = 7;
const unsigned char V_I = 8;
const unsigned char V_J = 9;
const unsigned char V_K = 10;
const unsigned char V_L = 11;
const unsigned char V_M = 12;
const unsigned char V_N = 13;

const unsigned char V_CAM = 14;
const unsigned char V_DRAW = 15;

//V_DRAW = (F_PX, F_PY, F_PZ)

//float register:
float * FREG;

const unsigned char F_PX = 0;
const unsigned char F_PY = 1;
const unsigned char F_PZ = 2;
const unsigned char F_A = 3;
const unsigned char F_B = 4;
const unsigned char F_C = 5;
const unsigned char F_D = 6;
const unsigned char F_E = 7;
const unsigned char F_F = 8;
const unsigned char F_G = 9;
const unsigned char F_H = 10;
const unsigned char F_I = 11;

const unsigned char F_DT = 12;
const unsigned char F_AT = 13;
const unsigned char F_CAMALPHA = 14;
const unsigned char F_CAMBETA = 15;

//shortcuts:
float * AUDIO_T;


#define BIRDNUM 3

unsigned int RND = 13;
void random()
{
	RND = (1664525 * RND + 1013904223);
}


//floating point & sse supported functions:

float absolute(float x)
{
	__asm
	{
		fld x
		fabs
		fstp x
	}
	return x;
}

float sinus(float x)
{
	__asm
	{
		fld x
		fsin
		fstp x
	}
	return x;
}

float cosinus(float x)
{
	__asm
	{
		fld x
		fcos
		fstp x
	}
	return x;
}

float invsqr(float x)
{
	if (x < 0.001f)
		x = 0.001f;
	__asm
	{
		rsqrtss xmm0, x
		movss x, xmm0
	}
	return x;
}
float int2float(int i)
{
	float x;
	__asm
	{
		fild i
		fstp x
	}
	return x;
}


// stack helper-functions

float st_invlen()
{
	float x = FSP[0];
	float y = FSP[-1];
	float z = FSP[-2];
	return invsqr(x*x + y*y + z*z);
}

void st_vecscale(float d)
{
	FSP[0] *= d;
	FSP[-1] *= d;
	FSP[-2] *= d;
}

void streg_copy(float const* src, float * dest)
{
	dest[0] = src[2];
	dest[1] = src[1];
	dest[2] = src[0];
}


#define OPCODE const unsigned char
#define CDWORD const unsigned char
#define MNEM const unsigned char
#define CMD(OP_,CDW_) ((OP_) * 16 + (CDW_))

OPCODE OP_R1 = 0;

CDWORD CW_FABS = 0;
CDWORD CW_FNEG = 1;
CDWORD CW_FRCP = 2;
CDWORD CW_FRSQR = 3;
CDWORD CW_FSIN = 4;
CDWORD CW_FCOS = 5;

MNEM FABS = CMD(OP_R1, CW_FABS);
MNEM FNEG = CMD(OP_R1, CW_FNEG);
MNEM FRCP = CMD(OP_R1, CW_FRCP);
MNEM FRSQR = CMD(OP_R1, CW_FRSQR);
MNEM FSIN = CMD(OP_R1, CW_FSIN);
MNEM FCOS = CMD(OP_R1, CW_FCOS);

void R1oper()
{
	float x = (*FSP);
	
	if (CW == CW_FABS)
		x = absolute(x);
	else if (CW == CW_FNEG)
		x = -x;
	else if (CW == CW_FRCP)
	{
		if (x < 0.001f)
		x = 0.001f;
		x = 1.0f / x;
	}
	else if (CW == CW_FRSQR)
		x = invsqr(x);
	else if (CW == CW_FSIN)
		x = sinus(x);
	else if (CW == CW_FCOS)
		x = cosinus(x);

	(*FSP) = x;
}


OPCODE OP_RX = 1;

CDWORD CW_FADD = 0;
CDWORD CW_FMUL = 1 ;
CDWORD CW_VECNEG = 2 ;
CDWORD CW_VECUNIT = 3 ;
CDWORD CW_VECLEN = 4 ;
CDWORD CW_VECSCALE = 5 ;
CDWORD CW_VECDOT = 6 ;
CDWORD CW_VECADD = 7 ;
CDWORD CW_VECCROSS = 8 ;
CDWORD CW_PHASOR = 9 ;
CDWORD CW_POLAR = 10 ;
CDWORD CW_SPHERICAL = 11 ;
CDWORD CW_FPUSHPI = 12;
CDWORD CW_FPUSH0 = 13;
CDWORD CW_FPUSH1 = 14;

MNEM FADD = CMD(OP_RX, CW_FADD);
MNEM FMUL = CMD(OP_RX, CW_FMUL);
MNEM VECNEG = CMD(OP_RX, CW_VECNEG);
MNEM VECUN = CMD(OP_RX, CW_VECUNIT);
MNEM VECLEN = CMD(OP_RX, CW_VECLEN);
MNEM VECSCALE = CMD(OP_RX, CW_VECSCALE);
MNEM VECDOT = CMD(OP_RX, CW_VECDOT);
MNEM VECADD = CMD(OP_RX, CW_VECADD);
//MNEM VECCROSS = CMD(OP_RX, CW_VECCROSS);
//MNEM PHASOR = CMD(OP_RX, CW_PHASOR);
MNEM POLAR = CMD(OP_RX, CW_POLAR);
//MNEM SPHERICAL = CMD(OP_RX, CW_SPHERICAL);
MNEM FPUSHPI = CMD(OP_RX, CW_FPUSHPI);
MNEM FPUSH0 = CMD(OP_RX, CW_FPUSH0);
MNEM FPUSH1 = CMD(OP_RX, CW_FPUSH1);

void RXoper()
{
	if (CW == CW_FADD)
	{
		--FSP;
		FSP[0] += FSP[1];
	}
	else if (CW == CW_FMUL)
	{
		--FSP;
		FSP[0] *= FSP[1];
	}
	else if (CW == CW_VECNEG)
	{
		st_vecscale(-1);
	}
	else if (CW == CW_VECUNIT)
	{
		float invlen = st_invlen();
		st_vecscale(invlen);
	}
	else if (CW == CW_VECLEN)
	{
		float len = 1.0f / st_invlen();
		FSP -= 2;
		(*FSP) = len;
	}
	else if (CW == CW_VECSCALE)
	{
		float d = *(FSP--);
		st_vecscale(d);
	}
/*	else if (CW == CW_VECDOT)
	{
		float dp = FSP[0]*FSP[-3] + FSP[-1]*FSP[-4] + FSP[-2]*FSP[-5];
		FSP -= 5;
		(*FSP) = dp;
	}*/
	else if (CW == CW_VECADD)
	{
		FSP[-3] += FSP[0];
		FSP[-4] += FSP[-1];
		FSP[-5] += FSP[-2];
		FSP -= 3;
	}
	/*else if (CW == CW_VECCROSS)
	{
		//out[x] = v1[y] * v2[z] - v1[z] * v2[y] 

		//out[y] = v1[z] * v2[x] - v1[x] * v2[z] 

		//out[z] = v1[x] * v2[y] - v1[y] * v2[x]
	}
	else if (CW == CW_PHASOR)
	{
	}*/
	else if (CW == CW_POLAR)
	{
		const float a = (*FSP);
		(*FSP) = cosinus(a) * FSP[-1];
		FSP[-1] *= -sinus(a);
	}
	//else if (CW == CW_SPHERICAL)
	//{
	//}
	else if (CW == CW_FPUSHPI)
	{
		*(++FSP) = 3.141593f;
	}
	else if (CW == CW_FPUSH0)
	{
		*(++FSP) = 0;
	}
	else if (CW == CW_FPUSH1)
	{
		*(++FSP) = 1.0f;
	}
}


OPCODE OP_IX = 2;

CDWORD CW_INT2FLOAT = 0;
CDWORD CW_INT2FLOAT16 = 1;
CDWORD CW_INT2FLOAT16RCP = 2;
CDWORD CW_INT2FLOAT256RCP = 3;
CDWORD CW_INT2INT16 = 4;
CDWORD CW_BYTECRACK53 = 5;
CDWORD CW_STACK0 = 6;
CDWORD CW_STACK1 = 7;
CDWORD CW_STACK2 = 8;
CDWORD CW_IPUSHRNDBIT = 9;

MNEM INT2FLOAT = CMD(OP_IX, CW_INT2FLOAT);
MNEM INT2FLOAT16 = CMD(OP_IX, CW_INT2FLOAT16);
MNEM INT2FLOAT16RCP = CMD(OP_IX, CW_INT2FLOAT16RCP);
MNEM INT2FLOAT256RCP = CMD(OP_IX, CW_INT2FLOAT256RCP);
MNEM INT2INT16 = CMD(OP_IX, CW_INT2INT16);
MNEM BYTECRACK53 = CMD(OP_IX, CW_BYTECRACK53);
MNEM STACK0 = CMD(OP_IX, CW_STACK0);
MNEM STACK1 = CMD(OP_IX, CW_STACK1);
MNEM STACK2 = CMD(OP_IX, CW_STACK2);
MNEM IPUSHRNDBIT = CMD(OP_IX, CW_IPUSHRNDBIT);

/*
IINC
IDEC
INEG
IADD
IMUL
*/

void stk_i2f(float d)
{
	int i = *(INTSP--);
	*(++FSP) = int2float(i) * d;
}

void IXoper()
{
	if (CW == CW_INT2FLOAT)
	{
		stk_i2f(1);
	}
	else if (CW == CW_INT2FLOAT16)
	{
		stk_i2f(16.0f);
		//(*FSP) *= ;
	}
	else if (CW == CW_INT2FLOAT16RCP)
	{
		stk_i2f(1.0f / 16.0f);
		//(*FSP) *= ();
	}
	else if (CW == CW_INT2FLOAT256RCP)
	{
		stk_i2f(1.0f / 256.0f);
		//(*FSP) *= ();
	}
	else if (CW == CW_INT2INT16)
	{
		(*INTSP) *= 16;
	}
	else if (CW == CW_BYTECRACK53)
	{
		int oct = (*INTSP);
		(*INTSP) = oct / 8;
		*(++INTSP) = oct % 8;
	}
	else if (CW >= CW_STACK0 && CW <= CW_STACK2)
	{
		FSPx[astack] = FSP;
		astack = CW - CW_STACK0;
		FSP = FSPx[astack];
	}
	else if (CW == CW_IPUSHRNDBIT)
	{
		random();
		*(++INTSP) = (RND % 100) < 50;
	}
}
/*
FPOP
VECPOP
GETX
GETY
VECZ
*/


OPCODE OP_IPUSHIM = 3;
#define IPUSHIM(IM) CMD(OP_IPUSHIM, IM)
void ipushim()
{
	*(++INTSP) = CW;
}


OPCODE OP_FPUSH = 4;
#define FPUSH(REGN) CMD(OP_FPUSH, REGN)
void fpush()
{
	*(++FSP) = FREG[CW];
}

OPCODE OP_FSTPOP = 5;
#define FSTPOP(REGN) CMD(OP_FSTPOP, REGN)
void fstpop()
{
	FREG[CW] = *(FSP--);
}


OPCODE OP_FSTPEEK = 6;
#define FSTPEEK(REGN) CMD(OP_FSTPEEK, REGN)
void fstpeek()
{
	FREG[CW] = *FSP;
}


OPCODE OP_VECPUSH = 7;
#define VECPUSH(REGN) CMD(OP_VECPUSH, REGN)
void vecpush()
{
	streg_copy(&VREG[CW*3], FSP+1);
	FSP += 3;
}


OPCODE OP_VECSTPOP = 8;
#define VECSTPOP(REGN) CMD(OP_VECSTPOP, REGN)
void vecstpop()
{
	streg_copy(FSP-2, &VREG[CW*3]);
	FSP -= 3;
}


OPCODE OP_VECSTPEEK = 9;
#define VECSTPEEK(REGN) CMD(OP_VECSTPEEK, REGN)
void vecstpeek()
{
	streg_copy(FSP-2, &VREG[CW*3]);
}


OPCODE OP_CONTROL = 10;

CDWORD CW_END = 0;
CDWORD CW_BTW1 = 1;
CDWORD CW_BTW2 = 2;
CDWORD CW_BTW3 = 3;
CDWORD CW_REPEAT = 4;
CDWORD CW_IF_LTZ = 5;
CDWORD CW_IF_BOUNDS = 6;

MNEM END = CMD(OP_CONTROL, CW_END);
MNEM BTW1 = CMD(OP_CONTROL, CW_BTW1);
MNEM BTW2 = CMD(OP_CONTROL, CW_BTW2);
MNEM BTW3 = CMD(OP_CONTROL, CW_BTW3);
MNEM REPEAT = CMD(OP_CONTROL, CW_REPEAT);
MNEM IF_LTZ = CMD(OP_CONTROL, CW_IF_LTZ);
MNEM IF_BOUNDS = CMD(OP_CONTROL, CW_IF_BOUNDS);

void eval();
void noeval();
/*
void between(unsigned int dim)
{
	float Bx[3];
	float Bx1[3];
	float Bdx[3];
	int Bxsz[3];

	int sz = 1;
	unsigned int n = 0;
	do
	{
		Bx[n] = (Bx1[n] = *(FSP--));
		
		Bxsz[n] = sz;
		int len = *(INTSP--);
		sz *= (len + 1);

		float lenf = int2float(len);
		
		Bdx[n] = ((*(FSP--)) - Bx1[n]) / lenf;
	}while(++n < dim);

	unsigned char *br = PC;
	
	sz--;
	do
	{
		int m = dim - 1;
		bool lflag = false;
		do
		{
			*(++FSP) = Bx[m];
			if (lflag)
				Bx[m] = Bx1[m];
			else if (sz % Bxsz[m] == 0)
			{
				Bx[m] += Bdx[m];
				lflag = true;
			}
		}while(--m > -1);
		PC = br;
		eval();

	} while(--sz > -1);
}*/

void repeat()
{
	int len = *(INTSP--);
	unsigned char *br = PC;
	do
	{
		PC = br;
		eval();
	} while(--len > 0);
}

void if_ltz()
{
	if (*(FSP--) < 0)
		eval();
	else
		noeval();
}

void control()
{
	/*if (CW > 0 && CW < 4)
		between(CW);
	else*/ if (CW == CW_REPEAT)
		repeat();
	else if (CW == CW_IF_LTZ)
		if_ltz();
	else if (CW == CW_IF_BOUNDS)
	{
		float min = *(FSP--);
		float max = *(FSP--);
		float val = *(FSP--);
		if (min < val && val < max)
			eval();
		else
			noeval();
	}
}

/*
OPCODE OP_JUMP = 11;
#define JUMP(SUBN) CMD(OP_JUMP, SUBN)
void jump()
{
	unsigned char * const jr = PC;
	PC = SUB[CW];
	eval();
	PC = jr;
}*/


//graphics helper functions

void set_projection(bool persp) //set projection matrix
{
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();

	if (persp)
		gluPerspective(80, 1.33, 1, 55.0);
	else
		glOrtho(0,1,1,0,0,1);

	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
}

OPCODE OP_GFX = 11;

CDWORD CW_PERSPECTIVE = 0;
CDWORD CW_ORTHOGONAL = 1;
CDWORD CW_CAMERA = 2;
CDWORD CW_DRAWQUADS = 3;
CDWORD CW_DRAWTRIANGLES = 4;
CDWORD CW_DRAWLINES = 5;
CDWORD CW_DRAWPOINTS = 6;
CDWORD CW_ENDDRAW = 7;
CDWORD CW_TEXCOORD2POP = 8;
CDWORD CW_VERTEX2POP = 9;
CDWORD CW_COLOR4POP = 10;
CDWORD CW_DRAWTESSPOLY = 11;
CDWORD CW_ENDTESSDRAW = 12;
CDWORD CW_TESSVX2POP = 13;
CDWORD CW_VERTEX3POP = 14;
CDWORD CW_CLS = 15;

MNEM PERSPECTIVE = CMD(OP_GFX, CW_PERSPECTIVE);
MNEM ORTHOGONAL = CMD(OP_GFX, CW_ORTHOGONAL);
MNEM CAMERA = CMD(OP_GFX, CW_CAMERA);
MNEM DRAWQUADS = CMD(OP_GFX, CW_DRAWQUADS);
MNEM DRAWTRIANGLES = CMD(OP_GFX, CW_DRAWTRIANGLES);
MNEM DRAWLINES = CMD(OP_GFX, CW_DRAWLINES);
MNEM DRAWPOINTS = CMD(OP_GFX, CW_DRAWPOINTS);
MNEM ENDDRAW = CMD(OP_GFX, CW_ENDDRAW);
MNEM TEXCOORD2POP = CMD(OP_GFX, CW_TEXCOORD2POP);
MNEM VERTEX2POP = CMD(OP_GFX, CW_VERTEX2POP);
MNEM COLOR4POP = CMD(OP_GFX, CW_COLOR4POP);
MNEM DRAWTESSPOLY = CMD(OP_GFX, CW_DRAWTESSPOLY);
MNEM ENDTESSDRAW = CMD(OP_GFX, CW_ENDTESSDRAW);
MNEM TESSVX2POP = CMD(OP_GFX, CW_TESSVX2POP);
MNEM VERTEX3POP = CMD(OP_GFX, CW_VERTEX3POP);
MNEM CLS = CMD(OP_GFX, CW_CLS);


void gfx()
{
	if (CW < 2)
	{
		set_projection(CW == CW_PERSPECTIVE);
	}
	else if (CW == CW_CAMERA)
	{
		gluLookAt(0.0,0.0,-10.0, 0.0,0.0,0.0, 0.0,1.0,0.0);
		glRotatef(-25.0f,1.0f,0,0);
	}
	else if (CW < 7)
	{
		/*int mode;
		if (CW == CW_DRAWQUADS)
			mode = GL_QUAD_STRIP;
		else if (CW == CW_DRAWTRIANGLES)
			mode = GL_TRIANGLES;
		else if (CW == CW_DRAWLINES)
			mode = GL_LINE_LOOP;
		else
			mode = GL_POINTS;
		glBegin(mode);*/
		glBegin(GL_QUAD_STRIP);
	}
	else if (CW == CW_ENDDRAW)
	{
		glEnd();
	}
	else if (CW == CW_TEXCOORD2POP)
	{
		const float u = *(FSP--);
		const float v = *(FSP--);
		glTexCoord2f(u,v);
	}
	else if (CW == CW_VERTEX2POP)
	{
		const float x = *(FSP--);
		const float y = *(FSP--);
		glVertex2f(x,y);
	}
	else if (CW == CW_VERTEX3POP)
	{
		const float x = *(FSP--);
		const float y = *(FSP--);
		const float z = *(FSP--);
		glVertex3f(x,y,z);
	}
	else if (CW == CW_COLOR4POP)
	{
		const float r = *(FSP--);
		const float g = *(FSP--);
		const float b = *(FSP--);
		glColor4f(r,g,b,*(FSP--));
	}
	else if (CW == CW_DRAWTESSPOLY)
	{
	    gluBeginPolygon(tess);
		tessidx = 0;
	}
	else if (CW == CW_ENDTESSDRAW)
	{
		gluEndPolygon(tess);
	}
	else if (CW == CW_TESSVX2POP)
	{
		tessvx[tessidx] = *(FSP--) / 512;
		tessvx[tessidx+1] = *(FSP--) / 512;
		tessvx[tessidx+2] = 0;
		gluTessVertex(tess, &tessvx[tessidx], &tessvx[tessidx]);
		tessidx += 3;
	}
	else if (CW == CW_CLS)
	{
		glClear(GL_COLOR_BUFFER_BIT);
	}
}

OPCODE OP_GFX2 = 12;

CDWORD CW_TEXTURE = 0;
CDWORD CW_NOTEXTURE = 1;
CDWORD CW_SPHERE4POP = 2;
CDWORD CW_BINDTEX1 = 3;
CDWORD CW_BINDTEX2 = 4;
CDWORD CW_ROTATE3POP = 5;

MNEM TEXTURE = CMD(OP_GFX2, CW_TEXTURE);
MNEM NOTEXTURE = CMD(OP_GFX2, CW_NOTEXTURE);
MNEM SPHERE4POP = CMD(OP_GFX2, CW_SPHERE4POP);
MNEM BINDTEX1 = CMD(OP_GFX2, CW_BINDTEX1);
MNEM BINDTEX2 = CMD(OP_GFX2, CW_BINDTEX2);
MNEM ROTATE3POP = CMD(OP_GFX2, CW_ROTATE3POP);

void gfx2()
{
	if (CW == CW_TEXTURE)
	{
		glEnable(GL_TEXTURE_2D);
	}
	/*else if (CW == CW_NOTEXTURE)
	{
		//glDisable(GL_TEXTURE_2D);
	}*/
	else if (CW == CW_SPHERE4POP)
	{
		//glEnable(GL_LIGHTING);
		//glEnable(GL_BLEND);
		//glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		//glBlendFunc(GL_SRC_COLOR, GL_DST_COLOR);
		//gluQuadricDrawStyle(quadric,GLU_SILHOUETTE);
		gluQuadricTexture(quadric,GL_TRUE);
		glPushMatrix();
		//float r = *(FSP--);
		float x = *(FSP--);
		float y = *(FSP--);
		float z = *(FSP--);
		glTranslatef(x+4,y-2,z);
		glColor4ub(200,120,120,100);
		gluSphere(quadric, 0.4, 20, 20);
		glColor4ub(200,120,120,40);
		gluSphere(quadric, 0.75, 20, 20);
		glPopMatrix();
		//glDisable(GL_BLEND);
		//glDisable(GL_LIGHTING);
	}
	else if (CW == CW_BINDTEX1 || CW == CW_BINDTEX2)
	{
		glBindTexture(GL_TEXTURE_2D, texid[CW-CW_BINDTEX1]);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	}
	/*else if (CW == CW_ROTATE3POP)
	{
		const float x = *(FSP--);
		const float y = *(FSP--);
		const float z = *(FSP--);
		glRotatef(x,1,0,0);
		glRotatef(y,0,1,0);
		glRotatef(z,0,0,1);
	}*/
}


typedef void(*voidfunc)();

voidfunc funxor[] = {R1oper,RXoper,IXoper,ipushim,fpush,fstpop,fstpeek,vecpush,vecstpop,vecstpeek,control,gfx,gfx2};


void eval()
{
	unsigned char operation;
	do
	{
		operation = *(PC++);
		unsigned char opcode = operation >> 4;
		CW = operation & 15;
		funxor[opcode]();
	} while(operation != END);
}

void noeval()
{
	int complexity = 0;
	do
	{
		unsigned char operation = *(PC++);
		unsigned char opcode = operation >> 4;
		if (operation == END)
			--complexity;
		else if (opcode == OP_CONTROL)
			++complexity;
	} while(! (complexity < 0));
}

typedef unsigned char program[];




///////////////////////////// SEQUENCER ///////////////////////////

void trig(float t)
{
	FREG[F_F] = -1.0f;
	float lim = 5.5f;
	float dur = 0.1f;
	for (float i=1; i<14; ++i)
	{
		if (t > lim && t < lim + dur)
			FREG[F_F] = 1.0f;

		lim += 6.0f - i*0.3f;
		dur *= 1.2f;
	}
	if (t > 55.0f)
		FREG[F_F] = 1.0f;
}




////////////////////////////// AUDIO ///////////////////////////////


#define SR 22050
const float spw = 1.0f / 22050.0f;

void render_audio(short *w, int len)
{
	//static float ticks = 0;

	while (len-- > 0)
	{
		trig(*AUDIO_T);

		program audio = {
			IPUSHIM(0),

			FPUSH(F_F), //if noise trigger
			IF_LTZ,
				INT2FLOAT, FSTPOP(F_A),
				IPUSHRNDBIT, INT2INT16, INT2INT16,
			END,
		END
		};
		PC = audio;
		eval();

		random();


		*(w++) = 12*(short)*(INTSP--);
		///////////////////// AUDIO TIMER /////////////////////
		FREG[F_AT] += spw;
	}
}

LPDIRECTSOUNDBUFFER dsb;
DWORD WSTART;
DWORD WLEN;

void write_audio()
{
	DWORD BufBytes1, BufBytes2;
	void *BufPtr1;
	void *BufPtr2;
	dsb->Lock(WSTART, WLEN, &BufPtr1, &BufBytes1, &BufPtr2, &BufBytes2, 0);
	render_audio((short*)BufPtr1, BufBytes1 / 2);
	render_audio((short*)BufPtr2, BufBytes2 / 2);
	dsb->Unlock(BufPtr1, BufBytes1, BufPtr2, BufBytes2);
}






void * reserve (unsigned int res_size)
{
	return LocalAlloc(GMEM_ZEROINIT, res_size);
}

#define RESERVE(TYPE, NUM) (TYPE *) reserve(NUM * sizeof(TYPE))


int WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
{
///////////////////// RESERVE MEMORY //////////////////////////

	PIXELFORMATDESCRIPTOR * pfd = RESERVE(PIXELFORMATDESCRIPTOR, 1);
	DEVMODE * dvm = RESERVE(DEVMODE, 1);
	//SUB = RESERVE(unsigned char *, 16);
	FSTACK = RESERVE(float, 98304);
	INTSTACK = RESERVE(int, 4096);
	float * VFREG = RESERVE(float, 16*4);
		VREG = VFREG;
		FREG = VREG + 15*3;
	//ECHOBFR = RESERVE(short, 44100);
	tessvx = RESERVE(double, 3*1024);

	FSPx[0] = FSTACK - 1;
	FSP = FSTACK - 1;
	FSPx[1] = FSTACK + 32767;
	FSPx[2] = FSTACK + 65535;
	INTSP = INTSTACK - 1;
	AUDIO_T = &FREG[F_AT];

	quadric = gluNewQuadric();


////////////////////// INIT WINDOW //////////////////////////////
	//PIXELFORMATDESCRIPTOR & pfd = descr->pfd;
	dvm->dmSize = sizeof(DEVMODE);
	dvm->dmPelsWidth = WIDTH;
	dvm->dmPelsHeight = HEIGHT;
	dvm->dmBitsPerPel = 32;		
	dvm->dmFields = DM_BITSPERPEL | DM_PELSWIDTH | DM_PELSHEIGHT;
	ChangeDisplaySettings(dvm, CDS_FULLSCREEN);

	pfd->nSize=sizeof(PIXELFORMATDESCRIPTOR);
	pfd->cColorBits = 32;
	pfd->dwFlags = PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER;
	HWND hWnd;
	HDC hDC = GetDC(hWnd = CreateWindow("edit", 0, WS_POPUP|WS_VISIBLE|WS_MAXIMIZE, 0, 0, 0 , 0, 0, 0, 0, 0));         
	SetPixelFormat(hDC, ChoosePixelFormat(hDC, pfd), pfd);
	wglMakeCurrent(hDC, wglCreateContext(hDC));

	
	ShowCursor(FALSE);
	//ShowWindow(hWnd,SW_SHOWMAXIMIZED);///
	SetForegroundWindow(hWnd);///

	tess = gluNewTess();
	gluTessCallback(tess, GLU_BEGIN, (GLvoid (__stdcall *) ( )) glBegin);
	gluTessCallback(tess, GLU_VERTEX, (GLvoid (__stdcall *) ( )) glVertex3dv);
	gluTessCallback(tess, GLU_END, (GLvoid (__stdcall *) ( )) glEnd);



	LPDIRECTSOUND8 dsnd = 0;
	DirectSoundCreate8(0, &dsnd, 0);
	dsnd->SetCooperativeLevel(hWnd, DSSCL_EXCLUSIVE);

	//const int msec = 1000;
	const int BufSize = 2 * SR;// * msec / 1000;

	WAVEFORMATEX pcmwf = {WAVE_FORMAT_PCM, 1, SR, BufSize, 2, 16, 0};

	DSBUFFERDESC dsbdesc = {sizeof(DSBUFFERDESC), DSBCAPS_STICKYFOCUS | DSBCAPS_GETCURRENTPOSITION2, BufSize, 0, &pcmwf, 0};
	dsnd->CreateSoundBuffer(&dsbdesc, &dsb, 0);

	WSTART = 0;
	WLEN = BufSize;
	write_audio();

	dsb -> Play(0, 0, DSBPLAY_LOOPING);
	DWORD WPLAY = 0;
	DWORD WMIX = 0;




unsigned char testpicture[491] =
{7, 
70, 95, 118,
109, 19,
154
, 114, 129, 72, 42, 26, 27, 81, 17, 34, 41, 232, 209, 248, 161, 163, 179, 193, 217, 225, 217, 232, 24, 208, 232, 248, 17, 32, 192, 176, 160, 169, 216, 216, 234, 0, 0, 192, 201, 224, 233, 1, 2, 250, 241, 233, 217, 201, 209, 201, 225, 241, 249, 249, 10, 65, 76, 73, 74, 120, 96, 56, 64, 73, 88, 56, 80, 168, 160, 160, 144, 136, 128, 104, 88, 56, 49, 40, 33, 41, 49, 72, 57, 8, 248, 219, 227, 218, 225, 225, 220, 223, 231, 238, 234, 235, 217, 177, 160, 137, 216, 136, 138, 130, 132, 105, 114, 113, 120, 153, 169, 161, 162, 162, 154, 145, 137, 123, 125, 115, 122, 121, 48, 50, 130, 136, 57, 56, 80, 49, 41, 83, 113, 73, 113, 139, 120, 66, 51, 98, 82, 89, 57, 48, 32, 248, 89, 112, 49, 97, 96, 65, 96, 144, 138
, 
10, 20, 40,
18, 120,
239
, 217, 232, 233, 235, 248, 9, 1, 2, 242, 249, 234, 224, 210, 192, 161, 138, 120, 120, 154, 160, 184, 216, 217, 218, 203, 202, 202, 210, 194, 201, 192, 97, 84, 89, 91, 90, 90, 97, 97, 202, 218, 218, 220, 210, 202, 200, 90, 114, 81, 81, 97, 90, 112, 105, 192, 192, 184, 160, 168, 248, 208, 136, 72, 160, 176, 152, 192, 216, 8, 216, 24, 24, 40, 208, 201, 202, 176, 216, 209, 201, 210, 210, 210, 193, 169, 153, 114, 115, 114, 96, 72, 144, 144, 136, 105, 104, 72, 48, 49, 136, 160, 96, 104, 104, 216, 113, 129, 120, 113, 106, 105, 88, 193, 193, 177, 185, 8, 27, 240, 225, 209, 201, 232, 208, 193, 208, 192, 208, 200, 152, 137, 232, 160, 168, 177, 248, 17, 24, 17, 232, 168, 216, 184, 200, 176, 232, 144, 232, 232, 241, 225, 224, 250, 1, 10, 3, 17, 35, 42, 42, 45, 43, 50, 51, 185, 187, 178, 169, 201, 232, 9, 232, 64, 232, 233, 234, 9, 249, 1, 16, 97, 1, 233, 32, 49, 98, 106, 108, 251, 234, 234, 0, 72, 89, 1, 66, 70, 68, 77, 71, 63, 79, 63, 75, 91, 107, 116, 137, 122, 208, 240, 233, 208, 120, 113, 129, 233, 232, 233, 216, 128, 216, 233, 121, 216, 208, 121, 131, 153, 112, 113, 97, 74, 90, 115, 122, 138, 154, 137
, 
//136, 174, 219,
118, 147, 234,
//0, 0, 255,
132, 131,
10
, 160, 152, 152, 112, 56, 48, 56, 16, 192, 208
, 
136, 174, 219,
//255, 255, 255,
162, 77,
11
, 104, 16, 1, 0, 0, 232, 184, 128, 120, 128, 96
, 
136, 174, 219,
//255, 255, 255,
180, 104,
14
, 56, 32, 48, 48, 64, 64, 224, 200, 200, 208, 193, 176, 128, 96
, 
//136, 174, 219,
100, 127, 244,
//0, 0, 255,
168, 99,
9
, 80, 8, 16, 24, 208, 176, 168, 152, 112
, 
10, 20, 40,
164, 98,
11
, 216, 232, 248, 48, 72, 96, 0, 88, 112, 192, 168
};
	int i = 490;
	do
	{
		*(++INTSP) = testpicture[i];
	}while(--i >= 0);

	glClearColor(0.86f,0.71f,0.51f,1);
	//glClearColor(1,1,1,1);
	//glClear(GL_COLOR_BUFFER_BIT);
	const int texreso = 512;
	glViewport(0,0,texreso,texreso);

	glGenTextures(2, texid);
	//glBindTexture(GL_TEXTURE_2D, texid[0]);

	glDrawBuffer(GL_FRONT_AND_BACK);

	program make_picture =
	{
		CLS,
		BINDTEX1,

		ORTHOGONAL,
		REPEAT,
			FPUSH1,
			INT2FLOAT256RCP,
			INT2FLOAT256RCP,
			INT2FLOAT256RCP,
			COLOR4POP,
			
			//DRAWLINES,
			DRAWTESSPOLY,
			INT2FLOAT/*256RCP*/,IPUSHIM(2),INT2FLOAT,FMUL, FSTPEEK(F_PY),
			INT2FLOAT/*256RCP*/,IPUSHIM(2),INT2FLOAT,FMUL, FSTPEEK(F_PX),

			//VERTEX2POP,
			TESSVX2POP,

			REPEAT,
				BYTECRACK53, //3 least significant are radius
				INT2FLOAT/*256RCP*/, //0...7 / 256 as radius
				FPUSH1/*256RCP*/,FADD, 
				IPUSHIM(6),INT2FLOAT,FMUL, // should be: (r0+1)*6

				INT2FLOAT16RCP, //0...2 as angle
				FPUSHPI,FMUL, //0...2pi

				POLAR,
				FPUSH(F_PX), FADD, FSTPOP(F_PX),
				FPUSH(F_PY), FADD, FSTPEEK(F_PY),
				FPUSH(F_PX),
				//VERTEX2POP,
				TESSVX2POP,
			END,
			//ENDDRAW,
			ENDTESSDRAW,
		END,
	END
	};

	PC = make_picture;
	eval();

	glCopyTexImage2D(GL_TEXTURE_2D,0,GL_RGB,0,0,texreso,texreso,0);
	glViewport(0,0,WIDTH,HEIGHT);

		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);


	program make_birds={
		CLS,
		IPUSHIM(0),
		INT2FLOAT,
		FSTPOP(F_A), //a=0

		IPUSHIM(BIRDNUM), INT2INT16,
		REPEAT,
			FPUSH(F_A), IPUSHIM(4), INT2FLOAT16, FMUL, FSIN, FPUSH(F_A), FADD, //push vx
			FPUSH(F_A), IPUSHIM(10), INT2FLOAT16, FMUL, FSIN, //push vy
			FPUSH0, //push vx
			
			FPUSH(F_A), IPUSHIM(10), INT2FLOAT16, FMUL, FSIN, //push z
			IPUSHIM(2), INT2FLOAT, //push 2.0f

			FPUSH1,
			FPUSH(F_A),
			FADD,
			FSTPEEK(F_A),//a++, push a

			POLAR, //pop a,2.0f -> push x,y	
		END,
	END
	}; //push BIRDNUM * P, V

	PC = make_birds;
	eval();
	glDrawBuffer(GL_BACK);


////////////////////// MAIN LOOP ///////////////////////////////
	do {
		//////////////// UPDATE SOUND //////////////////////////
		float previous_audio_t = (*AUDIO_T);
		dsb->GetCurrentPosition(&WPLAY, 0);
		int len = (int)WPLAY - (int)WMIX;
		if (len < 0) len += BufSize;
		WSTART = WMIX;
		WLEN = (DWORD)(len);
		write_audio();
		WMIX = WPLAY;
		FREG[F_DT] = (*AUDIO_T) - previous_audio_t;


		//////////////////// GFX ////////////////////////

		trig( (*AUDIO_T) - 1.0f );

		program make_texture =
		{
			BINDTEX2,
			//FPUSH(F_DT), IPUSHIM(10), INT2FLOAT, FMUL, FSTPOP(F_A), //a = dt*TH
			IPUSHIM(4), INT2INT16,
			REPEAT,
				IPUSHIM(4), INT2INT16,
				REPEAT,
					FPUSH1, //r
					FSTPEEK(F_A),
					FPUSH0, //g
					FPUSH0, //b
					FPUSH(F_A), //a

					FPUSH(F_F), // check noise trigger
					IF_LTZ,
						FSTPOP(F_A), VECSTPOP(V_A),
						IPUSHRNDBIT, INT2FLOAT, //r
						FSTPEEK(F_A),
						FPUSH0, //g
						FPUSH(F_A), IPUSHIM(8), INT2FLOAT16RCP, FMUL, //b
						FPUSH(F_A),
					END,


					//FPUSH(F_A), IPUSHIM(1), INT2FLOAT, FADD, FSTPOP(F_A), //a++
				END,
			END,

			IPUSHIM(4), INT2INT16, INT2INT16, INT2INT16,
			REPEAT,
				FSTPOP(F_A),
			END,
		END
		};
		PC = make_texture;
		eval();

		glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA,64,64,0,GL_RGBA,GL_FLOAT,FSP+1);

		program draw = {
			//Draw Girl:
			//CLS,
			ORTHOGONAL,
			BINDTEX1,

			FPUSH(F_F), // check noise trigger
			IF_LTZ,
				BINDTEX2,
			END,

			TEXTURE,
			IPUSHIM(3), INT2FLOAT16RCP,
			FPUSH1,
			FPUSH1,
			FPUSH1,
			COLOR4POP,
			DRAWQUADS,
				FPUSH1, //(0, 1)
				FPUSH0,
				TEXCOORD2POP,
				FPUSH0,	//(0, 0)
				FPUSH0,
				VERTEX2POP,

				FPUSH0, //(0,0)
				FPUSH0,
				TEXCOORD2POP,
				FPUSH1, //(0, 1)
				FPUSH0,
				VERTEX2POP,

				FPUSH1, //(0, 1)
				FPUSH0,
				TEXCOORD2POP,
				FPUSH0,	//(0.2, 0)
				IPUSHIM(3), INT2FLOAT16RCP,
				VERTEX2POP,

				FPUSH0, //(0,0)
				FPUSH0,
				TEXCOORD2POP,
				FPUSH1, //(0.2, 1)
				IPUSHIM(3), INT2FLOAT16RCP,
				VERTEX2POP,

				FPUSH1,
				IPUSHIM(14), INT2FLOAT16RCP,
				TEXCOORD2POP,
				FPUSH0,
				FPUSH1,
				VERTEX2POP,

				FPUSH0,
				IPUSHIM(14), INT2FLOAT16RCP,
				TEXCOORD2POP,
				FPUSH1,
				FPUSH1,
				VERTEX2POP,

			ENDDRAW,
			//NOTEXTURE,
			BINDTEX2,
		/*END
		};
		PC = drawgirl;
		eval();

		program draw = {*/
			// Draw Birds:
			PERSPECTIVE,
			CAMERA,

			IPUSHIM(BIRDNUM), INT2INT16, //pump stack0 to stack1 and stack2, read A,B (pos, v)
			REPEAT,
				VECSTPOP(V_A), //A = pos
				VECSTPOP(V_B), //B = v
				
				//DRAWLINES,
					//VECPUSH(V_B),
					//COLOR3POP,
					//VECPUSH(V_B),
					/*
					IPUSHIM(8), INT2FLOAT16RCP,
					IPUSHIM(1), INT2FLOAT,
					IPUSHIM(1), INT2FLOAT,
					IPUSHIM(1), INT2FLOAT,
					COLOR4POP,*/
					
					VECPUSH(V_A),
					//IPUSHIM(8), INT2FLOAT16RCP,
					SPHERE4POP,
					//VECPUSH(V_A),
					//IPUSHIM(14), INT2FLOAT16RCP,
					//SPHERE4POP,
					//VERTEX3POP, //draw
					//VECPUSH(V_A), VECPUSH(V_B), VECADD, VECUN,
					//VERTEX3POP,
				//ENDDRAW,

				STACK1, VECPUSH(V_B), VECPUSH(V_A),
				STACK2, VECPUSH(V_B), VECPUSH(V_A),
				STACK0, //push A,B to stack1 and stack2
			END,

			IPUSHIM(BIRDNUM), INT2INT16, //pump stack1, push to stack0
			REPEAT,
				STACK1, VECSTPOP(V_A), VECSTPOP(V_B), STACK0, //pop from stack1 to A,B

				IPUSHIM(9),
				REPEAT,
					IPUSHIM(0), INT2FLOAT,
				END,
				VECSTPOP(V_E), //E = P_mid
				VECSTPOP(V_F), //F = V_mid
				VECSTPOP(V_G), //G = evasion
				IPUSHIM(1), INT2FLOAT256RCP, FSTPOP(F_A), //a = n

				IPUSHIM(BIRDNUM), INT2INT16, //pump stack2 to stack0, read P, V for each j
				REPEAT,
					STACK2, VECSTPOP(V_C), VECSTPOP(V_D),
					STACK0,	VECPUSH(V_D), VECPUSH(V_C),
					//A = P, B = V, C = Pj, D = Vj
					
					VECPUSH(V_A), VECPUSH(V_C), VECNEG, VECADD, VECLEN, //|P-Pj|
					FSTPEEK(F_B), //b = dist
					IPUSHIM(4), INT2FLOAT,
					IPUSHIM(1), INT2FLOAT256RCP,

					IF_BOUNDS,
						VECPUSH(V_E), VECPUSH(V_C), VECADD, VECSTPOP(V_E), //E += C
						VECPUSH(V_F), VECPUSH(V_D), VECADD, VECSTPOP(V_F), //F += D
						FPUSH(F_A), IPUSHIM(1), INT2FLOAT, FADD, FSTPOP(F_A), //a++
					END,

					FPUSH(F_B),
					FPUSH1,
					IPUSHIM(1), INT2FLOAT256RCP,
					IF_BOUNDS, //if 1/256 < dist < 1
						VECPUSH(V_A), VECPUSH(V_C), VECNEG, VECADD, //P-Pj
						FPUSH(F_B), FRCP, VECSCALE, //(P-Pj) / |P-Pj|
						//IPUSHIM(1), INT2FLOAT16RCP, VECSCALE, // /= 16
						VECPUSH(V_G), VECADD,
						VECSTPOP(V_G), //G += P-Pj
					END,
				END,


				VECPUSH(V_E), VECPUSH(V_A), VECNEG, VECADD, FPUSH(F_A), FRCP, VECSCALE, VECSTPOP(V_E), //(E-=A) /= n
				VECPUSH(V_F), VECPUSH(V_B), VECNEG, VECADD, FPUSH(F_A), FRCP, VECSCALE, VECSTPOP(V_F), //(F-=V) /= n
				
				IPUSHIM(BIRDNUM), INT2INT16, //pump stack0 to stack2
				REPEAT,
					VECSTPOP(V_C), VECSTPOP(V_D),
					STACK2,	VECPUSH(V_D), VECPUSH(V_C), STACK0,
				END,
				
				//calculate new position and speed
				VECPUSH(V_B), FPUSH(F_DT), VECSCALE,
				VECPUSH(V_A), VECADD, 
				VECSTPOP(V_A), //A = p + v*dt

				VECPUSH(V_E), VECPUSH(V_A), VECNEG, VECADD, //Pmid - P
				IPUSHIM(1), INT2FLOAT, VECSCALE, //e * dt * (Pmid - P)
				
				VECPUSH(V_F), VECPUSH(V_B), VECNEG, VECADD, //Vmid - V
				IPUSHIM(7), INT2FLOAT16RCP, VECSCALE, //e * dt * (Vmid - V)

				VECADD, //r1+r2

				VECPUSH(V_G), //evasion
				IPUSHIM(3), INT2FLOAT16, VECSCALE, //e * dt * evasion
				
				VECADD, FPUSH(F_DT), VECSCALE,//r1+r2+r3

				VECPUSH(V_B), VECADD, VECSTPOP(V_B),  //V = V + (r1+r2+r3)
				//limit V:
				VECPUSH(V_B),
				VECLEN, FNEG, IPUSHIM(12), INT2FLOAT, FADD,
				IF_LTZ,
					VECPUSH(V_B),
					VECUN,
					VECSTPOP(V_B),
				END,

				VECPUSH(V_B), VECPUSH(V_A), //push A,B
			END,
			
			STACK2,
			IPUSHIM(BIRDNUM*2), INT2INT16, //repeat 2*6 times, pump stack2
			REPEAT,
				VECSTPOP(V_A), //pop from stack2
			END,
			STACK0,

		END
		}; //push BIRDNUM * (x, y)

		PC = draw;
		eval();

		SwapBuffers(hDC); 
		
	} while (!GetAsyncKeyState(VK_ESCAPE) && (*AUDIO_T) < 85.0f);


	ExitProcess(0);  
}


