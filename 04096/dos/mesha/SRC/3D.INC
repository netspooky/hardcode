;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
;
; micro 3D                                                   by Picard 1998 (c)
;
;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北

ZBUF_SIZE       EQU             20000h

STRUC tFace                    ; 16 bytes
  pa            dd @0           ; vertex pointers
  pb            dd @0           ;
  pc            dd @0           ;
  pd            dd @0           ; (or 0)
ENDS

STRUC tVertex                   ; 64 bytes
  x             dd @0
  y             dd @0
  z             dd @0
  nx            dd @0
  ny            dd @0
  nz            dd @0
  tx            dd @0
  ty            dd @0
  yy            dd @0
  xx            dd @0
  dist          dd @0
  col           dd @0
  gentx         dd @0
  genty         dd @0
  yy2           dd @0
  xx2           dd @0
ENDS

STRUC tModel                    ; 16 bytes
  VertexStart   dd @0            ; pointer to start Vertex
  FaceStart     dd @0            ; pointer to start Face
  VertexEnd     dd @0            ; pointer to end Vertex+1
  FaceEnd       dd @0            ; pointer to end Face+1
ENDS

STRUC tProcess
  Object        dd @0            ;*
  Delay         dd @0            ;*
  No            dd @0            ;*
  Data          dd @0            ;*
ENDS

STRUC tObject                   ;* CalcMatrix useses this order
  Size          dd @0
  Dir           dd 3 dup (@0)
  Pos           dd 3 dup (@0)
  Ofs           dd 3 dup (@0)
  dDir          dd 3 dup (@0)
  dPos          dd 3 dup (@0)
  dOfs          dd 3 dup (@0)

  Temp          db 128 - 76 dup (@0)
ENDS

