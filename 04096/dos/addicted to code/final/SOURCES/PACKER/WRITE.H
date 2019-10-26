//#define DEBUG1

unsigned long actbit = 0;

void writebit(int bit) {
int mask = 1;
unsigned long bitpos;
  bitpos = (actbit >> 3);
  mask <<= ( actbit & 7 );
  if (!bit) dst[bitpos] &= 255-mask;
  else dst[bitpos] |= mask;
  actbit++;
}
///////////////////////////////////////////////////////////////////////////////
void writeint(int num,int bits) {
  for (--bits; bits!=-1; bits--) writebit( (num >> bits) & 1);
}
///////////////////////////////////////////////////////////////////////////////
int actrbit=0;
int yyuu;

int readbit() {
  yyuu=0;
  _asm{
  mov	esi,[dst]
  mov	edi,[actrbit]
  inc	[actrbit]
  bt	[esi],edi
  jnc   Nope1
  mov	[yyuu],1
Nope1:
  } 
  return(yyuu);
}
///////////////////////////////////////////////////////////////////////////////
int readint(int bits) {
int x = 0,b;
  for (b=0; b<bits; b++) {
	x<<=1;
	x|=readbit();
	}
  return(x);
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
void writetree() {
int x,y,i,j;
int lastdist = 0;

  for (x=0; x<16; x++) writeint( treefreq[x].bits ,3);

  for (x=0; x<distlast; x++) 
	writeint( treefreq[ distfreq[x].bits ].code,
	          treefreq[ distfreq[x].bits ].bits);

  for (x=0; x<codelast; x++) 
	writeint( treefreq[ codefreq[x].bits ].code,
		  treefreq[ codefreq[x].bits ].bits);

  for (y=0; (listdst[y]!=256); y++) {
    i = listdst[y];
    if (i==256) break;

    if (i<=256) writeint(codefreq[i].code,codefreq[i].bits);
    else {
    	for (x=0; ((i-256+1)>=TLengMax[x+1]); x++);
	writeint(codefreq[x+257].code,codefreq[x+257].bits);
	writeint(((i-256+1)-TLengMax[x]),TLengBit[x]);
        

        j = listdst[++y];
	if (j == lastdist) {
	  writeint(distfreq[0].code,distfreq[0].bits);
	  }
	else {
          for (x=0; ((j)>=TDistMax[x+1]); x++);
          writeint(distfreq[x+1].code,distfreq[x+1].bits);
          writeint( j-TDistMax[x] , TDistBit[x] );
	  lastdist = j;
          }

	
        }
  }
  writeint(codefreq[256].code,codefreq[256].bits);

  cout << "Data compressed : " << actbit / 8+1 << endl;
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
void read_asm() {
int bitcount;
char *temp;
int *distance,*literal,*codes;
int a1,a2,a3,x;
int lastdist;

  temp = new char [1000000];
  codes = new int [10000];
  distance = &codes[16*2];
  literal = &distance[distlast*2];

  cout << endl << "Decompression... ";
  bitcount = 0;
  _asm{
 	mov	edi,[codes]
	mov	ecx,16
	push	edi
	push	ecx
DecodeFirst:
	mov	edx,3
	call	ReadInt
	stosd
	stosd
	loop	DecodeFirst
	pop	ecx
	pop	esi
	call	Build
	mov	ecx,[distlast]
	call	DecodeTree
	mov	ecx,[codelast]
	call	DecodeTree
 	mov	edi,[temp]
	jmp	UnCmp3
;///////////////////////////////////////////////
DecodeTree:
	push	ecx
	push	edi
DT:
	mov	esi,[codes]
	call	ReadCode
	stosd
	stosd
	loop	DT
	pop	esi
	pop	ecx
Build:
	xor	eax,eax
	xor	edx,edx
BB1:
	add	edx,edx
	inc	eax
	push	esi
	push	ecx
BB2:
	cmp	[esi],eax
	jnz	NopeBB
	mov	[esi+4],edx
	inc	edx
NopeBB:
	add	esi,8
	loop	BB2
	pop	ecx
	pop	esi
	cmp	al,15
	jnz	BB1
	ret
;///////////////////////////////////////////////
ReadInt:
	xor	eax,eax
ReadInt2:
 	or	edx,edx
	jz	NopeRi
	push	esi
	push	ecx
	mov	esi,[dst]
RI:
	mov	ecx,[bitcount]
	bt	[esi],ecx
	inc	[bitcount]
	rcl	eax,1
	dec	edx
	jnz	RI
	pop	ecx
	pop	esi
NopeRI:
	ret
;///////////////////////////////////////////////
UnCmp3:
	jmp	UnCmp2
;///////////////////////////////////////////////
UploadNum:
	dec	eax
	mov	dl,al
	sub	dl,cl
	js	BitsNope
	dec	cl
	and	al,cl
	inc	cl
	or	al,cl
	shr	cl,1
	shr	dl,cl
	jz	BitsNope
	and	edx,0FFh
	call	ReadInt2
BitsNope:
	ret
;///////////////////////////////////////////////
ReadCode:
	push	ebx
	xor	ebx,ebx
RC:
	mov	edx,[esi]
	or	edx,edx
	jz	NopeCode
	call	ReadInt
	cmp	eax,[esi+4]
	jz	Done
NopeCode:
	lodsd
	sub	[bitcount],eax
	lodsd
	inc	ebx
	jmp	RC
Done:
	xchg	eax,ebx
	pop	ebx
	ret
;///////////////////////////////////////////////
UnCmp2:
	jmp	UnCmp
;///////////////////////////////////////////////
Compress:
	dec	eax
	mov	ecx,4
	call	UploadNum
	push	eax
	mov	esi,[distance]
	call	ReadCode
	mov	ecx,2
	call	UploadNum
	inc	eax
	jz	LastDistance
	xchg	eax,ebx
LastDistance:
	pop	ecx
	mov	esi,edi
	sub	esi,ebx
	cmp	ebx,129
	sbb	ecx,-1-3
	rep	movsb
UnCmp:
	mov	esi,[literal]
	call	Readcode
	sub	eax,256
	jz	EOF11
	ja	Compress
	stosb
	jmp	UnCmp
EOF11:
	sub	edi,[temp]
	mov	[a1],edi
  }
  cout << "uncompressed size : " << a1 << endl;
  a2 = a3 = 0;
  int equal = 0;
  for (x=0; x<a1; x++) {
    a2 += int(src[x]);
    a3 += int(temp[x]);
    if (src[x] != temp[x]) if (!equal) equal = x;
    }
  cout << "Results: EQUAL-" << equal << " , CONTROL SUMS(old,new): " << a2 << " , " << a3 << endl;
  delete [] temp;
  delete [] literal;
  delete [] distance;
  delete [] codes;
}


