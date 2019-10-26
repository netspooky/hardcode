#!/usr/bin/env python

'''
This script does nasty stuff with the elf-header of our binary.
It sets bytes the kernel doesn't care about to zero for better compression
or puts strings used by the C code to it :o)
The offset and strings are hardcoded here. Keep in mind to update the
linker-script, when changing something about the strings!'''

import sys


CLEAR_BYTES = [
    {'offset':  4, 'length': 1},  # e_ident[EI_CLASS]
    {'offset':  5, 'length': 1},  # e_ident[EI_DATA]
    {'offset':  6, 'length': 1},  # e_ident[EI_VERSION]
    {'offset':  7, 'length': 1},  # e_ident[EI_OSABI]
    {'offset':  8, 'length': 1},  # e_ident[EI_ABIVERSION]
    {'offset':  9, 'length': 7},  # unused
    {'offset': 20, 'length': 4},  # e_version
    {'offset': 32, 'length': 4},  # e_shoff
    {'offset': 36, 'length': 4},  # e_flags
    {'offset': 40, 'length': 2},  # e_ehsize
    {'offset': 46, 'length': 2},  # e_shentsize
    {'offset': 48, 'length': 2},  # e_shnum
    {'offset': 50, 'length': 2},  # e_shstrndx
]

STRINGS = [
    {'offset': 46, 'string': 'GL.so'}
]

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print 'usage: {} FILENAME'.format(sys.argv[0])
        sys.exit(1)

    with open(sys.argv[1], 'r+b') as f:
        for byte in CLEAR_BYTES:
            f.seek(byte['offset'])
            f.write(byte['length'] * chr(0))

        for string in STRINGS:
            f.seek(string['offset'])
            f.write(string['string'] + chr(0))
