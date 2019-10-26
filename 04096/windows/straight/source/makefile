#   Make file for Turbo Assembler WAP32 example.
#   Copyright (c) 1996 by Borland International, Inc.

#       make -B                 Will build wap32.exe
#       make -B -DDEBUG         Will build the debug version of wap32.exe

NAME = win32
OBJS = $(NAME).obj texture.obj
DEF  = $(NAME).def

!if $d(DEBUG)
TASMDEBUG=/zi /m2
LINKDEBUG=/v
!else
TASMDEBUG=/zi /m2 /l
LINKDEBUG=/v
!endif

IMPORT=import32

$(NAME).EXE: $(OBJS) $(DEF)
  tlink32 /Tpe /aa /c $(LINKDEBUG) $(OBJS),$(NAME),, $(IMPORT) glut32.lib

.asm.obj:
   tasm32 $(TASMDEBUG) /ml $&.asm

clean:
   del *.obj
   del $(NAME).exe

texture.asm: texture.raw
  file2asm texture.raw texture

texture.obj: texture.asm
  tasm32 /ml texture.asm


