# MZESOLVR
*Maze Solver*
A 256-byte MS-DOS demo by ERN0 - 2016.10.03
Released at Function Party, 2017

## This is also not a 256-byte demo

As I said before, I am not a math expert, so I have to find simple
problems, if I want to make 256-byte demos. And I wanted.

The code is lack of tricks, and well-commented, so anyone without math
skills may understand it.

## The idea

This demo is inspired by the article "[Maze Generation In Thirteen
Bytes](https://trixter.oldskool.org/2012/12/17/maze-generation-in-thirteen-bytes/)",
where folks come out shorter and shorter solutions to draw a maze. The
maze generation is based on a well-known trick: randomly printing '/'
(slash) and '\\' (backslash) characters results a quite nice maze. On
VGA 256-color mode it looks like:
![maze](https://trixter.files.wordpress.com/2012/12/10print6_002.png)

If the maze drawing code is only some bytes long, we have lot of space
for the solver!

## The maze

The maze must be the same, every time the program starts. It can be
achieved by using a pseudo-random number generator, starting from the
same seed, or, which I choose, using program code: `0` bit means slash,
`1` bit means backslash (or reverse). The demo uses 320x200 pixel VGA
resolution, which is 40x25 = 1000 characters. The 256 byte of program
code contains 256 * 8 = 2048 bits, which is far enough.

Fortunatelly, the slash and the backslash characters look very
homogenous in this resolution, so simple BIOS print function can be
called. There's only one minor glitch: as you see in demo, and also on
the image (which I ripped off the article, but it has the same issue),
the right bottom part of the screen is empty. This is because if you
print a character at the last position of the screen, it occurs
scrolling. So, actually the maze is one byte (8 character) shorter than
40x25. It should be solved by copying some area to the screen, but it
requires lot of code (in terms of a 256-byte demo).

## The solver

In the first version of the demo, there were 4 dots hanging in the
maze, starting at different positions. It was too bare, 2x2 dots look
very poor in a 320x200 arena. So, I've changed it to a single point,
and the space I gained, I spent on a ringbuffer implementation. It
holds previous positions, so the pixel drawn by the solver routine will
be erased only several frames later - that's how the snake works.

As the walls are built from 45&deg; rotated elements, the solver
follows this coordinate system: "up-right" is the new "up" and so on,
as described in the comment:

````
;     left    up
;         \  /
;         (X)
;        /  \
;    down   right
````

The dot (snake head) has an actual position and direction. In each
frame, new direction, then new position gets calculated. The snake goes
foward until hits the wall, then tries to turn right, then left, and
the last, back. The offset values for collision checks and position
changes are stored in this table:

````
;                            left  up right down
t_lt:   dw CLT,DLT,t_lt  ;    X
t_up:   dw CUP,DUP,t_up  ;    X    X
t_rt:   dw CRT,DRT,t_rt  ;    -    X    X
t_dn:   dw CDN,DDN,t_dn  ;    X    -    X    X
        dw CLT,DLT,t_lt  ;    -    X    -    X
        dw CUP,DUP,t_up  ;    -    -    X    -
        dw CRT,DRT,t_rt  ;    X    -    -    X
        dw CDN,DDN,t_dn  ;         X    -    -
        dw CLT,DLT,t_lt  ;              X    -
        dw CUP,DUP,t_up  ;                   X
````

This is a combined table for the four directions. The "entry point" of
the table is the actual direction (see labels). Then the following
indexes should be used: 0, 1, 3, 6. For example, if the current
direction is right (`t_rt`), the following directions will be the
candidates for the new direction (stop at first match): right (keep
direction), down, up, left.

The snake has a start position at the border, then walks into the maze,
and finally quits at the bottom right corner. The start point is
declared, but maze itself is kinda random, as it comes from the code. I
was just lucky to get such an interesting and long open path.

## Compile and run

### Compile
I've used [FASM](https://flatassembler.net/):
`fasm mzesolvr.asm mzesolvr.com`

### Run

It's pure 80286 code, it can be run in [DOSBox](http://www.dosbox.com/).
