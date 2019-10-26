#ifndef FROMPLANE2COLOR_SCENES_IMPLICIT_FUNC_HPP
#define FROMPLANE2COLOR_SCENES_IMPLICIT_FUNC_HPP

namespace scenes
{
namespace implicit
{

struct tmpl
{
	const static uint scene_length = NUM_FPS*5;
	DRAW_FUNC_ATTRIB static void draw(uint frameCount)
	{
		const vec4 t =
			vec4(frameCount)/vec4(scene_length)
			*cps2 - cps1;

		FBUF_LOOP_BEGIN
		{
		}
		FBUF_LOOP_END
	}
};

struct plasma
{
	const static uint scene_length = NUM_FPS*10;
	DRAW_FUNC_ATTRIB static void draw(uint frameCount)
	{
		const vec4 t =
			vec4(frameCount)/vec4(scene_length);

		/*
			s(x)  = a*x^3 +   b*x^2 + c*x+d
			ds/dx = 3a*x^2 + 2b*x   + c

			constrain:
			s(0)  = d = s0(initial s)
			s(1)  = a + b + c + d = s1(last s)
			s'(0) = c = s0'(initial s speed)
			s'(1) = 3a + 2b + c = s1'(last s speed) = 0

			solve!
			d = s0
			a + b = s1 - c - d = s1 - s0' - s0
			c = s0'
			3a + 2b = s1' - c = s1' - s0

			b = s1-s0'-s0-a
			3a+2(s1-s0'-s0-a) = s1' - s0
			3a-2a + 2s1 - 2s0 = s1' - s0

			answer:
			a = s0 - 2s1 + s1'
			b = -2s0 + 3s1 - s0' - s1'
			c = s0'
			d = s0
		 */
		const vec4 s0 = cps0, s1 = 8.0f, s0d = cps1d2, s1d = cps0;
		const vec4 s =
			(s0 - cps2*s1 + s1d)*t*t*t + 
			(-s0*cps2 + 3.0f*s1 - s0d - s1d)*t*t +
			s0d*t +
			s0;
		const vec4 angle = t;
		const vec4 rot_x = itk_ncos3(angle);
		const vec4 rot_y = itk_nsin3(angle);
		FBUF_LOOP_BEGIN
		{
			vec4 rx = x*rot_x - (norm_height-y)*rot_y;
			vec4 ry = x*rot_y + (norm_height-y)*rot_x;

			const vec4 cx = rx*s+cps1d4;
			const vec4 cy = ry*s+cps1d4;
			const vec4 val = (itk_nsin3(cx)+itk_nsin3(cy))*cps1d4+cps1d2;

			fbuffer[c].r = val;
			fbuffer[c].g = cps1d4;
			fbuffer[c].b = cps1d4;
		}
		FBUF_LOOP_END
	}
};

struct plasma_wave
{
	const static uint scene_length = NUM_FPS*5;
	DRAW_FUNC_ATTRIB static void draw(uint frameCount)
	{
		const vec4 t =
			vec4(frameCount)/vec4(scene_length);

		const vec4 s = 8.0f;//4.0f+cps1d4;
		FBUF_LOOP_BEGIN
		{
			vec4 cx = x*s+cps1d4;
			vec4 cy = (norm_height-y)*s+cps1d4;
			vec4 val = (itk_nsin3(cx)+itk_nsin3(cy))*cps1d4+cps1d2;

			cx = (x-norm_width_half);
			cy = (norm_height_half-y);
			const vec4 r = cx*cx+cy*cy;

			const vec4 rad = itk_natan2_1(cy, cx);
			vec4 anim_rad =
				clamp
				(
					r*4.0f-t*t*8.0f+cps1d2
					-
					t*t*t*itk_nsin3(rad*16.0f)
				, cps0, cps1d2);
			val = itk_nsin3(anim_rad)+val;

			vec4 gb = (cps1 - anim_rad*cps2)*val;

			fbuffer[c].r = val;
			fbuffer[c].g = cps1d4+gb;
			fbuffer[c].b = cps1d4+gb;
		}
		FBUF_LOOP_END
	}
};

#define NUM_METABALLS 32
#define METABALL_SIZE (MIN_VIEW_LEN/4)
#define NORM_METABALL_SIZE (float(METABALL_SIZE)/MIN_VIEW_LEN)

//x.x, y.xに入っている値しかみません.
__forceinline bool is_metaball_visible(const vec4& x, const vec4& y)
{
	vec4 ret = x > -NORM_METABALL_SIZE;
	ret &= x < norm_width;

	ret &= y > -NORM_METABALL_SIZE;
	ret &= y < norm_height;

	return movemask(ret) & 1;

/*
	if(x.x <= -NORM_METABALL_SIZE || x.x >= norm_width)
	{
		return false;
	}

	if(y.x <=  -NORM_METABALL_SIZE || y.x >= norm_height)
	{
		return false;
	}

	return true;
*/
}

__forceinline void get_draw_range(
	const vec4& fpx, const vec4& fpy, const vec4& size,
	uint& width, uint& height, uint& c_head, vec4& x_head, vec4& y_head
	)
{
	//画面の端でカリング.
	//Culling by screen.
	vec4 fpx_min = max(fpx, cps0);
	vec4 fpx_max = min(fpx+NORM_METABALL_SIZE, norm_width);

	uint px_min = uvec4(fpx_min*float(MIN_VIEW_LEN)).x;
	uint px_max = uvec4(fpx_max*float(MIN_VIEW_LEN)).x;

	//align px_min and px_max for SSE.
	const uint px_min_a = px_min & ~3;
	x_head = -vec4(px_min - px_min_a)*DFXDVX+(fpx_min-fpx);
	//大きい方へalign.
	const uint px_max_a = ((px_max-1)&~3)+4;
	width = (px_max_a - px_min_a)/4;
	px_min = px_min_a;
	px_max = px_max_a;

	vec4 fpy_min = max(fpy, cps0);
	vec4 fpy_max = min(fpy+size, norm_height);

	const uint py_min = uvec4(fpy_min*float(MIN_VIEW_LEN)).x;
	uint py_max = uvec4(fpy_max*float(MIN_VIEW_LEN)).x;
	height = py_max-py_min;

	c_head = VIEW_WIDTH/4*py_min+px_min/4;
	y_head = fpy_min-fpy;
}

//vec4 fpx, fpy; is used as normalized metaball position.
#define METABALL_LOOP_BEGIN										\
	{															\
		/*画面に入らないメタボールは無視.*/						\
		/*Ignore metaball in out side screen.*/					\
		if(!is_metaball_visible(fpx, fpy))						\
		{														\
			continue;											\
		}														\
																\
		uint w, h;												\
		uint c_head;											\
		vec4 x_head, y;											\
		get_draw_range											\
		(														\
			fpx, fpy, vec4(NORM_METABALL_SIZE),					\
			w, h, c_head, x_head, y								\
		);														\
																\
		for(uint i=0; i<h; ++i, y += DFXDVX)					\
		{														\
			uint c = c_head;									\
			vec4 x = x_head + init_x;							\
			for(uint j=0; j<w; ++j, ++c, x+=delta_x)			\

#define METABALL_LOOP_END										\
			c_head += VIEW_WIDTH/4;								\
		}														\
	}															\

struct metaball_rise
{
	const static uint scene_length = NUM_FPS*5;

