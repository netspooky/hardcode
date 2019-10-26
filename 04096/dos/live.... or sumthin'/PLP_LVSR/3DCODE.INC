; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Return the sine and cosine of an angle as 18.14 fixed
;
;  Input:
;      AX - Angle (0-65534)
;
;  Returns:
;      ECX - Sine(angle) as 18.14 fixed
;      EDX - Cosine(angle) as 18.14 fixed
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Returns the sine and cosine of an angle as 18.14 fixed number.
; Uses the sineTable we calculated before.

; Angles are between 0 and 65535. This allows very accurate values
; to be returned (although internally this only uses angles 0-1024).


PROC getSinCos

        mov     bx,ax                   ; Get sin(angle)
        shr     bx,6
        shl     bx,2

        mov     ecx,[DWORD bx+sincosTable]

        mov     bx,16384                ; cos(angle) = sin(pi/2 - angle)
        sub     bx,ax
        shr     bx,6
        shl     bx,2

        mov     edx,[DWORD bx+sincosTable]

        ret

ENDP



; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Calculate matrix
;
;  Input:
;      rotX/Y/Z - Angles of rotation
;      DI       - Destination offset
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Calculates a matrix. Tha calculated matrix can then be used to rotate
; verteces very fast, since all the verteces can be rotated with the
; same matrix (as long as the rotation-angles stay the same).

; This routine requires the rotation angles to be given as memory-
; variables rotX/Y/Z. The angles are WORDs and between 0 and 65535.


PROC calculateMatrix

        push    di                      ; Save destination ptr

        mov     ax,[rotX]

        call    getSinCos               ; Get sin(rotX) & cos(rotX)
        mov     esi,ecx
        mov     [cos_x],edx

        mov     ax,[rotY]

        call    getSinCos               ; Get sin(rotY) & cos(rotY)
        push    ecx                     ; Save sin(rotY)
        mov     ebp,edx

        mov     ax,[rotZ]

        call    getSinCos               ; Get sin(rotZ) & cos(rotZ)
        mov     [sin_z],ecx

        pop     ebx                     ; Restore sin(rotY)
        mov     cl,14                   ; Fixed point decimals
        mov     di,OFFSET sinz_cosx     ; Destination offset

        mov     eax,[sin_z]             ; sin_z * cos_x
        imul    eax,[cos_x]
        sar     eax,cl
        stosd
	
        mov     eax,edx                 ; cos_z * sin_x
        imul    eax,esi
        sar     eax,cl
        stosd
	
        mov     eax,edx                 ; cos_z * cos_x
        imul    eax,[cos_x]
        sar     eax,cl
        stosd
	
        mov     eax,[sin_z]             ; sin_z * sin_x
        imul    eax,esi
        sar     eax,cl
        stosd

        pop     di                      ; Restore destination ptr

        mov     eax,edx                 ; m0 = cos_z * cos_y
        imul    eax,ebp
        sar     eax,cl
        stosd

        mov     eax,[sin_z]             ; m1 = -sin_z * cos_y
        imul    eax,ebp
        sar     eax,cl
        neg     eax
        stosd

        mov     eax,ebx                 ; m2 = sin(rotY)
        stosd

        mov     eax,[cosz_sinx]         ; m3 = sin_z * cos_x +
        imul    eax,ebx                 ;      cos_z * sin_x * sin_y
        sar     eax,cl
        add     eax,[sinz_cosx]
        stosd

        mov     eax,[sinz_sinx]         ; m4 = cos_z * cos_x -
        imul    eax,ebx                 ;      sin_z * sin_x * sin_y
        sar     eax,cl
        neg     eax
        add     eax,[cosz_cosx]
        stosd
	
        mov     eax,ebp                 ; m5 = -cos_y * sin_x
        imul    eax,esi
        sar     eax,cl
        neg     eax
        stosd

        mov     eax,[cosz_cosx]         ; m6 = sin_z * sin_x -
        imul    eax,ebx                 ;      cos_z * cos_x * sin_y
        sar     eax,cl
        neg     eax
        add     eax,[sinz_sinx]
        stosd

        mov     eax,[sinz_cosx]         ; m7 = cos_z * sin_x +
        imul    eax,ebx                 ;      sin_z * cos_x * sin_y
        sar     eax,cl
        add     eax,[cosz_sinx]
        stosd

        mov     eax,ebp                 ; m8 = cos_y * cos_x
        imul    eax,[cos_x]
        sar     eax,cl
        stosd

        ret

