
STACK  SEGMENT WORD STACK  'STACK'
        db 256 dup(?)
STACK  ENDS

PDATA  SEGMENT PARA PUBLIC 'PDATA'              ; Segment for the Vibrants Player

        ; Player and music segment

        INCLUDE driver.inc   ; driver include file
        MusicOffset = $-PDATA                   ; Offset for the music
        INCLUDE song.inc     ; the music!

PDATA  ENDS

DAMSEG SEGMENT PARA PUBLIC 'DAMIER'             ; Segment pour Damier !!!

Damier LABEL BYTE
       INCLUDE damrol3.asc      ; Damier (384+16)x90


;======= FLAMOOTS DATAS ========

Bonhom LABEL BYTE
       INCLUDE bonhom1.cga     ; mascotte !!!!!
       INCLUDE bonhom2.cga     ; 40x46 4 colors
       INCLUDE bonhom3.cga
       INCLUDE bonhom4.cga
       INCLUDE bonhom5.cga

Bonlen EQU 40/4*46+1 ; 1 pour ‚lt. bidon

Joepie LABEL BYTE
       INCLUDE joep1.cga       ; "JOEPIE !!!!!"
       INCLUDE joep2.cga
       INCLUDE joep3.cga
       INCLUDE joep4.cga
       INCLUDE joep5.cga
       INCLUDE joep6.cga

Joeplen EQU 80/4*54+1 ; 1 pour ‚lt. bidon

TFLlogo LABEL BYTE
       INCLUDE tfl.cga         ; TFL Logo !!!

TFLlen EQU 84/4*50+1  ; 1 pour ‚lt.bidon

DAMSEG ENDS

DATA   SEGMENT PARA PUBLIC 'DATA'

Sorry   BYTE 10,13,'Sorry Dude, You must have VGA card to see dis Intro...',10,13,'$'
Sorry2  BYTE 10,13,'Sorry, You must have a 386+ to run dis Intro properly !!!',10,13,'$'

Bye     BYTE 'You can send Email to : llardin@is1.vub.ac.be (Type One)',10,13
        BYTE '          or Fido  to : 2:291/725.2 (Green Kawa)',10,13,10,13
        BYTE '     or Snail Mail to : Laurent Lardinois (Type One)',10,13
        BYTE '                        271 Chauss‚e de Saint Job',10,13
        BYTE '                        1180 Bruxelles - Belgium',10,13,10,13
        BYTE 10,13
        BYTE 'Remember: -= Pleasure Access BBS =- +32-2-3461996',10,13

        BYTE 'CU l8r... (2B lame is good 4U !!!)',10,13,10,13
        BYTE '(C) The FLamoots 1994','$'

Autor   BYTE 10,13,'Dis little Intro was coded by -= Type One =- from TFL',10,13
        BYTE 'Pr‚Tro idea & gfx by -= Fred =- from TFL',10,13
        BYTE 'Zake by Thomas Mogensen (DRAX), tituled "Crooner"',10,13
        BYTE 'AdLib player by JCH from Vibrants/Interface by Patch from Avalanche ;-)...',10,13
        BYTE 'Cool Font by WITAN/"Facts Of Life"....',10,13,10,13,'$'

OldMode BYTE ?

        INCLUDE pa2.pak  ; ANSI P.A. BBS II

;------------------------------

Multi   LABEL BYTE
        INCLUDE multi2.xy

Pattern LABEL BYTE
        INCLUDE bloc4.asc

Copper  LABEL BYTE
        INCLUDE copper2.xx

Ampli   LABEL BYTE
        INCLUDE ampli.tbl

Rolax   LABEL BYTE
        INCLUDE rolax.y
RolaxPTR dw OFFSET Rolax

Vague   LABEL BYTE
        INCLUDE vague.y
VaguePTR dw OFFSET Vague

;--------------------------------------------------------
StartAdr = (384+16)*(90+17+1-1) ; Adr. patterns...
DamierAdr = (384+16)*(17+1)     ; Adr. damier...
ScrexxAdr = 384+16              ; Adr. screxx
;--------------------------------------------------------

Fonte LABEL BYTE                  ; (32+4+1)*3 bytes couleurs RGB
      INCLUDE witan.asc
TabFnt EQU OFFSET Fonte+(32+4+1)*3; Table pr‚-multipli‚e
BitFnt EQU TabFnt+93*2            ; BitMap Fonte

DamPal LABEL BYTE
       REPT 2
        db 32,32,32,40,40,40,48,48,48,56,56,56 ; Palette pour le "damier" !!!
        db 48,48,48,40,40,40,32,32,32,24,24,24
        db 0,0,32,0,0,40,0,0,48,0,0,56
        db 0,0,48,0,0,40,0,0,32,0,0,24
       ENDM
DamPTR dw OFFSET DamPal


Bars db 48,49,50,51,52,53,54,55
     db 56,57,58,59,60,61,62,63
     db 64,65,66,67,68,69,70,71
     db 72,73,74,75,76,77,78,79
     db 80,81,82,83,84,85,86,87
     db 88,89,90,91,92,93,94,95
     db 96,97,98,99,100,101,102,103
     db 104,105,106,107,108,109,110,111
     db 112,113,114,115,116,117,118,119

     db 104,105,106,107,108,109,110,111
     db 96,97,98,99,100,101,102,103
     db 88,89,90,91,92,93,94,95
     db 80,81,82,83,84,85,86,87
     db 72,73,74,75,76,77,78,79
     db 64,65,66,67,68,69,70,71
     db 56,57,58,59,60,61,62,63


     db 120,121,122,123,124,125,126,127
     db 128,129,130,131,132,133,134,135
     db 136,137,138,139,140,141,142,143
     db 144,145,146,147,148,149,150,151
     db 152,153,154,155,156,157,158,159
     db 160,161,162,163,164,165,166,167
     db 168,169,170,171,172,173,174,175
     db 176,177,178,179,180,181,182,183
     db 184,185,186,187,188,189,190,191

     db 176,177,178,179,180,181,182,183
     db 168,169,170,171,172,173,174,175
     db 160,161,162,163,164,165,166,167
     db 152,153,154,155,156,157,158,159
     db 144,145,146,147,148,149,150,151
     db 136,137,138,139,140,141,142,143
     db 128,129,130,131,132,133,134,135

BarPtr dw OFFSET Copper
AmpPtr dw OFFSET Ampli,OFFSET Ampli+512

Rasters LABEL BYTE
       i=0
       db 4 dup(0)
       REPT 63
       db i,i
       db i+1,i+1
       i=i+1
       ENDM
       db 63,63,63

Raster2 LABEL BYTE
       j=0
       REPT 13
       i=0
       REPT 16
       db i,j
       i=i+4
       ENDM
       j=j+5
       ENDM


RastPTR dw OFFSET Rasters,OFFSET Rasters+2

RastPage db 457*4*2 dup(0)
RastPagePTR dw OFFSET RastPage,OFFSET RastPage+457*4

Couleurs LABEL BYTE
       i=0
       REPT 62
       db 2,0,i/2,i
       db 2,0,i/2,i+1
       db 2,0,i/2,i
       i=i+1
       ENDM

       i=0
       REPT 63
       db 0,i,0,0
       i=i+1
       ENDM
       i=0
       REPT 4
       db 0,0,0,i
       i=i+1
       ENDM
       REPT 12
       db 0,0,0,i
       db 0,0,0,i
       db 0,0,0,i+1
       i=i+2
       ENDM
       REPT 35
       db 0,0,0,i
       db 0,0,0,i
       i=i+1
       ENDM
       i=i-1
       REPT 5
       db 0,0,0,i
       db 0,0,0,i
       db 0,0,0,i
       ENDM
       db 0,0,0,0

;------------------------------

