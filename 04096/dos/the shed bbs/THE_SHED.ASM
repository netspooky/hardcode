; ===========================================================================
;                             BBS Advert #1
;                             -------------
; This is the 3rd 80x86 assembler program I have written (the first two wrote
; 'Hello' on the screen), so if you think its crap, remember what YOUR 3rd
; assembler program was like :)
; Please feel free to modify it, but don't just stick your own text in it, as
; that is a very lame thing to do (though why you would WANT to put your name
; in this lame old thing is beyond me).  Also, if you are going to spread it
; around (please do!), spread it in its original form.
;
; I do not take any responsibility for damage caused to hardware or software
; as a result of you using this program.  You use it at your own risk.  Mind
; you, saying that, I can't really see any situation where using it would do
; any damage, but if something nasty does happen, don't get a smart lawyer
; and sue me for millions because I am actually quite poor.
;
; Naich. (dws@ras.phy.cam.ac.uk) 7-1-94
; ===========================================================================

.MODEL SMALL

SCREEN		EQU 0B800h
SLIDENO		EQU 150
TEXT_WAIT	EQU 225

.DATA

Xpos		DB 158			; Start positions for lines in Slide
		DB 24 dup (160)
Count		DW ?			; General purpose
Count1		DW ?			; General purpose
Flashc		DB 127, 15, 7, 8
From		DW 2243, 2403, 2563, 2723, 2883, 3043, 3203, 3363
Savescr		DW 2000 dup (?)		; Storage for screen
Byte1		DB ?
Byte2		DB ?			; Places to hold random numbers
Byte3		DB ?
Rndpos		DW 0			; Random number list position
Mappos		DB 15
Dashpos		DW 0
Strippos	DB 80

Message		DB " "
		DB "Why not try out The Shed - Cambridge's hottest BBS! "
		DB "Log on for the best software, and news of the latest PC hardware "
		DB "All software is tested for quality - No garbage allowed! "
		DB "The latest demos, programming, utilities, graphics, games... "
		DB "The best of the best squeezed into 150 Megs for you to download FREE! "
		DB "Why pay for Gigabytes of garbage when The Shed has all the good stuff? "
		DB "The Shed has chat areas, E-Mail and a library for you to browse through "
		DB "We also sell computers, so why not log on and check out our prices? "
		DB "The Shed is open from 6pm WET and all day Sunday "

Crapdisplay	DB "Sorry, but your mono display is too crap for this program!", 0Dh, 0Ah, 0Dh, 0Ah
		DB "Why not check out the prices at Cavendish Computers Cambridge and get a colour", 0Dh, 0Ah
		DB "one?  Phone (0223) 247620 NOW!!!  Come on Grandad, get a better computer."
		DB 0Dh, 0Ah, "$"

Wordpos		DB 40, 15, 8, 12, 10, 6, 5, 5, 7, 16
Wordlength	DB 1, 52, 65, 57, 61, 70, 71, 72, 68, 49
Linepos		DW 0		; Pointer to position in memory
Linenumnow	DB 0		; No of chars printed
Lineposnow	DB 80		; Position of first char printed
Textwait	DB TEXT_WAIT
Textpos		DB 80		; Scroll counter
Textflag	DB 1
Textline	DB 0		; Text line number

