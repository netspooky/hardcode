--== Gotcha ==--

code: the update^copro
sound: borrowed from lemmings, syndicate and chuck rock (all amiga)

0] About Gotcha

This is an ego shooter in 32k. It's based on an outdoor fractal terrain on which you fight either a bunch of bots or your human friends using a tcp/ip network connection. 

Gotcha is the result of a three week try to learn the complete dx8sdk. It is quite unstable and runs only on selected computers since I made quite a lot of mistakes during development. If you have a Geforce-series graphics card and quite new drivers (tested with 11.01 which is the shipping version for all Geforce3 cards) and Windows 2000, the chances are quite good that the singleplayer version is playable. The network release is kind of unpredictable, sometimes it runs stable for a long time, sometimes it crashes when someone tries to join a game...

Although the code is a mess, I spread it on demand, so if you're interested in collision detection for example (the only part I like), I can send it to you. Visual C++ 6.0 and the dx8sdk are required.

1] Control
   
1.1] Mouse

View Direction

Left MB = shoot
Right MB = jump

MouseSpeed Default = 100, higher numbers result in slower movement

1.2] Keyboard

W = Move Forward
S = Move Backward
A = Strafe Left
D = Strafe Right

Shift = Slow Down

Cursor = look around
Right Control = shoot

Escape = Toggle Menu
Return = Enter selected Menu
Cursor = Select Menu

2] Network

2.1] Create 

Enter a random seed which is the base for the terrain generator. 

2.2] Join 

Enter the name or ip of the host you want to connect with.

2.3] Add Bot

You can add bots to your single player game here. The number you enter is not used in the party version.

3] Developer Notes

3.1] Direct Music

If you're using mp3 compressed wave files as direct music segments, you can download only one into the performance, all following mp3 compressed segments will fail. There's no problem with PCM waves or other types of ACM compression.

4] Contact

email: malte.clasen@gmx.de
web: http://www.copro.org/malte
