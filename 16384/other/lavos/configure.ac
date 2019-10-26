AC_INIT([lavos], [r0], [devel@faemiyah.fi])

AC_CANONICAL_BUILD
AC_CANONICAL_HOST
AC_CANONICAL_TARGET

AM_INIT_AUTOMAKE([dist-bzip2])

AC_CHECK_C99
AC_CHECK_CXX

AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MAKE_SET
AC_C_BIGENDIAN

AC_COMPILE_MODE

AC_CONDITIONAL_DEFINE([USE_LD], [yes])

AC_CHECK_HEADER([inttypes.h])
AC_CHECK_HEADER([stdint.h])

AC_INCORPORATE_BOOST_ELEMENTARY([ENABLE_BOOST_ELEMENTARY], [yes])
AC_INCORPORATE_BOOST_PROGRAM_OPTIONS([ENABLE_BOOST_PROGRAM_OPTIONS], [yes])
AC_INCORPORATE_GLEW([ENABLE_GLEW], [yes])
AC_INCORPORATE_LIBPNG([1.5.0], [ENABLE_LIBPNG], [yes])
AC_INCORPORATE_OPENGL([ENABLE_OPENGL], [yes])
AC_INCORPORATE_SDL([1.2.7], [ENABLE_SDL], [yes])

AC_CONFIG_FILES([Makefile src/Makefile])
AC_OUTPUT

echo "
Configuration for $PACKAGE_TARNAME $PACKAGE_VERSION:
  Enable debug:          $ENABLE_DEBUG
  Enable optimizations:  $optimizations
  C Compiler:            $CC
  C compiler flags:      $CFLAGS
  C++ Compiler:          $CXX
  C++ compiler flags:    $CXXFLAGS
  Linker flags:          $LDFLAGS
  Libs:                  $LIBS
  Install prefix:        $prefix
Type 'make' to build and 'make install' to install $PACKAGE."