; ---------------------------------------------------------------------------
; Data for Shed logo
; ---------------------------------------------------------------------------
Screendata LABEL WORD
 DW  3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360
 DW  3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360
 DW  3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360
 DW  3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360
 DW  3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360
 DW  3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360
 DW  3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360
 DW  3360, 3360, 3360, 3360, 3872, 3886, 3872, 4041, 4045, 4045, 4043
 DW  4045, 4045, 4027, 3872, 4043, 3872, 3872, 4043, 3872, 4043, 4045
 DW  4045, 4027, 3872, 3872, 3872, 3872, 3872, 3886, 4041, 4045, 4045
 DW  4045, 4045, 4024, 3872, 4036, 4050, 4036, 3872, 3872, 4036, 4050
 DW  4036, 3886, 4041, 4045, 4045, 4045, 4045, 4024, 3872, 4041, 4045
 DW  4045, 4045, 4027, 3886, 3872, 3872, 3872, 3872, 3872, 3872, 4043
 DW  4045, 4027, 3886, 3872, 4043, 4045, 4027, 3872, 3886, 4041, 4045
 DW  4045, 4027, 3872, 3872, 3872, 3360, 3360, 3872, 3872, 3872, 3872
 DW  3872, 3872, 4026, 3872, 3886, 3872, 3872, 4044, 4045, 4045, 4025
 DW  3872, 4044, 4045, 3872, 3872, 3872, 3882, 3872, 3872, 3872, 3872
 DW  4026, 3872, 3886, 3872, 3872, 3872, 3872, 3886, 4026, 3882, 3872
 DW  3872, 3872, 4026, 3872, 3872, 4026, 3872, 3886, 3872, 3872, 3872
 DW  3872, 4026, 3882, 3872, 3872, 4040, 4027, 3872, 3872, 3872, 3886
 DW  3872, 3872, 4044, 4045, 4042, 4027, 3872, 4044, 4045, 4042, 4027
 DW  3872, 4040, 4045, 4045, 4027, 3886, 3872, 3872, 3360, 3360, 3872
 DW  3872, 3886, 3872, 3882, 3872, 4026, 3872, 3872, 3872, 3872, 4026
 DW  3872, 3886, 4026, 3872, 4026, 3872, 3886, 3872, 3872, 3872, 3872
 DW  3872, 3872, 3872, 4040, 4045, 4045, 4045, 4045, 4027, 3886, 3872
 DW  4044, 4045, 4045, 4045, 4045, 4025, 3872, 3886, 4044, 4045, 4045
 DW  4045, 4021, 3872, 3872, 4026, 3872, 3872, 3872, 3872, 4026, 3872
 DW  3886, 3872, 3872, 3872, 3872, 4026, 3872, 3886, 4026, 3872, 4026
 DW  3886, 3872, 4026, 3872, 4026, 3872, 3872, 4026, 3872, 3872, 3872
 DW  3360, 3360, 3872, 3872, 3872, 3872, 3872, 3872, 4042, 3872, 3872
 DW  3886, 3872, 4042, 3872, 3872, 4042, 3872, 4042, 4045, 4045, 4028
 DW  3872, 3872, 3872, 3872, 3886, 3872, 3872, 3872, 3872, 3872, 3882
 DW  4026, 3872, 3872, 4026, 3872, 3886, 3872, 3872, 4026, 3872, 3872
 DW  4026, 3872, 3872, 3872, 3886, 3872, 3872, 4026, 3872, 3872, 3886
 DW  4041, 4028, 3872, 3872, 3872, 3872, 3882, 3872, 4042, 4045, 4045
 DW  4028, 3872, 4042, 4045, 4045, 4028, 3886, 4040, 4045, 4045, 4028
 DW  3872, 3882, 3872, 3360, 3360, 2737, 2737, 2737, 2592, 2603, 2612
 DW  2612, 2592, 2600, 2608, 2601, 2610, 2610, 2611, 2592, 2613, 2614
 DW  2611, 2612, 2614, 2616, 2592, 2737, 2737, 2737, 3872, 4052, 4045
 DW  4045, 4045, 4045, 4028, 3872, 4036, 4048, 4036, 3872, 3872, 4036
 DW  4048, 4036, 3872, 4040, 4045, 4045, 4045, 4045, 4030, 3872, 4040
 DW  4045, 4045, 4045, 4028, 3872, 2737, 2737, 2592, 2603, 2612, 2612
 DW  2592, 2600, 2608, 2601, 2610, 2610, 2611, 2592, 2613, 2614, 2611
 DW  2612, 2614, 2616, 2592, 2737, 2737, 3360, 3360, 3360, 3360, 3360
 DW  3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360
 DW  3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360
 DW  3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360
 DW  3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360
 DW  3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360
 DW  3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360
 DW  3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360
 DW  3872, 3370, 3360, 3377, 3378, 3376, 3376, 3360, 3373, 3360, 3377
 DW  3380, 3372, 3380, 3376, 3376, 3360, 3394, 3408, 3411, 3360, 3360
 DW  3360, 3360, 3360, 3360, 3360, 3360, 3411, 3449, 3443, 3439, 3440
 DW  3443, 3360, 3386, 3360, 3406, 3425, 3433, 3427, 3432, 3872, 3360
 DW  3360, 3360, 3360, 3360, 3360, 3360, 3395, 3425, 3436, 3436, 3360
 DW  3438, 3439, 3447, 3360, 3430, 3439, 3442, 3360, 3428, 3429, 3437
 DW  3439, 3443, 3372, 3360, 3431, 3425, 3437, 3429, 3443, 3372, 2592
 DW  2592, 3360, 3360, 3872, 3370, 3360, 3377, 3381, 3376, 3360, 3405
 DW  3429, 3431, 3443, 3360, 3407, 3438, 3373, 3436, 3433, 3438, 3429
 DW  3872, 3872, 3872, 3872, 3872, 3872, 3104, 3104, 3104, 3104, 3104
 DW  3360, 3360, 3360, 3360, 3360, 3360, 3360, 3395, 3432, 3429, 3450
 DW  3438, 3429, 3449, 3360, 3360, 3360, 3360, 3360, 3360, 3445, 3444
 DW  3433, 3436, 3443, 3372, 3360, 3440, 3442, 3439, 3431, 3442, 3425
 DW  3437, 3437, 3433, 3438, 3431, 3372, 3360, 3427, 3432, 3425, 3444
 DW  3360, 3360, 3360, 3360, 3360, 3360, 3872, 3370, 3360, 3407, 3446
 DW  3429, 3442, 3360, 3377, 3360, 3399, 3433, 3431, 3360, 3433, 3438
 DW  3360, 3443, 3444, 3439, 3427, 3435, 3872, 3872, 3872, 3872, 3872
 DW  3872, 3872, 3872, 3872, 3872, 3872, 3360, 3360, 3360, 3360, 3360
 DW  3360, 3360, 3360, 3360, 2592, 2592, 2592, 2592, 2592, 2592, 2592
 DW  2592, 3425, 3442, 3429, 3425, 3443, 3360, 3425, 3438, 3428, 3360
 DW  3428, 3429, 3444, 3425, 3433, 3436, 3443, 3360, 3439, 3430, 3360
 DW  3444, 3432, 3429, 2592, 2592, 2592, 2592, 3360, 3360, 3872, 3370
 DW  3360, 3401, 3437, 3437, 3429, 3428, 3433, 3425, 3444, 3429, 3360
 DW  3430, 3442, 3429, 3429, 3360, 3428, 3439, 3447, 3438, 3436, 3439
 DW  3425, 3428, 2592, 2592, 2592, 2592, 2592, 2592, 2592, 2592, 2592
 DW  2592, 2592, 2592, 2592, 2592, 2592, 2592, 2592, 2592, 2592, 2592
 DW  2592, 2592, 2592, 2592, 3436, 3425, 3444, 3429, 3443, 3444, 3360
 DW  3427, 3439, 3437, 3440, 3445, 3444, 3429, 3442, 3360, 3432, 3425
 DW  3442, 3428, 3447, 3425, 3442, 3429, 3374, 2592, 2592, 2592, 3360
 DW  3360, 3872, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848
 DW  2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848
 DW  2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848
 DW  2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848
 DW  2848, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872
 DW  3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872
 DW  3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872
 DW  3872, 3872, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360
 DW  3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360
 DW  3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360
 DW  3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360
 DW  3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360
 DW  3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360
 DW  3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360
 DW  3360, 3360, 3360, 3360, 3360, 3360, 3360, 3872, 3872, 3872, 3872
 DW  3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872
 DW  3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872
 DW  3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872
 DW  3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872
 DW  3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872
 DW  3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872
 DW  3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3360, 3360, 3761
 DW  3760, 3761, 3762, 3761, 3760, 3761, 3762, 3761, 3760, 3761, 3762
 DW  3761, 3760, 3761, 3762, 3761, 3760, 3761, 3762, 3761, 3760, 3761
 DW  3762, 3761, 3760, 3761, 3762, 3761, 3760, 3761, 3762, 3761, 3760
 DW  3761, 3762, 3761, 3760, 3761, 3762, 3761, 3760, 3761, 3762, 3761
 DW  3760, 3761, 3762, 3761, 3760, 3761, 3762, 3761, 3760, 3761, 3762
 DW  3761, 3760, 3760, 3762, 3761, 3760, 3761, 3762, 3761, 3760, 3761
 DW  3762, 3761, 3760, 3761, 3762, 3761, 3760, 3761, 3762, 3761, 3760
 DW  3360, 3360, 3762, 3761, 4016, 4017, 4018, 4017, 4016, 4017, 4018
 DW  4017, 4016, 4017, 4018, 4017, 4016, 4017, 4018, 4017, 4016, 4017
 DW  4018, 4017, 4016, 4017, 4018, 4017, 4016, 4017, 4018, 4017, 4016
 DW  4017, 4018, 4017, 4016, 4017, 4018, 4017, 4016, 4017, 4018, 4017
 DW  4016, 4017, 4018, 4017, 4016, 4017, 4018, 4017, 4016, 4017, 4018
 DW  4017, 4016, 4017, 4018, 4017, 4016, 4017, 4018, 4017, 4016, 4017
 DW  4018, 4017, 4016, 4017, 4018, 4017, 4016, 4017, 4018, 4017, 4016
 DW  4017, 3762, 3761, 3360, 3360, 3760, 3762, 4018, 3872, 3872, 3872
 DW  3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872
 DW  3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872
 DW  3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872
 DW  3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872
 DW  3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872
 DW  3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872
 DW  3872, 3872, 3872, 4017, 3760, 3761, 3360, 3360, 3761, 3760, 4017
 DW  3872, 3872, 3616, 3616, 3616, 3616, 3616, 3616, 3616, 3616, 3616
 DW  3616, 3616, 3616, 3616, 3616, 3616, 3616, 3616, 3616, 3668, 3656
 DW  3653, 3616, 3667, 3656, 3653, 3652, 3616, 3650, 3650, 3667, 3616
 DW  3629, 3629, 3616, 3667, 3661, 3649, 3660, 3660, 3616, 3650, 3669
 DW  3668, 3616, 3658, 3669, 3657, 3651, 3673, 3617, 3617, 3872, 3872
 DW  3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872
 DW  3872, 3872, 3872, 3872, 3872, 3872, 4018, 3761, 3760, 3360, 3360
 DW  3762, 3761, 4016, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872
 DW  3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872
 DW  3872, 3629, 3629, 3629, 3629, 3629, 3629, 3629, 3629, 3629, 3629
 DW  3629, 3629, 3629, 3629, 3629, 3629, 3629, 3629, 3629, 3629, 3629
 DW  3629, 3629, 3629, 3629, 3629, 3629, 3629, 3629, 3629, 3629, 3629
 DW  3629, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872
 DW  3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 4017, 3762
 DW  3761, 3360, 3360, 3760, 3761, 4018, 3872, 3872, 3872, 3872, 3872
 DW  3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872
 DW  3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872
 DW  3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872
 DW  3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872
 DW  3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872
 DW  3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872, 3872
 DW  3872, 4017, 3760, 3762, 3360, 3360, 3761, 3760, 4017, 4018, 4017
 DW  4016, 4017, 4018, 4017, 4016, 4017, 4018, 4017, 4016, 4017, 4018
 DW  4017, 4016, 4017, 4018, 4017, 4016, 4017, 4018, 4017, 4016, 4017
 DW  4018, 4017, 4016, 4017, 4018, 4017, 4016, 4017, 4018, 4017, 4016
 DW  4017, 4018, 4017, 4016, 4017, 4018, 4017, 4016, 4017, 4018, 4017
 DW  4016, 4017, 4018, 4017, 4016, 4017, 4018, 4017, 4016, 4017, 4018
 DW  4017, 4016, 4017, 4018, 4017, 4016, 4017, 4018, 4017, 4016, 4017
 DW  4018, 4017, 4016, 4017, 4018, 3761, 3760, 3360, 3360, 3762, 3761
 DW  3760, 3761, 3762, 3761, 3760, 3761, 3762, 3761, 3760, 3761, 3762
 DW  3761, 3760, 3761, 3762, 3761, 3760, 3761, 3762, 3761, 3760, 3761
 DW  3762, 3761, 3760, 3761, 3762, 3761, 3760, 3761, 3762, 3761, 3760
 DW  3761, 3762, 3761, 3760, 3761, 3762, 3761, 3760, 3761, 3762, 3761
 DW  3760, 3761, 3762, 3761, 3760, 3761, 3762, 3761, 3760, 3761, 3762
 DW  3761, 3760, 3761, 3762, 3761, 3760, 3761, 3762, 3761, 3760, 3761
 DW  3762, 3761, 3760, 3761, 3762, 3761, 3760, 3761, 3762, 3761, 3360
 DW  3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360
 DW  3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360
 DW  3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360
 DW  3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360
 DW  3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360
 DW  3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360
 DW  3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360, 3360
 DW  3360, 3360, 3360, 800, 800, 2848, 2848, 2848, 2848, 2848, 2848
 DW  2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848
 DW  2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848
 DW  2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848
 DW  2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848
 DW  2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848
 DW  2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848
 DW  2848, 2848, 2848, 2848, 800, 800, 800, 800, 2848, 2848, 2848
 DW  2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848
 DW  2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848
 DW  2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848
 DW  2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848
 DW  2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848
 DW  2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848, 2848
 DW  2848, 2848, 2848, 2848, 2848, 2848, 2848, 800, 800

