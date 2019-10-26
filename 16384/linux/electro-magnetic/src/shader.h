static const char GLSLX_SOURCE_MAIN[] = R"(
#version 130

	uniform vec3 u_colo;
	uniform float u_prog;
	uniform float u_time;
	uniform float u_songpos;
	uniform sampler2D u_lastwave;
	uniform sampler2D u_noise;
    uniform sampler2D u_text;


vec3 trace_rott(vec2 pixpos, vec2 ro, vec2 rd, float ang)
{
    vec2 pos = floor(ro);
    vec3 c = vec3(0.0);

	vec2 delta = 1.0 / abs(rd);
    
    vec2 maxx = pos - ro;
    vec2 stepx = sign(rd);
    maxx += max(stepx, vec2(0.0));
   // if (rd.x >= 0.0) maxx.x+=1.0;
   // if (rd.y >= 0.0) maxx.y+=1.0;
    maxx /= rd;
    
    
    float tf = u_time * 0.0;
    
    vec3 wallcolc = vec3(0.0);
    for (int i = 0; i < 63; i++)
    {
        vec2 megatrick = vec2(1.0, 0.0);
//        if (maxx.x > maxx.y) megatrick = vec2(0.0, 1.0);
        megatrick = step(maxx.xy, maxx.yx);

        maxx += delta * megatrick;
        pos += stepx * megatrick;
        
        vec2 ff = pos;

        vec2 pvd = (pos - ro + (vec2(1.0) - stepx) / 2.0) / rd;
        float pvd_s = 0.0;
        
        pvd_s = dot(pvd * megatrick, vec2(1.0)) * 1.0;
        
        
        ff = ro + rd * pvd_s;

        if (length(floor(pos - vec2(15.0))) > (24.0 + sin(pos.x * 0.3412+tf) * 9.0 + sin(pos.y * 0.55213) * 9.0))
       {
//                 mat3 colmtx = mat3(0.1,0.5,0.7, 0.7,0.6,0.9, 0.9,0.3,0.6);
//       	    vec3 wallcol = megatrick.yxx * colmtx;

        float ld = dot(megatrick.xy * stepx.xy, normalize(ff - vec2(15.0)));
        vec3 wallcol = vec3(0.2, 0.6, 0.3) * ld;

           
                       
            float dfc = length(pos - vec2(15.0));

            float hf = -8.0 + pow(dfc, 1.0) * 0.6;
           hf += sin(dfc * 0.9 + u_songpos * 1.0 * 3.14159);
//           hf += mod(u_songpos * 4.0, 1.0);
            hf = max(3.0, hf);
            if (dfc > 30.0)
                hf = 12.8;

            vec2 uvj;
            uvj.y = -pixpos.y * pvd_s + hf * 2.0;
            uvj.x = dot(megatrick * ff.yx, vec2(1.0));
//            wallcol *= 0.7;
            wallcol *= pow(texture2D(u_noise, uvj * 0.1).b, 2.0) * 3.0;
            wallcol *= 1.0 - pow(abs(fract(dot(ff, stepx)) - 0.5) * 2.0, 4.0);
            
            float h = (1.6/pvd_s);

            wallcol *= (smoothstep(4.0, 8.0, u_songpos)*29.0 + 10.0)*30.0 / (pvd_s * pvd_s);
            //float hf = 8.8;

            if (i > 50 && abs(-pixpos.y- (h * 2.0)) > (h*12.8))
            {
                wallcol = vec3(0.1,0.6, 0.7); 

                vec4 nsampled = texture2D(u_noise, vec2(-ang * 6.0, pixpos.y) * 0.1);
                float wc = pow(nsampled.r, 19.0);
                wallcol = wc * vec3(3.0, 1.8, 2.1) * (0.8 + sin(u_time * 5.999 + nsampled.g * 5.9) * 0.2);
//                wallcol = texture2D(u_lastwave, pixpos).rgb * 0.01;
            }
            else if (abs(-pixpos.y- (h * 2.0)) < (h*hf))
            {
                wallcol *= vec3(abs(-pixpos.y - (h * 2.0))) * 0.2 + 0.5;
            }
            else
            {
                continue;
            }
            
            wallcolc = wallcol;
            
            if (-pixpos.y < (h * 2.0) ||  -pixpos.y < 0.0)
       		 {
                 c.rgb = wallcolc;
       		 }
            else if (-pixpos.y > 0.0)
                c.rgb = vec3(0.3,0.4, 0.8) * (20.0/dfc) + wallcolc * 0.2;

               break;

        }
    }
    
    //if (dot(rd, normalize(pixpos-ro)) > 0.99)
    //    c += vec4(0.4,0.1,0.1,0.0);

    return c;
}



