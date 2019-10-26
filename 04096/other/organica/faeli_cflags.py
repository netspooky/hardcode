# This module just determines the optimal CFlags for a given environment.

import copy
import os
import platform
import re
import sys

##############################################################################
# Locals #####################################################################
##############################################################################

cc_list = ['gcc', 'gcc34', 'gcc-3.4', 'gcc40', 'gcc-4.0', 'gcc41', 'gcc-4.1',
		'gcc42', 'gcc-4.2']
cxx_list = ['g++', 'g++34', 'g++-3.4', 'g++40', 'g++-4.0', 'g++41', 'g++-4.1',
		'g++42', 'g++-4.2']

##############################################################################
# Functions ##################################################################
##############################################################################

## \brief Get the version from executing a given string.
##
## @param execstr Exec string.
def get_version(execstr):
	[errin, errout] = os.popen4(execstr)
	if errout != None:
		for ii in errout.read().split():
			match = re.match("(\d+)\.(\d)+\.(\d+)", ii.strip())
			if match:
				return [int(match.group(1)), int(match.group(2)), int(match.group(3))]
	return None

## \brief Transform list into a string.
##
## @param lst List to transform
## @param sep Separator.
## @return List as string.
def list_string(lst, sep = ' '):
	ret = ''
	for ii in lst:
		if ret != '':
			ret += sep
		ret += str(ii)
	return ret

## \brief Find a binary from PATH.
##
## @param binary Binary name.
## @return True if exists, false if not.
def find_binary(binary):
	# Get the path list.
	path = os.environ['PATH'].split(':')
	for ii in path:
		try:
			st = os.stat(ii + '/' + binary)
			mode = st.st_mode
			return (mode & 1 != 0) or (mode & 8 != 0) or (mode & 64 != 0)
		except OSError:
			continue
	return False

## \brief Find newest version of some software.
##
## @param tries Different variations to try.
## @param veradd Version addition string.
## @return The variation that resulted in greatest version number.
def find_binary_newest(tries, veradd):
	best = [0, 0, 0]
	bestbin = None
	for ii in tries:
		if find_binary(ii):
			ver = get_version(ii + ' ' + veradd)
			for jj in range(0, 2):
				if best[jj] > ver[jj]:
					break
				if best[jj] < ver[jj]:
					best = ver
					bestbin = ii
	return bestbin

##############################################################################
# CFlagsOpt ##################################################################
##############################################################################