; ---------------------------------------------------------------------------
; Data for random numbers.  OK, so its not particularly elegant, but it has
; to be faster than generating them real time.
; ---------------------------------------------------------------------------

Rand1 LABEL BYTE
 DB  128, 0, 2, 128, 8, 0, 0, 16, 0, 2, 0, 8, 0, 2, 0, 0, 16, 32
 DB  0, 148, 0, 12, 0, 160, 16, 132, 2, 0, 0, 0, 40, 0, 68, 0, 0
 DB  2, 0, 1, 2, 0, 8, 176, 1, 8, 2, 65, 0, 164, 32, 128, 0, 0, 1
 DB  0, 0, 4, 144, 16, 0, 0, 129, 1, 0, 72, 32, 18, 128, 0, 0, 0
 DB  2, 80, 0, 64, 8, 66, 0, 32, 32, 4, 0, 4, 16, 68, 0, 1, 2, 4
 DB  0, 0, 64, 0, 64, 0, 4, 32, 2, 0, 128, 0, 0, 0, 0, 0, 9, 0, 16
 DB  4, 3, 0, 0, 0, 192, 0, 0, 0, 16, 16, 0, 4, 0, 16, 0, 0, 16, 0
 DB  93, 0, 192, 136, 0, 0, 16, 0, 2, 0, 0, 128, 0, 0, 0, 0, 0, 66
 DB  8, 4, 0, 128, 33, 2, 0, 0, 0, 0, 8, 128, 128, 128, 8, 64, 0
 DB  0, 0, 16, 0, 32, 0, 0, 0, 4, 64, 0, 0, 4, 32, 16, 0, 8, 0, 0
 DB  0, 64, 2, 0, 64, 0, 19, 80, 34, 0, 0, 0, 80, 1, 128, 0, 2, 33
 DB  1, 0, 1, 8, 0, 128, 128, 0, 16, 16, 0, 2, 26, 0, 0, 0, 16, 9
 DB  0, 0, 68, 0, 0, 0, 0, 0, 16, 4, 4, 0, 0, 64, 0, 1, 16, 8, 34
 DB  0, 0, 64, 4, 0, 0, 0, 0, 1, 16, 33, 0, 0, 2, 0, 16, 0, 0, 0
 DB  0, 2, 64, 4, 0, 104, 3, 0, 0, 32, 0, 8, 0, 0, 16, 8, 0, 0, 1
 DB  64, 36, 4, 64, 8, 0, 0, 0, 0, 0, 2, 0, 0, 68, 36, 0, 5, 0, 32
 DB  0, 0, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0, 8, 17, 0, 64, 0, 16, 0
 DB  0, 64, 2, 1, 0, 36, 130, 2, 0

