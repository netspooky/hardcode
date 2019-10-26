#version 420

#include "common.s"
#include "camera.s"
#include "distance_field.s"
#include "shadowmap.s"

uniform float sample_count;
layout(binding = 1) uniform sampler2DShadow shadowmap;

in vec3 vary_ray_dir;

out vec3 color;

void main()
{
//	vec2 pos = gl_FragCoord.xy/vec2(1080.0);
//	color = vec3(fract(pos), sin(sample_count*0.00001));

	float t = get_second(sample_count);

	vec3 ray_org	= is_shadowmap ? vary_ray_dir : get_cam_pos(t);
	mat3 viewmat	= get_view_mat(t, get_cam_pos(t));
	vec3 ray_dir	= is_shadowmap ? -viewmat[2] : normalize(vary_ray_dir);
	float x			= is_shadowmap ? 0.0 : length(vary_ray_dir);

	vec3 forward	= viewmat[2];

	color = vec3(-ray_dir.x, -ray_dir.y, ray_dir.z);
	gl_FragDepth = 0.9999;
	vec3 p = vec3(0.0);
	vec3 normal = vec3(0.0);
	material mtrl = material(vec3(0.0), vec3(0.0));
	for(int i=0; i<128; ++i)
	{
		p = ray_dir*x + ray_org;
		float dst = DF(p, t);
		if(dst < 0.001)
		{
			float z = x*dot(ray_dir, forward);
			//fragment shaderから出力される深度値は[0, 1]の範囲.
			//vertex shaderから出力されたz/wの範囲は[-1, 1].
			//pに射影行列を掛けてwで割って*1/2+1/2した値が深度値になる.
			if(is_shadowmap)
			{
				gl_FragDepth =
					clamp
					(
						-z/(SHADOWMAP_PROJ_FAR - SHADOWMAP_PROJ_NEAR),
						0.0,
						0.9999
					);
				return;
			}
			else
			{
				gl_FragDepth =
					clamp
					(
						(ZFAR+ZNEAR+2.0*ZFAR*ZNEAR/z)/(ZFAR-ZNEAR)*0.5 + 0.5,
						0.0,
						0.9999
					);
			}

			normal	= get_normal(p, t);
			mtrl	= get_material(p, t);
			break;
		}
		x += dst;
	}

	if(is_shadowmap)
		return;

	mat3 shadowmap_view_mat			= get_shadowmap_view_mat();
	vec3 shadowmap_light_dir		= shadowmap_view_mat[2];
	float dotln						= dot(shadowmap_light_dir, normal);

	vec3 shading = max(dotln, 0.0) * mtrl.diffuse;

	if(dotln > 0.0)
	{
		mat3 shadowmap_view_mat_trans	= transpose(shadowmap_view_mat);
		vec4 texcoord	=	shadowmap_projection*vec4(shadowmap_view_mat_trans*(p - get_shadowmap_light_pos()), 1.0);
		texcoord.xyz *= 0.5;
		texcoord.xyz += 0.5;
		texcoord.z -= 0.01;
		float shadow =
			textureProj
			(
				shadowmap,
				texcoord
			);
	//	if(texcoord.x < 1.0 && texcoord.x > 0.0 && texcoord.y < 1.0 && texcoord.y > 0.0)
	//		color *= 0.2;
	//	if(shadow < 1.0)
	//		color *= 0.2;
		color = shadow * shading + mtrl.ambient;
	}else
	{
		color = mtrl.ambient;
	}

	color *= 1.0 - max(gbl_begin(t), gbl_end(t));
}
