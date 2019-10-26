;esi=3x3matrix  edi=vector  ebx=target
mattrans proc
    pushad
    mov al, 3               
    @transloop:                                      
        fld dword ptr [edi]  
        fmul qword ptr [esi] 
        fld dword ptr [edi+4]
        fmul qword ptr [esi+24]
        fld dword ptr [edi+8]
        fmul qword ptr [esi+48]
        faddp st(1), st(0)                           
        faddp st(1), st(0)                           
        fstp dword ptr [ebx]
        add esi, 8                                    
        add ebx, 4                                       
    dec al                                           
    jnz @transloop
    popad
ret           
mattrans endp 
              
