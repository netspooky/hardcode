bcn_sec 	 db sLine   ,0,0,87,255,87
		 db sLine   ,0,0,169,255,169
		 db sFill   ,9,6,0,80
		 db SFill   ,9,6,0,180

		 db sFill   ,1,6,0,144

		 db sElipse ,6,165,117,8,5
		 db sElipse ,6,165,117,16,12
		 db sRectangle,1,145,100,161,111
		 db sRectangle,1,140,100,155,140
		 db sLine   ,6,146,128,155,99
		 db sLine   ,6,155,97,163,97
		 db sLine   ,6,146,128,153,128
		 db sLine   ,6,160,105,163,98
		 db sLine   ,6,153,128,154,127
		 db sFill   ,6,1,150,127
 
		 db sElipse ,6,198,117,8,5
		 db sElipse ,6,198,117,15,12
		 db sRectangle ,1,205,115,215,120
		 db sLine   ,6,205,114,211,114
		 db sLine   ,6,205,120,211,120
		 db sFill   ,6,1,207,113

		 db sElipse ,6,238,119,15,14
		 db sRectangle ,1,219,109,255,134
		 db sElipse ,6,234,117,8,6
		 db sRectangle ,1,221,117,246,125
		 db sRectangle ,1,237,113,245,119
	         db sLine ,6,214,128,221,128
		 db sLine ,6,214,128,220,107
		 db sLine ,6,220,105,228,105
		 db sLine ,6,227,108,228,106
		 db sLine ,6,221,128,225,117
		 db sLine ,6,236,128,244,128
		 db sLine ,6,236,128,240,115
		 db sLine ,6,244,128,248,109
		 db sFill ,6,1,219,125

		 db sLine   ,8,0,145,255,145
		 db sLine   ,8,0,149,255,149
		 db sLine   ,8,0,167,255,167

		 db sEnd




;secuencias:
;00 - [end      ]
;01 - [line     ]  color_index x0 y0 x1 y1
;02 - [vline    ]  color_index y0 y1 x
;03 - [elipse   ]  color_index xc yc a  b  
;04 - [rectangle]  color_index x0 y0 x1 y1 
;05 - [fill     ]  color_index fondo_index x0 y0       
;>=06 - [ end]

