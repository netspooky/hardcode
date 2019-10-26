;// (c) 1995-1997 Niklas Beisert / pascal
;// lasse reinboeng source
;// this header must stay on top of this file
;// free for non-commercial use of any kind as long as proper credits are given.

.386
model flat,prolog
locals

.code

public fireline_
fireline_ proc
@@lp:
    i=0
    rept 2
      mov eax,ebx
      add eax,[esi+i+320]
      add eax,[esi+i-1]
      add eax,[esi+i-320]
      add eax,[esi+i+1]
      mov ebx,eax
      and ebx,03030303h
      and eax,not 03030303h
      shr eax,2
      mov [edi+i],eax
      i=i+4
    endm
    add esi,i
    add edi,i
  dec ecx
  jnz @@lp
  ret
endp

public fireline256_
fireline256_ proc
@@lp:
    i=0
    rept 2
      mov eax,ebx
      add eax,[esi+i+256]
      add eax,[esi+i-1]
      add eax,[esi+i-256]
      add eax,[esi+i+1]
      mov ebx,eax
      and ebx,03030303h
      and eax,not 03030303h
      shr eax,2
      mov [edi+i],eax
      i=i+4
    endm
    add esi,i
    add edi,i
  dec ecx
  jnz @@lp
  ret
endp

end
