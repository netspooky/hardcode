#!/usr/bin/python

import fileinput, sys, re

def minimize(l):
    l = l.strip()
    if re.match("^\s*\/\*", l):
        return ""
    squeeze = ",+-/*%()[]=;:<>?"
    for char in squeeze:
        l = re.sub("\s*\%s\s*" % (char), char, l)
    return l

total = 0
print "ICONST char g_shader_fragment_audio[] = \"\""
for l in fileinput.input():
    if l[0] == '%':
        break
    l = minimize(l)
    if len(l) > 0:
        # macros need newline after
        if l[0] == "#":
            print "\"%s\\n\"" % (l)
            total += len(l) + 1
        else:
            print "\"%s\"" % (l)
            total += len(l)
print ";"

print >>sys.stderr, "Total len: %d" % (total)

