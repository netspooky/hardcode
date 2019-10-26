# Process this file with autoconf to produce a configure script.

# Init
AC_INIT([origami], [1], [foo@bar.com], [origami])

# J‰rjestelm‰n tyyppi
AC_CANONICAL_BUILD
AC_CANONICAL_HOST
AC_CANONICAL_TARGET

# Automaken init
AM_INIT_AUTOMAKE([dist-bzip2])

# Tarkistukset
AC_PROG_CPP
AC_PROG_CC
AC_PROG_CXX
AC_PROG_MAKE_SET
AC_PROG_RANLIB

AC_CHECK_HEADERS(math.h stdlib.h)

AC_STRIP_BINARIES
AC_CHECK_GL([no])
AC_CHECK_GTK([2.4.10], [no])
AC_CHECK_SDL([1.2.4])
AC_CHECK_SDL_IMAGE([no])

# Vapaavalintaiset jutut
AC_CONDITIONAL_DEFINE([FLAG_ENABLE_GTK], [$gtk])
AC_CONDITIONAL_DEFINE([FLAG_ENABLE_SDL_IMAGE], [$sdl_image])

# M‰‰ritell‰‰n k‰ytett‰v‰t conffifilut ja ulostetaan
AM_CONFIG_HEADER(src/config.h)
AC_CONFIG_FILES([Makefile src/Makefile])
AC_OUTPUT

# Lopetusjuttu
echo "
Configuration for: $PACKAGE_TARNAME
 Target system:		$target
 GTK front-end:		$gtk
 Icons with SDL_Image:	$sdl_image
 Compiler flags:	$CFLAGS
 Linker flags:		$LDFLAGS
 Libraries:		$LIBS
Type 'make' to build and 'make install' to install $PACKAGE.
"
