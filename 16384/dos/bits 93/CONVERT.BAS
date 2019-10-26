10 S$="123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ()',-.!:? "
20 OPEN "text" FOR INPUT AS #1
30 OPEN "message" FOR OUTPUT AS #2
40 PRINT #2,"message label word"
50 WHILE NOT(EOF(1))
60 LINE INPUT #1,A$
70 FOR I = 1 TO LEN(A$)
80 PRINT #2,CHR$(9);"dw "+STR$(INSTR(S$,MID$(A$,I,1)))+"*font_width*font_height + offset font_table"
90 NEXT
100 WEND
110 CLOSE #1
120 CLOSE #2
130 SYSTEM
