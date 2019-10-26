dnl If $2 is 'yes', define and make an am_conditional of $1
dnl AC_CONDITIONAL_DEFINE([DEFINE_STRING], [TEST_STRING])
AC_DEFUN([AC_CONDITIONAL_DEFINE],
[
  if test "x$2" = "xyes" ; then
    AC_DEFINE_UNQUOTED([$1], [1], [Conditionally defined])
  fi
  AM_CONDITIONAL([$1], [test "x$2" = "xyes"])
  AC_SUBST([$1], [$2])
])

dnl Add a C flag to current CFLAGS if it is not already there.
dnl AC_ADD_CCFLAG([FLAG])
AC_DEFUN([AC_ADD_CCFLAG],
[
	CFLAGS_addsave=[$CFLAGS]
	if test "x$CFLAGS_addsave" != "x" ; then
		flag=`echo "$1" | sed 's/-/\\\-/g'`
		if test -z "`echo \"${CFLAGS}\" | grep \"${flag}\"`" ; then
			CFLAGS="$CFLAGS_addsave $1"
		fi
	else
		CFLAGS="$1"
	fi
])

dnl Add a C++ flag to current CXXFLAGS if it is not already there.
dnl AC_ADD_CCFLAG([FLAG])
AC_DEFUN([AC_ADD_CXXFLAG],
[
	CXXFLAGS_addsave=[$CXXFLAGS]
	if test "x$CXXFLAGS_addsave" != "x" ; then
		flag=`echo "$1" | sed 's/-/\\\-/g'`
		if test -z "`echo \"${CXXFLAGS}\" | grep \"${flag}\"`" ; then
			CXXFLAGS="$CXXFLAGS_addsave $1"
		fi
	else
		CXXFLAGS="$1"
	fi
])

dnl Add a linker flag to current LDFLAGS if it is not already there.
dnl AC_ADD_CCFLAG([FLAG])
AC_DEFUN([AC_ADD_LDFLAG],
[
	LDFLAGS_addsave=[$LDFLAGS]
	if test "x$LDFLAGS_addsave" != "x" ; then
		flag=`echo "$1" | sed 's/-/\\\-/g'`
		if test -z "`echo \"${LDFLAGS}\" | grep \"${flag}\"`" ; then
			LDFLAGS="$LDFLAGS_addsave $1"
		fi
	else
		LDFLAGS="$1"
	fi
])

dnl Add a lib to current LIBS if it is not already there.
dnl AC_ADD_LIB([FLAG])
AC_DEFUN([AC_ADD_LIB],
[
	LIBS_addsave=[$LIBS]
	if test "x$LIBS_addsave" != "x" ; then
		flag=`echo "$1" | sed 's/-/\\\-/g'`
		if test -z "`echo \"${LIBS}\" | grep \"${flag}\"`" ; then
			LIBS="$LIBS_addsave $1"
		fi
	else
		LIBS="$1"
	fi
])

dnl Check for CC compiler and preserve existing flags (or their absence).
dnl Use as you would use AC_PROG_CC.
dnl AC_CHECK_COMPILERS([compilers])
AC_DEFUN([AC_CHECK_CC],
[
	CFLAGS_save="$CFLAGS"
	AC_PROG_CC([$1])
	CFLAGS="$CFLAGS_save"
])

dnl Check for CXX compiler and preserve existing flags (or their absence).
dnl Use as you would use AC_PROG_CXX.
dnl AC_CHECK_COMPILERS([compilers])
AC_DEFUN([AC_CHECK_CXX],
[
	CXXFLAGS_save="$CXXFLAGS"
	AC_PROG_CXX([$1])
	CXXFLAGS="$CXXFLAGS_save"
])

dnl Check if given C compiler flag is approperiate and include if yes.
dnl AC_CHECK_CCFLAG([FLAG])
AC_DEFUN([AC_CHECK_CCFLAG],
[
	if test "x$CC" != x ; then
		AC_LANG_PUSH([C])
		AC_MSG_CHECKING([if $CC accepts $1])
		CFLAGS_save=[$CFLAGS]
		AC_ADD_CCFLAG([$1])
		AC_TRY_COMPILE([],
			[],
			flag=[yes],
			flag=[no])
		if test x$flag = xno ; then
			CFLAGS="$CFLAGS_save"
		fi
		AC_MSG_RESULT([$flag])
		AC_LANG_POP([C])
	fi
])