Rand2 LABEL BYTE
 DB  64, 32, 0, 0, 1, 0, 48, 0, 0, 0, 0, 0, 146, 16, 128, 64, 32
 DB  32, 0, 0, 0, 0, 128, 68, 0, 128, 0, 16, 0, 64, 0, 80, 0, 66
 DB  44, 0, 0, 65, 1, 132, 0, 132, 0, 12, 76, 24, 0, 0, 25, 24, 0
 DB  64, 0, 0, 0, 0, 0, 0, 0, 9, 48, 8, 0, 4, 0, 0, 8, 6, 0, 132
 DB  2, 128, 0, 0, 13, 0, 2, 0, 68, 64, 0, 0, 8, 32, 0, 128, 1, 0
 DB  0, 0, 2, 16, 16, 0, 64, 16, 0, 0, 144, 0, 4, 66, 17, 0, 4, 0
 DB  0, 4, 16, 9, 20, 16, 0, 20, 0, 0, 0, 2, 0, 0, 0, 34, 2, 0, 16
 DB  0, 0, 8, 4, 0, 92, 0, 128, 64, 16, 0, 0, 0, 1, 0, 1, 0, 0, 32
 DB  0, 64, 1, 69, 0, 0, 0, 64, 0, 1, 0, 0, 2, 14, 1, 0, 0, 8, 144
 DB  3, 0, 1, 0, 1, 0, 1, 0, 0, 96, 2, 1, 0, 0, 4, 9, 0, 68, 0, 0
 DB  0, 0, 2, 0, 0, 1, 0, 0, 0, 2, 128, 0, 0, 4, 8, 4, 0, 0, 6, 24
 DB  0, 16, 0, 9, 16, 0, 0, 0, 0, 0, 0, 0, 69, 0, 1, 0, 0, 16, 97
 DB  136, 32, 0, 64, 140, 128, 144, 0, 17, 0, 8, 32, 4, 64, 64, 8
 DB  0, 0, 128, 0, 0, 0, 0, 0, 0, 128, 0, 0, 0, 16, 0, 36, 128, 0
 DB  1, 0, 0, 0, 0, 0, 128, 32, 0, 0, 0, 1, 4, 0, 0, 2, 0, 1, 0, 128
 DB  0, 32, 0, 0, 4, 64, 8, 4, 0, 1, 0, 66, 17, 24, 0, 0, 16, 128
 DB  0, 0, 0, 32, 16, 0, 0, 58, 0, 0, 128, 8, 0, 0, 0, 0, 64, 0, 0
 DB  0, 0, 66, 0, 1, 0, 0

