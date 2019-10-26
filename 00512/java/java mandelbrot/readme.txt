Java Mandelbrot

My goal was to write a gamma corrected mandelbrot under 512 bytes.
Not only the jar should have 512, but the jar+html should be <512.

Some heavy optimization was required, the src was written in bytecode,
also made some tweaking on the jar file. It is not a valid zip anymore,
but works fine as a jar.

Tested under WinXP, using appletviewer | firefox | IE.

F:      451 bytes   (the jar file)
F.html:  45 bytes   (the html file)

total:  506 bytes

Written by ricbit (Ricardo Bittencourt), 2006.6.13
ricbit@700km.com.br / http://www.700km.com.br/mundobizarro

Thanks to girino for his help.
