#!/bin/sh
LD_PRELOAD=/usr/lib/libSDL-1.2.so
LD_LIBRARY_PATH=/usr/lib/nvidia-current
exec ./$1
