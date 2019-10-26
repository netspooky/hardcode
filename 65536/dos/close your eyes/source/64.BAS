' ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
' Program Title: Close your eyes
'     Copyright: 1999
'        Author: kombi.IJSKAST
' Last Modified: no
' ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
'   Description: Program template for PowerBASIC programmers to control
'                exactly how PowerBASIC generates your executables.
' ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
'         Notes: borrelnotes, tigernotes
' ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
'       History: 1600, slag bij nieuwpoort
' ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

$CPU 8086                 ' program works on any CPU

$OPTIMIZE SIZE            ' make smallest possible executable
$COMPILE EXE              ' compile to an EXE

$DEBUG MAP OFF            ' turn off map file generation
$DEBUG PBDEBUG OFF        ' don't include pbdebug support in our executable

$LIB COM        OFF       ' turn off PowerBASIC's communications library.
$LIB CGA        OFF       ' turn off PowerBASIC's CGA graphics library.
$LIB EGA        OFF       ' turn off PowerBASIC's EGA graphics library.
'$LIB VGA        OFF       ' turn off PowerBASIC's VGA graphics library.
$LIB LPT        OFF       ' turn off PowerBASIC's printer support library.
$LIB IPRINT     OFF       ' turn off PowerBASIC's interpreted print library.
$LIB FULLFLOAT  OFF       ' turn off PowerBASIC's floating point support.

$ERROR BOUNDS   OFF       ' turn off bounds checking
$ERROR NUMERIC  OFF       ' turn off numeric checking
$ERROR OVERFLOW OFF       ' turn off overflow checking
$ERROR STACK    OFF       ' turn off stack checking

'$FLOAT PROCEDURE          ' use procedural floating point to optimize for
'                          ' machines without a co-processor

$COM    0                 ' set communications buffer to nothing
$STRING 16                ' set largest string size at 16k
$STACK  2048              ' let's use a 2k stack
$SOUND  1                 ' smallest music buffer possible

$DIM ARRAY                ' force arrays to be pre-dimensioned before they can
                          ' be used
$DYNAMIC                  ' all arrays will be dynamic by default

'$OPTION CNTLBREAK OFF     ' don't allow Ctrl-Break to exit program

DEFINT A-Z                ' default all variables to integers for maximum

$LINK "MSE_PB.OBJ"        '\
$INCLUDE "BWSB.PBI"   ' | Use these lines for PB3.x
$INCLUDE "GDMTYPE.BI" '/

DIM ModHeader       AS GDMHeader           'Module Header

'Freemem& = FRE(-1) - 800                 'Basic Heap - EXE Memory (80000)
A& = SETMEM(-100000)                     'This is the memory freed for
                                           'module and MSE usage.

'                  File Offset Ä¿  ÚÄ Oversampling rate (sound quality)
'                                 
ErrorFlag% = LoadMSE("SB16.MSE", 0, 45, 16384, &HFFFF, &HFF, &HFF)
'                                                       
'       MSE file name ÄÄÙ                ³      ÃÄÄÄÄÄÄÁÄÄÄÄÙ
'                           Buffer size ÄÙ      ÀÄ Autodetect IRQ, base I/O
'                                                  address, and DMA channel

SELECT CASE ErrorFlag%
CASE 0
CASE 1: PRINT "Base I/O address autodetection failure": END
CASE 2: PRINT "IRQ level autodetection failure": END
CASE 3: PRINT "DMA channel autodetection failure": END
CASE 4: PRINT "DMA channel not supported": END
CASE 6: PRINT "Sound device does not respond": END
CASE 7: PRINT "Memory control blocks destroyed": END
CASE 8: PRINT "Insufficient memory for mixing buffers": END
CASE 9: PRINT "Insufficient memory for MSE file": END
CASE 10: PRINT "MSE has invalid identification string (corrupt/non-existant)": END
CASE 11: PRINT "MSE disk read failure": END
CASE 12: PRINT "MVSOUND.SYS not loaded (required for PAS use)": END
CASE ELSE: PRINT "Unknown error on MSE startup" + STR$(ErrorFlag): END
END SELECT

ErrorFlag% = 0  'DONT use EMS

