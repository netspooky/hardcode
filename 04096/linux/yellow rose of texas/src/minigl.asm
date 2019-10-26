
        bits    32
        extern  dlopen,dlsym
        global  ml_init
        global  mlBegin,mlEnd,mlVertex3f,mlVertex3fv,mlMatrixMode,mlLoadIdentity
        global  mlClearColor,mlClear,mlColor3f
        global  mlRotatef,mlTranslatef,mlEnable,mlDisable
        global  mlLightfv,mlNormal3fv,mlLineWidth,mlFrustum
        section .text
        
ml_init pushad

        xor     eax,eax
        push    eax
        mov     eax,soname
        push    eax
        call    dlopen
        mov     ebp,eax
        pop     eax
        pop     eax

        mov     edi,mlBegin
        mov     esi,names
nexti:  lodsd
        cmp     eax,0
        je      finito
        push    eax
        push    ebp
        call    dlsym
        stosd
        pop     eax
        pop     eax
        jmp     nexti

finito: popad
        ret

        section .data
soname  db      "libGL.so",0

names   dd      glBegin,glEnd,glVertex3f,glMatrixMode,
        dd      glLoadIdentity,glClearColor,glClear,glColor3f,glRotatef,
        dd      glTranslatef,glEnable,glDisable,glLightfv
        dd      glNormal3fv,glLineWidth,glFrustum
        dd      0

glBegin         db      "glBegin",0
glEnd           db      "glEnd",0
glVertex3f      db      "glVertex3f",0
glMatrixMode    db      "glMatrixMode",0

glLoadIdentity  db      "glLoadIdentity",0
glClearColor    db      "glClearColor",0
glClear         db      "glClear",0
glColor3f       db      "glColor3f",0
glRotatef	db	"glRotatef",0

glTranslatef	db	"glTranslatef",0
glEnable	db	"glEnable",0
glDisable       db      "glDisable",0
glLightfv       db      "glLightfv",0

glNormal3fv     db      "glNormal3fv",0
glLineWidth     db      "glLineWidth",0
glFrustum       db      "glFrustum",0

        section .bss
mlBegin         resd    1
mlEnd           resd    1
mlVertex3f      resd    1
mlMatrixMode    resd    1

mlLoadIdentity  resd    1
mlClearColor    resd    1
mlClear         resd    1
mlColor3f       resd    1
mlRotatef	resd	1

mlTranslatef	resd	1
mlEnable	resd	1
mlDisable       resd    1
mlLightfv       resd    1

mlNormal3fv     resd    1
mlLineWidth     resd    1
mlFrustum       resd    1
