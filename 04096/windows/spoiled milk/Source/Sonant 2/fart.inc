; Song data for Sonant 2

%define SONANT2_NUM_MACHINES 17
%define SONANT2_COLUMNS 25
;%define SONANT2_FASTFORWARD 0
%define SONANT2_ROWLEN 5512

%define SONANT2_COMPILE_SQUARE
%define SONANT2_COMPILE_SAW
;%define SONANT2_COMPILE_TRI

%define SONANT2_COMPILE_DELAY
%define SONANT2_COMPILE_DISTO
%define SONANT2_COMPILE_FILTER
%define SONANT2_COMPILE_MIX

%define SONANT2_WAVE_CHAN 2
%define SONANT2_WAVE_SPS 44100
%define SONANT2_WAVE_BITS 16
%define SONANT2_WAVE_ALIGN SONANT2_WAVE_CHAN * SONANT2_WAVE_BITS / 8
%define SONANT2_WAVE_SIZE SONANT2_WAVE_CHAN * (SONANT2_COLUMNS + 2) * SONANT2_ROWLEN * 32
%define SONANT2_AUDIO_CLIPAMP 32767

%define SONANT2_MT_MASTUH 0
%define SONANT2_MT_OSC 1
%define SONANT2_MT_DELAY 2
%define SONANT2_MT_DISTO 3
%define SONANT2_MT_FILTER 4
%define SONANT2_MT_MIX 5

[section .bss]
song_buffer0:
	resd SONANT2_WAVE_SIZE
song_buffer1:
	resd SONANT2_WAVE_SIZE
song_buffer2:
	resd SONANT2_WAVE_SIZE
song_buffer3:
	resd SONANT2_WAVE_SIZE
song_buffer4:
	resd SONANT2_WAVE_SIZE

[section .data]
song_machines:
; Machine 0:
	db SONANT2_MT_OSC
	dd song_buffer0
	dd 0 ; osc_attack
	dd 5512 ; osc_sustain [ + osc_attack ]
	dd 8750 ; osc_release
	dd 0 ; osc_port
	dd 0.000000 ; osc_noise_vol
	dd 0.466667 ; osc_pan
	db 5 ; osc_oct 1
	db 0 ; osc_semi 1
	dd 0.100000 ; osc_det 1
	db 1 ; osc_xenv 1
	db 8 ; osc_waveform [ * 4 ] 1
	dd 1.000000 ; osc_vol 1
	db 5 ; osc_oct 2
	db 0 ; osc_semi 2
	dd 0.108000 ; osc_det 2
	db 1 ; osc_xenv 2
	db 8 ; osc_waveform [ * 4 ] 2
	dd 1.000000 ; osc_vol 2
	db 7 ; osc_oct 3
	db 0 ; osc_semi 3
	dd 0.100000 ; osc_det 3
	db 0 ; osc_xenv 3
	db 0 ; osc_waveform [ * 4 ] 3
	dd 0.000000 ; osc_vol 3
; Machine 1:
	db SONANT2_MT_OSC
	dd song_buffer1
	dd 97500 ; osc_attack
	dd 103012 ; osc_sustain [ + osc_attack ]
	dd 110000 ; osc_release
	dd 0 ; osc_port
	dd 0.000000 ; osc_noise_vol
	dd 0.466667 ; osc_pan
	db 7 ; osc_oct 1
	db 0 ; osc_semi 1
	dd 0.100000 ; osc_det 1
	db 0 ; osc_xenv 1
	db 8 ; osc_waveform [ * 4 ] 1
	dd 1.000000 ; osc_vol 1
	db 7 ; osc_oct 2
	db 0 ; osc_semi 2
	dd 0.110000 ; osc_det 2
	db 0 ; osc_xenv 2
	db 8 ; osc_waveform [ * 4 ] 2
	dd 0.836364 ; osc_vol 2
	db 7 ; osc_oct 3
	db 0 ; osc_semi 3
	dd 0.094000 ; osc_det 3
	db 0 ; osc_xenv 3
	db 8 ; osc_waveform [ * 4 ] 3
	dd 0.881818 ; osc_vol 3
; Machine 2:
	db SONANT2_MT_OSC
	dd song_buffer2
	dd 300 ; osc_attack
	dd 300 ; osc_sustain [ + osc_attack ]
	dd 2500 ; osc_release
	dd 833 ; osc_port
	dd 0.000000 ; osc_noise_vol
	dd 0.600000 ; osc_pan
	db 7 ; osc_oct 1
	db 0 ; osc_semi 1
	dd 0.100000 ; osc_det 1
	db 0 ; osc_xenv 1
	db 4 ; osc_waveform [ * 4 ] 1
	dd 0.750000 ; osc_vol 1
	db 7 ; osc_oct 2
	db 0 ; osc_semi 2
	dd 0.112000 ; osc_det 2
	db 0 ; osc_xenv 2
	db 4 ; osc_waveform [ * 4 ] 2
	dd 0.718182 ; osc_vol 2
	db 7 ; osc_oct 3
	db 0 ; osc_semi 3
	dd 0.100000 ; osc_det 3
	db 0 ; osc_xenv 3
	db 0 ; osc_waveform [ * 4 ] 3
	dd 0.000000 ; osc_vol 3
