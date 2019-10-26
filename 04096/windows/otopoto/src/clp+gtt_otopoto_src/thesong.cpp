/*
	This file is part of "otopoto / Collapse & Gatitos".

    "otopoto / Collapse & Gatitos" is free software: you can redistribute
	it and/or modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation, either version 3 of the
	License, or (at your option) any later version.

    "otopoto / Collapse & Gatitos" is distributed in the hope that it will
	be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
	of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with "otopoto / Collapse & Gatitos".  If not, see 
	<http://www.gnu.org/licenses/>.
*/

#include "thesong.h"
#include "synth.h"

Song thesong={
    {  // begin patterns
        {0x01, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}, //  0 - wind 1
        {0x01, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00}, //  1 - wind 2
        {0x00, 0x02, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00}, //  2 - wind 3
        {0x02, 0x01, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00}, //  3 - bongo+wind
        {0x05, 0x0a, 0x01, 0x02, 0x03, 0x00, 0x00, 0x00}, //  4 - bongo+bass1
        {0x05, 0x09, 0x01, 0x02, 0x03, 0x00, 0x00, 0x00}, //  5 - bongo+bass2
        {0x05, 0x09, 0x02, 0x01, 0x03, 0x00, 0x00, 0x00}, //  6 - bongo+bass1
        {0x05, 0x00, 0x00, 0x02, 0x03, 0x00, 0x00, 0x00}, //  7 - bongo+bass2
        {0x05, 0x04, 0x04, 0x04, 0x06, 0x07, 0x0a, 0x03}, //  8 - bongo+piano+bass1+melody1
        {0x05, 0x04, 0x04, 0x04, 0x00, 0x00, 0x09, 0x03}, //  9 - bongo+piano+bass1+melody2
        {0x05, 0x04, 0x04, 0x04, 0x06, 0x09, 0x00, 0x03}, // 10 - bongo+piano+bass1+melody3
        {0x05, 0x04, 0x04, 0x04, 0x08, 0x00, 0x00, 0x03}, // 11 - bongo+piano+bass1+melody4
        {0x05, 0x04, 0x04, 0x04, 0x03, 0x00, 0x00, 0x00}, // 12 - bongo+bass1+piano
        {0x05, 0x04, 0x04, 0x04, 0x03, 0x00, 0x00, 0x00}, // 13 - bongo+bass1+piano
        {0x05, 0x04, 0x04, 0x04, 0x0b, 0x03, 0x00, 0x00}, // 14 - bongo+piano+bass1+melody5
        {0x05, 0x04, 0x04, 0x04, 0x0c, 0x03, 0x00, 0x00}, // 15 - bongo+piano+bass1+melody6
        {0x05, 0x04, 0x04, 0x04, 0x0d, 0x03, 0x00, 0x00}, // 16 - bongo+piano+bass1+melody7
    }, // end patterns
    {  // begin txpose
        {-15,0}, // 0 - wind1
        {-9,0,-3}, // 1 - wind2
        {0,-20,0,-5}, // 2 - wind3
        {-15,0,0},     // 3 - bongo
        {9,21,-15,-9,0}, // 4 - bongo+bass1
        {9,23,-15,-3,0}, // 5 - bongo+bass1
        {6,21,-15,-9,0}, // 6 - bongo+bass1
        {6,-3,-9,0,0}, // 7 - bongo+bass1
        {9,7,11,14,21,21,21,0}, // 8 - bongo+piano+bass1+melody1
        {9,7,11,14,23,23,23,0}, // 9 - bongo+piano+bass1+melody2
        {6,7,11,16,21,21,21,0}, // 10 - bongo+piano+bass1+melody3
        {6,7,11,16,21,21,21,0}, // 11 - bongo+piano+bass1+melody4
        {9,7,11,14,0}, // 12 - bongo+bass1+piano
        {6,7,11,16,0}, // 13 - bongo+bass1+piano
        {9,7,11,14,25,0}, // 14 - bongo+piano+bass1+melody5
        {9,7,11,14,25,0}, // 15 - bongo+piano+bass1+melody6
        {6,7,11,16,25,0}, // 16 - bongo+piano+bass1+melody6
    }, // end txpose
    {  // begin tracks
	{{0,0,0,0,0,0,0,0,0,0,0,0}, 0},
        {{0x44,0,0,0,0,0,0,0,0,0,0,0}, 19}, // 1 - wind
        {{0,0,0,0x51,0,0,0,0,0,0,0,0}, 19}, // 2 - wind
        {{0,0,0,0xb4,0x74,0xa4,0,0,0,0xa4,0,0xa4,}, 0}, // 3 - bongo rhythm
        {{0,0,0,0xf1,0,0xb1,0,0,0,0xf1,0,0}, 53}, // 4 - piano rhythm
	{{0x57,0,0x17,0x37,0,0,0x52,0,0,0x37,0,0,}, 87}, // 5 - bassline 1
	{{0x6b,0,0,0x6b,0,0,0x6b,0,0,0x6c,0,0}, 112}, // 6
	{{0,0,0,0,0,0,0,0,0,0,0,0x6e}, 112}, // 7
	{{0x6b,0,0x69,0,0,0x67,0,0,0,0,0,0}, 112}, // 8
	{{0,0,0,0,0,0,0,0,0,0,0,0x6e}, 140}, // 9
	{{0x6e,0,0,0,0,0x6c,0x6b,0,0x6c,0,0,0x6e}, 140}, // a
	{{0x6f,0,0,0x6e,0,0,0x6c,0,0,0x6a,0,0}, 112}, // b - melody 5
	{{0x67,0,0,0x65,0,0x63,0,0,0,0,0,0}, 112}, // c - melody 6
	{{0x6c,0,0,0x60,0,0x60,0,0,0x62,0x63,0,0}, 112}, // d - melody 7
    }, // end tracks
    {  // begin instrument data
	// 0 (bongo)
	SIGMOID,10,1, //3
    TRIANGLE,24,50, //6
    LPF,2,40, //9
    MUL,3,0,  //12
	CONST,8,0, //15
	MUL,2,0, //18
    END,
	// 19 (wind)
	SIGMOID,2,15, //22
	SIGMOID,-10,6, //25
	MUL,2,0, //28
	TRIANGLE,-110,20, //31
	CONST,0,5, //34
	MUL,2,0, //37
	CONST,0,10, //40
	SUM,2,0, //43
	NOISE,0,0, //46
	LPF,2,10, //49
	MUL,8,0, //52
	END,
	// 53 (piano-ish)
	CONST,0,30, // 56
	SIGMOID,10,1, // 59
	TRIANGLE,0,15, // 62
	SQUARE,12,10, // 65
	SQUARE,-12,20, // 68
	SUM,2,0, //71
	SUM,4,0, //74
	MUL,6,0, //77
	LPF,8,20, //80
	CONST,0,70, //83
	MUL,2,0, //86
	END,
	// 87 (bass)
	SIGMOID, 8,3, //90
	TRIANGLE,-20,1, //93
	TRIANGLE,-8,50, //96
	SUM,2,0, //99
	LPF,4,0, //102
	CONST,0,80, //105
	MUL,2,0, //108
	MUL,7,0, //111
	END,
	// 112 (lead)
	CONST,0,30, // 115
	SIGMOID, 8,4, //118
	SQUARE,-20,50, //121
	SQUARE,-8,10, //124
	SUM,2,0, //127
	LPF,5,20, //130
	CONST,0,20, //133
	MUL,2,0, //136
	MUL,7,0, //139
	END,
	// 140 (pad)
	CONST,0,80, //143
	SIGMOID, 1,14, //146
	TRIANGLE,-8,50, //149
	CONST,0,10, //152
	MUL,2,0, //155
	MUL,4,0, //158
	END, //159

    }, // end instrument data
    {  // begin playlist
	0,1,2,1,
	3,3,3,3,
	4,5,6,7,
	4,5,6,7,

	8,9,10,11,
	8,9,10,11,
	
	12,12,13,13,
	12,12,13,13,
	
	14,15,16,13,
	14,15,16,13,
    }, // end playlist
};


