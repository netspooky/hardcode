/***************************************************************************
 *   By MeteoriK of Approximate <giles@spacepigs.com>                      *
 ***************************************************************************/

#include <stdlib.h>
#include <stdio.h>

#include "BitBuffer.h"

namespace Mapprox
{

BitBuffer::BitBuffer ( int size )
{
    buffer = ( uint8_t* ) malloc ( size );
    ptr = buffer;
}

BitBuffer::BitBuffer ( const char* filename )
{
    // Meaty!!! This is awful, absolutely no error checking here.. If the file doesn't exist then
    // the app seg faults!!
    // You need to have a think about how you want to handle this stuff, probably with exceptions
    // or even using the return value (which you can't do here since you've put the code in the constructor!)
    // Also, isn't there some QT way of opening a file? This is currently not portable
    // </rant>
    // PS, why are you using malloc/free? and also no checking there :|
    // - df
    FILE* ifp = fopen ( filename, "r" );
    if ( ifp )
    {
        fseek ( ifp, 0, SEEK_END );
        int size = ftell ( ifp );
        fseek ( ifp, 0, SEEK_SET );
        buffer = ( uint8_t* ) malloc ( size );
        fread ( buffer, size, 1, ifp );
        ptr = buffer;
    }
}

BitBuffer::BitBuffer( void* data )
{
    buffer = (uint8_t*) data;
    ptr = (uint8_t*) data;
}

BitBuffer::~BitBuffer()
{
    if ( buffer ) free ( buffer );
}


void BitBuffer::PushByte ( uint8_t byte )
{
    * ( ptr++ ) = byte;
}

uint8_t BitBuffer::FetchByte()
{
    return * ( ptr++ );
}

void BitBuffer::PushWord ( uint16_t word )
{
    uint16_t* wptr = ( uint16_t* ) ptr;
    * ( wptr++ ) = word;
    ptr = ( uint8_t* ) wptr;
}

uint16_t BitBuffer::FetchWord()
{
    uint16_t* wptr = ( uint16_t* ) ptr;
    uint16_t rval = * ( wptr++ );
    ptr = ( uint8_t* ) wptr;
    return rval;
}

void BitBuffer::PushLong ( uint32_t lword )
{
    uint32_t* lptr = ( uint32_t* ) ptr;
    * ( lptr++ ) = lword;
    ptr = ( uint8_t* ) lptr;
}

uint32_t BitBuffer::FetchLong()
{
    uint32_t* lptr = ( uint32_t* ) ptr;
    uint32_t rval = * ( lptr++ );
    ptr = ( uint8_t* ) lptr;
    return rval;
}

void BitBuffer::PushFloat ( float f )
{
    float* fptr = ( float* ) ptr;
    * ( fptr++ ) = f;
    ptr = ( uint8_t* ) fptr;
}

float BitBuffer::FetchFloat()
{
    float* fptr = ( float* ) ptr;
    float rval = * ( fptr++ );
    ptr = ( uint8_t* ) fptr;
    return rval;
}

void BitBuffer::Save ( const char* filename )
{
    FILE* ifp = fopen ( filename, "w'" );
    fwrite ( buffer, ( ptr - buffer ), 1, ifp );
    fclose ( ifp );
}

void BitBuffer::PushTwoNibbles(int a, int b)
{
    uint8_t byte;
    byte = a << 4;
    byte |= b;
    PushByte(byte);
}

void BitBuffer::FetchTwoNibbles(int& a, int& b)
{
    uint8_t byte = FetchByte();
    a = byte >> 4;
    b = byte & 0xF;
}

void BitBuffer::PushData(int count, uint8_t* source)
{
    for (int c=0; c<count; c++)
    {
        PushByte(*(source++));
    }
}

void BitBuffer::FetchData(int count, uint8_t* dest)
{
    for (int c=0; c<count; c++)
    {
        *(dest++) = FetchByte();
    }
}

}

