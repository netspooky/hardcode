# This m4 script file contains all the stuff possibly required to compile a
# various programs. Made for home use.

##############################################################################
# Jotaan #####################################################################
##############################################################################

# Cleanly insers stuff to a variable
# AC_VARIABLE_EXPAND(VARIABLE, EXPANDING_VARIABLE)
AC_DEFUN([AC_VARIABLE_EXPAND],
[
  # Simple test
  if test "$$1" != "" ; then
    $1="$[$1] $2"
  else
    $1="$2"
  fi
])

# Explicitly disable of binaries stripping?
# AC_STRIP_BINARIES
AC_DEFUN([AC_STRIP_BINARIES],
[
  # Configure additions
  AC_ARG_ENABLE(
    strip,
    AC_HELP_STRING(
      [--disable-strip],
      [Don't strip binaries of debugging information]),
    STRIP_BINARIES=[no],
    [])
  # Jos sanottiin niin älä tee mitään, muutoin lisää
  if test x$STRIP_BINARIES != xno ; then
    if test x`echo $LDFLAGS | grep "\(^\|\s\)\-s\($\|\s\)"` == x ; then
      AC_VARIABLE_EXPAND(LDFLAGS, [-s])
    fi
  fi
])

# If $2 is 'yes', define and make an am_conditional of $1
# AC_CONDITIONAL_DEFINE([DEFINE_STRING], [TEST_STRING])
AC_DEFUN([AC_CONDITIONAL_DEFINE],
[
  if test x$2 == xyes ; then
    AC_DEFINE_UNQUOTED([$1], [], [Conditionally defined])
  fi
  AM_CONDITIONAL([$1], [test x$2 == xyes])
  AC_SUBST([$1], [$2])
])

# Enables or disables debug mode
# AC_DEBUG_MODE([DEBUG_DEFINE])
AC_DEFUN([AC_DEBUG_MODE],
[
  AC_MSG_CHECKING([whether to enable debug])
  # Configure additions
  AC_ARG_ENABLE(
    debug,
    AC_HELP_STRING(
      [--enable-debug],
      [Compile with additional debugging information and functions (default: no)]),
    debugmode=[yes],
    debugmode=[no])

  AC_CONDITIONAL_DEFINE([$1], [$debugmode])
  AC_MSG_RESULT([$debugmode])
])

##############################################################################
# Nasm #######################################################################
##############################################################################

# Nasm configuration script. Returns the path to nasm (NASM_BIN) and the nasm
# output flags (NASM_FLAGS).
AC_DEFUN([AM_NASM_BIN],
[
# Configure additions
  AC_ARG_WITH(
    [nasm-dir],
    AC_HELP_STRING(
      [--with-nasm-dir],
      [nasm binary literal location (optional)]),
    [nasm_dir=$withval],
    [nasm_dir=""])
  AC_ARG_WITH(
    [nasm-prefix],
    AC_HELP_STRING(
      [--with-nasm-prefix],
      [nasm installation prefix (optional)]),
    [nasm_prefix=$withval],
    [nasm_prefix=""])
  AC_ARG_WITH(
    [nasm-output],
    AC_HELP_STRING(
      [--with-nasm-output],
      [nasm object format (recommended if using nasm)]),
    [nasm_output=$withval],
    [nasm_output=""])

  # Jos prefix
  if test x$nasm_prefix != x ; then
    nasm_dir = [$nasm_prefix/bin]
  fi

  # Haetaan se binääri
  if test x$nasm_dir != x ; then
    AC_PATH_PROG(NASM_BIN, [nasm], [no], [$nasm_dir])
  else
    AC_PATH_PROG(NASM_BIN, [nasm], [no])
  fi

# Testataan NASM:in output format
  AC_MSG_CHECKING([nasm output format])
  if test x$nasm_output != x ; then
    NASM_FORMAT="$nasm_output"
  else
    case $target in
      *linux*)
        NASM_FORMAT="elf"
        ;;
      *bsd*)
        NASM_FORMAT="aoutb"
        ;;
      *)
        NASM_FORMAT="aout"
        ;;
    esac
  fi
  AC_MSG_RESULT([$NASM_FORMAT])

# Kysytään nyt vielä halutaanko se ehdottomasti
  AC_MSG_CHECKING([do we want nasm])
  AC_ARG_ENABLE(
    [nasm],
    AC_HELP_STRING(
      [--enable-nasm],
      [Use the netwide assembler (req. ia32)]),
    [],
    NASM_BIN=[no])
  AM_CONDITIONAL(LF_ARCHITECHTURE_ia32, test x$NASM_BIN != xno)
  if test x$NASM_BIN != xno ; then
    AC_DEFINE([LF_ARCHITECHTURE_ia32], [], [Plaa])
    AC_MSG_RESULT([yes])
  else
    AC_MSG_RESULT([no])
  fi

  AC_SUBST(NASM_BIN)
  AC_SUBST(NASM_FLAGS, "-f $NASM_FORMAT")
])

