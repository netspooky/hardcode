varying vec3 Q,W,C,T,R,V,H;

void main()
{
	Q = gl_Normal;
	vec4 pos = gl_Vertex, col = gl_Color;
	C = col.xyz; //color, material, radius
	T = col.aaa; //time

	//T.x -= 5.94;

	// background flag T.z=1.0:
	T.z = step(8.0, pos.x*pos.x);

	// time, rotations:
	float t = T.x, 
		  beat = fract(t * 0.2805),
		  zoom = 6.0,
	      rot = 2.7*sin(t*0.3), //+1.2*fract(t*0.34),
		  sin_t=sin(rot),
		  cos_t=cos(rot);
	mat2x2 m = mat2x2(cos_t,sin_t, -sin_t,cos_t);

	if (85.8 < t)
		beat = 0.6*fract(beat * 2.0);

	 if (121.6 < t)
		beat = 0;

	// beat -> T.y:
	T.y = beat;
	H = T*0;

	if (14.6 < t)
		zoom += beat * 2.0;
	
	if (24.0 < t && t < 43.0 || 85.8 < t)
		++H.x;

	//Q = mix(Q,sign(Q),beat);
	// position += normal * radius:
	pos.xyz += Q * C.z;


	// wobble:
	if (0.5 < C.y)
	{
		//pos.xy = m * m * pos.xy;
		//pos.y += 0.01*sin(t+pos.x*90.0+pos.y*90.0);
		//pos.x += 0.01*cos(t+pos.x*90.0+pos.y*90.0);
		pos.xyz += 0.04*cos(t+pos.xzy*90.0+pos.yxz*90.0);
	}
	//pos.xyz = mix(pos.xyz, 0.05 * trunc(pos.xyz * 20.0), Q.x);
	// world position -> W:
	W = pos.xyz;
	
	// rotate position:
	//pos.xy = m * pos.xy;
	
	if (T.z < 0.5)
	{
		pos.xz = m * pos.xz;
		if (0.5 < H.x)
			pos.yz = m * pos.yz;
	}
	Q.xy = m * Q.xy;

	// view position -> R:
	R = W;
	R.z += zoom;

	// perspective:
	pos.xy *= 3.0 / R.z;

	// adjust z:
	pos.z *= 0.01;
	pos.z += T.z*0.8;

	// screen position -> V:
	V = pos.xyz;

	gl_Position = pos;
}

