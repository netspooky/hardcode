;
;  -> This is a demo, game, or some graphical editor of sorts, inclusive.
;
;  Video Include Module - All kinds of juicy tidbits that I either don't 
;  feel like memorizing, or just added for increased readability.
;


   Global TheImage   :Word
   Global PalBuf1    :Byte
   
   o   EQU Offset

   nil = 0

   SCREEN_SEG      = 0a000h  ; Segment of display memory in mode x

   ATTRIB_CTRL     = 03C0h   ; VGA Attribute Controller
   GC_INDEX        = 03CEh   ; VGA Graphics Controller
   SC_INDEX        = 03C4h   ; VGA Sequencer Controller
   SC_DATA         = 03C5h   ; VGA Sequencer Data Port
   CRTC_INDEX      = 03D4h   ; VGA CRT Controller
   CRTC_DATA       = 03D5h   ; VGA CRT Controller Data
   MISC_OUTPUT     = 03C2h   ; VGA Misc Register
   INPUT_1         = 03DAh   ; Input Status #1 Register

   PIXEL_PAN_REG   = 033h    ; Attrib Index: Pixel Pan Reg
   MAP_MASK        = 002h    ; Sequ Index: Write Map Mask reg
   READ_MAP        = 004h    ; GC Index: Read Map Register
   START_DISP_HI   = 00Ch    ; CRTC Index: Display Start Hi
   START_DISP_LO   = 00Dh    ; CRTC Index: Display Start Lo

   MASK_PLANE1     = 00102h  ; Map Register + Plane 1
   MASK_PLANE2     = 01102h  ; Map Register + Plane 2
   ALL_PLANE_ON    = 00F02h  ; Map Register + All Bit Planes

   CHAIN4_OFF      = 00604h  ; Chain 4 mode Off
   CHAIN4_ON       = 00c04h  ; Chain 4 mode On
   ASYNC_RESET     = 00100h  ; (A)synchronous Reset
   SEQU_RESTART    = 00300h  ; Sequencer Restart

   LATCHES_ON      = 00008h  ; Bit Mask + Data from Latches
   LATCHES_OFF     = 0FF08h  ; Bit Mask + Data from CPU

   VERT_RETRACE    = 08h     ; INPUT_1: Vertical Retrace Bit
   PLANE_BITS      = 03h     ; Bits 0-1 of Xpos = Plane #
   ALL_PLANES      = 0Fh     ; All Bit Planes Selected
   CHAR_BITS       = 0Fh     ; Bits 0-3 of Character Data
