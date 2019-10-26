@echo off
if exist b1.dat goto _%1
echo suxx 
goto e
:_
cls
echo the BATCH 4k - please wait.. precalculating..
echo.>b2.dat
call %0 g0 b1 $ **
call %0 g0 b2 # ****************************************************************
call %0 g0 b1 ^ weÿrulez!
for %%a in (0,1,2,3) do call %0 c %%a.!
for %%a in (0,1,2,3) do call %0 p1 %%a 
for %%a in (0,1,2,3,4,5,6) do call %0 p4 %%a 
for %%a in (0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6) do echo.>>2.!
echo ***************************************************************************>>2.!
for %%a in (6,5,4,3,2,1,0) do call %0 p5 %%a 
goto d
:_c
echo.>%2
goto e
:_p1
for %%b in (0,1,2,3,4,5,6,7,8,9) do call %0 p2 3 6 0
goto e
:_p4
for %%b in (0,2,4,6,8) do call %0 p2 %2 %%b 1
goto e
:_p5
for %%b in (8,6,4,2,0) do call %0 p2 %2 %%b 3
goto e
:_p2
copy /b %4.!+%2%3.$ >nul
goto e
:_g0
copy %2.dat t.%3 >nul
for %%a in (0,1,2,3,4,5,6,7) do call %0 g1 %%a %2 %3 %4
del t.%3 >nul
goto e
:_g1
for %%b in (0,1,2,3,4,5,6,7,8,9) do call %0 g2 %2 %%b %3 %4 %5
goto e
:_g2
if '%2%3'=='00' goto e
if '%2%3'=='79' goto e
copy t.%5 %2%3.%5 >nul
echo %6>>%2%3.%5
copy t.%5+%4.dat >nul
goto e
:d
for %%c in (0,1,2,3,4) do call %0 x2
for %%c in (0,1,2) do call %0 x3
for %%c in (0,1,2,3,4,5,6,7,8,9) do call %0 x4
for %%c in (0,1,2,3,4) do call %0 x1
goto de
:_x4
for %%a in (0,1,2,3) do call %0 k %%a.!
goto e
:_k
for %%e in (0,1,2,3,4,5,6,7,8,9) do call %0 w
cls
type %2
goto e
:_x2
for %%a in (0,1,2,3,4) do call %0 o3 %%a
for %%a in (4,3,2,1,0) do call %0 v3 %%a
goto e
:_x3
for %%a in (6,5,4,3,2,1,0) do call %0 v4 %%a
goto e
:_x1
for %%a in (0,1,2,3,4,5,6,7) do call %0 o1 %%a
for %%a in (7,6,5,4,3,2,1,0) do call %0 v1 %%a
goto e
:_o1
for %%b in (1,3,5,7,9) do call %0 o2 %2 %%b $
goto e
:_o3
for %%b in (0,1,2,3,4,5,6,7,8,9) do call %0 o2 %2 %%b #
goto e
:_o2
if '%4'=='$' goto t_o2
cls
:t_o2
if '%2%3'=='00' goto e
if '%2%3'=='79' goto e
if '%2%3'=='77' goto e
type %2%3.%4
goto e
:_v1
for %%b in (9,7,5,3,1) do call %0 v2 %2 %%b $
goto e
:_v3
for %%b in (9,8,7,6,5,4,3,2,1,0) do call %0 v2 %2 %%b #
goto e
:_v4
for %%b in (9,8,7,6,5,4,3,2,1,0) do call %0 v2 %2 %%b ^
goto e
:_v2
if '%4'=='$' goto tv2
cls
:tv2
if '%2%3'=='00' goto e
if '%2%3'=='79' goto e 
if '%2%3'=='01' goto e
type %2%3.%4
if '%4'=='^' goto tv4
goto e
:tv4
for %%d in (0,1,2,3,4,5,6,7,8) do type %2%3.%4
goto e
:_s
echo %2
echo.
for %%c in (*.$) do call %0 w
:_w
goto e
:de
for %%c in (0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f,g,h,i,j,k,l,m,n) do call %0 s ÿ
call %0 s youÿhaveÿexperienced
call %0 s daÿbatchhÿ4kÿfromÿb˜teamÿatÿgy¢gyszer'97
call %0 s ÿ
call %0 s codedÿbyÿroby/\/\u$ÿandÿblala
call %0 s ÿ
call %0 s shortÿgreets:ÿgitaneÿðÿbigfootÿðÿlorenzoÿðÿgafÿðÿdc-1 
call %0 s -------------ÿbobÿðÿtomcat2ÿðÿnormanÿðÿathoszÿðÿetc!!
for %%c in (0,1,2,3,4,5,6,7,8,9) do call %0 s ÿ
call %0 s tÿhÿeÿÿÿeÿnÿd
for %%c in (0,1,2,3,4,5,6,7,8,9,a,b,c) do call %0 s ÿ
del *.$
del *.#
del *.^
del *.!
del b2.dat
:e