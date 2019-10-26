#ifndef FROMPLANE2COLOR_SCENES_SIMPLE_HPP
#define FROMPLANE2COLOR_SCENES_SIMPLE_HPP

namespace scenes_simple
{
struct simple_anim
{
	const static uint scene_length = NUM_FPS*5;
	DRAW_FUNC_ATTRIB static void draw(uint frameCount)
	{
		const vec4 t =
			vec4(frameCount)/vec4(scene_length);

		FBUF_LOOP_BEGIN
		{
			const vec4 cx = x-norm_width_half;
			const vec4 cy = norm_height_half-y;
			const vec4 r = sqrt(cx*cx+cy*cy);
#if 1
			fbuffer[c].r = cps0;
			fbuffer[c].g = r*t;
			fbuffer[c].b = cps0;
#else
			const vec4 theta = itk_natan2_1(cy, cx);
			const vec4 v = itk_nsin3(r*cps8 + itk_nsin3(theta*16.0f)/8.0f);
			fbuffer[c].r = v;
			fbuffer[c].g = v;
			fbuffer[c].b = v;
#endif
		}
		FBUF_LOOP_END
	}
};

struct simple_anim_ring
{
	const static uint scene_length = NUM_FPS*5;
	DRAW_FUNC_ATTRIB static void draw(uint frameCount)
	{
		const vec4 t =
			vec4(frameCount)/vec4(scene_length);

		FBUF_LOOP_BEGIN
		{
			const vec4 cx = x-norm_width_half;
			const vec4 cy = norm_height_half-y;
			const vec4 r = sqrt(cx*cx+cy*cy);

			fbuffer[c].r = cps0;
			fbuffer[c].g = r*(cps1-t) + itk_nsin3(r*cps8)*t;
			fbuffer[c].b = cps0;
		}
		FBUF_LOOP_END
	}
};

struct simple_anim_ring_giza
{
	const static uint scene_length = NUM_FPS*5;
	DRAW_FUNC_ATTRIB static void draw(uint frameCount)
	{
		const vec4 t =
			vec4(frameCount)/vec4(scene_length);

		FBUF_LOOP_BEGIN
		{
			const vec4 cx = x-norm_width_half;
			const vec4 cy = norm_height_half-y;
			const vec4 r = sqrt(cx*cx+cy*cy);
			const vec4 rad = itk_natan2_1(cy, cx)+t*cps1d4;

			const vec4 gz_r = itk_nsin3(rad*cps16)*cps1d4*t;

			fbuffer[c].r = cps0;
			fbuffer[c].g = itk_nsin3(r*cps8+gz_r);
			fbuffer[c].b = cps0;
		}
		FBUF_LOOP_END
	}
};

typedef
	boost::mpl::vector
	<
		simple_anim,
		simple_anim_ring,
		simple_anim_ring_giza
	>
	scenes_simple_list;
}

#endif
