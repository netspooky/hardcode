;event class
;
;at a position in time calls all function's which should be called
;if more than one function is called at one position in time, the
;function at top of the list is called first.
;
;class funtion
;     int start_time 100
;     int end_time 200
;     proc* function ptr
;class end
;
;for each funtion
;     if t is inside t's time_interval
;          call function.ptr
;
;*****************************************************************************
function       struc
               func_ptr            dw   0
               func_start          dw   0
               func_end            dw   0
function       ends
;--------------------------------------------------
;event_array1  label funtion
;event_blit     function  <offset dummy_func, 0,2000>
;event_camera1  function  <offset dummy_func, 000,200>
;event_camera2  function  <offset dummy_func, 200,400>
;event_camera3  function  <offset dummy_func, 400,600>
;event_camera4  function  <offset dummy_func, 600,800>
;event_camera5  function  <offset dummy_func, 800,900>
;event_array     array     <6, offset event_blit>
;--------------------------------------------------
; example:
;   mov ax,100
;   mov si,offset event_array
;   call event_do
;
; ax = event time
; si = function_array
;
event_do       proc
               mov  cx,ds:[si].array_length
               mov  si,ds:[si].array_ptr
event_loop:    push cx
               push si
               push ax
               ; si = ptr to correct function struc
               cmp  ax,ds:[si].func_start
               jb   short event_skipFunc
               cmp  ax,ds:[si].func_end
               jae  short event_skipFunc
               mov  bx,ds:[si].func_ptr
               call bx
event_skipFunc:pop  ax
               pop  si
               add  si,size function
               pop  cx
               loop event_loop
               ret
event_do       endp
