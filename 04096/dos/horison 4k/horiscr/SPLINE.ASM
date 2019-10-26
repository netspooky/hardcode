;IFNDEF MACROA
;MACROA    proc
;MACROA    endp
;-----------------------------------------
;
; si = this spline array
; di = destination array
; eax = t
;
splines_getVal proc
               mov  splines_in_t,eax
               mov  cx,[si]
               add  si,2
splines_loop:  mov  bx,[si]
               fld  splines_in_t
               fist temp_dw
               fisub temp_dw
               ;st(0) = splines_rel_t
			shl	temp_dw,2
               add  bx,temp_dw
               call spline_getVal
               stosd
               add  si,2
			loop	splines_loop
               ret
splines_getVal endp
;-----------------------------------------
;A B-spline is constructed using arcs. If we want to form a B-spline
;using n arcs, we need n+3 key points, let them be c(0),c(1),...,c(n+2).
;The k:th arc (k = 1,2,...,n) of the B-spline is calculated from the formula
;rk(t) = 1/6*(1-3t+3t^2-t^3)*c(k-1) + 1/6*(4-6t^2+3t^3)*c(k) +
;        1/6*(1+3t+3t^2-3t^3)*c(k+1) + 1/6*t^3*c(k+2),
;where t ranges linearly from 0 to 1. The more different t values, the more
;accurate curve. Note that the ending point of the k:th arc and the starting
;point of the k+1:th arc are the same point. Even better, the curve is all
;smooth in these most significant points, too, mainly due to the truth that
;the shape of an arc is determined by as many as four key points summarized.
;-----------------------------------------
; description - spline class
; * when calling a function, si must be
;   pointing to a object.
;
; functions:
;    spline_getValue
;
;-----------------------------------------
;
; si = this spline (array of dword)
; eax = spline_t
; returns value in eax
;
spline_getVal  proc
               fst       spline_t_1
               fld       st(0)
               fimul     dw_3
               fstp      spline_3t_1
               fmul      st(0),st(0)
               fld       st(0)
               fimul     dw_3
               fstp      spline_3t_2
               fmul      spline_t_1
               fst       spline_t_3
               fimul     dw_3
               fstp      spline_3t_3
               fld1
               fsub      spline_3t_1
               fadd      spline_3t_2
               fsub      spline_t_3
               fmul      dptr[bx]
               fild      dw_4
               fsub      spline_3t_2
               fsub      spline_3t_2
               fadd      spline_3t_3
               fmul      dptr[bx+4]
               fld1
               fadd      spline_3t_1
               fadd      spline_3t_2
               fsub      spline_3t_3
               fmul      dptr[bx+8]
               fld       spline_t_3
               fmul      dptr[bx+12]
               faddp
               faddp
               faddp
               fmul      f_016
               fstp      spline_val
               mov       eax,spline_val
               ret
spline_getVal  endp
;-----------------------------------------