File = FREEFILE                            'Get a free file handle number
OPEN "1.GDM" FOR BINARY AS File         'Open the module in binary mode
'                  ÚÄ Calling: Load Flags (EMS enable)
'Load our module:    Returns: Error flag (0 - no errors) Call
LoadGDM FileAttr(File, 2), 0, ErrorFlag%, VARSEG(ModHeader), VARPTR(ModHeader)
'                                
'   File ÄÙ   ÀÄ Offset into       ÀÄ Module header that you can use later
' Handle         file to load         to get information on the GDM loaded.
'                from.

SELECT CASE ErrorFlag%
CASE 0
CASE 1: PRINT "Module is corrupt": END
CASE 2: PRINT "Could not autodetect module type": END
CASE 3: PRINT "Bad format ID": END
CASE 4: PRINT "Out of memory": END
CASE 5: PRINT "Cannot unpack samples": END
CASE 6: PRINT "AdLib samples not supported": END
CASE ELSE: PRINT "Unknown Load Error:" + STR$(ErrorFlag): END
END SELECT

CLOSE File                                 'Close the file handle..

MusChans = 0                               'Start out at zero..
FOR J = 1 TO 32                            'Scan for used music channels
  IF ASC(MID$(ModHeader.PanMap, J, 1)) <> &HFF THEN
    MusChans = MusChans + 1
  END IF
NEXT

'   ÚÄ Actual oversampling rate in use (Hz)
'   
OverRate& = StartOutput(MusChans, 0)      'Start your (sound) engines
'                                
'# of Music+Sound channels ÄÙ     ÀÄ Amplification level (0 - none)






                         ' speed and minimum size
pi! = 3.141592654


rem *** this is the IJSKAST 64k intro for bizarre 1999 ***
cls
color 7
screen 0
print "Choose your sound card - using IJSKASTplayer"
print
locate ,19
print "1.   Gus"
locate ,19
print "2.   Soundblaster"
locate ,19
print "3.   Adlib"
locate ,19
print "4.   IBM sound tech."
locate ,19
print "5.   Internal speaker"
locate ,18
print "5«.   PAS16"
locate ,19
print "6.   beeper"
locate ,19
print "7.   EWS64XL
locate ,19
print "8.   SB AWE64/32"
locate ,19
print "9.   diskdrive"
locate ,19
print "A.   HardSID"
locate ,19
print "B.   Double HardSID (stereo!)"
print "any key will do for.   No Sound"
locate 15,60
input "";hallo_nu_een_variabele_invoeren_aub

color 31
locate 18
print "warning. you do not have the card you selected"
print "we'll try a SB16, if it crashes, you don't have one."

delay 3.5





screen 0
cls
delay .5
locate 10,33
color 2
print "L O A D I N G"
for t = 12 to 14
locate t,32
print "[             ]"
delay .2
next t
color 10
for x = 12 to 14
for t = 33 to 45
locate x,t
print "-"
delay .1
next t
next x
delay .1
for x = 32 to 40
for t = 10 to 14
locate t,x
print " "
locate t,79-x
print " "
next t
delay .1
next x


StartMusic                                'Enable the music play flag
'Music should be playing now.



SCREEN 12
FOR r = 1 TO 210
CIRCLE (320, 240), r, (r*r/pi!), SIN(r / 2000000 * pi!) * 2 * pi!, r / 210 * pi!
NEXT r

locate 10,29
print "IJSKAST"
locate 13,25
print "PRESENTS"
locate 17,39
print "CLOSE YOUR EYES"
color 7
locate 19,43
print "Close Your Eyes"
color 8
locate 21,47
print "close your eyes"
delay 4
cls



color 7
screen 12
for t = 0 to 80
pset (t+320,224)
pset (320-t,224)
pset (t+320,226)
pset (320-t,226)
delay .05
next t

for t = 0 to 85
line (241,224+t)-(399,224+t),0
line (241,226-t)-(399,226-t),0
line (240,225+t)-(400,225+t)
line (240,225-t)-(400,225-t)
delay .05
next t


