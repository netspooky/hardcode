; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; **                      Routines for memory usage.                       ** 
; **                      Alain BROBECKER, aka Baah.                       ** 
; **                              June 1995.                               **  
; **                                                                       **
; ***************************************************************************
; ***************************************************************************


; ***************************************************************************
MEMLIB                  SEGMENT USE16                     
                        Assume CS:MEMLIB

;==== Main Memory release ===================================================
; Must be called first in the proggy.
; es must points on the beginning of psp.
main_memory_release     PROC FAR
  push      ax
  push      bx
  mov       bx,ss                   ; Calculate the size between the end of 
  mov       ax,es                   ; stack and the beginning of psp.
  sub       bx,ax
  mov       ax,sp                   ; Calculate end of stack.
  shr       ax,4
  inc       ax                      ; In case stack is not a multiple of 16.
  add       bx,ax                   ; Here bx=size of proggy/16.
  mov       ah,4ah                  ; Allocated memory modify function.
  int       21h
  jNC       @@main_memrelease_ok    ; If carry=0, all is ok. 
; If an error has occured, display message and quit.
  mov       ax,cs
  mov       ds,ax
  mov       dx,offset cs:@@main_memrelease_msg 
  mov       ah,09h                  ; Print string function.
  int       21h                     
  mov       ah,4ch                  ; Quit the proggy.
  int       21h                    
@@main_memrelease_msg:
  db  'Error in main memory release.',13,10,'$' 
@@main_memrelease_ok:
  pop       bx
  pop       ax
  ret
main_memory_release     ENDP
;============================================================================



;==== Allocate Memory =======================================================
; bx=size to allocate/16.
; Returns ax=segment of allocated memory.
allocate_memory         PROC FAR
  mov       ah,48h
  int       21h
  jNC       @@memalloc_ok           ; If carry=0, all is ok. 
; If an error has occured, display message and quit.
  mov       ax,cs
  mov       ds,ax
  mov       dx,offset cs:@@memalloc_errormsg 
  mov       ah,09h                  ; Print string function.
  int       21h                     
  mov       ah,4ch                  ; Quit the proggy.
  int       21h                    
@@memalloc_errormsg:
  db  'Error in memory allocation.',13,10,'$' 
@@memalloc_ok:
  ret
allocate_memory         ENDP
;============================================================================


MEMLIB                  ENDS
; ***************************************************************************
