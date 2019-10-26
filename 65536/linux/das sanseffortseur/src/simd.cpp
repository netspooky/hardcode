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

// DZ   bit 6 = 1       denormals are zero
// FZ   bit 15 = 1      flush to zero
// R+   bit 14 = 1      round positive
// R-   bit 13 = 1      round negative
// RZ   bits 13&14 = 1  round to zero
// RN   bits 13&14 = 0  round to nearest
void eSimdSetArithmeticFlags(eInt flags)
{
    // default control register value
    // FTZ=off | RTN | EXC. on | DAZ=off | flags (volatile)
    // 0       | 00  | 111111  | 0       | 000000
    static const eU16 DEFAULT_FLAGS = 0x1f80;

    eU16 mxcsr = DEFAULT_FLAGS;
    eSetBit(mxcsr, 15, flags&eSAF_FTZ);
    eSetBit(mxcsr,  6, flags&eSAF_DAZ);
    eSetBit(mxcsr, 13, (flags&eSAF_RN) || (flags&eSAF_RTZ));
    eSetBit(mxcsr, 14, (flags&eSAF_RP) || (flags&eSAF_RTZ));
    _mm_setcsr(mxcsr);
}