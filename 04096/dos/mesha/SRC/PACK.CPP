/*---------------------------------------

0 [8BIT char]
1 0 <4BIT offset>
1 <1..N-1:1 count> <HUF size>
1 <N:1> <HUF count> <HUF size>

<HUF>
0 <YBIT>
1 <XBIT>

---------------------------------------*/

#include <stdio.h>
#include <io.h>
#include <malloc.h>
#include <string.h>
#include <fcntl.h>
#include <dos.h>
#include <ctype.h>
#include <conio.h>
#include <sys/stat.h>

typedef unsigned char byte;
typedef unsigned int  word;

#define TRUE 1
#define FALSE 0

#define MAX_BYTE 7000
#define MAX_TYPE 256

/*----------------------------------------------------------*/

char output[MAX_BYTE];
int  outcount;
int  outpos;
int  outbit;

void putbit(int i) {
  outcount++;
  outbit += outbit;
  if (outbit == 256) {
    outbit = 1;
    outpos++;
    output[outpos] = 0;
  }
  if (i) output[outpos] |= outbit;
}

void putbits(long val,int count) {
/*
  while (count--) {
    putbit( (val & 1) != 0 );
    val >>= 1;
  }
  if (val)
    printf("putbits failed!\n");
*/
  if (val >= (1 << count))
    printf("putbits failed!\n");
  while (count--) {
    putbit( (val & (1 << count)) != 0 );
  }
}

void putbyte(char val) {
  int i;
  while (outbit != 128) putbit(0);
  for (i=0;i<8;i++) {
    putbit( val & 1);
    val >>= 1;
  }
}

/*----------------------------------------------------------*/

typedef struct {
  word Type;
  word Size;
  word Data;
  word Count;
} tInfo;

int     Parity[256];
tInfo   *Best;
byte    Data[MAX_BYTE];
int     Last[MAX_BYTE];
int     Size,OrigSize;
int     Max1,Max2,Max3,Max4;
int     Min1,Min2,Min3,Min4;

int     Const1 = 4;     // 1byte move offsetsize
int     Const2 = 5;     // huffman size1
int     Const3 = 9;     // huffman size2
int     Const4 = 7;     // bitsize max

void SetBest(int i,int Size,int Type,int Count,int Data) {
  tInfo* p = Best+i;
  if (p->Size > p[Count].Size + Size) {
    p->Type = Type;
    p->Count = Count;
    p->Data = Data;
    p->Size = p[Count].Size + Size;
  }
}

void Search(int Pos) {
  int i,j,k,k1;
  SetBest(Pos,1+8,0,1,Data[Pos]);
  i=Last[Pos];
  k1=Const1?0:1;
  while (i>=0) {
    j = 0;
    k = Pos-i;
    while (Pos+j < Size && Data[i+j] == Data[Pos+j]) {
      j++;
      if (Const1 && j == 1 && k <= Max1)
        SetBest(Pos,1+1+Const1,1,j,k);
      if (k >= Min2 && k <= Max2) {
        if (j < Const4 && j >= 2)
          SetBest(Pos,1+j-k1+(1+Const2),2,j,k);
        else
        if (j >= Min2+1 && j <= Max2+1)
          SetBest(Pos,1+Const4-k1+(1+Const2)+(1+Const2),3,j,k);
        else
        if (j >= Min3+1 && j <= Max3+1)
          SetBest(Pos,1+Const4-k1+(1+Const3)+(1+Const2),4,j,k);
      }
      else
      if (k >= Min3 && k <= Max3) {
        if (j < Const4 && j >= 2)
          SetBest(Pos,1+j-k1+(1+Const3),5,j,k);
        else
        if (j >= Min2+1 && j <= Max2+1)
          SetBest(Pos,1+Const4-k1+(1+Const2)+(1+Const3),6,j,k);
        else
        if (j >= Min3+1 && j <= Max3+1)
          SetBest(Pos,1+Const4-k1+(1+Const3)+(1+Const3),7,j,k);
      }
    }
    i=Last[i];
  }
}

word bSize,bC1,bC2,bC3,bI1,bI2,bI3,bC4;

void Calc( void ) {
  int i;
  memset(Best,0xFF,sizeof(tInfo)*Size);
  Best[Size].Size = 0;
  Max1 = 1 << Const1;
  Min1 = 1;
  Max2 = 1 << Const2;
  Min2 = 1;
  Max3 = Max2+(1 << Const3);
  Min3 = Max2+1;
  Max4 = Const4;
  for (i=Size-1;i>=0;i--)
    Search(i);
  if (Best[0].Size < bSize) {
    bSize = Best[0].Size;
    bC1 = Const1;
    bC2 = Const2;
    bC3 = Const3;
    bC4 = Const4;
  }
}

int BestDeep;
int BestType[3][MAX_TYPE];

