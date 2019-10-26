@echo off
mode 80
echo.
echo.
echo     ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹ €€€
echo    ≤ﬂ ‹‹‹‹‹‹ ﬂ ‹‹  ‹‹ ﬂ ‹‹‹‹‹‹ ﬂ ‹‹‹‹‹‹ ﬂ ‹‹‹‹‹‹ ﬂ ‹‹‹‹‹‹ ﬂ ‹‹‹‹€€€ ≤
echo    ± ≤€€  ﬂﬂﬂ ≤€€  €€€ ≤€€  ﬂﬂﬂ ≤€€  €€€ ≤€€  €€€ ≤€€  €€€ ≤€€  €€€ ±
echo    ∞ ﬂﬂﬂﬂﬂ€€€ ±≤€  €€€ ﬂﬂﬂﬂﬂ€€€ ±≤€  €€€ ±≤€ﬂﬂﬂﬂﬂ ±≤€  €€€ ±≤€  €€€ ∞
echo    ± ∞±≤‹€€€ﬂ ∞±≤‹€€€ﬂ ∞±≤‹€€€ﬂ ∞±≤‹€€€ﬂ ∞±≤‹€€€ﬂ ∞±≤ ‹€€ﬂ ∞±≤‹€€€ﬂ ±
echo    ﬂ≤‹‹‹‹       ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹ €€€ ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹       ‹‹‹‹≤ﬂ
echo        ﬂﬂ€€‹ ‹€€ﬂﬂ              ﬂﬂﬂ                   ﬂﬂ€€‹ ‹€€ﬂﬂ^ins
echo            ≤ €            . p R E S E N T s .             € ≤
echo            ± ›             "trace your mind"              ﬁ ±
echo     ‹‹‹ ‹  ∞ ›         a 4kb  realtime raytracer          ﬁ ∞  ‹ ‹‹‹
echo    ≤ﬂ                                                              ﬂ≤
echo    ≤                     1)  320 x 180 x 16bpp                      ≤
echo    ±                     2)  160 x 160 x 16bpp                      ±
echo    ±                     3)  160 x  80 x 16bpp                      ±
echo    ∞                     4)  80  x  40 x 16bpp                      ∞
echo    ∞                     5)  80  x  40 x 16bpp (small)              ∞
echo    ∞                     6)  exit                                   ∞
choice /c:123456 /n /t:4,20 ˇ  ∞                      select resolution: 
IF ERRORLEVEL 6 GOTO FUCK
IF ERRORLEVEL 5 GOTO RES5
IF ERRORLEVEL 4 GOTO RES4
IF ERRORLEVEL 3 GOTO RES3
IF ERRORLEVEL 2 GOTO RES2
trm_3218.exe
GOTO FUCK

:RES2
trm_1616.exe
GOTO FUCK

:RES3
trm_168.exe
GOTO FUCK

:RES4
trm_84.exe
GOTO FUCK

:RES5
trm_84s.exe

:FUCK
