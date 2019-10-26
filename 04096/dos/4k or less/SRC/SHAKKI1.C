#include <dos.h>
#include <stdlib.h>

#pragma inline
#define I asm

#define MATRIXSIZE 20
#define MATRIXLEN 8
#define MATCONST2 2560
#define COLORDIV 930
int lasttodraw=MATRIXSIZE*MATRIXSIZE - 1;

int *ScanRight;
int *ScanLeft;
int *ScanRCount;
int *ScanLCount;
extern unsigned drawoffs;
long *sintaulu;
long *costaulu;

#define LANDXSIZE 150
#define LANDYSIZE 150

char *landscape;


void CalcLandScape(void)
{
	register int i,j;
	for (i=0;i<LANDYSIZE;i++)
		for (j=0;j<LANDXSIZE;j++)
		{
			int i2=i-80,j2=j-50;

			long korkeus=((sintaulu[(((i2*i2-j2*i2)/(5))%350)+5]+32000L)>>9)+
														((sintaulu[(((j-20)*30)%350)+5]+33000L)>>9);
			if (korkeus<0) korkeus=0;
			landscape[i*LANDXSIZE+j]=(char)korkeus;
		}
}

long *matrixZ;


void CalcSinTable(void)
{
	long v,x,vc=0,xc=0,AA=193948423;
	register int i;
	x=32768L;v=0;
	for (i=0;i<=360;i++) {
		costaulu[i]=x;
		_EAX=x << 15;
		I cdq
		I shl eax,1
		I rcl edx,1
		I idiv dword ptr AA

		I sub vc,edx
		I sbb v,eax
		_EAX=vc;
		_EDX=v;
		I add xc,eax
		I adc x,edx
	}
	for (i=0;i<360;i++) {
		if (i<=90) sintaulu[i]=costaulu[90-i]; else
							 sintaulu[i]=costaulu[360+90-i];
	}
}

void ScanConvert(int x1,int y1,int x2,int y2,int *Scanner)
{
	int x,y;
	int k,kj;
	int DxA,Dy;
	int count;
	int Sx;
		Sx=((DxA=x2-x1)<0)?-1:1;
	if ((Dy=y2-y1)<0)
	{
		int temp=x1;x1=x2;x2=temp;
		temp=y1;y1=y2;y2=temp;
		I neg word ptr Dy
		I neg word ptr DxA
		I neg word ptr Sx
	}
		I cmp word ptr Dy,0
		I jnl ei_pienempi
		I neg word ptr Dy
ei_pienempi:
		I jnz ei_nolla
		Scanner[y1]=x1;
		return;
ei_nolla:
	I mov ax,DxA
	I cwd
	I idiv word ptr Dy
	I mov word ptr k,ax
	I mov word ptr kj,dx
	I cmp dx,0
	I jnl ei_pienempi1
	I neg word ptr kj
ei_pienempi1:
	Sx+=k;
	count=0;
	_DI=FP_OFF(Scanner);
	_BX=y1;
	_DX=y2;
	I cmp dx,480
	I jng ei__
	I mov dx,480
ei__:
	I shl bx,1
	I shl dx,1
	I add bx,di
	I add dx,di
	_DI=count;
	_CX=kj;
	_AX=x1;
looppi:
	I mov [bx],ax
ei_first:
	I add di,cx
	I jng ei_toinen1
	I add ax,Sx
	I mov si,Dy
	I sub di,si
ei_toinen:
	I add bx,2
	I cmp bx,dx
	I jle looppi
	I jmp kylla_toinen
ei_toinen1:
	I add ax,k
	I add bx,2
	I cmp bx,dx
	I jle looppi
kylla_toinen:;
}

