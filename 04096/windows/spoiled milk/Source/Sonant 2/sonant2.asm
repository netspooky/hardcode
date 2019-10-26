; Sonant 2
;  Synth system targeted for 4k intros.

; (C) 2009 Jake Taylor [ Ferris / Youth Uprising ]

%include "..\Include\win32n.inc"
%include "Sonant~1\fart.inc"

global _sonant2_init

; Windows (sound-specific)
%define waveOutOpen _waveOutOpen@24
extern waveOutOpen
%define waveOutPrepareHeader _waveOutPrepareHeader@12
extern waveOutPrepareHeader
%define waveOutWrite _waveOutWrite@12
extern waveOutWrite

[section .text]
_sonant2_init:
					pusha
					
					mov esi,song_machines
					mov ebx,SONANT2_NUM_MACHINES
machineloop:			mov ecx,SONANT2_WAVE_SIZE
						lodsb
						push eax
						lodsd
						mov [cb],eax
						pop eax
						cmp al,byte SONANT2_MT_MASTUH
						jne checkosc
							; Mastuh
mastuhcopyloop:					mov eax,[cb]
								fld dword [eax + ecx * 4]
								fimul word [glbl_20000]
								push eax
								fistp dword [esp]
								pop eax
								cmp eax,SONANT2_AUDIO_CLIPAMP
								mov edx,SONANT2_AUDIO_CLIPAMP
								jg mastuhclipdone
								cmp eax,-SONANT2_AUDIO_CLIPAMP
								mov edx,-SONANT2_AUDIO_CLIPAMP
								jl mastuhclipdone
								xchg eax,edx
mastuhclipdone:					mov [wave_buffer + ecx * 2],dx
							loop mastuhcopyloop
						jmp endmachineloop
checkosc:				cmp al,byte SONANT2_MT_OSC
%ifdef SONANT2_COMPILE_DELAY
						jne checkdelay
%elifdef SONANT2_COMPILE_DISTO
						jne checkdisto
%elifdef SONANT2_COMPILE_FILTER
						jne checkfilter
%elifdef SONANT2_COMPILE_MIX
						jne defaultmix
%else
						jne endmachineloop
%endif
							; Osc
							mov edi,osc_attack
							times 6 movsd
							mov edx,[cb]
							; Oscillator loop
							push ecx
							xor ecx,ecx
oscloop:						mov [cb],edx
								times 3 fldz ; st0 = phase; st1 = phasedelta; st2 = phasedeltadelta
								; Column loop
								push ecx
								xor ecx,ecx
colloop:							pusha
									mov eax,SONANT2_NUM_MACHINES
									sub eax,ebx
									imul eax,SONANT2_COLUMNS
									add ecx,eax
									; Note loop
									xor ebx,ebx
noteloop:								movzx eax,byte [song_columns + ecx] ; al = column ID
										test eax,eax
										jz noteloop_blank
										dec eax
										shl eax,byte 5
										movzx eax,byte [song_patterns + eax + ebx] ; cl = note number
										test eax,eax
										jz noteloop_blank
										pusha
										xchg eax,ecx
										xor eax,eax
										lodsb ; osc_oct
										sub eax,byte 8
										imul eax,byte 12
										add ecx,eax
										xor eax,eax
										lodsb ; osc_semi
										add ecx,eax
										call getnotefreq ; st0 = note frequency; st1 = phase; st2 = phasedelta; st3 = phasedeltadelta
										lodsd ; osc_det
										push eax
										fld dword [esp] ; st0 = osc_det; st0 = note frequency; st1 = phase; st2 = phasedelta; st3 = phasedeltadelta
										pop eax
										fadd dword [glbl_pointnine] ; st0 = osc_det + .9f; st0 = note frequency; st1 = phase; st2 = phasedelta; st3 = phasedeltadelta
										fmulp st1 ; st0 = note frequency * detune; st1 = phase; st2 = phasedelta; st3 = phasedeltadelta
										mov eax,[osc_port]
										test eax,eax
										jnz noteloop_noport
											fst st2
noteloop_noport:						fsub st2 ; st0 = note frequency - phasedelta; st1 = phase; st2 = phasedelta; st3 = phasedeltadelta
										push eax
										fidiv dword [esp] ; st0 = phasedeltadelta; st1 = phase; st2 = phasedelta; st3 = phasedeltadelta
										pop eax
										fstp st3 ; st0 = phase; st1 = phasedelta; st2 = phasedeltadelta
										; Sample loop
										xor ecx,ecx
