=====================    4K Procedural GFX Monitor  =======================
=====================      kioku @ System K 2009    =======================
=====================    M A D E   I N  J A P A N   =======================
Ver. 0.1
2009.04.13

-What's this?
For 4KB Procedural Graphics tool（or 4KB Executable Graphics).
Enables you to create executable graphics easily.
And you can make an exe file by using a Visual Studio Solution.
A main idea is based on iq's 4k demo framework sample and chocolux by alud.

-Feature
This is a tool for 4KB Executable Graphics using GLSL.
When you write GLSL, this tool will export to 4KB source code.


-Contents
4kgfxmon.exe           tool exe file
4kgfxmon_safe.exe      unpacked version
readme.txt             this file
readme_jp.txt          for japanese ;)
vs.glsl                vertexshader program at startup
fs.glsl                fragmentshader progam at startup
template.txt           template for exporting source code.
4kgfx.sln              for build by VisualStudio2005 solution
4kgfx.vcproj           for build by VisualC++ project
kickCrinkler.bat       this file is run after Release build event
sample folder          some samples



-basic usage
this tool draws one quad polygon to the main window
 with vertexprogram(vs.glsl) and framgment program(fs.glsl).

There is some vs/fs GLSL files in the sample folder.
You can try to copy it to 4kgfxmon.exe folder and kick 4kgfxmon.exe.


-Preview
this tool reads vs.glsl and fs.glsl at startup
and draws a polygon with the vs/fs shader program.
If no file is found, the tool can't create the source. There
will be no preview scene.


-Edit
This tool is for watching vs.glsl and fs.glsl.
If you modify and save vs.glsl or fs.glsl, 
this tool will reload these files.
You can get a preview quickly by changing shaders.
If the shader program has bugs, the tool outputs no preview but shows the errors.
After removing the bugs, this tool will preview the scene.


-Export
After creating error free shader programs, you can export it to cpp file.
Right click at main preview window, click "Export...".
you will get template.cpp in exe folder.
This source file is based on template.txt.
Added comments and the like will not be copied.
Export removes all TABs and unnecessary SPACEs.
Don't temper with template.txt.
(Warning! If template.txt does not exist the tool can't export source code.)

-Compiling an exe
First, you should export to template.cpp.
Second, open 4kgfx.sln with VisualStudio.
Finaly, you try to build the project.
(Works with vs2005/2008)

-Compiling an exe using crinkler
First, you should download crinkler [ http://www.crinkler.net/ ].
Copy crinkler to the 4kgfx.sln folder.
Second, open 4kgfx.sln with VisualStudio.
Finally, try to build with the "useCrinker" configuration.
VisualStudio will link using crinkler.
After the build compless.exe will be generated into the solution folder
(Works with Crinkler 1.1a)


-other features
Right click at main preview window.

Always On Top       -    Always on Top ;)
4:3                 -    Forces 4:3 aspect ratio when resizing.
16:9                -    Forces 16:9 aspect ratio when resizing.
16:10               -    Forces 16:10 aspect ratio when resizing.
calc RenderTime...  -    calculates render time from 10 successive renders.
Export...           -    exports to template.cpp

-Traslation support 
Vercy / Ümlaüt Design

-mail(fun and bug report)
 kioku@sys-k.net

-kioku / System K




