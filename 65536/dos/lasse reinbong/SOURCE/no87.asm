;// (c) 1995-1997 Niklas Beisert / pascal
;// lasse reinboeng source
;// this header must stay on top of this file
;// free for non-commercial use of any kind as long as proper credits are given.

.386
.model flat,prolog

public __CHP
public __8087
public _fltused_
public __init_387_emulator

.code

__CHP:
  frndint
_fltused_:
__8087:
__init_387_emulator:
  ret


;.data
;public __87xx
;public __87xxxxxxxxxxxxxxx
;__87xx:
;__87xxxxxxxxxxxxxxx:
;
;.code
;
;;num05 dd 0.5
;
;public _87xxxxx_
;public __87x
;__87x:
;;  fadd dword ptr cs:num05
;  frndint
;_87xxxxx_:
;  ret

end