sampleloop:									pusha
											; Portamento
											cmp ecx,[osc_port]
											jge sampleloop_noport
												fld st1
												fadd st3
												fstp st2
											; Envelope
sampleloop_noport:							fld1 ; st0 = e; st1 = phase; st2 = phasedelta; st3 = phasedeltadelta
											cmp ecx,[osc_attack]
											jge sampleloop_noattack
												fstp st0
												push ecx
												fild dword [esp]
												pop ecx
												fidiv dword [osc_attack]
sampleloop_noattack:						cmp ecx,[osc_sustain]
											jb sampleloop_norelease
												mov eax,ecx
												sub eax,dword [osc_sustain]
												push eax
												fild dword [esp]
												pop eax
												fidiv dword [osc_release]
												fsubrp st1
											; xenv
sampleloop_norelease:						fld st2 ; st0 = phasedelta; st1 = e; st2 = phase; st3 = phasedelta; st4 = phasedeltadelta
											xor eax,eax
											lodsb ; osc_xenv
											test eax,eax
											jz sampleloop_noxenv
												times 2 fmul st1 ; sample *= e * e;
											; Render sample
sampleloop_noxenv:							fadd st2 ; st0 = [updated] phase; st1 = e; st2 = phase; st3 = phasedelta; st4 = phasedeltadelta
											fst st2 ; st0 = phase; st1 = e; st2 = phase; st3 = phasedelta; st4 = phasedeltadelta
											lodsb ; osc_waveform
											call [osc_table + eax] ; st0 = sample; st1 = e; st2 = phase; st3 = phasedelta; st4 = phasedeltadelta
											lodsd ; osc_volume
											push eax
											fld dword [esp] ; st0 = osc_vol; st1 = sample; st2 = e; st3 = phase; st4 = phasedelta; st5 = phasedeltadelta
											pop eax
											fmulp st1 ; st0 = sample * osc_vol; st1 = e; st2 = phase; st3 = phasedelta; st4 = phasedeltadelta
											imul eax,[randseed],0x15a4e35
											mov [randseed],eax
											push ax
											fild word [esp] ; st0 = noise; st1 = sample; st2 = e; st3 = phase; st4 = phasedelta; st5 = phasedeltadelta
											pop ax
											fidiv word [glbl_255] ; st0 = normalized noise; st1 = sample; st2 = e; st3 = phase; st4 = phasedelta; st5 = phasedeltadelta
											call osc_sin
											fmul dword [glbl_pointeight]
											fmul dword [osc_noise_vol] ; st0 = noise * osc_noise_vol; st1 = sample; st2 = e; st3 = phase; st4 = phasedelta; st5 = phasedeltadelta
											faddp st1 ; st0 = sample + noise; st1 = e; st2 = phase; st3 = phasedelta; st4 = phasedeltadelta
											fmulp st1 ; st0 = sample * e; st1 = phase; st2 = phasedelta; st3 = phasedeltadelta
											; Write sample
											mov eax,ecx
											shl eax,byte 3
											add eax,[cb]
											fld st0
											fmul dword [osc_pan]
											fadd dword [eax]
											fstp dword [eax]
											add eax,byte 4
											fld1
											fsub dword [osc_pan]
											fmulp st1
											fadd dword [eax]
											fstp dword [eax] ; st0 = phase; st1 = phasedelta; st2 = phasedeltadelta
											popa
										inc ecx
										mov eax,[osc_sustain]
										add eax,[osc_release]
										cmp ecx,eax
										jne sampleloop
										popa
noteloop_blank:							add dword [cb],SONANT2_ROWLEN * SONANT2_WAVE_CHAN * 4
									inc ebx
									cmp bl,byte 32
									jb noteloop
									popa
								inc ecx
								cmp ecx,SONANT2_COLUMNS
								jb colloop
								pop ecx
								times 3 fstp st0
							add esi,byte 12
							inc ecx
							jpo oscloop
							pop ecx
%ifdef SONANT2_COMPILE_DELAY
						jmp endmachineloop
checkdelay:				cmp al,byte SONANT2_MT_DELAY
%ifdef SONANT2_COMPILE_DISTO
						jne checkdisto
%elifdef SONANT2_COMPILE_FILTER
						jne checkfilter
%elifdef SONANT2_COMPILE_MIX
						jne defaultmix
%else
						jne endmachineloop