Rand3 LABEL BYTE
 DB  50, 0, 0, 4, 2, 0, 2, 2, 0, 132, 6, 36, 72, 0, 2, 0, 192, 129
 DB  2, 0, 0, 0, 128, 4, 12, 128, 2, 66, 0, 32, 16, 128, 66, 128
 DB  0, 0, 0, 5, 16, 0, 32, 32, 72, 1, 16, 0, 128, 10, 0, 64, 16
 DB  32, 5, 128, 0, 16, 64, 0, 130, 0, 0, 0, 0, 0, 2, 32, 0, 0, 0
 DB  64, 0, 0, 0, 0, 66, 0, 0, 20, 16, 16, 34, 32, 0, 0, 0, 2, 0
 DB  0, 128, 0, 64, 96, 0, 0, 8, 8, 1, 1, 0, 0, 64, 2, 4, 0, 64, 65
 DB  4, 64, 0, 32, 64, 32, 0, 128, 16, 0, 4, 3, 64, 9, 0, 64, 0, 0
 DB  0, 0, 32, 1, 4, 0, 0, 0, 64, 0, 4, 32, 16, 32, 0, 64, 64, 0
 DB  0, 0, 0, 128, 24, 0, 33, 20, 2, 0, 0, 8, 2, 128, 0, 48, 4, 2
 DB  16, 224, 2, 0, 0, 128, 0, 0, 0, 0, 0, 32, 0, 0, 8, 0, 0, 0, 3
 DB  4, 0, 0, 32, 0, 0, 80, 1, 128, 64, 0, 0, 0, 0, 0, 0, 0, 0, 0
 DB  144, 2, 0, 4, 136, 0, 0, 0, 8, 64, 152, 20, 2, 1, 164, 0, 0
 DB  0, 64, 8, 0, 165, 0, 0, 0, 0, 128, 16, 1, 0, 0, 136, 0, 96, 4
 DB  128, 40, 72, 0, 0, 0, 5, 0, 36, 0, 80, 0, 208, 16, 0, 0, 67
 DB  0, 36, 0, 0, 0, 0, 65, 0, 0, 0, 96, 18, 0, 0, 64, 160, 0, 0
 DB  0, 108, 0, 129, 32, 69, 16, 66, 8, 0, 0, 0, 104, 4, 0, 0, 72
 DB  8, 0, 0, 128, 0, 129, 4, 1, 132, 0, 20, 0, 0, 128, 160, 0, 12
 DB  2, 0, 34, 0, 0, 0, 42, 80, 0, 32, 128, 0, 20, 64, 0, 32, 0, 16

.CODE

Start PROC

	mov ah, 01
	mov cx, 02000h
	int 10h			; Turn the cursor off

	in al, 21h
	push ax			; Store the old interrupt mask
	mov al, 11111101b	; Set interrupts
	out 21h, al		; Zap everything except K/B

	mov ax, SEG DGROUP	; Set Data segment to code
	mov ds, ax

	mov ax, SCREEN		; Set Extra segment to point at screen start
	mov es, ax

	int 11h			; Get equipment list
	and al, 30h		
	cmp al, 30h		; Check that display is colour
	jnz mainext2

	mov dx, OFFSET Crapdisplay
	mov ah, 9
	int 21h			; Print a rude message if it is not colour
	jmp mainext3		; Quit program

mainext2 :
	call Getscreen		; Store the screen
	call Slide		; Slide the screen on
	call Delay		; Wait for a bit
	call Flash		; Flash the bit at the bottom

