//
//	remembrance of summer (final)
//

#if defined(FINAL)
#undef  FINAL
#define FINAL 1
#else
#define FINAL 0
#endif

//#define  NO_SOUND		(!FINAL)
//#define TEST_SCENE_1	(!FINAL)	// sunset
//#define TEST_SCENE_2	(!FINAL)	// fireworks
//#define TEST_SCENE_3	(!FINAL)	// moonrise
enum {
	SCREEN_FULLSCREEN		= 1||FINAL ? 1 : 0,
	SCREEN_WIDTH			= 640,
	SCREEN_HEIGHT			= 480,
	SCREEN_COLORDEPTH		= 24,
	SCREEN_ZDEPTH			= 24,
};

#define SCREEN_ALPHADEPTH	(SCREEN_COLORDEPTH > 24 ? 8 : 0)
#define SCREEN_ASPECT		((float)SCREEN_WIDTH / (float)SCREEN_HEIGHT)

#include "main.h"

extern "C" int _fltused = 0;

enum {
	FADE_OUT_FRAME			= 63,
	TEMPO					= 75,
	TT_SUNSET_END			= SEC_TO_TICK(60.0/TEMPO*(32+0.5)),
	TT_FIREWORKS_END		= SEC_TO_TICK(60.0/TEMPO*(32+2+24)),
	TT_FIREWORKS_EMIT_END	= TT_FIREWORKS_END - SEC_TO_TICK(2.1),
	TT_MOONRISE_END			= SEC_TO_TICK(60.0/TEMPO*(32+2+24+20+4)),

//	SCENE2_EMIT1_SPEED		= 1,		// 1particle / 1msec
//	SCENE2_EMIT1_SPEED		= 2,		// 1particle / 2msec
	SCENE2_EMIT1_SPEED		= 5,		// 1particle / 5msec

	STROKE_EFFECT_TEXID		= 1,
	STROKE_COLOR_TEXID,

	STROKE_IMG_WIDTH		= 64,
	STROKE_IMG_D			= 2,

	NPARTICLE				= 1024 * 8,
};



//
//
//
enum { NHISTROY = 1<<6, };

struct XYZRGB {
	float		x, y, z;
	float		r, g, b;
};

struct PARTICLE {
	PARTICLE*	prev;
	PARTICLE*	next;
	float		x, y, z;
	float		vx, vy, vz;
	int			count;
	int			type;
	float		r, g, b;
	TICK		originTick;

	int			historyindex;
	XYZRGB		xyzrgb[NHISTROY];
};



//
//
//
struct VAR {
	TICK			tick;
	TICK			tickOrigin;		// music start
	TICK			tick2;
	TICK			tickOrigin2;	// app start

	HDC				hdc;
	GLUquadricObj*	qo;
	int				fade;
	unsigned int	glcolor_tmp;	// glColor4_CONST()

	int				scene2_emit_count;

	struct STROKE {
		float		len_a;
		float		len_b;
		float		angle_randomness_a;
		float		angle_randomness_b;
		int			alpha;
		int			clear_mode;
		float		width;
		int			anim_dt;
	} stroke;

	unsigned int	rnsx;

	struct PARTICLE_POOL {
		typedef PARTICLE Type;

		Type*	root;
		Type*	first;

		__forceinline void init(const int nparticle) {
			root = (Type*) malloc(sizeof(Type) * nparticle);
			root->prev =
			root->next = root;

			Type* p = root + 1;
			Type* end = root + nparticle;
			Type* np = 0;
			do {
				* (Type**) p = np;
				np = p++;
			} while(p < end);
			first = np;
		}

		__forceinline Type* alloc() {
			Type* p = first;
			if(p != 0) {
				first	= *reinterpret_cast<Type**> (p);

				Type* last	= root->next;

				p->next		= last;
				last->prev	= p;

				p->prev		= root;
				root->next	= p;
			}
			return p;
		}