ENDP



; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Rotate one vertex (no projection)
;
;  Input:
;      AX - Pointer to the matrix
;      SI - Pointer to 3 WORDs (x, y, z)
;      DI - Pointer to 3 WORDs (destination x, y, z)
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; This subroutine rotates one vertex. The matrix must be calculated first
; using the correct rotX/Y/Z -values. Before calling this, SI must
; point to three words (x/y/z) that will be used as the source coordinates.
; DI must point to destination.

; This routine will NOT project the coordinates to the screen.


PROC rotateVertex

        push    di                      ; Save destination ptr

        movsx   ebx,[WORD si]           ; Move x to ebx
        movsx   ecx,[WORD si+2]         ; Move y to ecx
        movsx   edx,[WORD si+4]         ; Move z to edx

        mov     si,ax                   ; Source offset of the matrix
        mov     di,OFFSET newX          ; Temporary destination ptr
        mov     [BYTE count],3          ; Loopcounter


; Rotate all three coordinates (x/y/z) in a loop ----------------------------

; x' = m0 * x + m1 * y + m2 * z
; y' = m3 * x + m4 * y + m5 * z
; z' = m6 * x + m7 * y + m8 * z

@@rotate_loop:
        lodsd                           ; Load next value from the matrix
        imul    eax,ebx                 ; Multiply with x
        mov     ebp,eax

        lodsd                           ; Load next value from the matrix
        imul    eax,ecx                 ; Multiply with y
        add     ebp,eax

        lodsd                           ; Load next value from the matrix
        imul    eax,edx                 ; Multiply with z
        add     eax,ebp

        stosd                           ; Store rotated coordinate

        dec     [BYTE count]            ; Loop
        jnz     @@rotate_loop


; Store rotated coordinates -------------------------------------------------

        pop     di                      ; Restore destination ptr
        mov     si,OFFSET newX          ; Source offset
        mov     cx,3                    ; Load & store 3 coords (x/y/z)

@@loop:
        lodsd                           ; Load rotated coordinate
        sar     eax,14                  ; Loose the decimals
        stosw                           ; Store it

        loop    @@loop                  ; Loop

        ret

ENDP



; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Rotate and project one vertex
;
;  Input:
;      AX - Pointer to the matrix
;      SI - Pointer to 3 WORDs (x, y, z)
;      DI - Pointer to 3 WORDs (destination x, y, z)
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; This routine first rotates the vertex using the previous routine.
; After rotation it will project the vertex to screen coordinates.

; The amount of perspective depends on a combination of the define
; OBJECT_SIZE and the memoryvariable distance.

; Incorrect x/y-ratio will also be corrected.


PROC rotateProjectVertex


; Rotate vertex -------------------------------------------------------------

        push    di                      ; Save destination ptr

        call    rotateVertex            ; Rotate


; Calculate perspective and convert to screen coordinates -------------------

        pop     di                      ; Restore destination ptr

        mov     ecx,[newZ]              ; z' = (z' + distance) / size
        add     ecx,[distance]
        sar     ecx,OBJECT_SIZE

        mov     eax,[newX]              ; x' = x' / z' + centerX
        cdq
        idiv    ecx

        imul    eax,XY_RATIO            ; Fix the x/y-ratio
        sar     eax,16                  ; Loose the decimals

        add     ax,[centerX]            ; Center the object
        stosw                           ; Store new x

        mov     eax,[newY]              ; y' = y' / z' + centerY
        cdq
        idiv    ecx
        add     ax,[centerY]            ; Center the object
        stosw                           ; Store new y

        mov     eax,[newZ]              ; Store new z
        shr     eax,(14-OBJECT_SIZE)
        stosw

        ret

