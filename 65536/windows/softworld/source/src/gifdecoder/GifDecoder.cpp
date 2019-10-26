#include "GifDecoder.h"
#include "BitStream.h"
#include <memory.h>


//The  Graphics  Interchange  Format(c)  is  the Copyright property of
//CompuServe  Incorporated.  GIF(sm)  is  a  Service  Mark property of
//CompuServe Incorporated.                                            

CGifDecoder::CGifDecoder(){
}

CGifDecoder::~CGifDecoder(){
}

long CGifDecoder::Open(unsigned char* buffer, long len){
	//	open data stream
	m_dat.ReadOpen(buffer, len);
	
	//	initializing
	int i;
	m_bitmap = NULL;
	m_allocated_local = FALSE;
	for( i = 4096 + 1; --i >= 0; ){
		table_value[i]    = NULL;
		table_length[i]   = 0;
	}
	
	//	reading basic data
	ReadHeader();
	ReadLogicalScreenDefinition();
	if( m_dat.PeekByte() == 0x21 )
		ReadExtensionBlock();
	if( m_dat.PeekByte() == 0x3b )
		return 0;
	ReadLocalImageDefinition();
	return m_xsize * m_ysize * 3;
}

void CGifDecoder::Close(void){
	// close stream
	m_dat.Close();

	// cleanup data
	int i = 0;
	while( table_value[i] )
		delete[] table_value[i++];
	if( m_bitmap && m_allocated_local ){
		delete[] m_bitmap;
		m_bitmap = NULL;
	}
}

int CGifDecoder::Decode(unsigned char* dest /* = NULL */){
	if( m_bitmap && m_allocated_local )
		delete[] m_bitmap;
	m_bitmap = dest;
	ReadImageData();
	return TRUE;
}

int CGifDecoder::ReadHeader(void){
	unsigned char str[3];
	m_dat.ReadBytes(str, 3);
	if( memcmp(str, "GIF", 3) != 0 )
		return FALSE;
	m_dat.ReadBytes(str, 3);	
	return TRUE;
}

int CGifDecoder::ReadLogicalScreenDefinition(void){
	m_dat.ReadWord();
	m_dat.ReadWord();
	if( m_dat.ReadBits(1) ){	
		m_gcmap_depth = m_dat.ReadBits(3) + 1;
		m_dat.ReadBits(1);	
		m_gcmap_size = (1 << (m_dat.ReadBits(3) + 1));
	}
	else{
		m_dat.ReadBits(7);
		m_gcmap_depth = 0;
		m_gcmap_size   = 0;
	}
	m_dat.ReadByte();	
	m_dat.ReadByte();
	if( m_gcmap_size )
		ReadGlobalColormap();
	return TRUE;
}

int CGifDecoder::ReadGlobalColormap(void){
	typedef struct SRGBColor{
		unsigned char b;
		unsigned char g;
		unsigned char r;
	} SRGBColor;

	int i;
	SRGBColor* cmap = (SRGBColor *)m_gcmap;
	for( i = 0; i < m_gcmap_size; i++ ){
		cmap[i].r = m_dat.ReadByte();
		cmap[i].g = m_dat.ReadByte();
		cmap[i].b = m_dat.ReadByte();
	}
	return TRUE;
}

int CGifDecoder::ReadLocalImageDefinition(void){
	unsigned char ch;
	do{
		ch = m_dat.ReadByte();
	}while( ch != 0x2c );
	m_dat.ReadWord();
	m_dat.ReadWord();	
	m_xsize =  m_dat.ReadByte();
	m_xsize |= m_dat.ReadByte() << 8;
	m_ysize =  m_dat.ReadByte();
	m_ysize |= m_dat.ReadByte() << 8;
	if( m_dat.ReadBits(1) ){
		m_interlace = m_dat.ReadBits(1);	
		m_dat.ReadBits(1);							
		m_dat.ReadBits(2);
		m_lcmap_size = 1 << (m_dat.ReadBits(3) + 1);
	}
	else{
		m_interlace = m_dat.ReadBits(1);	
		m_dat.ReadBits(6);
		m_lcmap_size = 0;
	}
	if( m_lcmap_size )
		ReadLocalColormap();
	return TRUE;
}

int CGifDecoder::ReadLocalColormap(void){
	typedef struct SRGBColor{
		unsigned char b;
		unsigned char g;
		unsigned char r;
	} SRGBColor;

	int i;
	SRGBColor* cmap = (SRGBColor *)m_lcmap;
	for( i = 0; i < m_lcmap_size; i++ ){
		cmap[i].r = m_dat.ReadByte();
		cmap[i].g = m_dat.ReadByte();
		cmap[i].b = m_dat.ReadByte();
	}
	return TRUE;
}

int CGifDecoder::ReadExtensionBlock(void){
	unsigned char functype;
	int i;
	m_dat.ReadByte();	//	0x21
	functype = m_dat.ReadByte();
	while( TRUE ){
		i = m_dat.ReadByte();
		if( i == 0 )
			break;
		for( ; --i >= 0; )
			m_dat.ReadByte();
	}
	return TRUE;
}

