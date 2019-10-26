void outp (int p,int v) {
	_asm {
	mov	edx,[p]
	mov	eax,[v]
	out	dx,al
	}
	}


void setgr() {
	int x;
	_asm {
		mov 	eax,13h
		int	10h
		}
	outp(0x3c8,0);
	for (x=0; x<256; x++) { 
			outp (0x3c9,x>>2); 
			outp (0x3c9,x>>2); 
			outp (0x3c9,x>>2); 
			}
	}

void text() {
	_asm {
		mov 	eax,3h
		int	10h
		}
	}


void wait() {
	_asm {
		xor	eax,eax
		int	16h
		}
}
