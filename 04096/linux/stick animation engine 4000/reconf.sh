#!/bin/sh

SRCM4="${HOME}/bin/cflags/acinclude.m4"

cp $SRCM4 .
autoreconf --force
