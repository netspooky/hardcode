float cur_time;

// The distance function
float DF(vec3 pos)
{
	return 
		mix(0.4, 0.2, cos(cur_time*200)) +
		cos(pos.x * 6 + cos(5 - pos.y*7) * 3) *
		cos(pos.y * 3 + cos( + pos.z*6) * 2) *
		cos(pos.z * 4 + cos(pos.x*8) * 2);
}

void main()
{
	cur_time = gl_Color.x;

	vec2 rel_pos = (gl_FragCoord.xy / 1000 - vec2(0.5,0.35))*75*cur_time;

	// Init the camera
	vec3 up = vec3(0,1,0);
	vec3 cam_pos = up.xxx;

	vec3 cam_z = vec3(cos(cur_time*20), 0, sin(cur_time*20));
	vec3 cam_x = cross(up,cam_z);
	vec3 cam_y = cross(cam_x,cam_z);
	vec3 ray_dir = ((cam_x*rel_pos.x)+(cam_y*rel_pos.y)+(cam_z));

	// Trace the ray
	float step_mul = 0.01 + smoothstep(0.5, 1, cur_time) * 0.05;
	float illum;

	float d;
	int i = 0; while (i++ < 100)
	{
		// Get the distance
		d = DF(cam_pos) * step_mul;

		illum += d;
		cam_pos += d*ray_dir;
	}

	// Get the normal
	vec3 n = (vec3(
		DF(cam_pos+up.yxx)-d,
		DF(cam_pos+up.xyx)-d,
		DF(cam_pos+up.xxy)-d));

	gl_FragColor = vec4(
		illum * cos(atan(n.z, n.y)) * cur_time * 2,
		illum * mix(1, cos(atan(n.x, n.z)), cur_time * 0.2),
		illum * cos(atan(n.y, n.x)) * (cur_time - 0.5),
		1);
}
