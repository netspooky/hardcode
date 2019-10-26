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

#ifndef DATA_STREAM_HPP
#define DATA_STREAM_HPP

// bit- and byte-wise reading from and
// writing to a memory buffer
class eDataStream
{
public:
    eDataStream(eConstPtr data=nullptr, eU32 size=0);
    eDataStream(const eByteArray &data);

    void        attach(eConstPtr data, eU32 size);
    void        advance(eU32 offset);

    void        writeBit(eBool bit, eU32 count=1);
    void        writeBits(eU32 dword, eU32 bitCount);
    void        writeU8(eU8 byte);
    eU32        writeU_dynamic(eU32 word);
    void        writeU16(eU16 word);
    void        writeU32(eU32 dword);
    void        writeVbr(eU32 dword);

    eBool       readBit();
    eBool       readBitOrZero();
    eU32        readBits(eU32 bitCount);
    eU8         readU8();
    eU32        readU_dynamic();
    eU16        readU16();
    eU32        readU32();
    eU32        readVbr();

    eByteArray  getData() const;
    eU32        getReadIndex() const;
    eU32        getWriteIndex() const;

private:
    eByteArray  m_data;
    eBool       m_reading;
    eU32        m_readIndex;
    eU32        m_bitCount;
    eU8         m_curByte;
};

#endif // DATA_STREAM_HPP