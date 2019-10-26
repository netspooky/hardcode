@echo off

c:\asm16\tasm d:\sinscr\sinscr /m
c:\asm16\tlink d:\sinscr\sinscr kernel\kernel,sinscr.exe /3 /x

del sinscr.obj

upx sinscr.exe
