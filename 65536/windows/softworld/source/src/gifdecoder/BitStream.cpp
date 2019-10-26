#include "BitStream.h"
#include <memory.h>

CBitStream::CBitStream(){
	int i;
	unsigned char tmp = 0x01;
	for( i = 0; i < 8; i++ ){
		m_bit_table[i] = tmp;
		tmp = tmp << 1;
	}
}

CBitStream::~CBitStream(){
}

int CBitStream::ReadOpen(unsigned char* buf, long len){
	m_buffer    = buf;
	m_pos_byte  = 0;
	m_pos_bit   = 7;
	m_byte_size = len;
	return TRUE;
}

void CBitStream::Close(void){
}

unsigned char CBitStream::ReadByte(void){
	unsigned char dest;
	ReadBytes(&dest, 1);
	return dest;
}

long CBitStream::ReadWord(void){
	long dest;
	if( m_pos_bit != 7 ){
		m_pos_bit = 7;
		m_pos_byte++;
	}
	dest = (long)ReadByte() << 8;
	dest |= (long)ReadByte();
	return dest;
}

long CBitStream::ReadBytes(unsigned char* buf, long len){
	if( m_pos_bit != 7 ){
		m_pos_bit = 7;
		m_pos_byte++;
	}
	if( m_pos_byte + len >= m_byte_size )
		len = m_byte_size - m_pos_byte;
	memcpy(buf, &(m_buffer[m_pos_byte]), len);
	m_pos_byte += len;
	return len;
}

unsigned char CBitStream::PeekByte(void){
	unsigned char ch;
	if( m_pos_byte + (m_pos_bit == 7 ? 0 : 1) + 1 >= m_byte_size )
		return 0;
	memcpy(&ch, &(m_buffer[m_pos_byte + (m_pos_bit == 7 ? 0 : 1)]), 1);
	return ch;
}

long CBitStream::SkipBytes(long len){
	if( m_pos_bit != 7 ){
		m_pos_bit = 7;
		m_pos_byte++;
	}
	if( m_pos_byte + len >= m_byte_size )
		len = m_byte_size - m_pos_byte;
	m_pos_byte += len;
	return len;
}

int CBitStream::ReadBits(long len){
	int dest;
	if( m_pos_byte * 8 + (7 - m_pos_bit + len) >= m_byte_size * 8 )
		len = m_byte_size * 8 - m_pos_byte * 8 - (7 - m_pos_bit);
	dest = 0;
	for( ; --len >= 0; ){
		dest = (dest << 1) | ((m_buffer[m_pos_byte] & m_bit_table[m_pos_bit]) ? 1 : 0);
		m_pos_bit--;
		if( m_pos_bit < 0 ){
			m_pos_bit = 7;
			m_pos_byte++;
		}
	}
	return dest;
}

int CBitStream::ReadReverseBits(long len){
	int dest;
	if( m_pos_byte * 8 + (7 - m_pos_bit + len) >= m_byte_size * 8 )
		len = m_byte_size * 8 - m_pos_byte * 8 - (7 - m_pos_bit);
	dest = 0;
	
	for( int i = len; --i >= 0; ){
		dest |= ((int)(m_buffer[m_pos_byte] & m_bit_table[7 - m_pos_bit]) ? 1 : 0) << (len - i - 1);
		m_pos_bit--;
		if( m_pos_bit < 0 ){
			m_pos_bit = 7;
			m_pos_byte++;
		}
	}
	return dest;
}




