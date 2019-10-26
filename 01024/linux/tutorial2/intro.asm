%ifndef FULLSCREEN
%define FULLSCREEN 0
;%define FULLSCREEN 0x80000000
%endif

bits 32 ; работаем в 32-битном режиме
org 0x00040000 ; эта константа автоматически прибавляется к смещениям всех меток, также, именно это значение будет лежать в спец-константе $$
; Почему здесь лежит именно такое значение? А хер его знает. (см ниже)

; начало elf-заголовка
db 0x7f, 'ELF' ; magic для опознавания файла, иначе система не поймёт, что это ELF
db 1 ; EI_CLASS = ELFCLASS32
db 1 ; EI_DATA ELFDATA2LSB
db 1 ; EI_VERSION = EV_CURRENT
times 9 db 0 ; 9 неиспользуемых байт, которые можно загадить мусором и не переживать об этом

dw 2 ; e_type = ET_EXEC -- запускаемый файл
dw 3 ; e_machine = EM_386
dd 1 ; e_version = EV_CURRENT
dd _start ; e_entry -- адрес точки входа, с этого места начнётся выполнение программы
dd phdrs - $$ ; e_phoff -- смещение относительно начала файла, по которому находятся program headers
dd 0 ; e_shoff -- --//-- section headers, коих у нас, к слову, нет, поэтому 0
dd 0 ; e_flags -- не надо нам никаких флагов
dw ehsize ; e_ehsize -- размер ELF-заголовка (52 байта)
dw phsize ; e_phentsize -- размер одного program header (32 байта)
dw 3 ; e_phnum -- их количество
;эти поля не нужны, поэтому просто пропускаем их
;dw 0 ; e_shentsize -- размер section header
;dw 0 ; e_shnum -- их количество (тютюшки)
;dw 0 ; e_shstrndx -- что-то там со строками связано, нам не нужно

ehsize equ ($-$$) ; $ означает текущее смещение от начала файла (+значение org), поэтому в ehsize теперь лежит размер elf-заголовка

phdrs: ; начало program header
dd 1 ; p_type = PT_LOAD -- тип заголовка "загрузи кусок файла мне в память, скотина"
dd 0 ; p_offset -- смещение относительно начала файла, откуда читать
dd $$ ; p_vaddr -- адрес в памяти, куда писать
dd $$ ; p_paddr -- физический адрес, какая-то платформенно-специфичная фигота, я сам не разобрался, поэтому давайте не будет выпендриваться и просто повторим за мной
dd file_size ; p_filesz -- размер куска файла, который будем загружать в память
dd mem_size ; p_memsz -- размер этого куска в памяти. Если больше, чем e_filesz, будет полиномиально интерполироваться побайтно. Если больше -- преобразовываться ФНЧ Чебышева второго рода 6 порядка. Шутка. ЛОЛ!!11 На самом деле, если больше, то остаток будет забиваться нулями. А если меньше И ТУТ СУКА ВЗРЫЩ КИШКИ ОБ СТЕНУ МОЗГИ ГОВНО РАСЧЛЕНЁНКА.
dd 7 ; p_flags (=PF_RWX) -- загруженные данные можно будет читать, исполнять и изменять.
dd 0x1000 ; p_align -- выравнивание, применяется и к смещению, и к адресу в памяти. 0x1000 является довольно безопасным значением

phsize equ ($-phdrs) ; аналогично рассчитываем размер program header

dd 2 ; p_type = PT_DYNAMIC
dd dynamic - $$ ; p_offset
dd dynamic ; p_vaddr
dd dynamic ; p_paddr
dd dynamic_size ; p_filesz
dd dynamic_size ; p_memsz
dd 6 ; p_flags = PF_RW
dd 4 ; p_align

dd 3 ; p_type = PT_INTERP
dd interp - $$ ; p_offset
dd interp ; p_vaddr
dd interp ; p_paddr
dd interp_size ; p_filesz
dd interp_size ; p_memsz
dd 4 ; p_flags = PF_R
; dynamic начинается на единицу, поэтому незачем писать еще одну
;dd 1 ; p_align

