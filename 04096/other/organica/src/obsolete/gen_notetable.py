#!/usr/bin/env python
# -*- coding: utf-8 -*-

import math

notes = ['c', 'cs', 'd', 'ds', 'e', 'f', 'fs', 'g', 'gs', 'a', 'as', 'h']

c = 0
for i in range(0, 8):
    for n in range(0, 12):
	val = i * 12 + n
	print "#define %s%d %s" % (notes[n], i, val)
	c += 1
print "#define pp 0"
print "#define acc | 0x80"

print "#define C1 | 0x00"
print "#define C2 | 0x40"
print "#define C3 | 0x80"
print "#define C4 | 0xc0"

base = 4000

print "unsigned short freqtable[13] = {"
for i in range(0, 12):
    val = base * math.exp(math.log(2) * i / 12)
    print "%d," % (int(val))
print "0,};"
