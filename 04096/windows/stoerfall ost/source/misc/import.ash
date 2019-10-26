comment #+

    This is the source-release of "Stoerfall Ost", our winning 4kb
    multimedia presentation that was first shown at Dialogos 2000.
    If you have any questions concerning the sourcecode drop us a
    line at freestyle@freestylas.org. Feel free to visit our
    webpage at http://www.freestylas.org.
    Copyright (C) 2001 freestyle
    
    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
    
+#



	.data

Import_Table	label byte

		impOpenGL32			= 0
		db 'OPENGL32',0
		impwglMakeCurrent		= impOpenGL32+0
			db 'wglMakeCurrent',0
		impwglCreateContext		= impOpenGL32+4
			db 'wglCreateContext',0
		impglEnable			= impOpenGL32+8
			db 'glEnable',0
		impglDisable			= impOpenGL32+12
			db 'glDisable',0
		impglPolygonMode		= impOpenGL32+16
			db 'glPolygonMode',0
		impglBlendFunc			= impOpenGL32+20
			db 'glBlendFunc',0
		impglDepthFunc			= impOpenGL32+24
			db 'glDepthFunc',0
		impglMatrixMode			= impOpenGL32+28
			db 'glMatrixMode',0
		impglPushMatrix			= impOpenGL32+32
			db 'glPushMatrix',0
		impglPopMatrix			= impOpenGL32+36
			db 'glPopMatrix',0
		impglLoadIdentity		= impOpenGL32+40
			db 'glLoadIdentity',0
		impglTranslatef			= impOpenGL32+44
			db 'glTranslatef',0
		impglRotatef			= impOpenGL32+48
			db 'glRotatef',0
		impglGenTextures		= impOpenGL32+52
			db 'glGenTextures',0
		impglBindTexture		= impOpenGL32+56
			db 'glBindTexture',0
;		impglTexEnvf			= impOpenGL32+60
;			db 'glTexEnvf',0
		impglTexParameteri		= impOpenGL32+60
			db 'glTexParameteri',0
		impglTexImage2D			= impOpenGL32+64
			db 'glTexImage2D',0
		impglInterleavedArrays		= impOpenGL32+68
			db 'glInterleavedArrays',0
		;impglDrawElements		= impOpenGL32+72
		;	db 'glDrawElements',0
		impglLightfv			= impOpenGL32+72
			db 'glLightfv',0
		impglFinish			= impOpenGL32+76
			db 'glFinish',0
		impglClear			= impOpenGL32+80
			db 'glClear',0
		impglDepthMask			= impOpenGL32+84
			db 'glDepthMask',0
		impglDrawArrays			= impOpenGL32+88
			db 'glDrawArrays',0
		impglShadeModel			= impOpenGL32+92
			db 'glShadeModel',0
		impglClearColor			= impOpenGL32+96
			db 'glClearColor',0
		impglFogfv			= impOpenGL32+100
			db 'glFogfv',0
		db 0
	
		impGDI32			= impOpenGL32+104
		db 'GDI32',0
		impSwapBuffers			= impGDI32+0
			db 'SwapBuffers',0
		impChoosePixelFormat		= impGDI32+4
			db 'ChoosePixelFormat',0
		impSetPixelFormat		= impGDI32+8
			db 'SetPixelFormat',0
		db 0

		impGLU32			= impGDI32+12
		db 'GLU32',0
		impgluPerspective		= impGLU32+0
			db 'gluPerspective',0
		impgluLookAt			= impGLU32+4
			db 'gluLookAt',0
		db 0
		
		impUser32			= impGLU32+8
		db 'USER32',0
;		impBeginPaint			= impUser32+0
;			db 'BeginPaint',0
;		impEndPaint			= impUser32+4
;			db 'EndPaint',0
;		impInvalidateRect		= impUser32+8
;			db 'InvalidateRect',0
;		impGetMessageA			= impUser32+12
;			db 'GetMessageA',0
;		impDispatchMessageA		= impUser32+16
;			db 'DispatchMessageA',0
		impCreateWindowExA		= impUser32+0
			db 'CreateWindowExA',0
;		impSetWindowLongA		= impUser32+24
;			db 'SetWindowLongA',0
		impShowCursor			= impUser32+4
			db 'ShowCursor',0
		impGetDC			= impUser32+8
			db 'GetDC',0
		impChangeDisplaySettingsA	= impUser32+12
			db 'ChangeDisplaySettingsA',0
;		 impPostQuitMessage		 = impUser32+40
;			 db 'PostQuitMessage',0
;		 impShowWindow			 = impUser32+44
;			 db 'ShowWindow',0
		impGetAsyncKeyState		= impUser32+16
			db 'GetAsyncKeyState',0
		impPeekMessageA			= impUser32+20
			db 'PeekMessageA',0
		impMessageBoxA			= impUser32+24
			db 'MessageBoxA',0
		impDestroyWindow		= impUser32+28
			db 'DestroyWindow',0
		db 0
   
		impMMSys			= impUser32+32
		db 'WINMM',0
		impWaveOutOpen			= impMMSys+0
			db 'waveOutOpen',0
		impWaveOutClose			= impMMSys+4
			db 'waveOutClose',0
		impWaveOutGetPosition		= impMMSys+8
			db 'waveOutGetPosition',0
		impWaveOutPrepareHeader		= impMMSys+12
			db 'waveOutPrepareHeader',0
		impWaveOutUnprepareHeader	= impMMSys+16
			db 'waveOutUnprepareHeader',0
		impWaveOutReset			= impMMSys+20
			db 'waveOutReset',0
		impWaveOutWrite			= impMMSys+24
			db 'waveOutWrite',0
		db 0

		impDSound			= impMMSys+28
		db 'DSOUND',0
		impDirectSoundCreate		= impDSound+0
			db 'DirectSoundCreate',0
		db 0

		db 0	; terminator of	dll list

	
	.data?

		dd ?		; temp dll handle
wincalltbl	dd 100 dup(?)	; i expect this	to be zero

	
	.code
       
impDoImports	proc near
	mov	edi,offset Import_Table
	mov	esi,offset wincalltbl
	mov	ebx,esi
	sub	ebx,4
	
dll_loop:
	push	edi
	call	LoadLibrary
	;invoke	 LoadLibrary, edi
	or	eax,eax
	jz	done
	
	mov	[ebx],eax	;save dll handle
       
proc_loop:
	mov	cl,255		;set ecx to something nozero
	xor	al,al
	repne	scasb		;go to next string
	
	mov	al,[edi]
	or	al,al
	jz	done_proc

	push	edi
	push	[ebx]
	call	GetProcAddress
	;invoke	 GetProcAddress, [ebx],edi
	or	eax,eax
	jz	done
	
	mov	[esi],eax	;save proc address
	add	esi,4
		
	jmp	proc_loop
	
done_proc:	  
	;add	ebx,4

	inc	edi		;skip name list	terminator

	mov	al,[edi]
	or	al,al
	jnz	dll_loop
	
	inc	al
done:
	ret
impDoImports	endp