mailoop1 :
	mov ah, 01
	int 16h			; Check for keypress in K/B buffer
	jnz mainext1

	call Retrace		; Smooth scrolls

	call Stars		; Make right-hand starry bit
	call Scroll_lower	; Shift it along
	call Scrolltext		; Do the text at the bottom
	call Stripes		; Shift the colours along

	mov al, Strippos	; Is there a full line of '-'s ?
	or al, al
	jz mailoop1		; Yes - loop back

	push ax
	call dash		; Add another '-'
	pop ax
	dec al			; Decrement counter
	mov Strippos, al
	jmp mailoop1

mainext1 :
	xor ah, ah
	int 16h			; Flush the keyboard buffer

	call Bringitback	; Do that thing with the screen
	call Putscreen		; Make sure its all back

mainext3 :
	pop ax			; Reset interrupts
	out 21h, al		; Restore everything

	mov ah, 01
	mov cx, 00708h
	int 10h			; Turn the cursor on

	mov ah, 4Ch
	int 21h			; Return to DOS


Start ENDP

; ---------------------------------------------------------------------------
; Wait for screen retrace to finish and then start
; ---------------------------------------------------------------------------
Retrace PROC

	push dx
	mov dx, 3DAh

rton:				; Wait for retrace to finish
	in al, dx
	test al, 8
	jnz rton
rtoff:
	in al, dx		; Wait for retrace to start
	test al, 8
	jz rtoff

	pop dx
	ret

Retrace ENDP

; ---------------------------------------------------------------------------
; Slide the logo onto the screen
; ---------------------------------------------------------------------------
Slide PROC

	xor ax, ax
	mov Count, ax		; Set line count to 0

	mov di, OFFSET Xpos	; Load di with Xpos location
	
logloop1:
	mov bx, Count		; Get current row

	mov al, [bx+di]		; Get position of line
	
	cmp al, 160		; Test for position < 160
	jz lognext1		; If still 160 goto next part

	cmp al, 254		; Check for position < 0
	jz lognext1		; If position leftmost goto next part

	call logline		; Draw line

	sub al, 2		; Shift line 1 to the left

	mov [bx+di], al		; Store new position
	cmp al, SLIDENO		; Check for position to start next row
	jnz lognext1		; If not in position goto next part

	mov ax, Count
	cmp ax, 24		; Check that the row is >= 24
	jnb lognext1		; Skip starting the next row if so

	inc ax			; Point to next line
	mov bx, ax
	mov al, 158		; ax holds the starting position for next line
	mov [bx+di], al		; Store it

lognext1:
	mov ax, Count		; Get current row
	inc ax			; Move onto next row
	cmp ax, 25		; Check for last line
	jnz lognext2

	call Retrace
	xor ax, ax		; Reset line number

Lognext2:
	mov Count, ax		; Store it
	
	mov bx, 24
	mov al, [bx+di]
	or al, al		; Check that row 24 is not 0
	jnz logloop1		; Loop back if so

	call Logline		; Draw last row in place
	ret

Slide ENDP

; ---------------------------------------------------------------------------
; Draw a line of screen.  bx = row, ax = position
; ---------------------------------------------------------------------------
Logline PROC
	push di
	push bx
	push ax

	mov si, OFFSET Screendata	; Set si pointer

	xor di, di		; Set di to start of screen

	mov ax, bx
	mov bx, 160
	mul bx			; Get start position of line in table
	add si, ax		; Store position in source index
	add di, ax		; Store row position in dest index
	pop ax

	add di, ax		; Store column position in dest index
	
	shr ax, 1
	mov cx, 80
	sub cx, ax		; Set count for movsb = 80-position/2
	shl ax, 1

	cld			; Set direction for movsb

	rep movsw		; Do it

	pop bx
	pop di
	ret

Logline ENDP

; ---------------------------------------------------------------------------
; Flash the bit at the bottom of the screen
; ---------------------------------------------------------------------------
Flash PROC
	xor ax, ax
	mov Count, ax		; Reset colour counter
	mov Count1, ax		; Reset row counter

Flaloop1 :
	mov si, OFFSET Flashc
	mov bx, Count		; Get offset for colour
	mov al, [bx+si]		; Get the current colour
	mov dl, al

Flaloop2 :
	mov si, OFFSET From
	mov bx, Count1		; Get offset for start row
	mov ax, [bx+si]		; Get start row
	mov di, ax		; Store it in di

	mov cx, 78		; Count for each row

Flaloop3 :
	mov [es:di], dl		; Put the new colour in its location

	add di, 2		; Move to next one

	loop Flaloop3		; Loop until row done

	mov ax, Count1
	add ax, 2		; Go to next position in row table
	mov Count1, ax

	cmp ax, 16
	jnz Flaloop2		; Loop until 8th position reached

	call Retrace
	call Retrace
	call Retrace		; Wait for a bit

	xor ax, ax
	mov Count1, ax		; Reset row count

	mov ax, Count
	inc ax			; Move to next colour
	mov Count, ax

	cmp ax, 4		; Finished?
	jnz Flaloop1		; If not loop back

	ret

Flash ENDP

; ---------------------------------------------------------------------------
; Wait for a bit
; ---------------------------------------------------------------------------
Delay PROC
	push cx
	mov cx, 100		; Wait for 100 screen refreshes

