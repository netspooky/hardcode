#!/bin/sh
LD_PRELOAD=/usr/lib32/libSDL-1.2.so
LD_LIBRARY_PATH=/usr/lib32/nvidia-current
exec ./$1