Scroll1 db 'salut bande de slaches !!!!        wat du u think about dis ????'
        db '           '
        db ' 384x564 with 820 colors out of 2.097.152 !!!!!     works on ALL vga boards !!!! '
        db '  cool non ???       TIPON is back with the return of the art of coding!!!! '
        db '  alias -=$KUKOO{II$=-   ratatataaaaaammmm !!!!!   kraboum !!!!!! '
        db '                   '
        db '....... okay here i am !!! $TYPE{ONE$ with another small release...'
        db '  dedicated to -=PLEASURE{ACCESS{BBS{II=-  and  --The FLamoots--... '
        db 'enjoy it !!!   I can do more but i want it works on SAM''s 386dx-33mhz '
        db 'isa trident 512ko vga board.... so don''t blame me, huhuhuhu ....'
        db '               '
        db 'GENERAL{GREETINGS :       - CHANNEL{38#INDEPENDANTS (i hope you''ll win in breden'
        db '........better coding dsp asm than cobol, nemrod mmmh ??? :-) '
        db '      - TRB (magic wish is a hit, MESH !!!!     it''s sad '
        db 'you had to sell your falcon, WILD{BRAIN...     SINEW{SHY : call me when you''ll '
        db 'finish krypton egg pc,  so i''ll spread the demo version '
        db 'on the whole universe at the light speed !!!!! nothing can beat internet.... )       '
        db '- SYNERGY{DESIGN (good demo for TCC 93 and the UNDERTAKER is '
        db 'the best HOUSE{MUSIC maker ever seen in the whole universe !!!! '
        db 'it makes me feel so gooooood !!!!)         '
        db '- AVALANCHE (you seems to be very cool guys !!!! '
        db 'congratulations for TEASPOON ;-)... hey PATCH, ready for another kukoo '
        db 'debugging ???.......)      - BUSTER#EXOCET#HYSTERIA{BBS '
        db '(thxx for supporting us !!!)      - IMPHOBIA (you''ve got the best '
        db 'disk-mag !!!!)      - ACCESS{DENIED '
        db '     - VLA (good job on internet !!! keep coding !!!!) '
        db '     - IGUANA (por fin tenemos una verdadera tracker rout. !!!!) '
        db '     - TEQUILLA{AND{SHAMEN (thx for helping us in our beginning on pc...)'
        db '     - VIBRANTS (sorry for ripping your rout !!!) - WITAN (ur fontz '
        db 'are so nice !!!).... '
        db '                   '
        db 'ALL{CREDITS{GO{TO :    SAM  (salut ma biche ...),   FRED  (back to the '
        db 'return met THE{FLAMOOTS{II .....allei chope !!!),    GREEN{KAWA  ('
        db 'salut bon BLEU !!!! content de t''avoir chez nous !!!),    ALDO  ('
        db 'un peu flou peut-etre au niveau de l''ourlet de la fente, mmh ?!? ),'
        db '   FLY  (bier is een plezier !!!),   JF  (accroche toi mec!!! tu vas voir '
        db 'comme c''est bon une session d''exams....),'
        db '   ABDEL  (c''est clair comme les gaufres de liege),'
        db '   WARLOCK{AND{NOISESWAPPER   (how is the amiga world nowadays ???),'
        db '   YVAN{DES{FRITES{ET{BENIN{GODET  (ta des news ???),   NEMROD{AND{FLATLINER (vive '
        db 'le FLACON 030 !!! zallez tous les niquer !!!),   MR{GUN 93 '
        db ' (t''es mort ou koi ????? give me a call !!!),'
        db '   REMORQUE  (on te voit plus beaucoups mec...),'
        db '   RECU  (don''t try dis intro on os2 ;-) .... ),'
        db '   GLU  (elle est mieux kla fois passee l''intro, hein ???? i hope '
        db 'my NO#MORE#VERTICAL#BORDERS#COZ#IT#SUCKS#ROUTINE works on your '
        db 'vga monitor !!!!! ;-) ),   les assistants GREG{ET{FRED  (rendez-vous au '
        db 'MTSM om beter te flamoeteren !!!!)'
        db '  et je salue   TOUS{LES{COPAINS#COPINES{DU{CI !!!!  (et j''emmerde le ndf) '
        db ' (un GRAND merci a tous ceux qui nous ont achete des cassettes $FLAMOOTS{II$...)'
        db '                  '
        db 'well, what about us ???? .... for my part, i''m just beginning '
        db 'my second year in computer science at the university (ULB)..... '
        db 'and it takes me a lot of time, pfiooouuuu !!!!!!   so i''m just '
        db 'CODING#SOUNDTRACKING some stuffs when i have enough free days...'
        db ' (+- every 10 years ;-) ) ....... OK{BON, have you ever eared '
        db 'about The FLamoots ???? no, really ???.. well...euh... '
        db 'so I and some FRIENDS '
        db 'have decided to join our competences for making more cool stuffs '
        db 'in the future (in +-2 years)..... we are only 2 coders for the moment : me '
        db 'TYPE{ONE and SAM (he really likes 80x25 text mode ;-) !!!!) '
        db 'maybe 3 if i get news from MR{GUN .....;-)......there is also '
        db 'our great SYSOP :   GREEN{KAWA... and   -=$PLEASURE{ACCESS{BBS$=-  wich '
        db 'will be operationnal in the beginning of 94   (coz university '
        db 'exams.....)....    other COSYSOP :   FLY for the ARCHIMEDES world '
        db '........'
        db ' but in the BEGINNING there was the FLAMOOTS{MIND !!!!!    a new '
        db 'vision of the existence (BIN{POURQUOI ???) !!!!!   prodigued by '
        db 'our GURU :   -={FRED{IER{=-   '
        db 'a cool long-haired guy, studying at the IAD  (sound engineering), '
        db 'making music (MIDI),  mixing and duplicating  '
        db 'our stuffs and more......  he''s the head of the organisation !!!    '
        db 'there is also ABDEL, our top-model ;-) ,   the KING{OF{FTP !!!!, '
        db 'our inspiration source for the moment.....   '
        db 'so before being a DEMO#BBS group,  we are a bunch of cool guys '
        db 'spending their time laughing,singing,drinking,eating,sleeping and '
        db 'studying (si si ...) .....  arf arf arf gaaaaa gaaaaa meup meup !!!!! '
        db 'pour le reste,  je vous renvois aux vertus du chicon magique : 900 fb'
        db ' avec la chainette.............   -=$THE{END$=-                       '
        db 'no i don''t want to finish dis screxx !!!!!    coz i just found some old '
        db 'lines i wrote 3 years ago in summer 1990 ,  on my good old atari st...   '
        db ' (i was 16 years...)    '
        db 'it may be my first screxx.....   i don''t remember .....   '
        db 'i just remember that we were spending a funny night at FLY (old) house''s , '
        db ' and i had brought my st.......   i had the brillant idea to code a demo '
        db '   and we began to write a text.......     there are some lines written by '
        db ' me, fly and green kawa (ex-rolmops ;-) )       '
        db ' in dis time i wasn''t so flamoots but i coded faster and more than now !!!!  '
        db ' ( snif snif !!!!!! belle epoque... )         '
        db ' so ,   back to the past       :      '


        db 'well, ladies and gentlemen ,  1 minute of silence ,  let me present the blitz demoh, '
        db 'me ...        and my friends.   '
        db 'i''m type 1 from unix mind   (PRE{FLAMOOTS)  ,  a new belgian crew from brussels  (uccle...hi trb '
        db '(the true winner of the gen4 challenge) .   for the frenchies : ''on est belches, une fois !!!!'')  '
        db 'who consists of 4 members :  type 1  ( 16 years,  the best of the crew  (i''ve coded this intro alone '
        db ' as a big boy ...  68000 and gfa '
        db 'coder,  grafist,  etc... works on 1040 ste   (NOW{ON{PC) )  ,  fly  ( 16 years, not ready yet ...may be coder, '
        db 'grafist ... works on amstrad  (ams-crade) cpc 6128  (the 8 bits shit you know) but soon on 1040 ste. '
        db '  (HE{NEVER{OWNS{A{ST{{{{{{JUST{AN{ARCHIMEDES{310{AND{A{PC{386DX40) '
        db '  he''s a very cool long-haired and lamer guy as me    (WHERE{ARE{HIS{LONG{HAIRS{NOW{???) )     '
        db ' rolmops  (16 years, not ready yet ...player , may be gfa coder ...play on 520 st but he''s the '
        db 'youngest best inventor of the world  ( he has used a new process of propulsion for his sixties 50 cc bike '
        db 'with compressed air  (as we can see in mad max but '
        db 'here it''s real),  a reactor,  and another things i''ve forgotten.   the original speed of his bike was 25 '
        db 'kilometers per hours and now he rides at 160 kilometers per hours with pure petrol !!!!! '
        db ' (he should have soon the belgium record with his new 50 cc '
        db 'engine with a speed over 200 kilometers per hours !!!!)     ( LAST{YEAR{KAWA{WAS{DOING{CROSS{COMPETITION{'
        db 'AND{HE{RODE{ON{750CC{BIKE)  '
        db 'frederic (16 years, musician and gfa coder ...works on 260 st (1 meg.) )    (YES,{OUR{'
        db 'GOOD{OLD{FRED{....{NOT{SO{FLAMOOTS{THAN{NOW...;-).     '
        db 'another friends are : eric who code 3d objects and works on a ''bidouilled'' 260 st (2.5 meg., tos 1.0 and '
        db 'tos 1.4 , blitter, arythmetic coprocessor 68882, palet of 32768 colors ,...) '
        db '  bernard v.  ( 16 years !!! , amiga 500 , 1040 stf , c64  and  silicon graphics 3d personal iris workstation (glups...) ) '
        db 'and   bernard f.  ( amiga , good coder)    (MORE{KNOWN{AS{MESH{NOW{...)  '
        db '  jeremy ( st , the best player and the worse guy of the school )   '
        db 'sinew shy (st) and wild brain (amiga) from trb  ,   alex (st) the best swapper.  '
        db '   well, the problem for me to code is i haven''t got any hard disk '
        db 'and any reset-proof ramdisk compatible with my ste.  so this intro is small '
        db 'because i''m not so mad to make a mega demo with this material.  '
        db '   ({THE{PROBLEM{IS{THAT{I{NEVER{SPREADED{OUT{MY{ST{INTROS{COZ{I{WAS{OBSESSING{'
        db 'DOING{A{MEGA{DEMO{.....MY{BIGGEST{ERROR{{{{)    '
        db 'but this scroll line is a true hard scroll text who use the 2 graphixx '
        db 'coprocessors of the ste :   the blitz (for copy screens and font) and the shifter '
        db '(for scroll).    the font i''ve used was ripped  (sorry ...) in the mega'
        db '-hyper-cool-and-hyper-extraordinary ultimate gfa demo  (not the ultimate i hope !!!) '
        db 'from the overlanders.     '
        db 'if you want to modify the speed of this scroll , just try the ''+'' and ''-'' keys.    '
        db 'press the ''*'' key to stop or active the sinus and the ''return'' key to freeze the screen.   '
        db '  ah yeah !  let''s go for some technical informations about this screen .     '
        db 'mmmmmh,  what about a little story ?!?     you really want it?       sure?      well! ... '
        db '  hum! ...    let''s go! ...    (what can i say?) ...   (shit ,it''s difficult!) ... '
        db 'for the moment i''m trying to search a story not too bad but i''m really out of ideas.   '
        db 'i''m listening to the radio ( raaaaaaaaadio kontakt !! , le p''tit dofin bleuh,  kwa !! )    '
        db 'there''s ''flagrant desir'' at the speaker and that''s make me shit...  i resume the words of this ''beat'' : '
        db ' '' c''est fou les trucs que tu sais m''faire !!!  je m''sens au bord de la crise de nerf !!! '
        db '  ( it''s crasy the things you make !!!  i feel so hysterical )   c''est tchaikovski !!!  '
        db ' swinger sur un beat en folie .   je m''suis pointe chez le d-j.   hey mec  '
        db ' qu''est-ce que tu (me) fais ?   refrain :  c''est mou !!!.   c''est dur !!! '
        db ' ( refrain : it''s soft !!!  it''s hard !!!)  et le d-j fou crie dans le micro !!! ''   etc...'
        db '  and all this mixture with a hyper-hysterical house beat  !!! ( boaf...)   ah yeah !!! '
        db 'i''m flying !!! (i''m burrying myself !!!  this is the shamest ''music'')    it''s good !!! '
        db 'aaaaaaaahhhh!!!  ooooooooooohhhh!   uuuuuuuuuuuhh!   euh?!!? mmmmmmmmmmmh?!?   '
        db 'gngngngngngngngn !!!! uh? wha? hon?  oh oh oh oh oh !!! excuse me..... i i i i i''m i''m sorry !!! '
        db 'i was in the w.c. (pipi-room) !!!!  will you another story ?!?  no !!!  ok...  '
        db ' my lamer friend fly  (on the beat !!!) will say something :     '
        db 'my friend,  type 1 , is the biggest lamer of the crew   (pas vrai ?) ... he says '
        db 'i''m on the beat , i''m flying ...let''s speak this son of a bitch ... what i like in this music ??? '
        db '  just the girl ''s singing... great voice ... great buttocks and big '
        db 'breast but she''ll never suck a lamer as me ......what can i say ???......i''m the oldest of the crew '
        db ',no... it''s frederic... yeah !! techno at the radio !!! all the girls of belgium dance on this beat at '
        db 'the disco (with me ??? ....... no!!!'
        db '        aaaaaaaargh !!! shit !!! fuck !!! ).... when they ''re dancing ......... i go to the w.c. to do others '
        db 'things  ''....scletchhh..gletch.??''    (BRANLEUR{VA{{)    after four years of experience i have a good imagination '
        db '(type 1 is the same as me for that but he '
        db 'doesn''t say that   ({MOI{???{JAMAIS{{!!!!;-){{ )...).   i''m boring of this stupid real story   ....  '
        db 'i''m going to speak about my feats on the shittest 8 bits of the world (cpc) !!!   ({{BURP{{!!!) '
        db 'last year i understand how to put up a picture on the screen ...  it''s at this moment i began to ''code'' '
        db '   ({ARF{ARF{)...first i made a super bip-bip music ... second i slept...i went '
        db 'to my friend''s house  (type 1)  and i saw the funny union and cuddly demos   (one day i''ll code as tcb ?  {{NEVER{{) '
        db 'shame on me,  i''m a worm.... the next day i try to do an overscan ... after 2 months i finished my first '
        db 'overscan source code ... ( i hope be able to do that on st     ({YOU{SHOULD{HAVE{A{ST{BEFORE{) ).... '
        db 'hardscroll ....deformation....60hz...i do that simply, in amstrad basic...'
        db 'end of the story ...beautiful ..no?     no!?      ok, guys !!!  i''ll try to do better for the next time '
        db ' (excuse me for my bad english !!!!).   see ya !!!!  '
        db '      hi guys and girls  (let''s go for a party ''mes poulettes'' !!!!) , i''m rolmops '
        db ' (the best genius , the greatest inventor , the most handsome , the strongest , etc...   ({LE{PLUS{VEINARD{SURTOUT{)'
        db '    come on girls !!!!!  i have got conversation and more !!!!  not as these lamers as '
        db 'fly and type 1) '
        db 'i''m the most popular  (don''t you know me ?  really ?   ask at your girlfriends !!!!) .'
        db '  i have a name in each language... french:  rolmops,  spanish:  el hombre a la cabeza de pescado, '
        db 'english: fishstick, in dutch  (vlaaaaaams): viskop, etc...    '
        db 'try to beat this stupid name !!!  (just pee-wee believe beat me...)    '
        db 'i want to give a message at all the girls of europe (...the world): come to my house !!!! '
        db 'come on my megamighty bike !!!!  and let''s go for a tour at a speed of 200 kilometers per hours !!! '
        db ' yeaaaaah ,good vibrations !!!!!!   '
        db 'phone number: (02) 378.19.47 (belgium) (arabics and pakis don''t phone !!!!! '
        db '    {HE''S{GOT{A{NEW{NUMBER{NOW{{.....   {CONTACT{HIM{ON{PA{BBS{{{{ )'
        db '  hi guys !!!  here is the real rolmops !!! it''s this bloody bastard of type 1 who spoke for me    ({HI{HI{HI{)...  '
        db 'i''m not a ''macho'' ({MENTEUR{) !!!!!!! i''m a serious young man   ({PFFFF{)   and i''m not lucky with the girls ({MON{OEUIL{)'
        db '   ( so i hope you ''ll find one for me !!! )    '
        db 'but i really have a super-bike but it ''s not ready yet .   if someone in the world is able '
        db 'to beat me in this domain ,  please contact me   (i accept any challenge)  '
        db 'i hope you will have fun with this intro .   see you soon !!!   (ciao chicas !!!)    '
        db ' 5    4     3     2     1      0    yeaaaaaaaaaah !!!!!   the return of type 1 !!!!!!    ({J''ETAIS{TRES{FORT{A{L''{EPOQUE{) '
        db ' fuck your mother, sisters and cats , sucker !!!!!   it''s 5 a.m , now !!!   it''s a good night !!!!  '
        db ' we have an explosive dynamisme !!!  3 hours before we have laughed , ''coz we had an interesting conversation . '
        db ' we have found new ideas that will change the life of each other in the future !!!!!   '
        db ':  t h e   r e t u r n   i n   t h e   p a s t  !!!!!!    yeaaaah as the erectus men !!!  '
        db '   we were eating chicken, porridge and coke by hand in the same plate !!!!    ({AAAH{JE{ME{RECONNAIS{BIEN{{)'
        db 'great  !!!!   but there was a problem.   yes, we were sitting on chairs !!!!  (do you understand ?)   '
        db ' but our ancestors were eating on the ground around a fire !!!!  '
        db 'but a great idea , suddenly , appeared in the mind of a girl who was sitting there with us :  '
        db '  we had to destroy the table with a hammer ...   yes , but there was another problem  :   the table worthed many money .  '
        db '  but another brillant idea appeared in the girl''s mind  :   we had to send the hammer after destroying the table !!!!   '
        db ' my reply was :   ''this was an intelligent deduction !!!''    (this story is true)   '
        db '   now me, fly and rolmops are watching the screen with fish eyes with one idea in our mind  :   we haven''t '
        db 'slept !!!!   and all that for this stupid text you are reading,  son of a bitch !!!!!    '
        db ' 5    4    3    2    1    0    ahahahah ???   this beginning likes shit!!!!  (fly) my little story '
        db 'about the belgian girls wasn''t true    ({MENTEUR{)   !!!  yeah what inspiration !!!!  '
        db 'i never go to the w.c to do ...   ({NO{BUT{IN{YOUR{BED{{{)   !!! b u t  if you have too '
        db 'many girls (14 to 25 years)    {{RECTIFIONS{{:(18 to 25 years)  '
        db 'send a letter (4 place saint job, uccle ( ? ? ? belgium ? ? ? )    ({IL{HABITE{PLUS{LA{)!!!!)'
        db '  all the coders speak over their life (...girlfriends , sport , music, films...) '
        db '  so    what about my girlfriend ?    she has a bad name : n o b o d y !!!  '
        db ' it like lame at 16 years ?'
        db 'no ??      ({A{20{ANS{C''EST{ENCORE{PLUS{CHIANT{{!!!{{{{{{BORDEL{{{DES{{LOCHES{{KOI{{{!!!!{A{POIL{!!!)  '
        db '.....  (type 1 and rolmops ....same for girls!!!)                '
        db ' -=$THE{END$=-        et oui c''etait le bon vieux temps !!!!!!!! '
        db ' allez c''est repartit pour un autre tour !!!!!                    '

        db 0
