AC_INIT([sae4], [1.0.0], [trilkk@faemiyah.fi])

AC_CANONICAL_BUILD
AC_CANONICAL_HOST
AC_CANONICAL_TARGET

AM_INIT_AUTOMAKE([dist-bzip2])

AC_PROG_CPP
AC_PROG_CXX
AC_PROG_INSTALL
AC_PROG_LIBTOOL
AC_PROG_LN_S
AC_PROG_MAKE_SET
AC_PROG_RANLIB

AC_REQUEST_C99([SAE4_C99], [yes])

AC_COMPILE_MODE([SAE4_DEBUG])
AC_CONDITIONAL_DEFINE([SAE4_GNU_LD], [yes])

AC_C_BIGENDIAN([bigendian=yes],
							 [littleendian=yes],
							 [AC_MSG_ERROR([could not determine endianness])])
AC_CONDITIONAL_DEFINE([SAE4_BIG_ENDIAN], [$bigendian])
AC_CONDITIONAL_DEFINE([SAE4_LITTLE_ENDIAN], [$littleendian])

AC_CHECK_HEADER([inttypes.h],
								[AC_DEFINE([SAE4_HAVE_INTTYPES_H],
													 [],
													 [C99 int types backend])],
								[])
AC_CHECK_HEADER([stdint.h],
								[AC_DEFINE([SAE4_HAVE_STDINT_H],
													 [],
													 [C99 int types backend])],
								[])
AC_CHECK_HEADER([sys/inttypes.h],
								[AC_DEFINE([SAE4_HAVE_SYS_INTTYPES_H],
													 [],
													 [C99 int types backend])],
								[])


AC_INCORPORATE_OPENGL([SAE4_OPENGL], [yes])
AC_INCORPORATE_GLUT([SAE4_FREEGLUT], [yes])
AC_INCORPORATE_SDL([1.2.7], [SAE4_SDL], [yes])


# Not using config.h
#AC_SPECIFIC_HEADER([src/config.h],
#									 [src/sae4_config.hpp],
#									 [LIFAE_])
AC_CONFIG_FILES([Makefile src/Makefile])
AC_OUTPUT

# output
VERSION_CURRENT=[1]
VERSION_REVISION=[0]
VERSION_AGE=[0]
LIBTOOL_VERSION=[$VERSION_CURRENT:$VERSION_REVISION:$VERSION_AGE]
AC_SUBST(LIBTOOL_VERSION)

echo "
Configuration for $PACKAGE_TARNAME $PACKAGE_VERSION:
	Enable debug:             $SAE4_DEBUG
	Enable optimizations:     $optimizations
	Compiler flags:           $CFLAGS
	Linker flags:             $LDFLAGS
	Libs:                     $LIBS
	Install prefix:           $prefix
Type 'make' to build and 'make install' to install $PACKAGE."
