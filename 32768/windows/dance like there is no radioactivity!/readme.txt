Dance like there is no radioactivity!

PC 64k intro for Revision2011
by Tomohiro

I think there is no radioactivity in this city, but all people in the city went to safer place.
There are many empty buildings. An electronic power supply company cannot sell their energy in this city.
They need to appeal a safety of this city.
They ordered their Syachikus to dance in this city.
Syachikus with white protective clothing will dance if they survived.

GPU Raytacing is used when drawing buildings.
Traditonal Rasterization is used when drawing human shape.

System requirement
--------
GPU: support OpenGL 3.2 or higher.
(nVidia Geforce8000s series or later supports OpenGL 3.3.
If your Geforce/Quadro doesn't support it, you might need to update GPU driver.
Most of DirectX 10 class GPU supports OpenGL 3.3)
OS: WindowsXP, WindowsVista or Windows7
CPU: support SSE3
(This program uses only 1 thread. Many core CPU is meaningless for this demo.
Running with many threads requires more code.)

Credit
--------
Code, Modeling, etc: Tomohiro

Tools
--------
kkrunchy:
Very nice packer.

shader_minifier.exe
Convert glsl shader code to suitable for 4k/64k intro.
Making intro without it will be pretty hard.
This is really awesome tool!

gvim:
If it was not exist, I could not write any codes.
Microsoft Visual C++ 2008 Express Edition:
If it was not exist, I would use g++ and Boost.Build.

Blender:
Best free 3D modeling tool to make something looks like human which is composed of multiple lines.
But all models/motions in this intro except human like shapes are created by instructions in this intro.

ResEdit:
I used this tool to make a dialog displayed before intro running.


API:
--------
OpenGL 3.2
win32api
SSE3

contact:
--------
gpuppur@gmail.com