dnl Check if given C++ compiler flag is approperiate and include if yes.
dnl AC_CHECK_CXXFLAG([flag])
AC_DEFUN([AC_CHECK_CXXFLAG],
[
	if test "x$CXX" != x ; then
		AC_LANG_PUSH([C++])
		AC_MSG_CHECKING([if $CXX accepts $1])
		CXXFLAGS_save=[$CXXFLAGS]
		AC_ADD_CXXFLAG([$1])
		AC_TRY_COMPILE([],
			[],
			flag=[yes],
			flag=[no])
		if test x$flag = xno ; then
			CXXFLAGS="$CXXFLAGS_save"
		fi
		AC_MSG_RESULT([$flag])
		AC_LANG_POP([C++])
	fi
])

dnl Check if given C++ compiler flag produces runnable code.
dnl AC_CHECK_CCRUN([FLAG])
AC_DEFUN([AC_CHECK_CCRUN],
[
	AC_LANG_PUSH([C])
	AC_MSG_CHECKING([if $CC runs $1])
	CFLAGS_save=[$CFLAGS]
	AC_ADD_CCFLAG([$1])
	AC_RUN_IFELSE(AC_LANG_PROGRAM([], []),
		flag=[yes],
		flag=[no],
		flag=[no])
	if test x$flag = xno ; then
		CFLAGS="$CFLAGS_save"
	fi
	AC_MSG_RESULT([$flag])
	AC_LANG_POP([C])
])

dnl Check if given C++ compiler flag produces runnable code.
dnl AC_CHECK_CXXRUN([FLAG])
AC_DEFUN([AC_CHECK_CXXRUN],
[
	AC_LANG_PUSH([C++])
	AC_MSG_CHECKING([if $CXX runs $1])
	CXXFLAGS_save=[$CXXFLAGS]
	AC_ADD_CXXFLAG([$1])
	AC_RUN_IFELSE(AC_LANG_PROGRAM([], []),
		flag=[yes],
		flag=[no],
		flag=[no])
	if test x$flag = xno ; then
		CXXFLAGS="$CXXFLAGS_save"
	fi
	AC_MSG_RESULT([$flag])
	AC_LANG_POP([C++])
])


dnl Check a flag for both C and C++
dnl AC_CHECK_CFLAG([flag])
AC_DEFUN([AC_CHECK_CFLAG],
[
	AC_CHECK_CCFLAG([$1])
	AC_CHECK_CXXFLAG([$1])
])

dnl Check a run flag for both C and C++
dnl AC_CHECK_CRUN([flag])
AC_DEFUN([AC_CHECK_CRUN],
[
	AC_CHECK_CCRUN([$1])
	AC_CHECK_CXXRUN([$1])
])

dnl Check if given linker flag is approperiate and include if yes.
dnl AC_CHECK_LDFLAG([FLAG])
AC_DEFUN([AC_CHECK_LDFLAG],
[
	AC_MSG_CHECKING([if linker accepts $1])
	LDFLAGS_save=[$LDFLAGS]
	AC_ADD_LDFLAG([$1])
	AC_TRY_LINK([],
		[],
		flag=[yes],
		flag=[no])
	if test x$flag = xno ; then
		LDFLAGS=[$LDFLAGS_save]
	fi
	AC_MSG_RESULT([$flag])
])

dnl Check for a given directory. If found, append it to the directories
dnl specified for the compiler headers.
dnl AC_CHECK_HEADER_DIRECTORY([DIRECTORY])
AC_DEFUN([AC_CHECK_HEADER_DIRECTORY],
[
	AC_MSG_CHECKING([for include directory $1])
	if test -d "$1" ; then
		AC_ADD_CCFLAG([-I$1])
		AC_ADD_CXXFLAG([-I$1])
		AC_MSG_RESULT([yes])
	else
		AC_MSG_RESULT([no])
	fi
])

dnl Check for a given directory. If found, append it to the directories
dnl specified for the linker library search paths.
dnl AC_CHECK_LIBRARY_DIRECTORY([DIRECTORY])
AC_DEFUN([AC_CHECK_LIBRARY_DIRECTORY],
[
	AC_MSG_CHECKING([for library directory $1])
	if test -d "$1" ; then
		AC_ADD_LDFLAG([-L$1])
		AC_MSG_RESULT([yes])
	else
		AC_MSG_RESULT([no])
	fi
])

