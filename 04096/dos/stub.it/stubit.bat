@echo off
echo Stub.it v.1.0. (C) by Tyler Durden
tinystub -s %1
peclear %1
dot_it %1
copy /b stub.com+%1 %1.com