		__forceinline Type* erase(Type* p) {
			Type* next = p->next;
			Type* prev = p->prev;
			prev->next = next;
			next->prev = prev;

			* reinterpret_cast<Type**> (p) = first;
			first = p;

			return prev;
		}

		__forceinline Type* begin() {
			return root->next;
		}

		__forceinline Type* end() {
			return root;
		}
	} particlePool;
};



//
//	OGL framework / auld
//	http://in4k.untergrund.net/index.php?title=Aulds_OGL_Framework
//
static __forceinline HDC winmain_startup() {
	HDC hdc;

	__asm {
		fnstcw	hdc
		or		BYTE PTR [hdc + 1], 0x0c		// or 0x0c00
		fldcw	hdc
	}

	if(SCREEN_FULLSCREEN) {
		#pragma pack(push, 1)
		struct _devicemode {
			BYTE	dmDeviceName[CCHDEVICENAME];
			WORD	dmSpecVersion, dmDriverVersion;
			WORD	dmSize;
			WORD	dmDriverExtra;
			DWORD	dmFields;
			short	dummy1[13];
			BYTE	dmFormName[CCHFORMNAME];
			WORD	dmLogPixels;
			DWORD	dmBitsPerPel;
			DWORD	dmPelsWidth;
			DWORD	dmPelsHeight;
			DWORD	dmDisplayFlags;
			DWORD	dmDisplayFrequency;
		} static dm = {						// do not set 'const'. ChangeDisplaySettings() will write dmDriverExtra.
			{ 0 },
			0, 0,
			sizeof(dm),
			0,
			DM_PELSWIDTH | DM_PELSHEIGHT,
			{ 0 },
			{ 0 },
			0,
			0,
			SCREEN_WIDTH,					// dmPelsWidth
			SCREEN_HEIGHT,					// dmPelsHeight
		};
		#pragma pack(pop)
		enum {
			exstyle  = 0,	//WS_EX_TOPMOST
			wndstyle = WS_POPUP | WS_VISIBLE | WS_MAXIMIZE,
		};
		ShowCursor(FALSE);
		FillRect(GetDC(CreateWindowExA(exstyle, "static", 0, wndstyle, 0, 0, 0, 0, 0, 0, 0, 0)), (RECT*) (&dm.dmPelsWidth - 2), (HBRUSH)GetStockObject(BLACK_BRUSH));
		ChangeDisplaySettingsA((DEVMODE*)&dm, CDS_FULLSCREEN);
		hdc = GetDC(CreateWindowExA(exstyle, "static", 0, wndstyle, 0, 0, 0, 0, 0, 0, 0, 0));
		ImmAssociateContext(hWnd, 0);
	} else {
		enum {
			exstyle  = 0,
			wndstyle = WS_OVERLAPPED | WS_CAPTION | WS_VISIBLE,
		};
		static RECT rc = { 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT };
		AdjustWindowRect(&rc, wndstyle, 0);
		hdc = GetDC(CreateWindowExA(exstyle, "static", 0, wndstyle, 0, 0, rc.right-rc.left, rc.bottom-rc.top, 0, 0, 0, 0));
	}

	static const PIXELFORMATDESCRIPTOR pfd = {
		0, 0, PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER,	// dwFlags
		0, SCREEN_COLORDEPTH,							// cColorBits
		0, 0, 0, 0, 0, 0, SCREEN_ALPHADEPTH,			// cAlphaBits
		0, 0, 0, 0, 0, 0, SCREEN_ZDEPTH,				// cDepthBits
	};

	SetPixelFormat(hdc, ChoosePixelFormat(hdc, &pfd), &pfd);
	wglMakeCurrent(hdc, wglCreateContext(hdc));

	return hdc;
}