##############################################################################
# sdl_image ##################################################################
##############################################################################

# SDL_image configuration script. Must be run after checking SDL. Sets
# SDL_IMAGE_LIBS
# AM_PATH_SDL_IMAGE([ACTION_IF_YES], [ACTION_IF_NO])
AC_DEFUN([AM_PATH_SDL_IMAGE],
[
  AC_ARG_ENABLE(
    [sdlimagetest],
    AC_HELP_STRING(
      [--disable-sdlimagetest],
      [Do not try to compile and run a test SDL_image program]),
    no_sdlimagetest=[yes],
    no_sdlimagetest="")

  SDL_IMAGE_LIBS=[-lSDL_image]
  
  if test x$no_sdlimagetest == x ; then
    AC_HAVE_LIBRARY(SDL_image, $1, $2)
  else
    $1
  fi

  AC_SUBST(SDL_IMAGE_LIBS)
])

##############################################################################
# libmad #####################################################################
##############################################################################

# libmad configuration script. Sets LIBMAD_CFLAGS and LIBMAD_LIBS
# AM_PATH_LIBMAD([MINIMUM_VERSION], [ACTION_IF_YES], [ACTION_IF_NO])
AC_DEFUN([AM_PATH_LIBMAD],
[

  LIBMAD_CFLAGS=""
  LIBMAD_LIBS=""

  if test -z "$PKG_CONFIG"; then
    AC_PATH_PROG(PKG_CONFIG, pkg-config, no)
  fi
  if test "$PKG_CONFIG" = "no" ; then
     $3
  else
    AC_MSG_CHECKING([for libmad >= $1])
    if `$PKG_CONFIG --atleast-version $1 mad` ; then
      LIBMAD_CFLAGS=`$PKG_CONFIG --cflags mad`
      LIBMAD_LIBS=`$PKG_CONFIG --libs mad`
      AC_MSG_RESULT([yes])
      $2
    else
      AC_MSG_RESULT([no])
      $3
    fi
  fi
  AC_SUBST(LIBMAD_CFLAGS)
  AC_SUBST(LIBMAD_LIBS)
])

##############################################################################
# Wrapperit ##################################################################
##############################################################################

# Wrapperi SDL:lle, jos ei pakollinen, $2 = [no]
# AC_CHECK_SDL([MINIMUM_VERSION])
AC_DEFUN([AC_CHECK_SDL],
[
  if test x$2 == xno ; then
    # Jos SDL:ää ei haluta
    AC_ARG_ENABLE(
      [sdl],
      AC_HELP_STRING(
        [--disable-sdl],
	[Do not include support for SDL]),
      sdl=[no],
      sdl=[yes])
  fi

  if test x$sdl != xno ; then
    AM_PATH_SDL($1, sdl=[yes], sdl=[no])
    AC_MSG_CHECKING([if SDL is ok])
    if test x$sdl == xyes ; then
      AC_MSG_RESULT([$sdl])
      AC_VARIABLE_EXPAND(CFLAGS, [$SDL_CFLAGS])
      AC_VARIABLE_EXPAND(CXXFLAGS, [$SDL_CFLAGS])
      AC_VARIABLE_EXPAND(LIBS, [$SDL_LIBS])
    else
      if test x$2 == xno ; then
	AC_MSG_RESULT([$sdl])
      else
	AC_MSG_ERROR([$sdl])
      fi
    fi
  fi
])