Scroll1PTR dw OFFSET Scroll1
Scroll1Col dw 0

;------------------------------



Banderolle db '****************************************'
           db '*        - PLEZIER ACCESS BBS -        *'
           db '****************************************'
           db '*  SysOp  : Green Monkey               *'
           db '* CoSysOps: Tampon - FLI - Pirate 2000 *'
           db '*--------------------------------------*'
           db '*  ALL for ZX81 - VIC20 - COPAM 8088   *'
           db '*  1 node running on SNUL KIT 300 bds  *'
           db '*    5:30pm - 8h30pm / 10Mo On-line    *'
           db '*      - !!! WINDOWS INSIDE !!! -      *'
           db '*--------------------------------------*'
           db '*  Remember: never forget to brush     *'
           db '*  your teeth before going to bed !!!  *'
           db '****************************************'
           db 10 dup(10,13),'$'

Skroll     db 10,13,'$'
GWBASIC    db 'PURE GW BASIC...                        '
           db '$'


;-------- Braban‡onne ---------

Brabant    db 7,2
           db 4,2*3
           db 5,2
           db 7,2*4
           db 9,2*3
           db 11,2
           db 12,2*3
           db 11,2
           db 12,2*3
           db 14,2
           db 11,2*6

Brablen    EQU ($ - (OFFSET Brabant))/2

;------------------------------

DATA    ENDS


.286
CODE  SEGMENT WORD PUBLIC 'CODE'
      ASSUME  CS:CODE, DS:DATA, SS:STACK

;---- MACROs ----

HSYNC MACRO          ; !! Sp‚cifique aux Rasters !!
      LOCAL lab1,lab2
;      mov  ah,dl

      mov  dx,03dah
lab1: in   al,dx
      jmp  $+2
      test al,01
      jnz  lab1
lab2: in   al,dx
      jmp  $+2
      test al,01
      jz   lab2

;      mov  dl,ah
      ENDM

VSYNC MACRO
      call WaitVbl
      ENDM

STARTUP MACRO
        mov ax,DATA
        mov ds,ax
        ENDM

EXIT    MACRO
        mov ax,4c00h
        int 21h
        ENDM

MPUSH   MACRO reg1:REQ,reg2:VARARG   ; Vive Y.Roggeman/Greg & ses Macros
        push reg1                    ; recursives !!!!!!! yahouuuuu !!!
        IFNB <reg2>
        MPUSH reg2
        ENDIF
        ENDM

MPOP    MACRO reg1:REQ,reg2:VARARG   ; bis bis !!!
        IFNB <reg2>                  ; type brol = record....
        MPOP reg2                    ; donc ‡a fait 20 bytes !!!
        ENDIF                        ; donc 1 word ....
        pop reg1                     ; brol je dis struct !!!
        ENDM