vec3 trace_cyber(vec2 pixpos, vec2 ro, vec2 rd)
{
	vec2 pos = floor(ro);
	vec3 c = vec3(0.0);

	vec2 delta = 1.0 / abs(rd);
	
	vec2 maxx = pos - ro;
	if (rd.x >= 0.0) maxx.x+=1.0;
	if (rd.y >= 0.0) maxx.y+=1.0;
	maxx /= rd;
	maxx += vec2(3.0);
	
	vec2 stepx = sign(rd);
	
	float dodot_old = 1.0;
	vec2 pos_old = vec2(10000.0);
	
	float thix = 1.0;
	
	for (int i = 0; i < 20; i++)
	{
		vec2 megatrick = vec2(1.0, 0.0);
//        if (maxx.x > maxx.y) megatrick = vec2(0.0, 1.0);
		megatrick = step(maxx.xy, maxx.yx);

		maxx += delta * megatrick;
		pos += stepx * megatrick;
		
		vec2 ff = pos;

		vec2 pvd = (pos - ro + (vec2(1.0) - stepx) / 2.0) / rd;
		float pvd_s = 0.0;
		
		pvd_s = dot(pvd * megatrick, vec2(1.0)) * 1.0;
		
		
		ff = ro + rd * pvd_s;

		float dodot = length(ff - pixpos);
		if (dodot_old < 0.1)
		{
			c = vec3(0.9,0.9, 0.8);
			break;
		}
		
		thix = max(0.0, 2.0 - dodot_old * 2.0);
		thix += max(0.0, 2.0 - dodot * 2.0);
		
		dodot_old = dodot;
		
		if (floor(pos_old) == floor(pixpos))
		{
			c *= 0.1;
			c += vec3(0.4, 0.5, 0.3) * 1.0;
			break;
		}
		pos_old = pos;

		for (float muli = 0.0; muli < 15.0; muli += 1.0)
		{
			float muli2 = 1.0 / (muli * 1.0 + 1.0);// + pow(muli, 2.0) * 0.05;
		if (floor(pos * muli2) == floor(pixpos * muli2))
		{
			c += vec3(0.4, 0.5, 0.7) * 0.009;
		}
		}
			   
   

		/*
		if (maxx.x < maxx.y)
		{
			maxx.x += delta.x;
			pos.x += step.x;
		}
		else
		{
			maxx.y += delta.y;
			pos.y += step.y;
		}
		*/
	}
	
	//if (dot(rd, normalize(pixpos-ro)) > 0.99)
	//    c += vec4(0.4,0.1,0.1,0.0);

	   float as = step(0.0, dot(rd.xy, (pixpos-ro)));

   float vd = abs(dot(rd.yx * vec2(-1.0, 1.0), (pixpos-ro))) / thix;
	if (vd < 0.05)
		c += vec3(0.4,0.1,0.1) * as;
	if (vd < 0.2)
		c += vec3(0.4,0.1,0.1) * as;
	

	c += fract(pixpos.y / 4.0) * 0.1;
/*	c += texture2D(iChannel1, pixpos / 4.0) * 0.1 - 0.02;
	c *= texture2D(iChannel0, pixpos / 16.0 + vec2(u_time * 0.05, 0.0)) * 0.3 + 0.9;
	c *= texture2D(iChannel0, pixpos / 8.0 + vec2(u_time * 0.02, 0.0)) * 0.3 + 0.9;
*/	

	return c;
}


