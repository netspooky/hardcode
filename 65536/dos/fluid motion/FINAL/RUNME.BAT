@echo off
if exist fluid.cfg echo Config file found, Running intro !
if NOT exist fluid.cfg setup.exe
demovt @fluid.cfg
