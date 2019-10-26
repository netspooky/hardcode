#!/bin/sh

BINARY="primordial_soup"

UNAME_BASE=`uname -s`
UNAME=`echo ${UNAME_BASE} | tr '[:upper:]' '[:lower:]'`

compile()
{
  COMPILE_SCRIPT="compile.sh"
  if [ ! -f "${COMPILE_SCRIPT}" ] ; then
    echo "${0}: '${COMPILE_SCRIPT}' not found"
    exit 1
  fi

  sh compile.sh --32 -DDISPLAY_MODE=$1
  if [ $? -ne 0 ] ; then
    echo "${0}: compile failed"
    exit 1
  fi

  RESOLUTION=$1
  WINDOWING="fullscreen"
  if [ $1 -lt 0 ] ; then
    RESOLUTION="${1#-}"
    WINDOWING="windowed"
  fi
  cp "src/${BINARY}" "rel/${BINARY}_${UNAME}-ia32_compo_${RESOLUTION}p_${WINDOWING}"
  if [ $? -ne 0 ] ; then
    echo "${0}: release copy failed"
    exit 1
  fi
}

compile "-720"
compile "-1080"
compile "720"
compile "1080"

ls -l "rel/${BINARY}_${UNAME}-ia32_compo_"*

exit 0
