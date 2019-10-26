@echo off
call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\bin\vcvars32.bat"
mkdir bin\party
mkdir obj\party

REM 16:9
call build 1024 576
call build 1280 720
call build 1366 768
call build 1600 900
call build 1920 1080
call build 2048 1152
call build 2560 1440
call build 3200 1800
call build 3840 2160
call build 4096 2304
call build 7680 4320
call build 8192 4608

REM 16:10
call build 1024 640
call build 1152 720
call build 1280 800
call build 1440 900
call build 1680 1050
call build 1920 1200
call build 2048 1280
call build 2304 1440
call build 2560 1600
call build 2880 1800
call build 3840 2400
call build 5120 3200
call build 7680 4800

REM 4:3
call build 640 480
call build 800 600
call build 1024 768
call build 1152 864
call build 1280 960
call build 1400 1050
call build 1440 1080
call build 1600 1200
call build 1792 1344
call build 1856 1392
call build 1920 1440
call build 2560 1920
call build 2800 2100
call build 3200 2400
call build 4096 3072
call build 6400 4800

REM 5:4
call build 1280 1024
call build 1600 1280
call build 1800 1440
call build 2560 2048
call build 5120 4096
