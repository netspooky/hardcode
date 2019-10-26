;	name	: Maelstrom
;	coder	: Dworkin
;	compo	: Demobit 2001
;	adress	: Brno :) Czech republic
;	e-mail	: ogion@centrum.cz
;	www	: http://hyperlink.cz/ogion/
;	message : I don't speak english.
;		  Tohle je moje prvni soutezni nebo 256 bytove intro.  Zdro-
;		  jak neni bez chyb a  poznamky se  mohu vztahovat k  nejake
;		  predchazejici verzi. Pokud vam MAELSTRM.COM vytuhne zkuste
;		  spustit TEST.COM a odhalit duvod.  V chranenem rezimu pro-
;		  cesoru mohou byt programu zakazany nektere cinnosti a muze
;		  se pak chovat nekorektne.  Pod Wokny98 bezi u mne az napo-
;		  druhe, pote co se vytvori maelstrm.pif.
;		  Chcete-li se vyhnout problemum spoustejte program v DOSu.
;
;
;  Testovano: DURON 750MHz, TNT2 Pro, DOS (musi byt zpomalovano a obraz
;	      nepravidelne zrni)
;
;  Minimalni konfigurace:
;
;  - 387+ (FSINCOS), pres tohle vlak nejede..
;  - direktiva SVGA = 1 -> SVGA 1.0 (rozliseni 100h = 640*480*256 barev)
;		    = 0 -> VGA (rozliseni 13h = 320*200*256), nic moc
;  - BIOS musi podporovat sluzbu: 0ch - Zapis bod pro dany rezim! Jinak
;				  VGA by to mela vzdy umet...
;  - direktiva OREZ = 1 -> Fce 0ch by umi nezobrazovat body mimo obrazovku
;		    = 0 -> Smirime se s tim ze budou spiraly mensi
;  - PC/XT :) (kvuli PPI (in al,60h), mimochodem pohyb mysi(v DOSu) nebo ESC
;	ukonci program)
;  - direktiva PALETA = 1 -> Meni pres DAC registry paletu (nepouziva BIOS)
;		      = 0 -> Nemeni paletu, vse je bile
;  - Sluzby BIOSu nesmi menit obsahy registru!
;
;
;  Realne minimum: 300MHz+ ??? (Lepe to ve 256 bytech nedokazi)
;
;  Kompilace: com.bat maelstrm
;
;  COM.BAT:	@echo off
;		rem Doporucuji nastavit COM.BAT !\! v "NC" nebo ! v "DN" pro .ASM
;		rem Jiny disk tlink nesezere ani s !:!\! nebo !\!
;		if exist %1 goto error
;		?:\?\tasm %1.asm %2 /m /la |more
;		?:\?\tlink /t /x %1
;		del %1.obj
;		goto exit
;		:error
;		echo Parametr musi byt bez pripony .asm!
;		:exit


SVGA	 EQU	 1	;0 = rezim 13h jinak 100h
OREZ	 EQU	 1	;0 = nekresli mimo obrazovku, jinak dokud nenarazi na boky
PALETA	 EQU	 1	;0 = porad bila, jinak tepajici paleta
ZDRZUJ	 EQU	 1	;0 = nesnazi se zpomalovat program
TEST_HW  EQU	 0	;0 = 256 intro, jinak prvne testuje hardware a pak zvoli VGA nebo SVGA!


; --------------------------- sem uz nesahej :) ------------------------------


.386P  ;to P kvuli mov eax,cr0
IDEAL
MODEL TINY


TESTKruh	EQU	0      ;chceme-li videt kruhy vzestupne
TESTSpiral	EQU	0      ;chceme-li videt spiraly vzestupne
CISLO		EQU	78     ;pocatek "nahodne" promnene pri TESTU (+127)
;n-uhelnik pri kruhu, presnost 4 (u spiral cislo+64)
;2=(1)
;3=43,44,45 (2/3)
;4=0,1!,2 (1/2)
;5=78 (4/5)
;6=nelze
;7=92 (6/7)
;8=65 (3/4)
;9=jen pri rozsireni nepresnosti zakonceni 100.6 (8/9)
; -> zvolim sude na kruh -> JC