; данные для PT_DYNAMIC
; только самый необходимый минимум
dynamic:
dd 1, st_libdl_name ; DT_NEEDED -- необходимо прилинковать библиотеку с именем, лежащим в st_libdl_name (индекс в таблице символов)
; опциональные рюшечки, просящие интерпретатор заранее проверить, все ли необходимые библиотеки на месте
;dd 1, st_libSDL_name
;dd 1, st_libGL_name
dd 4, dt_hash ; DT_HASH -- указатель на таблицу хешей
dd 5, dt_strtab ; DT_STRTAB -- указатель на таблицу строк. все ссылки на строки имеют смысл смещения относительно начала таблицы строк
dd 6, dt_symtab ; DT_SYMTAB -- указатель на таблицу символов
dd 10, dt_strtab_size ; DT_STRSZ -- размер таблицы строк
dd 11, 16 ; DT_SYMENT -- размер одной записи в таблице символов
dd 17, dt_rel ; DT_REL -- указатель на таблицу релокаций
dd 18, dt_rel_size; DT_RELSZ -- размер таблицы релокаций
dd 19, 8 ; DT_RELENT -- размер одной записи в таблице релокаций
dd 0, 0 ; DT_NULL -- конец данных для DT_DYNAMIC
dynamic_size equ $ - dynamic

; данные для DT_HASH
; эти данные нужны для чего-то вроде оптимизации загрузки миллионов импортируемых 
; функций из динамических библиотек, однако ж для наших двух функций это оверкилл
; поэтому здесь просто заглушка
dt_hash: dd 1, 3
; dt_symtab начинается как раз с четырёх нулевых двордов
;, 0, 0, 0, 0

; данные для DT_SYMTAB
; именно в этом месте мы говорим, какие функции нам нужно подгрузить динамически
dt_symtab:
; 1 -- первая запись пустая (зачем?!)
dd 0, 0, 0
dw 0, 0 ; SHN_UNDEF
; 2 'dlopen'
dd st_dlopen_name, 0, 0
dw 0x12 ; = ELF32_ST_INFO(STB_GLOBAL, STT_FUNC), т.е., короче говоря, тип символа -- глобальная функция
dw 0 ; SHN_UNDEF говорит, что этого символа у нас нет, и его надо искать вовне
; 3 'dlsym'
dd st_dlsym_name, 0, 0
dw 0x12, 0 ; --//--

; данные для DT_REL
; таблица релокаций. описывает, куда и как загружать адреса символов из таблицы символов
dt_rel:
dd rel_dlopen ; адрес, куда грузить
dd 0x0101 ; ELF32_R_INFO(1,R_386_32) : dt_symtab[1] ('dlopen'), тип = запиши адрес символа + r_addend(=0 у нас)
dd rel_dlsym ; --//--
dd 0x0201 ; ELF32_R_INFO(2,R_386_32) : dt_symtab[2] ('dlsym'), --//--
dt_rel_size equ $ - dt_rel

_start: ; поехали
 mov ebp, bss ; пускай ebp всё время указывает на bss -- будет удобно, поверьте!
; супер-удобные штуки, см далее
%define BSSADDR(a) ebp + ((a) - bss)
%define F(f) [ebp + ((f) - bss)]

; начнём загрузку функций
 mov esi, libs_to_dl+1 ; +1, т.к. ld_load ожидает, что мы уже вгрызлись на один символ в строку
 lea edi, [BSSADDR(libs_syms)] ; edi = адрес места, куда следует аккуратно сохранять адреса функций
ld_load:
 dec esi ; в этом месте мы уже вгрызлись в строку на 1, поэтому отступим назад
; подготовим параметры функции dlopen, они передаются через стек
 push 1 ; RTLD_LAZY
 push esi ; адрес имени библиотеки
 call F(rel_dlopen) ; eax = dlopen([esi], 1)
