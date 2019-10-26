	; ---=== MainMusic ===---       
	song	dw	00000h, 081ADh,082ADh,083B0h
		dw	000E0h, 08330h              
		dw	00100h, 0812Dh,081A9h,0822Dh,082B0h,083B4h
                dw      001E0h, 08334h              
                dw      00200h, 08129h,081ABh,08230h,082AFh,083B2h
                dw      002E0h, 08332h              
                dw      00300h, 0812Bh,081A9h,0822Fh,082ADh,083B0h
                dw      003C0h, 08129h,081A8h       
                dw      00400h, 08128h,081ADh       
                dw      004C0h, 0822Dh              
                dw      004E0h, 082AFh,08330h       
                dw      00500h, 0812Dh,081A9h,0822Fh,082B0h,083B4h
                dw      005C0h, 082B2h
                dw      00600h, 08129h,081ABh,08232h,08230h,082AFh,08334h,083B2h    
                dw      006E0h, 08332h
                dw      00700h, 0812Bh,081ADh,083B4h
                dw      007DCh, 08334h
                dw      007E0h, 083B4h  
                dw      007ECh, 08334h
                dw      007F0h, 083B2h                   
                dw      007FCh, 08332h              
                dw      00800h, 0822Fh,082ADh,083B4h
                dw      00900h, 08334h
                dw      00A00h, 0812Dh,081A1h
                dw      00BC0h, 089B0h,084C5h
          	dw	00BC8h, 08445h
                dw	00BE0h, 089ADh,084C8h      
        	dw	00BE8h, 08448h             
        l1      dw      00C00h, 089B9h,08121h,08132h,0822Dh,081ADh,08451h,0844Fh,0844Ah,084CCh,084C5h,084C8h
;                dw      00C60h, 0844Ch,084CFh    v(F)
                dw      00C80h, 0812Dh,081AFh,0844Ch,08445h,08448h,084CEh,084CBh,084C7h
