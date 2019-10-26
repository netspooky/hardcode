echo off
cls
echo;
echo This batch file will compile the Immortal Syndicate's BBS advertisement
echo Number 2 - Version 2.0
echo;
echo;
pause
tasm /m9 LOADER
tlink LOADER /t
cls
echo;
echo Compiling complete!
echo;
echo Your resulting compiled com file will now be many times larger than the
echo one the Immortal Syndicate released.  This is due to the fact of a post-
echo processing program which removed zero data from the end of the com file.
echo;
echo If you would like your com file to be the same as ours (5k) then you must
echo do some experimenting, and make a post-processing program of your own.


