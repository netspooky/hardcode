ITxt	db 24h
	db 34h
        dw 132+80*320
        db "SiLenCe",0
	db 24h
	db 44h
        dw 54+60*320
        db "n0thINg HerE",0,0ffh

DemTxt	db 70				;Show cycle count 
	db 30				;Clear cycle count
	dw 132+320*2			;Offs in VidMem
	db "N0w u wAtchIng An QUAZAR BBS deM0",0
	db 70
	db 30
	dw 115+320*2
	db "dIz Da m0sT DanGer0Us PlaCE iN unIVerSE",0
	db 70
	db 30
	dw 120+320*2
	db "LeTS yA J0iN thE woRLd 0f forBidDeN",0,0ffh

;	db "http://people.weekend.ru/wZone"
;	db "(095) 7515001"
;	db "24h"