locate 11,36
print "IJSKAST is"
delay .3
locate 13,32
print "about to infiltrate"
delay .3
locate 15,33
print "your nervesystem"
delay .3
locate 17,32
print "escape now you can"
color 8
delay 3
locate 19,34
print " we warned you"
delay .4
for t = 0 to 80
line (241+t,140)-(241+t,310)
line (399-t,140)-(399-t,310)
delay .05
line (240+t,140)-(240+t,310),0
line (400-t,140)-(400-t,310),0
next t

screen 12
color 15
locate 10,42
print "IJSKAST wAS fOUNDED"
delay .3
color 7
locate 12,20
print "oN jUNE tHE 4TH 1999"
delay .3
color 8
locate 14,42
print "tHIS iS oUR fIRST dEMO"
delay .3
color 7
locate 16,22
print "cLOSE yOUR eYES"
delay .3
color 15
locate 18,42
print "fOR oPTIMAL pLEASURE"
delay 1
for t= 1 to 210
pset (320+t,140)
pset (320-t,140)
next t

color 7

for t = 0 to 170
pset (530,140+t)
pset (110,140+t)
next t

for t = 0 to 170
line (110,140+t)-(530,140+t)
delay .03
line (110,139+t)-(530,139+t),0
next t


color 15
for t = 0 to 40
line (110,310+t)-(530,310+t)
pset (110,310+t)
pset (530,310+t)
pset (319,310+t)
pset (321,310+t)
pset (320,310+t),0
delay .03
line (111,309+t)-(318,309+t),0
line (322,309+t)-(529,309+t),0
next t
pset (320,350)

for t = 0 to 360
line (531-t,310)-(531-t,350),0
line (321-t/2,310)-(321-t/2,349),0
line (320-t/2,310)-(320-t/2,349)
line (530-t,310)-(530-t,350)
delay .027
next t
color 7
2
locate 21.1,24
print "elcome to this wonderful world
delay 2
color 15
locate 13,40
print "Please close your eyes now"
line (300,190)-(530,210),,b
delay 1
for t = 15 to 22
locate t,6
print "                                                        "
next t

for t = 0 to 640 step 5
line (t,0)-(300,190),t
line (t,0)-(530,190),t+8
line (t,480)-(300,210),t
line (t,480)-(530,210),t+8
next t

delay 2



1
rem *** initialize **************************************************effect 1
tim& =0
screen 7 '200x320
y=8
x=2
t1!=160
t2!=100
z=10
a=0
print "        Oh boy, this really sucks"
print "            don't U think....
locate 24,1


rem *** main loop ***
do until inkey$ <> ""
tim& = tim& +1
if tim& = 50000 then goto 99

'locate 1,1
'print t1,t2
if z=10 then gosub 10
if z=20 then gosub 20
if z=30 then gosub 30
if z=40 then gosub 40
if t1! <200 and t1! > 120 and t2! <120 and t2! >80 then y=8
if t1! >200 or t1! < 120 or t2! >120 or t2! <80 then y=7
if t1! >250 or t1! < 70 or t2! >160 or t2! <40 then y=15
loop


rem *** movement of circles ***
10
incr t1!,1.6
incr t2!
circle (t1!,t2!),x,y
circle (t1!,t2!),x+1,0
circle (t1!,t2!),x+2,0
circle (t1!,t2!),x+3,0
if t1!>= 300 then z=30
if t2!>= 180 then z=20

return

20
incr t1!,1.6
decr t2!
circle (t1!,t2!),x,y
circle (t1!,t2!),x+1,0
circle (t1!,t2!),x+2,0
circle (t1!,t2!),x+3,0

if t1!>= 300 then z=40
if t2!<= 20 then z=10

return

30
decr t1!,1.6
incr t2!
circle (t1!,t2!),x,y
circle (t1!,t2!),x+1,0
circle (t1!,t2!),x+2,0
circle (t1!,t2!),x+3,0

if t1!<= 20 then z=10
if t2!=> 180 then z=40
return

40
decr t1!,1.6
decr t2!
circle (t1!,t2!),x,y
circle (t1!,t2!),x+1,0
circle (t1!,t2!),x+2,0
circle (t1!,t2!),x+3,0
if t1!<=20 then z=20
if t2!<=20 then z=30

