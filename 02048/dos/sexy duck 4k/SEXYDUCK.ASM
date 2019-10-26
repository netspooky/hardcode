 .model tiny
.386
jumps
locals

.code
org 100h
start:
  mov ax,0003h
  int 10h

  mov ax,0100h
  mov cx,9735			;Textcursor an=1543 aus=9735
  int 10h


  mov di,offset sbuf		;SCREENBUFFER ZUM ERSTEN MAL LOESCHEN
  mov ax,0f20h
  mov cx,2000
  rep stosw			;move ax to es[di]

  mov di,offset sbuf+160	;STERNLINIE OBEN ZEICHNEN
  mov ax,0f2ah
  mov cx,80 ;1840
  rep stosw			;move ax to es[di]

  mov di,offset sbuf+3680	;STERNLINIE UNTEN ZEICHNEN
  mov ax,0f2ah
  mov cx,80
  rep stosw			;move ax to es[di]

  call BufScreen
  mov cx,20
  call WaitRet			;WARTEN VOR DEM 1. TEXT

  lea si,Text0
  call Teletext
  mov cx,230
  call WaitRet			;1. TEXT

  push es
  push 0b800h
  pop es
  mov ax,0fdbh			;WEISSER BLITZ
  mov di,0
  mov cx,2000
  rep stosw			;move dword ds[si] to es[di]
  pop es
  mov cx,2
  call WaitRet

  mov cx,6
MainLoop:
  push cx

  call ClearBuf
  mov si,offset Ente1
  call Ente
  call BufScreen

  call ClearBuf
  mov si,offset Ente2
  call Ente
  call BufScreen

  call ClearBuf
  mov si,offset Ente3
  call Ente
  call BufScreen

  call ClearBuf
  mov si,offset Ente4
  call Ente
  call BufScreen

  call ClearBuf
  mov si,offset Ente5
  call Ente
  call BufScreen

  call ClearBuf
  mov si,offset Ente4
  call EnteRev
  call BufScreen

  call ClearBuf
  mov si,offset Ente3
  call EnteRev
  call BufScreen

  call ClearBuf
  mov si,offset Ente2
  call EnteRev
  call BufScreen

  call ClearBuf
  mov si,offset Ente1
  call EnteRev
  call BufScreen

  call ClearBuf
  mov si,offset Ente2
  call EnteRev
  call BufScreen

  call ClearBuf
  mov si,offset Ente3
  call EnteRev
  call BufScreen

  call ClearBuf
  mov si,offset Ente4
  call EnteRev
  call BufScreen

  call ClearBuf
  mov si,offset Ente5
  call Ente
  call BufScreen

  call ClearBuf
  mov si,offset Ente4
  call Ente
  call BufScreen

  call ClearBuf
  mov si,offset Ente3
  call Ente
  call BufScreen

  call ClearBuf
  mov si,offset Ente2
  call Ente
  call BufScreen

  pop cx
  loop MainLoop


  push es
  push 0b800h
  pop es
  mov ax,0fdbh			;WEISSER BLITZ
  mov di,0
  mov cx,2000
  rep stosw			;move dword ds[si] to es[di]
  pop es
  mov cx,2
  call WaitRet

  mov di,offset sbuf+320	;SAUBER
  mov ax,0f20h
  mov cx,1680
  rep stosw			;move ax to es[di]

  call BufScreen

  lea si,Text1
  call Teletext
  mov cx,140
  call WaitRet
  lea si,Text2
  call Teletext
  mov cx,140
  call WaitRet
  lea si,Text3
  call Teletext
  mov cx,80
  call WaitRet
  lea si,Text4
  call Teletext
  mov cx,80
  call WaitRet
  lea si,Text5
  call Teletext
  mov cx,80
  call WaitRet

  push es
  push 0b800h
  pop es
  mov ax,0fdbh			;WEISSER BLITZ
  mov di,0
  mov cx,2000
  rep stosw			;move dword ds[si] to es[di]
  pop es

  mov cx,2
  call WaitRet

  push es
  push 0b800h
  pop es
  mov ax,0f20h			;WEISSER BLITZ AUS
  mov di,0
  mov cx,2000
  rep stosw			;move dword ds[si] to es[di]
  pop es

  mov ax,0100h
  mov cx,1543			;Textcursor an=1543 aus=9735
  int 10h

  mov ax, 004ch
  int 21h

