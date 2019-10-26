@echo off
del /q *.com

nasm -D DOSBOX ship.asm -o ship.com
nasm ship.asm -o shipdos.com

ndisasm -o 256 -b 16 ship.com > ndis.asm

