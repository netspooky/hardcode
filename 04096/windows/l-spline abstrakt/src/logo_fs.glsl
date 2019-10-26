uniform sampler2D U;
varying vec3 Q,W,C,T,R,V,H;





void main()
{
	vec3 lv = W-vec3(0.5, 0.4*sin(T.x * 2.5), 1.0);
	float t = T.x, nn = 0, beat = T.y;
	
	// light:
	vec4 fg = vec4(3.04 * max(0,dot(Q, normalize(lv))) / (3.0*dot(lv,lv)+0.2) + 1.3*pow(1.0 - abs(dot(normalize(R),Q)),  9.0));

	// color:
	fg.yz *= C.x;

	// bkg:
	if (0.5 < T.z)
	{
		// blur:
		fg*=0;
		while (++nn < 46.1)
		{
			fg += texture2D(U,V.xy*0.5-0.5 + 0.00024*nn*vec2(cos(nn*0.1),sin(nn*0.1)) );
			//fg = max(fg, smp) + fg*0.01;
		}
		fg *= 0.017;
		
		// extra blur effect:
		if (H.x > 0.5)
			fg *= 1.2;

		// color effect:
		fg.x*=sin(t*3.2);

		// ground effect:
		if (V.y < -0.3)
		{
			vec2 gp = V.xy / (-V.y+0.5);

			nn = max(0, sin(gp.y*160.0) * max(0, sin(gp.x*60.0-t*3.0)));
			
			//nn *= sin(gp.y*(60.0*(1.0-beat)) + gp.x*60.0 + t);

			if (H.x < 0.5)
				nn *= max(0,sin(gp.x * 10.0 + sin(gp.y * (60.0 * (1.0-beat)))));
				//nn *= abs(sin(gp.x * 60.0 + sin(gp.y * (60.0 * (1.0-beat)))));

			fg += nn * (0.1+(1.0-beat*beat));

			fg.yz*=0.7;
		}
		else if (0.5 < H.x)
		{
			vec2 gp = V.xy-vec2(0.1, 0.8-t*0.01);
			fg += 0.003 / dot(gp, gp);
		}
		if (0.99 < V.y)
			fg *= 0;
	}

	// noise:
	beat = step(beat, 0.2)*sin(beat*62.4)*0.2;
	fg.yz -= beat * abs(sin(V.y*780.0)) - 0.02;

	if (43.0 < t && t < 69.0 && beat > 0.02)
	{
		fg = vec4(1.0) - fg;
		fg.x = 0;
	}

	gl_FragColor = fg * min(1.0, 62.3 - t*0.5);
}

