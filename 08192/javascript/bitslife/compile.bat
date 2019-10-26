@echo off

rem java -jar closure-compiler.jar --compilation_level ADVANCED_OPTIMIZATIONS --js intro.js --js_output_file intro-compiled.js 
rem jsexe.exe intro-compiled.js index.html

jsexe.exe -bn intro.js index.html
