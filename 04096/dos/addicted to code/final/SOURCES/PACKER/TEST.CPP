
#include <iostream.h>
#include <stdio.h>
#include "types.h"
#include "inc.h"
#include "huffman.h"
#include "arthm.h"

///////////////////////////////////////////////////////////////////////////////
class LZNode {
public:
  LZNode 	*next,*prev;
  int 		p;
};

int	maxdct,code,ncode;
LZNode 	**wordtab;			//table of indexes to last byte pairs
LZNode	*ndct,*wtab,*lzdct;		//some useful pointers

byte 	*src,*dst,*pdst;		//source and destination buffers

byte	*arthm_dst1;
byte	*pdst1;

BStream	bst0;				// for arithmetic codes stream
BStream	bst1;				// for distance + extra leng bits
BStream bst;				// for combined bst1 + bst0

///////////////////////////////////////////////////////////////////////////////
void NewCode (int x) {
  code = src[x]+(src[x+1] << 8);
  wtab = wordtab[code];
  ndct = &(lzdct[x & (maxdct-1)]);

  if (x>=maxdct) {
      if (ndct->next) ndct->next->prev = NULL;
      else {
	   ncode = src[ndct->p]+(src[ndct->p+1] << 8);
           wordtab[ncode] = NULL;
	   }
      }
  
  if (!wtab) ndct->prev = NULL;
  else {
     ndct->prev = wtab;
     wtab->next = ndct;
     }
  ndct->next = NULL;
  ndct->p = x;
  wordtab[code] = ndct;
}
///////////////////////////////////////////////////////////////////////////////
dword	Power2(dword val) 
{
dword  p2,n;
  p2 = 0;
  n = val;
  while (n) {
    p2++;
    n >>= 1;
    }
  if (p2) p2--;
  return p2;
}
///////////////////////////////////////////////////////////////////////////////
FILE 	*f;
int	x,y,z,i,j,d;
int	filesize;
int	CRC1,CRC2;
int 	unit1s,unit2s,trees;
///////////////////////////////////////////////////////////////////////////////
  int symbols,extrabits,extraleng;
