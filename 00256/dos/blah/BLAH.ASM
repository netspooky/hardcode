comment ~

 entry for 256 byte xmas demo compo.  held december 1997.
 came 4th.

 here are some of the comments from the voting forms:

  zoon: "interesting, looks nice"
  spyko: "cool explosion, nicely blurred"
  dabat: "Realy nice, suprising"
  vulture: "Just all round good"
  martin : "CooooooL but no so nice"
  insomniac: "One of my absolute favourites, realistic explosion!"
  estrato: "is that a particle system?"

some people smoke too many drugs.

~

;num      equ  4096
num      equ  1024

fpd		equ  4

code	segment para public 'code'
		assume cs:code, ds:code
		.486
		org 100h
start:
  xor dx, dx				; argh argh argh hate hate hate
  mov dh, 060h
  mov fs, dx

  mov dh, 0a0h
  mov es, dx

  mov al, 13h
  int 10h

  mov dx, 3c8h
  xchg ax, bx
  out dx, al
  inc dx
  mov cl, 255
PalLoop:
  mov al, cl
  neg al 					; for evil palette, uncomment either this..
  sar al, 2 				; .. or this.
  out dx, al
  out dx, al
  or al, 8
  out dx, al
  loop PalLoop

InitPart:

  push es

  push cs
  pop es

  lea di, part
  mov ch, (num/256)
InitLoop:
  mov ax, 2560
  stosw
  mov ax, 800
  stosw
  call rand
  call rand
  loop InitLoop

  pop es


MainLoop:

  lea si, part

  mov ch, (num/256)
PartLoop:

  mov ax, [si+4]
  add [si], ax 			; xx += tx.

  mov ax, [si+2]
  add ax, [si+6]
  mov [si+2], ax

  sar ax, fpd

  mov di, ax
  imul di, 320

  cmp al, 190
  jbe Fine
Fucked:
  neg word ptr [si+6]
  sar word ptr [si+6], 1

  sar word ptr [si+4], 2

Fine:

  lodsw						; evil.
  sar ax, fpd

  inc word ptr [si+4]	; may look wrong but isn't :)

Bonzai:

  add di, ax
  add si, 6 				; may look wrong but isn't :)

  mov byte ptr fs:[di], 255				 ; i don't like this for some reason..
								 ; maybe because it's 4 bytes.. :)
  loop PartLoop

  dec bl
  jz InitPart

  push ds

  push fs
  pop ds

  xor di, di
  mov ch, 0fah
BlurLoop:		 ; the brain of st. peter has been conwerted to ewil :)
;	xor dx, dx						  ; to get the evil background, comment this.
  mov dl, [di+1]
  add ax, dx
  mov dl, [di-320]
  add ax, dx
  mov dl, [di+320]
  add ax, dx
  shr ax, 2

  jz NoCool
  dec ax
NoCool:

  mov [di], al
  inc di
  loop BlurLoop

  xchg di, cx			; PURE EVIL!!!!
  xor si, si
  rep movsb

  pop ds

  in al, 60h

  cmp al, 1
  jne MainLoop

;  xor di, di
;  xor eax, eax

  mov ax, 3
  int 10h

  mov ah, 09h
  lea dx, nyaha
  int 21h

rand:
  imul bp, 4e6dh
  mov ax, bp
  sar ax, 9
  stosw			 ; this _shouldn't_ crash it.. hmm.. di would have to be FFFEh,
					 ; which it isn't.  it's somewhere a bit lower.. so everything
					 ; is cool, and we get a nice random errorlevel for dos :)
  ret

nyaha db "<insert a profound but still confusing message> gyrzoon 97","$"


part	db  num*8 dup (?) 		; xx,yy,tx,ty

blah	dd  ?

ends code
end start