delloop1 :
	call Retrace
	loop delloop1
	
	pop cx
	ret

Delay ENDP

; ---------------------------------------------------------------------------
; Save the screen in Savescr memory
; ---------------------------------------------------------------------------
Getscreen PROC
	push ds
	push es
	pop ds
	pop es			; Swap es and ds

	mov cx, 2000		; Counter for movsw

	mov di, OFFSET Savescr	; Set destination

	xor si, si		; Set source

	cld			; Set direction

	rep movsw		; Shove it all in there

	push ds
	push es
	pop ds
	pop es			; Swap es and ds back
	ret

Getscreen ENDP

; ---------------------------------------------------------------------------
; Restore screen from Savescr memory
; ---------------------------------------------------------------------------
Putscreen PROC
	mov cx, 2000		; Counter for movsw

	mov si, OFFSET Savescr	; Set source

	xor di, di		; Set destination

	cld			; Set direction

	rep movsw		; Suck it all out again
	ret

Putscreen ENDP

; ---------------------------------------------------------------------------
; Scroll the starfield type thingy
; ---------------------------------------------------------------------------
Scroll_lower PROC
	mov ax, 2240
	mov Count, ax		; Count holds the starting position for row

scrloop1 :
	mov si, Count		; si = position to be checked
	mov bx, 2		; Start of check position

scrloop2 :
	mov cx, 2		; cx = No. of places to shift it

	mov ax, [bx+es:si]	; Get the character
	cmp ax, 3844		; Is it a large blob?
	jnz scrnext1		; If not...

	cmp bx, 2		; Is it at the leftmost position?
	jz scrnext1		; If so forget it

	mov cx, 4		; Make it move 2 places

scrnext1 :
	push bx
	sub bx, cx		; Get its new position
	mov [bx+es:si], ax	; output character
	pop bx

	add bx, 2		; Move to next position
	cmp bx, 160		; End of line?
	jnz scrloop2

	mov ax, Count
	add ax, 160		; Set start pos to next line
	mov Count, ax

	cmp ax, 3520		; Finished?
	jnz scrloop1
	ret

Scroll_lower ENDP
	
; ---------------------------------------------------------------------------
; Draw the stars at the rightmost part of the scroller
; ---------------------------------------------------------------------------
Stars PROC
	mov bx, Rndpos		; Get position of random numbers in table
	inc bx
	cmp bx, 320		; End of table?
	jnz stanext1		; No

	xor bx, bx		; Reset position

stanext1 :
	mov Rndpos, bx		; Store new position

	mov si, OFFSET Rand1	; Get start of random table 1
	mov al, [bx+si]		; Get number
	mov Byte1, al		; Store it

	mov si, OFFSET Rand2
	mov al, [bx+si]
	mov Byte2, al

	mov si, OFFSET Rand3
	mov al, [bx+si]
	mov Byte3, al

	mov cx, 8		; Set loop counter

staloop1 :
	mov ax, 160
	mul cx
	add ax, 2238		; Calculate position of star
	mov di, ax

	mov ax, 32
	mov [es:di], ax

	mov al, Byte1		; Get random number
	test al, 1		; Check for a star at that position
	jz stanext2		; No star so skip it

	push ax
	mov ax, 3834		; Code for star
	mov [es:di], ax		; Write it
	pop ax

stanext2 :
	shr al, 1
	mov Byte1, al		; Shift pattern and store it

	mov al, Byte2		; Get random number
	test al, 1		; Check for a star at that position
	jz stanext3		; No star so skip it

	push ax
	mov ax, 3844		; Code for star
	mov [es:di], ax		; Write it
	pop ax

stanext3 :
	shr al, 1
	mov Byte2, al		; Shift pattern and store it

	mov al, Byte3		; Get random number
	test al, 1		; Check for a star at that position
	jz stanext4		; No star so skip it

	push ax
	mov ax, 3066		; Code for star
	mov [es:di], ax		; Write it
	pop ax

stanext4 :
	shr al, 1
	mov Byte3, al		; Shift pattern and store it

	loop staloop1
	ret

Stars ENDP

; ---------------------------------------------------------------------------
; Shift the colour stripey bits along
; ---------------------------------------------------------------------------
Stripes PROC
	xor di, di		; Load di with 0

	mov cx, 80		; Load loop counter

	mov al, Mappos		; Get position in colour map
	dec al			; Move to next one
	cmp al, 8
	jnz strnext1		; If not at end of table goto next bit

	mov al, 15		; Start of table

strnext1 :
	mov Mappos, al		; Store new start position

strloop1 :
	mov [es:di+2081], al
	mov [es:di+3521], al	; Output new colours

	add di, 2		; Move to next position
	inc al			; Move to next colour
	cmp al, 16
	jnz strnext2		; If not at end of table goto next bit

	mov al, 9

strnext2 :
	loop strloop1		; Loop until done
	ret

Stripes ENDP

; ---------------------------------------------------------------------------
; Draw a '-' at the next position on the line
; ---------------------------------------------------------------------------
Dash PROC
	mov bx, Dashpos
	mov al, 196

	mov [es:bx+2080], al
	mov [es:bx+3520], al

	add bx, 2
	mov Dashpos, bx
	ret

Dash ENDP

