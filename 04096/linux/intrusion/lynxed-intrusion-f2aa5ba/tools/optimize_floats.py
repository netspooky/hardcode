#!/usr/bin/env python

'''
This script scans the source-code for float-constants, and replaces them with
similar, but better compressible ones.
Since it modifies the source-files themself, this is not ran automatically by
the build-process.'''

import sys
import re
import struct
from itertools import izip


MAX_DIFFERENCE = 0.1


def rreplace(s, old, new, count=-1):
    return new.join(s.rsplit(old, count))


def float_to_bin(f):
    return bin(struct.unpack('=I', struct.pack('=f', f))[0])


def bin_to_float(b):
    return struct.unpack('=f', struct.pack('=I', int(b, 2)))[0]


def optimize(f):
    f1 = f
    f2 = f

    while abs(f - f1) <= MAX_DIFFERENCE:
        f2 = f1
        f1 = bin_to_float(rreplace(float_to_bin(f2), '1', '0', 1))

        if f1 == f2:
            break

    return f2


def process_file(filename):
    with open(filename, 'r') as f:
        content = f.read()

    content = re.sub(r'(-?[0-9]*\.[0-9]*)f',
                     lambda m: '{}f'.format(optimize(float(m.group(1)))),
                     content)

    with open(filename, 'w') as f:
        f.write(content)


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print 'usage: {} SOURCE_FILE [SOURCE_FILE ...]'.format(sys.argv[0])
        sys.exit(1)

    source_files = sys.argv[1:]

    for filename in source_files:
        process_file(filename)
