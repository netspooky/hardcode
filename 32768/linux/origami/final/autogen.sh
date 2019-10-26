#!/bin/sh
# General autogen.sh, written by Trilkk
# To backup data, run with command line argument "save", otherwise regenerates
# the build environment.

# Change these lines according to the project.
PACKAGE="origami"
SAVEDIR="/archive/www/fhi/data"

# Directories to look stuff in.
AUTOMAKEDIR="/usr/share/automake"
LIBTOOLDIR="/usr/share/libtool"
ACINCLUDEDIR="/archive/config"

# Define a function to copy a file (and possibly warn if it is missing).
copy_and_warn()
{
  if test ! -e $1 ; then
    echo "Warning: \"$1\" missing."
  else
    cp $1 .
  fi
}

# Act according to the command line
case "$1" in
  save)
    echo "Backuping data."
    rm $SAVEDIR/${PACKAGE}_dev.*
    cd ..
    #s-ar c $SAVEDIR/${PACKAGE}_dev.rar $PACKAGE
    s-ar c $SAVEDIR/${PACKAGE}_dev.tar.bz2 $PACKAGE
    cd $PACKAGE
    #make dist
    #mv ${PACKAGE}*.tar.gz $SAVEDIR/
    #mv ${PACKAGE}*.tar.bz2 $SAVEDIR/
    ;;
  *)
    echo "Regenerating build environment."
    copy_and_warn $AUTOMAKEDIR/config.guess
    copy_and_warn $AUTOMAKEDIR/config.sub
    copy_and_warn $AUTOMAKEDIR/depcomp
    copy_and_warn $AUTOMAKEDIR/install-sh
    copy_and_warn $AUTOMAKEDIR/missing
    copy_and_warn $AUTOMAKEDIR/mkinstalldirs
    copy_and_warn $LIBTOOLDIR/ltmain.sh
    chmod +x config.guess config.sub depcomp install-sh missing mkinstalldirs
    cp $ACINCLUDEDIR/acinclude.m4 .
    #autoreconf --force configure.ac
    aclocal-1.8 -I /usr/local/share/aclocal
    automake-1.8
    autoconf
    ;;
esac

exit 0