//
// ppk
//
#if !(NO_SOUND)
#define PPK_STATIC_FORCE_INLINE
#define PPK_USE_FILTER
#define PPK_FILTER_F	0.35
#define PPK_FILTER_Q	0.90
#include "ppk/ppk.cpp"
static void WINAPI musicThread(LPVOID param) {
	static const
	#include "sequence.bin.h"
	enum {
		render_buffer_len	= 8 * 1024 * 1024,	// buffer length in sample
		sample_rate			= PPK::SAMPLE_RATE,	// Hz
		channel				= 1,				// 1:monaural, 2:stereo
		bits_per_sample		= 16,				// 16bit/sample
		render_buffer_bytes	= sizeof(short) * render_buffer_len,
		alloc_size			= PPK::WAVETABLE_SIZE + render_buffer_bytes,
	};

	char* wavetable_buf		= (char*)  GlobalAlloc(GMEM_FIXED|GMEM_ZEROINIT, alloc_size);
	short* riff_top			= (short*) &wavetable_buf[PPK::WAVETABLE_SIZE];
	short* render_buffer;

	{
		#pragma pack(push, 1)
		struct WAV_HEADER {
			struct HEADER {
				char	riffChunkID[4];				// 'RIFF'
				int		riffChunkSize;

				char	waveFormatListChunkID[4];	// 'WAVE'
				char	fmtChunkID[4];				// 'fmt '
				int		fmtChunkSize;
				struct FMT {
					short	audioFormat;
					short	numChannels;
					int		sampleRate;
					int		byteRate;
					short	blockAlign;
					short	bitsPerSample;
				} fmt;
			} header;

			char	dataChunkID[4];					// 'data'
			int		dataChunkSize;
		} static const dh = {
			{
				{ 'R', 'I', 'F', 'F' },
				render_buffer_bytes + sizeof(WAV_HEADER::HEADER),
				{ 'W', 'A', 'V', 'E' },
				{ 'f', 'm', 't', ' ' },
				sizeof(WAV_HEADER::HEADER::FMT),
				{
					1,													// 1 : signed 16-bit PCM
					channel,
					sample_rate,
					bits_per_sample * channel / 8 * sample_rate,		// byteRate
					bits_per_sample * channel / 8,						// blockAlign
					bits_per_sample,
				}
			},
			{ 'd', 'a', 't', 'a', },
			render_buffer_bytes,
		};
		#pragma pack(pop)
		WAV_HEADER* h = (WAV_HEADER*) riff_top;
		*h = dh;
		render_buffer = (short*) &h[1];
	}

	PPK::sequencer(render_buffer, &render_buffer[render_buffer_len], wavetable_buf, sequence_pattern);

	sndPlaySound((LPCSTR)riff_top, SND_MEMORY|SND_ASYNC);
	* (TICK*) param = GET_TICK();
	Sleep(INFINITE);
}
#endif



//
//
//
enum {
	MY_RAND_MAX = 0x7fff,
};

static __forceinline unsigned int krand(unsigned int &seed) {
	seed *= 5;
	seed++;
	return (seed >> 12) & MY_RAND_MAX;
}