;n-uhelnik pri kruhu, presnost 3
;2=(1)
;3=43,44 (2/3)
;4=0,1!,2 (1/2)
;5=78 (4/5)
;6=nelze
;7=jen pri rozsireni nepresnosti zakonceni 92,93 (6/7)
;8=65 (3/4)
;9=jen pri rozsireni nepresnosti zakonceni 100.6 (8/9)

if SVGA or TEST_HW
     grRezim	   EQU	   4f02h
     PolX	   EQU	   320
     PolY	   EQU	   200
     Scroll	   EQU	   79 + 24 * 256   ;x + y*256
else
     grRezim	   EQU	   0013h
     PolX	   EQU	   160
     PolY	   EQU	   100
     Scroll	   EQU	   39 + 24 * 256   ;x + y*256
endif


CODESEG
    Org 100h
    STARTUPCODE
;Pocatecni kod je prepsan promnenymi
;InitGraph
@100h:
    mov ax,grRezim	       ;2+1
    mov SI,0100h	       ;1+2(konstanta) Data v intrukci SI+4, SI se nikdy NEMENI!
if TESTSpiral or TESTKruh
    mov [word Ptr SI+6],Cislo
endif
if TEST_HW
   jmp @Hardware
else
   if SVGA
      MOV BX,SI 		 ;2
   endif
endif
    int 010h		       ;2
; ---- Smycka pro novy obrazec -----------------------------------------------

@main_repeat:
      MOV CH,7fh	       ;2 Cekej 3 sekundy
@Nekresli:
      Call @Wait
      LOOP @Nekresli	       ;2 Vystup: CX = 0
;Clear
      mov ax,0600h	       ;2 ah=sluzba, al=posunutych radku(0=cele)
      XOR BX,BX 	       ;2 bh atribut znaku
			       ;  ch=horni okraj okna, cl=levy radek okna
if TEST_HW
      mov dx,[TestScroll]
else
      mov dx,Scroll	       ;3 dh=dolni okraj okna, dl=pravy radek okna
endif
      int 010h		       ;2
;Polomer & Uhel
      Call @Random	       ;3 DX=40h cast kodu je umistena za Randomm aby relativni odkazy byly ShortInt
      MOV  [SI],AX	       ;2 q AX = 00?? + 80h = 2*r
      XCHG DX,CX	       ;2 Inicializace prirustku DX=0,CX=40h

if TEST_HW
   PUSH CX
   MOV	CL,[TestPosun]
   SHR	AX,CL
   POP	CX
   JP  @Neni_Spirala
else
   if SVGA
      RCR  AX,1 	       ;2/3 AX = r,carry bylo=0
      if TESTSpiral
	 JMP @TestSpiral
      endif
      JC  @Neni_Spirala        ;2
   else
      SHR  AX,2
      if TESTSpiral
	 JMP @TestSpiral
      endif
      JP  @Neni_Spirala
   endif
endif

@TestSpiral:
if TESTKruh
   JMP @Neni_Spirala
endif
	 INC DX 	       ;1
	 SHR AX,1	       ;2
	 SUB [Word Ptr SI],CX  ;2
@Neni_Spirala:
      LEA  BX,[SI+2]	       ;3 = MOV BX,Offset R
      MOV [BX],AX	       ;2 [r] = AX

if TEST_HW
      MOV BP,[TestX]	       ;3
      MOV DI,[TestY]	       ;3
else
      MOV BP,PolX	       ;3
      MOV DI,PolY	       ;3
endif

;	  | q		 |  r		|  dx
;---------+--------------+--------------+-------
; Spirala |  64 + 0..255 |  32 + 0..63	|  1
; Kruh	  | 128 + 0..255 |  64 + 0..127 |  0

      ADD AX,DI 	       ;2 AX = OldY = FirstY = Gy + r
      MOV CX,BP 	       ;2 CX = OldX = FirstX = Gx
	 db 0dbh
	 db 0e3h	       ;2 finit, nechci aby mne prekladac predhodil WAIT
	 fldpi		       ;2 ST(0) = pi
	 fimul [word ptr SI]   ;2 ST(0) = ST * q
	 fidiv [word ptr SI+4] ;3 ST(0) = ST/c100 = prirustek uhlu
	 fld st 	       ;2 ST(1) = ST(0)
