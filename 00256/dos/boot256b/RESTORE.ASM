;Restore MBR by TomCat/Abaddon

;It works under DOS only
;You should select the drive
;The number of the boot drive is 80h

ORG 256
 MOV    AX,13H          ; graphic video mode for colored text
 INT    10H

 CALL   hello
 DB     3+8,'Restore MBR by TomCat/Abaddon',13,10,0
hello:
 POP    SI              ; popsi is my favorite x86 instruction
 CALL   println

 CALL   get
 DB     7,'Get filename...',0
get:
 POP    SI
 CALL   print

 MOV    SI,80H
 MOVZX  CX,BYTE [SI]
 JCXZ   zero
 INC    SI
seek:
 CMP    BYTE [SI],' '
 JA     found
 INC    SI
 LOOP   seek
zero:
 JMP    error
found:
 MOV    DI,SI
seek2:
 CMP    BYTE [SI],' '
 JNA    found2
 INC    SI
 LOOP   seek2
found2:
 MOV    BYTE [SI],0
 PUSHA
 CALL   printok
 CALL   get2
 DB     7,'Get disk number...',0
get2:
 POP    SI
 CALL   print
 POPA
seek3:
 CMP    BYTE [SI],' '
 JA     found3
 INC    SI
 LOOP   seek3
found3:
 CMP    BYTE [SI],'8'
 JNE    error
 MOV    AL,BYTE [SI+1]
 SUB    AL,'0'
 JC     error
 CMP    AL,3
 JA     error
 CBW
 ADD    AL,80H
 MOV    GS,AX
 CALL   printok

 CALL   open
 DB     7,'Load backup file...',0
open:
 POP    SI
 CALL   print

 MOV    DX,DI
 MOV    AX,3D00H
 INT    21H
 JC     error
 XCHG   AX,BX
 MOV    DX,sector
 MOV    CX,768
 MOV    AH,3FH
 INT    21H
 XCHG   AX,BP
 MOV    AH,3EH
 INT    21H
 CALL   printok

 CALL   length
 DB     7,'Check file length...',0
length:
 POP    SI
 CALL   print
 CMP    BP,512
 JA     error
 CALL   printok

 CALL   mbr
 DB     7,'Check MBR...',0
mbr:
 POP    SI
 CALL   print
 CMP    WORD [sector+510],0AA55H
 JC     error
 CALL   printok

 CALL   sure
 DB     7,'Fix MBR... Are you sure? (Yes/No):',0
sure:
 POP    SI
 CALL   print
 MOV    AH,0
 INT    16H
 CMP    AL,'y'
 JE     sureok
 CMP    AL,'Y'
 JE     sureok
 CALL   no
 DB     4+8,' No',0
no:
 POP    SI
 CALL   println
 JMP    aborted

sureok:
 CALL   yes
 DB     2+8,' Yes',0
yes:
 POP    SI
 CALL   println

 CALL   write
 DB     7,'Write sector...',0
write:
 POP    SI
 CALL   print
 MOV    CX,3
retry3:
 PUSH   CX
 MOV    BX,sector
 MOV    DX,GS
 MOV    CX,0001H
 MOV    AX,0301H
 INT    13H
 POP    CX
 JNC    writeok
 MOV    AH,0
 INT    13H
 LOOP   retry3
 JMP    error
writeok:
 CALL   printok

exit:
 CALL   bye
 DB     6,13,10,'Done. Have a nice reboot!',0
bye:
 POP    SI
 CALL   print
 JMP    done

error:
 CALL   printfailed
aborted:
 CALL   abort
 DB     6,13,10,'Aborted.',0
abort:
 POP    SI
 CALL   print
done:
 MOV    AH,0
 INT    16H
 MOV    AX,3
 INT    10H
return:
RETN

printfailed:
 CALL   failed
 DB     4+8,' Failed',0
failed:
 POP    SI
 JMP    println
printok:
 CALL   ok
 DB     2+8,' Ok',0
ok:
 POP    SI
println:
 CALL   print
printnl:
 CALL   newline
 DB     0,13,10,0
newline:
 POP    SI
print:
 LODSB
 MOV    BL,AL
char:
 LODSB
 TEST   AL,AL
 JZ     return
 MOV    AH,0EH
 INT    10H
 JMP    char

sector:
