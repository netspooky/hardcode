#ifndef BITSTREAM_H_WRITTEN_BY_YAZTROMO_INCLUDED
#define BITSTREAM_H_WRITTEN_BY_YAZTROMO_INCLUDED

#ifndef TRUE
	#define TRUE	1
#endif  TRUE
#ifndef FALSE
	#define FALSE 0
#endif  FALSE
#ifndef NULL
	#define NULL  0
#endif  NULL

class CBitStream{
protected:
	long m_pos_byte;
	long m_pos_bit;
	long m_byte_size;
	unsigned char m_bit_table[8];
	unsigned char* m_buffer;
public:
	CBitStream();
	~CBitStream();
	int ReadOpen(unsigned char* buf, long len);
	void Close(void);
	unsigned char ReadByte(void);
	unsigned char PeekByte(void);
	long ReadWord(void);
	long ReadBytes(unsigned char* buf, long len);
	int  ReadBits(long len);
	int  ReadReverseBits(long len);
	long GetRestByte(void){return m_byte_size-m_pos_byte-((m_pos_bit==7)?0:1);};
	long GetBytePos(void){return m_pos_byte;};
	long GetRestBit(void){return m_pos_bit + 1;};
	long SkipBytes(long len);
};

#endif  BITSTREAM_H_WRITTEN_BY_YAZTROMO_INCLUDED