if TESTSpiral or TestKruh
      INC [Byte Ptr SI+6]      ;zvysime "nahodnou" promnenou
endif
;  Smycka dalsi primku obrazce -----------------------------------------------
@Repeat:
	 fld st 	       ;2
	 fsincos	       ;2 ST=COS(ST),ST(1)=SIN(ST)
	 fimul [word ptr BX]   ;2
	 fistp [word ptr SI]   ;2
	 push DI	       ;1
	 add DI,[si]	       ;2
	 fimul [word ptr BX]   ;2
	 fistp [word ptr SI]   ;2
	 push BP	       ;1
	 add BP,[si]	       ;2
	 PUSHA		       ;1


;{Procedure SlowLine; (56 bytes!) Assembler;}
; Prvni univerzalni line v 256 intru??? :)
;@SlowLine:
;   MOV BP,NewX
;   MOV CX,OldX
;   MOV DI,NewY
;   MOV AX,OldY        ;3 (kratka intrukce)
   SUB CX,BP	      ;2 CX = DeltaX
   MOV BX,CX	      ;2
   JNS @DeltaX	      ;2
   NEG BX	      ;2
@DeltaX:	      ;  BX = abs(DeltaX)
   SUB AX,DI	      ;2 AX = DeltaY
   MOV DX,AX	      ;2
   JNS @DeltaY	      ;2
   NEG DX	      ;2
@DeltaY:	      ;  DX = abs(DeltaY)
   CMP BX,DX	      ;2 Porovnani absolutnich	hodnot rozdilu
   MOV BL,90h	      ;2
   JAE @Init	      ;2
   INC	BX	      ;1
   XCHG AX,CX	      ;1
@Init:
      MOV [Byte Ptr SI+Rozdil_NOP],BL	;3 90h=NOP,91h=XCHG AX,CX
      MOV BX,CX 	   ;2 odted je CX promnena smycky a BX deltaX
@Loop:
      PUSHA		   ;1 PUSH AX,BX,CX
      IMUL CX		   ;2 DX:AX=AX*CX,CX promnena
      IDIV BX		   ;2 AX=DX:AX div BX,BX je DELTA delitele
@POZOR_MENENA_INSTRUKCE:
      NOP		   ;1 NOP nebo XCHG AX,CX
      XCHG BX,AX	   ;1 MOV BX,AX
;Nakresli bod
@POZOR_DATA_V_INSTRUKCI:   ; Dat co nejvys aby Rozdil_NOP bylo jeste ShortInt
      MOV  AX,0c07h	   ;3 druhy byt instrukce je cislo aktualni barvy!!!
      ADD  CX,BP	   ;2 = X
      LEA  DX,[BX+DI]	   ;2 = Y
      XOR BX,BX 	   ;2 BH= Stranka
      INT  10h		   ;2
;Zmena palety & cekani
      CALL @Wait
      POPA		   ;1 POP CX,BX,AX
      DEC  CX		   ;1 Dec(Abs(CX))
      JNS  @Kladny	   ;2
      INC  CX		   ;1
      INC  CX		   ;1
@Kladny:
      JNZ  @Loop	   ;2
;{End SlowLine}



	 POPA		       ;1
	 mov CX,BP	       ;2 (CX)OldX = NewX(BP)
	 XCHG DI,AX	       ;1 (AX)OldY = NewY(DI)
	 fadd st,st(1)	       ;2 nasobek := nasobek + inc_nasobek
	 POP BP 	       ;1 320
	 POP DI 	       ;1 200
; ---- Testovani konce obrazce -----------------------------------------------
;Ukonceni u spiral: OldY <(=) 0 nebo OldY >= 640
      ADD [Word Ptr BX],DX     ;2 r=r+1/0
if Orez
      CMP [Word Ptr BX],BP     ;2 r>=320
else
      CMP [Word Ptr BX],DI     ;2 r>=200