WRITE   MACRO val:REQ
        push dx
        mov dx,3ceh
        mov ax,4005h OR (val*256)
        out dx,ax
        pop dx
        ENDM


;----------------

;---------------------- INIT ------------------------------------------

GO:      STARTUP

         mov     ah,0fh
         int     10h
         mov     OldMode,al          ; Sauve Mode courant

;-------- Routine de d‚tection ---------
         xor     bx,bx                ;- VGA Detect -
         mov     ax,01a00h
         int     10h
         cmp     bl,7
         jc      @F
         cmp     bl,00dh
         jc      VGA_Ok
@@:      lea     dx,Sorry             ; Sorry You've not...
         mov     ah,9
         int     21h
         jmp     @F                   ; EXIT
VGA_Ok:                               ;- Processor Detect - (C) Bible PC
         xor     ax,ax                ; Fixer AX sur 0
         push    ax                   ; et placer sur la pile
         popf                         ; Retirer de la pile comme reg. de flags
         pushf                        ; Replacer sur la pile
         pop     ax                   ; et ramener dans AX
         and     ax,0f000h            ; Annuler tous les bits sauf les 4 sup.
         cmp     ax,0f000h            ; bits 12 … 15 sont-ils tous … 1 ?
         je      @F                   ; --> Beurk XT : EXIT
         mov     ax,07000h            ; 286 ou 386
         push    ax                   ; Placer la valeur 07000h sur la pile
         popf                         ; Retirer comme registre de flags
         pushf                        ; et replacer sur la pile
         pop     ax                   ; Ramener dans le registre AX
         and     ax,07000h            ; Masquer tous les bits sauf 12 … 14
         jne     pc386_Ok             ; --> Ok 386
         lea     dx,Sorry2            ; d‚sol‚....
         mov     ah,9
         int     21h

@@:      lea     dx,Bye               ; Bye Bye ...
         mov     ah,9
         int     21h
         EXIT
;-----------------------------------------


.386
pc386_OK:cli
         cld

;--------------------------------------
         call    PreTro               ; !!!!! Flamoots Screen !!!!!
;--------------------------------------
         call    TheDemo              ; !!!!! main screen !!!!!
;--------------------------------------


         mov     al,3                 ; Mode Texte 80x25
         xor     ah,ah
         int     10h
         mov     ax,1112h             ; fonte 8x8
         xor     bl,bl
         int     10h
         mov     ah,01h               ; D‚finit Curseur blanc...
         mov     cx,0ff00h
         int     10h


         mov     cx,20
@@:      VSYNC
         loop    @B

         mov     si,OFFSET IMAGEDATA  ; Put ANSI Screen
         mov     ax,0B800h
         mov     es,ax
         xor     di,di
         xor     eax,eax
         mov     cx,80*50/2           ; !!!!! Fuck TIME !!!!!
         rep     stosd                ; arf arf, bien fait SAM !!!
         xor     di,di
         mov     cx,IMAGEDATA_LENGTH
         call    UNCRUNCH

Ansi:    VSYNC
         mov     si,OFFSET Couleurs
         mov     dx,3dah
         mov     cx,56-32
@@:      HSYNC                       ; on passe le logo.....
         loop    @B
         mov     cx,343+32
@@:      HSYNC                       ; d‚grad‚ sur coordonn‚es
         mov     dl,0c8h
         outsw
         inc     dl
         outsb
         outsb
         loop    @B

         in      al,60h              ; EXIT ?
         cmp     al,39h              ; Space Bar ...
         je      @F
         cmp     al,1                ; Escape ...
         jne     Ansi

@@:      mov     ax,40h              ; !!! Vider buffer clavier !!! ;-)
         mov     es,ax
         mov     ax,es:[001ah]
         mov     es:[001ch],ax

         mov     al,OldMode             ; Ancien Mode
         xor     ah,ah
         int     10h

         lea     dx,Autor            ; Who has coded dis stuff ?
         mov     ah,9
         int     21h
         lea     dx,Bye              ; Contact us !!!
         mov     ah,9
         int     21h

         sti

         EXIT

;------------------------------------------------------------------------------

;==============================================================================
;========================== The FLamoots PART ... =============================
;==============================================================================

PreTro   PROC NEAR

          mov     ax,05h             ; CGA 320x200 4 colors !!!!!
          int     10h

          mov     ax,0B800h          ; CGA Video Mem
          mov     es,ax
          xor     eax,eax
          xor     di,di
          mov     cx,32768/4
          rep     stosd              ; kill "time" arf arf ....

          lea     dx,Banderolle      ; affiche notre banderolle !!!!
          mov     ah,09h
          int     21h
          cli

          in      al,021h            ; r‚cup‚rer IRQ MASK...
          push    ax
          mov     al,11111110b
          out     021h,al            ; only my IRQ0

          push    ds
  ;-- D‚tourner interruption temporisateur sur routine utilisateur
          push    dx                 ; Ranger DX et BX sur la pile
          push    bx
          mov     ax,351Ch           ; Lire adresse de l'interruption
                                     ; temporisateur
          int     21h                ; Appeler interruption du DOS
          mov     cs:[time_anc],bx   ; Adresse d'offset de l'ancienne
                                     ; interruption
          mov     cs:[time_anc+2],es ; et ranger adresse de segment
          mov     ax,cs
          mov     ds,ax
          mov     dx,OFFSET Sound_Ti ; Adresse d'offset nouvelle routine tempor.
          mov     ax,251Ch           ; Fixer nouvelle routine temporisateur
          int     21h                ; Appeler interruption du DOS
          cli
          pop     bx                 ; Retirer BX et DX de la pile
          pop     dx
          pop     ds

;----- Jouer gammes chromatiques ----------------
;----- + faire marcher bonhomme !!!!! -----------

          xor     bl,bl              ; Commencer par le Do de la 3Šme octave
          mov     dl,1 ;9            ; Jouer une demie seconde chaque fois
          mov     di,80*(100-23-4)+80-10
@@:       call    Play_Tune          ; Jouer note
          mov     si,OFFSET Bonhom
          REPT    5
          VSYNC
          ENDM
          call    BonhClr            ; Effacer traces...
          dec     di                 ; avance de 1 pas
          call    BonhPut            ; Afficher Bonhomme "marche pas"
          inc     bl
          cmp     bl,34 ;36
          je      @F
          call    Play_Tune
          mov     si,OFFSET Bonhom+Bonlen
          REPT    5
          VSYNC
          ENDM
          call    BonhClr            ; Effacer traces....
          sub     di,2               ; bonhomme avance de 2 pas
          call    BonhPut            ; Afficher Bonhomme "marche"
          inc     bl
          cmp     bl,34 ;36          ; Toutes notes 3 octaves d‚j… jou‚es ???
          jne     @B                 ; NON --> Jouer note suivante
@@:
;------------------------------------------------
          VSYNC
          mov     si,OFFSET Bonhom+Bonlen*2
          call    BonhPut
          REPT 30
          VSYNC
          ENDM

          call    TFLPut             ; afficher notre logo

          REPT 30
          VSYNC
          ENDM

;-------- Braban‡onne -----------

  ;        sub     di,5*80            ; initialiser DI
          mov     cx,Brablen
          mov     si,OFFSET Brabant  ; adr. notes
@@:       lodsw
          mov     bl,al              ; note
          mov     dl,ah              ; dur‚e
          push    si
          VSYNC
          call    BonhClr            ; Effacer traces...
          sub     di,5*80            ; fait sauter bonhomme de 5*2 pixels
          mov     si,OFFSET Bonhom+Bonlen*3
          call    BonhPut            ; Afficher Bonhomme jambe en l'air
          pop     si
          call    Play_Tune          ; Jouer note
          dec     cx
          jcxz    @F
          lodsw
          mov     bl,al
          mov     dl,ah
          push    si
          VSYNC
          mov     si,OFFSET Bonhom+Bonlen*2
          call    BonhClr            ; Effacer traces
          add     di,5*80            ; remet bonhomme en place
          call    BonhPut            ; Afficher Bonhomme fixe
          pop     si
          call    Play_Tune          ; continuer braban‡onne
          loop    @B
@@:
          cli
          pop     ax
          out     021h,al            ; restituer MASK....

          REPT    10
          VSYNC
          ENDM
          call    BonhClr
          add     di,5*80
          mov     si,OFFSET Bonhom+Bonlen*4
          call    BonhPut            ; Bonhomme fixe avec grand sourire...


;-------- Joepie !!!!! ---------

      ; afficher bulle avec JOEPIE !!!!!
          mov     si,OFFSET Joepie   ; 1Šre ‚tape
          mov     cx,6
@@:       REPT 5
          VSYNC
          ENDM
          call    JoepPut            ; affichage
          add     si,Joeplen         ; ‚tape suivante
          loop    @B
     ;--------------------------------

          mov     cx,20
@@:       VSYNC
          loop    @B
@@:       in      al,60h             ; EXIT ?
          cmp     al,39h             ; Space Bar ...
          je      @F
          cmp     al,1               ; Escape ...
          jne     @B
@@:       mov     ax,40h             ; !!! Vider buffer clavier !!! ;-)
          mov     es,ax
          mov     ax,es:[001ah]
          mov     es:[001ch],ax

          mov     cx,10
@@:       REPT    8                   ; 8 VSYNC pour que ‡a soit plus fluide...
          VSYNC
          ENDM
          lea     dx,Skroll           ; scrolling HARDWARE hyper-optimis‚ !!!
          mov     ah,09h
          int     21h
          cli
          loop    @B

          lea     dx,GWBASIC          ; langage utilis‚....
          mov     ah,09h
          int     21h
          cli

          REPT    80                  ; pause pour qu'on voit bien....
          VSYNC
          ENDM

         ;-- Activer … nouveau ancienne interruption temporisateur ----
          push    ds
          mov     ax,251Ch           ; N fonct. pour Fixer vecteur d'interruption
          lds dx,DWORD PTR cs:[time_anc] ; Charger ancienne adresse dans DS:DX
          int     21h                ; Appeler interruption du DOS
          cli
          pop     ds

          ret

