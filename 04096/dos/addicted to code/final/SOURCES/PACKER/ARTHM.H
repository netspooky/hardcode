#ifndef _ARITHMETIC_COD
#define _ARITHMETIC_COD
/*
 *        THIS IS ARITHEMTIC ENTROPHY ENCODER/DECODER LIBRARY
 *
 *	author: khamoon / tube27 ^ byteway
 *	date:   3.05.1999
 *	notes:  uses Bit queueing arithmetic method
 *		(based on MACM-96 by Mahesh Naik)
 *	greetz: great thanks goes to Pinker for showing me the bit queue
 *		method
 *
 */

#include "types.h"
#include "bstream.cpp"
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//dword	one = 0x10000;
//dword	half = 0x8000;
dword	one = 0x8000;
dword	half = (0x8000 >> 1);

class _freq {
public:
//  dword	code;
//  word	code;
  dword	range;
  dword qlength;

  dword bits;
  BStream *data;
public:
  word	code;


  dword num;
  dword count;
  dword *tab;

  _freq();
  _freq(dword _num);
  ~_freq(); 
  void set_stream(BStream *_data);	// set stream for otput/input
  void settable(dword _num);		// set new tab (new number of symbols)	
  void set_adaptative();		// prepare adaptative coding
  void update(dword symbol);		// update table after new symbol
  void reset_encoder();			// reset encoder (new lo and hi)
  void reset_decoder();			// reset decoder (hi , lo and code)

  void encode_symbol(dword symbol);		// encode symbol (table set)
  void encode_symbol(dword symbol,_freq *fr);	// encode symbol (table set)
  void encode_symbol_ad(dword symbol);		// encode sym. and update table
  void encode_symbol_ad(dword symbol,_freq *fr);	// encode sym. and update table
  void flush_encoder();

  dword decode_symbol();			// decode symbol from stream
  dword decode_copy_symbol(BStream*);		// decode symbol from stream
  dword decode_symbol(_freq *fr);		// decode symbol from stream
  dword decode_symbol_ad();			// decode symbol (adaptative)
  dword decode_copy_symbol_ad(BStream*);	// decode symbol (adaptative)
  dword decode_symbol_ad(_freq *fr);		// decode symbol (adaptative)
};

_freq::_freq() {
  tab = NULL;
  data = NULL;
  num = count = 0;
  reset_encoder();
}

_freq::_freq(dword _num) {
  data = NULL;
  settable(_num);
  reset_encoder();
}

void _freq::settable(dword _num) {
  if (tab) delete [] tab;
  count = 0;
  num = _num;
  tab = new dword [num+1];
  for (dword i=0; i<=num; i++) tab[i] = 0;
}

void _freq::set_adaptative() {
  for (dword i=0; i<= num; i++) tab[i] = i;
}

_freq::~_freq() {
  if (tab) delete [] tab;
}

void _freq::update(dword symbol) {
  for (dword i=symbol+1; i<=num; i++) tab[i]++;
  count++;
}

void _freq::reset_encoder() {
  code = 0;
  qlength = 0;
  range = one;

  bits = 0;
}

void _freq::reset_decoder() {
dword i;
  code = 0;
  for (i=0; i<15; i++) {
    code <<= 1;
    code += data->ReadBit();
    }
  range = one;
  qlength = 0;
}

void _freq::encode_symbol(dword symbol) {
dword low;

  low = range * (dword)tab[symbol] / (dword)tab[num];
  code += low;
  range = (range * (dword)tab[symbol+1] / (dword)tab[num]) - low;

  if (code & one) {
    code ^= one;
    data->WriteBit(1); bits++;
    while (--qlength) { data->WriteBit(0); bits++; }
    }
  while (range <= half) {
    if (code >= half) {
      if (qlength == 0) { data->WriteBit(1); bits++; }
        else qlength++;
      code -= half;
      }
    else {
      if (qlength) {
        data->WriteBit(0); bits++;
        while(--qlength) { data->WriteBit(1); bits++; }
        }
      qlength = 1;
      }

    range <<= 1;
    code <<= 1;
    }
}

void _freq::encode_symbol(dword symbol,_freq *fr) {
/*
  dword range;
  range = (dword) (hi - lo) + 1;
  hi = lo + (word) ((range * fr->tab[symbol+1]) / fr->tab[num] - 1);
  lo = lo + (word) ((range * fr->tab[symbol]) / fr->tab[num]);

  for ( ; ; ) {
    if ( (hi & 0x8000) == (lo & 0x8000) ) {
      bits++;
      data->WriteBit(hi & 0x8000);
      while (underflow_bits > 0) {
        data->WriteBit(~hi & 0x8000);
        bits++;
        underflow_bits--;
        }
      }
    else if ( (lo & 0x4000) && !(hi & 0x4000) ) {
        underflow_bits++; 
        lo &= 0x3FFF;
        hi |= 0x4000;
        }
    else return;
    lo <<= 1;
    hi = (hi << 1) + 1;
    }
*/
}

void _freq::encode_symbol_ad(dword symbol) {
  encode_symbol(symbol);
  update(symbol);
}

void _freq::encode_symbol_ad(dword symbol,_freq *fr) {
  encode_symbol(symbol,fr);
  fr->update(symbol);
}

void _freq::flush_encoder() {
dword low,mask;

  if (qlength) {
    data->WriteBit(0); bits++;
    qlength--;
    while (qlength--) { data->WriteBit(1); bits++; }
    }
  low = code;
  for (mask = half; mask; mask>>=1) {
    if (low & mask) data->WriteBit(1);
      else data->WriteBit(0);
    bits++;
    }
}

void _freq::set_stream(BStream *_data) {
  data = _data;
}


dword _freq::decode_symbol() {
dword	symbol,low;

  count = ((dword)(code+1) * tab[num] - 1) / range;
  
  for (symbol=0; tab[symbol+1] <= count; symbol++);

  low = range * tab[symbol] / tab[num];
  code -= low;
  range = (range * tab[symbol+1] / tab[num]) - low;

  while (range <= half) {
    range <<= 1;
    code <<= 1;
    code += data->ReadBit();
    }

  return symbol;
}

dword _freq::decode_copy_symbol(BStream *bst) {
dword	symbol,low;

  count = ((dword)(code+1) * tab[num] - 1) / range;
  
  for (symbol=0; tab[symbol+1] <= count; symbol++);

  low = range * tab[symbol] / tab[num];
  code -= low;
  range = (range * tab[symbol+1] / tab[num]) - low;

  while (range <= half) {
    range <<= 1;
    code <<= 1;
    code += data->ReadCopyBit(bst);
    }

  return symbol;
}


dword _freq::decode_symbol(_freq *fr) {
dword	symbol,low;

  count = ((dword)(code+1) * fr->tab[num] - 1) / range;
  
  for (symbol=0; fr->tab[symbol+1] <= count; symbol++);

  low = range * fr->tab[symbol] / fr->tab[num];
  code -= low;
  range = (range * fr->tab[symbol+1] / fr->tab[num]) - low;

  while (range <= half) {
    range <<= 1;
    code <<= 1;
    code += data->ReadBit();
    }
  return symbol;
}

dword _freq::decode_symbol_ad() {
dword symbol;
  symbol = decode_symbol();
  update(symbol);
  return symbol;
}

dword _freq::decode_copy_symbol_ad(BStream *bst) {
dword symbol;
  symbol = decode_copy_symbol(bst);
  update(symbol);
  return symbol;
}

dword _freq::decode_symbol_ad(_freq *fr) {
dword symbol;
  symbol = decode_symbol(fr);
  fr->update(symbol);
  return symbol;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#endif
