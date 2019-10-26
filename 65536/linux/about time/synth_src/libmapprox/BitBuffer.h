/***************************************************************************
 *   By MeteoriK of Approximate <giles@spacepigs.com>                      *
 ***************************************************************************/

#ifndef MAPPROXBITBUFFER_H
#define MAPPROXBITBUFFER_H

#include <stdint.h>

namespace Mapprox
{

/**
 @author MeteoriK <giles@spacepigs.com>
*/
class BitBuffer
{
    private:
        uint8_t* buffer;
        uint8_t* ptr;
    public:
        BitBuffer ( int size=10000000 );
        BitBuffer ( const char* filename );
        BitBuffer ( void* data );

        ~BitBuffer();
        void PushByte ( uint8_t byte );
        uint8_t FetchByte();
        void PushWord ( uint16_t word );
        uint16_t FetchWord();
        void PushLong ( uint32_t lword );
        uint32_t FetchLong();
        void PushFloat ( float f );
        float FetchFloat();
        void PushTwoNibbles( int a, int b );
        void FetchTwoNibbles( int& a, int& b );
        void PushData(int count, uint8_t* source);
        void FetchData(int count, uint8_t* dest);
        void Reset() { ptr = buffer; }

        void Save ( const char* filename );
};

}

#endif