	DRAW_FUNC_ATTRIB static void draw(uint frameCount)
	{
		{
			FBUF_LOOP_BEGIN
			{
				fbuffer[c].r = fbuffer[c].g = fbuffer[c].b = -1.0f;
			}
			FBUF_LOOP_END
		}

		const vec4 t =
			vec4(frameCount)/vec4(scene_length);

		for(uint ii=0; ii<NUM_METABALLS; ++ii)
		{
			//floatで計算してもいいけどできるだけ同じ命令を使い回したほうが圧縮されやすい.
			//正規化された座標系でのメタボールの位置.
			//How do you place and move metaballs?
		//	const vec4 fpy = cps0;//(vec4(ii)/NUM_METABALLS);
		//	const vec4 fpx = t.x*4.0f-1.0f + (vec4(ii)/(NUM_METABALLS));
			const vec4 fii = vec4(ii);
			const vec4 tmp = itk_ncos3(fii/17.0f);
			const vec4 rad = tmp/4.0f+1.0/8.0f;
			const vec4 fpy =
				(cps1-t)*(cps1-t)
				+
				(itk_nsin3(vec4(ii)/NUM_METABALLS)+cps1)/cps2;
			const vec4 fpx = rad + (vec4(ii)/(NUM_METABALLS));

			METABALL_LOOP_BEGIN
			{
				const vec4 cx = x - NORM_METABALL_SIZE*0.5f;
				const vec4 cy = y - NORM_METABALL_SIZE*0.5f;
				const vec4 r = cx*cx+cy*cy;
				const vec4 val = max((rsqrt(r)-vec4(cps1)/(NORM_METABALL_SIZE/2.0f))/16.0f, cps0);

#if 0
				//My code working correctly?
				fbuffer[c].r = x/NORM_METABALL_SIZE;
				fbuffer[c].g = y/NORM_METABALL_SIZE;
				fbuffer[c].b = cps0;
#else
				fbuffer[c].r += val;
				fbuffer[c].g += val;
				fbuffer[c].b += val;
#endif
			}
			METABALL_LOOP_END
		}

		const vec4 s = 8.0f;
		FBUF_LOOP_BEGIN
		{
			vec4 cx = x*s+cps1d4;
			vec4 cy = (norm_height-y)*s+cps1d4;
			const vec4 val = (itk_nsin3(cx)+itk_nsin3(cy))*cps1d4+cps1d2;

			fbuffer[c].r = itk_abs(fbuffer[c].r) * val;
			fbuffer[c].g = itk_abs(fbuffer[c].g) * (cps1d4+val);
			fbuffer[c].b = itk_abs(fbuffer[c].b) * (cps1d4+val);
		}
		FBUF_LOOP_END
	}
};

struct metaball_roll
{
	const static uint scene_length = NUM_FPS*10;