PreTro   ENDP


BonhPut  PROC NEAR  ; routine affichage bonhomme CGA

; SI = Adr Bonhomme ....
; DI = Pos. Screen

          MPUSH   ax,es,cx,di,ds

          mov     ax,DAMSEG
          mov     ds,ax
          mov     ax,0B800h          ; CGA Video Memory
          mov     es,ax
          mov     cx,46/2 ; hauteur = 46 pixels
@@:       movsd           ; 10 bytes
          movsd           ; = 40 pixels with (CGA)
          movsw
          sub     di,10
          xor     di,2000h ; odd lines
          movsd
          movsd
          movsw
          xor     di,2000h ; even lines
          add     di,80-10 ; next line
          loop    @B

          MPOP    ax,es,cx,di,ds

          ret

BonhPut   ENDP

BonhClr  PROC NEAR  ; routine effa‡age bonhomme CGA

; DI = Pos. Screen

          MPUSH   ax,es,cx,di

          mov     ax,0B800h          ; CGA Video Memory
          mov     es,ax
          mov     cx,46/2 ; hauteur = 46 pixels
          xor     eax,eax
@@:       stosd           ; 10 bytes
          stosd           ; = 40 pixels with (CGA)
          stosw
          sub     di,10
          xor     di,2000h ; odd lines
          stosd
          stosd
          stosw
          xor     di,2000h ; even lines
          add     di,80-10 ; next line
          loop    @B

          MPOP    ax,es,cx,di

          ret

BonhClr  ENDP

JoepPut   PROC NEAR  ; affichage de la bulle avec le "JOEPIE !!!"

; SI = Adr Joepie ....

          MPUSH   ax,es,cx,si,ds

          mov     ax,DAMSEG
          mov     ds,ax
          mov     ax,0B800h          ; CGA Video Memory
          mov     es,ax
          mov     di,80*(100-23-20)  ; position o— afficher la bulle....
          mov     cx,54/2-1 ; hauteur = 54 pixels
@@:       REPT 5          ; 20 bytes
          movsd           ; = 80 pixels with (CGA)
          ENDM
          sub     di,20
          xor     di,2000h ; odd lines
          REPT 5
          movsd
          ENDM
          xor     di,2000h ; even lines
          add     di,80-20 ; next line
          loop    @B
          REPT 5
          movsd
          ENDM


          MPOP    ax,es,cx,si,ds

          ret


JoepPut   ENDP


TFLPut PROC NEAR  ; routine affichage logo TFL CGA

          MPUSH   ax,es,cx,si,di,ds

          mov     si,OFFSET TFLlogo
          mov     di,80*60+40

          mov     ax,DAMSEG
          mov     ds,ax
          mov     ax,0B800h          ; CGA Video Memory
          mov     es,ax
          mov     cx,50/2 ; hauteur = 50 pixels
@@:       movsd           ; 21 bytes
          movsd           ; = 84 pixels with (CGA)
          movsd
          movsd
          movsd
          movsb
          sub     di,21
          xor     di,2000h ; odd lines
          movsd
          movsd
          movsd
          movsd
          movsd
          movsb
          xor     di,2000h ; even lines
          add     di,80-21 ; next line
          loop    @B

          MPOP    ax,es,cx,si,di,ds

          ret


TFLPut  ENDP


;------------ Speaker Routine (C) Bible PC --------------

; -- PLAY_TUNE : Jouer une note --------------------------
; -- Entr‚e    : BL = Num‚ro de note par rapport au DO 3Šme octave
; --             DL = Dur‚e de note en 1/18Šmes de seconde
; -- Sortie    : Aucune
; -- Registres : AX, CX, ES et FLAGS sont modifi‚s
; -- Infos     : Le contr“le n'est rendu … la routine d'appel qu'une
; --             fois la dur‚e de note ‚coul‚e

Play_Tune PROC NEAR

         push    dx                 ; Ranger DX et BX sur la pile
         push    bx

         mov     al,182             ; Pr‚parer g‚g‚ration d'un son
         out     43h,al             ; Envoyer valeur au Timer Command Register
         xor     bh,bh              ; BH pour adressage table notes = 0
         shl     bx,1               ; Doubler n note (car table de mots)
         mov     ax,cs:[notes+bx]   ; Lire valeur de note
         out     42h,al             ; Octet faible dans Timer Counter Register
         mov     al,ah              ; Transf‚rer octet fort dans AL
         out     42h,al             ; et aussi dans Timer Counter Register
         in      al,61h             ; Lire bit de contr“le du haut-parleur
         or      al,11b             ; Deux bits inf‚rieurs activent haut-parleur
         mov     cs:[fin_s],1       ; Note doit encore ˆtre jou‚e
         mov     cs:[compteur_s],dl ; Sauver dur‚e de note
         out     61h,al             ; Activer haut-parleur

         VSYNC
         sti                        ; on peut activer ....
play:    cmp     cs:[fin_s],0       ; Note termin‚e ?
         jne     play               ; NON --> Attendre encore
         cli                        ; stopper, j'ai pas envie du timer...

         VSYNC
         in      al,61h             ; Lire bit de contr“le du haut-parleur
         and     al,11111100b       ; Annuler 2 bits inf‚rieurs
         out     61h,al             ; D‚sactiver haut-parleur


         pop     bx                 ; Retirer BX et DX de la pile
         pop     dx
         ret                        ; Retour au programme d'appel

Play_Tune ENDP

;-- Nouvelle interruption temporisateur -----------------------

Sound_Ti PROC FAR                   ; Est appel‚e 18 fois par seconde

         dec     cs:[compteur_s]    ; D‚cr‚menter compteur
         jne     fin_st             ; Si pas encore 0, alors fin
         mov     cs:[fin_s],0       ; Signaler dur‚e de note ‚coul‚e

fin_st: ; jmp     DWORD PTR cs:[time_anc] ; Vers l'ancienne interruption tempor.

         iretf

;== Voici les variables dont ont besoin les routines BEEP BEEP ==========

time_anc   dw (?),(?)               ; Adresse de l'ancienne interruption tempor.
compteur_s db (?)                   ; Dur‚e restante d'1 note en 1/18Šme de sec
fin_s      db (?)                   ; Indique si note a d‚j… ‚t‚ jou‚e
notes      dw 3921,8609,8126,7670   ; Valeurs de notes pour l'octave 3
           dw 7239,6833,6449,6087
           dw 5746,5423,5119,4831
           dw 4560,4304,4063,3834   ; Valeurs de notes pour l'octave 4
           dw 3619,3416,3224,3043
           dw 2873,2711,2559,2415
           dw 2280,2152,2031,1917   ; Valeurs de notes pour l'octave 5
           dw 1809,1715,1612,1521
           dw 1436,1355,1292,1207

Sound_Ti ENDP


;==============================================================================
;========================== The DEMO ..... principale =========================
;==============================================================================

TheDemo PROC NEAR



         VSYNC
         call Mode13x               ; 384x564 256 colors Chained
                                    ; (no more Tweaked ... snif )

         mov     dx,3c4h            ; Screen Off
         mov     al,01h
         out     dx,al
         inc     dl
         in      al,dx
         or      al,100000y
         out     dx,al

       
         mov     dx,3c0h            ; Pixel Panning Compatibility...
         mov     al,30h
         out     dx,al
         inc     dl
         in      al,dx
         dec     dl
         or      al,00100000y
         out     dx,al

;------------------------------------------------------------------------------
        mov     ax, PDATA               ; adr. AdLib Player
        mov     Player[2], ax

        mov     ah, 6
        call    MusicDriver

        jnc     InitializedOk           ; card was there, it's ok

        ; Card not there, so patch code to use a RET instead of NOP
        ; This way, no extra coding involved to cancel calls to
        ; the player.  This test program doesn't do anything BUT
        ; play music, so ... :)
        mov     BYTE PTR cs:[MusicPatch], 0C3h

InitializedOk:
        ; Initialize the music now
        mov     ah, 0                           ; function 0, init music
        mov     bx, PDATA                       ; segment of MUSIC
        mov     cx, MusicOffset                 ; offset of MUSIC
        call    MusicDriver

        mov     ah, 2                           ; Not sure what this one does, but it's required
        mov     bx, 0
        call    MusicDriver

        ; Music all initialized ...
        ; Note that si is destroyed in calls to MusicDriver, so if you're using it, you'd
        ; better save and restore it!

        ; *****************************************************************************
        ; Set the CPS of the song ...
        ; *****************************************************************************

;        push    ds
;        mov     ax, PDATA
;        mov     ds, ax

        ; Which version of music file are we using?  If it's version > 01.14, then the
        ; CPS of the song is stored in the 9th byte.  < 01.14, and it's the second byte.
;        mov     bx, MusicOffset
;        cmp     word ptr [bx], 0434ah   ; "JC"
;        jne     _old_vers

;        mov     bx, MusicOffset+8
;        jmp     _init_loc1

;_old_vers:
;        mov     bx, MusicOffset+1

;_init_loc1:
        ; Get CPS
;        mov     al, byte ptr [bx]
;        xor     ah, ah
;        pop     ds

        ; Set the calls to the timer to our CPS.
;        mov     bx, ax                  ; Figure out 1193180/cycles to get
;        mov     ax, 34DCh               ; proper divisor for timer
;        mov     dx, 12h
;        div     bx

;        mov     al, 00110110b           ; Set timer interrupt 0 to the
;        out     43h, al                 ; divisor
;        out     40h, al
;        mov     al, ah
;        out     40h, al

        ; *****************************************************************************

        ; Save old interrupt
;        mov     ax, 351ch
;        int     21h
;        mov     word ptr [oldint1c], bx
;        mov     word ptr [oldint1c+2], es

        ; Put in new interrupt
;        push    ds
;        mov     ax, seg newint1c
;        mov     ds, ax
;        mov     dx, offset newint1c
;        mov     ax, 251ch
;        int     21h
;        pop     ds
;------------------------------------------------------------------------------

      
         call    PutPattern           ; Construct multidirectional patterns...
         call    InitFonte            ; Couleur fonte + ligne de blanc
         call    PutDamier            ; Afficher Damier !!!


