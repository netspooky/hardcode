;----------------------------------------------------------------------------
; MAGIC-EYE! 128 (original idea/C code by CrASH_Man) 18 Jan 2000
; Copyright (C) 2000 Barubary and CrASH_Man
;----------------------------------------------------------------------------
; Assembles with TASM.
; For the #ASM compo #3 - 128 byte demo
;
; Email: barubary@lfx.org, crashman@affinix.com

This program draws a sphere in a Magic-Eye picture - you know, those things
you're supposed to see when you cross your eyes, intentionally misfocus,
roll over, play dead, etc.  All I know is that while I (Barubary) can't see
them at all, most of the world (including CrASH_Man) can.  So good luck to
those who managed to get their eyes and this program working.  Obviously, it
was NOT me who did the testing.

The dot pattern used as the base is random.  The reason for this is that
otherwise, this program is nothing more than a compressed bitmap.

And yes, it works in NT and Win2000.

-- Barubary


NOTE: Although the resulting file is 128 bytes, it should be counted as 126.
To make the file an even 128, we moved a BSS variable into the COM file.
It's 126 simply by moving the BSS variable out of the COM file, which can be
done by anyone.



CrASH_Man wrote an optimized C program some time ago to draw these Magic Eye
things...  When a TI-82 programmer/hacker told us about the contest, we
decided to port his C program to assembly language.

At first, I wrote a minimally optimized version of his code - more or less a
direct port of the C version - while he played Beatmania on his PSX.  Then he
stopped playing (a miracle in itself) and helped me get it from about 150 to
126 (what it is now).

By far the best optimization was the implementation of the 3D distance
formula (to get the Z coordinate for the given X and Y coordinates), whose C
version he called fn().

Then we turned it in.


The original fn() is below.

int fn(int cx, int cy, int x, int y, int rad)
{
   int tx,ty,tmp;

   tx = cx-x, ty = cy-y;               // want 0-47 here

   tmp = rad*rad - tx*tx - ty*ty;

   if (tmp < 0)                        // 0 if outside sphere
      return 0;
   else
      return ((int) sqrt((double) tmp)) >> DEPTH;
}

Implementing this in a small space looks quite nasty because of how all the
registers need to move around, and the reverse subtractions (constant - reg).
Note that cx and cy are actually constants, as is rad.  The solution I came
up with was to calculate everything in their negative form.  This was a huge
optimization, because now the annoying reverse subtractions weren't
necessary.

It's fairly obvious that tx and ty can be calculated in their negative form,
because you square them anyway.  This is in fact an advantage, as using IMUL
is easier than MUL - any source, any target.  So now we have a positive,
squared tx and ty.

Now for tmp.  The natural way would be to calculate (tx*tx + ty*ty) then
subtract it from rad.  This is a pain in the ass, because it's reverse
subtraction.  Here we go again: calculate tmp negative as well.  Now you just
add tx*tx and ty*ty, and subtract rad*rad (a constant, so the assembler can
square it at compile time).

Now we go to the square root phase.  We have 2 problems here:
1. Our tmp from above is the negative of what we want to square root.
2. We must handle the case where the "true" tmp is negative - which occurs
   when we're "outside" the sphere.

It turns out that the same negativity helps us AGAIN, here to avoid the
"required" compare against 0.  The trick here is simple.  We want to convert
negative tmp's (positive of what we have currently) into 0 so we don't get a
floating point exception (which gives us the weird value 8000 later).  The
solution is to copy the "sign" bit of -tmp into all the other bits, then AND
it with -tmp.  If -tmp is positive (tmp negative), then this results in our
mask being 0000 - ANDing gets us to the desired value 0.  If -tmp is negative
(tmp positive), the mask is FFFF, and ANDing with it does nothing, leaving
our value alone.  Finally, we NEG -tmp, to get a desirable value for square
root.

The original implementation of the mask stuff was this:

mov dx, ax
sar dx, 15    // copy sign bit of dx into all bits of dx; makes FFFF or 0000
and ax, dx

CrASH_Man saw a nice way to handle this in 1 byte instead of 7 - our friend
CWD.  CWD does the same thing as all 7 bytes above (minus flags, which we
don't care about here) - in 1 byte.

Next comes the floating point crap to do the square root, which, as you might
guess, can't be optimized, unless you find some other way to square root in
under 13 bytes.

The complete fn() assembly code is:

    mov     ax, cx                      ; ty (note: negative from C code)
    lea     dx, [bx-CENTER_X-PERIOD]    ; tx (negative); -PERIOD for x2
    imul    ax, ax                      ; Signed-squaring removes negatives
    imul    dx, dx                      ;

    add     ax, dx                      ; tmp
    sub     ax, RADIUS * RADIUS         ; ax = -tmp now

                                        ; Masking (to prevent sqrt of negs)
    cwd                                 ; If tmp positive (ax neg), dx=FFFF
    and     ax, dx                      ; Zero if tmp is negative
    neg     ax                          ; Need tmp, not -tmp

    mov     [sqrt_temp], ax             ; Square root
    fild    word ptr [sqrt_temp]        ;
    fsqrt                               ;
    fistp   word ptr [sqrt_temp]        ;
    mov     si, [sqrt_temp]             ;

    shr     si, DEPTH                   ; Divide by 4 (end fn())