# Wrapperi SDL_image:lle, jos ei pakollinen, $1 = [no]
# AC_CHECK_SDL_IMAGE
AC_DEFUN([AC_CHECK_SDL_IMAGE],
[
  if test x$1 == xno ; then
    # Jos SDL_IMAGE:a ei haluta
    AC_ARG_ENABLE(
      [sdlimage],
      AC_HELP_STRING(
        [--disable-sdlimage],
	[Do not include support for SDL_image]),
      sdl_image=[no],
      sdl_image=[yes])
  fi

  if test x$sdl_image != xno ; then
    AM_PATH_SDL_IMAGE(sdl_image=[yes], sdl_image=[no])
    AC_MSG_CHECKING([if SDL_image is ok])
    # Jos meillä ei ole SDL:ää, niin sitten ei ole SDL_imageakaan
    if test x$sdl != xyes ; then
      sdl_image=[no]
      if test x$1 == xno ; then
	AC_MSG_RESULT([no SDL])
      else
	AC_MSG_ERROR([no SDL])
      fi
    else
      if test x$sdl_image == xyes ; then
	AC_MSG_RESULT([$sdl_image])
	AC_VARIABLE_EXPAND(LIBS, [$SDL_IMAGE_LIBS])
      else
	if test x$1 == xno ; then
	  AC_MSG_RESULT([$sdl_image])
	else
	  AC_MSG_ERROR([$sdl_image])
	fi
      fi
    fi
  fi
])

# Wrapperi gtk:lle, jos ei pakollinen, $2 = [no]
# AC_CHECK_GTK([MINIMUM_VERSION], [ENABLED_DEFINE_NAME])
AC_DEFUN([AC_CHECK_GTK],
[
  if test x$2 == xno ; then
    # Jos GTK:ta ei haluta
    AC_ARG_ENABLE(
      [gtk],
      AC_HELP_STRING(
        [--disable-gtk],
	[Do not include support for GTK]),
      gtk=[no],
      gtk=[yes])
  fi

  if test x$gtk != xno ; then
    AM_PATH_GTK_2_0($1, gtk=[yes], gtk=[no])
    AC_MSG_CHECKING([if gtk is ok])
    if test x$gtk == xyes ; then
      AC_MSG_RESULT([$gtk])
      AC_VARIABLE_EXPAND(CFLAGS, [$GTK_CFLAGS])
      AC_VARIABLE_EXPAND(CXXFLAGS, [$GTK_CFLAGS])
      AC_VARIABLE_EXPAND(LIBS, [$GTK_LIBS])
    else
      if test x$2 == xno ; then
	AC_MSG_RESULT([$gtk])
      else
	AC_MSG_ERROR([$gtk])
      fi
    fi
  fi
])

# Wrapperi libfhi:lle
# AC_CHECK_LIBFHI([MINIMUM_VERSION])
AC_DEFUN([AC_CHECK_LIBFHI],
[
  AM_PATH_LIBFHI($1, libfhi=[yes], libfhi=[no])
  AC_MSG_CHECKING([if libfhi is ok])
  if test x$libfhi == xyes ; then
    AC_MSG_RESULT([$libfhi])
    AC_VARIABLE_EXPAND(CFLAGS, [$LIBFHI_CFLAGS])
    AC_VARIABLE_EXPAND(CXXFLAGS, [$LIBFHI_CFLAGS])
    AC_VARIABLE_EXPAND(LIBS, [$LIBFHI_LIBS])
  else
    AC_MSG_ERROR([$libfhi])
  fi
])

# Wrapperi libxml:lle
# AC_CHECK_LIBXML([MINIMUM_VERSION])
AC_DEFUN([AC_CHECK_LIBXML],
[
  AM_PATH_XML2($1, libxml=[yes], libxml=[no])
  AC_MSG_CHECKING([if libxml is ok])
  if test x$libxml == xyes ; then
    AC_MSG_RESULT([$libxml])
    AC_VARIABLE_EXPAND(CXXFLAGS, [$XML_CPPFLAGS]) # Vain C++
    AC_VARIABLE_EXPAND(LIBS, [$XML_LIBS])
  else
    AC_MSG_ERROR([$libxml])
  fi
])

