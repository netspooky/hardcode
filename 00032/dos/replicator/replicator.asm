; asmcompo #9 by #asm@EFNet
; http://asmcompo.org
; 
; Replicator by mov
; mov@movnet.org
; 08/06/04

[org 0x100]

init:
  mov al, 0x13
  int 0x10                   ; videomode 0x13 (320x200x256)
  pop di                     ; 0000
  pop cx                     ; 20CD
  pop es                     ; 9FFF
  
start:
  call get_ip                ; push ip
get_ip:
  pop si                     ; si = ip
  sub si, 3                  ; get address of start

  mov cx, PROGRAM_SIZE       ; number of bytes to move
  rep movsb                  ; move them

  lea si, [di-PROGRAM_SIZE]  ; update the source index to the end of the
                             ; snippet minus its length
delay:
  dec cx
  loop delay

  push es                    ; see below.
  pop ds                     ; ds = es
  push es                    ; see below.
  push si                    ; see below.
  retf                       ; cs = es, ip = si

end:
  PROGRAM_SIZE EQU $-start
