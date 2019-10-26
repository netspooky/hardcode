lds si,[si]			; 		the infamous SInception move setup
nop					; 		that was exhausting, so let's chill
L: lodsb			; 		load ... something
and al,[si+80]		;		weave it logically into another thing
not al				;		now take the opposite, because we can
mov [si],al			;		store this as a new something
imul si,byte 41		;		we didn't multiply yet!
jmp short L			;		everybody needs workout, so jump!