//
//	generate brush stroke
//
static __forceinline void genStroke(VAR& var) {
	enum {
		WIDTH	= STROKE_IMG_WIDTH,
		D		= STROKE_IMG_D,
	};

	//	capture the screen
	glEnable(GL_TEXTURE_2D);
	glDisable(GL_BLEND);

	glLoadIdentity();

	glColor4_CONST(1.0f, 1.0f, 1.0f, 1.0f);

	enum {
		nloop = 3,
		texid = STROKE_EFFECT_TEXID,
		width = 512,
	};

	glBindTexture(GL_TEXTURE_2D, texid);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, width, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);

	{for(int i = 0; i < nloop; ++i) {
		glCopyTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, 0, 0, width, width);
		glBegin(GL_QUADS);
		glTexCoord2i(0, 0);	glVertex2s(-1, -1);
		glTexCoord2i(1, 0);	glVertex2s( 0, -1);
		glTexCoord2i(1, 1);	glVertex2f( 0.0f, SCREEN_ASPECT-1.0f);
		glTexCoord2i(0, 1);	glVertex2f(-1.0f, SCREEN_ASPECT-1.0f);
		glEnd();
	}}

	static int intbuf_body[(WIDTH+D*2) * WIDTH];
	static float angle[WIDTH * WIDTH];

	int* intbuf = &intbuf_body[0] + WIDTH*D*1;
	glReadPixels(0, 0, WIDTH, WIDTH, GL_RGBA, GL_UNSIGNED_BYTE, intbuf);
	gluBuild2DMipmaps(GL_TEXTURE_2D, 3, WIDTH, WIDTH, GL_RGBA, GL_UNSIGNED_BYTE, intbuf);

	{	// intensity
		for(int i = 0; i < WIDTH*WIDTH; ++i) {
			const unsigned char* cp = (const unsigned char*) &intbuf[i];
			int r = cp[0];
			int g = cp[1];
			int b = cp[2];
			int c = r*2 + g*5 + b;
			intbuf[i] = c;
		}
	}

	{	// gradient
		const int* ip = intbuf + WIDTH + 1;
		float* ap = &angle[1*WIDTH + 1];
		for(int i = 0; i < WIDTH*(WIDTH-2)-1; ++i, ++ip, ++ap) {
			int sx = 0, sy = 0;
			{
				const int* dp = ip - WIDTH*D;
				for(int dy = 0; dy < D*2+1; ++dy, dp += WIDTH) {
					sx += dp[(+D+1)];
					sx += dp[(+D+0)];
					sx -= dp[(-D-0)];
					sx -= dp[(-D-1)];
				}
			}

			{
				const int* dp = ip - D;
				for(int dx = 0; dx < D*2+1; ++dx, dp++) {
					sy += dp[(+D+1) * (WIDTH)];
					sy += dp[(+D+0) * (WIDTH)];
					sy -= dp[(-D-0) * (WIDTH)];
					sy -= dp[(-D-1) * (WIDTH)];
				}
			}

			*ap = atan2f((float)-sx, (float)sy);
		}
	}

	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	if(var.stroke.clear_mode != 0) {
		glBlendFunc(GL_SRC_ALPHA, GL_ONE);
		glColor4_CONST(0.0f, 0.0f, 0.0f, 0.0f);
	}
	glBegin(GL_QUADS);
	glTexCoord2i(0, 0);	glVertex2s(-1, -1);
	glTexCoord2i(1, 0);	glVertex2s( 1, -1);
	glTexCoord2i(1, 1);	glVertex2s( 1,  1);
	glTexCoord2i(0, 1);	glVertex2s(-1,  1);
	glEnd();

	glColor4ub(0xff, 0xff, 0xff, var.stroke.alpha);

	glTranslatef(-64.0f/62.0f, -64.0f/62.0f, 0.0f);
	glScalef(64.0f/62.0f*2.0f, 64.0f/62.0f*2.0f, 0.0f);

	glLineWidth(var.stroke.width);

	glEnable(GL_BLEND);
	glBegin(GL_LINES);
	{
		enum {
			RND_A = 1,
		//	RND_B = 0,
			RND_M = 12,			// 12 : 4096
		};
		unsigned int slrnd = 0;
		int stroke_rnd = 0;
		int RND_B = (var.tick2 / var.stroke.anim_dt);
		for(int i = 0; i < 4096; ++i) {
			// randomize stroke order
			stroke_rnd *= RND_A * 4 + 1;	// 4*n + 1
			stroke_rnd += RND_B * 2 + 1;	// 2*n + 1
			stroke_rnd %= 1 << RND_M;		// 1 << n

			int strokev = stroke_rnd;
			if(strokev >= (WIDTH-2)*(WIDTH-2)) {
				continue;
			}

			int x = (strokev % (WIDTH-2)) + 1;
			int y = (strokev / (WIDTH-2)) + 1;
			float ax = (float) x * (1.0f / ((float)WIDTH));
			float ay = (float) y * (1.0f / ((float)WIDTH));

			(void) krand(slrnd);
			int frnd = slrnd & 0xff;

			float stroke_len = var.stroke.len_a * frnd + var.stroke.len_b;

			float aa = angle[y*WIDTH + x] + frnd * var.stroke.angle_randomness_a + var.stroke.angle_randomness_b;
			float kx = cosf(aa) * stroke_len;
			float ky = sinf(aa) * stroke_len;

			glTexCoord2f(ax, ay);
			glVertex2f(ax+kx, ay+ky);
			glVertex2f(ax-kx, ay-ky);
		}
	}
	glEnd();
}



