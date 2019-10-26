#!/bin/sh

DNLOAD="../dnload/dnload.py"
if test ! -f "${DNLOAD}" ; then
  DNLOAD="/usr/local/src/dnload/dnload.py"
  if test ! -f "${DNLOAD}" ; then
    DNLOAD="/usr/local/src/faemiyah-demoscene/dnload/dnload.py"
    if test ! -f "${DNLOAD}" ; then
      echo "${0}: could not find dnload.py"
      exit 1
    fi
  fi
fi

if test ! -f src/dnload.h ; then
  touch src/dnload.h
fi

python "${DNLOAD}" -I/opt/local/include src/intro.cpp -v
if test $? -ne 0 ; then
  echo "${0}: regenerating symbols failed"
  exit 1
fi

exit 0