;----- On peut splitter l'‚cran … pr‚sent !!!! ------

         mov     dx,3d4h             ; Line Compare
         mov     al,07h              ; overflow reg.
         out     dx,al
         inc     dl
         in      al,dx
         or      al,00010000y        ; set bit 9 LC
         out     dx,al
         dec     dl
         mov     al,09h              ; max scan line reg.
         out     dx,al
         inc     dl
         in      al,dx
         and     al,10111111y        ; clear bit 10 LC
         out     dx,al
         dec     dl
         mov     ax,1*256+18h        ; set 8 bits LC
         out     dx,ax

         mov     dx,3c4h             ; Screen On
         mov     al,01h
         out     dx,al
         inc     dl
         in      al,dx
         and     al,011111y
         out     dx,al

;--------- Pr‚pare la page raster derriŠre les rasters verticaux !!! ----------

         mov     si,OFFSET Raster2 ; D‚grad‚ Copper Rouge-Vert
         mov     ax,ds
         mov     es,ax
         mov     di,OFFSET RastPage
         add     di,257*4-1
         mov     cx,200
@@:      add     di,2
         lodsw
         mov     WORD PTR[di+457*4],ax
         stosw
         loop    @B

;------------------------------------------------------------------------------

;------- Main Part ---------

        mov     ax,0a000h
        mov     es,ax                ; Screen Base...
        mov     si,OFFSET Multi      ; !!! Warning DS:SI !!!

Main:    mov     dx,3d4h             ; CRT Port
         mov     al,0ch              ; FAIT mover le multidirectionnel
         out     dx,al
         inc     dl
         outsb                       ; HIGH(adr)
         dec     dl
         inc     al
         out     dx,al
         inc     dl
         outsb                       ; LOW(adr)

;-------------------
         push    si                  ; remove that if you want to use CPS rate
         mov     ah,3
         call    MusicDriver         ; play music
;         pop     si
;-------------------

;*********************************** ; -- SYNCHRO VBL --
         VSYNC
;***********************************

;---
         mov     dx,3c8h             ; renouveler Palette Damier ...
         mov     al,256-37-16
         out     dx,al
         inc     dl
         mov     cx,16*3
         mov     si,DamPTR
         rep     outsb

         add     DamPTR,3            ; rotationaliser la palette !!!
         cmp     DamPTR,OFFSET DamPal+16*3
         jne     @F
         mov     DamPTR,OFFSET DamPal
@@:

;---
         pop     si


         mov     dx,3c0h
         mov     al,33h
         out     dx,al
         outsb                       ; Horizontal Panning


; Patterns 36x64...

         mov     dl,0d4h             ; 72 pixels With...
         mov     ax,00913h
         out     dx,ax
      ;   mov     al,09h
      ;   out     dx,al
      ;   inc     dl
      ;   in      al,dx
      ;   or      al,1
      ;   out     dx,al               ; double vertical size
         mov     ax,02109h
         out     dx,ax

         push    si
         mov     bx,ds               ; Save Segment DS

         mov     si,ScrexxAdr+384+14 ; scroll par 2 pixels
         mov     di,ScrexxAdr+384+12 ; Position to Scroll...
         mov     ax,es
         mov     ds,ax
         mov     cx,96 ;257          ; copy overflow screxx ...
         rep     movsd

         mov     gs,si
         mov     ds,bx

         mov     si,RastPagePTR      ; Pointeur sur Copper Bars ....

         mov     cx,257
         mov     dx,3c8h
WaitCop:
    ;--- HSYNC ---
         mov  dl,0dah
@@:      in   al,dx    ; !!! important pour compatibilit‚ !!!
         jmp  $+2
         test al,01
         jnz  @B
@@:      in   al,dx
         jmp  $+2
         test al,01
         jz   @B

         mov     dl,0c8h             ; Afficher Rasters
         outsw
         inc     dl
         outsb
         outsb
         mov     bp,si               ; Save SI

         mov     ax,es
         mov     ds,ax
         mov     si,gs
         REPT 5 ;6;+3                ; Scrolling int‚gr‚ !!!
         movsd         ; 17*384/4
         ENDM
         mov     gs,si

         mov     ds,bx
         mov     si,bp

         loop    WaitCop

         mov     WORD PTR [SelfMotte1+1],gs ; encore 193*4 bytes … scroller ...
         mov     WORD PTR [SelfMotte2+1],di ; (on reporte ...)

;------------

; Copper Bars...
         HSYNC            ; resynchronise ...

         mov     dl,0d4h             ; 0 pixels With...
         mov     ax,00013h
         out     dx,ax
       ;  mov     al,09h
       ;  out     dx,al
       ;  inc     dl
       ;  in      al,dx
       ;  and     al,11111110y        ; half vertical size
       ;  out     dx,al
         mov     ax,02009h
         out     dx,ax

; On y va...
         mov     cs:[SelfMod4+1],sp
         mov     bp,AmpPtr ; pointeur sur table amplitudes
         mov     sp,AmpPtr+2
         mov     bx,BarPtr ; pointeur sur table sinus
         mov     gs,si     ; sauver compteur Rasters
         mov     si,OFFSET Bars

         mov     cx,200-1
Barbar:  cmp     si,OFFSET Bars+16*8
         jne     @F
         mov     si,OFFSET Bars
@@:      mov     fs,si
         mov     ax,WORD PTR[bx]
         mov     di,sp
         imul    WORD PTR[di]
         add     dx,176+16
         mov     di,dx

  ;--- HSYNC ---
         mov  dx,3dah
@@:      in   al,dx    ; !!! important pour compatibilit‚ !!!
         jmp  $+2
         test al,01
         jnz  @B
@@:      in   al,dx
         jmp  $+2
         test al,01
         jz   @B

         mov  si,gs
         mov  dl,0c8h
         outsw         ; poke rasters !!!
         inc  dl
         outsb
         outsb
         mov  gs,si

         mov  si,fs
         movsd                      ; afficher tron‡on...
         movsd
         mov     ax,WORD PTR[bx]
         imul    WORD PTR ds:[bp]   ; sinus*amplitude
         add     dx,176+16          ; centrer le sinus...
         mov     di,dx
         add     si,(16-1)*8
         movsd
         movsd
         add     bx,2
         add     bp,2
         add     sp,2
         sub     si,16*8
         loop    Barbar

;-------- Last line .... ---------
         cmp     si,OFFSET Bars+16*8
         jne     @F
         mov     si,OFFSET Bars
@@:      mov     fs,si
         mov     ax,WORD PTR[bx]
         mov     di,sp
         imul    WORD PTR[di]
         add     dx,176+16
         mov     di,dx

  ;--- HSYNC ---
       
         mov  dx,3dah
@@:      in   al,dx     ; !!! important pour compatibilit‚ !!!
         jmp  $+2
         test al,01
         jnz  @B
@@:      in   al,dx
         jmp  $+2
         test al,01
         jz   @B
    
         mov  dl,0d4h
         mov  ax,03213h ; (384+16) pixels de large !!!
         out  dx,ax

         mov  si,fs
         movsd                      ; afficher tron‡on...
         movsd
         mov     ax,WORD PTR[bx]
         imul    WORD PTR ds:[bp]   ; sinus*amplitude
         add     dx,176+16          ; centrer le sinus...
         mov     di,dx
         add     si,(16-1)*8
         movsd
         movsd

;--------------------

SelfMod4  LABEL WORD
          mov     sp,0000h

         HSYNC             ; resynchronise ...
         mov  dx,3c8h   ; Black border ...
         xor  ax,ax
         out  dx,ax
         inc  dl
         out  dx,al
         out  dx,al

;-----------
         mov  dx,ds
         mov  ax,es
         mov  ds,ax

SelfMotte1 LABEL WORD       ; encore 161 bytes … scroller (… cause ISA Bus)
           mov    si,0000h  ; source
SelfMotte2 LABEL WORD
           mov    di,0000h  ; destination
           mov    cx,161
           rep    movsd     ; scroll !!!!
         mov  ds,dx
;-----------


       ; Clear 1st line....
         xor     di,di
         xor     eax,eax
         mov     cx,(384/2+4)/2
         rep     stosd               ; Effacer ligne Copper...

    ; Pr‚parer Page Rasters...

         push    es
         mov     ax,ds
         mov     es,ax
         mov     si,RastPtr ; D‚grad‚ de bleu
         mov     di,RastPagePTR+2
         mov     cx,257
         xor     al,al
@@:      add     di,2
         stosb
         movsb
         loop    @B
         mov     cx,200
         xor     al,al
@@:      add     di,3
         stosb
         loop    @B

       ; Vagues Bleues !!!

         mov     bx,VaguePTR  ; Pointeur sur vagues
         mov     cx,8
         mov     dx,RastPagePTR+2

@@:      mov     di,[bx]
         add     di,dx

         mov     BYTE PTR[di+3],16     ; Affichage des nuances de bleu ...
         mov     BYTE PTR[di+3+4],24
         mov     BYTE PTR[di+3+4*2],32
         mov     BYTE PTR[di+3+4*3],36
         mov     BYTE PTR[di+3+4*4],40
         mov     BYTE PTR[di+3+4*5],44
         mov     BYTE PTR[di+3+4*6],48
         mov     BYTE PTR[di+3+4*7],52
         mov     BYTE PTR[di+3+4*8],56
         mov     BYTE PTR[di+3+4*9],60
         mov     BYTE PTR[di+3+4*10],63
         mov     BYTE PTR[di+3+4*11],60
         mov     BYTE PTR[di+3+4*12],56
         mov     BYTE PTR[di+3+4*13],52
         mov     BYTE PTR[di+3+4*14],48
         mov     BYTE PTR[di+3+4*15],44
         mov     BYTE PTR[di+3+4*16],40
         mov     BYTE PTR[di+3+4*17],36
         mov     BYTE PTR[di+3+4*18],32
         mov     BYTE PTR[di+3+4*19],24
         mov     BYTE PTR[di+3+4*20],16
         add     bx,2*4
         loop    @B


         mov     bx,RolaxPTR    ; Pointeur sur Rouleaux !!!
         mov     cx,6
         mov     dx,RastPagePTR+2

