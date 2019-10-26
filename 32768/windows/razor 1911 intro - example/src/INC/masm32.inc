; #########################################################################
;
;                      Include file for MASM32.LIB
;
; #########################################################################

; for both --> arg num, buffer
ArgCl  PROTO :DWORD,:DWORD   ; GUI mode version
ArgClC PROTO :DWORD,:DWORD   ; console mode version
GetCL PROTO :DWORD,:DWORD

Alloc       PROTO :DWORD
Free        PROTO :DWORD

a2dw   PROTO :DWORD
atodw  PROTO :DWORD          ; return value in eax
htodw  PROTO :DWORD          ; return value in eax
dwtoa  PROTO :DWORD,:DWORD   ; value - buffer
dw2a   PROTO :DWORD,:DWORD
dw2hex PROTO :DWORD,:DWORD

GetErrDescription PROTO :DWORD

FloatToStr  proto stdcall fpin: QWORD, szDbl: PTR CHAR
FloatToStr2	proto	stdcall fpin: QWORD, szDbl: PTR CHAR
StrToFloat	proto	stdcall szIn: PTR BYTE, fpout: PTR DWORD

InString  PROTO :DWORD,:DWORD,:DWORD                    ; new version

BinSearch PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD      ; classic scanner

; Boyer Moore based algorithms
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
BMBinSearch  PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD   ; complete BM
BMHBinsearch PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD   ; horspool variation
SBMBinSearch PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD   ; simplified version
WordCount    PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD   ; BM word counter

; ----------------------
; Encryption componemts
; ----------------------
XorData PROTO :DWORD,:DWORD,:DWORD,:DWORD
RolData PROTO :DWORD,:DWORD,:DWORD,:DWORD
RorData PROTO :DWORD,:DWORD,:DWORD,:DWORD

lcase PROTO :DWORD          ; address string
ucase PROTO :DWORD          ; address string

ltrim PROTO :DWORD,:DWORD   ; source - dest
rtrim PROTO :DWORD,:DWORD   ; source - dest

trim PROTO :DWORD

lnstr  PROTO :DWORD          ; length in eax
StrLen PROTO :DWORD

revstr PROTO :DWORD,:DWORD

; ---------------------------------------------------------------
; Note that these following 3 procedures are no longer included
; in the library, they have been replaced with later and faster
; procedures. Code written with these procedures is still
; functional by means of the following equates which map them
; directly to the later procedures.
; ---------------------------------------------------------------

; lstr   PROTO :DWORD,:DWORD,:DWORD    ; source - substring - length
; rstr   PROTO :DWORD,:DWORD,:DWORD    ; source - substring - length
; midstr PROTO :DWORD,:DWORD,:DWORD,:DWORD

szCatStr PROTO :DWORD,:DWORD
szLeft   PROTO :DWORD,:DWORD,:DWORD
szRight  PROTO :DWORD,:DWORD,:DWORD
szMid    PROTO :DWORD,:DWORD,:DWORD,:DWORD
szMultiCat PROTO C :DWORD,:DWORD,:VARARG

; -----------------------------------------
; Note that the equates MUST be put after
; the procedure names that they equate to.
; -----------------------------------------
lstr equ <szLeft>
rstr equ <szRight>
midstr equ <szMid>
; ******************************

shell PROTO :DWORD  ; run programs synchronously

StripRangeI PROTO :DWORD,:DWORD,:BYTE,:BYTE
StripRangeX PROTO :DWORD,:DWORD,:BYTE,:BYTE

MemCopy PROTO :DWORD,:DWORD,:DWORD  ; source - dest - length
memfill PROTO :DWORD,:DWORD,:DWORD

GetAppPath   PROTO :DWORD     ; buffer has app path
NameFromPath PROTO :DWORD,:DWORD
GetPathOnly  PROTO :DWORD,:DWORD

exist PROTO :DWORD
filesize PROTO :DWORD

FrameCtrl   PROTO :DWORD,:DWORD,:DWORD,:DWORD
FrameWindow PROTO :DWORD,:DWORD,:DWORD,:DWORD
FrameGrp    PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD

Frame3D PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
line    PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
circle  PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD

DisplayBmp   PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
DisplayIcon  PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
VerticalTile PROTO :DWORD,:DWORD,:DWORD
SetBMcolor   PROTO :DWORD,:DWORD

BmpButton    PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD

StdOut       PROTO :DWORD
StdIn        PROTO :DWORD,:DWORD
locate       PROTO :DWORD,:DWORD
ClearScreen  PROTO
StripLF      PROTO :DWORD

BrowseForFolder PROTO :DWORD,:DWORD,:DWORD,:DWORD
FontDialog      PROTO :DWORD,:DWORD,:DWORD
ColorDialog     PROTO :DWORD,:DWORD,:DWORD
PageSetupDialog PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
PrintDialog     PROTO :DWORD,:DWORD,:DWORD

Read_File_In    PROTO :DWORD,:DWORD
ofCallBack      PROTO :DWORD,:DWORD,:DWORD,:DWORD
Write_To_Disk   PROTO :DWORD,:DWORD
sfCallBack      PROTO :DWORD,:DWORD,:DWORD,:DWORD
RichEd1         PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RichEd2         PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD

GetPercent      PROTO :DWORD,:DWORD
IntMul          PROTO :DWORD,:DWORD
IntDiv          PROTO :DWORD,:DWORD
IntSqrt         PROTO :DWORD

CombSortA       PROTO :DWORD,:DWORD
CombSortD       PROTO :DWORD,:DWORD
nrQsortA        PROTO :DWORD,:DWORD
nrQsortD        PROTO :DWORD,:DWORD

