tasm  BWPRINT
tasm  3DROTATE
tlink 3DROTATE+BWPRINT

@echo off
echo  Read this file (MAKE.BAT) for an explaination of it.
rem     'tasm BWPRINT'  creates   BWPRINT.OBJ
rem     'tasm 3dROTATE' creates   ROTATE.OBJ
rem     'tlink 3dROTATE+BWPRINT'  links together ROTATE.OBJ and BWPRINT.OBJ
rem         note that the first OBJ file in the list is what the .EXE file
rem         will be called.  If more .OBJ files were linked, the order would
rem         not really matter.

