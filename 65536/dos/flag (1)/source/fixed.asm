
				.model small,c
				locals

				extrn oldpos:word

				.code

				public FixedMul,FixedDiv,FixedAdd,Distance


param1 			equ [4+bp]
param2 			equ [6+bp]
param3 			equ [8+bp]
param4			equ [10+bp]



FixMul			macro r2		; multiplies eax by r2
								; result in eax
								; trashes edx
				imul dword ptr r2
				shrd eax,edx,16

				endm


FixDiv			macro r2		; divides eax by r2
								; result in eax
								; trashes edx
				mov edx,eax
				sar edx,16
				shl eax,16
				idiv dword ptr r2

				endm

.386

FixedAdd		proc near

				push bp
				mov bp,sp

				mov eax,param1
				add eax,param3

				mov edx,eax
				shr edx,16

				pop bp

				ret

FixedAdd		endp


FixedMul		proc near

				push bp
				mov bp,sp

				mov eax,param1
				FixMul param3

				mov edx,eax
				shr edx,16

				pop bp
				ret

FixedMul		endp


FixedDiv		proc near

				push bp
				mov bp,sp

				mov eax,param1
				FixDiv param3

				mov edx,eax
				shr edx,16

				pop bp
				ret

FixedDiv		endp


Distance		proc near

				push bp
				mov bp,sp

				push si
				push di

				xor esi,esi
				xor edi,edi

				mov di,word ptr param1
				shl di,4
				add di,oldpos
				mov si,word ptr param2
				shl si,4
				add si,oldpos

				mov eax,[edi]	; oldpos[a].x
				sub eax,[esi]	; - oldpos[b].x

				FixMul eax		; ^2

				mov ebx,eax

				mov eax,[edi+4] ; oldpos[a].y
				sub eax,[esi+4] ;  - oldpos[b].y

				FixMul eax		; ^2

				add eax,ebx

				mov edi,eax		; get square root..
				or edi,edi
				jz @@zero
				js @@zero

				bsr ecx,edi					; 1st approximation
				sub cl,16
				ja @@2

				lea esi,[edi*2]
				jmp @@3
@@2:
				shr cl,1
				add cl,16
				mov esi,1
				shl esi,cl

@@3:
				mov eax,edi					; 2nd approximation
				FixDiv esi
				mov ebx,esi
				sub ebx,eax
				sar ebx,1
				sub esi,ebx

				mov eax,edi					; 3rd approximation
				FixDiv esi
				mov ebx,esi
				sub ebx,eax
				sar ebx,1
				sub esi,ebx

				mov eax,edi					; 4th approximation
				FixDiv esi
				mov ebx,esi
				sub ebx,eax
				sar ebx,1
				sub esi,ebx

				mov eax,esi
				mov edx,eax
				shr edx,16
@@1:
				pop di
				pop si
				pop bp
				ret

@@zero:
				xor ax,ax
				xor dx,dx
				jmp @@1


Distance		endp







				end
