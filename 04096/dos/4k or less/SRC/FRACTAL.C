#include <dos.h>
#include <mem.h>
#include <stdio.h>
#include <stdlib.h>
#pragma inline
#define PROTECT
#define MATRIXSIZE 20

#define I asm
#define XPos 32
#define YPos 34
#define Xsize 128
#define Ysize 64
#define SCALE_FACTOR 16
//2
extern char Liike[];
extern int lasttodraw;
extern int *ScanRight;
extern int *ScanLeft;
extern int *ScanRCount;
extern int *ScanLCount;
extern long *sintaulu;
extern long *costaulu;

extern void pixel(int,int,int);
void CalcLandScape(void);
void setmode(void);
void piirralauta(void);
unsigned char *CurPalette;

typedef void (*funcptr)(void);

extern void ScanConvert(int x,int y,int x1,int y1,int *Scanner);
extern int *ScanRight;
extern int *ScanLeft;
void SetPage(unsigned offs)
{
I mov dx,03d4h
I mov bx,offs
I mov al,0ch
I mov ah,bh
I out dx,ax
I inc al
I mov ah,bl
I out dx,ax
}
volatile unsigned drawoffs=19200;

void rotate(int,int,int);
void LaskeSpeeds(void);

volatile int XN=0,YN=0;
volatile int KN=0;
volatile int XA,YA,KA;
int volatile TM;
volatile char *LiikePtr=Liike;

volatile int P_i=90,P_X=20,P_Y=20;
volatile int P_XCount=0,P_YCount=0,P_icount=0;
void VahennaTime(void)
{
		 if (lasttodraw>0) lasttodraw-=8;
		 if (TM>0) TM--; else
			{
			if (TM!=-1) {
				XA=LiikePtr[0];
				YA=LiikePtr[1];
				KA=LiikePtr[2];
				TM=LiikePtr[3];
				LiikePtr+=4;
			}
				else {lasttodraw+=16;return;}
			}

			P_icount+=(KN+=KA);
		if (P_icount<0) {P_i--;P_icount+=SCALE_FACTOR;} else
		if (P_icount>SCALE_FACTOR) {P_i++;P_icount-=SCALE_FACTOR;}
		if (P_i<0) P_i+=360;
		if (P_i>=360) P_i-=360;
		P_YCount+=(YN+=YA);
		if (P_YCount<0) {P_Y--;P_YCount+=SCALE_FACTOR;} else
		if (P_YCount>SCALE_FACTOR) {P_Y++;P_YCount-=SCALE_FACTOR;}
		P_XCount+=(XN+=XA);
		if (P_XCount<0) {P_X--;P_XCount+=SCALE_FACTOR;} else
				if (P_XCount>SCALE_FACTOR) {P_X++;P_XCount-=SCALE_FACTOR;}
}

void CalcSinTable(void);



extern char *landscape;
extern long *XCoord;
extern long *YCoord;
extern int *XIndex;
extern int *YIndex;
extern int *XIndex1;
extern int *YIndex1;
extern long *matrixZ;
extern void far TimerHandler(void);
void SetIntVec(char,unsigned,unsigned);

void clrscr(void)
{
	 I push es
	outport(0x3c4,0x0f02);
	_ES=0xa000;
	_EDI=drawoffs;
	_ECX=4800;
	_EAX=0;
	I rep stosd
	I pop es
}
void waitscreen(void);

void main_1()
{
	char  l_andscape[22500];
	long AXCoord[MATRIXSIZE*MATRIXSIZE];
	long AYCoord[MATRIXSIZE*MATRIXSIZE];
	int AXIndex[(MATRIXSIZE+1)*(MATRIXSIZE+1)];
	int AYIndex[(MATRIXSIZE+1)*(MATRIXSIZE+1)];
	int AXIndex1[(MATRIXSIZE+1)*(MATRIXSIZE+1)];
	int AYIndex1[(MATRIXSIZE+1)*(MATRIXSIZE+1)];
	long AMatrixZ[MATRIXSIZE*MATRIXSIZE];
	long A_sintaulu[360],A_costaulu[360];
	int End_effect(void);
	int j,item;
	XCoord=AXCoord;
	YCoord=AYCoord;
	XIndex=AXIndex;
	YIndex=AYIndex;
	XIndex1=AXIndex1;
	YIndex1=AYIndex1;
	_DI=(int)(matrixZ=AMatrixZ);
	_ES=_DS;
	_CX=MATRIXSIZE*MATRIXSIZE/4;
	asm rep stosd
	drawoffs=0;
	clrscr();

	landscape=l_andscape;
	sintaulu=A_sintaulu;costaulu=A_costaulu;

		_AX=0;
		_BX=980;
		_CX=_BX;
		_DI=(int)ScanRight;
		I rep stosw
		_CX=_BX;
		_DI=(int)ScanLeft;
		I rep stosw
		_CX=_BX;
		_DI=(int)ScanRCount;
		I rep stosw
		_CX=_BX;
		_DI=(int)ScanLCount;
		I rep stosw;
	 drawoffs=19200;
	 clrscr();
	 CalcSinTable();
	 CalcLandScape();
	 XA=LiikePtr[0];
	 YA=LiikePtr[1];
	 KA=LiikePtr[2];
	 TM=LiikePtr[3];
	 LiikePtr+=4;

	SetIntVec(0x8,FP_OFF(TimerHandler),_CS);
	#ifdef PROTECT
	I mov al,0feh
	I out 021h,al
	#endif
	for (;(TM!=-1 || lasttodraw<MATRIXSIZE*MATRIXSIZE);) {
		rotate(P_i,P_X,P_Y);

		piirralauta();

		waitscreen();

		drawoffs^=19200;
		outport(0x3c4,0x0f02);

		I mov ax,0a000h
		I mov es,ax
		I mov di,word ptr drawoffs
		I add di,3300
		I mov cx,4062
		I xor eax,eax
		I rep stosd
	}
}
