#!/usr/bin/env python
#
# Script for findng the compiler and flags for generating the smallest
# possible binary from given source files.

import itertools
import os
import subprocess
import sys
import time

def create_binary(compile_args):
	run_process(compile_args)
	run_process(strip_args)
	run_process(cp_args)
	packed = run_process(lzma_args)
	fd = open(base, 'a+b')
	fd.seek(0, os.SEEK_END)
	fd.write(packed)
	fd.close()

def flatten(lst):
	"""Flattens a list by removing all sublists within it."""
	return [item for sublist in lst for item in sublist]

def run_process(pargs):
	"""Run a process, return output, throw an error on failure."""
	proc = subprocess.Popen(args=pargs, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	(sout, serr) = proc.communicate()
	code = proc.returncode
	if code != 0:
		raise RuntimeError('could not execute: %s' % str(pargs))
	return sout

def time2str(seconds):
	ret = ''
	if seconds > 3600:
		hours = seconds / 3600
		seconds -= hours * 3600
		ret = '%ih ' % (hours)
	minutes = seconds / 60
	seconds -= minutes * 60
	if minutes > 0 or ret != '':
		ret += '%02im ' % minutes
	return ret + '%02is' % seconds

base = 'src/dirty_garden'
source = 'src/main.c'
unpacked = base + '_unpacked'
stripped = base + '_stripped'
header = 'unpackhdr_lzma'
cc_sdl = run_process(['sdl-config', '--cflags']).strip().split()
print cc_sdl
cc_always = ['-std=gnu99', '-o', unpacked, source] + cc_sdl + ['-ffast-math', '-fomit-frame-pointer', '-fweb', '-mpreferred-stack-boundary=2']
ld_always = ['-L/usr/local/lib', '-nostdlib', '-nostartfiles', '-lthr']
strip_args = ['strip', '-K', '.bss', '-K', '.text', '-K', '.data', '-R', '.comment', '-R', '.note', '-R', '.note.ABI-tag', '-R', '.fini', '-R', '.gnu.version', '-R .gnu.hash', '-R', '.eh_frame', '-R', '.eh_frame_hdr', '-o', stripped, unpacked]
cp_args = ['cp', header, base]
lzma_args = ['/usr/local/bin/lzma', 'e', '-a1', '-fb90', '-d13', '-lc0', '-mfbt2', '-so', stripped]

#cc = ['gcc44', 'gcc45']
cc = ['gcc44', 'gcc45', 'gcc46', 'gcc47']
cc_opt = ['-Os', '-O']
#cc_opt = ['-O1', '-Os']
#cc_arch = ['-march=pentium4', '-march=core2']
cc_arch = ['-march=i386', '-march=pentium2', '-march=pentium4', '-march=core2']
#cc_varying = ['-fgcse', '-fgcse-las', '-fgcse-sm', '-mpreferred-stack-boundary=2']
cc_varying = ['-fforce-addr', '-fgcse-las', '-fgcse-after-reload', '-fgcse-sm', '-fmerge-all-constants', '-fmodulo-sched', '-fno-inline', '-fno-keep-static-consts', '-fno-peephole', '-freorder-blocks', '-fsingle-precision-constant', '-ftracer', '-funsafe-loop-optimizations']

if __name__ == '__main__':

	total = len(cc) * len(cc_opt) * len(cc_arch) * (2 ** len(cc_varying))

	smallest = 2**31
	smallest_args = []
	idx = 0

	print('%i permutations.' % total)

	start_time = time.time()

	try:
		for ii in cc:
			for jj in cc_opt:
				for kk in cc_arch:
					for ll in range(0, len(cc_varying) + 1):
						for mm in itertools.combinations(cc_varying, ll):
							try:
								mm = list(mm)
								compile_args = [ii] + cc_always + [jj, kk] + mm + ld_always
								if idx > 0:
									elapsed_time = int(time.time() - start_time)
									remaining_time = int((float(elapsed_time) / float(idx)) * float(total - idx))
									remaining_time = time2str(remaining_time)
									elapsed_time = time2str(elapsed_time)
								else:
									elapsed_time = 'N/A'
									remaining_time = 'N/A'
								idx += 1
								print '\r%i of %i ; %s used, %s left                  ' % (idx, total, elapsed_time, remaining_time)
								create_binary(compile_args)
							except RuntimeError as ee:
								print ee
								sys.exit(1)
								next
							size = os.path.getsize(base)
							print '-> %i' % (size)
							if size < smallest or (size == smallest and len(compile_args) < len(smallest_args)):
								smallest = size
								smallest_args = compile_args
	except KeyboardInterrupt as ee:
		print 'interrupted: %s' % (ee)
	except Exception as ee:
		print 'error: %s' % (ee)
	
	print '%i: %s' % (smallest, ' '.join(smallest_args))
	create_binary(smallest_args)

	sys.exit(0)
