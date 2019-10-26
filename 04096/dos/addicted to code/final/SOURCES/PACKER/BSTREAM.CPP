#include "types.h"


class BStream {
  byte	*tab;
  dword	TabSize;

  dword	BitPos;

  static byte SetMask[8];
  static byte ZeroMask[8];
public:
  
  BStream();
  BStream(void*);			// Init and set table 

  void	SetTable(void*);		// Set table ptr
  void*	GetTable();			// Get table ptr

  void	SetBitPos(dword BPos);		// Set this->BitPos
  dword	GetBitPos();			// Get this->BitPos

  int32 ReadBit(dword);			// Reads bit (bit position)
  int32	ReadBit();			// Reads bit and increases BitPos
  int32	ReadInt(dword);			// Read (number) of bits (rcl)
  void	WriteBit(dword,int32);		// Writes bit(int32) at position(dword)
  void	WriteBit(int32);		// Writes bit (int32) and inc(BitPos)
  void	WriteZeroBit();
  void	WriteOneBit();
  void	WriteInt(int32,dword);		// Write (dword) lsign bits of (int32)

  int32	ReadCopyBit(BStream*);		// Read bit and WriteIt() to BStream
  int32	ReadCopyInt(dword,BStream*);	// Read int and WriteIt() to BStream
};


byte BStream::SetMask[8] = {1,2,4,8,16,32,64,128};
byte BStream::ZeroMask[8] = {0xFE,0xFD,0xFB,0xF7,0xEF,0xDF,0xBF,0x7F};

BStream::BStream() {
  tab = NULL;
  BitPos = 0;
}

BStream::BStream(void *tab) {
  this->tab = (byte*)tab;
  BitPos = 0;
}

void	BStream::SetBitPos(dword BPos) {
  BitPos = BPos;
}

dword	BStream::GetBitPos() {
  return BitPos;
}

void	BStream::SetTable(void *tab) {
  this->tab = (byte*)tab;
}

void	*BStream::GetTable() {
  return tab;
}

void	BStream::WriteBit(int32 bit) {
dword	d,shift;
  d = (BitPos >> 3);  
  shift = (BitPos & 7);
  if (bit) {
    tab[d] |= SetMask[shift];
    }
  else {
    tab[d] &= ZeroMask[shift];
    }    
  BitPos++;
}

int32	BStream::ReadBit() {
dword	d,shift;
byte	b;
  d = (BitPos >> 3);  
  shift = (BitPos & 7);
  b = tab[d];
  BitPos++;
  return ((b >> shift) & 1);
}

void	BStream::WriteBit(dword BPos,int32 bit) {
dword	d,shift;
  d = (BPos >> 3);  
  shift = (BPos & 7);
  if (bit) {
    tab[d] |= SetMask[shift];
    }
  else {
    tab[d] &= ZeroMask[shift];
    }    
}

int32	BStream::ReadBit(dword BPos) {
dword	d,shift;
byte	b;
  d = (BPos >> 3);  
  shift = (BPos & 7);
  b = tab[d];
  return ((b >> shift) & 1);
}

void	BStream::WriteOneBit() {
dword	d,shift;
  d = (BitPos >> 3);  
  shift = (BitPos & 7);
  BitPos++;
  tab[d] |= SetMask[shift];
}

void	BStream::WriteZeroBit() {
dword	d,shift;
  d = (BitPos >> 3);  
  shift = (BitPos & 7);
  BitPos++;
  tab[d] &= ZeroMask[shift];
}

void	BStream::WriteInt(int32 val,dword nbits) {
dword i;
  for (i=0; i<nbits; i++) WriteBit((val >> (nbits-1-i)) & 1);
}

int32	BStream::ReadInt(dword nbits) {
int32 val = 0;
  while (nbits--) {
    val <<= 1;
    val += ReadBit();
    }
  return val;
}

int32	BStream::ReadCopyBit(BStream *bst) {
dword	d,shift;
int32	b;
  d = (BitPos >> 3);  
  shift = (BitPos & 7);
  b = tab[d];
  BitPos++;
  b = (b >> shift) & 1;
  bst->WriteBit(b);
  return b;
}

int32	BStream::ReadCopyInt(dword nbits,BStream *bst) {
int32 val = 0;
int32 bit;
  while (nbits--) {
    val <<= 1;
    bit = ReadCopyBit(bst);
    val += bit;
    }
  return val;
}

