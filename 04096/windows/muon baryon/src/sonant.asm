; Sonant

;  Synth system targeted for 4k intros...now in 100% NASM!! :D

; [c] 2009 Ferris / YUP

global _sonant_init

%include "..\Include\win32n.inc"
%include "Sonant\ambidumbi.inc"

; Windows (sound-specific)
%define waveOutOpen _waveOutOpen@24
extern waveOutOpen
%define waveOutPrepareHeader _waveOutPrepareHeader@12
extern waveOutPrepareHeader
%define waveOutWrite _waveOutWrite@12
extern waveOutWrite

%define WAVE_CHAN 2 ; Channels
%define WAVE_SPS 44100 ; Samples per second
%define WAVE_BITS 16 ; Bits per sample
%define WAVE_ALIGN WAVE_CHAN * WAVE_BITS / 8 ; Bytes per sample
%define WAVE_SIZE WAVE_CHAN * WAVE_SPS * 240 ; Buffer size in samples
%define AUDIO_CLIPAMP 32767 ; Audio clipping amplitude
%define _4K_SONANT_END_ _4K_SONANT_ENDPATTERN_ * _4K_SONANT_ROWLEN_ * WAVE_SPS * 32 / 1000 ; End time in milliseconds

[section .text]
					; Initialize and play audio
_sonant_init:
					;  Set up stack
					;enter 0,0
					push ebp
					mov ebp,esp
					
					;  Save registers
					push eax
					push ebx
					push ecx
					push edx
					push esi
					mov esi,00430000h
					
					;  Parse song data
					;   Loop through instruments
					mov ecx,8
instrumentloop:			dec ecx
						mov [currentinstrument],ecx
						;   Clear buffers
						xor eax,eax
						push ecx
						mov ecx,WAVE_SIZE * 4
clearbuffers:				mov [lbuffer + ecx],eax
							mov [rbuffer + ecx],eax
						loop clearbuffers
						mov [currentpos],eax
						;   Loop through patterns
						xor ecx,ecx
patternloop:				mov [currentpattern],ecx
							;   Loop through rows
							push ecx
							xor ecx,ecx
