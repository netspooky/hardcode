@Echo off
if "%1"=="" goto infohelp
%1
echo  ÿ
if errorlevel==0 goto info0
if errorlevel==1 goto info1
if errorlevel==2 goto info2
if errorlevel==3 goto info3
if errorlevel==4 goto info4
if errorlevel==5 goto info5
echo Unknown error. Report to the Author!
goto end
:infohelp
echo ÿ
echo Usage:     RUNHELP  (GIANT or GIANTSHW)
echo ÿ
echo            This little program helps you to find out
echo            if you cannot run these 4kb intros.
goto end
:info1
echo Out of Memory.
goto end
:info2
echo 386 or better needed.
goto end
:info3
echo Math coprocessor not found.
goto end
:info4
echo VGA needed.
goto end
:info5
echo DOS version 3.0 or better needed.
goto end
:info0
echo Everything went OK!
:end

