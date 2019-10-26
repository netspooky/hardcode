#ifndef _GIFDECODER_H_WRITTEN_BY_YAZTROMO_INCLUDED
#define _GIFDECODER_H_WRITTEN_BY_YAZTROMO_INCLUDED

#include "BitStream.h"

class CGifDecoder{
public:
	CGifDecoder();
	~CGifDecoder();
	int Decode(unsigned char* dest = NULL);
	long Open(unsigned char* buffer, long len);
	void Close(void);
	long GetWidth(void){return m_xsize;};
	long GetHeight(void){return m_ysize;};
	unsigned char* GetImageBuffer(void){return m_bitmap;};
protected:
	void dump(const char* format, ...);
	int ReadHeader(void);
	int ReadLogicalScreenDefinition(void);
	int ReadGlobalColormap(void);
	int ReadLocalImageDefinition(void);
	int ReadLocalColormap(void);
	int ReadExtensionBlock(void);
	int ReadImageData(void);

	void ReinitTable(void);
	void InitTable(void);
	int ReadImageSubBlock(void);
	void AddTable(int sindex, int cindex);
	void OutputTable(int index);
	void OutputFirst(int index);
	void UpdateRuster(void);
	long m_xsize;
	long m_ysize;
	int m_gcmap_depth;
	int m_gcmap_size;
	int m_lcmap_size;
	int m_output_index;
	unsigned char* m_bitmap;
	int m_allocated_local;
	unsigned char m_gcmap[256*3];
	unsigned char m_lcmap[256*3];
	CBitStream m_dat;
	char m_interlace;

	int ruster;
	int path;
	int code, nextentry;
	int codesize, codelength;
	int eoi, cc;
	int lastcode;
	int unreadbits;
	int unreadvalue;
	unsigned char* table_value[4096+1];
	int table_length[4096+1];
};

__inline void CGifDecoder::UpdateRuster(void){
	if( !(m_output_index % m_xsize) ){
		if( path == 1 )
			ruster += 8;
		else if( path == 2 )
			ruster += 8;
		else if( path == 3 )
			ruster += 4;
		else
			ruster += 2;
		if( ruster >= m_ysize ){
			path++;
			if( path == 2 )
				ruster = 4;
			else if( path == 3 )
				ruster = 2;
			else
				ruster = 1;
		}
		m_output_index = m_xsize * ruster;
	}
}

#endif  _GIFDECODER_H_WRITTEN_BY_YAZTROMO_INCLUDED
