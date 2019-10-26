####################################################
### 'kaliskop' => ...a 256 byte intro by Kuemmel ###
###             for Demosplash 2016              ###
####################################################
|                                                  |
| A reincarnation of a may be not so well know     |
| fractal formula from Kali (see the fractalforums |
| here http://www.fractalforums.com/new-theories-  |
| and-research/very-simple-formula-for-fractal-    |
| patterns/ It uses this iteration formula:        |
|                                                  |
| x = abs(x)                                       |
| y = abs(y)                                       |
| m = x*x+y*y                                      |
| x = x/m+cx                                       |
| y = y/m+cy                                       |
|                                                  |
| and some LN-colouring approach that I tuned.     |
|                                                  |
| It goes in and out the fractal set and then      |
| shifts to a deeper iteration level, looping      |
| after a minute or so. Due to the amount of       |
| computation time on old machines I used Hellmoods|
| dithering approach that simply skips 2 out of 3  |
| pixels.                                          |
|                                                  |
| As there were some bytes left I added some Midi  |
| sound that plays some disharmonious minors. Just |
| switch it off if you get annoyed ;-) It just     |
| fits the "graphical mood" somehow ;-)            |
|                                                  |
| - runs fine on WindowsXP on my Sempron 1800 MHz  |
|   laptop, runtime/midi sync optimised for Vsync  |
| - In the folder 'no_dither' I made a version that|
|   doesn't use the dithering approach but of      |
|   course needs a high spec several GHz machine   |
| - runs also on DOSBox, but a bit slow even at    |
|   full cycles                                    |
|                                                  |
| Cheers,                                          |
|                                                  |
|     Kuemmel                                      |
|                                                  |
| Special thanks to HellMood and Sensenstahl for   |
| continuous support and greetings to all the      |
| others in the tiny intro coder world !           |
|                                                  |
####################################################
### e-mail: michael.kuebel@googlemail.com        ###
### web...: www.mikusite.de                      ###
####################################################