# Wrapperi libmad:lle, jos ei pakollinen, $2 = [no]
# AC_CHECK_LIBMAD([MINIMUM_VERSION])
AC_DEFUN([AC_CHECK_LIBMAD],
[
  if test x$2 == xno ; then
    AC_ARG_ENABLE(
      [libmadtest],
      AC_HELP_STRING(
        [--disable-libmad],
	[Do not include support for libmad]),
      libmad=[no],
      libmad=[yes])
  fi

  if test x$libmad != xno ; then
    AM_PATH_LIBMAD($1, libmad=[yes], libmad=[no])
    AC_MSG_CHECKING([if libmad is ok])
    if test x$libmad == xyes ; then
      AC_MSG_RESULT([$libmad])
      AC_VARIABLE_EXPAND(CFLAGS, [$LIBMAD_CFLAGS])
      AC_VARIABLE_EXPAND(CXXFLAGS, [$LIBMAD_CFLAGS])
      AC_VARIABLE_EXPAND(LIBS, [$LIBMAD_LIBS])
    else
      if test x$2 == xno ; then
	AC_MSG_RESULT([$libmad])
      else
	AC_MSG_ERROR([$libmad])
      fi
    fi
  fi
])

# Wrapperi GL:lle, jos ei pakollinen $2 = [no]
# AC_CHECK_GL
AC_DEFUN([AC_CHECK_GL],
[
  # Jos ei pakollinen
  if test x$1 == xno ; then
    AC_ARG_ENABLE(
      [gl],
      AC_HELP_STRING(
        [--disable-gl],
	[Do not include support for OpenGL]),
      gl=[no],
      gl=[yes])
  fi
  # Testataanko vai otetaanko kylmänä?
  AC_ARG_ENABLE(
      [gltest],
      AC_HELP_STRING(
        [--disable-gltest],
	[Do not search for OpenGL libraries (assume defaults work)]),
      gltest=[no],
      gltest=[yes])

  if test x$gl != xno ; then
    if test x$gltest == xno ; then
      AC_VARIABLE_EXPAND(LIBS, [-lGL -lGLU -lglut])
      AC_SUBST(HAVE_GL_GL_H)
      AC_SUBST(HAVE_GL_GLU_H)
      AC_SUBST(HAVE_GL_GLUT_H)
    else
      AC_HAVE_LIBRARY(GL, [], [glerror=[yes]])
      AC_HAVE_LIBRARY(GLU, [], [glerror=[yes]])
      AC_HAVE_LIBRARY(glut, [], [glerror=[yes]])
      AC_CHECK_HEADERS([GL/gl.h] [GL/glu.h] [GL/glut.h], [], [glerror=[yes]])
    fi
    AC_MSG_CHECKING([if OpenGL is ok])
    if test x$glerror == xyes ; then
      gl=[no]
      if test x$2 == xno ; then
	AC_MSG_RESULT([$gl])
      else
	AC_MSG_ERROR([$gl])
      fi
    else
      AC_MSG_RESULT([$gl])
      gl=[yes]
    fi
  fi
])

##############################################################################
# Ei niin asiaankuuluva ######################################################
##############################################################################

# Tutkii missä on FIONREAD (für CType)
# AC_FIND_FIONREAD
AC_DEFUN([AC_FIND_FIONREAD],
[
  AC_MSG_CHECKING(where to find FIONREAD)
  AC_EGREP_CPP(yes,
    [#include <sys/ioctl.h>
     #ifdef FIONREAD
       yes
     #endif],
    [AC_DEFINE(NEED_SYS_IOCTL,,[need sys/ioctl.h for FIONREAD])
     AC_MSG_RESULT(sys/ioctl.h)],
    [AC_EGREP_CPP(yes,
      [#include <sys/filio.h>
       #ifdef FIONREAD
         yes
       #endif],
      [AC_DEFINE(NEED_SYS_FILIO,,[need sys/filio for FIONREAD])
       AC_MSG_RESULT(sys/filio.h)],
      [AC_MSG_RESULT(not found)])
    ])

  AC_SUBST(NEED_SYS_IOCTL)
  AC_SUBST(NEED_SYS_FILIO)
])

##############################################################################
# Loppu ######################################################################
##############################################################################
