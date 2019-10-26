@echo off
echo This example will show some interested experiences with Ripple Viewer
echo Blur=5 Freq=0 Type=1
pause
riplview.exe example.bmp 5 0 1
echo Blur=3 Freq=3 Type=2
pause
riplview.exe example.bmp 3 3 2
echo Blur=4 Freq=1 Type=0
pause
riplview.exe example.bmp 4 1
echo Blur=3 Freq=0 Type=3
pause
riplview.exe example.bmp 3 0 3
echo Blur=0
echo Oh no! No bluring! It looks soooo ugly! Yek!
pause
riplview.exe example.bmp 0
echo ...do rest yourself...