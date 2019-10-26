#!/bin/sh
as -o synth-processed.o synth-processed.asm
if [ $? -ne 0 ] ; then
  echo "${0}: synth assembly failed"
  exit 1
fi
objdump -xd synth-processed.o > synth-processed.objdump
if [ $? -ne 0 ] ; then
  echo "${0}: synth objdump failed"
  exit 1
fi
gcc -o main.o -c main.c
if [ $? -ne 0 ] ; then
  echo "${0}: main compile failed"
  exit 1
fi
gcc -o asmtest synth-processed.o main.o -lsndfile
if [ $? -ne 0 ] ; then
  echo "${0}: link failed"
  exit 1
fi
exit 0