; Machine 3:
	db SONANT2_MT_OSC
	dd song_buffer3
	dd 300 ; osc_attack
	dd 300 ; osc_sustain [ + osc_attack ]
	dd 300 ; osc_release
	dd 0 ; osc_port
	dd 0.500000 ; osc_noise_vol
	dd 0.908333 ; osc_pan
	db 7 ; osc_oct 1
	db 0 ; osc_semi 1
	dd 0.100000 ; osc_det 1
	db 0 ; osc_xenv 1
	db 0 ; osc_waveform [ * 4 ] 1
	dd 0.000000 ; osc_vol 1
	db 7 ; osc_oct 2
	db 0 ; osc_semi 2
	dd 0.100000 ; osc_det 2
	db 0 ; osc_xenv 2
	db 0 ; osc_waveform [ * 4 ] 2
	dd 0.000000 ; osc_vol 2
	db 7 ; osc_oct 3
	db 0 ; osc_semi 3
	dd 0.100000 ; osc_det 3
	db 0 ; osc_xenv 3
	db 0 ; osc_waveform [ * 4 ] 3
	dd 0.000000 ; osc_vol 3
; Machine 4:
	db SONANT2_MT_OSC
	dd song_buffer4
	dd 300 ; osc_attack
	dd 1550 ; osc_sustain [ + osc_attack ]
	dd 300 ; osc_release
	dd 0 ; osc_port
	dd 0.500000 ; osc_noise_vol
	dd 0.116667 ; osc_pan
	db 7 ; osc_oct 1
	db 0 ; osc_semi 1
	dd 0.100000 ; osc_det 1
	db 0 ; osc_xenv 1
	db 0 ; osc_waveform [ * 4 ] 1
	dd 0.000000 ; osc_vol 1
	db 7 ; osc_oct 2
	db 0 ; osc_semi 2
	dd 0.100000 ; osc_det 2
	db 0 ; osc_xenv 2
	db 0 ; osc_waveform [ * 4 ] 2
	dd 0.000000 ; osc_vol 2
	db 7 ; osc_oct 3
	db 0 ; osc_semi 3
	dd 0.100000 ; osc_det 3
	db 0 ; osc_xenv 3
	db 0 ; osc_waveform [ * 4 ] 3
	dd 0.000000 ; osc_vol 3
; Machine 5:
	db SONANT2_MT_FILTER
	dd song_buffer0
	dd 0.450000 ; flt_lfo_amt
	dd 0.00001633506872 ; flt_lfo_phasedelta
	dd 0.054422 ; flt_freq [ / 88200]
	dd 0.330000 ; flt_res
	db 1 ; flt_type
	dd 0.000000 ; flt_dry
	dd 1.000000 ; flt_wet
; Machine 6:
	db SONANT2_MT_MIX
	dd song_buffer3,song_buffer4
	dd 1.000000 ; mix_vol1
	dd 0.283333 ; mix_vol2
; Machine 7:
	db SONANT2_MT_FILTER
	dd song_buffer2
	dd 0.520000 ; flt_lfo_amt
	dd 0.00000689062426 ; flt_lfo_phasedelta
	dd 0.077098 ; flt_freq [ / 88200]
	dd 0.290000 ; flt_res
	db 0 ; flt_type
	dd 0.525000 ; flt_dry
	dd 0.533333 ; flt_wet
; Machine 8:
	db SONANT2_MT_DISTO
	dd song_buffer0
	dd 8.700000 ; dst_gain
; Machine 9:
	db SONANT2_MT_FILTER
	dd song_buffer1
	dd 0.720000 ; flt_lfo_amt
	dd 0.00000469444421 ; flt_lfo_phasedelta
	dd 0.048753 ; flt_freq [ / 88200]
	dd 0.340000 ; flt_res
	db 3 ; flt_type
	dd 0.000000 ; flt_dry
	dd 1.000000 ; flt_wet
; Machine 10:
	db SONANT2_MT_FILTER
	dd song_buffer3
	dd 0.100000 ; flt_lfo_amt
	dd 0.00000875173464 ; flt_lfo_phasedelta
	dd 0.102041 ; flt_freq [ / 88200]
	dd 0.990000 ; flt_res
	db 0 ; flt_type
	dd 0.000000 ; flt_dry
	dd 1.000000 ; flt_wet
; Machine 11:
	db SONANT2_MT_DELAY
	dd song_buffer2
	dd 0.330000 ; dly_amt
	dd 33072 ; dly_time
; Machine 12:
	db SONANT2_MT_MIX
	dd song_buffer0,song_buffer1
	dd 0.300000 ; mix_vol1
	dd 1.000000 ; mix_vol2
