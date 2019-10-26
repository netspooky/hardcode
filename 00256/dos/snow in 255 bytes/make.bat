@echo off
tasm snf.asm
tlink /tdc snf.obj
del snf.obj
del snf.map
