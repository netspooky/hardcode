cartman_body_sec db sElipse ,85,214,40,5
		 db sFill   ,0,85,214
		 db sElipse ,167,215,48,4
		 db SFill   ,0,167,215

		 db sElipse ,108,127,116,80
		 db sElipse ,162,120,119,82

		 db sRectangle,0,0,255,194
		 db sRectangle,100,192,173,202

		 db sLine   ,34,174,38,190
		 db sLine   ,38,192,44,194
		 db sLine   ,215,193,218,171

 		 db sLine   ,44,195,50,212
		 db sLine   ,198,211,206,197

		 db SFill   ,7,171,206

		 db sElipse ,125,190,109,88
		 db sRectangle,0,0,255,123
		 db sRectangle,0,149,29,255
		 db sRectangle,218,144,255,255
		 db sRectangle,0,225,255,255

		 db sElipse ,126,100,76,60
		 db sElipse ,40,161,20,14
		 db sRectangle,32,146,69,166
		 db sElipse ,42,164,18,11
		 db sRectangle,24,153,50,168
		 db sLine   ,32,149,50,155
 		 db SFill   ,8,41,164

		 db sElipse ,209,163,18,6
		 db sRectangle,200,157,230,170
		 db sElipse ,212,158,14,17
		 db sRectangle,198,160,201,168
		 db sFill    ,8,212,156

		 db sFill    ,9,130,180

		 db sVLine   ,160,205,125
		 db sVline   ,200,201,120   ;Plot (120,200)!!!!!!
		 db sEnd


cartman_head_sec db sElipse    ,125,86,78,69
		 db sRectangle ,0,0,255,131
		 db sElipse    ,137,142,115,69
		 db sElipse    ,136,147,115,69

		 db sElipse    ,126,100,76,60
		 db sElipse    ,126,100,77,61

		 db sRectangle ,0,0,49,200
		 db sRectangle ,204,0,255,200
		 db sRectangle ,0,170,255,230

		 db sElipse    ,112,102,16,20
		 db sElipse    ,149,101,17,19
                 db sFill      ,13,118,98
                 db sFill      ,13,141,99
		 db sElipse    ,118,98,2,2
		 db sElipse    ,141,99,2,2

		 db sLine      ,116,147,139,149
		 db sLine      ,124,142,141,144

		 db sFill      	,10,119,59
		 db sFill	,8,130,75
		 db SFill	,11,130,127

		 db sEnd
			

;secuencias:
;00 - [end      ]
;01 - [line     ]  color_index x0 y0 x1 y1
;02 - [vline    ]  color_index y0 y1 x
;03 - [elipse   ]  color_index xc yc a  b  
;04 - [rectangle]  color_index x0 y0 x1 y1 
;05 - [fill     ]  color_index fondo_index x0 y0       
;>=06 - [ end]