;                dw      00CE0h, 0844Bh,084CCh           v(C)
                dw      00D00h, 0812Fh,081B0h,0844Eh,0844Bh,08447h,084CFh,084C8h,084CCh
                dw      00D80h, 08130h,081B2h,0844Fh,08448h,0844Ch,084D1h,084CEh,084CAh
                dw      00DE0h, 0844Eh,084CFh      
                ;	00E=00C..00F=00D           
        l2      dw      01000h, 08132h,081ADh,085B9h,089B9h,08451h,0844Fh,0844Ah,084CCh,084C5h,084C8h,08456h,0844Eh
                dw      0100Ch, 08539h                     
                dw      01030h, 085C0h                     
                dw      0103Ch, 08540h                     
                dw      01060h, 086BFh;,0844Ch,084CFh
                dw      01080h, 0812Dh,081AFh,0844Ch,08445h,08448h,084CEh,084CBh,084C7h
                dw      010C8h, 0863Fh,085BFh   ; ^(F)
                dw      010D0h, 0853Fh,085C0h              
                dw      010D8h, 08540h,085BFh              
                dw      010E0h, 0853Fh,085C0h,0844Bh,084CCh
                dw      010F0h, 08540h,085C2h              
                dw      01100h, 0812Fh,081B0h,08542h,085BCh,0844Eh,0844Ch,08447h,084CFh,084C8h,084CCh
                dw      0110Ch, 0853Ch                     
                dw      01130h, 085C3h                     
                dw      0113Ch, 08543h                     
                dw      01160h, 085C2h                                   
                dw      01180h, 08130h,081B2h,08542h,086BEh,0844Fh,08448h,0844Ch,084D1h,084CEh,084CAh
                dw      011C0h, 0863Eh,085C0h
                dw      011E0h, 0844Eh,084CFh    
                dw      01200h, 08132h,081ADh,08540h,086C0h,08451h,0844Fh,0844Ah,084CCh,084D3h,084D8h
                dw      01280h, 0812Dh,081AFh,0844Ch,08453h,08458h,084D6h,084D1h,084CCh
                dw      012C0h, 08640h
                dw      012E0h, 08451h,084CFh        
                dw      012F0h, 0844Fh,084CEh
                dw      01300h, 0812Fh,081B0h,08456h,0844Eh,0844Ch,084D4h,084D1h,084CCh
                dw      01380h, 08130h,081B2h,08454h,08451h,0844Ch,084D6h,084D1h,084CEh
                dw    	013C0h, 089B9h                                                 
                dw      013E0h, 089B1h,08451h,084CFh
                ;	014=010..017=013
        l3      dw      01800h, 08132h,0844Fh,08456h,0844Eh,081ADh,082ADh,089B9h
                dw      01A00h, 0812Dh,081B3h,0822Dh,082A7h
                dw      01C00h, 08133h,081ADh,08227h,082ADh,089B9h
                dw      01E00h, 0812Dh,081B3h,0822Dh,082A7h
                dw      02000h, 08133h,081ADh,08227h,082ADh,089B9h
                dw      020C0h, 0812Dh,081ABh        
                dw      020E0h, 0812Bh,081AEh,089B9h 
                dw      02100h, 0812Eh,081ADh,089B9h 
                dw      021C0h, 0812Dh,081ABh        
                dw      021E0h, 0812Bh,081AEh,089B9h 
                dw      02200h, 0812Eh,081B0h,0822Dh,082B0h
                dw      022C0h, 08130h,081AEh
                dw      022E0h, 0812Eh,081B1h
                dw      02300h, 08131h,081B0h
                dw      023C0h, 08130h,081AEh
                dw      02400h, 0812Eh,081ADh,08230h,082ADh,089B9h
                dw      024C0h, 0812Dh,081ABh             
                dw      024E0h, 0812Bh,081AEh,089B9h      
                dw      02500h, 0812Eh,081ADh,089B9h      
                dw      025C0h, 0812Dh,081ABh,089B9h
                dw      025E0h, 0812Bh,081ADh,089B1h
                dw      02600h, 089B9h,083B4h,089A6h
                dw      02700h, 08334h       
                dw      02800h, 0812Dh,081A1h,089A4h,089AAh
                dw      02830h, 089A4h,089AAh             
                dw      02860h, 089A4h,089AAh             
                dw      02890h, 089A4h,089AAh             
                dw      028B0h, 089AAh                    
                dw      028B8h, 089AAh                    
                dw      028C0h, 089A4h,089AEh             
                dw      028D0h, 089A4h,089AEh      
                dw      028E0h, 089A4h,089AEh      
                dw      02900h, 089A6h,08121h,081ADh,080ADh
                dw      0290Ch, 0812Dh,0822Dh,0802Dh
        	dw     	0             
                                                  
                                      
 	; ---=== repeaters ===---     
 	; format: 8 bit synchronizer, 1 bit NoteOn/Off, 7 bit NoteValue 		
	                              
 	; rythm at beginning          
	ch0rep1	db	000h,10101101b
	   	db	00Ch,00101101b
 		db	030h,10101101b
		db	03Ch,00101101b           
 		db	060h,10101101b                   
		db	06Ch,00101101b                   
		db	090h,10101101b                   
		db 	09Ch,00101101b                   
		db   	0C0h,10101101b                   
		db	0CCh,00101101b                   
 		db	0D0h,10101101b                   
		db	0DCh,00101101b                   
 		db	0E0h,10101101b                   
		db 	0ECh,00101101b
		                      
	; tekkno parts                
	tek1	db	000h,10111001b
		db	008h,00111001b
		db	010h,10111001b
		db	018h,00111001b
		db	020h,10111001b
		db	028h,00111001b
		db	030h,10111001b
		db	038h,00111001b
		db	040h,10111100b           
		db	04Fh,00111100b
		db	050h,10111001b
		db	058h,00111001b
		db	060h,10111001b
		db	068h,00111001b
		db	070h,10111001b
		db	078h,00111001b
		db	080h,10111110b
		db	08Fh,00111110b
		db	090h,10111001b
		db	098h,00111001b
		db	0A0h,10111001b
		db	0A8h,00111001b
		db	0B0h,10111111b
		db	0BFh,00111111b
		db	0C0h,10111001b
		db	0C8h,00111001b
		db	0D0h,10111111b
		db	0DFh,00111111b
		db	0E0h,10111110b
		db	0E8h,00111110b           
		db	0F0h,10111100b
		db	0F8h,00111100b
	
