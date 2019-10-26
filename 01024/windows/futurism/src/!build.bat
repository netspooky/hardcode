nasmw -f bin dx_depacker_gtc.asm -o depacker.bin -s -O9
nasmw -f bin futurism.asm -o futurism.exe -s -O9
1kpack.exe depacker.bin futurism.exe 



pause