;------------------------------------------------------------------------

Teletext proc

  push es
  push 0b800h
  pop es

  push si

  mov si,offset sbuf		;Screen saubern
  mov ax,0f20h
  mov di,320
  mov cx,1680
  rep stosw			;move dword ds[si] to es[di]

  pop si

  mov di,(3*80)*2-16

;  lea si,Text1
  lea bx,Font


  @@writetext:

  lodsb
  cmp al,-1
  je  @@endoftext
  cmp al,0
  jne @@nobreak
     add di,6*160
     lodsb
  @@nobreak:
  add di,16
  cmp al,32
  je  @@writetext

     pusha
     sub al,63
     mov ah,0
     imul ax,7*5
     add bx,ax

     mov cx,5
     @@ycharlp:
        mov ch,7
        @@xcharlp:
           mov al,[bx]
           inc bx
           stosb
           inc di
           dec ch
        jnz @@xcharlp
        add di,160-14
     loop @@ycharlp
     sub di,5*160
     
     mov cx,2
     call WaitRet

     popa
     
  jmp @@writetext


  @@endoftext:

  pop es

  ret

Teletext endp

BufScreen proc
  push es			;SCREENPUFFER -> SCREEN
  push 0b800h
  pop es
  mov si,offset sbuf
  mov di,0
  mov cx,1000
  rep movsd			;move dword ds[si] to es[di]
  pop es
  mov cx,6
  call WaitRet
  ret
BufScreen endp

ClearBuf proc
  mov di,offset sbuf		;SCREENBUFFER LOESCHEN
  add di,320
  mov ax,0f2eh
  mov cx,1680
  rep stosw			;move ax to es[di]

  mov di,offset backcount
  mov bx,[di]
  add bx,2			;ZAEHLER FUER DIE STREIFEN ERHOEHEN
  cmp bx,10
  jl ClearNoReset
  mov bx,0
ClearNoReset:
  mov [di],bl

  add bx,320

  mov di,offset sbuf
  mov cx,280
  mov al,42
ClearLoop:
  mov [di+bx],al		;STERNSTREIFEN ZEICHNEN
  add bx,12
loop ClearLoop

  ret
ClearBuf endp

WaitRet proc
;  mov cx,6
WaitLoop:
  mov dx,3dah
WaitForOff:
  in al,dx
  test al,08h
  jnz WaitForOff
WaitForOn:
  in al,dx
  test al,08h
  jz WaitForOn
loop WaitLoop
  ret
WaitRet endp

Ente proc
  mov ah,0eh			;Farbe
  mov bx,9999
  mov ch,0
Label1:
  cmp bx,[si]
  je Label2
  mov di,offset sbuf
  add di,[si]
  add si,2
  mov al,[si]
  inc si
  mov cl,[si]
  rep stosw			;move ax to es[di]
  inc si
  jmp Label1
Label2:
  ret
Ente endp

EnteRev proc
  mov ah,0eh			;Farbe
  mov bx,9999
  mov ch,0
LabelRev1:
  cmp bx,[si]
  je LabelRev2
  mov di,offset sbuf+160
  add di,[si]

  push ax
  push bx
  mov ax,[si]
  mov bl,160
  div bl
  shr ax,7
  sub di,ax
  pop bx
  pop ax

  add si,2
  mov al,[si]
  inc si
  mov cl,[si]

  mov ch,0
  sub di,cx
  sub di,cx

  rep stosw			;move ax to es[di]
  inc si
  jmp LabelRev1
LabelRev2:
  ret
EnteRev endp

;------------------------------------------------------------------------

sbuf db 4000 dup(0)

backcount dw 0