## \brief Class that tries to find optimal CFlags.
class CFlags:

	## Machine type.
	machine = ''

	## C compiler.
	compiler_cc = None

	## C++ compiler.
	compiler_cxx = None

	## C flags.
	ccflags = []

	## C++ flags.
	cxxflags = []

	## Linker flags.
	ldflags = []

	## C compiler version.
	ccver = []

	## C++ compiler version.
	cxxver = []

	## OS name.
	uname = (os.uname())[0]

	## \brief Initializing function also determines the parameters.
	##
	## @param cc C compiler.
	## @param cxx C++ compiler.
	## @param type Flags type (optimized, safe, debug, none).
	def __init__(self, cc = None, cxx = None, type = 'safe'):

		# Determine cc lists.
		if type == 'optimized':
			cc_list = ['gcc', 'gcc34', 'gcc-3.4', 'gcc40', 'gcc-4.0', 'gcc41',
					'gcc-4.1', 'gcc42', 'gcc-4.2']
			cxx_list = ['g++', 'g++34', 'g++-3.4', 'g++40', 'g++-4.0', 'g++41',
					'g++-4.1', 'g++42', 'g++-4.2']
		else:
			cc_list = ['gcc']
			cxx_list = ['g++']

		# Determine machine type.
		self.machine = platform.processor()
		if self.machine == '':
			self.machine = platform.machine()

		# Find a C compiler, prefers gcc.
		if cc:
			self.compiler_cc = cc
		else:
			self.compiler_cc = find_binary_newest(cc_list, '-v')
		if not self.compiler_cc:
			print "Error: no C compiler found (specify with CC)."
			sys.exit(1)
		self.ccver = get_version(self.compiler_cc + ' -v')

		# Find a C++ compiler, prefers g++.
		if cxx:
			self.compiler_cxx = cxx
		else:
			self.compiler_cxx = find_binary_newest(cxx_list, '-v')
		if not self.compiler_cxx:
			print "Error: no C++ compiler found (specify with CXX)."
			sys.exit(1)
		self.cxxver = get_version(self.compiler_cxx + ' -v')

		# No optimization -> do nothing.
		if type == 'none':
			return
		# Append all obligatory paths to the environment. This may add some
		# compilation and script overhead, but it's a lot better than having to
		# search all around for any files.
		tmpflags = self.path_includes('/opt/include /opt/local/include /sw/include /usr/local/include /usr/X11R6/include'.split())
		self.ccflags += tmpflags
		self.cxxflags += tmpflags
		self.ldflags += self.path_libraries('/opt/lib /opt/local/lib /sw/lib /usr/local/lib /usr/X11R6/lib'.split())

		# At least some kind of optimization has been selected. Add default
		# warning flags, that should keep the code well within reasonable
		# parameters. Note that safe optimization flags don't include these since
		# some software packages use -Werror.
		if type != 'safe':
			self.add_cflags('-Wall -Wconversion -Wdisabled-optimization -Wextra -Winit-self -Winline -Wshadow -Wswitch-default')
			# If gcc version is 4, we may add some additional warnings.
			if self.ccver[0] >= 4:
				self.add_cflags('-Wmissing-include-dirs -Wstrict-aliasing=2')
			# Some flags only apply to C++.
			self.add_cxxflags('-Wold-style-cast -Woverloaded-virtual')

		# Always safe to use these flkags, regardless of optimization.
		self.add_cflags('-pipe')

		# Always safe to optimize linker output.
		self.add_ldflags('-O1')
		# Check for debug. If it's on, we do nothing.
		if type == 'debug':
			self.add_cflags('-g -O0')
			return
		# If not debugging, we may strip binaries (if not on Darwin).
		if self.uname != 'Darwin':
			self.add_ldflags('-s')
		# These optimization flags can be set regardless of optimization level.
		self.add_cflags('-fomit-frame-pointer')
		# Safe optimization assumes pretty much nothing.
		if type == 'safe':
			self.add_cflags('-O2')
			return
		# Default build is as optimized as possible.
		self.add_cflags('-O3 -ffast-math -fsingle-precision-constant')
		# GCC 4 brings additional compiler flags for use.
		if self.ccver[0] >= 4:
			self.add_cflags('-ftracer -fweb')

	## \brief Copy method.
	##
	## @return Copy of this.
	def Copy(self):
		return copy.deepcopy(self)

	## \brief Add following C/C++ flags.
	##
	## @param str Flags to add.
	def add_cflags(self, str):
		tmpflags = str.split()
		self.ccflags += tmpflags
		self.cxxflags += tmpflags

	## \brief Add following C++ flags.
	##
	## @param str Flags to add.
	def add_cxxflags(self, str):
		self.cxxflags += str.split()

	## \brief Add following linker flags.
	##
	## @param str Flags to add.
	def add_ldflags(self, str):
		self.ldflags += str.split()

	## \brief Get C compiler.
	##
	## @return C compiler name as a string.
	def get_cc(self):
		return self.compiler_cc

	## \brief Get ccflags.
	##
	## @return List of flags.
	def get_ccflags(self):
		return self.ccflags

	## \brief Get C++ compiler.
	##
	## @return C++ compiler name as a string.
	def get_cxx(self):
		return self.compiler_cxx

	## \brief Get cxxflags.
	##
	## @return List of flags.
	def get_cxxflags(self):
		return self.cxxflags

	## \brief Get ldflags.
	##
	## @return List of flags.
	def get_ldflags(self):
		return self.ldflags

	## \brief Transform a path into an include path if it exits.
	##
	## @param path Path to check.
	## @return Path or empty string.
	def path_to_include_path(self, path):
		if os.path.exists(path):
			return '-I' + path
		return ''

	## \brief Transform a path into an library path if it exits.
	##
	## @param path Path to check.
	## @return Path or empty string.
	def path_to_library_path(self, path):
		if os.path.exists(path):
			return '-L' + path
		return ''

	## \brief Process a list of include paths, return a list of flags for all
	## existing.
	##
	## @param lst List of paths.
	## @return List of flags.
	def path_includes(self, lst):
		ret = []
		for ii in lst:
			flag = self.path_to_include_path(ii)
			if flag != '':
				ret += [flag]
		return ret

	## \brief Process a list of library paths, return a list of flags for all
	## existing.
	##
	## @param lst List of paths.
	## @return List of flags.
	def path_libraries(self, lst):
		ret = []
		for ii in lst:
			flag = self.path_to_library_path(ii)
			if flag != '':
				ret += [flag]
		return ret

	## \brief Print C compiler.
	def print_cc(self):
		print self.compiler_cc

	## \brief Print ccflags.
	def print_ccflags(self):
		print list_string(self.ccflags)

	## \brief Print C++ compiler.
	def print_cxx(self):
		print self.compiler_cxx

	## \brief Print cxxflags.
	def print_cxxflags(self):
		print list_string(self.cxxflags)

	## \brief Print ccflags.
	def print_ldflags(self):
		print list_string(self.ldflags)

##############################################################################
# End ########################################################################
##############################################################################
