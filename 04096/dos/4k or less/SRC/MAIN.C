#include <dos.h>
#pragma asm
#define PROTECT
#define I asm
extern void bezier(int x1,int y1,int x2,int y2,int x3,int y3,int x4,int y4,int color);
void scanconvert2(int,int,int,int,int);
void SetPage(unsigned);

extern unsigned drawoffs;

extern char cmdtable[];
extern int lengthtable[];
extern char delaytable[];

int *wcmdtable;
int *wcmdtable2;
int *xspeed;
int *yspeed;
int color=60;
int oldframes=0;
int framecount=0;
int * cnvrt(register int *a,register int *b,int frames)
{
	int ispeed;
	if (frames!=oldframes) {framecount=0; oldframes=frames; }
												 else framecount++;
	if (frames==1) {
		a[0]=b[0];a[1]=b[1];} else {
	frames--;
	a[0]+=(
				 xspeed[framecount]+=
						( ( (((b[0])-(a[0])) /frames)-xspeed[framecount]) )>>2   );
	a[1]+=(yspeed[framecount]+=
		((((b[1])-(a[1]))/(frames)-yspeed[framecount])) >>2) ;
	}
	return a+2;
}

int *cnvrtbezier(int *a,int *b,const int frames,int nro)
{
	int i,*k;
	for (i=0;i<=nro;i+=2)
		k=cnvrt(a+i,b+i,frames);
	return k;
}

typedef int * (*CNVRTFUNC)(int *,int *,const int);
int *convert(register int *a,int *b,const int frames)
{
	int nro=6;
	do {
				register int *p=cnvrtbezier(a,b,frames,nro);
			b+=p-a; a=p;
			nro=2;
	 } while (*a);
		return a+1;
}

int beziernro=1;
extern int *ScanLeft;
extern int *ScanRight;
char *ScanMark;
void ScanConvert(int,int,int,int,int *);
void Fillpatch(int,int,long);

void scanconvert2(int x1,register int y1,int x2,register int y2,int color)
{
	int markcode,i,sx;
	if (y1==y2) return;
	if (y2>=240) y2=239;
	if (y1>=240) y1=239;
	if (y1>y2) {
		I mov ax,y1
		I xchg ax,y2
		I mov y1,ax
		I mov ax,x1
		I xchg ax,x2
		I mov x1,ax
		}
	x1+=32;x2+=32;
	if ((ScanMark[y1+1]==0 && ScanMark[y2-1]==0) || (ScanMark[y1+1]==beziernro || ScanMark[y2-1]==beziernro)) {
		markcode=beziernro;
		ScanConvert(x1,y1,x2,y2,ScanLeft);
	} else
	{
		int A,temp;
		markcode=0;
		ScanConvert(x1,y1,x2 ,y2,ScanRight);
		for (A=y1;A<y2;A++) {
			I movzx eax,word ptr A
			I movzx ebx,word ptr ScanLeft
			I movzx ecx,word ptr ScanRight
			I mov dx,[eax*2+ebx]
			I cmp dx,[eax*2+ecx]
			I jle no_swap
			I xchg dx,[eax*2+ecx]
			I mov [eax*2+ebx],dx
no_swap:

		}
		_AL=color;
		_AH=_AL;
		I push ax
		I push ax
		I pop ecx
		Fillpatch(y1,y2,_ECX);
	}
	for (i=y1;i<y2;i++) ScanMark[i]=markcode;
}


#define SET_RES(a)
#define ENABLE_SET(a)
#define SET_RES1(a)
#define ENABLE_SET1(a)


int * draw(register const int *p)
{
	beziernro=1;
 _ES=_CS;
 _DI=(int)ScanMark;
 _CX=120;
 _EAX=0;
	I rep stosd
	do {
		bezier(p[0],p[1],p[2],p[3],p[4],p[5],p[6],p[7],color);
		p+=8;
		beziernro++;
	} while (*p);
	return (int *)++p;
}
void waitscreen(void)
{
	while((inportb(0x3da)&8));
	SetPage(drawoffs);
	while(0==(inportb(0x3da)&8));
}
void clrscr(void);

