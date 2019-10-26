nasmw -f bin dx_depacker_gtc.asm -o depacker.bin -s -O9
nasmw -f bin transmission.asm -o transmission.bin -s -O9
1kpack.exe depacker.bin transmission.bin transmission.exe 



pause