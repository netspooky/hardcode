
InterpolarUV PROC       ;esi->textura, edi->buffer

        xor eax,eax
        mov small yoffset,eax
        mov small y,eax
                                ;  yoffset=0;
                                ;  for (y=0;y<25;y++)
                                ;  {
@loopY:
        xor eax,eax
        mov small xoffset,eax

                                ;xoffset=0;
        mov small x,eax
                                ;for (x=0;x<40;x++)
                                ;{
@loopX:

        mov eax,small x
        mov ebx,small y

        shl ebx,6
        add ebx,eax        ;d00=x+(y<<6);

        shl ebx,2 ;*4

d00     EQU ebx
d01     EQU d00+64*4
d10     EQU d00+1*4
d11     EQU d01+1*4

                            ;        d01=d00+64;
                            ;        d10=d00+1;
                            ;        d11=d01+1;

                ;d_u_ar=(_u[d10]-(u_ar=_u[d00]))>>3; //AjO Optimizing C Revolv¡o %)

        mov   eax,_u[d00]
        mov   ecx,_u[d10]
        mov   small u_ar,eax
        sub   ecx,eax
        shr   ecx,3
        mov   small d_u_ar,ecx

                ;d_v_ar=(_v[d10]-(v_ar=_v[d00]))>>3;

        mov   eax,_v[d00]
        mov   ecx,_v[d10]
        mov   small v_ar,eax
        sub   ecx,eax
        shr   ecx,3
        mov   small d_v_ar,ecx


                                        ;**d_z_ar=(_z[d10]-(z_ar=_z[d00]))>>3;
                ;d_u_ab=(_u[d11]-(u_ab=_u[d01]))>>3;

        mov   eax,_u[d01]
        mov   ecx,_u[d11]
        mov   small u_ab,eax
        sub   ecx,eax
        shr   ecx,3
        mov   small d_u_ab,ecx



                ;d_v_ab=(_v[d11]-(v_ab=_v[d01]))>>3;

        mov   eax,_v[d01]
        mov   ecx,_v[d11]
        mov   small v_ab,eax
        sub   ecx,eax
        shr   ecx,3
        mov   small d_v_ab,ecx

                

            ;     for (intx=0;intx<8;intx++)
            ;     {
            mov small intx,0
@LoopSX:
        
           ;d_u_aa=(u_ab-(u=u_ar))>>3;  //diferencias de arriba a abajo

           mov eax,small u_ar
           mov u,eax
           mov ecx,small u_ab
           sub ecx,eax
           shr ecx,3
           mov small d_u_aa,ecx


           ;d_v_aa=(v_ab-(v=v_ar))>>3;

           mov eax,small v_ar
           mov v,eax
           mov ecx,small v_ab
           sub ecx,eax
           shr ecx,3
           mov small d_v_aa,ecx



                ;           yoff=yoffset;

           mov eax,yoffset
           mov yoff,eax


        mov small inty,0

@LoopSY:
               ;for (inty=0;inty<8;inty++)
               ;{
          

                                        ;     if (abs((z>>8)-zcam)<5000)
                   ;((dword *)RenderBuffer)[xoffset+intx+yoff]=
                   ;  ((dword *)Textura)[((u>>8)&0xff)+(v&0xff00)];

             mov eax,small u
             shr eax,8
             mov ecx,small v
             mov ah,ch
             movzx eax,ax
             shl eax,2
             mov eax,[esi+eax]

             mov ebx,small xoffset
             add ebx,small intx
             add ebx,small yoff
             shl ebx,2
             mov [edi+ebx],eax


             mov ebx,small d_u_aa
             mov eax,small d_v_aa
             add u,small ebx
             add v,small eax
                  ;u+=d_u_aa ;
                  ;v+=d_v_aa ;

              add small yoff,320
                  ;yoff+=320;
                ;           }
             inc small inty
             cmp small inty,8
             jb @LoopSY


             mov eax,d_u_ar
             mov ebx,d_u_ab

             mov ecx,d_v_ar
             mov edx,d_v_ab

             add u_ar,eax
             add u_ab,ebx

             add v_ar,ecx
             add v_ab,edx
        
                ;        u_ar+=d_u_ar; u_ab+=d_u_ab;
                ;        v_ar+=d_v_ar; v_ab+=d_v_ab;


;     }
      inc small intx
      cmp small intx,8
      jb @LoopSX

      
;  xoffset+=8; //X=X+8;
        add small xoffset,8
;         } //next x
      inc small x
      cmp small x,40
      jb @LoopX

      add small yoffset,ModoX*8


        ;    yoffset+=2560;          //320*8;
        ; } //next y
        inc small y
        cmp small y,30
        jb @LoopY

        ret

InterpolarUV ENDP
