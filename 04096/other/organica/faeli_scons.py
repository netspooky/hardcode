# This is a SCons module is for compilation environment and automatic
# configuration.

# Uses several system libraries.
import copy
import os
import platform
import re
import sys

# SCons is required. you really shouldn't live without it anyway.
import faeli_cflags
import SCons
import SCons.Environment
import SCons.Options.EnumOption

##############################################################################
# Pkgconfig ##################################################################
##############################################################################

## \brief Class PkgConfig is used to collect data for pkg-config file writing.
##
## PkgConfig should be used to find and search any configuration flags
## required for the compilation of a program. When ready, it can export a
## pkgconfig file that can be used to link against a library just created.
class PkgConfig:

	## CFlags variable.
	cflags = None

	## Environment construct.
	env = None

	## Binary installation directory.
	dir_bin = None

	## Header installation directory.
	dir_inc = None

	## Library installation directory.
	dir_lib = None

	## Installation prefix.
	dir_prefix = "/usr/local"

	## System binary installation directory.
	dir_sbin = None

	## Exported C compiler flags.
	pkg_cflags = []

	## Exported linker flags.
	pkg_lflags = []

	## Exported library requirements.
	pkg_libs = []

	## Exported pkg-config package prerequirements.
	pkg_req = []

	## Exported library that will be produced and required for linking against
	## this.
	pkg_self = []

	## Package description.
	pkg_desc = "No description"

	## Package name.
	pkg_name = "Unnamed"

	## Package version.
	pkg_version = "0.0.0"

	## \brief Default constructor.
	##
	## Init the object, taking one system environment.
	##
	## @param environment Environment to use.
	def __init__(self,
			environment = SCons.Environment.Environment(ENV = os.environ)):
		# Assign environment, leave cflags for later.
		self.env = environment
		# Now get the actual options. Autotools default flags are preferred over
		# SCons ones. This will replace the SCons default ones with the Autotools
		# ones if they exist.
		self.env_replace('LINK', 'LD')
		self.env_replace('CCFLAGS', 'CFLAGS')
		self.env_replace('LINKFLAGS', 'LDFLAGS')

	## \brief Copy method.
	##
	## @return copy of this.
	def Copy(self):
		ret = PkgConfig(self.env.Copy())
		ret.cflags = self.cflags.Copy()
		ret.dir_bin = self.dir_bin
		ret.dir_inc = self.dir_inc
		ret.dir_lib = self.dir_lib
		ret.dir_prefix = self.dir_prefix
		ret.dir_sbin = self.dir_sbin
		ret.pkg_cflags = copy.deepcopy(self.pkg_cflags)
		ret.pkg_lflags = copy.deepcopy(self.pkg_lflags)
		ret.pkg_libs = copy.deepcopy(self.pkg_libs)
		ret.pkg_req = copy.deepcopy(self.pkg_req)
		ret.pkg_self = copy.deepcopy(self.pkg_self)
		ret.pkg_desc = self.pkg_desc
		ret.pkg_name = self.pkg_name
		ret.pkg_version = self.pkg_version
		return ret

	## \brief Append a C compiler flag to environment.
	##
	## @param flag Flag to add.
	def add_cflag(self, flag):
		self.add_ccflag(flag)
		self.add_cxxflag(flag)

	## \brief Append a C compiler flag to environment.
	##
	## @param flag Flag to add.
	def add_ccflag(self, flag):
		if not self.env_find('CCFLAGS', flag):
			self.env.Append(CCFLAGS = [flag])
			if self.env['ENV'].has_key('CCFLAGS'):
				self.env['ENV']['CCFLAGS'] += ' ' + flag
			else:
				self.env['ENV']['CCFLAGS'] = flag

	## \brief Append a C++ compiler flag to environment.
	##
	## @param flag Flag to add.
	def add_cxxflag(self, flag):
		if not self.env_find('CXXFLAGS', flag):
			self.env.Append(CXXFLAGS = [flag])
			if self.env['ENV'].has_key('CXXFLAGS'):
				self.env['ENV']['CXXFLAGS'] += ' ' + flag
			else:
				self.env['ENV']['CXXFLAGS'] = flag

	## \brief Append a linker flag to environment.
	##
	## @param flag1 First flag.
	## @param flag2 Second flag, may be omitted.
	def add_ldflag(self, flag1, flag2 = None):
		if not self.env_find('LINKFLAGS', flag1, flag2):
			self.env.Append(LINKFLAGS = [flag1])
			if flag2:
				self.env.Append(LINKFLAGS = [flag2])
			# Appending done, now modify the actual environment value too.
			if self.env['ENV'].has_key('LINKFLAGS'):
				self.env['ENV']['LINKFLAGS'] += ' ' + flag1
				if flag2:
					self.env['ENV']['LINKFLAGS'] += ' ' + flag2
			else:
				self.env['ENV']['LINKFLAGS'] = flag1
				if flag2:
					self.env['ENV']['LINKFLAGS'] += ' ' + flag2

	## \brief Append a library to environment.
	##
	## @param lib Library to add.
	def add_lib(self, lib):
		if not self.env_find('LIBS', lib):
			self.env.Append(LIBS = [lib])
			if self.env['ENV'].has_key('LIBS'):
				self.env['ENV']['LIBS'] += ' ' + lib
			else:
				self.env['ENV']['LIBS'] = lib

	## \brief Append a include path.
	##
	## @param path Path.
	def add_path_include(self, path):
		flag = self.cflags.path_to_include_path(path)
		if flag != '':
			self.add_cflag(flag)

	## \brief Append a library path.
	##
	## @param path Path.
	def add_path_library(self, path):
		flag = self.cflags.path_to_library_path(path)
		if flag != '':
			self.add_ldflag(flag)

	## \brief Add a C compiler flag to the pkgconfig data, also export to
	## environment.
	##
	## @param flag Flag to add.
	def add_pkg_cflag(self, flag):
		if flag != '' and not flag in self.pkg_cflags:
			self.add_cflag(flag)
			self.pkg_cflags += [flag]

	## \brief Add a linker flag to the pkgconfig data, also export to
	## envirionment.
	##
	## @param flag Flag to add.
	def add_pkg_ldflag(self, flag):
		if flag != '' and not flag in self.pkg_ldflags:
			self.add_ldflag(flag)
			self.pkg_lflags += [flag]

	## \brief Add a library to the pkgconfig data, also export to environment.
	##
	## @param lib Library to add.
	def add_pkg_lib(self, lib):
		if lib != '' and not lib in self.pkg_libs:
			self.add_lib(lib)
			self.pkg_libs += [lib]

	## \brief Add 'self' requirement.
	##
	## This kind of library will be required upon linking the package provided
	## by this pkgconfig. For example, if you're making a library, add it's name
	## here.
	##
	## @param lib Library to be 'exported'.
	def add_pkg_self(self, lib):
		if lib != '' and not lib in self.pkg_self:
			self.pkg_self += [lib]

	## \brief Add a requirement to the pkgconfig data.
	##
	## @param op The requirement (a package within pkg-config).
	def add_requirement(self, op):
		if op != '' and not op in self.pkg_req:
			self.pkg_req += [op]

	## \brief Clear package flags.
	##
	## Use this when continuing from another pkgconfig where you want to keep
	## the flags presented, but not include them in the package flags to be
	## exported (instead, add a requirement).
	def clear_pkg_flags(self):
		self.pkg_cflags = []
		self.pkg_lflags = []
		self.pkg_libs = []
		self.pkg_req = []
		self.pkg_self = []

	## \brief Check for debug mode.
	##
	## If debug is enabled, specify given flag.
	## @param op The flag to specify (for define) if debug is on.
	def check_debug(self, op):
		if self.env['type'] == 'debug':
			self.add_cflag('-D' + op)

	## \brief Get default optimizing flags.
	def defaults(self):
		self.cflags = faeli_cflags.CFlags(None, None, self.env['type'])
		# Add all cflags, cxxflags, etc that were acquired from the determiner.
		for ii in self.cflags.get_ccflags():
			self.add_ccflag(ii)
		for ii in self.cflags.get_cxxflags():
			self.add_cxxflag(ii)
		for ii in self.cflags.get_ldflags():
			self.add_ldflag(ii)
		# Get the compilers if they were defined.
		self.env['CC'] = self.cflags.get_cc()
		self.env['CXX'] = self.cflags.get_cxx()
		#self.env['LINK'] = self.cflags.get_cc()
		# Print the results.
		print 'Checking processor type: ' + self.cflags.machine
		print 'Checking for CC: ' + self.cflags.get_cc() + ' ' + faeli_cflags.list_string(self.cflags.ccver, '.') 
		print 'Checking for CXX: ' + self.cflags.get_cxx() + ' ' + faeli_cflags.list_string(self.cflags.cxxver, '.')
		print "Checking for CFLAGS: " + faeli_cflags.list_string(self.env_fetch('CCFLAGS'))
		print "Checking for CXXFLAGS: " + faeli_cflags.list_string(self.env_fetch('CXXFLAGS'))
		print "Checking for LDFLAGS: " + faeli_cflags.list_string(self.env_fetch('LINKFLAGS'))

	## \brief Get environment value from given environment
	##
	## @param op Variable name.
	## @return Variables as array or empty stirng if not found.
	def env_fetch(self, op):
		if self.env['ENV'].has_key(op):
			return self.env['ENV'][op].split()
		return None

	## \brief Find a given flag in environment
	##
	## @param name Variable name.
	## @param flag1 First flag to search.
	## @param flag2 Second flag to search, may be omitted.
	## @return True if (both?) exist in flags, false if not.
	def env_find(self, name, flag1, flag2 = None):
		if self.env['ENV'].has_key(name):
			array = self.env['ENV'][name].split()
			for ii in range(len(array)):
				if flag1 == array[ii]:
					if flag2:
						if flag2 == array[ii + 1]:
							return True
					else:
						return True
		return False

	# Replace environment variable with a given name by another with another
	# given name, but only if replacement exists.
	# @param dst Destination variable name.
	# @param src Source variable name.
	def env_replace(self, dst, src):
		if self.env['ENV'].has_key(src):
			self.env['ENV'][dst] = self.env['ENV'][src]

	# Return the environment.
	# @return Copied environment construct.
	def get_env(self):
		return self.env.Copy()

	# Get executable directory.
	# @return Directory string.
	def get_dir_bin(self):
		if self.dir_bin:
			return self.dir_bin
		return os.path.join(self.dir_prefix, 'bin')

	# Get include directory.
	# @param forpc True if required for .pc -file.
	# @return Directory string.
	def get_dir_inc(self, forpc = False):
		if self.dir_inc:
			return self.dir_inc
		if forpc:
			return '${prefix}/include'
		return os.path.join(self.dir_prefix, 'include')

	# Get library directory.
	# @param forpc True if required for .pc -file.
	# @return Directory string.
	def get_dir_lib(self, forpc = False):
		if self.dir_lib:
			return self.dir_lib
		if forpc:
			return '${exec_prefix}/lib'
		return os.path.join(self.dir_prefix, 'lib')

	# Get pkgconfig install directory.
	# @return Directory string.
	def get_dir_pkgconfig(self):
		return os.path.join(self.get_dir_lib(), 'pkgconfig')

	# Get system binary install directory.
	# @return Directory string.
	def get_dir_sbin(self):
		if self.dir_sbin:
			return self.dir_sbin
		return os.path.join(self.dir_prefix, 'sbin')

	# Get the current environment out. Needed for compilation.
	# @return Environment extracted from the CFlags object.
	def get_env(self):
		return self.env.Copy()

	# Get the current uname.
	# @return OS type.
	def get_uname(self):
		return self.cflags.uname

	# Run options script.
	# @param opt Options object.
	# @return Help text for SCons Help.
	def options(self, opt):
		# Take the options (Autotools-compatible). This allows you to manually
		# specify some flags that are passed instead of getting them from the
		# operating system environment.
		opt.Add('CC', 'C compiler',
				self.env_fetch('CC'))
		opt.Add('CXX', 'C++ compiler',
				self.env_fetch('CXX'))
		opt.Add('LINK', 'Linker',
				self.env_fetch('LD'))
		opt.Add('CCFLAGS', 'C compiler flags',
				self.env_fetch('CCFLAGS'))
		opt.Add('CXXFLAGS', 'C++ compiler flags',
				self.env_fetch('CXXFLAGS'))
		opt.Add('LINKFLAGS', 'Linker flags',
				self.env_fetch('LINKFLAGS'))
		opt.Add(SCons.Options.EnumOption('type',
			'Type and optimization level of build', 'optimized',
			allowed_values=('debug', 'none', 'optimized', 'safe')))
		opt.Add('prefix', 'Installation prefix', '/usr/local')
		# Update back to the environment struct.
		opt.Update(self.env)
		# Return help text.
		return opt.GenerateHelpText(self.env)

	# Wrapper to parseconfig to fix an erraneous input string.
	# @param command Command that generates a string.
	def parseconfig(self, command):
		# Open the command from operating system.
		str = os.popen(command).read()
		str_array = str.split()
		# Read things SCons ParseConfig cannot handle.
		for ii in str_array:
			if ii[:2] == '-D' and ii[2:]:
				self.add_cflag(ii)
		# Replace inconsistensies that could cause breakage.
		str = str.replace('-Wl,--rpath', '-Wl,-rpath')
		str = str.replace('"', '\"')
		# Run actual parseconfig afterwards.
		self.env.ParseConfig('echo "' + str + '"')

	# Set the name, version and description
	# @param n Name.
	# @param v Version.
	# @param d Description.
	def set_info(self, n, v, d):
		self.name = n
		self.version = v
		self.description = d

	# Set bindir (to other than prefix/bin).
	# @param str Directory.
	def set_dir_bin(self, srt):
		self.dir_bin = str

	# Set incdir (to other than prefix/include).
	# @param str Library directory.
	def set_dir_inc(self, srt):
		self.dir_include = str

	# Set libdir (to other than prefix/lib).
	# @param str Library directory.
	def set_dir_lib(self, srt):
		self.dir_lib = str

	# Set the installation prefix
	# @param str Prefix directory.
	def set_dir_prefix(self, str):
		self.dir_prefix = str

	# Set sbindir (to other than prefix/bin).
	# @param str Directory.
	def set_dir_sbin(self, str):
		self.dir_sbin = str

	# Write a pkgconfig .pc file
	# @param filename File to write to.
	def write(self, filename):
		file = open(filename, 'wt')
		# Write prefixes.
		file.write('prefix=' + self.dir_prefix + '\n')
		file.write('exec_prefix=${prefix}\n')
		file.write('libdir=' + self.get_dir_lib(True) + '\n')
		file.write('includedir=' + self.get_dir_inc(True) + '\n')
		# Write info.
		file.write('\nName: ' + self.name + '\nDescription: ' + self.description +
				'\nVersion: ' + self.version + '\nRequires:')
		# Write requirements.
		for ii in self.pkg_req:
			file.write(' ' + ii)
		# No cflags if nothing specified.
		file.write('\nCflags: -I${includedir}')
		for ii in self.pkg_cflags:
			file.write(' ' + ii)
		# No lflags if nothing specified.
		file.write('\nLibs: -L${libdir}')
		for ii in self.pkg_lflags:
			file.write(' ' + ii)
		for ii in self.pkg_libs:
			file.write(' -l' + ii)
		for ii in self.pkg_self:
			file.write(' -l' + ii)
		# Close and end.
		file.close()

	########################################
	# Find framework #######################
	########################################

	# Try to include a framework that works with a shell script, i.e.
	# pkg-config.
	# @param vcommand Version check command.
	# @param acommand Command to add flags.
	# @param name Name of the package (for checking).
	# @param cmp Comarison version (must be greater or equal to).
	# @param define Export this flag if successful.
	# @param obligatory If true, exit on error.
	# @return True if found, False if not.
	def find_compare(self, vcommand, acommand, name, cmp, define = '',
			obligatory = False):
		# Print searching text.
		print 'Checking for ' + name + ' version >= ' + cmp + ':',
		[errin, stdout, errout] = os.popen3(vcommand)
		stdstr = stdout.read().strip()
		errstr = errout.read().strip()
		# Check for not in pkg-config
		if errstr.find("PKG_CONFIG_PATH") != -1:
			err = ' not in pkg-config.'
			if obligatory:
				print 'Error:' + err
				sys.exit(1)
			print 'Warning:' + err
			return False
		# Check for no command execution.
		if stdstr == "":
			err = ' could not check version.'
			if obligatory:
				print 'Error:' + err
				sys.exit(1)
			print 'Warning:' + err
			return False
		# Create error string.
		errstr = (stdout.read() + errout.read()).strip()
		# Check for nonexisting package.
		if errstr.find("PKG_CONFIG_PATH") != -1:
			if obligatory:
				print 'Error: no'
				sys.exit(1)
		# Read the version and prepare it (as the compared version)
		ver = stdstr.split('.')
		cmpver = cmp.split('.')
		# Initialize to false.
		ret = False
		# Loop, if succeeds, ret will be true.
		for i in range(len(cmpver)):
			# If the strings are invalid, just default to 0 silently.
			try:
				vn = int(ver[i])
			except ValueError:
				vn = 0
			try:
				cn = int(cmpver[i])
			except ValueError:
				cn = 0
			# Compare integerified string parts.
			if vn < cn:
				if obligatory:
					print 'Error: no (' + stdstr + ')'
					sys.exit(1)
				print 'no (' + errstr + ')'
				return False
			elif vn > cn:
				break
		print 'yes (' + stdstr + ')'
		# Parse the config.
		self.parseconfig(acommand)
		# Manually add -D flag if defined.
		if define != '':
			self.add_pkg_cflag('-D' + define)
		return True

	# Search for a library and a header, add to this project if found.
	# @param lib Name of the library.
	# @param header Name of the header.
	# @param define Export this flag if successful.
	# @param lang Language (usually C).
	# @param obligatory If true, exit on error.
	# @param force If true, continue even if not found.
	# @return True on success, false on error.
	def find_libwithheader(self, lib, header, define = '', lang = 'C',
			obligatory = False, force = True, symbol = ''):
		conf = self.env.Configure()
		if symbol:
			success = conf.CheckLibWithHeader(lib, header, lang, symbol)
		else:
			success = conf.CheckLibWithHeader(lib, header, lang)
		if not success:
			if force:
				print "Warning: library " + lib + " not found, continuing anyway."
			elif obligatory:
				print "Error: library " + lib + " not found."
				sys.exit(1)
			else:
				print "Warning: library " + lib + " not found."
				return False
		self.env = conf.Finish()
		# If definition was forced, do it.
		if define != '':
			self.add_pkg_cflag('-D' + define)
		# Add library manually on failure (since if not for force, we'd have quit
		# already).
		if not success:
			self.add_pkg_lib(lib)
		return True

	# Search for given header (default: C, not C++), append given define if
	# found, possibly abort if not found.
	# @param header Header name.
	# @param define Export this flag if successful.
	# @param lang Language (usually 'C').
	# @param obligatory If true, exit on error.
	# @return True on success, false on error.
	def find_header(self, header, define = '', lang = 'C', obligatory = False):
		conf = self.env.Configure()
		if lang == 'C':
			success = conf.CheckCHeader(header)
		else:
			success = conf.CheckCXXHeader(header)
		if not success and obligatory:
			print "Error: header " + header + " not found."
			sys.exit(1)
		self.env = conf.Finish()
		# Abort on failure
		if not success:
			return False
		# Add definition on success.
		if define:
			self.add_pkg_cflag('-D' + define)
		return True

	# Search for a given function, append given define if found, possibly abort
	# if not found.
	# @param func Function name.
	# @param header Header where the prototype is declared.
	# @param define Export this flag if successful.
	# @param lang Language (usually 'C').
	# @param obligatory If true, exit on error.
	# @return True on success, false on error.
	def find_function(self, func, header, define = '', lang = 'C',
			obligatory = False):
		conf = self.env.Configure()
		success = conf.CheckFunc(func, header, lang)
		self.env = conf.Finish()
		if not success:
			return False
		# Add definition on success.
		if define:
			self.add_pkg_cflag('-D' + define)
		return True

	########################################
	# Individual find methods ##############
	########################################

	# Find GDlib.
	# @param cmp Minimum version.
	# @param define If set, define this on success.
	# @param obligatory If true, exit on error.
	# @return True on success, false on error.
	def find_gdlib(self, cmp,  define = '', obligatory = True):
		return self.find_compare('gdlib-config --version',
				'gdlib-config --cflags --libs ; echo "-lgd"', 'GDlib', cmp, define,
				obligatory)

	# Find GLEW.
	# @param define If set, define this on success.
	# @param obligatory If true, exit on error.
	# @return True on success, false on error.
	def find_glew(self, define = '', obligatory = True):
		return self.find_libwithheader('GLEW', 'GL/glew.h', define, 'C',
				obligatory)

	# Find GLUT.
	# @param define If set, define this on success.
	# @param obligatory If true, exit on error.
	# @return True on success, false on error.
	def find_glut(self, define = '', obligatory = True):
		if self.get_uname() == 'Darwin':
			if define != '':
				self.add_cflag('-D' + define)
			self.add_path_include('/System/Library/Frameworks/GLUT.framework/Headers')
			self.add_path_library('/System/Library/Frameworks/GLUT.framework/Libraries')
			self.add_ldflag('-framework', 'GLUT')
			print 'Checking for OpenGL: -framework GLUT'
			return True
		else:
			return self.find_libwithheader('glut', 'GL/glut.h', define, 'C',
					obligatory)

	# Find Freetype.
	# @param cmp Minimum version.
	# @param define If set, define this on success.
	# @param obligatory If true, exit on error.
	# @return True on success, false on error.
	def find_freetype(self, cmp,  define = '', obligatory = True):
		return self.find_compare('freetype-config --version',
				'freetype-config --cflags --libs', 'FreeType', cmp, define,
				obligatory)

	# Find libflac.
	# @param define If set, define this on success.
	# @param obligatory If true, exit on error.
	# @return True on success, false on error.
	def find_FLAC(self, define = '', obligatory = True):
		return self.find_libwithheader('FLAC', 'FLAC/all.h', define, 'C',
				obligatory)

	## /brief Find libid3tag.
	##
	## @param define If set, define this on success.
	## @param obligatory If true, exit on error.
	## @return True on success, false on error.
	def find_id3tag(self, cmp, define = '', obligatory = True):
		if self.find_pkgconfig('id3tag', cmp, define, False):
			return True	  
		return self.find_libwithheader('id3tag', 'id3tag.h', define, 'C',
				obligatory)

	# Find ncurses
	# @param define If set, define this on success.
	# @param obligatory If true, exit on error.
	# @return True on success, false on error.
	def find_ncurses(self, define = '', obligatory = True):
		return self.find_libwithheader('ncurses', 'ncurses.h', define, 'C',
				obligatory)

	# Find OpenGL, a little bit trickier this time.
	# @param define If set, define this on success.
	# @param obligatory If true, exit on error.
	# @return True on success, false on error.
	def find_opengl(self, define = '', obligatory = True):
		# Check for OSX, if yes, do a little add beforehand
		if self.get_uname() == 'Darwin':
			if define != '':
				self.add_cflag('-D' + define)
			self.add_path_include('/System/Library/Frameworks/OpenGL.framework/Headers')
			self.add_path_library('/System/Library/Frameworks/OpenGL.framework/Libraries')
			self.add_ldflag('-framework', 'OpenGL')
			print 'Checking for OpenGL: -framework OpenGL'
			return True
		# Proceed.
		success = self.find_libwithheader('GL', 'GL/gl.h', define, 'C',
				obligatory)
		if success:
			success = self.find_libwithheader('GLU', 'GL/glu.h', '', 'C',
					obligatory)
			return success

	# Find a pkgconfig'd package.
	# @param name Name of the package in pkg-config.
	# @param cmp Minimum version.
	# @param define If set, define this on success.
	# @param obligatory If true, exit on error.
	# @return True on success, false on error.
	def find_pkgconfig(self, name, cmp, define = '', obligatory = True):
		if faeli_cflags.find_binary('pkg-config'):
			return self.find_compare(
					'pkg-config --modversion ' + name,
					'pkg-config --cflags --libs ' + name,
					name,
					cmp,
					define,
					obligatory)
			if obligatory:
				sys.exit(1)
		return False

	# Find pthread.
	# @param If set, define this on success.
	# @param obligatory If true, exit on error.
	# @return True on success, false on error.
	def find_pthread(self, define = '', obligatory = True):
		return self.find_libwithheader('pthread', 'pthread.h', define, 'C',
				obligatory)

	# Find SDL.
	# @param cmp Minimum version.
	# @param define If set, define this on success.
	# @param obligatory If true, exit on error.
	# @return True on success, false on error.
	def find_sdl(self, cmp,  define = '', obligatory = True):
		# Check for OSX, if yes, use framework.
		if self.get_uname() == 'Darwin':
			if define != '':
				self.add_cflag('-D' + define)
			self.add_path_include('/Library/Frameworks/SDL.framework/Headers')
			self.add_path_library('/Library/Frameworks/SDL.framework/Libraries')
			self.add_cflag('-D_REENTRANT')
			self.add_ldflag('-framework', 'SDL')
			self.add_ldflag('-framework', 'Cocoa')
			print 'Checking for SDL: -framework SDL'
			return True
		# Otherwise default.
		if faeli_cflags.find_binary('sdl-config'):
			vcommand = 'sdl-config --version'
			ccommand = 'sdl-config --cflags --libs'
		elif faeli_cflags.find_binary('sdl11-config'):
			vcommand = 'sdl11-config --version'
			ccommand = 'sdl11-config --cflags --libs'
		else:
			if obligatory:
				sys.exit(1)
			return False
		return self.find_compare(vcommand, ccommand, 'SDL', cmp, define,
				obligatory)

	# Find SDL_image.
	# @param define If set, define this on success.
	# @param obligatory If true, exit on error.
	# @return True on success, false on error.
	def find_sdl_image(self, define = '', obligatory = True):
		# Check for OSX, if yes, use framework.
		if self.get_uname() == 'Darwin':
			if define != '':
				self.add_cflag('-D' + define)
			self.add_path_include('/Library/Frameworks/SDL_image.framework/Headers')
			self.add_path_library('/Library/Frameworks/SDL_image.framework/Libraries')
			self.add_ldflag('-framework', 'SDL_image')
			print 'Checking for SDL_image: -framework SDL_image'
			return True
		return self.find_libwithheader('SDL_image', 'SDL_image.h', define, 'C',
				obligatory)

	# Find SDL_mixer.
	# @param define If set, define this on success.
	# @param obligatory If true, exit on error.
	# @return True on success, false on error.
	def find_sdl_mixer(self, define = '', obligatory = True):
		# Check for OSX, if yes, use framework.
		if self.get_uname() == 'Darwin':
			if define != '':
				self.add_cflag('-D' + define)
			self.add_path_include('/Library/Frameworks/SDL_mixer.framework/Headers')
			self.add_path_library('/Library/Frameworks/SDL_mixer.framework/Libraries')
			self.add_ldflag('-framework', 'SDL_mixer')
			print 'Checking for SDL_image: -framework SDL_mixer'
			return True
		return self.find_libwithheader('SDL_mixer', 'SDL_mixer.h', define, 'C',
				obligatory)

	# Find wxWidgets.
	# @param cmp Minimum version.
	# @param define If set, define this on success.
	# @param obligatory If true, exit on error.
	# @return True on success, false on error.
	def find_wxwidgets(self, cmp,  define = '', obligatory = True):
		return self.find_compare('wx-config --version',
				'wx-config --cflags --libs', 'wxWidgets', cmp, define,
				obligatory)

##############################################################################
# End ########################################################################
##############################################################################