return

99
tim& =0
rem ****************************************************************effect 2!
cls


'wat een onzin
'door B.S.E
'paar vage bugs, helemaal rechts is ook een beetje links
'TSJEESUSs, zo'n overzichtelijk proggie heb ik nog nooit gemaakt


rem *** Initialize ***
screen 7 '320,200
x!=0
xx!=160
yy!=100

rem *** Prints text on screen ***
print "    Uh oh it's getting worse!!!!!"
100    'Start loop
   incr tim&: if tim& = 150000 then goto 199
   rem *** reads keyboard input ***
   a$ = inkey$

      rem *** Draws a strange object on the screen and deletes a larger one ***
      circle (xx!,yy!),60,0,x!,x!,tan(sin(cos(tan(x!))))
      incr x!,.1
      circle (xx!,yy!),30,x!,x!,x!,tan(sin(cos(tan(x!))))

      rem *** Random movement of the object ***
      randomize timer
      x1! = rnd*.1-.05
      y1! = rnd*.1-.05
      xx!=xx!+x1!
      yy!=yy!+y1!

        rem *** Make sure it doesn't fall of the edge ***
        if x!>100 then x!=0   'small bug, probably -x- gives error when too high
	if xx!<0 then xx!=1
	if xx!>320 then xx!=319
	if yy!<90 then yy!=91
	if yy!>200 then yy!=199

   rem *** -q- or -esc- to quit ***
   if a$ = "q" then end
   if a$ = chr$(27) then end

   rem *** Yes, you can help moving the object ***
   if a$ = chr$(0,75) then xx!=xx!-10 'left
   if a$ = chr$(0,77) then xx!=xx!+10 'right
   if a$ = chr$(0,80) then yy!=yy!+10 'down
   if a$ = chr$(0,72) then yy!=yy!-10 'up

goto 100 'return to beginning

199
tim& =0
rem *****************************************effect 3 alweer (hoi!)
cls
screen 7
rem *** first some precalculations ***
        cls
        print "Did"
        print "you"
        print "find"
        print "the"
        print "hidden"
        print "bug?"
	tim& =0
        pi!= 3.141592654
	z! = 180 / pi!
        zz!= 360 / z!
        zzz! = .1
        t! = 0
        color 15
        a=10
        c=100
        z!=.1
rem *** Main program ***
200 a$ = inkey$
if a$ = chr$(27) then end
incr tim&,1

if tim& = 30 then gosub 210
if tim& = 50 then gosub 220
if tim& = 100 then goto 299
	x! = sin(t!)
	x2!= sin(t!-zzz!)
	y! = cos(t!)
	y2!= cos(t!-zzz!)
                for b = 10 to c step a
        		pset (160+x!*b,100-y!*b)
	                pset (160+x!*(b+a/2),100+y!*(b+a/2))
                next b
                delay .1
                for b = 10 to c step a
		        pset (160+x2!*b,100-y2!*b),0
		        pset (160+x2!*(b+a/2),100+y2!*(b+a/2)),0
                next b
	incr t!,zzz!
goto 200
210 locate 10
print "Which"
print "one? "
return

220
locate 15
print "There"
print "were"
print "so"
print "many..."
return



250
t=0
for x! = 1 to 80000
incr t!,1.1
pset (t!,(230*cos(t!))),t!
pset (t!,(250/cos(t!))),t!
pset (310*cos(t!),t!),t!
pset (330/cos(t!),t!),t!
if t! > 640 then t!=t!-640
next x!
t!=640
for x! = 1 to 100000
decr t!,1.1
pset (t!,(230*cos(t!))),0
pset (t!,(250/cos(t!))),0
pset (310*cos(t!),t!),0
pset (330/cos(t!),t!),0
if t!<1 then t!=t!+640
next x!
return





299
rem ******************************************************yes yes effect 4
color 1
tim& =0
REM *** Main Program ***
screen 12 'Resolution of 640 x 480

t=1       'Start position = top left corner, -why? -why not?
tt=1      't = horizontal, tt = vertical
pl=30     'How many pixels to centre moves
kkk = 0
goto 310


