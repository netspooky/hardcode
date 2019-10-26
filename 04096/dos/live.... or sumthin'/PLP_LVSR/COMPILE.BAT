@echo off

tasm /z /m9 /la intro
tlink /t /3 intro

if exist intro.exe del intro.exe