vec3 trace_3ddda(vec3 ro, vec3 rd)
{
    vec3 c = vec3(0.0);
    float fog = (0.0);

    vec3 pos = floor(ro);
    vec3 delta = vec3(1.0) / abs(rd);
    vec3 maxx = pos - ro;
    vec3 stepx = sign(rd);
    maxx += max(stepx, vec3(0.0));
    maxx /= rd;
    
    vec3 er_pos;
    vec3 er_delta;
    vec3 er_maxx;
    vec3 er_stepx;
    int raymode=0;
    
    vec3 c_ro = ro;
    vec3 c_rd = rd;
    
    float last_pvds = 0.0;
    float last_pvds2 = 0.0;
    
    float tf = 5.2 + u_time * 0.0;
    vec3 lspos = vec3(15.0, 15.0,15.0);
    lspos.x += cos(u_time) * 0.0;
    
    float pulse = 0.5 + sin(u_time * 1.0) * 0.05;
    
    float lightdist;
    float last_valofac;

    for (int i = 0; i < 2024; i++)
    {
        vec3 megatrick = vec3(0.0);
        megatrick = step(maxx.xyz, maxx.yxy) * step(maxx.xyz, maxx.zzx);

        maxx += delta * megatrick;
        pos += stepx * megatrick;
        
        vec3 pvd = (pos - c_ro + (vec3(1.0) - stepx) / 2.0) / c_rd;
        float pvd_s = 0.0;
        
        pvd_s = dot(megatrick, pvd);
       

        
        vec3 posmid = pos-vec3(15.0);
        float pml = length(posmid);
        
        float hitti = 0.0;
        if (pml > 28.0)
        {
            hitti = 1.0;
        }
        
        if (pml > 11.0 && pml < 12.0 && sin(tf+dot(posmid, vec3(8.4234, 8.6346, 7.3423))) < 0.0 )
        {
            hitti = 2.0;
        }

        if (pml > 4.0 && pml < 5.0 && sin(tf+dot(posmid, vec3(8.4234, 8.6346, 7.3423))) < -0.8 )
        {
            hitti = 2.0;
        }
        
        
        if (raymode == 0)
        {
            last_pvds2 = last_pvds;
            last_pvds = pvd_s;
            float rnd = fract(sin(u_time*42.5612323+pvd_s * 24.23)) * 0.1;
            vec3 ff = c_ro + c_rd * ((last_pvds + last_pvds2) * 0.5 + rnd);

            vec3 lv = lspos - ff;
            lightdist = length(lv);
            lv /= lightdist;
            
            if (hitti > 0.5)
            {
                float ls = max(0.0, -dot(megatrick * stepx, lv));
                c = vec3(3.0 / pow(pvd_s, 0.5));
                c = c * 0.0 + dot(c, vec3(1.0)) * vec3(1.0, 0.6, 0.2) * 0.1 * ls;
                //c = vec3(1.0, 0.6, 0.2) * 0.6 * ls;
                c *= last_valofac;
                //c += texture2D(iChannel0, ff.xy).rgb * (hitti - 1.0) * 0.3;
                c += fog * vec3(1.0, 0.9, 0.8) * pulse;
                break;
            }

            

            er_pos = pos;
            er_delta = delta;
            er_maxx = maxx;
            er_stepx = stepx;
            raymode = 1;
          
            c_ro = ff;
            c_rd = lv;


            pos = floor(c_ro);
            delta = vec3(1.0) / abs(c_rd);
            maxx = pos - c_ro;
            stepx = sign(c_rd);
            maxx += max(stepx, vec3(0.0));
            maxx /= c_rd;        
        }
        else if (raymode == 1)
        {
            bool valoonosui = false;
            if (pvd_s > lightdist)
            {
                fog += abs(last_pvds2 - last_pvds) / pvd_s; 
                valoonosui = true;
            }

            if (hitti > 0.5 || valoonosui)
            {
                last_valofac = valoonosui ? 1.0 : 0.8;
                pos = er_pos;
                delta = er_delta;
                maxx = er_maxx;
                stepx = er_stepx;
                raymode = 0;
                c_ro = ro;
                c_rd = rd;
            }
        }
        
        
    }

    return c;
}