//
//
//
static __forceinline void initParticle(VAR& var) {
	var.particlePool.init(NPARTICLE+1);
}

static __forceinline void drawParticle(VAR& var) {
	gluPerspective(45.0, SCREEN_ASPECT, 0.0, 1.0);
	gluLookAt(32.0, -16.0, 40.0,	// eye
			  16.0,   8.0,  0.0,	// target
			   0.0,   1.0,  0.0);	// up vector

	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_COLOR, GL_ONE);

	const float sc = 1.0f / 16.0f;
	glScalef(sc, sc, sc);
	glLineWidth(1.0f);

	// emit particle 1
	if(var.tick < TT_FIREWORKS_EMIT_END) {
		while(var.scene2_emit_count * SCENE2_EMIT1_SPEED < var.tick - TT_SUNSET_END) {
			PARTICLE* p = var.particlePool.alloc();
			if(p == 0) {
				break;
			}
			var.scene2_emit_count++;

			const float spd = 0.7f*3.0f*3.0f*0.4f * 60.0f;
			float sp  = krand(var.rnsx) * (spd / (float)(MY_RAND_MAX+1)) + spd*0.5f;
			float ang = krand(var.rnsx) * (M_PIf * 2.0f / (float)(MY_RAND_MAX+1));
			p->x =
			p->y =
			p->z = 0.0f;
			p->type = 0;
			p->count = 640 + (var.scene2_emit_count % 20) * 40;

			p->historyindex = 0;
			p->r = 1.0f;
			p->g = 0.75f;
			p->b = 0.5f;
			p->vy = sp * cosf(ang);
			p->vz = 0.0f;
			p->vx = sp * sinf(ang);
			p->originTick = var.tick;
			for(int i = 0; i < NHISTROY; ++i) {
				p->xyzrgb[i].x = p->x;
				p->xyzrgb[i].y = p->y;
				p->xyzrgb[i].z = p->z;
				p->xyzrgb[i].r = p->r;
				p->xyzrgb[i].g = p->g;
				p->xyzrgb[i].b = p->b;
			}
		}
	}

	for(PARTICLE* p = var.particlePool.begin(); p != var.particlePool.end(); p = p->next) {
		bool erase = false;
		if(var.tick >= p->originTick + p->count) {
			erase = true;
		} else {
			if(p->type == 0 && var.tick >= p->originTick + (p->count*6)/8) {
				p->r =
				p->g =
				p->b = 0.0f;
				// emit particle 2
				for(int i = 0; i < 3; ++i) {
					PARTICLE* cp = var.particlePool.alloc();
					if(cp) {
						XYZRGB* h = &p->xyzrgb[p->historyindex];
						const float spd = 0.5f*3.0f*3.0f*3.0f*0.3f * 60.0f;
						float sp  = krand(var.rnsx) * (spd / (float)(MY_RAND_MAX+1));
						float ang = krand(var.rnsx) * (M_PIf * 2.0f / (float)(MY_RAND_MAX+1));
						cp->x = h->x;
						cp->y = h->y;
						cp->z = h->z;
						cp->type = 1;
						cp->count = 240 + i * 8;

						cp->historyindex = 0;
						cp->r = 1.0f;
						cp->g = 0.75f;
						cp->b = 0.5f;
						cp->vy = sp * cosf(ang);
						cp->vz = 0.0f;
						cp->vx = sp * sinf(ang);
						cp->originTick = var.tick;
						for(int i = 0; i < NHISTROY; ++i) {
							cp->xyzrgb[i].x = cp->x;
							cp->xyzrgb[i].y = cp->y;
							cp->xyzrgb[i].z = cp->z;
							cp->xyzrgb[i].r = cp->r;
							cp->xyzrgb[i].g = cp->g;
							cp->xyzrgb[i].b = cp->b;
						}
					}
				}
			}

			float ft = (var.tick - p->originTick) * (1.0f / 1024.0f);

			for(int ik = 0; ik < 4; ik++) {
				p->historyindex--;
				p->historyindex &= NHISTROY-1;

				XYZRGB* h = &p->xyzrgb[p->historyindex];
				float vr = powf(0.95f, ft) * ft;
				h->x = p->x + p->vx * vr;
				h->y = p->y + p->vy * vr - 0.0003f * powf(ft, 1.4f);
				h->z = p->z + p->vz * vr;

				h->r = p->r * powf(0.9997f, ft);
				h->g = p->g * powf(0.9950f, ft);
				h->b = p->b * powf(0.9900f, ft);
			}

			glBegin(GL_LINE_STRIP);
			for(int it = 0; it < NHISTROY; ++it) {
				int iit = (p->historyindex + it) & (NHISTROY-1);
				XYZRGB* q = &p->xyzrgb[iit];
				glColor3fv(&q->r);
				glVertex3fv(&q->x);
			}
			glEnd();
		}

		if(erase) {
			p = var.particlePool.erase(p);
		}
	}
}



