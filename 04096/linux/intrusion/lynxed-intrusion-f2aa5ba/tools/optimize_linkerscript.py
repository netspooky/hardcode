#!/usr/bin/env python

'''
Quite stupid script to find the best section-ordering for optimal
compression.
To do this, it takes a linkerscript with special comments and tries
to build all possible combinations, while searching for the smallest one.
Caution: It expects a section-definition to be one line!

This script isn't ran automatically by Makefile, since it takes way too much
time (5 hours on my machine on a tmpfs. Some parallelization would be nice,
but, well, I'm too lazy).'''

import sys
import os
import subprocess
from math import factorial
from itertools import permutations


def parse_linkerscript(filename):
    part = 'head'
    content = {
        'head': [],
        'sections': [],
        'tail': []
    }

    with open(filename) as f:
        for line in f.readlines():
            if line.strip() == '/* SECTIONS_BEGIN */':
                content[part].append(line)
                part = 'sections'
            elif line.strip() == '/* SECTIONS_END */':
                part = 'tail'
                content[part].append(line)
            else:
                content[part].append(line)

    return ''.join(content['head']), \
        content['sections'], ''.join(content['tail'])


def get_scripts(head, lines, tail):
    for permutation in permutations(lines, len(lines)):
        yield ''.join([head, ''.join(permutation), tail])


def write_linkerscript(filename, script):
    with open(filename, 'w') as f:
        f.write(script)


def try_build(build_command, target):
    with open(os.devnull, "w") as null:
        status = subprocess.call(
            build_command, shell=True, stdout=null, stderr=null)

    if status != 0:
        print 'build failed with exit status {}'.format(status)
        sys.exit(2)
    return os.path.getsize(target)


if __name__ == '__main__':
    if len(sys.argv) != 4:
        print 'usage: {} FILENAME BUILD_COMMAND TARGET'.format(sys.argv[0])
        sys.exit(1)

    filename, build_command, target = sys.argv[1:]

    head, lines, tail = parse_linkerscript(filename)

    permutation = 0
    permutation_count = factorial(len(lines))
    best_size = -1
    best_script = ''
    for script in get_scripts(head, lines, tail):
        if permutation % 100 == 0:
            print 'trying permutation #{}/{} ({:.1f}%)...'.format(
                permutation, permutation_count,
                permutation / float(permutation_count) * 100.0)

        write_linkerscript(filename, script)
        size = try_build(build_command, target)

        if best_size == -1 or size < best_size:
            print 'permutation #{} gave new best size of {}'.format(
                permutation, size)
            best_size = size
            best_script = script

        permutation += 1

    print 'all permutations tried, best size was {}, rebuilding!'.format(
        best_size)

    write_linkerscript(filename, best_script)
    try_build(build_command, target)

    print 'done :o)'