int Compress(int Super) {
  int i,j,k;
  long l;
  long outlast;
  for (i=0;i<256;i++) {
    j = 0;
    k = i;
    while (k) {
      if (k & 1) j++;
      k >>= 1;
    }
    Parity[i] = j & 1;
  }
  if (Super) {
    bSize = (word)-1;
    l = 0;
    for (Const1=0;Const1<=10;Const1++) {
      for (Const2=0;Const2<=10;Const2++) {
        for (Const3=Const2+1;Const3<=10;Const3++) {
          for (Const4=1;Const4<=10;Const4++) {
            Calc();
            if ((l & 15)==0) {
              printf("%5li %i:%i:%i:%i %3i %i        \r",l,bC1,bC2,bC3,bC4,(bSize+7)>>3,bSize);
              if (kbhit()) goto quit;
            }
            l++;
          }
        }
      }
    }
quit:
    printf("\n");
    Const1 = bC1;
    Const2 = bC2;
    Const3 = bC3;
    Const4 = bC4;
  }
  Calc();
  j = 0;
  BestDeep = 0;
  memset(BestType,0,sizeof(BestType));
  while (j < Size) {
    BestType[0][Best[j].Type]++;
    BestType[1][Best[j].Type]+=Best[j].Size - Best[j+Best[j].Count].Size;
    BestType[2][Best[j].Type]+=Best[j].Count;
    j += Best[j].Count;
    BestDeep++;
  };
  printf("Consts = %i,%i,%i,%i\nCompression in bytes: %i/%i (%li%%)\n"
         "Tokens: %i\n",Const1,Const2,Const3,Const4,(Best[0].Size+7)>>3,
    OrigSize,(long)((Best[0].Size+7)>>3)*100/OrigSize,BestDeep );
  for (i=0;i<MAX_TYPE;i++) {
    if (BestType[0][i])
      printf("  Type %i: %3i, %4i bits, decodes %4i bytes\n",i,
        BestType[0][i],BestType[1][i],BestType[2][i]);
  }
  outpos = -1;
  outbit = 128;
  outcount = 0;
  j = 0;
  k = Const1?0:1;
  while (j < Size) {
    outlast = outcount;
    switch (Best[j].Type) {
      case 0:
        putbit(0);
        putbits(Best[j].Data,8);
        break;
     case 1:
        putbit(1);
        putbit(0);
        putbits(Best[j].Data - Min1,Const1);
        break;
     case 2:
        putbit(1);
        for (i=1+k;i<Best[j].Count;i++) putbit(1);
        putbit(0);
        putbit(0);
        putbits(Best[j].Data - Min2,Const2);
        break;
     case 3:
        putbit(1);
        for (i=k;i<Const4;i++) putbit(1);
        putbit(0);
        putbits(Best[j].Count - Min2-1,Const2);
        putbit(0);
        putbits(Best[j].Data - Min2,Const2);
        break;
     case 4:
        putbit(1);
        for (i=k;i<Const4;i++) putbit(1);
        putbit(1);
        putbits(Best[j].Count - Min3-1,Const3);
        putbit(0);
        putbits(Best[j].Data - Min2,Const2);
        break;
     case 5:
        putbit(1);
        for (i=1+k;i<Best[j].Count;i++) putbit(1);
        putbit(0);
        putbit(1);
        putbits(Best[j].Data-Min3,Const3);
        break;
     case 6:
        putbit(1);
        for (i=k;i<Const4;i++) putbit(1);
        putbit(0);
        putbits(Best[j].Count-Min2-1,Const2);
        putbit(1);
        putbits(Best[j].Data-Min3,Const3);
        break;
     case 7:
        putbit(1);
        for (i=k;i<Const4;i++) putbit(1);
        putbit(1);
        putbits(Best[j].Count-Min3-1,Const3);
        putbit(1);
        putbits(Best[j].Data-Min3,Const3);
        break;
    }
    if (Best[0].Size - Best[j+Best[j].Count].Size != outcount) {
      printf("Write sync failed at %i type %i (orig:%i writed:%i)!\n",j,Best[j].Type,
        Best[j].Size - Best[j+Best[j].Count].Size, outcount - outlast );
      return 1;
    }
    j += Best[j].Count;
  }
  return 0;
}

void Convert( void ) {
  int i,j;
  for (i=0;i<Size;i++) {
    Last[i] = -1;
    for (j=i-1;j>=0;j--) {
      if (Data[i] == Data[j]) {
        Last[i] = j;
        break;
      }
    }
  }
}

/*----------------------------------------------------------*/

int main(int pc,char** ps) {
  int f;
  unsigned short s;
  ps = ps;
  printf("Text Packer v2.1\nCopyright (c) 1998 by Picard / Rhyme\n\n");
  Best = (tInfo*) malloc(sizeof(tInfo) * MAX_BYTE);
  if (Best == NULL) return 1;
  f = open("mesha.exe",O_BINARY | O_RDONLY);
  if (f == -1) {
    printf("Can't open input file!\n");
    return 1;
  }
  lseek(f,8,SEEK_SET);
  read(f,&s,2);
  lseek(f,s*16 + 0x1100,SEEK_SET);
  Size = read(f,Data,sizeof(Data));
  close(f);
  OrigSize = Size;
  Convert();
  if (Compress(pc > 1))
    return 1;
  f = open("unpack.com",O_BINARY | O_RDONLY);
  if (f == -1) {
    printf("Can't open unpack.com!\n");
    return 1;
  }
  Size = read(f,Data,sizeof(Data));
  close(f);
  f = open("mesha.com",O_RDWR | O_BINARY | O_TRUNC | O_CREAT,S_IREAD | S_IWRITE);
  if (f == -1) {
    printf("Can't create output file!\n");
    return 1;
  }
  write(f,Data,Size);
  write(f,output,(outcount+7)>>3);
  close(f);
  return 0;
}