Ente1   dw 680
  db 219,7
  dw 834
  db 219,3
  dw 840
  db 32,7
  dw 854
  db 219,3
  dw 976
  db 219,9
  dw 994
  db 32,13
  dw 1020
  db 219,2
  dw 1134
  db 219,1
  dw 1136
  db 32,24
  dw 1184
  db 219,1
  dw 1296
  db 219,2
  dw 1300
  db 32,22
  dw 1344
  db 219,1
  dw 1404
  db 219,3
  dw 1460
  db 219,3
  dw 1466
  db 32,18
  dw 1502
  db 219,1
  dw 1562
  db 219,1
  dw 1564
  db 32,3
  dw 1570
  db 219,1
  dw 1626
  db 219,1
  dw 1628
  db 32,16
  dw 1660
  db 219,1
  dw 1716
  db 219,3
  dw 1722
  db 32,5
  dw 1732
  db 219,1
  dw 1784
  db 219,1
  dw 1786
  db 32,17
  dw 1820
  db 219,1
  dw 1868
  db 219,4
  dw 1876
  db 32,9
  dw 1894
  db 219,1
  dw 1942
  db 219,1
  dw 1944
  db 32,19
  dw 1982
  db 219,3
  dw 2016
  db 219,6
  dw 2028
  db 32,13
  dw 2054
  db 219,1
  dw 2102
  db 219,1
  dw 2104
  db 32,22
  dw 2148
  db 219,14
  dw 2176
  db 32,19
  dw 2214
  db 219,1
  dw 2262
  db 219,1
  dw 2264
  db 32,55
  dw 2374
  db 219,1
  dw 2422
  db 219,1
  dw 2424
  db 32,54
  dw 2532
  db 219,1
  dw 2584
  db 219,1
  dw 2586
  db 32,52
  dw 2690
  db 219,1
  dw 2746
  db 219,2
  dw 2750
  db 32,48
  dw 2846
  db 219,2
  dw 2910
  db 219,3
  dw 2916
  db 32,42
  dw 3000
  db 219,3
  dw 3076
  db 219,4
  dw 3084
  db 32,34
  dw 3152
  db 219,4
  dw 3244
  db 219,34
  dw 9999

Ente2   dw 688
  db 219,7
  dw 842
  db 219,3
  dw 848
  db 32,7
  dw 862
  db 219,3
  dw 990
  db 219,6
  dw 1002
  db 32,13
  dw 1028
  db 219,2
  dw 1148
  db 219,1
  dw 1150
  db 32,21
  dw 1192
  db 219,1
  dw 1310
  db 219,1
  dw 1312
  db 32,21
  dw 1354
  db 219,1
  dw 1392
  db 219,4
  dw 1472
  db 219,2
  dw 1476
  db 32,19
  dw 1514
  db 219,1
  dw 1548
  db 219,2
  dw 1552
  db 32,4
  dw 1560
  db 219,1
  dw 1636
  db 219,1
  dw 1638
  db 32,17
  dw 1672
  db 219,1
  dw 1704
  db 219,2
  dw 1708
  db 32,7
  dw 1722
  db 219,1
  dw 1792
  db 219,2
  dw 1796
  db 32,17
  dw 1830
  db 219,1
  dw 1858
  db 219,3
  dw 1864
  db 32,10
  dw 1884
  db 219,1
  dw 1950
  db 219,1
  dw 1952
  db 32,20
  dw 1992
  db 219,2
  dw 2012
  db 219,3
  dw 2018
  db 32,14
  dw 2046
  db 219,1
  dw 2108
  db 219,1
  dw 2110
  db 32,23
  dw 2156
  db 219,8
  dw 2172
  db 32,18
  dw 2208
  db 219,1
  dw 2268
  db 219,1
  dw 2270
  db 32,49
  dw 2368
  db 219,1
  dw 2428
  db 219,1
  dw 2430
  db 32,49
  dw 2528
  db 219,1
  dw 2590
  db 219,1
  dw 2592
  db 32,47
  dw 2686
  db 219,1
  dw 2752
  db 219,1
  dw 2754
  db 32,45
  dw 2844
  db 219,1
  dw 2914
  db 219,2
  dw 2918
  db 32,40
  dw 2998
  db 219,3
  dw 3078
  db 219,4
  dw 3086
  db 32,33
  dw 3152
  db 219,3
  dw 3246
  db 219,33
  dw 9999

