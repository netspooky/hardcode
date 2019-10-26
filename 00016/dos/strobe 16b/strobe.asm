;; Strobe 16B
;; Whizart, 5 October 2013
;; Compile with nasm; tested under DOSBox 0.74

org  100h

mov dx, 03c9h		;; set palette for color(s) port

flicker:

%ifdef cyanred
	out dx, al	;; 1st
%endif

	in al, 40h

%ifndef cyanred
	out dx, al	;; 1st
%endif

%ifdef red
	aaa
%endif

	out dx, al	;; 2nd

%ifdef yellow
	aaa
%endif

	out dx, al	;; 3rd

	in al, 60h	;; check for ESC
	dec al
	jnz flicker

ret