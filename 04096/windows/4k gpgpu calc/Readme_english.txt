4k GPGPU calc

PC 4k game for Tokyo Demo Fest 2013
by Tomohiro

This program take GLSL float expression and display result.
(Please refer "Example.txt")

Ascii arts used in this game is not my original but created by anonymous 2ch
people.

System requirement
--------
GPU: support OpenGL 3.2 or higher.
(nVidia Geforce8000s series or later supports OpenGL 3.3.
If your Geforce/Quadro doesn't support it, you might need to update GPU driver.
Most of DirectX 10 class GPU supports OpenGL 3.3)
This program is only tested in Nvidia and intel GPU. Because I have only intel and Nvidia GPUs.
But I read OpenGL specification and tried to avoid using vender specific functions.
So theoretically, this program runs in any 3D accelerator supports OpenGL 3.

OS: Windows7 or 8
CPU: support x87 FPU
(This program uses only 1 thread. Many core CPU is meaningless for this demo.)

Credit
--------
Code, Sound, etc: Tomohiro

Tools
--------
Crinkler:
Greate compressing linker for 4k intro!
http://www.crinkler.net/

gvim:
If it was not exist, I could not write any codes.

Microsoft Visual C++ 2012 Express Edition:
If it was not exist, I would use g++ and Boost.Build.

API:
--------
OpenGL 3.2
win32api

contact:
--------
gpuppur@gmail.com

TwitterID
--------
@demotomohiro