ENDP



; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Draw a filled polygon
;
;  Input:
;      AL - Color
;      BX - Pointer to vertex 1 (3 x WORD)
;      SI - Pointer to vertex 2 (3 x WORD)
;      DI - Pointer to vertex 3 (3 x WORD)
;      ES - Segment to draw to
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; A nice routine that draws one filled triangle. The order of verteces
; doesn't matter before calling.

; This routine does not use the common edgebuffer. Instead the x-coordinates
; for every scanline are calculated on-the-fly as we go downwards.
; The triangle is drawn in two halves. The first section ends (and the
; next starts) at y2 (if y2 is vertically the in the middle).

; Full clipping is also implemented.

;        + (x1,y1)
;        |\
;        | \  <- First section
; (x2,y2)|  \
;    ....+...\.....
;         \_  \
;           \_ \  <- 2nd section
;             \_\
;               \\
;                -+ (x3,y3)


; NOTE! This routine does NOT destroy any registers!
; ==================================================


PROC drawPoly


; Sort verteces to acending order (by y-coordinates) ------------------------

        pushad                          ; Save all registers

        mov     bp,ax                   ; Save the color

        mov     ax,[bx+2]               ; Compare verteces 1 & 2
        cmp     ax,[si+2]
        jle     @@noxchg1

        xchg    bx,si                   ; Swap if y1 > y2

@@noxchg1:
        mov     ax,[bx+2]               ; Compare verteces 1 & 3
        cmp     ax,[di+2]
        jle     @@noxchg2

        xchg    bx,di                   ; Swap if y1 > y3

@@noxchg2:
        mov     ax,[si+2]               ; Compare verteces 2 & 3
        cmp     ax,[di+2]
        jle     @@noxchg3

        xchg    si,di                   ; Swap if y2 > y3

@@noxchg3:


; Calculate all deltas ------------------------------------------------------

        call    @@calc_delta            ; Calculate delta (verteces 1 & 2)

        mov     [delta2],eax            ; Store delta
        mov     [polyHeight],cx         ; Save height

        xchg    di,si                   ; Next delta


; After the xchg:
;    bx - vertex 1
;    si - vertex 3
;    di - vertex 2


        call    @@calc_delta            ; Calculate delta (verteces 1 & 3)

        cmp     cx,0                    ; Check the height
        je      @@quit                  ; Height of the poly 0 -> Quit

        mov     [delta1],eax            ; Store delta

        xchg    bx,di                   ; Next delta


; After the xchg:
;    bx - vertex 2
;    si - vertex 3
;    di - vertex 1


        call    @@calc_delta            ; Calculate delta (verteces 2 & 3)

        mov     [delta3],eax            ; Store delta
        mov     [polyHeight2],cx        ; Save height


; Initialize variables and draw ---------------------------------------------