void Fillpatch(int y1,int y2,long color)
{
	int x1,x2,y,Dx,sDx,eDx,i,oy;
	char *p;
	static unsigned char LeftMask[]={0xf,0xe,0xc,0x8};
	static unsigned char RightMask[]={1,3,7,0xf};
	oy=y1;
	while (ScanRight[oy]>=320) ScanRight[oy++]=319;
	oy=y2;
	while (ScanRight[oy]>=320) ScanRight[oy--]=319;
	oy=y1;
	while (ScanLeft[oy]<0) ScanLeft[oy++]=0;
	oy=y2;
	while (ScanLeft[oy]<0) ScanLeft[oy--]=0;
	 p=(char *)(y1*80+drawoffs);
	outportb(0x3c4,2);
	_ES=0xa000;
	for (y=y1;y<=y2;y++,p+=80) {
		I .386
		_DI=FP_OFF(ScanLeft);
		I mov bx,word ptr y
		I shl bx,1
		I mov si,[bx+di]
		_DI=FP_OFF(ScanRight);
		I mov cx,[bx+di]
		I cmp si,cx
		I jne ei_pois
		continue;
ei_pois:
		I jbe ei_vaihtoa
		I xchg si,cx
		I mov [bx+di],cx
		_DI=FP_OFF(ScanLeft);
		I mov [bx+di],si
ei_vaihtoa:
		_DI=FP_OFF(p);

		I mov dx,si
		I and si,3
		I mov al,[si+offset LeftMask]
		I shr cx,2
		I shr dx,2
		I add di,dx
		I sub cx,dx
		I mov dx,03c5h;
		I jle only_one_byte
		I out dx,al
		I mov eax,color
		I stosb
		I mov al,15
		I sub cx,2
		I jz three_bytes
		I jnl not_only_two_bytes
		I jmp only_one_byte
three_bytes:
		I out dx,al
		I mov eax,color
		I stosb
		I mov al,15
		I	jmp only_one_byte
not_only_two_bytes:
		I out dx,al
			I .386
			I inc cx
			I mov eax,color
			I shr cx,1
			I jnc ei_byte
			I stosb
ei_byte:;
			I shr cx,1
			I jnc ei_word
			I stosw
ei_word:;
			I rep stosd
			I mov al,15

only_one_byte:
	 I push di
	 _DI=FP_OFF(ScanRight);
	 I mov bx,[bx+di]
	 I pop di
	 I and bx,3
	 I and al,[bx+offset RightMask]
	 I out dx,al
	 I mov eax,color
	 I stosb
	}
}

void patch(int *x,int *y,unsigned long color)
{
	int i,MaxIndex,Temp,AA;
	register int MinIndexR,MinIndexL;
	int MinPointY,MaxPointY,TopIsFlat,LeftEdgeDir;
	int CurIndex,PrevIndex;
	int *ScanK;

	MaxPointY=MinPointY=y[MinIndexL=MaxIndex=0];
	for (i=1;i<4;i++) {
		if (y[i]<MinPointY) MinPointY=y[MinIndexL=i]; else
		if (y[i]>MaxPointY) MaxPointY=y[MaxIndex=i];
	}
	if (MinPointY==MaxPointY) return;
	MinIndexR=MinIndexL;
	while (y[MinIndexR]==MinPointY) {MinIndexR++;MinIndexR&=3;}
	MinIndexR--;MinIndexR&=3;
	while (y[MinIndexL]==MinPointY) {MinIndexL--;MinIndexL&=3;}
	MinIndexL++;MinIndexL&=3;
	LeftEdgeDir=-1;
	if (0!=(TopIsFlat=(x[MinIndexL]!=x[MinIndexR]) & 1)) {//?1:0)==1) {
		if (x[MinIndexL]>x[MinIndexR]) {
			LeftEdgeDir=1;
			Temp=MinIndexL;
			MinIndexL=MinIndexR;
			MinIndexR=Temp;
		}
	}
	if (MaxPointY-MinPointY-1+TopIsFlat<=0) return;
	PrevIndex=CurIndex=MinIndexL;
	ScanK=ScanLeft;
	for (AA=0;AA<2;AA++) {
		do {
			CurIndex+=LeftEdgeDir;CurIndex&=3;
			ScanConvert(x[PrevIndex],y[PrevIndex],x[CurIndex],y[CurIndex],ScanK);
			PrevIndex=CurIndex;
		} while (CurIndex!=MaxIndex);
		PrevIndex=CurIndex=MinIndexR;
		I neg word ptr LeftEdgeDir
		ScanK=ScanRight;
	}

	if (MaxPointY>=240) MaxPointY=239;
	for (i=MinPointY;i<=MaxPointY;i++)
	{
		if (ScanRight[i]<0) ScanRight[i]=0;
		if (ScanRight[i]>=320) ScanRight[i]=319;
		if (ScanLeft[i]<0) ScanLeft[i]=0;
		if (ScanLeft[i]>=320) ScanLeft[i]=319;
	}
	Fillpatch(MinPointY,MaxPointY,color);
}