300       'main loop
if inkey$ <> "" then end
incr tim&
incr kkk
if tim& = 175 then goto 399
for te = 0 to 480 step 80   'Draws to lines from certain points
for tel = 0 to 640 step 80  'to the centre (t,tt)
line (tel,te)-(t,tt),kkk
next tel,te

return


310                         'Routine for moving to the right and bottom
gosub 390                  'Goes to the place for removing "old" lines
incr t,pl
incr tt,pl
if t> 620 then goto 320     'Make sure it doesn't bounce of the edges
if tt> 460 then goto 340
gosub 300                    'Move to the main loop, which draws to lines
goto 310

320                         'Move to the left and bottom
gosub 390
decr t,pl
incr tt,pl
if t< 20 then goto 310
if tt> 460 then goto 330
gosub 300
goto 320

330                         'Move to the left and top
gosub 390
decr t,pl
decr tt,pl
if t< 20 then goto 340
if tt< 20 then goto 320
gosub 300
goto 330

340                         'Move to the right and top
gosub 390
incr t,pl
decr tt,pl
if t> 620 then goto 330
if tt< 20 then goto 310
gosub 300
goto 340


390                        'removes the "old" lines from the screen

for te = 0 to 480 step 80
for tel = 0 to 640 step 80
line (tel,te)-(t,tt),0      '...,0 means color = black, so delete line
next tel
next te

return

399
tim&=0
rem *****************************************************555555555555


screen 12
x=40
locate 20,20
color 1
print "CODE    KOMBI.IJSKAST"



400 a$ = inkey$
incr tim&
if tim& =3001 then gosub 250:goto 499
if a$ = "q" then end
x=x+1
gosub 420
if x=440 then goto 410
goto 400

410 a$ = inkey$
if a$ = "q" then end
x=x-1
gosub 430
if x=40 then goto 400
goto 410

420
line (x,100)-(x,200)
line (x-1,100)-(x-1,200),0

line (480-x,100)-(480-x,200)
line (481-x,100)-(481-x,200),0

line (x,100)-(480-x,200)
color 12
return

430
line (x,100)-(x,200)
line (x+1,100)-(x+1,200),0


line (480-x,100)-(480-x,200)
line (479-x,100)-(479-x,200),0

line (x,100)-(480-x,200)
color 4
return


499
cls
tim&=0
rem *****************************************************5555555-2222222


screen 12
x=40
locate 5,50
color 4
print "MUSIC    JEUK.IJSKAST



500 a$ = inkey$
incr tim&
if tim& =3001 then gosub 250:goto 599
if a$ = "q" then end
x=x+1
gosub 520
if x=440 then goto 510
goto 500

510 a$ = inkey$
if a$ = "q" then end
x=x-1
gosub 530
if x=40 then goto 500
goto 510

520
line (x,200)-(x,300),1
line (x-1,200)-(x-1,300),0

line (480-x,200)-(480-x,300),1
line (481-x,200)-(481-x,300),0

line (x,200)-(480-x,300),1
color 12
return

530
line (x,200)-(x,300),9
line (x+1,200)-(x+1,300),0

line (480-x,200)-(480-x,300),9
line (479-x,200)-(479-x,300),0

line (x,200)-(480-x,300),9
color 4
return

599
tim&=0
cls
rem *****************************************5555555555555-4444444444


screen 12
x=40
locate 20,20
color 1
print "GRAPHIX    BEMMEL.IJSKAST"



600 a$ = inkey$
incr tim&
if tim& =3001 then gosub 250:goto 649
if a$ = "q" then end
x=x+1
gosub 620
if x=440 then goto 610
goto 600

610 a$ = inkey$
if a$ = "q" then end
x=x-1
gosub 630
if x=40 then goto 600
goto 610

620
line (x,100)-(x,200)
line (x-1,100)-(x-1,200),0

line (480-x,100)-(480-x,200)
line (481-x,100)-(481-x,200),0

line (x,100)-(480-x,200)
color 12
return

630
line (x,100)-(x,200)
line (x+1,100)-(x+1,200),0


line (480-x,100)-(480-x,200)
line (479-x,100)-(479-x,200),0

