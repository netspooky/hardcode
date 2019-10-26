#!/bin/bash
# Checks the size of the, should be under 4096 kB

TARGET=derivations

echo 'executable:'
cat $TARGET | wc -c
