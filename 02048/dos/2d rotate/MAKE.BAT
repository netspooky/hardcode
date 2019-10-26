tasm BWPRINT
tasm ROTATE
tlink ROTATE+BWPRINT

@echo off
echo  Read this file (MAKE.BAT) for an explaination of it.
rem     'tasm BWPRINT'  creates BWPRINT.OBJ
rem     'tasm ROTATE'   creates ROTATE.OBJ
rem     'tlink ROTATE+BWPRINT'  links together ROTATE.OBJ and BWPRINT.OBJ
rem         note that the first OBJ file in the list is what the .EXE file
rem         will be called.  If more .OBJ files were linked, the order would
rem         not really matter.