//
//
//
static __forceinline void drawSunSet(VAR& var) {
	glDisable(GL_BLEND);

	// sky color
	glBegin(GL_TRIANGLE_STRIP);
	{for(int i = 0; i < 16; ++i) {
		float a = (float) i * (1.0f / 16.0f);
		float r = powf(a, 560.0f/256.0f) * (243.0f/256.0f) + 12.0f/256.0f;
		float g = powf(a, 448.0f/256.0f) * ( 90.0f/256.0f) + 12.0f/256.0f;
		float b = powf(a, 320.0f/256.0f) * ( 38.0f/256.0f) + 24.0f/256.0f;
		glColor3f(r, g, b);

		float y = a * -1.50f + 0.5f;
		glVertex2f(-1.0f, y);
		glVertex2f( 0.0f, y + 1.0f/16.0f);
	}}
	glEnd();

	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_COLOR, GL_DST_COLOR);

	float ky = (-1024*1024/10/2 - var.tick2) * (10.0f/(1024.0f*1024.0f));

	// sun
	glTranslatef(-0.5f, ky, 0.0f);
	glScalef(2.0f/8.0f, 3.0f/8.0f, 0.0f);
	glColor4_CONST(251/256.0f, 180/256.0f, 60/256.0f, 1.0f);
	gluDisk(var.qo, 0.0f, 0.8f, 32, 1);

	// horizon
	glLoadIdentity();
	glDisable(GL_BLEND);
	glColor4_CONST(0.0f/256.0f, 15.0f/256.0f, 20.0f/256.0f, 1.0f);
	glBegin(GL_QUADS);

	glVertex2s(-1, -1);
	glVertex2s( 1, -1);
	glVertex2f( 1, -230.0f/256.0f);
	glVertex2f(-1, -230.0f/256.0f);
	glEnd();

	// bird
	{
		glLineWidth(3.0f);
		float basex = var.tick2 * (1.0f / 1024.0f/32.0f) - (332.0f/256.0f);

		for(int na = 0; na < 3; ++na) {
			float kk = powf(1.1f, (float)na) / 256.0f;
			float kang = sinf(var.tick2 * kk)*30.0f;
			glLoadIdentity();
			glTranslatef(basex+0.1f*na, -0.4f+0.05f*na, 0.0f);
			glScalef(0.05f, 0.1f, 0.0f);

			glPushMatrix();
			glRotatef(kang, 0.0f, 0.0f, 1.0f);
			glBegin(GL_LINE_STRIP);
			{for(int i = 0; i < 16; ++i) {
				float a = (float)i * (1.0f / 16.0f);
				glVertex2f(a, a-powf(a, 3.3f));
			}}
			glEnd();
			glPopMatrix();

			glScalef(-1.0f, 1.0f, 0.0f);

			glPushMatrix();
			glRotatef(kang, 0.0f, 0.0f, 1.0f);
			glBegin(GL_LINE_STRIP);
			{for(int i = 0; i < 16; ++i) {
				float a = (float)i / 16.0f;
				glVertex2f(a, a-powf(a, 3.3f));
			}}
			glEnd();
			glPopMatrix();
		}
	}

	// scatter (?)
	glEnable(GL_BLEND);
	glLoadIdentity();
	glTranslatef(-0.5f, ky, 0.0f);
	glScalef(2.0f*0.5f, 1.2f*0.5f+ky*(1.0f/8.0f), 0.0f);
	glColor4_CONST(251/256.0f/2.0f, 120/256.0f/2.0f, 60/256.0f/2.0f, 1.0f);
	gluDisk(var.qo, 0.0f, 1.0f, 32, 1);
}



