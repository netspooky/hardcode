@nasmw pe2com.asm -o pe2com.com -l pe2com.lst
rem @nasmw pe2exe.asm -o pe2exe.exe -l pe2exe.lst
@apack pe2com.com
rem @apack -m pe2exe.exe