vec3 decode2d(vec2 uv2d)
{
    float linearpos = uv2d.y * 512.0 + uv2d.x;
    
    vec3 pos = vec3(0.0);
    //pos.xy = uv2d / 512.0;
    pos.x = mod(linearpos, 64.0);
    linearpos = (linearpos - pos.x) / 64.0;
    pos.y = mod(linearpos, 64.0);
    linearpos = (linearpos - pos.y) / 64.0;
    pos.z = mod(linearpos, 64.0);
    
    return pos;
}

vec2 encode2D(vec3 pos)
{
    pos.y -= 4.0;
    float linearpos = (pos.z * 64.0 + pos.y) * 64.0 + pos.x;
    
    vec2 uv;
    uv.x = mod(linearpos, 512.0);
    linearpos = (linearpos - uv.x) / 512.0;
    uv.y = mod(linearpos, 512.0);
    
    return uv;
}

vec4 volumesampling(vec3 pos)
{
    pos = floor(pos);
    vec2 tuv = (encode2D(pos) + vec2(0.5)) / vec2(512.0);
    return texture2D(u_lastwave, tuv);
}



vec3 tracepb(vec3 ro, vec3 rd)
{
    vec3 c = vec3(0.0);
    float fog = (0.0);

    vec3 pos = floor(ro);
    vec3 delta = vec3(1.0) / abs(rd);
    vec3 maxx = pos - ro;
    vec3 stepx = sign(rd);
    maxx += max(stepx, vec3(0.0));
    maxx /= rd;

    float last_pvds = 0.0;
    float last_pvds2 = 0.0;
    for (int i = 0; i < 128; i++)
    {
        vec3 megatrick = vec3(0.0);
        megatrick = step(maxx.xyz, maxx.yxy) * step(maxx.xyz, maxx.zzx);

        maxx += delta * megatrick;
        pos += stepx * megatrick;
        
        vec3 pvd = (pos - ro + (vec3(1.0) - stepx) / 2.0) / rd;
        float pvd_s = 0.0;
        
        pvd_s = dot(megatrick, pvd);
       
        
        vec3 pos2 = pos;
        //pos2 = clamp(pos2, vec3(0.0), vec3(63.0));
        //pos2 = mod(pos2, vec3(64.0));
        
        float ehh = min(min(pos2.x, pos2.y), pos2.z);
        vec3 pos22 = vec3(63.0) - pos2;
        ehh = min(ehh,min(min(pos22.x, pos22.y), pos22.z));
        if (ehh < 0.0)
            continue;
        
        vec2 tuv = (encode2D(pos2) + vec2(0.5)) / vec2(512.0);
        vec4 hc = texture2D(u_lastwave, tuv);
        
        //vec3 hc = vec3(0.0);
        //if (length(pos2 - vec3(15.0)) < 14.0)
            //hc = vec3(1.0);
        

        
        last_pvds2 = last_pvds;
        last_pvds = pvd_s;
        //float rnd = fract(sin(iGlobalTime*42.5612323+pvd_s * 24.23)) * 0.1;
          vec3 ff = ro + rd * ((last_pvds + last_pvds2) * 0.5);
            
         //if (length(hc) > 0.1)
            //{
              //  return hc;
            //}
        fog += length(hc.rg) * 0.1 * abs(last_pvds2 - last_pvds) / pvd_s;
        
        if (hc.a> 0.2)
        {
            c = vec3(0.3, 0.2, 0.4);
            vec3 pos2 = pos + megatrick * stepx;
            vec2 tuv = (encode2D(pos2) + vec2(0.5)) / vec2(512.0);
            vec4 hc = texture2D(u_lastwave, tuv);
            c *= length(hc.rg) * 1.0;
            break;
        }
    }
    
    //c = vec3(0.1, 0.2, 0.9);
    return c + fog * 10.0 * vec3(1.0, 0.9, 0.8);
}

            