endif
      JNB @Dlouhy_Skok	       ;2 ANO = konec obrazce
      OR  DX,DX 	       ;2 DX=1=Spirala,jinak DX=0
      JNZ @Repeat	       ;2
;Ukonceni u kruhu: (y < 0) AND (ABS(X) <= 4)
      CMP AX,DI 	       ;2 Y > 0?
      JNA @Repeat	       ;2
@Zaporne:
      NEG [Word Ptr SI]        ;2
      JS  @Zaporne	       ;2 [SI] = Abs([SI])
      CMP [Word Ptr SI],4      ;3!!! s=1=data se rozsiri na 16bit
      JA  @Repeat	       ;2
@Dlouhy_Skok:
      JMP @Main_Repeat	       ;3

; -------- Konec hlavni smycky -----------------------------------------------

;{Procedure Wait;}
@Wait:
;Zmena palety
if PALETA
@Pozadi:
   INC [Byte Ptr SI + Rozdil_Color] ;3
   JZ @Pozadi			    ;2
   MOV AL,[SI + Rozdil_Color]	    ;3
   MOV	   DX,03C8h		    ;3 Registr pro zapis PEL Addres Write Mode
   OUT	   DX,AL		    ;1
   INC	   DX			    ;1 Datovy registr PEL Data Registr
   PUSH SI			    ;1
   STD				    ;1 LODS,OUTS dekrementuje SI
   LODSW			    ;1 SI - 2
   OUTSB			    ;1 zapis cervene  DS:SI -> OUT DX
   OUTSB			    ;1 zapis zelene   DS:SI -> OUT DX
   INC [DWord Ptr SI]		    ;3 DWord!
   OUTSB			    ;1 zapis modre    DS:SI -> OUT DX
   POP SI			    ;1 SI = 100h
endif
;Procedura RandomByte; cteni hodnoty citace 0
; -- Procedura uvnitr procedury ----------------------------------------------
;Usetri se jedno call a ret, kdyby Wait nemenilo CH nemusela by byt
@Random:
   XOR AX,AX
;KeyPressed
   IN AL,60h		       ;2 Cteme scan code klavesy ESC=1,nic = 41h?
   DEC AX		       ;1
   JNZ @NoExit		       ;2
   PUSH AX		       ;2 Do zasobniku NULU => RETN skoci na zacatek PSP = na INT20h

   MOV AL,3
   INT 10h
   MOV AH,9
   MOV DX,OFFSET Text
   INT 21h

@NoExit:
   mov	al,0D2h       ;2 al=d2h zpetne cteni citace 0
   out	43h,al	      ;2
   mov dx,40h	      ;3 po Random se ocekava vystup DX = 40h,viz vyse
   in al,dx	      ;1 nizsi
   in al,dx	      ;1 vyssi
if ZDRZUJ
   XCHG BX,AX	      ;1 BX=00??h
@Cekej:
   in al,dx	      ;mozna ze nekde mohou nastat potize pri cteni bez out 43h
   in al,dx
   CMP al,bl
   JZ @Cekej
endif
if TESTSpiral or TESTKruh
   MOV AX,[SI+6]
endif
   ADD	AX,7fh	       ;3!! s=1,carry=0, inicializujeme q
;Vystup:
;AX=BH??h+7fh
;BX=00??h
;DX=0040h
   RETN

;DATASEG
;vypnouto aby to nekricelo ze nejde udelat ROZDIL z jinych segmentu,
;stejnak DS=CS a na vysledek ulozeni dat to nema vliv
;tohle uz nema smysl kdyz vsechny promnene jsou ted pro prekladac neviditene


