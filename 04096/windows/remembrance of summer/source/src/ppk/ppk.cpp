#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include "ppk.h"

namespace PPK {

#ifdef PPK_STATIC_FORCE_INLINE
static __forceinline
#endif
void sequencer(
	short* render_buffer,
	short* render_buffer_end,
	char* wavetable_buf,
	const unsigned char* pattern
) {
	#pragma pack(push, 1)
	typedef struct _rwsmp {
		unsigned int	cbSize;
		unsigned short	usUnityNote;
		short			sFineTune;
		int				lAttenuation;
		unsigned int	fulOptions;
		unsigned int	cSampleLoops;
	} WSMPL;

	typedef struct _rloop {
		unsigned int	cbSize;
		unsigned int	ulType;
		unsigned int	ulStart;
		unsigned int	ulLength;
	} WLOOP;

	union SEQUENCER_REG {
		void*			p;

		int				i;
		short			s[2];
		signed char		c[4];

		unsigned int	ui;
		unsigned short	us[2];
		unsigned char	uc[4];
	};

	struct SEQUENCER_VAR {
		SEQUENCER_REG	reg[REG_END - REG_TOP + 1];
	} var;

	static const struct DRIVES_GM_DLS {
		char	str[16];
	} path = { "\\drivers\\gm.dls" };
	#pragma pack(pop)

#define	PPK_SNDTBL	((const char**) wavetable_buf)

	{
		enum {
			FOURCC_WAVE = ('w'<<0) | ('a'<<8) | ('v'<<16) | ('e'<<24),
		};

		char* gmdls_buf = wavetable_buf;

		* (DRIVES_GM_DLS*) &gmdls_buf[GetSystemDirectoryA(gmdls_buf, 127)] = path;
		int gmdls_size = _lread(_lopen(gmdls_buf, 0), gmdls_buf, WAVETABLE_SIZE);
		const char** w = PPK_SNDTBL;
		const char* q = gmdls_buf;

		const char* endptr = &q[gmdls_size];
		for(;;) {
			do {
				q++;
				if(q >= endptr) {
					goto read_dls_end;
				}
			} while(* (const unsigned int*) q != FOURCC_WAVE);
			const WSMPL* wsmpl = (const WSMPL*) &q[0x26];
			const short *smp = (const short*) &q[0x52];
			if(wsmpl->cSampleLoops == 0) {
				smp = (const short*) &q[0x42];
				WLOOP* wloop = (WLOOP*) &smp[-12];
				wloop->ulStart = (* (const unsigned int*) &smp[-2])/2-1;
				wloop->ulLength += 1;
			}
			WLOOP* wloop = (WLOOP*) &smp[-12];
			wloop->ulStart  <<= PITCH_SHIFT;
			wloop->ulLength <<= PITCH_SHIFT;

			*w++ = (char*) smp;
		}
	read_dls_end:
		;
	}

	const unsigned char* p = pattern;

#ifdef PPK_USE_FILTER
	var.reg[REG_FILTER_BUF_0].i = 0;
//	var.reg[REG_FILTER_BUF_1].i = 0;
#endif
	for(;;) {
		unsigned int c = (unsigned int) (*p++);
		if((unsigned char)c <= REG_END) {
			if((unsigned char)c == REG_QUIT) {
				break;
			}
			var.reg[c].i = * (short*) p;
			p++;
			p++;
			continue;
		}
		c -= LEN_TOP;

		if((unsigned char)c <= (LEN_END-LEN_TOP)) {
			var.reg[REG_LENGTH].i = c * var.reg[REG_TEMPO].i;
			continue;
		}

		{
			if((unsigned char)c <= REST - LEN_TOP) {
			} else {
				{
					unsigned char n = c;
					n -= NOTE_TOP-LEN_TOP;
					n -= CENTER_NOTE;
					var.reg[REG_NOTE].uc[0] += n;
				}
				var.reg[REG_PITCH_BASE].i = var.reg[REG_NOTE].i * 64;

				if(var.reg[REG_KEY].i <= 0) {
					__asm {
						fldz
						fst		qword ptr [var.reg+REG_KEYTIME*4+8*0]
						fst		qword ptr [var.reg+REG_KEYTIME*4+8*1]
						fstp	qword ptr [var.reg+REG_KEYTIME*4+8*2]
					}
					var.reg[REG_KEY].i++;
					var.reg[REG_LFO_DV].i = var.reg[REG_LFO_RATE].i;
				}

				int l = var.reg[REG_LENGTH].i;
				l *= var.reg[REG_GATERATIO].i;
				l >>= GATE_SHIFT;
				l--;
#if 1
				l -= 3;
#endif
				if(*p == SLUR) {
					p++;
					l = var.reg[REG_LENGTH].i;
				}
				var.reg[REG_KEYOFF].i += l;
			}
			short* dest = &render_buffer[var.reg[REG_TIME].i];
			var.reg[REG_TIME].i += var.reg[REG_LENGTH].i;

			{
				const short *smp = (const short*) PPK_SNDTBL[var.reg[REG_INSTRUMENT].i];
				const WLOOP* wloop = (const WLOOP*) &smp[-12];
				var.reg[REG_ENDPTR].p = &dest[var.reg[REG_LENGTH].i];
				do {
					int ti = var.reg[REG_KEYTIME].i++;

					int e;
					{
						enum { dvp_base = REG_ENV_ATTACK_RATE, };
						int dvp = REG_ENV_ATTACK_RATE - dvp_base;
						if(ti > var.reg[REG_ENV_ATTACK_TIME].i) {
							++dvp;
						}
						if(ti > var.reg[REG_ENV_DECAY_TIME].i) {
							++dvp;
						}
						if(ti >= var.reg[REG_KEYOFF].i) {
							--var.reg[REG_KEY].i;
						}
						if(var.reg[REG_KEY].i <= 0) {
							dvp = REG_ENV_RELEASE_RATE - dvp_base;
						}
						int v = var.reg[REG_EG_OUTPUT].i;
						v += var.reg[dvp + dvp_base].i;
						if(v < 0) {
							v = 0;
						}
						if(v > EG_MAX) {
							v = EG_MAX;
						}
						var.reg[REG_EG_OUTPUT].i = v;
						e = v >> (EG_SHIFT-8);
					}

					int o;
					{
						if(ti > var.reg[REG_LFO_DELAY].i) {
							int v = var.reg[REG_LFO_VAL].i += var.reg[REG_LFO_DV].i;
							if(v < 0) {
								v = -v;
							}
							if(v > var.reg[REG_LFO_DEPTH].i) {
								var.reg[REG_LFO_DV].i = -var.reg[REG_LFO_DV].i;
							}
						}

						{
							int note;
							note  = var.reg[REG_PITCH_BASE].i;
							note += var.reg[REG_DETUNE].i;
							note += var.reg[REG_LFO_VAL].i >> LFO_SHIFT;
							var.reg[REG_PITCH_SRC].i = note;
						}

						__asm {
							fild	dword ptr [var.reg+REG_PITCH_SRC*4]
							fild	dword ptr [var.reg+REG_KEYSCALE*4]
							fdivp	st(1), st(0)
							fld1
							fld		st(1)
							fprem
							f2xm1
							faddp	st(1), st(0)
							fscale
							fstp	st(1)
							fistp	qword ptr [var.reg+REG_PITCH*4]
						}
						{
							int spos = var.reg[REG_SAMPLE_POS].i;
							spos += var.reg[REG_PITCH].i;
							{
								int loop_start  = * (int*) &wloop->ulStart;
								int loop_length = * (int*) &wloop->ulLength;
								spos += loop_length;
								do {
									spos -= loop_length;
								} while(spos >= loop_start + loop_length);
							}
							var.reg[REG_SAMPLE_POS].i = spos;
							int s = spos >> PITCH_SHIFT;
							o = smp[s];
						}
					}

					if(dest < render_buffer_end) {
						int output;
						output = o;
						output *= e;
						output *= var.reg[REG_VOLUME].i;
						output >>= 8 + VOL_SHIFT;

#ifdef PPK_USE_FILTER
						// http://www.musicdsp.org/showArchiveComment.php?ArchiveID=29
						{
							enum {
								BUFSHIFT = 12,
								BUFSCALE = 1 << BUFSHIFT,
								f	= (int) (PPK_FILTER_F * BUFSCALE),
								q	= (int) (PPK_FILTER_Q * BUFSCALE),
								fb	= (int) ((PPK_FILTER_Q + PPK_FILTER_Q / (1.0 - PPK_FILTER_F)) * BUFSCALE),
							};
							int in = output;
							int& buf0 = var.reg[REG_FILTER_BUF_0].i;
							int& buf1 = var.reg[REG_FILTER_BUF_1].i;
							int t = (in - buf0) + ((fb*(buf0 - buf1)) >> BUFSHIFT);
							t *= f;
							t >>= BUFSHIFT;
							buf0 += t;
							buf1 += (f*(buf0 - buf1)) >> BUFSHIFT;
						//	output = buf0 - buf1;	// BPF
							output = in - buf1;		// HPF
						//	output = buf1;			// LPF
						}
#endif
						output += *dest;
						{
#ifdef PPK_USE_FILTER
							int omax = 32767;
#else
							int omax = var.reg[REG_OUTPUT_MAX].i;
#endif
							if(output > omax) {
								output = omax;
							}
							if(output < -omax) {
								output = -omax;
							}
						}
						*dest = output;
					}
				} while(++dest < (short*) var.reg[REG_ENDPTR].p);
			}
		}
	}

	return;
}

} // namespace PPK
