"Pop Shades 15b" by HellMood / DESiRE

the idea is to use image data as VGA
palette entries (subfunction 1012h)
stosb + stosw creates a 3 byte pattern
"0,x,x" which shifts to "x,0,x" and
"x,x,0" because 65536 mod 3 != 0
thus, creating shades of cyan, yellow
and magenta, similar to popart colors.


Tested to work with DosBox 0.74, i got
slightly varying results on WinXP, and
also for Oracle Virtual Box (MSDOS 6.22)

Youtube : 
https://www.youtube.com/watch?v=rGTsHjGI5iw