%endif
							; Delay
							push ebx
							lodsd ; dly_amt
							push eax
							fld dword [esp] ; st0 = dly_amt
							pop eax
							lodsd ; dly_time
							sub ecx,eax
							shl eax,byte 2
							xchg eax,edx
							mov eax,[cb]
dly_loop:						mov ebx,eax
								add ebx,edx
								add eax,byte 4
								fld dword [eax] ; st0 = sample; st1 = dly_amt
								fmul st1 ; st0 = sample * dly_amt; st1 = dly_amt
								fadd dword [ebx] ; st0 = delay sample; st1 = dly_amt
								fstp dword [ebx] ; st0 = dly_amt
							loop dly_loop
							fstp st0
							pop ebx
%endif
%ifdef SONANT2_COMPILE_DISTO
						jmp endmachineloop
checkdisto:				cmp al,byte SONANT2_MT_DISTO
%ifdef SONANT2_COMPILE_FILTER
						jne checkfilter
%elifdef SONANT2_COMPILE_MIX
						jne defaultmix
%else
						jne endmachineloop
%endif
							; Disto
							lodsd ; dst_gain
							push eax
							fld dword [esp] ; st0 = dst_gain
							pop eax
							mov eax,[cb]
distoloop:						fld dword [eax + ecx * 4] ; st0 = sample; st1 = dst_gain
								fmul st1 ; st0 = sample * gain; st1 = dst_gain
								fld1 ; st0 = 1; st1 = sample * gain; st2 = dst_gain
								fpatan ; st0 = final sample; st1 = dst_gain
								fstp dword [eax + ecx * 4] ; st0 = dst_gain
							loop distoloop
							fstp st0
%endif
%ifdef SONANT2_COMPILE_FILTER
						jmp endmachineloop
checkfilter:			cmp al,byte SONANT2_MT_FILTER
%ifdef SONANT2_COMPILE_MIX
						jne defaultmix
%else
						jne endmachineloop
%endif
							; Filter
							push ebx
							mov ebx,[cb]
							xor edx,edx
							inc edx
filter_chanloop:				mov ecx,SONANT2_WAVE_SIZE
								fldz
								fst dword [phasedeltadelta]
								fstp dword [e]
filter_sampleloop:					push esi
									lodsd ; flt_lfo_amt
									mov [phasedelta],eax
									fld1
									fsub dword [phasedelta]
									dec ecx
									push ecx
									fild dword [esp]
									pop eax
									lodsd ; lft_lfo_phasedelta
									push eax
									fmul dword [esp]
									pop eax
									call osc_sin
									fld1
									faddp st1
									fmul dword [phasedelta]
									faddp st1
									lodsd ; flt_freq
									push eax
									fmul dword [esp]
									pop eax
									call osc_sin
									fmul dword [glbl_oneandonehalf]
									fst dword [phasedelta]
									fmul dword [e]
									fadd dword [phasedeltadelta]
									fstp dword [phasedeltadelta]
									fld dword [ebx + ecx * 4]
									fsub dword [e]
									lodsd ; flt_res
									push eax
									fmul dword [esp]
									pop eax
									fsub dword [phasedeltadelta]
									fst dword [r]
									fmul dword [phasedelta]
									fadd dword [e]
									fstp dword [e]
									fld dword [phasedeltadelta] ; Notch
									fadd dword [r]
									fstp dword [phasedelta]
									xor eax,eax
									lodsb ; flt_type
									cmp al,byte 0 ; hipass
									jne flt_testlo
										fld dword [r]
										fstp dword [phasedelta]
										jmp flt_done
flt_testlo:							cmp al,byte 1 ; lopass
									jne flt_testband
										fld dword [phasedeltadelta]
										fstp dword [phasedelta]
										jmp flt_done
flt_testband:						cmp al,byte 2 ; bandpass
									jne flt_done
										fld dword [e]
										fstp dword [phasedelta]
flt_done:							fld dword [ebx + ecx * 4]
									lodsd ; flt_dry
									push eax
									fmul dword [esp]
									pop eax
									fld dword [phasedelta]
									lodsd ; flt_wet
									push eax
									fmul dword [esp]
									pop eax
									faddp st1
									fstp dword [ebx + ecx * 4]
									pop esi
								dec ecx
								jnz filter_sampleloop
								add ebx,byte 4
							dec edx
							jz filter_chanloop
							pop ebx
							add esi,byte 25
%endif
%ifdef SONANT2_COMPILE_MIX
						jmp endmachineloop
							; Mix
