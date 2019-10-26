nasmw -f bin dx_depacker_gtc.asm -o depacker.bin -s -O9
nasmw -f bin plastice.asm -o plastice.bin -s -O9
1kpack.exe depacker.bin plastice.bin 



pause