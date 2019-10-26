/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 *   This file is part of
 *       ______        _                             __ __
 *      / ____/____   (_)____ _ ____ ___   ____ _   / // /
 *     / __/  / __ \ / // __ `// __ `__ \ / __ `/  / // /_
 *    / /___ / / / // // /_/ // / / / / // /_/ /  /__  __/
 *   /_____//_/ /_//_/ \__, //_/ /_/ /_/ \__,_/     /_/.   
 *                    /____/                              
 *
 *   Copyright © 2003-2012 Brain Control, all rights reserved.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "system.hpp"

eDataStream::eDataStream(eConstPtr mem, eU32 length) :
    m_reading(eFALSE),
    m_readIndex(0),
    m_bitCount(0),
    m_curByte(0)
{
    attach(mem, length);
}

eDataStream::eDataStream(const eByteArray &data) :
    m_reading(eFALSE),
    m_readIndex(0),
    m_bitCount(0),
    m_curByte(0)
{
    if (!data.isEmpty())
        attach(&data[0], data.size());
}

void eDataStream::attach(eConstPtr data, eU32 size)
{
    if (data && size)
    {
        m_data.resize(size);
        eMemCopy(&m_data[0], data, size);
        m_reading = eTRUE;
        m_bitCount = 8;
    }
}

void eDataStream::advance(eU32 offset) 
{
    m_readIndex += offset;
}

void eDataStream::writeBit(eBool bit, eU32 count)
{
    eASSERT(!m_reading);

    for (eU32 i=0; i<count; i++)
    {
        eSetBit(m_curByte, m_bitCount, bit);
        m_bitCount++;

        if (m_bitCount == 8)
        {
            m_data.append(m_curByte);
            m_bitCount = 0;
            m_curByte = 0;
        }
    }
}

void eDataStream::writeU8(eU8 byte)
{
    writeBits(byte, 8);
}

void eDataStream::writeU16(eU16 word)
{
    writeBits(word, 16);
}

eU32 eDataStream::writeU_dynamic(eU32 dword)
{
	for(eU32 i = 0; i < 4; i++) {
		if((dword & 0xFFFFFF80) == 0) {
			writeBits(dword, 8);
			return i;
		} else
			writeBits((dword & 0x0000007F) | 0x00000080, 8);

		dword = dword >> 7;
	}
	return 4;
}


void eDataStream::writeU32(eU32 dword)
{
    writeBits(dword, 32);
}

void eDataStream::writeBits(eU32 dword, eU32 bitCount)
{
    for (eU32 i=0; i<bitCount; i++)
        writeBit(eGetBit(dword, i));
}

// writes elias gamma encoded integer
void eDataStream::writeVbr(eU32 dword)
{
    eASSERT(dword < eU32_MAX);
    dword++; // 0 is not encodable
    const eInt bitCount = eFtoL(eLog2((eF32)dword))+1; // truncation crucial

    for (eInt i=0; i<bitCount-1; i++)
        writeBit(eFALSE);

    for (eInt i=bitCount-1; i>=0; i--)
        writeBit(eGetBit(dword, i));
}

eBool eDataStream::readBit()
{
    eASSERT(m_reading);
    eASSERT(m_readIndex <= m_data.size());

    if (m_bitCount == 8)
    {
        m_curByte = m_data[m_readIndex++];
        m_bitCount = 0;
    }

    return eGetBit(m_curByte, m_bitCount++);
}

eBool eDataStream::readBitOrZero()
{
    if (m_readIndex >= m_data.size() && m_bitCount >= 7)
        return 0;
    else
        return readBit();
}

eU32 eDataStream::readBits(eU32 bitCount)
{
    eU32 result = 0;
    for (eU32 i=0; i<bitCount; i++)
        result |= (readBit()<<i);

    return result;
}

eU8 eDataStream::readU8()
{
    return readBits(8);
}

eU32 eDataStream::readU_dynamic()
{
	eU32 result = 0;
	for(eU32 i = 0; i < 5; i++) {
		eU32 cur = readBits(8);
		result |= (cur & 0x0000007F) << (i * 7);
		if((cur & 0x00000080) == 0) 
			break;
	}
	return result;
}

eU16 eDataStream::readU16()
{
    return readBits(16);
}

eU32 eDataStream::readU32()
{
    return readBits(32);
}

// reads elias gamma encoded integer
eU32 eDataStream::readVbr()
{
    eInt bitCount = 0;
    while (!readBit())
        bitCount++;

    eU32 dword = 0;
    for (eInt i=bitCount-1; i>=0; i--)
        eSetBit(dword, i, readBit());

    eSetBit(dword, bitCount, eTRUE);
    return dword-1; // because of +1 when encoding
}

eByteArray eDataStream::getData() const
{
    eByteArray finalData = m_data;
    finalData.append(m_curByte);
    return finalData;
}

eU32 eDataStream::getReadIndex() const
{
    return m_readIndex;
}

eU32 eDataStream::getWriteIndex() const
{
    return m_data.size();
}