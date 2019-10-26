'*****************************************************************************
'*                                                                           *
'* Program to write out the tables needed for wobbler.asm                    *
'* By TH/20/3/96                                                             *
'*                                                                           *
'*****************************************************************************

PRINT "Writing out variables"
DIM n AS INTEGER
deg2rad = 3.141592654# / 180
HTable = FREEFILE
OPEN "HTable.inc" FOR OUTPUT AS HTable
PRINT "Writing htable..."
PRINT #HTable, "HTable LABEL WORD"
FOR n = 0 TO 199
        PRINT #HTable, "DW", INT(SIN(n * (360 / 200) * deg2rad * 2) * 10)
NEXT
PRINT #HTable, "DW", "?"
CLOSE HTable

VTable = FREEFILE
OPEN "VTable.inc" FOR OUTPUT AS VTable
PRINT "Writing vtable..."
PRINT #VTable, "VTable LABEL WORD"
FOR n = 0 TO 319
        PRINT #VTable, "DW", INT(COS(n * (360 / 320) * deg2rad * 2) * 10)
NEXT
PRINT #VTable, "DW", "?"
CLOSE #VTable


PRINT "All done"

