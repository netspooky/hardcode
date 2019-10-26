#ifndef FROMPLANE2COLOR_SCENES_HINOMARU_HPP
#define FROMPLANE2COLOR_SCENES_HINOMARU_HPP

namespace scenes
{
namespace hinomaru
{
#define HINOMARU_RADIUS (9.0f/100.0f)
#define HINOMARU_HIZASHI_SCALE 16.0f
#define HINOMARU_HIZASHI_GRAD 8.0f
struct rising
{
	const static uint scene_length = NUM_FPS*5;
	DRAW_FUNC_ATTRIB static void draw(uint frameCount)
	{
		const vec4 t =
			vec4(frameCount)/vec4(scene_length)
			*cps2 - cps1;
		const vec4 w = t+cps1;
		const vec4 maru = cps1-itk_abs(t);

		FBUF_LOOP_BEGIN
		{
			const vec4 cx = x-norm_width_half;
			const vec4 cy = norm_height_half-y;
			const vec4 r = cx*cx+cy*cy;
			const vec4 gb = select(r<HINOMARU_RADIUS , maru, w);
			fbuffer[c].r = w;
			fbuffer[c].g = gb;
			fbuffer[c].b = gb;
		}
		FBUF_LOOP_END
	}
};

struct hizashi
{
	const static uint scene_length = NUM_FPS*10;
	DRAW_FUNC_ATTRIB static void draw(uint frameCount)
	{
		const vec4 t =
			vec4(frameCount)/vec4(scene_length)
			*cps2 - cps1;
	//	const vec4 w = t+1.0f;
	//	const vec4 maru = 1.0f-itk_abs(t);

		FBUF_LOOP_BEGIN
		{
			const vec4 cx = x-norm_width_half;
			const vec4 cy = norm_height_half-y;
			vec4 rad = itk_natan2_1(cy, cx);
			rad =
				(
					itk_fract
					(
						rad*(t*HINOMARU_HIZASHI_SCALE+HINOMARU_HIZASHI_SCALE)
					)-cps1d2
				)
				*HINOMARU_HIZASHI_GRAD*t;
			vec4 r = cx*cx+cy*cy;
			vec4 gb = select(r<HINOMARU_RADIUS, cps0, rad);
			fbuffer[c].r = cps1;
			fbuffer[c].g = gb;
			fbuffer[c].b = gb;
		}
		FBUF_LOOP_END
	}
};

struct hizashi_rotating
{
	const static uint scene_length = NUM_FPS*10;
	DRAW_FUNC_ATTRIB static void draw(uint frameCount)
	{
		const vec4 t =
			vec4(frameCount)/vec4(scene_length)
			-cps1;//*cps2 - 1.0f;
	//	const vec4 w = t+1.0f;
	//	const vec4 maru = 1.0f-itk_abs(t);

		FBUF_LOOP_BEGIN
		{
			const vec4 cx = x-norm_width_half;
			const vec4 cy = norm_height_half-y;
			const vec4 r = cx*cx+cy*cy;
			vec4 rad = itk_natan2_1(cy, cx);
			rad *= r*itk_nsin3(-t*t*cps2+cps2)+cps1;
			rad =
				(
					itk_fract
					(
						rad*(HINOMARU_HIZASHI_SCALE+HINOMARU_HIZASHI_SCALE)
					)-cps1d2
				)
				*HINOMARU_HIZASHI_GRAD;
			vec4 gb = select(r<HINOMARU_RADIUS, cps0, rad);
			fbuffer[c].r = cps1;
			fbuffer[c].g = gb;
			fbuffer[c].b = gb;
		}
		FBUF_LOOP_END
	}
};

struct hizashi_tiling
{
	const static uint scene_length = NUM_FPS*10;
	DRAW_FUNC_ATTRIB static void draw(uint frameCount)
	{
		const vec4 t =
			vec4(frameCount)/vec4(scene_length)
			;//*cps2 - 1.0f;
	//	const vec4 w = t+1.0f;
	//	const vec4 maru = 1.0f-itk_abs(t);

		const vec4 s = t*t*64.0f+cps1;
		const vec4 angle = (itk_abs(t))/*1.0f*/;
		const vec4 rot_x = itk_ncos3(angle);
		const vec4 rot_y = itk_nsin3(angle);
		FBUF_LOOP_BEGIN
		{
			const vec4 rx = x*rot_x - (norm_height-y)*rot_y;
			const vec4 ry = x*rot_y + (norm_height-y)*rot_x;
			vec4 cx = rx/norm_width*s;
			vec4 cy = ry/norm_height*s;

			const vec4 offset_x = -vec4(norm_width_half);
			const vec4 offset_y = -vec4(norm_height_half);
			cx = itk_abs(itk_fract(cx))*norm_width + offset_x;
			cy = itk_abs(itk_fract(cy))*norm_height + offset_y;
			vec4 r = cx*cx+cy*cy;
			vec4 rad = itk_natan2_1(cy, cx);
			rad =
				(
					itk_fract
					(
						rad*(HINOMARU_HIZASHI_SCALE+HINOMARU_HIZASHI_SCALE)
					)-cps1d2
				)
				*HINOMARU_HIZASHI_GRAD;
			vec4 gb = select(r<HINOMARU_RADIUS, cps0, rad);
			gb = gb*(cps1-t)+cps1d4*t;
#if 1
			fbuffer[c].r = cps1;
			fbuffer[c].g = gb;
			fbuffer[c].b = gb;
#else
			fbuffer[c].r = cx;
			fbuffer[c].g = cy;
			fbuffer[c].b = 0;
#endif
		}
		FBUF_LOOP_END
	}
};

#if 0
struct hizashi_wave
{
	const static uint scene_length = NUM_FPS*5;
	DRAW_FUNC_ATTRIB static void draw(uint frameCount)
	{
		const vec4 t =
			vec4(frameCount)/vec4(scene_length)
			;//*cps2 - 1.0f;
	//	const vec4 w = t+1.0f;
	//	const vec4 maru = 1.0f-itk_abs(t);

		FBUF_LOOP_BEGIN
		{
			vec4 cx = x-norm_width_half;
			vec4 cy = norm_height_half-y;
			vec4 r = cx*cx+cy*cy;
			vec4 rad = itk_natan2_1(cy, cx);
			rad += itk_nsin3(sqrt(r)*8.0f)*t*(1.0f/128.0f);
			rad =
				(
					itk_fract
					(
						rad*(HINOMARU_HIZASHI_SCALE+HINOMARU_HIZASHI_SCALE)
					)-cps1d2
				)
				*HINOMARU_HIZASHI_GRAD;
			vec4 gb = select(r<HINOMARU_RADIUS, cps0, rad);
			fbuffer[c].r = 1.0f;
			fbuffer[c].g = gb;
			fbuffer[c].b = gb;
		}
		FBUF_LOOP_END
	}
};

struct hizashi_wave_tunnelize
{
	const static uint scene_length = NUM_FPS*20;
	DRAW_FUNC_ATTRIB static void draw(uint frameCount)
	{
		const vec4 t =
			vec4(frameCount)/vec4(scene_length)
			;//*cps2 - 1.0f;
	//	const vec4 w = t+1.0f;
	//	const vec4 maru = 1.0f-itk_abs(t);

		FBUF_LOOP_BEGIN
		{
			vec4 cx = x-norm_width_half;
			vec4 cy = norm_height_half-y;
			vec4 r = cx*cx+cy*cy;
			vec4 rad = itk_natan2_1(cy, cx);
			vec4 len = sqrt(r);
			len = len*(1.0f-t)+cps2/len*t;
			rad += itk_nsin3(len*8.0f+t*8.0f)*(1.0f/128.0f);
			rad =
				(
					itk_fract
					(
						rad*(HINOMARU_HIZASHI_SCALE+HINOMARU_HIZASHI_SCALE)
					)-cps1d2
				)
				*HINOMARU_HIZASHI_GRAD;
			vec4 gb = select(r<HINOMARU_RADIUS, cps0, rad);
			fbuffer[c].r = 1.0f;
			fbuffer[c].g = gb;
			fbuffer[c].b = gb;
		}
		FBUF_LOOP_END
	}
};
#endif

//Add your cool scene class to this template class.
typedef
	boost::mpl::vector
	<
		rising,
		hizashi,
		hizashi_rotating,
		hizashi_tiling
	//	hizashi_wave,
	//	hizashi_wave_tunnelize
	>
	list;

#undef HINOMARU_RADIUS
#undef HINOMARU_HIZASHI_SCALE
#undef HINOMARU_HIZASHI_GRAD
}
}

#endif
