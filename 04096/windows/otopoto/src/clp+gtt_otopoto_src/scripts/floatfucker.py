#!/usr/bin/python
# floatfucker.py by slack/Necrostudios
# it now rounds instead of truncating (thanks iq :)

import re
import sys
from struct import pack, unpack

def trunc_float(f):
	return unpack("f",pack("I", (unpack("I",pack("f",f))[0]+0x8000)&0xFFFF0000))[0]

def repl_float(m):
	s = m.group()
	sign = m.group(2)
	try:
		f = float(s[:-1])
	except:	
		print "ERROR ----> ", s
		return s
	f2 = trunc_float(f)
	if sign == '+':
		return '+'+str(f2)+'f'
	else:
		return str(f2)+'f'

float_re = re.compile("(([+-]|)\d*\.\d+|\d+\.\d*)f", re.I)

src = file(sys.argv[1]).read()
dst = float_re.sub(repl_float, src)
file(sys.argv[2],"w").write(dst)


