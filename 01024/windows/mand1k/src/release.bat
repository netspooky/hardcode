@echo off
nasmw -f bin mand1k.asm -o mand1k.obj -s -O9
c:\ruby193\bin\ruby super1kpack.rb mand1k.obj mand1k.exe