long *XCoord;
long *YCoord;
int *XIndex;
int *YIndex;
int *XIndex1;
int *YIndex1;

void rotate(int kulma,int xp,int yp)
{
	int i,j;
	long sinalfa,cosalfa,Zsinalfa,Zcosalfa,Xcosalfa,Xsinalfa,Dsin,Dcos,DsinTemp,DcosTemp;
	int offs1;
	I movzx ebx,word ptr kulma
	I movzx eax,word ptr sintaulu
	I mov esi,[eax+ebx*4]
	I movzx ecx,word ptr costaulu
	I mov edi,[ebx*4+ecx]
	I imul eax,esi,-MATCONST2
	I mov Zsinalfa,eax
	I mov Xsinalfa,eax
	I mov DsinTemp,eax
	I imul eax,edi,-MATCONST2
	I mov Zcosalfa,eax
	I mov Xcosalfa,eax
	I mov DcosTemp,eax
	I imul eax,esi,MATRIXLEN*2*16
	I mov Dsin,eax
	I imul eax,edi,MATRIXLEN*2*16
	I mov Dcos,eax

	for (i=0;i<MATRIXSIZE;i++)
	{
		for (j=0;j<MATRIXSIZE;j++)
		{

			int Z;

			_AL=(landscape[(i+yp)*LANDXSIZE+j+xp]&255);
			_AH=0;
	I mov ecx,dword ptr Xcosalfa
	I add ecx,dword ptr Zsinalfa
	I push ecx
	I mov ecx,dword ptr Zcosalfa
	I sub ecx,dword ptr Xsinalfa
	I cwde
			I shl eax,17
			I mov esi,eax
			I mov edi,ecx
			I sar ecx,1
			I add esi,ecx
			I neg esi
			I sar eax,1
			I sub edi,eax
			I mov ecx,edi
			I sar edi,12
			matrixZ[offs1=i*MATRIXSIZE+j]=_EDI;

			I pop eax
			I sar ecx,1
			I sar esi,1
			I sar eax,1

			I add ecx,0x4020000
			I jnl ei_neg
			XCoord[offs1]=-5000;
			YCoord[offs1]=-5000;
			I jmp save_values

ei_neg:
			I mov edx,100*2
			I imul edx
			I idiv ecx
			I pop ecx*/

			I push ecx
			I movzx ebx,word ptr offs1
			I movzx ecx,word ptr XCoord
			I mov dword ptr [ecx+ebx*4],eax
			I pop ecx


			I mov eax,esi
			I mov edx,100*2
			I imul edx
			I idiv ecx

			I movzx ecx,word ptr YCoord
			I mov dword ptr [ecx+ebx*4],eax

save_values:
			I mov eax,Dcos
			I add Xcosalfa,eax
			I mov eax,Dsin
			I add Xsinalfa,eax
		}
		I mov eax,Dcos
		I add Zcosalfa,eax
		I mov eax,Dsin
		I add Zsinalfa,eax

		I mov eax,DcosTemp
		I mov Xcosalfa,eax

		I mov eax,DsinTemp
		I mov Xsinalfa,eax

	}

}

