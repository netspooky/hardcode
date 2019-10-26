@REM call bgiobj techno.hsc music.obj Music Music_Segment Data
@call binobj Slow1.hsc music.obj Music Music_Segment Data
@call tasm faugh.asm /m2
@REM call tlink music.obj faugh.obj /m /s
@call tlink faugh.obj /m /s
