Matcha Powder vs Wasabi Powder: Modern Copyright War

PC 4k intro for Revision 2013
by Tomohiro


System requirement
--------
GPU: support OpenGL 3.3 or higher.
(nVidia Geforce8000s series or later supports OpenGL 3.3.
If your Geforce/Quadro doesn't support it, you might need to update GPU driver.
Most of DirectX 10 class GPU supports OpenGL 3.3)
This program is only tested in Nvidia and Intel GPU, because I have only these GPUs.
But I read OpenGL specification and tried to avoid using vender specific functions.
So theoretically, this program runs in any 3D accelerator supports OpenGL 3.

OS: Windows7 or Windows8 (maybe WindowsXP, WindowsVista)
CPU: support x87 FPU
(This program uses only 1 thread)

Credit
--------
Code, Sound, etc: Tomohiro

Tools
--------
Crinkler:
Greate compressing linker for 4k intro!
http://www.crinkler.net/

shader_minifier.exe:
Convert glsl shader code to suitable for 4k/64k intro.
Making intro without it will be pretty hard.
This is really awesome tool!
http://www.ctrl-alt-test.fr/?p=358

glew4k:
Automate OpenGL extension initialization for 4k intro.
https://github.com/demotomohiro/glew4kb

gvim:
If it was not exist, I could not write any codes.

Microsoft Visual C++ 2012 Express Edition:
If it was not exist, I would use g++ and Boost.Build.

API:
--------
OpenGL 3.3
win32api

contact:
--------
gpuppur@gmail.com

TwitterID
--------
@demotomohiro