void SortIndexes(int mini,int maxi)
{
	int k,data1,data2;
	register int i,j;
	int d;
	if (maxi>mini) {
		d=(mini+maxi)>>1;
		SortIndexes(mini,d);
		SortIndexes(d+1,maxi);
		I mov ax,ds
		I mov es,ax
		I movzx eax,word ptr mini
		I movzx esi,word ptr XIndex
		I movzx edi,word ptr XIndex1
		I lea esi,[esi+2*eax]
		I lea edi,[edi+2*eax]
		I movzx ecx,word ptr maxi
		I sub ecx,eax
		I inc ecx
		I shr ecx,1
		I jnc ei_wordi
		I movsw
ei_wordi:
		I rep movsd

		I movzx esi,word ptr YIndex
		I movzx edi,word ptr YIndex1
		I movzx eax,word ptr mini
	 I lea esi,[esi+2*eax]
	 I lea edi,[edi+2*eax]
		I movzx ecx,word ptr maxi
		I sub ecx,eax
		I inc ecx
		I shr ecx,1
		I jnc ei_wordi1
		I movsw
ei_wordi1:
		I rep movsd


	 for (i=k=mini,j=d+1;k<=maxi;k++)
			if (i>d)
				{XIndex[k]=XIndex1[j];YIndex[k]=YIndex1[j++];} else
			if (j>maxi)
				{XIndex[k]=XIndex1[i];YIndex[k]=YIndex1[i++];} else

			if (matrixZ[XIndex1[i]*MATRIXSIZE+YIndex1[i]]<matrixZ[XIndex1[j]*MATRIXSIZE+YIndex1[j]])
				{XIndex[k]=XIndex1[i];YIndex[k]=YIndex1[i++];} else
				{XIndex[k]=XIndex1[j];YIndex[k]=YIndex1[j++];}

	}
}


void DoSortIndex(void)
{
	static int Done=0;
	register int i,j;
	if (!Done) { Done=1;
	 I movzx esi,XIndex
	 I movzx edi,YIndex
	 I xor eax,eax
	 I mov dx,MATRIXSIZE-1
l2:
	 I mov cx,MATRIXSIZE-1
l1:
	 I mov word ptr [esi+eax*2],dx
	 I mov word ptr [edi+eax*2],cx
	 I inc ax
	 I loop l1
	 I dec dx
	 I jnl l2
	}
	SortIndexes(0,MATRIXSIZE*MATRIXSIZE-1);
}

void piirralauta(void)
{
	int tabX[4],tabY[4];
	int i,j;
	int k;
	int color;

	DoSortIndex();
	for (k=MATRIXSIZE*MATRIXSIZE;k>=lasttodraw;k--)
		{
			int AA;
			register long *XAPtr,*YAPtr;
			i=XIndex[k];
			j=YIndex[k];
			AA=i*MATRIXSIZE+j;
			if ((unsigned)i>=MATRIXSIZE-1 || (unsigned)j>=MATRIXSIZE-1) continue;

			XAPtr=XCoord+AA;
			tabX[0]=XAPtr[0]+160;
			tabX[1]=XAPtr[MATRIXSIZE]+160;
			tabX[2]=XAPtr[MATRIXSIZE+1]+160;
			tabX[3]=XAPtr[1]+160;

			YAPtr=YCoord+AA;
			tabY[0]=YAPtr[0]+120;
			tabY[1]=YAPtr[MATRIXSIZE]+120;
			tabY[2]=YAPtr[MATRIXSIZE+1]+120;
			tabY[3]=YAPtr[1]+120;
			color=30-(matrixZ[AA]/COLORDIV);

			if ((tabX[0] & tabX[1] & tabX[2] & tabX[3])<0) continue;
			if (tabX[0]>=320 && tabX[1]>=320 && tabX[2]>=320 && tabX[3]>=320) continue;
			if (tabY[0]>=240 && tabY[1]>=240 && tabY[2]>=240 && tabY[3]>=240) continue;
			if ((tabY[0]|tabY[1]|tabY[2]|tabY[3])<0) {continue;}

				_ECX=color;
				_CH=_CL;
				I push Cx
				I push Cx
				I pop eCx
				patch((int*)tabX,(int*)tabY,_ECX);
		}
}