line (x,100)-(480-x,200)
color 4
return




649
rem  **********************************55555555555555555555-6666666666666666
tim&=0
cls



screen 12
x=40
locate 5,40
color 4
print "RED BULL PROVIDER     KLEVER.IJSKAST"
locate 6,35
print "also spiritual advisor"



650 a$ = inkey$
incr tim&
if tim& =3001 then goto 699
if a$ = "q" then end
x=x+1
gosub 670
if x=440 then goto 660
goto 650

660 a$ = inkey$
if a$ = "q" then end
x=x-1
gosub 680
if x=40 then goto 650
goto 660

670
line (x,200)-(x,300),1
line (x-1,200)-(x-1,300),0

line (480-x,200)-(480-x,300),1
line (481-x,200)-(481-x,300),0

line (x,200)-(480-x,300),1
color 12
return

680
line (x,200)-(x,300),9
line (x+1,200)-(x+1,300),0

line (480-x,200)-(480-x,300),9
line (479-x,200)-(479-x,300),0

line (x,200)-(480-x,300),9
color 4
return






699
rem ********************************666666666666666666666666666
tim& =0

cls
screen 12

for x = 200 to 400
circle (320,220),x,x
next x

x=0
t=0
700 b$ = inkey$
tim&=tim&+1
if tim& = 1500 then gosub 710
if tim& = 5000 then goto 799
if b$ = "q" then end
circle (320,220),x,t
x=x+1
t=t-1
if x = 150 then x = 0
goto 700

710
for t = 401 to 199 step -1
circle (320,220),t,0
next t
return

799
rem *************************************************7777777777777777

x=1
hoogte = 60

step1 = 5
step2 = 3


for t = 1 to 55000
incr x,step2
line (x*step1,(sin(x))*50+hoogte)-((x-step2)*step1,(sin((x-step2)))*50+hoogte),c

randomize timer
c = int(rnd*15)+1

if x>130 then x=x-128:   incr hoogte,1
if hoogte > 500 then hoogte=hoogte-439

next t

999
rem ************************************************greetz

cls
screen 7
print "
print "
print "
print "
print "
print "
print "
print "
print "
print "
print "
print "
print
print
print
print
color 2
line (60,20)-(100,30)
line (100,30)-(100,90)
line (60,20)-(58,48)
line (58,48)-(100,58)
line (100,90)-(55,84)
color 5
line (120,25)-(115,90)
line (120,25)-(150,40)
line (150,40)-(118,60)
line (118,60)-(155,95)
color 9
line (165,20)-(165,80)
line (205,20)-(205,80)
for t = 20 to 80 step 30
line (165,t)-(195,t)
line (205,t)-(235,t)
next t

color 10
line (60,15)-(300,15)
line (260,15)-(250,90)

color 11
line (270,30)-(295,25)
line (270,30)-(265,50)
line (265,50)-(290,45)
line (290,45)-(285,70)
line (285,70)-(260,75)


color 5
print "IJSKAST WOULD LIKE TO GREET EVERYBODY"
print "WHO VOTED FOR US"
print "AND THAT INCLUDES YOU!"
print
print
print ".............well it better include you"
delay 6


1999
rem *********************************************************endsortoff

'quote van de dag
'ik zie door de blikjes bier mijn monitor niet meer

cls
screen 12
x!=320
y=240
w!=320
v!=320
circle (x!,y),319

2100
a$ = inkey$
if a$ <> "" then end
circle (x!+2,y),100,0
circle ((x!*1.1)+2,y),120,0
circle (v!+1,y),160,0
x! = x! -1
w! = w! -.9
v! = v! -.75
if x!= 110 then goto 2200
circle (x!,y),100,8
circle ((x!*1.1)+2,y),120,7
circle (v!,y),160,15
goto 2100

2200
a$ = inkey$
if a$ <> "" then end
circle (x!-2,y),100,0
circle (w!-2,y),120,0
circle (v!-1,y),160,0
x!=x!+1
w!=w!+.9
v!=v!+.75
if x!= 530 then goto 2500
circle (x!,y),100,8
circle (w!,y),120,7
circle (v!,y),160,15
goto 2200
end

