This is readme for the source package to the Sun Of Boc -1k intro, released
at the Assembly 2012.


Code credits:
 - Main work: Jere "XMunkki" Sanisalo
   http://www.xmunkki.org/
 - Some base code (isystem): iq / Iñigo Quílez
   http://www.iquilezles.org/
 - Some misc stuff may have been scoured from the web, apoligies if you were
   missed


License:
The license used is GPLv2 (so if you use it/modify it, you need to release the
sources as well). See LICENSE.txt for more information.


Requirements:
 - Microsoft Visual Studio 2008 Express
 - "glext.h" OpenGL extension header, found from the Internet
 - Crinkler (1.3 was used here) to compile the release version(s)
   http://crinkler.net/
 - Shader minifier if you want to change the shader in other than debug mode
   http://www.ctrl-alt-test.fr/?page_id=7
   (version used here: 1.1.1)


Information:
The intro happens mostly in the pixel shader using OpenGL/GLSL. The time is
passed down as a vertex color using glColor3us. The time is in ticks, so this
gives us 65535 ticks until it wraps and ~65 secs is enough for a small intro.
The wrap around detection is combined with the key detection by simply masking
out the lower 16 bits and combining that with the key read. The mouse cursor
is not hidden at all (it would take at least ShowCursor and PeekMessage for it
to work on Win7), it is instead moved to the top left corner with the hope no
one goes nerd rage over it.

In debug mode, the executable polls the local file "Shader.glsl". If it's
found or changed, then it will be read, compiled and if valid, set as current.
The results of the compilation are printed out as debug strings into Visual
Studios "Output" window. This gives us sub-second iteration times for the
actual effect. Pressing F2 during the debug mode resets the intro timer.