dnl Enables or disables selected compiler flags.
dnl AC_DEBUG_MODE([DEBUG_DEFINE])
AC_DEFUN([AC_COMPILE_MODE],
[
  AC_MSG_CHECKING([for compilation mode])
  AC_ARG_ENABLE(
    debug,
    AC_HELP_STRING(
      [--enable-debug],
      [Compile with additional debugging information and functions]),
    debug=[yes],
    debug=[no])
  AC_ARG_ENABLE(
    optimizations,
    AC_HELP_STRING(
      [--disable-optimizations],
      [Do not try to compile with aggressive optimizations]),
    optimizations=[no],
    optimizations=[yes])

	if test x$debug = xyes ; then
		optimizations=[no]
	fi

	AC_CONDITIONAL_DEFINE([$1], [$debug])

	if test x$debug != xno ; then
  	AC_MSG_RESULT([debug])
		AC_CHECK_CFLAG([-O0])
		AC_CHECK_CFLAG([-g])
		AC_CHECK_CFLAG([-funit-at-a-time])
	elif test x$optimizations != xno ; then
  	AC_MSG_RESULT([optimized])
		AC_CHECK_CFLAG([-O3])
		AC_CHECK_CFLAG([-ffast-math])
		AC_CHECK_CFLAG([-fgcse-sm])
		AC_CHECK_CFLAG([-fgcse-las])
		AC_CHECK_CFLAG([-fgcse-after-reload])
		AC_CHECK_CFLAG([-fsee])
		AC_CHECK_CFLAG([-fsingle-precision-constant])
	else
  	AC_MSG_RESULT([normal])
		AC_CHECK_CFLAG([-O2])
	fi
	AC_CHECK_CFLAG([-pipe])
	if test x$debug = xno ; then
		AC_CHECK_CFLAG([-fomit-frame-pointer])
		AC_CHECK_LDFLAG([-s])
	fi
	if test x$debug$optimizations != xnono ; then
		AC_CHECK_CFLAG([-Wall])
		AC_CHECK_CFLAG([-Wconversion])
		AC_CHECK_CFLAG([-Wdisabled-optimization])
		AC_CHECK_CFLAG([-Wextra])
		AC_CHECK_CFLAG([-Winit-self])
		AC_CHECK_CFLAG([-Winline])
		AC_CHECK_CCFLAG([-Wmissing-declarations])
		AC_CHECK_CFLAG([-Wmissing-include-dirs])
		AC_CHECK_CCFLAG([-Wmissing-prototypes])
		AC_CHECK_CXXFLAG([-Wold-style-cast])
		AC_CHECK_CCFLAG([-Wold-style-definition])
		AC_CHECK_CXXFLAG([-Woverloaded-virtual])
		AC_CHECK_CFLAG([-Wshadow])
		AC_CHECK_CFLAG([-Wstrict-aliaising=2])
		AC_CHECK_CCFLAG([-Wstrict-prototypes])
		AC_CHECK_CFLAG([-Wswitch-default])
	fi
	if test x$debug$optimizations = xnoyes ; then
		AC_CHECK_CFLAG([-ftracer])
		AC_CHECK_CFLAG([-fweb])
	fi

	AC_CHECK_HEADER_DIRECTORY([/opt/include])
	AC_CHECK_LIBRARY_DIRECTORY([/opt/lib])
	AC_CHECK_HEADER_DIRECTORY([/opt/local/include])
	AC_CHECK_LIBRARY_DIRECTORY([/opt/local/lib])
	AC_CHECK_HEADER_DIRECTORY([/sw/include])
	AC_CHECK_LIBRARY_DIRECTORY([/sw/lib])
	AC_CHECK_HEADER_DIRECTORY([/usr/local/include])
	AC_CHECK_LIBRARY_DIRECTORY([/usr/local/lib])
	AC_CHECK_HEADER_DIRECTORY([/usr/X11R6/include])
	AC_CHECK_LIBRARY_DIRECTORY([/usr/X11R6/lib])
])

dnl Enables or disables tests.
dnl AC_ENABLE_TESTS([TEST_DEFINE], [action if yes], [action if no])
AC_DEFUN([AC_ENABLE_TESTS],
[
	AC_MSG_CHECKING([whether tests are enabled])
	AC_ARG_ENABLE([tests],
		AC_HELP_STRING([--enable-tests],
			[Build non-installable test programs (default: no)]),
		tests=[yes],
		tests=[no])
	AC_CONDITIONAL_DEFINE([$1], [$tests])
	AC_MSG_RESULT([$tests])
	if test x$tests = xyes ; then
		ifelse([$2], , :, [$2])
	else
		ifelse([$3], , :, [$3])
	fi
])

