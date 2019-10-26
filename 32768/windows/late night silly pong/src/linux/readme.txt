Sorry for the bad written code. It was late.

The linux src was modified a bit. (renamed cpp to c)
Please use this source if you wanna compile the project on another x86 platform!

I compiled it with:
	gcc -o asm_compo11 main.c graphics.c -lpthread `sdl-config --cflags --libs`

If that doenst work, use this instead:
	gcc -o asm_compo11 main.c graphics.c -lSDL

over and out - saida