	DRAW_FUNC_ATTRIB static void draw(uint frameCount)
	{
		{
			FBUF_LOOP_BEGIN
			{
				fbuffer[c].r = fbuffer[c].g = fbuffer[c].b = -1.0f;
			}
			FBUF_LOOP_END
		}

		const vec4 t =
			vec4(frameCount)/vec4(scene_length);

		for(uint ii=0; ii<NUM_METABALLS; ++ii)
		{
			//floatで計算してもいいけどできるだけ同じ命令を使い回したほうが圧縮されやすい.
			//正規化された座標系でのメタボールの位置.
			//How do you place and move metaballs?
		//	const vec4 fpy = cps0;//(vec4(ii)/NUM_METABALLS);
		//	const vec4 fpx = t.x*4.0f-1.0f + (vec4(ii)/(NUM_METABALLS));
			const vec4 fii = vec4(ii);
			const vec4 tmp = itk_ncos3(fii/17.0f);
			const vec4 angle = (t*t*tmp)*4.0f*itk_nsin3(vec4(ii)*cps1d2+cps1d4);
			const vec4 rad = tmp/4.0f+1.0/8.0f;
			const vec4 fpy = itk_nsin3(angle)*rad + (itk_nsin3(vec4(ii)/NUM_METABALLS)+cps1)/cps2;
			const vec4 fpx = itk_ncos3(angle)*rad + (vec4(ii)/(NUM_METABALLS));

			METABALL_LOOP_BEGIN
			{
				const vec4 cx = x - NORM_METABALL_SIZE*0.5f;
				const vec4 cy = y - NORM_METABALL_SIZE*0.5f;
				const vec4 r = cx*cx+cy*cy;
				const vec4 val = max((rsqrt(r)-vec4(cps1)/(NORM_METABALL_SIZE/2.0f))/16.0f, cps0);

#if 0
				//My code working correctly?
				fbuffer[c].r = x/NORM_METABALL_SIZE;
				fbuffer[c].g = y/NORM_METABALL_SIZE;
				fbuffer[c].b = cps0;
#else
				fbuffer[c].r += val;
				fbuffer[c].g += val;
				fbuffer[c].b += val;
#endif
			}
			METABALL_LOOP_END
		}

		const vec4 s = 8.0f+t*64.0f;//4.0f+cps1d4;
		FBUF_LOOP_BEGIN
		{
			vec4 cx = x*s+cps1d4;
			vec4 cy = (norm_height-y)*s+cps1d4;
			const vec4 val = (itk_nsin3(cx)+itk_nsin3(cy))*cps1d4+cps1d2;

			fbuffer[c].r =
				max(fbuffer[c].r, -1.0f)*t*t*16.0f + itk_abs(fbuffer[c].r) * val;
			fbuffer[c].g =
				max(fbuffer[c].g, -1.0f)*t*t*16.0f + itk_abs(fbuffer[c].g) * (cps1d4+val);
			fbuffer[c].b =
				max(fbuffer[c].b, -1.0f)*t*t*16.0f + itk_abs(fbuffer[c].b) * (cps1d4+val);
		}
		FBUF_LOOP_END
	}
};

//#define PURE_METABALL
#ifdef PURE_METABALL
#	define	THRESHOLD_C	512.0f
#endif
struct metaball_disappear
{
	const static uint scene_length = NUM_FPS*10;