dnl Create a specific configuration file accepting only certain types of
dnl flags.
dnl AC_SPECIFIC_HEADER([TEMPORARY_CONFIG_FILE_NAME], [FINAL_CONFIG_FILE_NAME], [CONFIGURATION_TERM_PREFIX])
AC_DEFUN([AC_SPECIFIC_HEADER],
[
	AC_CONFIG_COMMANDS([specific header],	[cat $1 | grep $3 > $2])
	AC_CONFIG_HEADERS([$1])
])

dnl Check for 32/64 -bit memory space.
dnl AC_CHECK_POINTER_SIZE([DEFINE_IF_32], [DEFINE_IF_64])
AC_DEFUN([AC_CHECK_POINTER_SIZE],
[
	AC_MSG_CHECKING([If pointer size is 32 bits])
	AC_RUN_IFELSE(
		[int main(void)
		{
			if(sizeof(void*) = 4)
			{
				return 0;
			}
			return 1;
		}],
		[acptrsize32bit=yes],
		[acptrsize32bit=no],
		[acptrsize32bit=no])
	if test x$acptrsize32bit = xyes ; then
		AC_MSG_RESULT([yes])
	else
		AC_MSG_RESULT([no])
	fi
	AC_CONDITIONAL_DEFINE([$2], [$acptrsize32bit])
	AC_MSG_CHECKING([If pointer size is 64 bits])
	AC_RUN_IFELSE(
		[int main(void)
		{
			if(sizeof(void*) = 8)
			{
				return 0;
			}
			return 1;
		}],
		[acptrsize64bit=yes],
		[acptrsize64bit=no],
		[acptrsize64bit=no])
	if test x$acptrsize64bit = xyes ; then
		AC_MSG_RESULT([yes])
	else
		AC_MSG_RESULT([no])
	fi
	AC_CONDITIONAL_DEFINE([$2], [$acptrsize64bit])
])

dnl Incorporation.
dnl AC_INCORPORATE([name], [yesno], [cflags], [libs], [define], [obligatory])
AC_DEFUN([AC_INCORPORATE],
[
	AC_MSG_CHECKING([if $1 is ok])
	if test x$2 = xyes ; then
		AC_ADD_CCFLAG([$3])
		AC_ADD_CXXFLAG([$3])
		AC_ADD_LIB([$4])
		AC_MSG_RESULT([yes])
	elif test x$6 = xyes ; then
		AC_MSG_ERROR([no])
	else
		AC_MSG_RESULT([no])
	fi

	if test -n $5 ; then
		AC_CONDITIONAL_DEFINE([$5], [$2])
	fi
])

dnl Incorporation through pkg-config.
dnl AC_INCORPORATE_PKGCONFIG([name], [version], [define on found], [obligatory])
AC_DEFUN([AC_INCORPORATE_PKGCONFIG],
[
	PKG_CHECK_MODULES([$1],
		[$1],
		pkgc=[yes],
		pkgc=[no])
	AC_INCORPORATE([$1], [$pkgc], $[$1[]_CFLAGS], $[$1[]_LIBS], $3, $4)
])

dnl Incorporate Freetype2.
dnl AC_INCORPORATE_FREETYPE2([version], [define on found], [obligatory])
AC_DEFUN([AC_INCORPORATE_FREETYPE2],
[
	AC_CHECK_FT2([$1],
		freetype2=[yes],
		freetype2=[no])
	AC_INCORPORATE([Freetype2], [$freetype2], [$FT2_CFLAGS], [$FT2_LIBS], [$2], [$3])
])

dnl Incorporate libpng.
dnl AC_INCORPORATE_LIBPNG([version], [define on found], [obligatory])
AC_DEFUN([AC_INCORPORATE_LIBPNG],
[
	AC_INCORPORATE_PKGCONFIG([libpng],
		[$1],
		[$2],
		[no])
	if test x$pkgc = xno ; then
		AC_INCORPORATE_PKGCONFIG([libpng12],
			[$1],
			[$2],
			[$3])
	fi
])

dnl Incorporate SDL.
dnl AC_INCORPORATE_SDL([version], [define on found], [obligatory])a
AC_DEFUN([AC_INCORPORATE_SDL],
[
	AM_PATH_SDL([$1],
		sdl=[yes],
		sdl=[no])
	AC_INCORPORATE([SDL], [$sdl], [$SDL_CFLAGS], [$SDL_LIBS], [$2], [$3])
])

