bits       32
section    .data

global    _pal
global    _back
global    _barol
global    _baror
global    _barro
global    _barru
global    _barul
global    _barur
global    _cursor
global    _topaz8
global    _top8bm
global    _diamo12
global    _dia12bm
global    _text1
global    _credz

_pal:     incbin "data\work.pal"
          times 192 db 0
_back:    incbin "data\back.rle"
_barol:   incbin "data\barol.spr"
_baror:   incbin "data\baror.spr"
_barro:   incbin "data\barro.spr"
_barru:   incbin "data\barru.spr"
_barul:   incbin "data\barul.spr"
_barur:   incbin "data\barur.spr"
_cursor:  incbin "data\cursor.spr"

_topaz8:  dd .bitmap
          incbin "data\topaz_08.fnt",4
.bitmap:  incbin "data\topaz_08.bit"

_diamo12: dd .bitmap
          incbin "data\diamo_20.fnt",4
.bitmap:  incbin "data\diamo_20.bit"

_text1:   incbin "data\general.dat"
_credz:   incbin "data\credits.dat"