defaultmix:					lodsd ; buffer 2
							xchg eax,edx
							lodsd ; mix_vol1
							push eax
							fld dword [esp] ; st0 = mix_vol1
							pop eax
							lodsd ; mix_vol2
							push eax
							fld dword [esp] ; st0 = mix_vol2; st1 = mix_vol1
							pop eax
							mov eax,[cb]
mixloop:						fld dword [eax + ecx * 4] ; st0 = sample 1; st1 = mix_vol2; st2 = mix_vol1
								fmul st2
								fld dword [edx + ecx * 4] ; st0 = sample 2; st1 = sample 1; st2 = mix_vol2; st3 = mix_vol1
								fmul st2
								faddp st1 ; st0 = sample 1 + sample 2; st1 = mix_vol2; st2 = mix_vol1
								fstp dword [eax + ecx * 4] ; st0 = mix_vol2; st1 = mix_vol1
							loop mixloop
							times 2 fstp st0
%endif
endmachineloop:			
					dec ebx
					jnz machineloop
					
					times 3 push byte 0
					push wave_format
					push WAVE_MAPPER
					push esi
					call waveOutOpen
					push byte 32
					push wave_header
					push dword [esi]
					call waveOutPrepareHeader
					push byte 32
					push wave_header
					push dword [esi]
					call waveOutWrite
					
					popa
					ret
					
					; Oscillators
					;  Sine
					;   st0 = input
					;   st0 = output
osc_sin:
					fadd st0
					fldpi
					fmulp st1
					fsin
					ret
					
%ifdef SONANT2_COMPILE_SQUARE
					;  Square
					;   st0 = input
					;   st0 = output
osc_square:
					call osc_sin
					ftst
					fnstsw ax
					fstp st0
					fld1
					sahf
					jae osc_square_return
					fchs
osc_square_return:	ret
%endif
					
%ifdef SONANT2_COMPILE_SAW
					;  Saw
					;   st0 = input
					;   st0 = output
osc_saw:
					fstp dword [edi]
					fld1
					fld dword [edi]
					fprem
					fstp st1
					fsub dword [glbl_onehalf]
					ret
%endif
					
%ifdef SONANT2_COMPILE_TRI
					;  Tri
					;   st0 = input
					;   st0 = output
osc_tri:
					call osc_saw
					fadd dword [glbl_onehalf]
					mov [edi],word 4
					fimul word [edi]
					fld1
					fadd st0
					fcomp st1
					fnstsw ax
					sahf
					jb osc_tri_ret1
					fld1
					fsubr
					jmp osc_tri_return
osc_tri_ret1		mov [edi],word 3
					fild word [edi]
					fsub
osc_tri_return:		ret
%endif
					
					; Function to evaluate note frequency
					;  ecx = note #
					;  st0 = freq
getnotefreq:		
					fld dword [freq_init]
notefreqloop:			fmul dword [freq_mult]
					loop notefreqloop
					ret

[section .bss]
wave_buffer:
	resw SONANT2_WAVE_SIZE
cb:
	resd 1
osc_attack:
cb2:
phasedelta:
	resd 1
osc_sustain:
phasedeltadelta:
	resd 1
osc_release:
r:
	resd 1
osc_port:
e:
	resd 1
osc_noise_vol:
	resd 1
osc_pan:
	resd 1

[section .data]
glbl_20000:
	dw 20000
glbl_88200:
	dd 88200.0
glbl_onehalf:
	dd 0.5
glbl_oneandonehalf:
	dd 1.5
glbl_pointnine:
	dd 0.9
glbl_pointeight:
	dd 0.8
glbl_255:
	dw 255
freq_init:
	dd 0.000003649615
freq_mult:
	dd 1.059463094
wave_format:
	dw WAVE_FORMAT_PCM
	dw SONANT2_WAVE_CHAN
	dd SONANT2_WAVE_SPS
	dd SONANT2_WAVE_ALIGN * SONANT2_WAVE_SPS
	dw SONANT2_WAVE_ALIGN
	dw SONANT2_WAVE_BITS
wave_header:
	dd wave_buffer
	dd SONANT2_WAVE_SIZE * SONANT2_WAVE_BITS / 8
	dd 0,0,0,0,0,0
randseed:
	dd 1
osc_table:
	dd osc_sin
%ifdef SONANT2_COMPILE_SQUARE
	dd osc_square
%else
	dd 0
%endif
%ifdef SONANT2_COMPILE_SAW
	dd osc_saw
%else
	dd 0
%endif
%ifdef SONANT2_COMPILE_TRI
	dd osc_tri
%endif