2500
cls
z=220
y=140
x=420
w=340
for t = 0 to 200
line (z-t,y-t)-(x-t,w-t),3,b	'cube
line (z-t,y+t)-(x-t,w+t),1,b	'cube
line (z+t,y-t)-(x+t,w-t),1,b	'cube
line (z+t,y+t)-(x+t,w+t),3,b	'cube
delay .005
next t

for t = 0 to 200
line (z-t,y-t)-(x-t,w-t),4,b	'cube
line (z-t,y+t)-(x-t,w+t),2,b	'cube
line (z+t,y-t)-(x+t,w-t),4,b	'cube
line (z+t,y+t)-(x+t,w+t),2,b	'cube
delay .005
next t

for t = 0 to 200
line (z-t,y-t)-(x-t,w-t),5,b	'cube
line (z-t,y+t)-(x-t,w+t),5,b	'cube
line (z+t,y-t)-(x+t,w-t),6,b	'cube
line (z+t,y+t)-(x+t,w+t),6,b	'cube
delay .005
next t
for t = 0 to 200
line (z-t,y-t)-(x-t,w-t),7,b	'cube
line (z-t,y+t)-(x-t,w+t),8,b	'cube
line (z+t,y-t)-(x+t,w-t),8,b	'cube
line (z+t,y+t)-(x+t,w+t),7,b	'cube
delay .005
next t

for t = 0 to 200
line (z-t,y-t)-(x-t,w-t),9,b	'cube
line (z-t,y+t)-(x-t,w+t),10,b	'cube
line (z+t,y-t)-(x+t,w-t),9,b	'cube
line (z+t,y+t)-(x+t,w+t),10,b	'cube
delay .005
next t

for t = 0 to 200
line (z-t,y-t)-(x-t,w-t),11,b	'cube
line (z-t,y+t)-(x-t,w+t),11,b	'cube
line (z+t,y-t)-(x+t,w-t),12,b	'cube
line (z+t,y+t)-(x+t,w+t),12,b	'cube
delay .005
next t

for t = 0 to 200
line (z-t,y-t)-(x-t,w-t),13,b	'cube
line (z-t,y+t)-(x-t,w+t),14,b	'cube
line (z+t,y-t)-(x+t,w-t),14,b	'cube
line (z+t,y+t)-(x+t,w+t),13,b	'cube
delay .005
next t
2000
for t = 0 to 200
line (z-t,y-t)-(x-t,w-t),15,b	'cube
line (z-t,y+t)-(x-t,w+t),7,b	'cube
line (z+t,y-t)-(x+t,w-t),15,b	'cube
line (z+t,y+t)-(x+t,w+t),7,b	'cube
delay .005
next t


for x! = 0 to 320 step .1
line (x!,0)-(x!,480),x!
line (640-x!,0)-(640-x!,480),x!
line (x!-20,0)-(x!-20,480),0
line (660-x!,0)-(660-x!,480),0
next x!
cls






2800
color 14
locate 5,41
print "O
locate ,41
print "P
locate ,41
print "E
locate ,41
print "N
locate ,41
print "
locate ,41
print "S
locate ,41
print "O
locate ,41
print "U
locate ,41
print "R
locate ,41
print "C
locate ,41
print "E
locate ,41
print "-"
locate ,41
print "C
locate ,41
print "O
locate ,41
print "D
locate ,41
print "E
locate ,41
print "
locate ,41
print "R
locate ,41
print "U
locate ,41
print "L
locate ,41
print "E
locate ,41
print "Z

        x=0
        t=0
do until inkey$ = chr$(27)
        incr x,1
        line (cos(x),t)-(313,cos(x)*240+240),x
        line (t+640,cos(x))-(333,cos(x)*240+240),x
        if x = 3000 then goto 2999
loop




2999
cls
color 7
cls
locate 14,40:print "end"
color 8
locate 16,50
print "You can open your eyes again"
do until inkey$ <> ""
loop

StopMusic                               'Disable music processing
StopOutput                              'Stop all sound output
UnloadModule                            'Free module memory
FreeMSE                                 'Remove MSE from memory

