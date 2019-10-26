#ifndef FROMPLANE2COLOR_SCENES_TRANSFORM_HPP
#define FROMPLANE2COLOR_SCENES_TRANSFORM_HPP

namespace scenes
{
namespace transform
{

#define PLANE_HEIGHT cps2

struct screen2planes
{
	const static uint scene_length = NUM_FPS*10;
	DRAW_FUNC_ATTRIB static void draw(uint frameCount)
	{
		const vec4 t =
			vec4(frameCount)/vec4(scene_length);

		FBUF_LOOP_BEGIN
		{
			const vec4 cx = x-norm_width_half;
			const vec4 cy = norm_height_half-y;

			const vec4 rate = itk_abs(PLANE_HEIGHT/cy);
			const vec4 planes_x = rate*cx;
			const vec4 planes_y = rate;
			vec4 anim_t = t*t;
			anim_t *= anim_t;
			vec4 smpl_x = x*(cps1-anim_t) + planes_x*anim_t;
			vec4 smpl_y = y*(cps1-anim_t) + planes_y*anim_t;
			const vec4 x_proj = (itk_fract(smpl_x)*cps2-cps1);
			const vec4 y_proj = (itk_fract(smpl_y)*cps2-cps1);
			vec4 z = cps1-(itk_abs(cps1-(x_proj*x_proj)-(y_proj*y_proj)));

			fbuffer[c].r = z;
			fbuffer[c].g = z;
			fbuffer[c].b = z;
		}
		FBUF_LOOP_END
	}
};

struct planes2tunnel
{
	const static uint scene_length = NUM_FPS*10;
	DRAW_FUNC_ATTRIB static void draw(uint frameCount)
	{
		const vec4 t =
			vec4(frameCount)/vec4(scene_length);

		FBUF_LOOP_BEGIN
		{
			const vec4 cx = x-norm_width_half;
			const vec4 cy = norm_height_half-y;

			const vec4 rate = itk_abs(PLANE_HEIGHT/cy);
			const vec4 planes_x = rate*cx;
			const vec4 planes_y = rate;
			const vec4 tunnel_x = itk_natan2_1(cy, cx)*8.0f;
			const vec4 tunnel_y = rsqrt(cx*cx+cy*cy)*2.0f;
			vec4 anim_t = t;
			vec4 smpl_x = planes_x*(cps1-anim_t) + tunnel_x*anim_t;
			vec4 smpl_y = planes_y*(cps1-anim_t) + tunnel_y*anim_t;
			const vec4 x_proj = (itk_fract(smpl_x)*cps2-cps1);
			const vec4 y_proj = (itk_fract(smpl_y)*cps2-cps1);
			vec4 z = cps1-(itk_abs(cps1-(x_proj*x_proj)-(y_proj*y_proj)));

			fbuffer[c].r = z;
			fbuffer[c].g = z;
			fbuffer[c].b = z;
		}
		FBUF_LOOP_END
	}
};

struct tunnel
{
	const static uint scene_length = NUM_FPS*10;
	DRAW_FUNC_ATTRIB static void draw(uint frameCount)
	{
		const vec4 t =
			vec4(frameCount)/vec4(scene_length);

		FBUF_LOOP_BEGIN
		{
			const vec4 cx = x-norm_width_half;
			const vec4 cy = norm_height_half-y;

			const vec4 tunnel_x = itk_natan2_1(cy, cx)*8.0f;
			const vec4 tunnel_y = rsqrt(cx*cx+cy*cy)*(2.0f+t*t*1.0f*itk_nsin3(tunnel_x));
			vec4 smpl_x = tunnel_x;
			vec4 smpl_y = tunnel_y;
			const vec4 x_proj = (itk_fract(smpl_x)*cps2-cps1);
			const vec4 y_proj = (itk_fract(smpl_y)*cps2-cps1);
			vec4 z = cps1-(itk_abs(cps1-(x_proj*x_proj)-(y_proj*y_proj)));

			fbuffer[c].r = z;
			fbuffer[c].g = z;
			fbuffer[c].b = z;
		}
		FBUF_LOOP_END
	}
};
//Add your cool scene class to this template class.
typedef
	boost::mpl::vector
	<
		screen2planes,
		planes2tunnel,
		tunnel
	>
	list;
}
}

#endif