Ente3   dw 700
  db 219,8
  dw 854
  db 219,3
  dw 860
  db 32,8
  dw 876
  db 219,2
  dw 1006
  db 219,4
  dw 1014
  db 32,13
  dw 1040
  db 219,2
  dw 1164
  db 219,1
  dw 1166
  db 32,19
  dw 1204
  db 219,1
  dw 1326
  db 219,1
  dw 1328
  db 32,18
  dw 1364
  db 219,1
  dw 1380
  db 219,4
  dw 1488
  db 219,1
  dw 1490
  db 32,17
  dw 1524
  db 219,1
  dw 1536
  db 219,2
  dw 1540
  db 32,4
  dw 1548
  db 219,2
  dw 1646
  db 219,1
  dw 1648
  db 32,17
  dw 1682
  db 219,1
  dw 1692
  db 219,2
  dw 1696
  db 32,8
  dw 1712
  db 219,2
  dw 1802
  db 219,2
  dw 1806
  db 32,17
  dw 1840
  db 219,1
  dw 1848
  db 219,2
  dw 1852
  db 32,12
  dw 1876
  db 219,2
  dw 1958
  db 219,2
  dw 1962
  db 32,20
  dw 2002
  db 219,3
  dw 2008
  db 32,16
  dw 2040
  db 219,1
  dw 2116
  db 219,1
  dw 2118
  db 32,42
  dw 2202
  db 219,1
  dw 2274
  db 219,1
  dw 2276
  db 32,44
  dw 2364
  db 219,1
  dw 2434
  db 219,1
  dw 2436
  db 32,44
  dw 2524
  db 219,1
  dw 2594
  db 219,1
  dw 2596
  db 32,43
  dw 2682
  db 219,1
  dw 2756
  db 219,1
  dw 2758
  db 32,41
  dw 2840
  db 219,1
  dw 2918
  db 219,2
  dw 2922
  db 32,37
  dw 2996
  db 219,2
  dw 3082
  db 219,3
  dw 3088
  db 32,31
  dw 3150
  db 219,3
  dw 3248
  db 219,31
  dw 9999

Ente4   dw 704
  db 219,9
  dw 858
  db 219,3
  dw 864
  db 32,9
  dw 882
  db 219,2
  dw 1012
  db 219,3
  dw 1018
  db 32,14
  dw 1046
  db 219,2
  dw 1170
  db 219,1
  dw 1172
  db 32,19
  dw 1210
  db 219,1
  dw 1330
  db 219,1
  dw 1332
  db 32,19
  dw 1370
  db 219,1
  dw 1492
  db 219,1
  dw 1494
  db 32,19
  dw 1532
  db 219,3
  dw 1654
  db 219,1
  dw 1656
  db 32,21
  dw 1698
  db 219,3
  dw 1812
  db 219,1
  dw 1814
  db 32,25
  dw 1864
  db 219,2
  dw 1968
  db 219,2
  dw 1972
  db 32,28
  dw 2028
  db 219,2
  dw 2124
  db 219,2
  dw 2128
  db 32,32
  dw 2192
  db 219,1
  dw 2282
  db 219,1
  dw 2284
  db 32,35
  dw 2354
  db 219,2
  dw 2440
  db 219,1
  dw 2442
  db 32,38
  dw 2518
  db 219,1
  dw 2600
  db 219,1
  dw 2602
  db 32,38
  dw 2678
  db 219,1
  dw 2762
  db 219,1
  dw 2764
  db 32,36
  dw 2836
  db 219,1
  dw 2924
  db 219,1
  dw 2926
  db 32,34
  dw 2994
  db 219,1
  dw 3086
  db 219,2
  dw 3090
  db 32,29
  dw 3148
  db 219,3
  dw 3250
  db 219,29
  dw 9999

Ente5   dw 710
  db 219,9
  dw 864
  db 219,3
  dw 870
  db 32,9
  dw 888
  db 219,3
  dw 1020
  db 219,2
  dw 1024
  db 32,15
  dw 1054
  db 219,2
  dw 1178
  db 219,1
  dw 1180
  db 32,19
  dw 1218
  db 219,1
  dw 1338
  db 219,1
  dw 1340
  db 32,19
  dw 1378
  db 219,1
  dw 1500
  db 219,1
  dw 1502
  db 32,17
  dw 1536
  db 219,1
  dw 1662
  db 219,1
  dw 1664
  db 32,15
  dw 1694
  db 219,1
  dw 1822
  db 219,1
  dw 1824
  db 32,15
  dw 1854
  db 219,1
  dw 1978
  db 219,2
  dw 1982
  db 32,17
  dw 2016
  db 219,2
  dw 2132
  db 219,3
  dw 2138
  db 32,21
  dw 2180
  db 219,3
  dw 2288
  db 219,2
  dw 2292
  db 32,27
  dw 2346
  db 219,2
  dw 2446
  db 219,1
  dw 2448
  db 32,31
  dw 2510
  db 219,1
  dw 2604
  db 219,1
  dw 2606
  db 32,33
  dw 2672
  db 219,1
  dw 2764
  db 219,1
  dw 2766
  db 32,33
  dw 2832
  db 219,1
  dw 2926
  db 219,1
  dw 2928
  db 32,31
  dw 2990
  db 219,1
  dw 3088
  db 219,2
  dw 3092
  db 32,27
  dw 3146
  db 219,2
  dw 3252
  db 219,27
  dw 9999