	DRAW_FUNC_ATTRIB static void draw(uint frameCount)
	{
		{
			FBUF_LOOP_BEGIN
			{
				fbuffer[c].r = fbuffer[c].g = fbuffer[c].b =
#ifdef PURE_METABALL
					0.0f
#else
					-1.0f
#endif
					;
			}
			FBUF_LOOP_END
		}

		const vec4 t =
			vec4(frameCount)/vec4(scene_length);

		for(uint ii=0; ii<NUM_METABALLS; ++ii)
		{
			//floatで計算してもいいけどできるだけ同じ命令を使い回したほうが圧縮されやすい.
			//正規化された座標系でのメタボールの位置.
			//How do you place and move metaballs?
		//	const vec4 fpy = cps0;//(vec4(ii)/NUM_METABALLS);
		//	const vec4 fpx = t.x*4.0f-1.0f + (vec4(ii)/(NUM_METABALLS));
			const vec4 fii = vec4(ii);
			const vec4 tmp = itk_ncos3(fii/17.0f);
			const vec4 angle =
				((t+cps1)*(t+cps1)*tmp)*4.0f*itk_nsin3(vec4(ii)*cps1d2+cps1d4);
			const vec4 rad = tmp/4.0f+1.0/8.0f + t*t*4.0f;
			const vec4 fpy =
					itk_nsin3(angle)*rad
				+
					(itk_nsin3(vec4(ii)/NUM_METABALLS)+cps1)/cps2;
			const vec4 fpx = itk_ncos3(angle)*rad + (vec4(ii)/(NUM_METABALLS));

			METABALL_LOOP_BEGIN
			{
				const vec4 cx = x - NORM_METABALL_SIZE*0.5f;
				const vec4 cy = y - NORM_METABALL_SIZE*0.5f;
				const vec4 r = cx*cx+cy*cy;
				const vec4 val =
					max((rsqrt(r)-vec4(cps1)/(NORM_METABALL_SIZE/2.0f))/16.0f, cps0);

				fbuffer[c].r += val;
				fbuffer[c].g += val;
				fbuffer[c].b += val;
			}
			METABALL_LOOP_END
		}

		FBUF_LOOP_BEGIN
		{
			const vec4 x_proj = min(t*cps2, cps1)*(itk_fract(x)*cps2-cps1);
			const vec4 y_proj = max(t*cps2-cps1, cps0)*(itk_fract(y)*cps2-cps1);
			vec4 z = cps1-(itk_abs(cps1-(x_proj*x_proj)-(y_proj*y_proj)));
#ifdef PURE_METABALL
			fbuffer[c].r =
				select
				(
					fbuffer[c].r > vec4(cps1)/(NORM_METABALL_SIZE/2.0f)/THRESHOLD_C*NUM_METABALLS,
					1.0f, 0.0f
				);
			fbuffer[c].g =
				select
				(
					fbuffer[c].g > vec4(cps1)/(NORM_METABALL_SIZE/2.0f)/THRESHOLD_C*NUM_METABALLS,
					1.0f, 0.0f
				);
			fbuffer[c].b =
				select
				(
					fbuffer[c].b > vec4(cps1)/(NORM_METABALL_SIZE/2.0f)/THRESHOLD_C*NUM_METABALLS,
					1.0f, 0.0f
				);
#else
			fbuffer[c].r = max(fbuffer[c].r, cps0)*16.0f + z;
			fbuffer[c].g = max(fbuffer[c].g, cps0)*16.0f + z;
			fbuffer[c].b = max(fbuffer[c].b, cps0)*16.0f + z;
#endif
		}
		FBUF_LOOP_END
	}
};
//Add your cool scene class to this template class.
typedef
	boost::mpl::vector
	<
		plasma,
		plasma_wave,
		metaball_rise,
		metaball_roll,
		metaball_disappear
	>
	list;
}
}

#endif