; ---------------------------------------------------------------------------
; Put the screen back by incrementing or decrementing the character there
; ---------------------------------------------------------------------------
Bringitback PROC

	call Setcolours		; Set the colours back to the original

briloop1 :
	xor bl, bl		; Reset completion flag
	xor di, di		; Reset screen position
	mov si, OFFSET Savescr	; Reset position in saved table
	mov cx, 2000		; Reset counter for loop

briloop2 :
	mov al, [es:di]		; Get character from screen
	mov ah, [si]		; Get saved caracter
	cmp al, ah		; Are they the same?
	jz briout		; If so skip the next bit

	mov bl, 1		; Set flag
	sub ah, al
	jc briless		; If saved char > screen char

	inc al
	mov [es:di], al		; Output char
	jmp briout		; This one is done

briless :
	dec al
	mov [es:di], al		; Output char

briout :
	add di, 2
	add si, 2		; Move to next position
	loop briloop2		; Go round again

	or bl, bl		; Check flag
	jnz brinext4

	ret			; Return if flag not set

brinext4 :
	in al, 60h
	cmp al, 02Ah
	jz brinext3		; Check for LH shift pressed

	call retrace
	jmp briloop1

brinext3 :
	ret

Bringitback ENDP

; ---------------------------------------------------------------------------
; Reset all the colour attributes on the screen
; ---------------------------------------------------------------------------
Setcolours PROC
	mov cx, 2000		; Set up loop counter
	mov si, OFFSET Savescr
	inc si			; Get position of first attribute

	mov di, 1		; Get position of first screen attribute

setloop1 :
	mov al, [si]
	mov [es:di], al		; Restore attribute

	add si, 2
	add di, 2		; Move to next position

	loop setloop1
	ret

Setcolours ENDP

; ---------------------------------------------------------------------------
; Do the text scroller thing at the bottom of the screen
;
; Textflag = 0 -- Just do the scroll bit until text is off the screen
;            1 -- Scroll and print out next letter
;            2 -- Do nothing
; ---------------------------------------------------------------------------
Scrolltext PROC
	mov al, Textflag
	or al, al
	jnz stxnext1

	call Textflag0
	ret

stxnext1 :
	cmp al, 1
	jnz stxnext2

	call Textflag1
	ret

stxnext2 :
	call Textflag2
	ret

Scrolltext ENDP

; ---------------------------------------------------------------------------
; Scroll the line until the text is off the screen
; ---------------------------------------------------------------------------
Textflag0 PROC
	call Scroll_line
	mov al, Textpos		; Check for scroll completion
	dec al
	mov Textpos, al
	or al, al		; Finshed?
	jz tf0next2
	ret			; No - return

tf0next2 :
	mov al, 80
	mov Textpos, al		; Reset Text flag

	mov al, Textline	; Get the current line number
	inc al			; Go to next one
	mov Textline, al	; Store it
	cmp al, 10		; At the end?
	jnz tf0next3

	xor ax, ax
	mov Linepos, ax		; Reset text pointer
	mov Textline, al	; Reset line counter

tf0next3 :
	mov al, 1		; Increment text flag
	mov Textflag, al
	ret

Textflag0 ENDP	

; ---------------------------------------------------------------------------
; Print the text on the screen as it scrolls
; ---------------------------------------------------------------------------
Textflag1 PROC
	call Scroll_line	; Shift everything along

	dec Lineposnow		; Update position of 1st char

	mov cl, Linenumnow	; No of chars printed this line

	mov al, Textline	; Get the current line
	mov bx, OFFSET Wordlength
	xlat			; Get current Wordlength
	cmp al, cl		; Is it at the end of the line?
	jz tf1next1

	mov si, OFFSET Message
	mov bx, Linepos
	mov al, [bx+si]
	mov di, 3838
	mov [es:di], al		; Print the char

	inc cl
	mov Linenumnow, cl	; Increment the No. of chars printed

	inc Linepos		; Move to next char
	ret

tf1next1 :
	mov al, Textline
	mov bx, OFFSET Wordpos
	xlat			; Get the stop position for this line

	mov bl, Lineposnow	; Get the position of this line
	cmp al, bl
	jz tf1next2		; Has it reached its position?

	ret			; No - return

tf1next2 :
	mov al, 80
	mov Lineposnow, al	; Reset the position of the line

	xor al, al
	mov Linenumnow, al	; Reset the No. of chars printed

	mov al, 2
	mov Textflag, al	; Inrement the flag
	ret

Textflag1 ENDP

; ---------------------------------------------------------------------------
; Wait for 125 screen refreshes
; ---------------------------------------------------------------------------
Textflag2 PROC
	mov al, Textwait
	dec al
	mov Textwait, al	; Update the No. of screen refreshes so far

	or al, al
	jz tf2next1		; Finished?

	ret

tf2next1 :
	mov al, TEXT_WAIT
	mov Textwait, al	; Reset count

	xor al, al
	mov Textflag, al	; Reset text flag

	ret

Textflag2 ENDP

; ---------------------------------------------------------------------------
; Scroll the text bit at the bottom of the screen
; ---------------------------------------------------------------------------
Scroll_line PROC
	mov si, 3682
	mov di, 3680
	mov cx, 79

sclloop1 :
	mov al, [es:si]
	mov [es:di], al
	add si, 2
	add di, 2
	loop sclloop1
	ret

Scroll_line ENDP

.STACK 512

END Start