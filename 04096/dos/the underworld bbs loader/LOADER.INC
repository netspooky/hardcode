;
; It's `Just Another Generic Loader'
;    so bite me...
;
; The Include File (where all that global stuff goes)
;
; If only the world was two dimensional, vectors and virtual reality would
; be a shitload easier, wouldn't you say?
;

; -----> Ds: Variables

Global FrameCounter:WORD,YLen:BYTE,Font8x8[222*64]:BYTE,Font8x16[222*128]:BYTE
Global Ptr8x8:DWORD,Ptr8x16:DWORD,Lev2:BYTE,Lev3:BYTE,StarPtr1:WORD
Global StarPtr2:WORD,Stars1[200]:WORD,Stars2[200]:WORD
Global XLoc:WORD,YLoc:WORD
Global BufferWidth:WORD,BufferHeight:WORD,BufWidth:WORD

; -----> Cs: Variables 

Global XAddsX:WORD,XAddsC:WORD,XAddsY:WORD,BufferPtr:WORD
Global ClrAdd1:BYTE,ClrAdd2:BYTE


; -----> STARS.ASM

Global UpdateStars         :Proc
Global HorizStars          :Proc


; -----> TEXT.ASM
                                                    
Global DownLoadBios        :Proc
Global AntiAlias           :Proc
Global DispString          :Proc
Global ProcessString       :Proc
Global FoldString_Open     :Proc
Global FoldString_Close    :Proc


; -----> SCALE.ASM

Global DispImage           :Proc
Global DispImg_SclX        :Proc
Global ClrImg_SclX         :Proc
