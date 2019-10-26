@echo off
nasmw -D DEBUG -f bin mand1k.asm -o mand1k.exe -s -O9
1kpack "dx_depacker_gtc_debug.bin" mand1k.exe