;compiles with nbasm16.exe

.model tiny                  
.code                
	mov al,13h	;graphics mode
	int 10h		;int call

loop:	mov al,dl	;retrieve al from dl
	mov ah,12	;write pixel
    
	int 10h		;int call
	
	;graphics code
	inc bx		
	inc cx

	xor al,bh
	add bh,cl

	mov dl,al 	;store away al in dl

	;sound code               
	out 61h,al	;play a note

	;exit code
	mov ah,11	;is button pressed
	int 21h		;int call
	cmp al,0	;0 = nothing pressed

	je loop		;do it agian
	.exit

.end