; обратите внимание, что здесь мы <s>не чистим после себя</s>засираем стек и РАДУЕМСЯ ЭТОМУ
 mov ebx, eax ; сохраним то, что dlopen нам вернул, в ebx

; скипаем все до 0
ld_skip_to_zero:
 lodsb
 test al, al
 jnz ld_skip_to_zero

; если следующий тоже \0 то конец текущей библиотеки
 lodsb
 test al, al
 jz ld_second_zero

; это еще не конец, куда собрался, это еще не конец!
 dec esi ; опять отматываемся на 1 назад
 push esi ; начало строки с названием функции
 push ebx ; возвращенный из dlopen указатель на загруженную библиотеку
 call F(rel_dlsym) ; eax = dlsym([ebx], [esi])
 stosd ; запишем eax (возвращенный указатель на функцию) в [edi], edi += 4
 jmp ld_skip_to_zero ; перемотаем до следуюшего нуля

ld_second_zero:
; если третий не ноль, то подгрузим что-нибудь еще!
 lodsb
 test al, al
 jnz ld_load

; здесь наша умопомрачительная интра!
 push 0x21 ; SDL_INIT_ TIMER | VIDEO
 call F(SDL_Init) ; SDL_Init(SDL_INIT_TIMER | SDL_INIT_VIDEO);

 push 2 | FULLSCREEN	; SDL_OPENGL
 push 32 ; 32 бита на пиксель
 push HEIGHT
 push WIDTH
 call F(SDL_SetVideoMode) ; SDL_SetVideoMode(WIDTH, HEIGHT, 32, SDL_OPENGL|FULLSCREEN);

; WxH уже есть в стеке! cdecl ftw!
 push 0
 push 0
 call F(glViewport) ; glViewport(0, 0, WIDTH, HEIGHT);
 call F(SDL_ShowCursor) ; SDL_ShowCursor(0);

; загрузка шейдеров
 call F(glCreateProgram) ; eax = glCreateProgram();
 mov edi, eax ; edi = program_id
 push 0x8b31
 pop esi ; esi = GL_VERTEX_SHADER
; здесь и далее используем 4 байта по адресу ebp как temp переменную -- там лежит ненужный нам более адрес dlopen, можно затирать
 mov dword [ebp], shader_vtx
 push esi
 call F(glCreateShader) ; eax = glCreateShader(GL_VERTEX_SHADER);
 mov ebx, eax
 push 0
 push ebp
 push 1
 push eax
 call F(glShaderSource) ; glShaderSource(shader_id, 1, &shader_vtx, 0);
 push ebx ; драйвера nVidia портят стек, поэтому нужно перезаливать аргументы
 call F(glCompileShader) ; glCompileShader(shader_id);
 push ebx ; опять поганая нвидия всё портит!
 push edi
 call F(glAttachShader) ; glAttachShader(program_id, shader_id);
 dec esi ; esi = GL_FRAGMENT_SHADER
 mov dword [ebp], shader_frg
; точная копия того, что вверху = хорошо жмётся!
 push esi
 call F(glCreateShader)
 mov ebx, eax
 push 0
 push ebp
 push 1
 push eax
 call F(glShaderSource)
 push ebx
 call F(glCompileShader)
 push ebx
 push edi
 call F(glAttachShader)
 push edi
 call  F(glLinkProgram) ; glLinkProgram(program_id);
 call  F(glUseProgram) ; glUseProgram(program_id);