void partdo(int frame)
{
	convert(wcmdtable,draw(wcmdtable),frame);
	waitscreen();
	drawoffs^=19200;
	clrscr();
}


void setmode(void);
extern unsigned char *CurPalette;
extern void DoSetPalette(char *pal);
int main_2(void)
{
 char *p;
 char _ScanMark[482];
 int _wcmdtable[2000];
 int frame,temp,i;
 int _xspeed[2000],_yspeed[2000];
 int lengthindex=0;
 ScanMark=_ScanMark;
 _ES=_DS;
 _SI=(int)cmdtable;
 _DI=(int)_wcmdtable;
 _CX=1000;
 _AH=0;
loopppi:
I lodsb
I mov dl,al
I and ax,0f0h
I shl ax,4
I stosw
I mov al,dl
I and ax,0fh
I shl ax,8
I stosw
I loop loopppi
 xspeed=_xspeed;


 yspeed=_yspeed;
 _DI=FP_OFF(ScanMark);
 _CX=482;
 asm rep stosb

 wcmdtable=_wcmdtable;
 setmode();
 SetPage(19200);
	 for (temp=0,i=0;temp<63;temp++,i+=3)
	 {
				CurPalette[i+1]=CurPalette[i]=temp/2;
				CurPalette[i+2]=temp;

	 }

	 I push es
		_ES=_DS;
		_DX=FP_OFF(CurPalette);
		_CX=256;
		_BX=0;
		_AX=0x1012;
		geninterrupt(0x10);
 I pop es

 draw(wcmdtable);
 for (frame=0;frame<100;frame++) waitscreen();
 do {
 _ES=_DS;
 _CX=2000;
 _BX=_CX;
 _DI=(int)xspeed;
 _AX=0;
I rep stosw
 _DI=(int)yspeed;
 _CX=_BX;
 _AX=0;
I rep stosw

	 for (frame=lengthtable[lengthindex];frame>0;frame--) {
		partdo(frame);
		partdo(--frame);
	}
		wcmdtable=draw(wcmdtable);

		_CX=(unsigned char)delaytable[lengthindex];
l1:
		I push cx
		waitscreen();
		I pop cx
		I loop l1
 } while (lengthtable[++lengthindex]!=-1);
 return 0;
}

extern int *ScanRCount;
extern int *ScanLCount;
extern void main_1(void);

typedef void far *HANDLER;
HANDLER  OldKbHandler,OldTimerHandler;

void VahennaTime(void);

void far TimerHandler(void)
{
I pusha
I push cs
I pop ds
I call near ptr VahennaTime
I mov al,20h
I out 20h,al
I popa
I iret
}

void SetIntVec(char nro,int hoff,int hseg)
{
	asm push ds
	_DS=hseg;
	_DX=hoff;
	_AH=0x25;
	_AL=nro;
	geninterrupt(0x21);
	asm pop ds
}

void main()
{
	int Iseg,Iofs;
	int  A_ScanRight[980];
	int  A_ScanLeft[980];
	int  A_ScanRCount[980];
	int  A_ScanLCount[980];
	char  c_urpalette[768];
	#ifdef PROTECT
	I mov al,0ffh
	I out 021h,al
	#endif

	ScanRight=A_ScanRight;
	ScanLeft=A_ScanLeft;
	ScanRCount=A_ScanRCount;
	ScanLCount=A_ScanLCount;
	CurPalette=c_urpalette;

	asm push es
	_AX=0x3508;
	geninterrupt(0x21);
	Iseg=_ES;
	Iofs=_BX;

	asm pop es
	main_2();
	main_1();
	I cli
	SetIntVec(0x8,Iofs,Iseg);
#ifdef PROTECT

	I mov al,0b0h
	I out 021h,al
#endif
	_AX=3;
	geninterrupt(0x10);
}
