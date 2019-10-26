lds bx,[bx]      		; get pointer to screen
mov al,0x13       		; switch to graphic mode
int 0x10				; 320 x 320 in 256 colors
L: 
imul si,byte 0x75		; pseudorandomize position
lodsb					; get "left" pixel value
adc al,[si+0x140]		; add "bottom" pixel + "random" (carry from imul)
add al,0x32				; add offset (shift band separation)
adc al,ch				; change behaviour at threshold (ch = 0 -> add 1 more)
sar al,0x01				; average pixel value (/2)
sbb al,0x99				; sub offset (/2) & flip top bit & even/odd influence
mov [si],al				; write pixel (ignore content)
in al,0x60				; the usual way of...
dec al					; ...checking for ESC key...
jnz L					; ...and loop while not pressed...
ret						; ...otherwise exit