//
//
//
static __forceinline void drawMoonRise(VAR& var) {
	float kt = (var.tick - TT_FIREWORKS_END) * (1.0f / 1024.0f);

	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_COLOR, GL_ONE);

	// moon
	{
		glEnable(GL_LIGHTING);
		glEnable(GL_LIGHT0);

		static float ambient_color[] = {  96.0f/256.0f,  96.0f/256.0f, 128.0f/256.0f, 1.0f, };

		glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT , ambient_color);

		glTranslatef(-0.75f+kt*(12.0f/1024.0f), -0.75f+kt*(36.0f/1024.0f), 0.0f);
		glScalef(0.25f, 0.25f*1.6f, 1.0f);
		gluSphere(var.qo, 1.0f, 64, 64);

		glDisable(GL_LIGHTING);
	}

	// pampas grass
	const float tk = 1.0f / 256.0f;
	float tt = (sinf(kt * (3.0f / 2.0f)) + 224.0f/64.0f) * tk;

	glLoadIdentity();
	glTranslatef(-22.0f/16.0f, -1.0f, 0.0f);
	glScalef(1.0f, 1.0f/16.0f, 0.0f);

	glDisable(GL_BLEND);
	glColor4_CONST(144.0f/256.0f, 128.0f/256.0f, 96.0f/256.0f, 0.0f);
	glLineWidth(5.0f);

	{for(int ki = 0; ki < 40; ++ki) {
		int kk = ((ki & 7)<<3) ^ (ki >> 3) ^ ki;	// fixme
		glTranslatef(((kk*3) & 255) * (4.0f/256.0f/64.0f) + 1.0f/128.0f, 0.0f, 0.0f);
		glBegin(GL_LINE_STRIP);
		float klen = ((kk & 15) + 6) * (1.0f / 16.0f);
		for(int i = 0; i < 16; ++i) {
			float x = powf(i*tt, 1.6f);
			glVertex2f(x, i * klen);
		}
		glEnd();
	}}

	// fadein
	{
		glBlendFunc(GL_ONE_MINUS_SRC_ALPHA, GL_SRC_ALPHA);
		glEnable(GL_BLEND);

		float a = kt;
		if(a < 1.0f) {
			glColor4f(0.0f, 0.0f, 0.0f, a);
			glLoadIdentity();
			gluDisk(var.qo, 0.0f, 32.0f, 4, 1);
		}
	}
}