mainloop:

 call F(SDL_GetTicks) ; eax == SDL_GetTicks(); -- время в миллисекундах
 push eax
 fninit ; нужно сбросить состояние FPU, потому что все вокруг норовят его испортить
 fild dword [esp] ; st(0) = eax == time в миллисекундах, st(1) = 4000
 push 4000
 fild dword [esp] ; st(0) = 4000
 fdiv ; st(0) /= 4000 = время в секундах/4
 fld1 ; st(0) = 1, st(1) = время в с
 faddp st1 ; st(0) = время в с + 1
 fstp dword [esp]
 pop eax ; eax = (float-ieee)t в секундах
 push eax
 push eax
 xor eax, 0x80000000 ; eax = -(float-ieee)t в секундах
 push eax
 push eax
 call F(glRectf) ; glRectf(-t,-t,t,t)
 times 5 pop eax ; здесь, к сожалению, приходится убирать за собой, т.к. мы крутимся в цикле и не можем гадить бесконечно

 call F(SDL_GL_SwapBuffers)

 lea edx, [BSSADDR(SDL_Event)] ; адрес памяти под структуру SDL_Event
 push edx
 call F(SDL_PollEvent) ; SDL_PollEvent(&SDL_Event);
 pop edx ; восстановим edx
 cmp byte [edx], 2 ; SDL_Event.type != SDL_KEYDOWN
 jnz mainloop

 call F(SDL_Quit) ; восстановим режим экрана и прочее
; вон из Новосибирска!
 xor eax, eax ; eax = 0
 inc eax ; ex = 1 (exit syscall)
 int 0x80 ; вызов syscall

; сгруппируем строки вмете -- ожидаем, что так они будут лучше паковаться
; стандартный линуксовый интерпретатор для динамической линковки
interp: db '/lib/ld-linux.so.2', 0
interp_size equ $ - interp

; данные для DT_STRTAB
; таблица строк. в ней лежит всё, необходимое для PT_DYNAMIC -- названия библиотек и имена функций
dt_strtab:
st_libdl_name equ $ - dt_strtab ; адрес строки относительно начала таблицы строк
db 'libdl.so.2', 0 ; все строки -- нуль-терминированные
st_dlopen_name equ $ - dt_strtab
db 'dlopen', 0
st_dlsym_name equ $ - dt_strtab
db 'dlsym', 0 
dt_strtab_size equ $ - dt_strtab

; имена библиотек и функций, которые нужно загрузить ручками
libs_to_dl:
st_libSDL_name equ $ - dt_strtab
db 'libSDL-1.2.so.0', 0 ; самое кросс-дистрибутивное название библиотеки, которое мне удалось выяснить эмпирически
db 'SDL_Init', 0
db 'SDL_SetVideoMode', 0
db 'SDL_PollEvent', 0
db 'SDL_GetTicks', 0
db 'SDL_ShowCursor', 0
db 'SDL_GL_SwapBuffers', 0
db 'SDL_Quit', 0
db 0 ; два нуля подряд = конец библиотеки
st_libGL_name equ $ - dt_strtab
db 'libGL.so.1', 0
db 'glViewport', 0
db 'glCreateShader', 0
db 'glShaderSource', 0
db 'glCompileShader', 0
db 'glCreateProgram', 0
db 'glAttachShader', 0
db 'glLinkProgram', 0
db 'glUseProgram', 0
db 'glRectf', 0
db 0, 0 ; три нуля подряд = конец загрузки

%include "shaders.inc"

file_size equ ($-$$) ; ну тут уже всё понятно должно быть

; BSS-секция, в ней лежат неинициализированные данные
absolute $
bss:

; резервируем место под адреса функций
libdl_syms:
rel_dlopen: resd 1
rel_dlsym: resd 1

libs_syms:
SDL_Init: resd 1
SDL_SetVideoMode: resd 1
SDL_PollEvent: resd 1
SDL_GetTicks: resd 1
SDL_ShowCursor: resd 1
SDL_GL_SwapBuffers: resd 1
SDL_Quit: resd 1
glViewport: resd 1
glCreateShader: resd 1
glShaderSource: resd 1
glCompileShader: resd 1
glCreateProgram: resd 1
glAttachShader: resd 1
glLinkProgram: resd 1
glUseProgram: resd 1
glRectf: resd 1

SDL_Event: resb 24

mem_size equ ($-$$)