void CGifDecoder::InitTable(void){
	int i = 0;
	while( table_value[i] ){
		delete[] table_value[i];
		table_value[i] = NULL;
		i++;
	}

	for( i = (1 << codesize); --i >= 0; ){
		table_value[i] = new unsigned char[1];
		table_value[i][0] = (unsigned char)i;
		table_length[i] = 1;
	}
	table_value[(1 << codesize)] = new unsigned char[1];	
	table_value[(1 << codesize)+1] = new unsigned char[1];	

	nextentry = (1 << codesize) + 2;
	codelength = codesize + 1;
	lastcode = -1;
}

void CGifDecoder::ReinitTable(void){
	int i;
	nextentry = (1 << codesize) + 2;
	codelength = codesize + 1;
	i = nextentry;
	while( table_value[i] ){
		delete[] table_value[i];
		table_value[i] = NULL;
		i++;
	}
}

int CGifDecoder::ReadImageData(void){
	if( !m_bitmap ){
		m_bitmap = new unsigned char[m_xsize * m_ysize * 3];
		m_allocated_local = TRUE;
	}
	m_output_index = 0;
	codesize = m_dat.ReadByte();
	
	InitTable();
	cc = (1 << codesize);
	eoi = (1 << codesize) + 1;

	unreadbits  = 0;
	unreadvalue = 0;
	
	if( m_interlace ){
		path   = 1;
		ruster = 0;
	}

	while( ReadImageSubBlock() )
		;
	
	return TRUE;
}

int CGifDecoder::ReadImageSubBlock(void){
	int i;
	i = m_dat.ReadByte();	
	if( i == 0 )
		return FALSE;
	i = m_dat.GetBytePos() + i;
	while( m_dat.GetBytePos() + (int)((codelength-m_dat.GetRestBit()+7)/8) < i){
		if( unreadbits ){
			code =  unreadvalue;
			code |= m_dat.ReadReverseBits(codelength - unreadbits) << unreadbits;
			unreadbits = 0;
		}
		else
			code = m_dat.ReadReverseBits(codelength);
		if( code == eoi )
			return FALSE;
		else if( code == cc ){	//	Clear code
			ReinitTable();
			lastcode = m_dat.ReadReverseBits(codelength);
			if( lastcode == eoi ) 
				return FALSE;
			OutputTable(lastcode);
		}
		else if( code < nextentry ){
			OutputTable(code);
			if( lastcode >= 0 ){
				if( code < 4096 )
					AddTable(lastcode, code);
			}
			lastcode = code;
		}
		else{
			OutputTable(lastcode);
			OutputFirst(lastcode);
			if( code < 4096 )
				AddTable(lastcode, lastcode);
			lastcode = code;
		}
	}
	unreadbits = (i - m_dat.GetBytePos() - ((m_dat.GetRestBit()%8)?1:0))*8 + m_dat.GetRestBit() % 8;
	unreadvalue = m_dat.ReadReverseBits(unreadbits);
	
	return TRUE;
}

void CGifDecoder::AddTable(int sindex, int cindex){
	table_length[nextentry] = table_length[sindex] + 1;
	table_value[nextentry]  = new unsigned char[table_length[nextentry]];
	memcpy(table_value[nextentry], table_value[sindex], table_length[sindex]);
	table_value[nextentry][table_length[sindex]] = table_value[cindex][0];
	nextentry++;
	if( nextentry == (1 << codelength) && nextentry != 4096)
		codelength++;
}

void CGifDecoder::OutputTable(int index){
	typedef struct SRGBColor{
		unsigned char b;
		unsigned char g;
		unsigned char r;
	} SRGBColor;
	
	int i;
	SRGBColor* cmap;
	if( m_lcmap_size )
		cmap = (SRGBColor *)m_lcmap;
	else
		cmap = (SRGBColor *)m_gcmap;
	
	if( m_interlace ){
		for( i = 0; i < table_length[index]; i++ ){
			((SRGBColor *)m_bitmap)[m_output_index++] = cmap[table_value[index][i]];
			UpdateRuster();
		}
	}
	else{
		for( i = 0; i < table_length[index]; i++ )
			((SRGBColor *)m_bitmap)[m_output_index++] = cmap[table_value[index][i]];
	}
}

void CGifDecoder::OutputFirst(int index){
	typedef struct SRGBColor{
		unsigned char b;
		unsigned char g;
		unsigned char r;
	} SRGBColor;

	SRGBColor* cmap;
	if( m_lcmap_size )
		cmap = (SRGBColor *)m_lcmap;
	else
		cmap = (SRGBColor *)m_gcmap;

	((SRGBColor *)m_bitmap)[m_output_index++] = cmap[table_value[index][0]];
	if( m_interlace )
		UpdateRuster();
}


