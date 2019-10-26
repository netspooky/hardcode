Radioactivity in tokyo damaged my intro!

PC 4k intro for Tokyo Demo Fest 2012
by Tomohiro


System requirement
--------
GPU: support OpenGL 3.2 or higher.
(nVidia Geforce8000s series or later supports OpenGL 3.3.
If your Geforce/Quadro doesn't support it, you might need to update GPU driver.
Most of DirectX 10 class GPU supports OpenGL 3.3)
This program is only tested in Nvidia GPU. Because I have only Nvidia GPUs.
But I read OpenGL specification and tried to avoid using vender specific functions.
So theoretically, this program runs in any 3D accelerator supports OpenGL 3.

OS: WindowsXP, WindowsVista or Windows7
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

shader_minifier.exe
Convert glsl shader code to suitable for 4k/64k intro.
Making intro without it will be pretty hard.
This is really awesome tool!
http://www.ctrl-alt-test.fr/?p=358

gvim:
If it was not exist, I could not write any codes.

Microsoft Visual C++ 2008 Express Edition:
If it was not exist, I would use g++ and Boost.Build.

API:
--------
OpenGL 3.2
win32api

contact:
--------
gpuppur@gmail.com
