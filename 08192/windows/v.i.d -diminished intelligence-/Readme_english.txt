V.I.D -Diminished Intelligence-

PC 8k intro for Tokyo Demo Fest 2016
by Tomohiro

System requirement
--------
GPU: support OpenGL 4.2 or higher.
(nVidia Geforce400s series or later supports OpenGL 4.2.
If your Geforce/Quadro doesn't support it, you might need to update GPU driver.
Most of DirectX 11 class GPU supports OpenGL 4.2)
This program is only tested in Nvidia GPU, because I have only that GPU.
But I read OpenGL specification and tried to avoid using vender specific functions.
So theoretically, this program runs in any 3D accelerator supports OpenGL 4.

OS: Windows7 or Windows8 (maybe WindowsXP, WindowsVista)
CPU: support x87 FPU
(This program uses only 1 thread)

4k Intro doesn't run!
--------
Most of 4k intro don't check errors in order to make file as small as possible.
*_debug.exe shows same visual and sound and it has error check code and output error messages in console.

Credit
--------
Code, Sound, etc: Tomohiro
Demo Consaltant: hole, q

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

Microsoft Visual Studio Community 2013:
If it was not exist, I would use g++ and Boost.Build.

API:
--------
OpenGL 4.2
win32api

contact:
--------
gpuppur@gmail.com

GitHub
--------
https://github.com/demotomohiro

TwitterID
--------
@demotomohiro