;	tek2	db	000h,11000101b
; 		db	010h,01000101b
; 		db	020h,11001100b
; 		db	030h,01001100b
; 		db	040h,11010001b
; 		db	050h,01010001b
; 		db	060h,11000101b
; 		db	070h,01000101b
; 		db	080h,11001010b
; 		db	090h,01001010b
; 		db	0A0h,11000101b
; 		db	0A8h,01000101b
; 		db	0B0h,11001011b
; 		db	0C8h,01001011b
; 		db	0D0h,11001000b
; 		db	0D8h,01001000b
; 		db	0E0h,11001010b
; 		db	0E8h,01001010b
; 		db	0F0h,11001000b
; 		db	0F8h,01001000b
 	
	tek3	db	000h,11000101b
		db	00Ch,01000101b
		db	020h,11000000b
		db	02Ch,01000000b
		db	030h,11000011b
		db	03Ch,01000011b
		db	050h,11000000b
		db	05Ch,01000000b
		db	070h,11000110b
		db	07Ch,01000110b
		db	090h,11000000b
		db	09Ch,01000000b
		db	0B0h,11000101b
		db	0CFh,01000101b
		db	0D0h,11000000b
		db	0DFh,01000000b
		db	0E0h,11000011b
		db	0EFh,01000011b
		db	0F0h,11000110b
		db	0FFh,01000110b
	                                                 
	; beat data: first drums, then hihat (2 columns in a tracker) 	
	drums1	db	000h,10100100b
	      	db	040h,10100110b
		db	070h,10100100b                   
		db	090h,10100100b                   
		db	0A0h,10100100b                   
		db	0C0h,10100110b                   
	      	db	0E0h,10100110b                   
	hihat1	db	000h,10101010b
		db	010h,10101010b                   
		db	020h,10101110b
		db	030h,10101010b                   
		db 	040h,10101110b                   
		db	050h,10101010b                   
		db	060h,10101010b                   
		db	070h,10101010b                   
		db 	080h,10101010b                   
		db	090h,10101010b                   
		db	0A0h,10101010b                   
		db	0B0h,10101110b                   
		db	0C0h,10101010b                   
		db	0D0h,10101010b                   
		db	0E0h,10101010b                   
		db	0F0h,10101010b
		                      
	drums2	db	000h,10100100b
		db	040h,10100110b
		db	070h,10100100b
		db	0A0h,10100100b
		db	0C0h,10100110b
	hihat2	db	000h,10101010b
		db	008h,10101010b
		db	010h,10101110b
		db	018h,10101010b
		db	020h,10101010b
		db	028h,10101010b
		db	030h,10101110b                 
		db	038h,10101010b
		db	040h,10101010b           
		db	048h,10101010b
		db	050h,10101110b
		db	058h,10101010b
		db	060h,10101010b
		db	068h,10101010b
		db	070h,10101110b
		db	078h,10101010b
		db	080h,10101010b
		db	088h,10101010b
		db	090h,10101110b
		db	098h,10101010b
		db	0A0h,10101010b
		db	0A8h,10101010b
		db	0B0h,10101110b
		db	0B8h,10101010b
		db	0C0h,10101010b
		db	0C8h,10101010b
		db	0D0h,10101110b                 
		db	0D8h,10101010b
		db	0E0h,10101010b
		db	0E8h,10101010b           
		db	0F0h,10101110b
		db	0F8h,10101010b