vec2 getcomplex(ivec2 c)
{
    return texelFetch(u_lastwave, c, 0).rg;
}

	void main()
	{
		vec2 reso = vec2(640.0, 480.0);
		vec2 fboreso = vec2(512.0, 512.0);
			vec3 col = vec3(0.0);
            float a = 1.0;

		vec2 uv = gl_FragCoord.xy / reso;
		vec2 uv2 = (uv - vec2(0.5)) * 2.0 * reso / reso.x;

        vec2 uvfbo = gl_FragCoord.xy / fboreso;

        float realprog = u_prog;

        if (u_prog > 199.5)
        {
            float valomix = u_songpos - 36.0;
            valomix *= 1.3;
            //valomix += sin(u_songpos * 7.342) * 0.5 - 0.5;
            float pas = uv2.x + uv2.y;
            valomix *= 1.3+sin(floor(pas * 5.0) * 1.42) * 0.3;
            realprog = 106.0;
            if (valomix > (uv2.x-uv2.y+2.0))
                realprog = 100.0;
        }


        // PROG_WAVEMAP
		if (realprog < 0.5)
		{
//			gl_FragColor = vec4(u_colo, 1.0);

			ivec2 fc = ivec2(gl_FragCoord.xy);

    vec2 c;


//    vec2 cmid = getcomplex(fc);

    vec3 midi = texelFetch(u_lastwave, fc, 0).rgb;

    vec2 cmid = midi.rg;

			vec2 c1 = getcomplex(fc + ivec2(-1, 0));
            vec2 c2 = getcomplex(fc + ivec2( 1, 0));
            vec2 c3 = getcomplex(fc + ivec2( 0,-1));
            vec2 c4 = getcomplex(fc + ivec2( 0, 1));

    vec2 c14 = getcomplex(fc+ivec2(-1, -1));
    vec2 c24 = getcomplex(fc+ivec2( 1, -1));
    vec2 c13 = getcomplex(fc+ivec2(-1,  1));
    vec2 c23 = getcomplex(fc+ivec2( 1,  1));


    c = cmid;

        vec2 fugdir = normalize(vec2(1.0));
    float fd = fugdir.x;
    float fdn = 1.0 - fugdir.x;

    float neighbors = (c1.r + c2.r + c3.r + c4.r);
    float nbdiv = 4.0;
        
    neighbors += mix(c1.r, c13.r, fugdir.x);
    neighbors += mix(c2.r, c23.r, fugdir.x);
    neighbors += mix(c1.r, c14.r, fugdir.x);
    neighbors += mix(c2.r, c24.r, fugdir.x);
    neighbors += mix(c3.r, c13.r, fugdir.x);
    neighbors += mix(c3.r, c23.r, fugdir.x);
    neighbors += mix(c4.r, c14.r, fugdir.x);
    neighbors += mix(c4.r, c24.r, fugdir.x);
    
    nbdiv += 8.0;
    
    neighbors += cmid.r;
    nbdiv += 1.0;
    
    
    c.g += (neighbors / nbdiv) - cmid.r;

    c.r += c.g * 0.9;
    c.r *= 0.999;

    
    float paska = 1.0;

    // SIVUT
    paska *= smoothstep(0.0,0.05, uvfbo.y);
    paska *= smoothstep(1.0,0.95, uvfbo.y);
    paska *= smoothstep(0.0,0.05, uvfbo.x);
    paska *= smoothstep(1.0,0.95, uvfbo.x);


    vec2 uvw = uvfbo * 0.1;

//    paska *= smoothstep(0.3,0.4, texture2D(u_noise, uvw).r);


//    paska *= 1.0 - max(0.0, sin(uvfbo.x * 70.0));
//    paska += 1.0 - max(0.0, sin(uvfbo.y * 60.0));

    paska *= smoothstep(0.2,0.3, texture2D(u_noise, uvfbo * 0.04).r);

    if (length(gl_FragCoord.xy - vec2(128.0, 350.0)) < 10.0)
        paska = 1.0;

    paska = clamp(paska, 0.0, 1.0);

    c.rg *= paska;
    
    
    vec2 osci = vec2(0.0);
    //float lfo = sin(u_time * 32.3) * 20.0;
    float lfo = 0.0;
    osci.x = cos(u_time * 150.3 + lfo);
    osci.y = sin(u_time * 150.3 + lfo);
    //vec2 osci = vec2(1.0);       
        vec2 lp = vec2(128.0, 350.0);
//       lp.x += cos(u_time * 0.906452) * 200.0;
//        lp.y += sin(u_time * 0.85923) * 200.0;
        if (u_songpos < 4.0)
           { lp.y -= u_songpos * 10.0;}
        else if (u_songpos < 20.0)
        {lp.x = -10.0;}
        else if (u_songpos < 32.0)
        {
            float omo = u_songpos - 20.0;
            lp.x += 350.0 - omo * 50.0;
            lp.y += -300.0+omo * 50.0;
        }

    lp += (texture2D(u_noise, uvfbo + vec2(0.312919239, 0.2235123) * u_time).rg - vec2(0.5)) * 5.0;


    c = mix(c, osci, smoothstep(2.0,1.0, distance(gl_FragCoord.xy, lp)));
    if (distance(gl_FragCoord.xy, lp) < 1.0)
    {
        c = osci;
      }
    
    
    if (u_songpos < 0.1)
        c = vec2(0.0);

    float mixi = 0.997 - pow(clamp(u_songpos / 1.0, 0.0, 1.0), 0.6) * 0.94;
    float keskiarvo = mix(midi.b,length(c), mixi);
    
    col = vec3(c, keskiarvo);
    a = paska;
//    fragColor = vec4(c, 0, 0.0);






		}
        // PROG_PLASMABLUR
        else if (realprog < 1.5)
        {
    vec3 pos = decode2d(gl_FragCoord.xy);   
    
//    if (mod(u_songpos, 4.0) > 2.0)
  //  {
        vec4 avg = vec4(0.0);
        avg += volumesampling(pos + vec3(1.0, 0.0, 0.0));
        avg += volumesampling(pos + vec3(-1.0, 0.0, 0.0));
        avg += volumesampling(pos + vec3(0.0, 1.0, 0.0));
        avg += volumesampling(pos + vec3(0.0, -1.0, 0.0));
        avg += volumesampling(pos + vec3(0.0, 0.0, 1.0));
        avg += volumesampling(pos + vec3(0.0, 0.0, -1.0));
        avg += volumesampling(pos + vec3(0.0, 0.0, 0.0));
        avg /= vec4(7.0);


//        col = avg.rgb;
  //      a = avg.a;
    
   
    //     pos /= 64.0;
    //  fragColor = vec4(pos,1.0);
          
        float lenni = length(pos - vec3(32.0));
    


        vec4 paskavalintaolicol = vec4(0.0);

        paskavalintaolicol.a = 0.0;
        paskavalintaolicol.r = 1.0 - clamp((lenni - 20.0) * 0.2, 0.0, 1.0);

         lenni += sin(pos.x * 0.4 + u_time * 4.0) * 4.0;
         lenni += sin(pos.y * 0.3 + u_time*3.0)  * 3.0;
        lenni += sin(pos.z * 0.9 + u_time*7.0)  * 3.0;
        if (lenni < 15.0)
             paskavalintaolicol.a = 1.0;

        float kuti = mod(u_songpos, 4.0);

        float mixfac = smoothstep(2.0, 1.9, kuti);
        mixfac += smoothstep(3.8, 4.0, kuti);
        col = mix(avg.rgb, paskavalintaolicol.rgb, mixfac);
        a = mix(avg.a, paskavalintaolicol.a, mixfac);


        }
        // PROG_C64
		else if (realprog < 100.5)
		{
			col = vec3(0.6, 0.4, 0.2) * 0.1;
            vec4 lv = texture2D(u_lastwave, uv * vec2(1.0, 0.8));
			col += pow(lv.b, 1.0) * vec3(2.2, 1.3, 0.4) * 10.0;

            vec3 ggigi = texture2D(u_noise, uv * 0.5).rrr * 0.5;
            ggigi = pow(ggigi, vec3(2.0));
            col = mix(vec3(0.6,0.5,0.6-uv.y*0.5)+ggigi, col, lv.a);

			col = min(vec3(1.5), col);
		}




        // PROG_CYBER KORVAA KORVAA
		else if (realprog < 101.5)
		{
			{
				float ang = u_time * 1.0 + length(uv2) * (2.0 + cos(u_time * 0.4) * 2.0);
				mat2 rotxmat = mat2(sin(ang),cos(ang),-cos(ang),sin(ang));
			}
	
			vec2 rd = normalize(vec2(0.5, 0.5));
	
			vec2 uvr = fract( vec2(4.354812) * u_time + uv);
	
			float haxa = length(uv2) * 0.0;
			float ang1 = u_time * 0.1;// + texture2D(iChannel1, uvr).r * 0.02 + haxa;
			float ang = sin(ang1 * 2.0) * 0.1 + 3.14159 * 1.25;
			ang += ang1 * 1.2;
			mat2 rotxmat = mat2(sin(ang),cos(ang),-cos(ang),sin(ang));
			rd = rotxmat * rd;
	
			vec2 ro = vec2(15.5);
	
			vec3 muna;
			float mulu = 15.0;// + sin(u_time) * 10.0;
			muna = trace_cyber(uv2 * vec2(mulu) + vec2(15.0), ro, rd);
			col = muna * 0.5;
		}





        // PROG_ROTT

		else if (realprog < 102.5)
		{
    {
   	float ang = u_time * 1.0 + length(uv2) * (2.0 + cos(u_time * 0.4) * 2.0);
    mat2 rotxmat = mat2(sin(ang),cos(ang),-cos(ang),sin(ang));
//   		uv2 = rotxmat * uv2;
    }
    
    vec2 rd = normalize(vec2(0.5, 0.5));
    
    vec2 uvr = fract( vec2(4.354812) * u_time + uv);
    
    float haxa = (uv2.x*1.0 / (uv2.y * 0.2 + 4.0)) * 1.9;
    float ang = u_time * 0.2 + haxa;
//    ang += uv2.x * 0.4;
    mat2 rotxmat = mat2(sin(ang),cos(ang),-cos(ang),sin(ang));
    rd = rotxmat * rd;
    
    float aat = u_time * 0.4;
    vec2 ro = vec2(15.5);
    ro.x += cos(aat * 1.9623) * 2.0;
    ro.y += sin(aat * 1.56423) * 2.0;
    ro.x -= cos(aat * 4.1623) * 1.0;
    ro.y += sin(aat * 3.6423) * 1.0;
 
    vec3 muna;
    muna = trace_rott(uv2, ro, rd, ang);    
    col = muna * 0.6;
    col = pow(col, vec3(1.4));
		}


        // PROG_3DDAA

        else        if (realprog < 103.5)
        {

   vec3 rd = normalize(vec3(uv2 * 1.0, 1.6));

    float ang = sin(u_time * 1.0) * 0.1 + 3.14159 * 0.5;
    mat2 rotxmat = mat2(sin(ang),cos(ang),-cos(ang),sin(ang));
  //  rd.xz = rotxmat * rd.xz;
    rd.xy = rotxmat * rd.xy;
    rd.xyz = rd.xzy * vec3(1.0, -1.0, 1.0);
    
//    vec3 ro = vec3(15.5, 37.0, 15.0);
    vec3 ro = vec3(15.5, 24.0, 15.0);

    if (u_songpos > 40.0)
    {
        ro.y += (37.0-24.0) * min(1.0, (u_songpos-40.0) / 8.0);
    }

    ro.x += sin(u_time * 0.4) * 3.0;
    ro.y += sin(u_time * 0.46 + 1.0) * 3.0;
    ro.z += sin(u_time * 0.432 + 2.0) * 3.0;
 
    col = trace_3ddda(ro, rd).rgb;
}
        // PROG_PBRENDER
        else if (realprog < 104.5)
        {
            col = vec3(0.6, 0.4, 0.2) * 0.1;
            vec4 lv = texture2D(u_lastwave, uv);
            col = lv.baa;
        }

        // PROG_PBTRACE
        else if (realprog < 105.5)
        {
    vec3 rd = normalize(vec3(uv2 * 1.0, 2.0));

    //float ang = sin(iGlobalTime * 1.0) * 0.1 + 3.14159 * 0.5;
    float ang = u_time * 0.1;
    mat2 rotxmat = mat2(sin(ang),cos(ang),-cos(ang),sin(ang));
  //  rd.xz = rotxmat * rd.xz;
    rd.xz = rotxmat * rd.xz;
    //rd.xyz = rd.xzy * vec3(1.0, -1.0, 1.0);
    
    float awayfloat = max(0.0, u_songpos - 56.0) * 4.0;
    vec3 ro = vec3(32.5, 32.0, 32.0);
    ro.xz += rotxmat * vec2(0.0, -60.0-awayfloat);
    
    ro.x += sin(u_time * 0.4) * 3.0;
    ro.y += sin(u_time * 0.46 + 1.0) * 3.0;
    ro.z += sin(u_time * 0.432 + 2.0) * 3.0;
 
    col = tracepb(ro, rd) * (1.0 / (awayfloat / 32.0 + 1.0));
}
    // PROG_DIFFUSOR
    else if (realprog < 106.5)
    {
    float dist = length(uv2) * 0.4;
    float rad = 6.0;
    float numblocks = 100.0;

        float distpos = floor(dist * 50.0);
        float numsectors = distpos * rad + 3.0;

        if (distpos > (u_songpos-32.0)*8.0)
        {
            numsectors = 0.0;
        }
    
    float am = u_time * 0.02;
    float fyge = u_songpos + distpos * 0.0538;
    float amadd = smoothstep(0.0, 0.5, fract(fyge));
    am += (floor(fyge)+amadd) * 0.1341;
    float ang = fract(4.0 + atan(uv2.x,uv2.y) / (2.0 * 3.14159) + am + distpos / 3.235 );
    
    float xp = pow(floor(ang * numsectors), 2.0);
    float yp = pow(distpos, 2.0);
    //float l = mod(pow(7.0, xp), numsectors) / numsectors;
    float l = mod(pow(xp+yp, 2.0), numblocks) / numblocks;
    //l = ang;
    col = vec3(1.0, 0.5, 0.2) * l * 3.0;
    }


		if (realprog > 99.5)
		{
            float mudi = 100.0;

            mudi = min(mudi, 0.9 - abs(uv2.x));
            mudi = min(mudi, 0.68 - abs(uv2.y));

            mudi = min(mudi, 0.9 - dot(uv2, vec2(0.7, 0.7)));

            float submudi = 10000.0;
            submudi = -0.85   - dot(uv2, vec2(0.7, 0.7));
            submudi = max(submudi, 0.7 + dot(uv2, vec2(0.7, 0.7)));
            mudi = min(mudi, submudi);

  //          if (abs(uv2.x) > 0.9 || abs(uv2.y) > 0.9)
 /*           if (mudi < 0.0)
                col = col * 0.3 + vec3(0.2, 0.1, 0.6);
            else if (mudi < 0.01)
				col = col * 0.3 + vec3(0.0, 0.0, 0.0);
*/
            col = mix(col * 0.2 + vec3(0.0), col, smoothstep(0.009, 0.01, mudi));
            col = mix(col * 0.2 + vec3(0.2, 0.1, 0.6), col, smoothstep(0.0, 0.004, mudi));

            col *= mod(gl_FragCoord.y, 2.0) * 0.4 + 0.6;

				col *= 0.95 + sin(gl_FragCoord.y * 0.1 + u_time * 4.0) * 0.05;

//				col *= mod(u_songpos * 2.0, 1.0) * -0.1 + 1.0;

				col += vec3(texture2D(u_noise, uv+vec2(u_time * 99.3923)).g * 0.1);

				float gv = dot(col, vec3(0.3333));
				col = col * 0.5 + gv * vec3(1.0, 0.6, 0.2) * 0.5;

                vec2 tuv;
                tuv.x = uv2.x + 0.8 ;
                tuv.y = -uv2.y + 0.5;

                tuv *= vec2(0.39, 1.2);
                if (tuv.x >= 0.0 && tuv.y >= 0.0 && tuv.x < 1.0 && tuv.y < 1.0)
                    col += texture2D(u_text, tuv).rgb;
        col = pow(col, vec3(1.4));



		}


		gl_FragColor = vec4(col, a);

//		gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
	}
	)";

static const char GLSLX_NAME_U_COLO[] = "u_colo";
static const char GLSLX_NAME_U_PROG[] = "u_prog";
static const char GLSLX_NAME_U_TIME[] = "u_time";
static const char GLSLX_NAME_U_LASTWAVE[] = "u_lastwave";
static const char GLSLX_NAME_U_NOISE[] = "u_noise";
static const char GLSLX_NAME_U_TEXT[] = "u_text";
static const char GLSLX_NAME_U_SONGPOS[] = "u_songpos";