; Machine 13:
	db SONANT2_MT_MIX
	dd song_buffer3,song_buffer2
	dd 1.000000 ; mix_vol1
	dd 1.000000 ; mix_vol2
; Machine 14:
	db SONANT2_MT_DELAY
	dd song_buffer0
	dd 0.400000 ; dly_amt
	dd 33072 ; dly_time
; Machine 15:
	db SONANT2_MT_MIX
	dd song_buffer3,song_buffer0
	dd 0.700000 ; mix_vol1
	dd 1.000000 ; mix_vol2
; Machine 16:
	db SONANT2_MT_MASTUH
	dd song_buffer3

song_columns:
; Oscillator 0:
	db 000h,000h,000h,000h,001h,006h,007h,008h,001h,006h,007h,008h,001h,006h,007h,008h,001h,006h,007h,008h,000h,000h,000h,000h,000h
; Oscillator 1:
	db 002h,003h,004h,005h,002h,003h,004h,005h,002h,003h,004h,005h,002h,003h,004h,005h,002h,003h,004h,005h,002h,003h,004h,005h,002h
; Oscillator 2:
	db 000h,000h,000h,000h,000h,000h,000h,000h,009h,00ah,00bh,00ch,009h,00ah,00bh,00ch,009h,00ah,00bh,00ch,009h,00ah,00bh,00ch,000h
; Oscillator 3:
	db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,00dh,00eh,00dh,00eh,00dh,00eh,00dh,00eh,000h,000h,000h,000h,000h
; Oscillator 4:
	db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,00eh,00dh,00eh,00dh,00eh,00dh,00eh,00dh,000h,000h,000h,000h,000h

song_patterns:
; Pattern 1:
	db 097h,000h,097h,000h,097h,000h,097h,000h,097h,000h,097h,000h,097h,000h,097h,000h,097h,000h,097h,000h,097h,000h,097h,000h,097h,000h,097h,000h,097h,000h,097h,000h
; Pattern 2:
	db 08bh,08eh,097h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
; Pattern 3:
	db 089h,08dh,095h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
; Pattern 4:
	db 087h,090h,093h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
; Pattern 5:
	db 084h,089h,09ah,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,099h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
; Pattern 6:
	db 095h,000h,095h,000h,095h,000h,095h,000h,095h,000h,095h,000h,095h,000h,095h,000h,095h,000h,095h,000h,095h,000h,095h,000h,095h,000h,095h,000h,095h,000h,095h,000h
; Pattern 7:
	db 093h,000h,093h,000h,093h,000h,093h,000h,093h,000h,093h,000h,093h,000h,093h,000h,093h,000h,093h,000h,093h,000h,093h,000h,093h,000h,093h,000h,093h,000h,093h,000h
; Pattern 8:
	db 090h,000h,090h,000h,090h,000h,090h,000h,090h,000h,090h,000h,090h,000h,090h,000h,095h,000h,095h,000h,095h,000h,095h,000h,095h,000h,095h,000h,095h,000h,095h,000h
; Pattern 9:
	db 097h,08bh,097h,08bh,097h,0a3h,097h,08bh,097h,08bh,097h,0a3h,08bh,0a3h,0a1h,09eh,097h,08bh,097h,08bh,097h,0a3h,097h,08bh,097h,08bh,097h,0a3h,08bh,0a3h,0a1h,09eh
; Pattern 10:
	db 095h,089h,095h,089h,095h,0a3h,095h,089h,095h,089h,095h,0a3h,089h,0a3h,0a1h,09eh,095h,089h,095h,089h,095h,0a3h,095h,089h,095h,089h,095h,0a3h,089h,0a3h,0a1h,09eh
; Pattern 11:
	db 087h,093h,09fh,087h,093h,09fh,087h,093h,0a6h,087h,093h,0a5h,087h,093h,0a1h,087h,087h,093h,09fh,087h,093h,09fh,087h,093h,0a6h,087h,093h,0a8h,087h,093h,0a5h,087h
; Pattern 12:
	db 09ch,090h,09ch,090h,09ch,0a8h,090h,09ch,0a8h,090h,09ch,0a5h,090h,09ch,0a6h,090h,095h,089h,095h,089h,095h,0a1h,089h,095h,0a6h,089h,095h,0a8h,089h,095h,0aah,095h
; Pattern 13:
	db 093h,000h,093h,000h,093h,093h,000h,093h,000h,093h,000h,093h,093h,093h,093h,000h,093h,000h,000h,093h,093h,093h,000h,093h,000h,093h,093h,000h,093h,093h,000h,093h
; Pattern 14:
	db 093h,000h,093h,000h,093h,093h,093h,000h,093h,000h,093h,093h,000h,000h,093h,000h,093h,000h,093h,093h,000h,000h,093h,000h,093h,093h,093h,093h,000h,093h,093h,000h
