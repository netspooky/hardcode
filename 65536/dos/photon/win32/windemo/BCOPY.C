int mpitch;

void memcpy32bto24b(void *, void *,int);
#pragma aux memcpy32bto24b =\
   "pusha",\
   "push ebp",\
   "xor eax,eax",\
   "shr ecx,5",\
   "xlloop: ",\
   "mov eax,[esi]",\
   "shl eax,8",\
   "mov ebp,[esi+4]",\
   "mov ebx,[esi+8]",\
   "shrd eax,ebp,8",\
   "mov [edi],eax",\
   "rol ebp,8",\
   "mov bp,bx",\
   "mov edx,[esi+12]",\
   "rol ebp,16",\
   "shr ebx,16",\
   "mov [edi+4],ebp",\
   "shl edx,8",\
   "mov dl,bl",\
   "mov [edi+8],edx",\
   "mov eax,[esi+16]",\
   "shl eax,8",\
   "mov ebp,[esi+20]",\
   "mov ebx,[esi+24]",\
   "shrd eax,ebp,8",\
   "mov [edi+12],eax",\
   "rol ebp,8",\
   "mov bp,bx",\
   "mov edx,[esi+28]",\
   "rol ebp,16",\
   "shr ebx,16",\
   "mov [edi+16],ebp",\
   "shl edx,8",\
   "mov dl,bl",\
   "mov [edi+20],edx",\
   "add edi,24",\
   "add esi,32",\
   "dec ecx",\
   "jnz xlloop",\
   "pop ebp",\
   "popa",\
parm [edi] [esi] [ecx] \
modify exact [esi edi eax ebx ecx edx];

void memcpy32bto15b(void *, void *,int);
#pragma aux memcpy32bto15b =\
   "pusha",\
   "push ebp",\
   "xor eax,eax",\
   "shr ecx,2",\
   "xlloop: ",\
   "mov ebx,0",\
   "mov edx,[esi]",\
   "shl edx,16",\
   "shr edx,27",\
   "shl edx,5",\
   "mov ebx,[esi]",\
   "shl ebx,8",\
   "shr ebx,27",\
   "shl ebx,10",\
   "add edx,ebx",\
   "mov ebx,[esi]",\
   "shl ebx,24",\
   "shr ebx,27",\
   "add edx,ebx",\
   "mov [edi],dx",\
   "add edi,2",\
   "add esi,4",\
   "dec ecx",\
   "jnz xlloop",\
   "pop ebp",\
   "popa",\
parm [edi] [esi] [ecx] \
modify exact [esi edi eax ebx ecx edx];
/*
void memcpy32bto16b(void *, void *,int);
#pragma aux memcpy32bto16b =\
   "pusha",\
   "push ebp",\
   "xor eax,eax",\
   "shr ecx,2",\
   "xlloop: ",\
   "mov ebx,0",\
   "mov edx,[esi]",\
   "shl edx,16",\
   "shr edx,26",\
   "shl edx,5",\
   "mov ebx,[esi]",\
   "shl ebx,8",\
   "shr ebx,27",\
   "shl ebx,11",\
   "add edx,ebx",\
   "mov ebx,[esi]",\
   "shl ebx,24",\
   "shr ebx,27",\
   "add edx,ebx",\
   "mov [edi],dx",\
   "add edi,2",\
   "add esi,4",\
   "dec ecx",\
   "jnz xlloop",\
   "pop ebp",\
   "popa",\
parm [edi] [esi] [ecx] \
modify exact [esi edi eax ebx ecx edx];
*/

void memcpy32bto16b1(void *, void *,int);
#pragma aux memcpy32bto16b1 =\
   "pusha",\
   "push ebp",\
   "xor eax,eax",\
   "shr ecx,2",\
   "xlloop: ",\
   "mov edx,[esi]",\
   "and edx, 000000001111100000000000b",\
   "shr edx,6",\
   "mov ebx,[esi]",\
   "and ebx, 111110000000000000000000b",\
   "shr ebx,9",\
   "add edx, ebx",\
   "mov ebx,[esi]",\
   "and ebx, 000000000000000011111000b",\
   "shr ebx, 3",\
   "add edx, ebx",\
   "mov [edi],dx",\
   "add edi,2",\
   "add esi,4",\
   "dec ecx",\
   "jnz xlloop",\
   "pop ebp",\
   "popa",\