@@:      mov     di,[bx]
         add     di,dx

         mov     BYTE PTR[di+2],16     ; Affichage des rouleaux ...
         mov     BYTE PTR[di+2+4],24
         mov     BYTE PTR[di+2+4*2],32
         mov     BYTE PTR[di+2+4*3],36
         mov     BYTE PTR[di+2+4*4],40
         mov     BYTE PTR[di+2+4*5],44
         mov     BYTE PTR[di+2+4*6],48
         mov     BYTE PTR[di+2+4*7],52
         mov     BYTE PTR[di+2+4*8],56
         mov     BYTE PTR[di+2+4*9],60
         mov     BYTE PTR[di+2+4*10],63
         mov     BYTE PTR[di+2+4*11],60
         mov     BYTE PTR[di+2+4*12],56
         mov     BYTE PTR[di+2+4*13],52
         mov     BYTE PTR[di+2+4*14],48
         mov     BYTE PTR[di+2+4*15],44
         mov     BYTE PTR[di+2+4*16],40
         mov     BYTE PTR[di+2+4*17],36
         mov     BYTE PTR[di+2+4*18],32
         mov     BYTE PTR[di+2+4*19],24
         mov     BYTE PTR[di+2+4*20],16
         add     bx,2
         loop    @B

         pop     es

;---------- Afficher tranche caractŠre suivant --------------

         mov     bx,Scroll1PTR        ; scroll par 2 pixels ...
@@:      mov     al,BYTE PTR[bx]
         test    al,al
         jnz     @F
         mov     bx,OFFSET Scroll1
         jmp     @B
@@:      sub     al,32                  ; - spacebar
         shl     al,1
         xor     ah,ah
         mov     si,ax
         mov     si,WORD PTR[si+TabFnt] ; prend position char ds table
         add     si,BitFnt              ; ajouter adresse bitmap
         add     si,Scroll1Col          ; ajouter colonne … prendre
         mov     di,ScrexxAdr+384+14    ; position scrolltext
         mov     cx,17
@@:      movsw
         add     si,14         ; ligne suivante dans le caractŠre
         add     di,(384+16)-2 ; ligne suivante … l'‚cran
         loop    @B

         add     Scroll1Col,2  ; 1 tranche en plus
         cmp     Scroll1Col,16
         jne     @F
         mov     Scroll1Col,0  ; quand plus de tranche, on passe au caractŠre
         inc     bx            ; suivant
         mov     Scroll1PTR,bx
@@:

;-------------------------------------------


         pop     si  ; !!! r‚cupŠre SI maintenant !!!


; Test des tables ....

         add     WORD PTR[VaguePTR],2
         cmp     WORD PTR[VaguePTR],OFFSET Vague+1024
         jne     @F
         mov     WORD PTR[VaguePTR],OFFSET Vague
@@:
         add     WORD PTR[RolaxPTR],6*2
         cmp     WORD PTR[RolaxPTR],OFFSET Rolax+(256*2)*6
         jne     @F
         mov     WORD PTR[RolaxPTR],OFFSET Rolax
@@:
         add     WORD PTR[BarPtr],2       ; A-t-on fait le tour ???
         cmp     WORD PTR[BarPtr],OFFSET Copper+1024
         jne     @F
         mov     WORD PTR[BarPtr],OFFSET Copper
@@:
         add     WORD PTR[AmpPtr],4
         cmp     WORD PTR[AmpPtr],OFFSET Ampli+1024
         jne     @F
         mov     WORD PTR[AmpPtr],OFFSET Ampli
@@:      add     WORD PTR[AmpPtr+2],4
         cmp     WORD PTR[AmpPtr+2],OFFSET Ampli+1024
         jne     @F
         mov     WORD PTR[AmpPtr+2],OFFSET Ampli
@@:


         cmp     si,OFFSET Multi+3*512
         jne     @F                  ; A-t-on fait le tour ???
         mov     si,OFFSET Multi
@@:

         mov     ax,RastPTR          ; Swap Blue Gradiant Page
         xchg    ax,RastPTR+2        ; --> flipping = 128 tints
         mov     RastPTR,ax

         mov     ax,RastPagePTR      ; Swap Raster Pages...
         xchg    ax,RastPagePTR+2    ; for animations...
         mov     RastPagePTR,ax

;--------------------------------------------------


;-----------

         in      al,60h              ; EXIT ?
         cmp     al,39h              ; Space Bar ...
         je      GoOut
         cmp     al,1                ; Escape ...
         jne     Main

GoOut:


;------------------------------------------------------------------------------

;----- EXIT -----

;------------------------------------------------------------------------------
        ; Put in old interrupt
;        push    ds
;        mov     ax, word ptr [oldint1c+2]
;        mov     ds, ax
;        mov     dx, word ptr [oldint1c]
;        mov     ax, 251ch
;        int     21h
;        pop     ds

        ; Shut down music
        mov     ah, 2
        mov     bx, 0
        call    MusicDriver

        ; Reset timer to standard ...
;        mov     al, 00110110b
;        out     43h, al
;        mov     ax, 65535
;        out     40h, al
;        mov     al, ah
;        out     40h, al
;------------------------------------------------------------------------------

         ret

TheDemo  ENDP

;==============================================================================
;==============================================================================

PutPattern PROC NEAR

           mov  dx,3c8h                 ; Init our palette....
           xor  al,al
           out  dx,al
           inc  dl
           mov  si,OFFSET Pattern+32
           mov  cx,256*3                ; 256 colors !!!
InitPal:   lodsb
           shr  al,2                    ; 8 bits --> 6 bits
           out  dx,al
           loop InitPal

           mov  ax,0a000h               ; Construire motif...
           mov  es,ax

           mov  di,StartAdr
           mov  cx,32
@@:        mov  dx,cx                   ; Afficher 1er bloc … l'‚cran
           mov  cx,36/4
           rep  movsd
           add  di,36
           mov  cx,dx
           loop @B

           push ds
           mov  ax,es
           mov  ds,ax
           mov  si,StartAdr
           mov  di,StartAdr+36*2*32+36
           mov  cx,32*36/4*2
           rep  movsd                   ; construct 1st line

           mov  si,StartAdr
           mov  di,StartAdr+64*36*2
           mov  cx,(1+3)*64*36/4*2
           rep  movsd                   ; Fill all the screen
           pop  ds

           ret

PutPattern ENDP

InitFonte PROC NEAR

           mov  dx,3c8h                 ; Init our palette....
           mov  al,256-32-4-1
           out  dx,al
           inc  dl
           mov  si,OFFSET Fonte
           mov  cx,(32+4+1)*3           ; 36+1 colors !!!
InitPal:   lodsb
           shr  al,2                    ; 8 bits --> 6 bits
           out  dx,al
           loop InitPal


; remplir une ligne de blancs...

           mov  ax,0a000h               ; Video mem.
           mov  es,ax

           mov  di,ScrexxAdr
           mov  eax,01010101h           ; black line <> color 0
           mov  cx,(384+16)/4
           rep  stosd

           mov  di,ScrexxAdr+384+16     ; Screxx offset
           mov  si,BitFnt               ; space-bar

           mov  cx,17

Fill1char: movsd                        ; 1er char. space
           movsd
           movsd
           movsd
           add  di,384+16-16
           loop Fill1char

           push ds                      ; remplir la ligne

           mov  ax,0a000h
           mov  ds,ax
           mov  si,ScrexxAdr+384+16
           mov  di,ScrexxAdr+384+16+16
           mov  cx,17
Fill1line: mov  dx,cx
           mov  cx,384/4
           rep  movsd
           add  si,16
           add  di,16
           mov  cx,dx
           loop Fill1line

           pop  ds

           ret

InitFonte ENDP

PutDamier PROC NEAR                     ; fout le damier … la 564-90Šme ligne

          push ds

          mov  si,OFFSET Damier
          mov  ax,DAMSEG
          mov  ds,ax
          mov  ax,0a000h
          mov  es,ax
          mov  di,DamierAdr

          mov  cx,90*(384+16)/4         ; copy pattern ...
          rep  movsd


          pop  ds

          ret

PutDamier ENDP

WaitVbl  PROC NEAR

         MPUSH ax,dx

         mov  dx,3dah
@@:      in   al,dx
         jmp  $+2
         jmp  $+2
         test al,08
         jnz  @B
@@:      in   al,dx
         jmp  $+2
         jmp  $+2
         test al,08
         jz   @B

         MPOP ax,dx

         ret

WaitVbl  ENDP

Mode13x PROC NEAR

	push	ds
	mov	ax,cs
	mov	ds,ax

	mov	ax,13h		; start with standard mode 13h
	int	10h		; let the bios set the mode

        mov     dx,3c4h         ; alter sequencer registers
   ;     mov     ax,0604h        ; disable chain 4
   ;     out     dx,ax

   ;     mov     ax,0f02h        ; set write plane mask to all bit planes
   ;     out     dx,ax
        push    di
        xor     di,di
        mov     ax,0a000h       ; screen starts at segment A000
        mov     es,ax
        mov     cx,32768/2      ; 256ko Video Mem
        xor     eax,eax
        cld
        rep     stosd           ; clear the whole of the screen
        pop     di

        mov     ax,0100h        ; synchronous reset
	out	dx,ax		; asserted
	mov	dx,3c2h		; misc output
	mov	al,0e7h		; use 28 mHz dot clock
	out	dx,al		; select it
	mov	dx,3c4h		; sequencer again
	mov	ax,0300h	; restart sequencer
	out	dx,ax		; running again

	mov	dx,3d4h		; alter crtc registers

	mov	al,11h		; cr11
	out	dx,al		; current value
	inc	dx		; point to data
	in	al,dx		; get cr11 value
	and	al,7fh		; remove cr0 -> cr7
	out	dx,al		;    write protect
	dec	dx		; point to index
	cld
	mov	si,offset vptbl
        mov     cx,((OFFSET vpend)-(OFFSET vptbl)) SHR 1
