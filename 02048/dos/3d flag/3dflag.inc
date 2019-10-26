MAX_DEGS equ 512
SHIFT_CONST equ 12

TEXT_COLOR equ 100

FLAG_WIDTH equ 16
FLAG_HEIGHT equ 16
CELL_SIZE equ 32
COS_STEP equ 20
MAX_P equ FLAG_WIDTH*FLAG_HEIGHT
MAX_F equ ((FLAG_WIDTH-1)*(FLAG_HEIGHT-1))*2

TEMP1 equ FLAG_WIDTH*CELL_SIZE/2
TEMP2 equ FLAG_HEIGHT*CELL_SIZE/2

;------------------------------------------------------------

point3d struc
	x3d dd ?
	y3d dd ?
	z3d dd ?
ends

point2d struc
	x2d dw ?
	y2d dw ?
ends

face struc
	face_v1 dw ?
	face_v2 dw ?
	face_v3 dw ?
ends

matrix struc
	dd 9 dup(?)
ends