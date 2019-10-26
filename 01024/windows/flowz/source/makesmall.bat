#!/bin/sh

strip --strip-all -v -R .comment oglsmall.exe
dropper /c3 /o2 /n /p2 oglsmall.exe
apack oglsmall.com
ls -l oglsmall.exe oglsmall.com out.com
