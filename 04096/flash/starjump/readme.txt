StarJump 4K Flash 10 intro
by Shiru (shiru@mail.ru), 07'09

This is my first attempt to make Adobe Flash 4K intro.

Requirements: Flash Player 10 or better. The intro is tweaked to work smoothly
on my computer (PIV 3 GHz), though it works no so smooth in browser, comparing
with stand-alone player. Will work on slower computers with frameskip.

Sound data is prerendered when intro starts, because AS3 is not fast enough to
make synthesis in realtime together with smooth animation.

Source code is provided.  It is not very useful, though,  because the  way the
Flash works  is require to do  really stupid things to reduce file size,  like
replacing constants to precalculated values and use shorter names of variables
and functions. The source code can be compiled with Flex SDK 3.