Font db 'ллллллл'
  db '      л'
  db '   лллл'
  db '       '
  db '   л   '

  db '   л   '
  db '   л   '
  db '   л   '
  db '       '
  db '   л   '

  db 'ллллллл'
  db 'л     л'
  db 'ллллллл'
  db 'л     л'
  db 'л     л'
         
  db 'ллллллл'
  db 'л     л'
  db 'лллллл '
  db 'л     л'
  db 'ллллллл'

  db 'ллллллл'
  db 'л      '
  db 'л      '
  db 'л      '
  db 'ллллллл'

  db 'лллллл '
  db 'л     л'
  db 'л     л'
  db 'л     л'
  db 'лллллл '

  db 'ллллллл'
  db 'л      '
  db 'ллллл  '
  db 'л      '
  db 'ллллллл'

  db 'ллллллл'
  db 'л      '
  db 'ллллл  '
  db 'л      '
  db 'л      '

  db 'ллллллл'
  db 'л      '
  db 'л  лллл'
  db 'л     л'
  db 'ллллллл'

  db 'л     л'
  db 'л     л'
  db 'ллллллл'
  db 'л     л'
  db 'л     л'

  db 'ллллллл'
  db '   л   '
  db '   л   '
  db '   л   '
  db 'ллллллл'

  db 'ллллллл'
  db '      л'
  db '      л'
  db '      л'
  db 'лллллл '

  db 'л     л'
  db 'л     л'
  db 'лллллл '
  db 'л     л'
  db 'л     л'

  db 'л      '
  db 'л      '
  db 'л      '
  db 'л      '
  db 'ллллллл'

  db 'ллллллл'
  db 'л  л  л'
  db 'л  л  л'
  db 'л  л  л'
  db 'л  л  л'

  db 'ллллллл'
  db 'л     л'
  db 'л     л'
  db 'л     л'
  db 'л     л'

  db 'ллллллл'
  db 'л     л'
  db 'л     л'
  db 'л     л'
  db 'ллллллл'

  db 'ллллллл'
  db 'л     л'
  db 'ллллллл'
  db 'л      '
  db 'л      '

  db 'ллллллл'
  db 'л     л'
  db 'л     л'
  db 'л   л л'
  db 'ллллллл'

  db 'ллллллл'
  db 'л     л'
  db 'лллллл '
  db 'л     л'
  db 'л     л'

  db 'ллллллл'
  db 'л      '
  db 'ллллллл'
  db '      л'
  db 'ллллллл'

  db 'ллллллл'
  db '   л   '
  db '   л   '
  db '   л   '
  db '   л   '
  
  db 'л     л'
  db 'л     л'
  db 'л     л'
  db 'л     л'
  db 'ллллллл'

  db 'л     л'
  db 'л    л '
  db 'л   л  '
  db 'л  л   '
  db 'ллл    '

  db 'л  л  л'
  db 'л  л  л'
  db 'л  л  л'
  db 'л  л  л'
  db 'ллллллл'

  db 'л     л'
  db 'л     л'
  db ' ллллл '
  db 'л     л'
  db 'л     л'

  db 'л     л'
  db 'л     л'
  db 'ллллллл'
  db '   л   '
  db '   л   '

  db 'л     л'
  db 'л     л'
  db 'ллллллл'
  db '      л'
  db '      л'

Text0 db ' SEXY     ',0,' DUCK     ',0,' ZK       ',-1
Text1 db ' DONT     ',0,' LIKE     ',0,' THIS?    ',-1
Text2 db ' JUST     ',0,' DONT     ',0,' VOTE@    ',-1
Text3 db ' A        ',0,' REALFAKE ',0,' INTRO    ',-1
Text4 db ' THANKS   ',0,' TO       ',0,' HADES    ',-1
Text5 db ' GREETS   ',0,' TO       ',0,' ALL      ',-1

end start