; First section is the part of the triangle between y1 and y2 (upper half)
; and the second section is between y2 and y3 (lower half)

        mov     ax,bp                   ; Restore color

        mov     bp,[di+2]               ; Initial y-coordinate
        mov     si,bp
        imul    bp,BUFFER_WIDTH         ; Offset to the start of the row

        mov     dx,[bx]                 ; Store initial x-coordinates
        shl     edx,16                  ; in 16.16 fixed to ebx & edx
        mov     bx,[di]                 ; (this is actually for the case
        shl     ebx,16                  ;  that there's no 1st section)

        cmp     [polyHeight],0          ; Check the height of this section
        je      @@next_section          ; Was 0 -> No 1st section

        mov     edx,ebx                 ; Fix initial x-coords

        call    @@outer_loop            ; Draw the first section

@@next_section:
        mov     ecx,[delta3]            ; Lower section uses delta3
        mov     [delta2],ecx            ; (delta1 remains the same)

        mov     cx,[polyHeight2]        ; Get the height of this section

        cmp     cx,0                    ; Height 0 -> Quit
        je      @@quit

        mov     [polyHeight],cx         ; Store height

        call    @@outer_loop            ; Draw the 2nd section

@@quit:
        popad                           ; Restore all registers

        ret


; Outer loop (draws one section of the triangle) ----------------------------

; This handy loop draws one section of the triangle. The height
; of the section must be stored in polyHeight memoryvariable.

; Both left- and right-side deltas must be constant through
; the whole section (that's why we'll have to draw two sections).

; This loop uses the following registers:

;    AL  - Color

;    EBX - 1st x-coordinate as 16.16 fixed (deltas are added to these)
;    EDX - 2nd x-coordinate as 16.16 fixed

;    CX  - 1st temporary x-coordinate as integer
;    DI  - 2nd temporary x-coordinate as integer

;    SI  - current y-coordinate as integer (used for clipping)
;    BP  - offset to the start of the current scanline


@@outer_loop:
        cmp     si,YMAX                 ; Vertical clipping needed?
        ja      @@next_scanline         ; Yepp -> Don't draw this scanline

        mov     ecx,edx                 ; Get 1st x-coordinate
        shr     ecx,16                  ; Loose the decimals

        mov     edi,ebx                 ; Get 2nd x-coordinate
        shr     edi,16                  ; Loose the decimals

        cmp     di,cx                   ; Is di the leftmost coordinate?
        jl      @@noxchg

        xchg    cx,di                   ; Nope -> Swap x-coordinates

@@noxchg:
        cmp     di,0                    ; Left clipping needed?
        jg      @@no_left_clip

        xor     di,di                   ; Yes -> Clip

@@no_left_clip:
        cmp     cx,XMAX                 ; Right clip needed?
        jl      @@no_right_clip

        mov     cx,XMAX                 ; Yes -> Clip

@@no_right_clip:
        sub     cx,di                   ; Width of the scanline
        inc     cx
        js      @@next_scanline         ; Completely out of the screen?

        add     di,bp                   ; Initial offset

        rep stosb                       ; Draw the scanline

@@next_scanline:
        add     bp,BUFFER_WIDTH         ; Next scanline
        inc     si

        add     ebx,[delta1]            ; Add deltas to x-coordinates
        add     edx,[delta2]

        dec     [polyHeight]            ; Loop polyHeight times
        jnz     @@outer_loop

        ret


; Calculate one delta -------------------------------------------------------

; Input: bx & si - Pointers to the verteces
; Returns delta y in cx and delta x / delta y in eax (16.16 fixed)

@@calc_delta:
        mov     cx,[si+2]               ; cx = delta y
        sub     cx,[bx+2]

        jz      @@cd_quit               ; Divisor 0 -> Return

        mov     ax,[si]                 ; ax = delta x
        sub     ax,[bx]

        movsx   ecx,cx                  ; Prepare for a 16.16 division
        shl     eax,16
        cdq

        idiv    ecx                     ; eax = delta x / delta y

@@cd_quit:
        ret

ENDP



; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Draw one 3D-box
;
;  Input:
;      SI - Pointer to the boxdata
;      ES - Segment to draw to
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; This routine draws one 3D-box. SI must point to the box-data,
; which looks like (all numbers are bytes):

;     width, height, depth, xrot, yrot, xpos, ypos, zpos, color

; where width, height and depth are the dimensions of the box,
; x/yrot give the direction (zrot is always 0) and x/y/zpos
; define the position.

; First the routine will generate the 8 verteces required for the box
; using the known dimensions. Then the box will be rotated using
; the values found from the data and moved to it's own position.

; After that the camera will be rotated (actually we'll just rotate
; the box to the other direction....)

; The 8 verteces are ordered as follows:

;        5       6
;         +-------+
;         |\      .\          Height
;         | +-------+           |
;         | |1    . |2   Width  |
;        8| |    7. |        ---+
;         +.|.....+ |            \
;          \|      \|             \
;           +-------+            Depth
;            4       3


PROC drawBox

        push    es                      ; Save destination segment

        push    cs                      ; ES = CS (ES is needed for the
        pop     es                      ; variables that are in CS)


; Create all 8 verteces for the box from the known dimensions ---------------

        xor     ax,ax                   ; Empty the upper byte
        lodsb                           ; Get the width of the box

        mov     [boxX2],ax              ; Store right side x-coordinates
        mov     [boxX3],ax
        mov     [boxX6],ax
        mov     [boxX7],ax

        neg     ax

        mov     [boxX1],ax              ; Store left side x-coordinates
        mov     [boxX4],ax
        mov     [boxX5],ax
        mov     [boxX8],ax

        xor     ax,ax                   ; Empty the upper byte
        lodsb                           ; Get the height of the box

        mov     [boxY1],ax              ; Store upper y-coordinates
        mov     [boxY2],ax
        mov     [boxY5],ax
        mov     [boxY6],ax

        neg     ax

        mov     [boxY3],ax              ; Store lower y-coordinates
        mov     [boxY4],ax
        mov     [boxY7],ax
        mov     [boxY8],ax

        xor     ax,ax                   ; Empty the upper byte
        lodsb                           ; Get the depth of the box

        neg     ax

        mov     [boxZ5],ax              ; Store backside z-coordinates
        mov     [boxZ6],ax
        mov     [boxZ7],ax
        mov     [boxZ8],ax

        neg     ax

        mov     [boxZ1],ax              ; Store frontside z-coordinates
        mov     [boxZ2],ax
        mov     [boxZ3],ax
        mov     [boxZ4],ax


; Rotate the box around it's center -----------------------------------------

        xor     ax,ax                   ; Empty the upper byte
        mov     di,OFFSET rotX          ; Destination offset

        lodsb                           ; Get x-rotation angle
        shl     ax,8                    ; Convert 8bit angle -> 16bit angle
        stosw                           ; Store angle

        lodsb                           ; Get y-rotation angle
        shl     ax,8                    ; Convert 8bit angle -> 16bit angle
        stosw                           ; Store angle

        stosb                           ; z-rotation angle is always 0
        stosb                           ; (al will be zero after shl ax,8)

        push    si                      ; Save pointer to the box-data

        mov     di,OFFSET matrix        ; Destination offset for the matrix
        call    calculateMatrix         ; Calculate the matrix

        mov     di,OFFSET boxX1         ; Initial offset
        mov     [count2],8              ; Loopcounter

@@loop1:
        mov     si,di                   ; Source and dest. are the same
        mov     ax,OFFSET matrix        ; Offset of the matrix to use

        call    rotateVertex            ; Rotate one vertex

        dec     [count2]                ; Loop through all 8 verteces
        jnz     @@loop1


; Move rotated box to the right position ------------------------------------

        pop     si                      ; Restore the ptr to the box-data

        lodsb                           ; Get x-position
        movsx   dx,al
        add     dx,dx

        lodsb                           ; Get y-position
        movsx   bx,al
        add     bx,bx

        lodsb                           ; Get z-position
        movsx   ax,al
        add     ax,ax

        sub     ax,[cameraHeight]       ; Subtract the height of the camera

        mov     di,OFFSET boxX1         ; Start from here
        mov     cx,8                    ; Loop through 8 verteces

@@loop2:
        add     [di],dx                 ; Add coordinates (x/y/z)
        add     [di+2],bx
        add     [di+4],ax

        add     di,6                    ; Advance pointer

        loop    @@loop2                 ; Loop


; Rotate camera (actually the box to the other direction) -------------------

        push    si                      ; Save the ptr to the box-data

        mov     di,OFFSET boxX1         ; Initial source for rotation
        mov     [count2],8              ; Loopcounter

@@loop3:
        mov     si,di                   ; Source and dest. are the same
        mov     ax,OFFSET cameraMatrix  ; Offset of the camera's matrix

        call    rotateProjectVertex     ; Rotate & prject one vertex

        dec     [count2]                ; Loop through all 8 verteces
        jnz     @@loop3


; Draw all 6 sides (12 faces) of the box ------------------------------------

; Since all 12 faces are drawn with the same color, we don't have to care
; about sorting the faces. It will look just the same with or without it.

; I could have done a loop here, but I'm relying the compression
; to take care of the 12 calls to drawPoly.


        pop     si                      ; Restore the ptr to the box-data
        pop     es                      ; Restore destination segment

        lodsb                           ; Get the color of the box

        mov     bx,OFFSET boxX1         ; Load the coords of the first
        mov     si,OFFSET boxX2         ; face
        mov     di,OFFSET boxX3

; BX - vertex 1
; SI - vertex 2
; DI - vertex 3

        call    drawPoly                ; Draw face #1

        mov     di,OFFSET boxX6

; BX - vertex 1
; SI - vertex 2
; DI - vertex 6

        call    drawPoly                ; Draw face #2

        mov     bx,OFFSET boxX3

; BX - vertex 3
; SI - vertex 2
; DI - vertex 6

        call    drawPoly                ; Draw face #3

        mov     si,OFFSET boxX7

; BX - vertex 3
; SI - vertex 7
; DI - vertex 6

        call    drawPoly                ; Draw face #4

        mov     di,OFFSET boxX4

; BX - vertex 3
; SI - vertex 7
; DI - vertex 4

        call    drawPoly                ; Draw face #5

        mov     si,OFFSET boxX1

; BX - vertex 3
; SI - vertex 1
; DI - vertex 4

        call    drawPoly                ; Draw face #6

        mov     bx,OFFSET boxX8

; BX - vertex 8
; SI - vertex 1
; DI - vertex 4

        call    drawPoly                ; Draw face #7

        mov     si,OFFSET boxX7

; BX - vertex 8
; SI - vertex 7
; DI - vertex 4

        call    drawPoly                ; Draw face #8

        mov     di,OFFSET boxX5

; BX - vertex 8
; SI - vertex 7
; DI - vertex 5

        call    drawPoly                ; Draw face #9

        mov     bx,OFFSET boxX6

; BX - vertex 6
; SI - vertex 7
; DI - vertex 5

        call    drawPoly                ; Draw face #10

        mov     si,OFFSET boxX1

; BX - vertex 6
; SI - vertex 1
; DI - vertex 5

        call    drawPoly                ; Draw face #11

        mov     bx,OFFSET boxX8

; BX - vertex 8
; SI - vertex 1
; DI - vertex 5

        call    drawPoly                ; Draw face #12


@@quit:
        ret

ENDP



; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Sort an array (bidirectional bubblesort)
;
;  Input:
;      SI - Pointer to the array
;      CX - Lenght of the array
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Sorts an array consisting of depths and indexes. The array must be
; ordered as follows:

;     depth, index, depth, index ...   (all numbers are WORDs)

; where depth is the number to be sorted and index is just any number
; (I'm using it to point to the right box in box-data).

; The algorithm used here is called "bidirectional bubblesort".
; The difference between this and the traditional bubblesort is
; that every other scan will be from beginning to the end, and every
; other from the end to the beginning (like a ping-pong ball).
; Traditional bubblesort only goes one way.

; While being significanly faster than the normal bubblesort,
; it's still awfully slow compared to quick- and radix-sorts.

; So why I am using it? Since it's a very short algorithm.
; (My _extremely_ fast radix-sort is about 5 times bigger....)


PROC bubbleSort

        dec     cx                      ; Save the loopcounter
        mov     bp,cx

        xor     dl,dl                   ; Clear the flag
        mov     di,4                    ; Start by going forward

@@loop:
        mov     eax,[si]                ; Get both depth and index

        cmp     ax,[si+4]               ; Compare to the next depth
        jge     @@noswap                ; Greater already -> Don't swap

        xchg    eax,[si+4]              ; Swap both depth and index
        mov     [si],eax

        mov     dl,1                    ; Raise the flag

@@noswap:
        add     si,di                   ; Next depth and index

        dec     cx                      ; Loop through the array
        jnz     @@loop

        mov     cx,bp                   ; Restore the loopcounter

        sub     si,di                   ; Fix the pointer
        neg     di                      ; Change the direction

        dec     dl                      ; Clear the flag and compare
        jz      @@loop                  ; Flag was 1 -> Loop again

        ret

ENDP



; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Draw a 3D-scene made out of Legos(tm).... oops, meant boxes.
;
;  Input:
;      SI - Offset to the scenedata
;      ES - Segment to draw to
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


PROC draw3DScene

        mov     bx,si                   ; Save source offset
        push    es                      ; Save destination segment

        push    cs                      ; ES has to point to the codesegment
        pop     es                      ; for now (because of the stosw's)


; Rotate all boxes for sorting ----------------------------------------------

; First we'll get the position (x/y/z) of a box. Then it will be
; rotated with the camera's matrix. Then the rotated z-coordinate
; will be put into an array along with the number of the box
; for depth-sorting. This will be done for all the boxes in da scene.


        mov     cx,[si]                 ; Get number of boxes (loopcounter)

        add     si,7                    ; Point SI to first box'es position
        mov     bp,OFFSET sortArray     ; Array for sorting
        xor     dx,dx                   ; Initial index (number of the box)

@@store:
        mov     di,OFFSET tempX         ; Store coordinates temporarily here

        lodsb                           ; Get x-coordinate
        cbw                             ; Convert BYTE -> WORD
        stosw                           ; Store 16bit coordinate

        lodsb                           ; Get y-coordinate
        cbw                             ; Convert BYTE -> WORD
        stosw                           ; Store 16bit coordinate

        lodsb                           ; Get z-coordinate
        cbw                             ; Convert BYTE -> WORD
        stosw                           ; Store 16bit coordinate

        pusha                           ; Save regs

        mov     ax,OFFSET cameraMatrix  ; Matrix of the camera
        mov     si,OFFSET tempX         ; Pointer to the vertex
        mov     di,si                   ; Source and dest. are the same

        call    rotateVertex            ; Rotate vertex (position of the box)

        popa                            ; Restore regs

        mov     ax,[tempZ]              ; Get rotated z for sorting
        mov     [bp],ax                 ; Store z-coordinate to the array
        mov     [bp+2],dx               ; Store the boxnumber (index)

        inc     dx                      ; Advance index
        add     bp,4                    ; Advance the arraypointer
        add     si,6                    ; Next position in scenedata

        loop    @@store                 ; Loop through all boxes in da scene


; Perform depth-sorting -----------------------------------------------------

        mov     si,OFFSET sortArray     ; Offset to the array to sort
        mov     cx,[bx]                 ; Number of items to sort

        pusha                           ; Save all registers

        call    bubbleSort              ; Sort the array (box z-coordinates)

        popa                            ; Restore registers


; Draw the scene ------------------------------------------------------------

; This part will draw all the boxes in order of their z-coordinates.

        pop     es                      ; Restore destination segment

        mov     di,si                   ; Pointer to the sorted array
        add     bx,2                    ; Offset to the first box in da scene

@@draw:
        movsx   eax,[WORD di]           ; Get z-coordinate of the box

        shl     eax,14                  ; Add distance to it
        add     eax,[distance]
        sar     eax,14

        cmp     ax,Z_CLIP               ; Z-clipping needed?
        jl      @@quit                  ; Yes -> Discard rest of the boxes

        mov     si,[di+2]               ; Get the index of the box to draw

        imul    si,9                    ; Each box is 9 bytes
        add     si,bx                   ; si = Offset to the box to draw

        pusha                           ; Save all regs

        call    drawBox                 ; Draw one box

        popa                            ; Restore regs
        add     di,4                    ; Next index from the array

        loop    @@draw                  ; Loop through all boxes

@@quit:
        ret

ENDP