dnl Incorporate OpenGL.
dnl This means both libGL and libGLU.
dnl AC_INCORPORATE_OPENGL([define on found], [obligatory])
AC_DEFUN([AC_INCORPORATE_OPENGL],
[
	AC_LANG_PUSH([C])
	AC_SEARCH_LIBS([glFrustum],
		[GL],
		gl=[yes],
		gl=[no])
	AC_SEARCH_LIBS([gluPerspective],
		[GLU],
		glu=[yes],
		glu=[no])
	AC_MSG_CHECKING([if OpenGL is ok])
	if test "x$gl" = "xyes" ; then
		if test "x$glu" = "xyes" ; then
			AC_MSG_RESULT([yes])
			AC_CONDITIONAL_DEFINE([$1], [yes])
		elif test "x$2" = "xyes" ; then
			AC_MSG_ERROR([no])
			AC_CONDITIONAL_DEFINE([$1], [no])
		else
			AC_MSG_RESULT([no])
			AC_CONDITIONAL_DEFINE([$1], [no])
		fi
	elif test "x$2" = "xyes" ; then
		AC_MSG_ERROR([no])
		AC_CONDITIONAL_DEFINE([$1], [no])
	else
		AC_MSG_RESULT([no])
		AC_CONDITIONAL_DEFINE([$1], [no])
	fi
	AC_LANG_POP([C])
])

dnl Incorporate GLUT.
dnl AC_INCORPORATE_GLUT([define on found], [obligatory])
AC_DEFUN([AC_INCORPORATE_GLUT],
[
	AC_LANG_PUSH([C])
	AC_SEARCH_LIBS([glutInit],
		[glut],
		glut=[yes],
		glut=[no])
	AC_INCORPORATE([GLUT], [$glut], [], [], [$1], [$2])
])

dnl Require C standard.
dnl AC_INCORPORATE_C99([define on found], [obligatory])
AC_DEFUN([AC_REQUEST_C99],
[
	AC_PROG_CC_C99()
	AC_MSG_CHECKING([for C99])
	if test "x$ac_cv_prog_cc_c99" != "xno" ; then
		AC_MSG_RESULT([yes])
		AC_CONDITIONAL_DEFINE([$1], [yes])
	else
		if test x$obligatory = xyes ; then
			AC_MSG_ERROR([no])
		else
			AC_MSG_RESULT([no])
		fi
	fi
])

dnl Check if openmp is supported.
dnl AC_CHECK_OPENMP([define on yes], [obligatory])
AC_DEFUN([AC_INCORPORATE_OPENMP],
[
	openmp_c=[yes]
	openmp_cxx=[yes]
	openmp_ld=[yes]

	if test "x$CC" != x ; then
		AC_LANG_PUSH([C])
		AC_MSG_CHECKING([if $CC accepts -fopenmp])
		CFLAGS_save=[$CFLAGS]
		AC_ADD_CCFLAG([-fopenmp])
		AC_TRY_COMPILE([],
			[],
			flag=[yes],
			flag=[no])
		if test x$flag = xno ; then
			openmp_c=[no]
		fi
		AC_MSG_RESULT([$flag])
		AC_LANG_POP([C])
		CFLAGS="$CFLAGS_save"
	fi

	if test "x$CXX" != x ; then
		AC_LANG_PUSH([C++])
		AC_MSG_CHECKING([if $CXX accepts -fopenmp])
		CXXFLAGS_save=[$CXXFLAGS]
		AC_ADD_CXXFLAG([-fopenmp])
		AC_TRY_COMPILE([],
			[],
			flag=[yes],
			flag=[no])
		if test x$flag = xno ; then
			openmp_cxx=[no]
		fi
		AC_MSG_RESULT([$flag])
		AC_LANG_POP([C++])
		CXXFLAGS="$CXXFLAGS_save"
	fi

	AC_MSG_CHECKING([if $LD accepts -fopenmp])
	LDFLAGS_save=[$LDFLAGS]
	AC_ADD_LDFLAG([-fopenmp])
	AC_TRY_LINK([],
		[],
		flag=[yes],
		flag=[no])
	if test x$flag = xno ; then
		openmp_ld=[no]
	fi
	AC_MSG_RESULT([$flag])
	LDFLAGS=[$LDFLAGS_save]

	openmp_ok=[no]
	if test x$openmp_c = xyes ; then
		if test x$openmp_cxx = xyes ; then
			if test x$openmp_ld = xyes ; then
				openmp_ok=[yes]
			fi
		fi
	fi

	AC_INCORPORATE([OpenMP], [$openmp_ok], [-fopenmp], [-fopenmp], [$1], [$2])
])
