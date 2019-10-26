@echo off

if exist intro.com del intro.com

tasm /m /zi /z /ddebug intro
if errorlevel 1 quit

tlink /v /3 intro
if errorlevel 1 quit

td286 %1 intro