rowloop:						;   Check current pattern
								mov edx,[currentinstrument]
								imul edx,byte 18;48
								add edx,[currentpattern]
								movzx eax,byte [song_data_patterns + edx] ; al = current pattern
								cmp eax,byte 0 ; if(al) {
								jbe exitrowloop
									dec eax
									mov edx,[currentinstrument]
									imul edx,128;320
									imul eax,byte 32
									add edx,eax
									movzx eax,byte [song_data_columns + edx + ecx] ; al = current note
									cmp eax,byte 0 ; if(n) {
									jbe exitrowloop
										mov [currentnote],eax
										;   Initialize instrument
										mov edx,[currentinstrument]
										mov ebx,edx
										shl ebx,byte 2
										mov eax,[song_data_env_attack + ebx]
										mov [attack],eax
										mov eax,[song_data_env_sustain + ebx]
										mov [sustain],eax
										mov eax,[song_data_env_release + ebx]
										mov [release],eax
										fldz
										fst qword [c1]
										fst qword [c2]
										fst dword [filter_low]
										fstp dword [filter_band]
										movzx eax,byte [song_data_fx_resonance + edx]
										mov [esi],eax
										fild dword [esi]
										fidiv word [glbl_255]
										fstp dword [filter_q]
										;   Write note
										push ecx
										mov ecx,[attack]
										add ecx,[sustain]
										add ecx,[release]
writenoteloop:								;   LFO
											mov eax,ecx
											push ecx
											movzx ecx,byte [song_data_lfo_freq + edx]
											call getlfofreq
											add eax,[currentpos]
											mov [esi],eax
											fimul dword [esi]
											mov [esi],dword _4K_SONANT_ROWLEN_
											fidiv dword [esi]
;											movzx eax,byte [song_data_lfo_waveform + edx]
											call osc_sin;call [osc_table + eax]
											movzx eax,byte [song_data_lfo_amt + edx]
											mov [esi],eax
											fimul dword [esi]
											fidiv word [glbl_512]
											fadd dword [glbl_onehalf]
											fstp dword [lfor]
											pop ecx
											;   Panning
											mov eax,ecx
											push ecx
											movzx ecx,byte [song_data_fx_pan_freq + edx]
											call getlfofreq
											add eax,[currentpos]
											mov [esi],eax
											fimul dword [esi]
											mov [esi],dword _4K_SONANT_ROWLEN_
											fidiv dword [esi]
											call osc_sin
											movzx eax,byte [song_data_fx_pan_amt + edx]
											mov [esi],eax
											fimul dword [esi]
											fidiv word [glbl_512]
											fadd dword [glbl_onehalf]
											pop ecx
											;   Envelope
											fld1
											cmp ecx,dword [attack]
											jge envelope_test2
											fstp st0
											mov [esi],ecx
											fild dword [esi]
											fidiv dword [attack]
											jmp envelope_end
envelope_test2:								mov eax,[attack]
											add eax,[sustain]
											cmp ecx,eax
											jb envelope_end
											mov eax,ecx
											sub eax,[attack]
											sub eax,[sustain]
											mov [esi],eax
											fild dword [esi]
											fidiv dword [release]
											fsubp st1
envelope_end:								fstp dword [e]
											;   Oscillator 1
											push ecx
											movzx ecx,byte [song_data_osc1_oct + edx]
											sub ecx,byte 8
											imul ecx,byte 12
;											movzx eax,byte [song_data_osc1_det + edx]
;											add ecx,eax
											add ecx,[currentnote]
											call getnotefreq
;											fld dword [glbl_det]
;											movzx eax,byte [song_data_osc1_detune + edx]
;											mov [esi],eax
;											fimul dword [esi]
;											fidiv word [glbl_255]
;											fld1
;											faddp st1
;											fmulp st1
											pop ecx
;											movzx eax,byte [song_data_lfo_osc1_freq + edx]
;											test ax,ax
;											jz osc1_no_freq
;											fadd dword [lfor]
osc1_no_freq:								movzx eax,byte [song_data_osc1_xenv + edx]
											dec eax
											js osc1_no_xenv
											fmul dword [e]
											fmul dword [e]
osc1_no_xenv:								fadd qword [c1]
											fst qword [c1]
											movzx eax,byte [song_data_osc1_waveform + edx]
											call [osc_table + eax]
											movzx eax,byte [song_data_osc1_vol + edx]
											mov [esi],eax
											fimul dword [esi]
											fidiv word [glbl_255]
											;   Oscillator 2
											push ecx
											movzx ecx,byte [song_data_osc2_oct + edx]
											sub ecx,byte 8
											imul ecx,byte 12
;											movzx eax,byte [song_data_osc2_det + edx]
;											add ecx,eax
											add ecx,[currentnote]
											call getnotefreq
											fld dword [glbl_det]
											movzx eax,byte [song_data_osc2_detune + edx]
											mov [esi],eax
											fimul dword [esi]
											fidiv word [glbl_255]
											fld1
											faddp st1
											fmulp st1
											pop ecx
;											movzx eax,byte [song_data_osc2_xenv + edx]
;											test ax,ax
;											jz osc2_no_xenv
;											fmul dword [e]
;											fmul dword [e]
osc2_no_xenv:								fadd qword [c2]
											fst qword [c2]
											movzx eax,byte [song_data_osc2_waveform + edx]
											call [osc_table + eax]
											movzx eax,byte [song_data_osc2_vol + edx]
											mov [esi],eax
											fimul dword [esi]
											fidiv word [glbl_255]
											faddp st1
											;   Noise oscillator
											imul eax,[randseed],15a4e35h
											mov [randseed],eax
											mov [esi],ax
											fild word [esi]
											fidiv word [glbl_255]
											call osc_sin
											movzx eax,byte [song_data_noise_fader + edx]
											mov [esi],eax
											fimul dword [esi]
											fidiv word [glbl_255]
											fmul dword [e]
											faddp st1
											fmul dword [e]
											;   State variable filter
											fild dword [song_data_fx_freq + edx * 4]
											movzx eax,byte [song_data_lfo_fx_freq + edx]
											test ax,ax
											jz lfo_no_fx_freq
											fmul dword [lfor]
lfo_no_fx_freq:								fmul dword [glbl_pi_over_sr]
											fsin
											fmul dword [glbl_1_and_one_half]
											fld dword [filter_band]
											fmul st1
											fadd dword [filter_low]
											fstp dword [filter_low]
											fld st1
											fsub dword [filter_band]
											fmul dword [filter_q]
											fsub dword [filter_low]
											fst dword [filter_high]
											fmulp st1
											fadd dword [filter_band]
											fstp dword [filter_band]
											movzx ax,byte [song_data_fx_filter + edx]
;											cmp ax,byte 1
;											jne sv_test2
;											fstp st0
;											fld dword [filter_high]
;											jmp sv_done
sv_test2:									cmp ax,byte 2
											jne sv_test3
											fstp st0
											fld dword [filter_low]
											jmp sv_done
sv_test3:									cmp ax,byte 3
											jne sv_done;sv_test4
											fstp st0
											fld dword [filter_band]
;											jmp sv_done
;sv_test4:									cmp ax,byte 4
;											jne sv_done
;											fstp st0
;											fld dword [filter_low]
;											fadd dword [filter_high]
											;   Output
sv_done:									movzx eax,byte [song_data_env_master + edx]
											mov [esi],eax
											fimul dword [esi]
											fimul word [glbl_mv]
											mov ebx,ecx
											add ebx,[currentpos]
											shl ebx,byte 2
											fld st0
											fmul st2
											fadd dword [rbuffer + ebx]
											fstp dword [rbuffer + ebx]
											fld1
											fsubrp st2
											fmulp st1
											fadd dword [lbuffer + ebx]
											fstp dword [lbuffer + ebx]
										dec ecx
										cmp ecx,byte 0
										jg writenoteloop
										pop ecx
exitrowloop:				add [currentpos],dword _4K_SONANT_ROWLEN_
							inc ecx
							cmp ecx,byte 32
							jb rowloop
							pop ecx
						inc ecx
						cmp ecx,_4K_SONANT_ENDPATTERN_; - 1
						jb patternloop
						
						;   Cross delay
						mov edx,[currentinstrument]
						movzx eax,byte [song_data_fx_delay_amt + edx]
						mov [esi],eax
						fild dword [esi]
						fidiv word [glbl_255]
						fstp dword [delayamt]
						movzx eax,byte [song_data_fx_delay_time + edx]
						imul eax,_4K_SONANT_ROWLEN_
						shr eax,1
						mov [delaytime],eax
						xor ecx,ecx
delayloop:				mov edx,ecx
						add edx,[delaytime]
						shl edx,byte 2
						fld dword [rbuffer + ecx * 4]
						fmul dword [delayamt]
						fadd dword [lbuffer + edx]
						fstp dword [lbuffer + edx]
						fld dword [lbuffer + ecx * 4]
						fmul dword [delayamt]
						fadd dword [rbuffer + edx]
						fstp dword [rbuffer + edx]
						inc ecx
						mov eax,WAVE_SIZE
						sub eax,[delaytime]
						cmp ecx,eax
						jb delayloop
						
						;   Write to buffer
						mov ecx,WAVE_SIZE
wtbloop:				mov ebx,ecx
						shl ebx,2
						add ebx,wave_buffer
						fld dword [lbuffer + ecx * 4]
						fiadd word [ebx]
						fistp dword [esi]
						mov edx,[esi]
						call clip
						mov [ebx],ax
						sub ebx,2
						fld dword [rbuffer + ecx * 4]
						fiadd word [ebx]
						fistp dword [esi]
						mov edx,[esi]
						call clip
						mov [ebx],ax
						loop wtbloop
						
						pop ecx
					cmp ecx,0
					jg instrumentloop
					
					;  Send to WaveOut API
					push byte 0
					push byte 0
					push byte 0
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
					
					;  End func
					pop esi
					pop edx
					pop ecx
					pop ebx
					pop eax
					;leave
					pop ebp
					ret
					
					; Audio clipping function
					;  edx = input
					;  eax = output
clip:
					cmp edx,AUDIO_CLIPAMP
					mov eax,AUDIO_CLIPAMP
					jg clip_return
					cmp edx,-AUDIO_CLIPAMP
					mov eax,-AUDIO_CLIPAMP
					jl clip_return
					mov eax,edx
clip_return:		ret
					
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
					
					;  Saw
					;   st0 = input
					;   st0 = output
osc_saw:
					fstp dword [esi]
					fld1
					fld dword [esi]
					fprem
					fstp st1
					fsub dword [glbl_onehalf]
					ret
					
					;  Tri
					;   st0 = input
					;   st0 = output
osc_tri:
					call osc_saw
					fadd dword [glbl_onehalf]
					mov [esi],word 4
					fimul word [esi]
					fld1
					fadd st0
					fcomp st1
					fnstsw ax
					sahf
					jb osc_tri_ret1
					fld1
					fsubr
					jmp osc_tri_return
osc_tri_ret1		mov [esi],word 3
					fild word [esi]
					fsub
osc_tri_return:		ret
					
					; Function to evaluate note frequency
					;  ecx = note #
					;  st0 = freq
getnotefreq:		
					fld dword [freq_init]
notefreqloop:			fmul dword [freq_mult]
					loop notefreqloop
					ret
					
					; Function to evaluate lfo frequency
					;  ecx = lfo value
					;  st0 = freq
getlfofreq:		
					inc ecx
					fld dword [lfo_freq_init]
lfofreqloop:			fadd st0
					loop lfofreqloop
					ret

[section .bss]
wave_buffer: ; Synth buffer
	resw WAVE_SIZE * WAVE_CHAN
lbuffer: ; Left channel
	resd WAVE_SIZE
rbuffer: ; Right channel
	resd WAVE_SIZE
currentpos: ; Current buffer position
	resd 1
currentinstrument: ; Current parsing instrument
	resd 1
currentpattern: ; Current parsing pattern
	resd 1
currentnote: ; Current note
	resd 1
attack: ; Current instrument attack
	resd 1
sustain: ; Current instrument sustain
	resd 1
release: ; Current instrument release
	resd 1
c1: ; Oscillator 1's current frequency
	resq 1
c2: ; Oscillator 2's current frequency
	resq 1
filter_q: ; Filter resonance
	resd 1
filter_high:
	resd 1
filter_low:
	resd 1
filter_band:
	resd 1
samplepos: ; Current sample position
	resd 1
lfor: ; Current lfo result
	resd 1
e: ; Current envelope amplitude
	resd 1
delaytime: ; Current instrument delay time
	resd 1
delayamt: ; Current instrument delay amount
	resd 1

[section .data]
glbl_onehalf:
	dd 0.5
glbl_255:
	dw 255
glbl_512:
	dw 512
glbl_1_and_one_half:
	dd 1.5
glbl_mv:
	dw 140
glbl_pi_over_sr:
	dd 0.000071237
glbl_det:
	dd 0.2
wave_format: ; Wave format header
	dw WAVE_FORMAT_PCM
	dw WAVE_CHAN
	dd WAVE_SPS
	dd WAVE_ALIGN * WAVE_SPS
	dw WAVE_ALIGN
	dw WAVE_BITS
wave_header: ; Wave header
	dd wave_buffer
	dd WAVE_SIZE * WAVE_CHAN * WAVE_BITS / 8
	dd 0,0,0,0,0,0
randseed: ; Random number generator seed
	dd 1
freq_init: ; Initial frequency
	dd 0.000002403
freq_mult: ; Frequency multiplier
	dd 1.059463094
lfo_freq_init: ; Initial lfo frequency
	dd 0.001953125
osc_table: ; Table to look up oscillator functions
	dd osc_sin,osc_square,osc_saw,osc_tri
