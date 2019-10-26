@echo off
mode 80
echo ‹‹‹‹‹‹‹‹‹‹‹‹‹                                             ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
echo             ﬂ€                                           €ﬂ
echo              € ﬂﬂﬂﬂﬂﬂﬂﬂﬂ€‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹€ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ €
echo              €                                      ﬂﬂ€‹ €
echo              €                                         € €
echo              ﬂ                                           ﬂ
echo ‹±∞±≤ﬂﬂ€‹  ‹±∞±≤  €‹  ‹±∞±≤ﬂﬂ€‹  ‹±∞±≤ﬂﬂ€‹  ‹±∞±≤ﬂﬂ€‹  ‹±∞±≤ﬂﬂ€‹  ‹±∞±≤ﬂﬂ€‹
echo €≤±≤€   €› €≤±≤€   €› €≤±≤€   €› €≤±≤€   €› €≤±≤€   €› €≤±≤€   €› €≤±≤€   €›
echo €€≤€€    ﬂ €€≤€€   ﬁ€ €€≤€€    ﬂ €€≤€€   ﬁ€ €€≤€€   ﬁ€ €€≤€€   ﬁ€ €€≤€€   ﬁ€
echo ﬂﬂﬂﬂﬂﬂﬂﬂ€› €€€€€   €› ﬂﬂﬂﬂﬂﬂﬂﬂ€› €€€€€   €› €€€€€ﬂﬂﬂﬂﬂ €€€€€   €› €€€€€   €›
echo €€€€€ ‹€ﬂ  €€€€€ ‹€ﬂ  €€€€€ ‹€ﬂ  €€€€€ ‹€ﬂ  €€€€€ ‹€ﬂ  €€€€€  €ﬂ  €€€€€ ‹€ﬂ
echo  ﬂﬂﬂﬂﬂﬂ     ﬂﬂﬂﬂﬂﬂ     ﬂﬂﬂﬂﬂﬂ    €€€€€ﬂﬂ     ﬂﬂﬂﬂﬂﬂ     ﬂﬂﬂﬂ  ﬂ    ﬂﬂﬂﬂﬂﬂ
echo              € €                 ﬂ€€€€                   €
echo              € ﬂ€‹‹                                 ^ins €
echo              € ‹‹‹‹‹‹‹‹‹€ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€‹‹‹‹‹‹‹‹‹‹ €
echo             ‹€            . p R E S E N T s .            €‹
echo ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ             "trace your mind 2"             ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
echo    ≤ﬂ                                                              ﬂ≤
echo    ≤                      1) 320 x 80 x 16bpp                       ≤
echo    ≤                      2) 160 x 80 x 16bpp                       ≤
echo    ±                      3) 160 x 40 x 16bpp                       ±
echo    ±                      4)  80 x 40 x 16bpp                       ±
echo    ∞                      5) exit                                   ∞
choice /c:12345 /n /t:4,20 ˇ  ∞                      select resolution: 
IF ERRORLEVEL 5 GOTO FUCK
IF ERRORLEVEL 4 GOTO RES4
IF ERRORLEVEL 3 GOTO RES3
IF ERRORLEVEL 2 GOTO RES2
trm2_328.exe
GOTO FUCK

:RES2
trm2_168.exe
GOTO FUCK

:RES3
trm2_164.exe
GOTO FUCK

:RES4
trm2_84.exe

:FUCK