//
//
//
#ifdef _DEBUG
INT WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, INT)
#else
extern "C" void __cdecl WinMainCRTStartup()
#endif
{
	VAR var;
	var.hdc					= winmain_startup();
	var.fade				= 0;
	var.scene2_emit_count	= 0;
	var.tickOrigin			=
	var.tickOrigin2			= GET_TICK();

#if TEST_SCENE_1
#define NO_SOUND 1
	var.tickOrigin = var.tickOrigin2 = GET_TICK() - 0;
#endif
#if TEST_SCENE_2
#define NO_SOUND 1
	var.tickOrigin = var.tickOrigin2 = GET_TICK() - TT_SUNSET_END;
#endif
#if TEST_SCENE_3
#define NO_SOUND 1
	var.tickOrigin = var.tickOrigin2 = GET_TICK() - TT_FIREWORKS_END;
#endif

	initParticle(var);
	var.qo = gluNewQuadric();
	gluQuadricNormals(var.qo, GLU_TRUE);
	gluQuadricTexture(var.qo, GLU_TRUE);

#if !(NO_SOUND)
	CreateThread(0, 0, (LPTHREAD_START_ROUTINE) musicThread, (void*) &var.tickOrigin, 0, 0);
#endif
	do {
		{
			TICK t = GET_TICK();
			var.tick	= t - var.tickOrigin;
			var.tick2	= t - var.tickOrigin2;
		}

		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		glLoadIdentity();

		static const VAR::STROKE strokeTable[] = {
			{	// sunset
				300.0f / 128.0f / 128.0f / 256.0f,		// len_a
				300.0f / 128.0f / 128.0f,				// len_b
				0.1f / 128.0f,							// angle_randomness_a
				0.0f,									// angle_randomness_b
				0x8c,									// alpha
				0,										// clear_mode
				11.0f,									// width
				250,									// anim_dt
			},
			{	// particle
				800.0f / 128.0f / 128.0f / 256.0f,		// len_a
				10.0f / 128.0f / 128.0f,				// len_b
				0.05f / 128.0f,							// angle_randomness_a
				M_PIf / 2.0f,							// angle_randomness_b
				0xf0,									// alpha
				1,										// clear_mode
				8.0f,									// width
				SEC_TO_TICK(60.0/TEMPO*2),				// anim_dt
			},
			{	// moonrise
				400.0f / 128.0f / 128.0f / 256.0f,		// len_a
				150.0f / 128.0f / 128.0f,				// len_b
				0.02f / 128.0f,							// angle_randomness_a
				0.0f,									// angle_randomness_b
				0x60,									// alpha
				0,										// clear_mode
				11.0f,									// width
				1<<31,									// anim_dt
			},
		};

		if(var.tick < TT_SUNSET_END) {
			var.stroke = strokeTable[0];
			drawSunSet(var);
		} else if(var.tick < TT_FIREWORKS_END) {
			var.stroke = strokeTable[1];
			drawParticle(var);
		} else {
			var.stroke = strokeTable[2];
			drawMoonRise(var);
		}

		genStroke(var);
		glDisable(GL_TEXTURE_2D);

		if(var.tick >= TT_MOONRISE_END) {
			++var.fade;
			((void (WINAPI*)(int,int,int,int))glColor4ub) (0, 0, 0, var.fade << 2);
			gluDisk(var.qo, 0.0f, 32.0f, 4, 1);
		}
	} while(
		SwapBuffers(var.hdc),
		var.fade < FADE_OUT_FRAME &&
		(((int (WINAPI*)(int)) GetAsyncKeyState) (VK_ESCAPE) - 1 < 0)
	);
	((void (WINAPI*)(void)) ExitProcess) ();
}