;naky konstanty
Adr100h      EQU    OFFSET @100h ;Pri primem (x-100h) by to udelalo word :(
AdrColor     EQU    OFFSET @POZOR_DATA_V_INSTRUKCI+1
AdrNOP	     EQU    OFFSET @POZOR_MENENA_INSTRUKCE
Rozdil_Color	    EQU    (AdrColor-Adr100h)
Rozdil_NOP	    EQU    (AdrNOP-Adr100h)

;Usetrime 1 byt kdyz uvedeme relativni adresu misto nacteni absolutni
;Dejte bacha aby rozdil se vlezl do ShortInt!!!


;Blue	 db	 ?		;-4
;Green	 db	 ?		;-3
;Red	 db	 ?		;-2
;Empty	 db	 ?		;-1 (kvuli inc DWORD u zmeny palety)
;100h
;X&Y&Q	 DW	 ?		;
;R	 DW	 ?		;+2
;Const256	 DW	 256	;+4
Text	 db	 'DEMOBiT 2001$'


;---------------------------------------------------------------------------



if TEST_HW
@Hardware:
	    MOV DX, OFFSET T286
	    CALL @Napis
;Test CPU
	    MOV CX,0f000h	;test 8086
	    XOR AX,AX
	    PUSH AX
	    POPF
	    PUSHF
	    POP AX
	    AND AX,CX
	    CMP AX,CX
	    JZ @Bad_Halt	;jen 8086 = neni 286

	    MOV BX,OFFSET T387 ;Test kopru 387
	    CALL @Napis_Ok
	    SMSW AX
;	     mov eax,cr0      ;tohle ve win98 blbo
	    and al,10h		;test Extension Type (1 = 387)
	    JZ @Bad_Halt

;Test rezimu procesoru
	    MOV BX,OFFSET TMod	;Test Real/Protect
	    CALL @Napis_Ok
	    MOV DX,OFFSET TReal
	    SMSW AX
	    AND AL,1
	    JZ @Real
	    MOV DX,OFFSET TProtect
@Real:	    CALL @Napis

;Test grafiky
	    MOV DX,OFFSET TVGA	;Cteni kombinace monitoru
	    CALL @Napis
	    MOV AX,1a00h
	    INT 10h		;ve Win to nekdy smaze okno :(
	    CMP AL,1ah
	    JNZ @Bad_Halt	;neni VGA
;vodcat to jede aspon VGA
	    MOV BX,OFFSET TSVGA ;Hledame VESA BIOS
	    CALL @Napis_Ok
	    MOV DI,OFFSET TBUF	;ES:DI 256 bytovy buffer
	    MOV AX,4f00h
	    INT 10h
	    CMP AX,004fh
	    JNZ @VGA_Only	;nenalezena

	    MOV BX,OFFSET TSluzba ;Zjisteni informaci o rezimu
	    CALL @Napis_Ok
	    MOV AX,4f01h	;buffer zas ES:DI
	    MOV CX,100h 	;videorezim
	    INT 10h
	    CMP AX,004fh
	    JNZ @VGA_Only	;sluzba nebyla uspesne vykonana

	    MOV BX,OFFSET TRezim ;umi rezim 100h?
	    CALL @Napis_Ok
	    TEST [Word Ptr DI],0001h	 ;s=1
	    JZ @VGA_Only	;neumi

	    MOV BX,OFFSET TBIOS
	    CALL @Napis_Ok	;BIOS podporuje rezim 100h?
	    TEST [Word Ptr DI],0004h	 ;s=1
	    JZ @VGA_Only	;nepodporuje

	    MOV DX,OFFSET TInit
	    CALL @ReadKey
	    mov AX,4f02h
	    mov BX,0100h
	    INT 10h
	    XCHG CX,AX		;AX zrusi @Napis,DX zrusi @Napis_Ok
	    MOV DX,OFFSET T100H
	    CALL @Napis
	    CMP CX,4fh		;s=1 -> 004f
	    JNZ @VGA_Only	;tohle by snad ani nemelo nastat
	    MOV DX,OFFSET T_ok	;odentruj
	    CALL @Napis
	    JMP  @Jedem

;--------------------------------

@Bad_Halt:
   MOV DX, OFFSET T_BAD
   CALL @Napis
   EXITCODE

@VGA_Only:
   MOV DX, OFFSET T_BAD
   CALL @Napis
   MOV DX, OFFSET TRUNVGA
   CALL @ReadKey
   SHR [TestX],1
   SHR [TestY],1
   SHL [TestPosun],1
   SUB [TestScroll],40
   MOV AX,0013h
   INT 10h
@Jedem:
   MOV DX,OFFSET TSpeed
   CALL @Napis
   JMP @Main_Repeat


@Napis_Ok:
   MOV DX, OFFSET T_OK
   CALL @Napis
   MOV DX,BX
   CALL @Napis
RETN

@Napis:
   MOV AH,9
   INT 21h  ;vypis
RETN


@ReadKey:
    CALL @Napis
    MOV DX, OFFSET TKEY
    CALL @Napis
@Key:
    XOR AH,AH	       ;2 AH := 0, INT 16h pak cte znak z klavesnice
    INT 16H	       ;2 AL := ASCII kod znaku; AH := SCAN kod znaku
RETN



T_OK	 db	'... ok!',13,10,9,'- $'
T_BAD	 db	'... chyba!! :(',13,10,'$' ;viz *
T286	 db	'  Test: - cder DWRKiN... ok! :)',13,10,9,'- 286$' ;to jsem zvedav zda to funguje
T387	 db	'387$'			   ;dtto
TMod	 db	'Rezim procesoru: $'	   ;dtto
TReal	 db	'Real :)$'		   ;dtto
TProtect db	'Protected :($' 	   ;dtto
;TVirtual db	 'Virtual 8086 Mode :($'       ;
TVGA	 db	13,10,9,'- VGA$'
TSVGA	 db	'VESA SVGA$'
TSluzba  db	'Zjisteni informaci o modu SVGA$'
TRezim	 db	'Graficky adapter umi rezim 100h$'
TBIOS	 db	'VESA BIOS podporuje rezim 100h$'

TRUNVGA  db	'  Program pobezi ve VGA (13h).$'
TINIT	 db	'... ok!',13,10,'  Program pobezi v SVGA (100h).$' ;viz *
TKEY	 db	' Stiskni klavesu...$' ;viz *
T100h	 db	'  Rezim spusten$'     ;viz *
TSPEED	 db	'Funguje port 40h? (hodiny)',13,10,'  Cekas-li pres 3 vteriny tak NE...$'
TBUF	 db	256 DUP(?)

;* delka je uz 79!
;  Program pobezi v SVGA (100h). Stiskni klavesu...  Rezim spusten... chyba!! :(

TestX	dw	PolX
TestY	dw	PolY
TestScroll	dw	 Scroll
TestPosun	db	 1

endif

END

P.S. Hadejte z ktere zx hry je tohle :)

				  пмлмллллллллллм
				   пллллллпплп ллллмм
				    плллллм    пппллл ллплмм
				     плллл м  мммлл    пплмлллм
				      ппллллл ллппмлллллплплм плм
     ммммммммм			   млллмм плллпмллллллмм лмллллллм
  млппммммллллллмм		   ппппллл     пппп	  пплл плл
  пмллп мммммпплллллмм		     млммп лл  ммллллллмм   плммлппмллпм
   ллл ллллллллллллпллл       лм     пл л ллллм  л п млп      пл ллллп пл
   плл ллл    плллл лллл    м ллм     плмллллллл плмллп   ммлл пмлллммм  л
      лллл    ллллпмлллл    пллллллппмлллллллллл лммммммллллп  лллллллл мл
      плл    ллллп пллллл    мллллл ллллллллллл мллллллллллммл ллллллллллп
	     пппп   лллллм ммм	ппп пллллллллп пллллллллллллппмлллллллллл
		     лллллл ллллм  ллмпппппм	ммппппппппмм ллллллллллл
	      ммллллм плллл ллллл лллллллл плммлп мллллллллл ллллллллллл
	    млллпп	ппмллллпл ллллллп ммм мммл плллллллп лллллплл лп
	    ллл        ммлллллп л лп мллмллллмлллллмлллллл ммм плл    л
	    пллмммлллллллллллпмллмм ллллллллллллллллллллл лллллмпл   лп
	     плллллллллллллллллллл ллллллллллллллллллллл ллллллллммллл
		ппппппппп ммлллллл лллллллллллллллллллп млллллллллпллп
		       пллллп лллл лллл ллллллллллмплпп лллллллллл лл
			  лм	мллмплп ллллллллллл  лллммппллллллм
			   лл ллллллмп млллллллллл  лллллллм лллллл
                             ппппп млм лллллллллл млллллллллмлллллл