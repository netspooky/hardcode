cls

gosub pg
?:?"         pRESS eNTAR tO sTART dA gAME!^^^# cODe by tRATE^#gfx^^bY voiCE!"
play "cdefg"
delay 0.1
play"g"
delay 0.1
play"aaaag"
delay 0.1
play "aaaag"
delay 0.1
play "ffffee
delay 0.1
play "ddddc"

a=timer

frucht:
i$=inkey$
if i$<>chr$(13) then frucht
b=timer

randomize b-a
cls

gamestart = timer

locate 23,1
?"----^#timer::        :---------------------------------^#hits::         :-----"

locate 23,15
? agt
locate 23,65
? treffer


dc=1
x=1
ex=1
sready=1
gosub pEimer
gosub pSprite
setTime=timer


while(a$<>chr$(27))

  again:

  if int(timer-gamestart)>agt then

     agt=int(timer-gamestart)
     locate 23,15
     ? agt

     if treffer/agt => 1 then
        locate 23,34
        ?"*trate-like*------"
        goto sdr
     end if

     if treffer/agt => 0.9 then
        locate 23,34
        ?"*fbk-like*--------"
        goto sdr
     end if

     if treffer/agt => 0.8 then
        locate 23,34
        ?"*superb*----------"
        goto sdr
     end if

     if treffer/agt => 0.7 then
        locate 23,34
        ?"*nice*------------"
        goto sdr
     end if

     if treffer/agt => 0.6 then
        locate 23,34
        ?"*well, quite nice*"
        goto sdr
     end if

     if treffer/agt => 0.5 then
        locate 23,34
        ?"*ok*--------------"
        goto sdr
     end if

    if treffer/agt => 0.4 then
        locate 23,34
        ?"*mmhh.. *---------"
        goto sdr
     end if

    if treffer/agt => 0.3 then
        locate 23,34
        ?"*mmhh.. *---------"
        goto sdr
     end if

    if treffer/agt => 0.2 then
        locate 23,34
        ?"*erm. not soo bad*-"
        goto sdr
     end if

    if treffer/agt <= 0.2 then
        locate 23,34
        ?"*l„cherlich!*------"
        goto sdr
     end if

     sdr:

  end if

  acttimer=timer
  if acttimer-setTime>0.03   then

     if dc=7 then
             direc=int(100*rnd(77)+1)
             dc=1
     end if

     if dc<7 then dc=dc+1

     if direc>50 and ex<60 then
        gosub crEimer
        ex=ex+1
     end if

     if direc<50 and ex>1 then
        gosub clEimer
        ex=ex-1
     end if

     gosub pEimer

     setTime = timer
  end if

  a$=inkey$

  if sready>1 then sready=sready-1

  if a$="" goto again



  if a$=chr$(0)+"K" then

     if x>1 then
        gosub clSprite
        x=x-1
        gosub pSprite
     end if

  end if

  if a$=chr$(0)+"M" then
     if x<47 then
        gosub crSprite
        x=x+1
        gosub pSprite
     end if
  end if

  if a$=" " and sready=1 then
     sready = 20
     gosub pScheisse

     if x+17>ex+7 and x+17<ex+13 then
          treffer = treffer + 1
          locate 23,65
          ? treffer

          if treffer = 15 then
             cls
             gosub pg
             ?:?"  the end - 'coded' by trate, big fbk logo by voice... "
             end

          end if
     end if

  end if

wend

cls
gosub pg
?:?"             the end - 'coded' by trate, big fbk logo by voice... "

end

pSprite:

locate 1,x
?"            \///\\\\//"
locate 2,x
?"           ( _      _ )"
locate 3,x
?"          ____\    / _____"
locate 4,x
?"        /                 \"
locate 5,x
?"      /  __            __   \"
locate 6,x
?"    /  /  |            |  \   \"
locate 7,x
?" /   /    |            |    \   \"
locate 8,x
?"/.\/      \            /      \/\."
locate 9,x
?"           )          ("
locate 10,x
?"          /      .     \"
locate 11,x
?"         /       .       \"
locate 12,x
?"        (       /:\       )"
locate 13,x
?"          \ __ //   \ __ /"


return

crSprite:

locate 1,x+12
?" "
locate 2,x+12
?" "
locate 3,x+10
?" "
locate 4,x+8
?" "
locate 5,x+6
?" "
locate 6,x+4
?" "
locate 7,x+1
?" "
locate 8,x
?" "
locate 9,x+11
?" "
locate 10,x+10
?" "
locate 11,x+9
?" "
locate 12,x+8
?" "
locate 13,x+10
?" "

return

clSprite:

locate 1,x+22
?" "
locate 2,x+22
?" "
locate 3,x+25
?" "
locate 4,x+27
?" "
locate 5,x+28
?" "
locate 6,x+30
?" "
locate 7,x+32
?" "
locate 8,x+33
?" "
locate 9,x+22
?" "
locate 10,x+23
?" "
locate 11,x+25
?" "
locate 12,x+26
?" "
locate 13,x+25
?" "

return


pEimer:

locate 18,ex
?"    \       /"

locate 19,ex

?"     |     |"

locate 20,ex
?"     |     |"

locate 21,ex
?"     |_____|"

color 6,0
for i=1 to treffer
    if i<=6 then locate 21,ex+6+i-1
    if i=>6 then locate 20,ex+i
    if i=>11 then locate 19,ex+i-5
    ?"O"
next i
color 7,0

return

clEimer:

locate 18,ex+12
?" "
locate 19,ex+11
?" "
locate 20,ex+11
?" "
locate 21,ex+11
?" "

return


crEimer:

locate 18,ex+4
?" "
locate 19,ex+5
?" "
locate 20,ex+5
?" "
locate 21,ex+5
?" "

return

pScheisse:

color 6,0
locate 13,x+17
?"O"
delay 0.07
locate 13,x+17
?" "

locate 14,x+17
?"O"
delay 0.07
locate 14,x+17
?" "

locate 15,x+17
?"O"
delay 0.07
locate 15,x+17
?" "

locate 17,x+17
?"O"
delay 0.07
locate 17,x+17
?" "

locate 18,x+17
?"O"
delay 0.07
locate 18,x+17
?" "
color 7,0

return

pg:
?"                                       |
?"             , .                  //'  |
?"           `                     /'   ø:        //|        ù,       ù,
?"          `                _ ___|¬______)\    //' |  _ ______)\       `,
?"           `ù,.       , '       :      ///  //'  ù|   :ø     ¬/'       .
?"                     ù«         ù     //'  /'    :|          |'
?"           ù     ù ùù:       :      //'|  |ø     ||   '      : ùù  ù
?"              ,ù     |    - -ö----\/'  |  |      !|,ù'       '
?"  _ __ ___  /(__vc!bm: _   _ |__|___   :  |      ù       ., ' _ ______ __ _
?"- -        `\\       ù      ¬:    //   _ _:                 `,            -- -
?"   `    - -- -\\     ù       '  //'  '    ù ` ,   :ù.        :-- -       '
?"    -\_  __  _ `\   _:.     _ù_/'  `           ù  |__`,     :| __ ___ _/-
?"                 `\( |       :  : ù    ù       :  |   :     ||
?"                     |ù      |  |      :«`.    ù ù|   |     :|
?"       `,       \ \\ |:      |  :«      `'     ' :|  _:«_ ___`\   /
?"       ù             ||      |   `ù,____ __ ,ù'  ||   ù      )/'      ,.ù
?"                     |:    _/'            :      :|
?"                     |ù. '                `  ù . ù|  _fischbratkueche_
?"                     |`                          `|

return


