Nuno
PC 4k intro for Breakpoint2010
by Tomohiro

Nuno means cloth in Japanese.
My first plan was making cloth simulation in 4k.
But showing only a cloth is not funny.
At first, I made some dancers, becaues dancer wearing cloth looks very good.
But there is no space and time left for cloth simulation.

System requirement
--------
GPU: support OpenGL 3.1 or higher.
(nVidia Geforce8000s series or later supports OpenGL 3.1.
If your Geforce/Quadro doesn't support it, you might need to update GPU driver.
Most of DirectX 10 class GPU supports OpenGL 3.1)
OS: WindowsXP, WindowsVista or Windows7
CPU: support SSE3
(This program uses only 1 thread. Many core CPU is meaningless for Nuno.
Running with many threads requires more code.)

Although this program looks primitve, this program using vertex/fragment shaders and the instanced rendering in order to reduce CPU code.

Credit
--------
Code, Modeling: Tomohiro

Special Thanks
--------
kioku / System K
He gave me a lot of usefull advises.

Tools
--------
Crinkler:
When I build Nuno without Crinkler, Size of Nuno is about 13000 bytes!
Thank you very very much for Crinkler!
gvim:
If it was not exist, I could not write any codes.
Microsoft Visual C++ 2008 Express Edition:
If it was not exist, I would use g++ and Boost.Build.
Blender:
Best free 3D modeling tool to make something looks like human which is composed of multiple lines.

API:
--------
OpenGL 3.1
win32api

contact:
--------
gpuppur@gmail.com