parm [edi] [esi] [ecx] \
modify exact [esi edi eax ebx ecx edx];

void memcpy32bto16b320d1(void *, void *,int);
#pragma aux memcpy32bto16b320d1 =\
   "pusha",\
   "push ebp",\
   "mov ebp, [mpitch]",\
   "xor eax,eax",\
   "shr ecx,2",\
   "xlloop: ",\
   "mov edx,[esi]",\
   "and edx, 000000001111100000000000b",\
   "shr edx,6",\
   "mov ebx,[esi]",\
   "and ebx, 111110000000000000000000b",\
   "shr ebx,9",\
   "add edx, ebx",\
   "mov ebx,[esi]",\
   "and ebx, 000000000000000011111000b",\
   "shr ebx, 3",\
   "add edx, ebx",\
   "mov ebx, edx",\
   "shl ebx, 16",\
   "mov bx, dx",\
   "mov [edi],ebx",\
   "mov [edi+ebp],ebx",\
   "add edi,4",\
   "add esi,4",\
   "dec ecx",\
   "jnz xlloop",\
   "pop ebp",\
   "popa",\
parm [edi] [esi] [ecx] \
modify exact [esi edi eax ebx ecx edx];

void memcpy32bto16b320d2(void *, void *,int);
#pragma aux memcpy32bto16b320d2 =\
   "pusha",\
   "push ebp",\
   "mov ebp, [mpitch]",\
   "xor eax,eax",\
   "shr ecx,2",\
   "xlloop: ",\
   "mov edx,[esi]",\
   "and edx, 000000001111110000000000b",\
   "shr edx,5",\
   "mov ebx,[esi]",\
   "and ebx, 111110000000000000000000b",\
   "shr ebx,8",\
   "add edx, ebx",\
   "mov ebx,[esi]",\
   "and ebx, 000000000000000011111000b",\
   "shr ebx, 3",\
   "add edx, ebx",\
   "mov ebx, edx",\
   "shl ebx, 16",\
   "mov bx, dx",\
   "mov [edi],ebx",\
   "mov [edi+ebp],ebx",\
   "add edi,4",\
   "add esi,4",\
   "dec ecx",\
   "jnz xlloop",\
   "pop ebp",\
   "popa",\
parm [edi] [esi] [ecx] \
modify exact [esi edi eax ebx ecx edx];

void memcpy32bto16b2(void *, void *,int);
#pragma aux memcpy32bto16b2 =\
   "pusha",\
   "push ebp",\
   "xor eax,eax",\
   "shr ecx,2",\
   "xlloop: ",\
   "mov edx,[esi]",\
   "and edx, 000000001111110000000000b",\
   "shr edx,5",\
   "mov ebx,[esi]",\
   "and ebx, 111110000000000000000000b",\
   "shr ebx,8",\
   "add edx, ebx",\
   "mov ebx,[esi]",\
   "and ebx, 000000000000000011111000b",\
   "shr ebx, 3",\
   "add edx, ebx",\
   "mov [edi],dx",\
   "add edi,2",\
   "add esi,4",\
   "dec ecx",\
   "jnz xlloop",\
   "pop ebp",\
   "popa",\
parm [edi] [esi] [ecx] \
modify exact [esi edi eax ebx ecx edx];

//6, 8, 3 i fullscreen (1.5.5.5)

/*

//Green
   "and edx, 000000001111100000000000b",\
   "shr edx,5",\
//Red
   "and edx, 111110000000000000000000b",\
   "shr edx,8",\
//Blue
   "and edx, 000000000000000011111000b",\
   "shr edx, 3",\

   "mov ebx,[esi]",\
   "and ebx, 111110000000000000000000b",\
   "shr ebx,19",\
   "add edx,ebx",\
   "mov ebx,[esi]",\
   "and ebx, 000000000000000011111000b",\
   "shl ebx, 8",\
   "add edx,ebx",\
   */
