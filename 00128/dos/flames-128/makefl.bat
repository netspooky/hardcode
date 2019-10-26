@echo off
tasm flames.asm
tlink /tdc flames.obj
del flames.obj
del flames.map
