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

#python "${DNLOAD}" -c src/intro.cpp -o src/junamatkailuintro -lc -ldl -lgcc -lEGL -lGLESv2 -v -m dlfcn
python "${DNLOAD}" -c src/intro.cpp -o src/junamatkailuintro -lbcm_host -lc -lgcc -lm -lEGL -lGLESv2 -lSDL -v -m hash
if test $? -ne 0 ; then
  echo "${0}: compilation failed"
  exit 1
fi

exit 0