///////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
main() {

  maxdct = 32768;
  lzdct = new LZNode [maxdct];
  wordtab = new LZNode* [ 65536 ];
  for (x=0; x<65536; x++) wordtab[x] = NULL;

  if ((f = fopen("s.s","rb"))==0) cerr << " File error !" << endl;
  fseek(f,0,2);
  filesize = ftell(f);

  src = new byte [filesize];
  arthm_dst1 = new byte [filesize];
  pdst1 = new byte [filesize];

  fseek(f,0,0);

  fread(src,8192,1,f);
  filesize -= 8192;
  fread(src,filesize,1,f);
  fclose(f);

  bst0.SetTable(arthm_dst1);
  bst0.SetBitPos(0);
  bst1.SetTable(pdst1);
  bst1.SetBitPos(0);

  cout << " þ Filesize: " << filesize << endl;
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//compress...
  cout << " þ Compression in progress...";

int	lmax,l,bestl;
LZNode	*bestmatch;

dword	LengMax = 271;		// including 271 (271 is ok, 272 not)

dword	Leng,Dist;
dword	LastDist = 0;

dword	LastDistUse = 0;
dword	LongestString = 0;


_freq SATH(288);		// <0..287>
  SATH.set_stream(&bst0);
  SATH.set_adaptative();
  SATH.reset_encoder();


  for (x=0; x<filesize; x++) {
     code = src[x]+(src[x+1] << 8);
     wtab = wordtab[code];
     lmax = (filesize-x);
     if (lmax > LengMax) lmax = LengMax;

     if ((wtab)&&(lmax > 1)) {
///// compression used ....
	bestl=1;
///// search for the longest string ....
	for (ndct=wtab; ndct; ndct=ndct->prev) {
		for (l=2; ((l<lmax)&&(src[x+l]==src[ndct->p+l])); l++);
		if (l>bestl) {
			bestmatch = ndct;
			bestl = l;
  			}
		}
	Dist = (x-(bestmatch->p));
	Leng = bestl;


	if ((Leng==2)&&(Dist>255)) {
//	if ((Leng==2)&&(Dist>255)&&(Dist != LastDist)) {
		NewCode(x);
		SATH.encode_symbol_ad(src[x]);
		}

/////// (bestl == 2) => (dist <= 255) , (bestl>2) => (dist>1) /////////////

	else {
	  if (Leng > LongestString) LongestString = Leng;


	  if (Leng == 2) {
	    if (Dist == LastDist) {
	      LastDistUse++;
	      SATH.encode_symbol_ad(257);
	      }
	    else {
	      d = Power2(Dist);
	      SATH.encode_symbol_ad(257+1+d);
	      bst1.WriteInt(Dist,d);
	      }
            LastDist = Dist;
	    for (--bestl; bestl; bestl--) NewCode(x++);
	    NewCode(x);
	    }


	  else {
	    if (Leng <= 16) {
	      SATH.encode_symbol_ad(266 + Leng - 3);
	      }
	    else {
	      d = Power2(Leng - 16);
	      SATH.encode_symbol_ad(280 + d);
	      bst1.WriteInt((Leng-16),d);
	      }

	    if (Dist == LastDist) {
	      bst1.WriteInt(0,4);
              LastDistUse++;
	      }
	    else {
              d = Power2(Dist);
	      bst1.WriteInt(1+d,4);
	      bst1.WriteInt(Dist,d);
	      }

            LastDist = Dist;  
	    for (--bestl; bestl; bestl--) NewCode(x++);
	    NewCode(x);
	    }
	  }
	}
     else {
///// literal stored  ....
	NewCode(x);
	SATH.encode_symbol_ad(src[x]);
	}
  }
  SATH.encode_symbol_ad(256);
  SATH.flush_encoder();

  cout << "done." << endl;
  
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
  cout << " þ Decompress, check, merge bit streams...";

int32	Code = 0;
dword	Decoded = 0;

  pdst = new byte [filesize];
  dst = new byte [filesize];
  bst.SetTable(dst);
  bst.SetBitPos(0);

  bst0.SetBitPos(0);
  bst1.SetBitPos(0);
  SATH.reset_decoder();
  SATH.set_adaptative();

dword	StartCode = SATH.code;

  LastDist = 0;

  while (Code != 256 && Decoded <= filesize) {
    Code = SATH.decode_copy_symbol_ad(&bst);
    if (Code == 256) break;

    if (Code < 256) {
      if (Code != src[Decoded]) {
        cout << "Symbol break! - pos: " << Decoded << endl;
        break;
        }
      pdst[Decoded++] = Code;
      continue;
      }

    if (Code <= 265) {
      d = Code - 257;		// <0..8>
      if (d == 0) Dist = LastDist;
      else Dist = bst1.ReadCopyInt(d-1,&bst) + (1 << (d-1));
      Leng = 2;
      }

    if (Code >= 266) {
      if (Code <= 279) Leng = Code - 266 + 3;
      else Leng = bst1.ReadCopyInt(Code - 280,&bst) + (1 << (Code - 280)) + 16;

      d = bst1.ReadCopyInt(4,&bst);
      if (d == 0) Dist = LastDist;
      else Dist = bst1.ReadCopyInt(d-1,&bst) + (1 << (d-1));
      }
  
    LastDist = Dist;

    for (i=0; i<Leng; i++) {
      pdst[Decoded] = pdst[Decoded - Dist];
      if (pdst[Decoded] != src[Decoded]) {
        cout << "Copy break! - pos: " << Decoded << "(leng,dist): " << Leng << "," << Dist << endl;
        break;
        }
      Decoded++;
      }
      
    }

  cout << "done." << endl;

  cout << "   Decoded size: " << Decoded << endl;
  cout << "   Copmressed data size: " << ((bst.GetBitPos() + 7) >> 3) << endl;


  d = (bst.GetBitPos() + 7) >> 3;
  f = fopen("comp.inc","wb");
  fprintf(f,"dw %d\n",StartCode);
  for (x=0; x<d; x++) {
    if ((x & 15) == 0) fprintf(f,"db ");
    fprintf(f,"%d",(int32)dst[x]);
    if (((x & 15) != 15) && (x != (d-1))) fprintf(f,",");
    if ((x & 15) == 15) fprintf(f,"\n");
    }
  fclose(f);
  
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
  _asm{
	xor	eax,eax
	int	16h
	}

  delete [] src;
  delete [] dst;
  delete [] lzdct;
  delete [] wordtab;
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
