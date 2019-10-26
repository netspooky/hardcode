nasmw -f bin dx_depacker_gtc.asm -o depacker.bin -s -O9
nasmw -f bin fractaliz.asm -o fractaliz.bin -s -O9
1kpack.exe depacker.bin fractaliz.bin fractaliz.exe 

pause