outlp:	lodsw
	out	dx,ax
	loop	outlp
       
	pop	ds
	ret

vptbl   dw      06b00h  ; horz total
        dw      06301h  ;05901h  ; horz displayed
        dw      06302h  ;05a02h  ; start horz blanking /* je baise la cirrus */
        dw      08e03h  ;08e03h  ; end horz blanking
        dw      06404h  ;05e04h  ; start h sync
        dw      08005h  ;08a05h  ; end h sync
        dw      04006h  ;00d06h  ; vertical total
        dw      0f007h  ;03e07h  ; overflow
        dw      06009h  ;04009h  ; cell height
        dw      03410h  ;0ea10h  ; v sync start
        dw      00111h  ;0ac11h  ; v sync end and protect cr0-cr7
        dw      03412h  ;0df12h  ; vertical displayed
     ;   dw      03013h  ;02d13h  ; offset
        dw      00013h  ; offset=0 --> hidden screen at the beginning !!!!
    ;    dw      00014h  ; turn off dword mode
        dw      03415h  ;0e715h  ; v blank start
        dw      00616h  ;00616h  ; v blank end
        dw      0e317h  ; turn on byte mode

      ;  dw      0221bh ; enable more than 64ko decoding on Cirrus Board ...

vpend   LABEL   WORD

Mode13x ENDP

;THEDRAW IMAGE UNCRUNCHING ROUTINE
;-----------------------------------------------------------------------------
;Compatible with MASM (Microsoft) and TASM v1.0 (Borland).  Minor format
;changes may be required for other assemblers.
;-----------------------------------------------------------------------------
;
;This is the routine for displaying crunched TheDraw image files.  The
;crunched data format is a simple custom protocol for reproducing any image.
;The control codes below decimal 32 are reserved for this function.
;Characters 32 and above are written directly to the destination address.
;
;The following shows the format of a control code sequence.  Please note that
;not all functions use the optional bytes <x> or <y>.
;
;Data Structure:  <current byte>[<x>[<y>]]
;
;   0..15 = New Foreground Color
;  16..23 = New Background Color
;      24 = Go down to next line, return to same horizontal position as when
;           routine was started (akin to a c/r).
;      25 = Displays <x> number of spaces.
;      26 = Displays <x> number of <y>.  Also used to display ANY characters
;           below #32.  This function is the only way to do this although it
;           uses three bytes.  Otherwise the code would be interpreted as
;           another command.
;      27 = Toggles on/off the foreground attribute blink flag.
;  28..31 = reserved
;
;----------------------------------------------------------------------------
;
;To use the routine, call the uncrunch procedure with the DS:SI register pair
;pointing to the TheDraw output listing, the ES:DI register pair pointing to
;the destination display address, and the length of the crunched image data
;in the CX register.  All modified registers are restored upon exiting.
;
;Assume an output file of a 40 character by 10 line block.  The label
;'IMAGEDATA' has been added for referencing purposes. ie:
;
;
;     ;TheDraw Assembler Crunched Screen Image
;     IMAGEDATA_WIDTH EQU 40
;     IMAGEDATA_DEPTH EQU 10
;     IMAGEDATA_LENGTH EQU 467
;     IMAGEDATA LABEL BYTE
;                DB      ...list of image bytes here...
;
;
;The following assembly language code could then be used to display the
;40x10 block on the screen with:
;
;                MOV     SI,offset IMAGEDATA
;                MOV     AX,0B800h
;                MOV     ES,AX
;                MOV     DI,34*2 + 5*160-162
;                MOV     CX,IMAGEDATA_LENGTH
;                CALL    UNCRUNCH
;
;The data segment (DS register) is assumed to point at the segment ImageData
;resides in.   The ES:DI register pair points at position (34,5) on the color
;graphics adapter screen, calculated as an offset from the start of the screen.
;Monochrome card users, replace the 0B800h with 0B000h.
;
;The original horizontal starting offset is remembered by the uncrunch routine.
;The offset is restored upon moving down to the next line.  This permits a
;block to be displayed correctly anywhere on the screen.  ie:
;
;              ÚÄ horizontal starting offset
;              V
;  +-------------------------------------------------+
;  |                                                 |
;  |                                                 | <- Assume this
;  |                                                 |    is the video
;  |           ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿               |    display.
;  |           ³ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ³               |
;  |           ³ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ³               |
;  |           ³ÛÛ ImageData block ÛÛ³               |
;  |           ³ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ³               |
;  |           ³ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ³               |
;  |           ³ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ³               |
;  |           ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ               |
;  |                                                 |
;  |                                                 |
;  |                                                 |
;  +-------------------------------------------------+
;
;
;To display the block in the lower-right corner, change the DI assignment to:
;
;                MOV     DI,40*2 + 15*160-162
;
;The block is 40 characters wide by 10 lines deep.  To display on a 80 by 25
;screen, we must display the block at coordinates (40,15).  To display in
;the upper-left screen corner use:
;
;                MOV     SI,offset IMAGEDATA
;                MOV     AX,0B800H
;                MOV     ES,AX
;                MOV     DI,1*2 + 1*160-162       ;coordinates 1,1
;                MOV     CX,IMAGEDATA_LENGTH
;                CALL    UNCRUNCH
;
;Notice in both cases only the offset address changed.  Note the latter case
;is also used for displaying a full screen image (which in general are
;always displayed at coordinate 1,1).
;
;----------------------------------------------------------------------------
;
;That's it!  The routine was designed for easy use and understanding; however,
;for some people the best way is to experiment.  Create a program using the
;above examples, perhaps with a 40x10 block (or any size).  Good luck!
;

UNCRUNCH PROC NEAR
;
;Parameters Required:
;  DS:SI  Crunched image source pointer.
;  ES:DI  Display address pointer.
;  CX     Length of crunched image source data.
;
       PUSH    SI                      ;Save registers.
       PUSH    DI
       PUSH    AX
       PUSH    BX
       PUSH    CX
       PUSH    DX
       JCXZ    Done

       MOV     DX,DI                   ;Save X coordinate for later.
       XOR     AX,AX                   ;Set Current attributes.
       CLD

LOOPA: LODSB                           ;Get next character.
       CMP     AL,32                   ;If a control character, jump.
       JC      ForeGround
       STOSW                           ;Save letter on screen.
Next:  LOOP    LOOPA
       JMP     Short Done

ForeGround:
       CMP     AL,16                   ;If less than 16, then change the
       JNC     BackGround              ;foreground color.  Otherwise jump.
       AND     AH,0F0H                 ;Strip off old foreground.
       OR      AH,AL
       JMP     Next

BackGround:
       CMP     AL,24                   ;If less than 24, then change the
       JZ      NextLine                ;background color.  If exactly 24,
       JNC     FlashBitToggle          ;then jump down to next line.
       SUB     AL,16                   ;Otherwise jump to multiple output
       ADD     AL,AL                   ;routines.
       ADD     AL,AL
       ADD     AL,AL
       ADD     AL,AL
       AND     AH,8FH                  ;Strip off old background.
       OR      AH,AL
       JMP     Next

NextLine:
       ADD     DX,160                  ;If equal to 24,
       MOV     DI,DX                   ;then jump down to
       JMP     Next                    ;the next line.

FlashBitToggle:
       CMP     AL,27                   ;Does user want to toggle the blink
       JC      MultiOutput             ;attribute?
       JNZ     Next
       XOR     AH,128                  ;Done.
       JMP     Next

MultiOutput:
       CMP     AL,25                   ;Set Z flag if multi-space output.
       MOV     BX,CX                   ;Save main counter.
       LODSB                           ;Get count of number of times
       MOV     CL,AL                   ;to display character.
       MOV     AL,32
       JZ      StartOutput             ;Jump here if displaying spaces.
       LODSB                           ;Otherwise get character to use.
       DEC     BX                      ;Adjust main counter.

StartOutput:
       XOR     CH,CH
       INC     CX
       REP STOSW
       MOV     CX,BX
       DEC     CX                      ;Adjust main counter.
       LOOPNZ  LOOPA                   ;Loop if anything else to do...

Done:  POP     DX                      ;Restore registers.
       POP     CX
       POP     BX
       POP     AX
       POP     DI
       POP     SI
       RET

UNCRUNCH ENDP

;How to use the VIBRANTS play-driver
;-----------------------------------

;These cool drivers are ... cool!  The song included here is a TINY 3.1k, but
;it sounds as good as most MODs.  And it only requires an AdLib!  And takes up
;much less time to play!  Wow.

;Anyway, JCH said he'd release a doc explaining how to use them.  Well, so far
;... I haven't seen anything.  So, hacking into the drivers (and looking at the
;KUKOO source code, :), I figured out how to use them.

;One thing you should know:  The soundblaster driver (SBL-0103.P01) seems to
;require some other initializations (probably the soundblaster port, IRQ, etc),
;and I can't figure out how to do that.  So, the D01 songs don't work!  (The
;digital intstruments are all garbled, yuck).

;Anyway, here's the code!  Assemble it with TASM (MASM shmasm!), and ... have
;fun! Heh.  Oh, don't forget to use forward references!  (/m)

;If you want to get the whole Play-Driver package, call The Revelation Station
;at 604-477-5337.  Please note!  That these drivers and songs are 100%
;copyrighted by the authors, VIBRANTS.  DON'T USE THEM IN YOUR PROGRAMS WITHOUT
;PERMISSION!  As this is not a 'program', but rather a 'tutorial', I hope they
;won't get mad.  :)

; *****************************************************************************

MusicDriver     PROC NEAR

        ; General-purpose Music Driver call

MusicPatch      LABEL BYTE
        nop

        call    DWORD PTR cs:[Player]
        cli     ; remove the cli if you want to use the CPS rate...
        ret

Player  DW      0,0

MusicDriver     ENDP

; *****************************************************************************

;newint1c        PROC

        ; New interrupt 1c!

;        push    ax
;        push    si

;        mov     ah, 3                   ; Update music
;        call    MusicDriver

;        pop     si
;        pop     ax

;        pushf
;        call    DWORD PTR [oldint1c]

;        iret

;        oldint1c        dd      0

;newint1c        ENDP


CODE     ENDS


 END GO
