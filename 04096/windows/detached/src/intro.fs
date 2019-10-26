// make the whole shader non-const after minifying, because we set this constant before compiling

const int CurScene = 0x0; // this 0x0 has to be readded, because the optimizer throws it away

// Parameters from our host
// x: Scene+Time
// y: Height
// z: Aspect offset
// w: Sync
uniform vec4 Y; 

float cFac, CurTime, CurTime2, CurStep, pi2= 6.28319;
int m;
vec2 CurNormal;
vec3 cRes, rayDir, CurColor = vec3(0.), RayStep = vec3(0.);
vec3 LightColor= vec3( 3., 2.5, 2.0);
vec3 BackColor= vec3( 0.7, 0.6, 0.4);
vec4 HitMaterial;

vec2 rotate(vec2 v,float y)
{
	return cos(y)*v+sin(y)*vec2(-v.y,v.x);
}

float repeatr(inout vec2 v,float x, float y) 
{
    float a= atan(v.y,v.x);
	float z=mod(a,y)-y*.5;
	v=(length(v))*vec2(cos(z),sin(z));
	v.x-=x;
    return a-z;
}

void repeat( inout float w, float y )
{
	w= mod( w - y*.5, y ) - y*.5;
}

void repeate( inout float w, float y, float z )
{
	w= max( abs(w)-z, mod( w - y*.5, y ) - y*.5);
}

float row( float w, float y)
{
	return floor( ( w - y*.5 )/ y );
}

float CBox( in vec3 p, in vec3 box, float rad )
{
    return length( max( abs(p) - box + vec3(rad), 0.0 ) ) - rad;
}

float CBox2D( in vec2 p, in vec2 box, float rad )
{
    return length( max( abs(p) - box + vec2(rad), 0.0 ) ) - rad;
}

float plasm(float x, float a, float b,float c)
{
	return sin(x+a+c*sin(x+b));
}

float smin( float a, float b, float k )
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}

float hash( vec2 p )
{
	float h = dot(p,vec2(23.2,15.7));	
    return fract(sin(h)*232.45);
}

float noise(vec2 p)
{
	vec2 e = vec2(1.0, 0.0);
    vec2 i = floor( p );
    vec2 f = fract( p );	
	f *= f*(3.0-2.0*f);
    return -0.5 + mix( mix( hash( i + e.yy ), 
                     hash( i + e.xy ), f.x),
                mix( hash( i + e.yx ), 
                     hash( i + e.xx ), f.x), f.y);
}

float tunnel(vec3 p)
{
		p.y += 4.0 * plasm(1.1, CurTime * 3. + p.z * 0.02, 0.4, p.z * 0.02);
		p.x += 4.0 * plasm(0.9, CurTime * 4. + p.z * 0.02, -1.4, p.z * 0.02);
		float r = row(p.z, 24.0);
		repeat(p.z, 24.0);
		p.xy= rotate( p.xy, r + plasm(1.1, CurTime * 4., 1.3, r * 0.2));
		r = max( 12. - length(p.xz), length(length(p.xy) - 32.) - 1.0);
		repeatr(p.xy, 32.0, pi2 / 5.0);
		return min ( r, max( length( p.z) - 1., length(length(p.xy) - 18.) - 1.0));
}

float f0(vec3 p)
{
	if (CurScene > 7)
	{
		return length(p) - 32. - Y.w;
	}
	else
	{
		return length(p) - 48. - Y.w;
	}
}

float f1(vec3 p)
{
	if (CurScene > 7)
	{
		float f = 999.0;
		
		for (float i = 0.; i < 3.; ++i)
		{
			vec3 o = p;
			o.xy= rotate( o.xy, i + 2.3 * CurTime );
			o.zx= rotate( o.zx, 2. * i + 4.3 * CurTime );
			o.z += 48. + 8.0 * plasm(1.1, CurTime * 2., 0.4, CurTime * 0.02);
			o.yz= rotate( o.yz, i + 5.9 * CurTime );
			o.xy= rotate( o.xy, i + 2.3 * CurTime );
			f = min (f, CBox(o, vec3(16., 16., 16.) + Y.w, 3.));
		}

		return max( 40. - length(p), smin(f, length(p) - 34., 24.));
	}
	else if (CurScene > 3)
	{
		float r = 360. - CurTime * 222.0 - p.z;
		r = 8. - (r < 0. ? 0. : 0.001 * r * r);
		p.y -= 4.0 * plasm(1.1, CurTime * 2. + p.z * 0.02, 0.4, p.z * 0.02);
		p.x -= 4.0 * plasm(0.9, CurTime * 2. + p.z * 0.02, -1.4, p.z * 0.02);
		return length(p.xy) - r - Y.w;
	}
	else
	{
		p.z += 192. - 96.* CurTime;

		p.xy= rotate( p.xy, 2.3 * CurTime );
		p.yz= rotate( p.yz, 1.9 * CurTime );

		return CBox(p, vec3(32., 32., 32.) + Y.w, 0.);
	}
}

float f2(vec3 p)
{
	if (CurScene > 7)
	{
		//return 999.0;
		float f = CBox(p, vec3(555., 555., 555.), 0.);

		float s = 1.0;
		vec3 o = p;
		for( int m=0; m<4; m++ )
		{
			o.x += 33.;
			o.xz= rotate( o.xz, 1.6 + 0.13 * CurTime);
			o.yz= rotate( o.yz, 4.8 * 0.19 * CurTime );
			float y = 444./s;
			vec3 r = abs(0.33 - 1.0*abs(mod( o - y*.5, y ) - y*.5));
			f = max(f, 111.0 / s - min(max(r.x,r.y),min(max(r.y,r.z),max(r.z,r.x))));
			s*= 3.0;
		}
	    return f;
	}
	else if (CurScene > 3)
	{
		return tunnel(p);
	}
	else
	{
		float s = repeatr(p.xy, 64.0, pi2 / 48.0);
		float r = row(p.z, 6.0);
		repeat(p.z, 12.0);
		s = plasm(s, CurTime * 8., 1.3, r * 0.2) + 0.8;
		return length(p) - s;
	}
}

float f(vec3 p)
{
	return min( min( f0(p), f1(p) ), f2(p) );
}

float fN(vec3 p)
{
	return f(p);
}

void mat(vec3 p)
{
	HitMaterial = vec4(-1.8, 3.0, 0.6, 2.0);

	float z= 0.1;

	if( z > f0(p) )
	{
		z= f0(p);
		CurColor = vec3(250, 105, 0)/255;
		CurStep= .6;
	}

	if( z > f1(p) )
	{
		z= f1(p);

		CurColor = vec3(105, 210, 231)/255;
		CurStep= .6;
	}
		
	if( z > f2(p) )
	{
		CurColor = vec3(224, 228, 204)/255;
		CurStep= .3;
	}
}

vec3 lightSphere(vec3 normal, vec3 color, vec2 desc)
{
	return smoothstep(desc.x, desc.y, dot(vec3( 0.86, 0.5, 0.0),normal)) * color;
}

vec3 filter(vec3 col)
{
	vec2 uv = vec2(gl_FragCoord.xy / Y.y);
	uv.x -= Y.z;
	vec2 uv2=2*uv-1;	

 	float blend = min(8.0*abs(sin((Y.x)*3.1415)),1.0); 
	col*=.9+0.1*sin(10.*Y.x+uv2.x*Y.y);	
	col*=.9+0.1*sin(10.*Y.x+uv2.y*Y.y);	
	float Scr=1.5-length(uv2*2)*0.15;

	if (uv.y >= blend-0.02) col*=0.7;
	if (uv.y >= blend-0.04) col*=0.7;
	if (uv.y <= 1.02-blend) col*=0.7;
	if (uv.y <= 1.04-blend) col*=0.7;
    
    return smoothstep(0.0, 1.0, col*Scr*blend) * 2.0;
}

void main()
{
	CurTime= fract(Y.x);
	CurTime2= CurTime * CurTime;

	// Get the look direction for the current pixel (always look forwards)
	rayDir = vec3((gl_FragCoord.xy / Y.y - 0.5), 0.8);
	rayDir.x -= Y.z;
	
	// Camera position
	vec3 p = vec3( 0.0, 11.0, -CurTime * 33.0);

	if( CurScene < 1)
	{
		p = vec3( -44.0, -33.0, 99.0);
		rayDir.yz= rotate( rayDir.yz, -CurTime);
		rayDir.xz= rotate( rayDir.xz, -CurTime);
	}
	else if( CurScene < 2)
	{
		p = vec3( 22.0, 3.0, 111.0 * (1.0 - CurTime * 0.3));
		rayDir.xz= rotate( rayDir.xz, 3.);
	}
	else if( CurScene < 3 )
	{
		p = vec3( -44.0, -33.0, -99.0);
		rayDir.yz= rotate( rayDir.yz, -CurTime);
		rayDir.xz= rotate( rayDir.xz, 4.5 -CurTime);
	}
	else if( CurScene < 4 )
	{
		p = vec3( 55.0, 33.0, -155.0 * (1.0 - CurTime * 0.6));
		rayDir.yz= rotate( rayDir.yz, 0.4 );
		rayDir.xz= rotate( rayDir.xz, -4.5 - CurTime );
	}
	else if( CurScene < 5 )
	{
		p= vec3( 11., 0., -111.);
		rayDir.xz= rotate( rayDir.xz, 3.);
	}
	else if( CurScene < 6 )
	{
		p= vec3( -18.0, -11., -111.0 * (1.0 - CurTime * 0.3));
		rayDir.yz= rotate( rayDir.yz, -CurTime * .3);
		rayDir.xz= rotate( rayDir.xz, -CurTime);
	}
	else if( CurScene < 7 )
	{
		p= vec3( -18.0, -11., 144.0 * (1.0 - CurTime * 0.3));
		rayDir.yz= rotate( rayDir.yz, -CurTime * .3);
		rayDir.xz= rotate( rayDir.xz, -CurTime);
	}
	else if( CurScene < 8 )
	{
		p= vec3( 18.0, -11., 111.0 * (1.0 - CurTime * 0.5));
		rayDir.yz= rotate( rayDir.yz, -CurTime * .3);
		rayDir.xz= rotate( rayDir.xz, -0.3  + CurTime * 2.);
	}
	else if( CurScene < 9 )
	{
		p= vec3( -55.0, 99., 177.);
		rayDir.yz= rotate( rayDir.yz, -0.4);
		rayDir.xz= rotate( rayDir.xz, 3.5 * (1.0 - CurTime * 0.3) );
	}
	else if( CurScene < 10 )
	{
		p= vec3( -290., 153., -70.);
		rayDir.yz= rotate( rayDir.yz, 0.4);
		rayDir.xz= rotate( rayDir.xz, -CurTime);
	}
	else if( CurScene < 11 )
	{
		p= vec3( -66., 44.0, 0.0);
		rayDir.yz= rotate( rayDir.yz, 0.6 );
		rayDir.xz= rotate( rayDir.xz, 4.4 );
	}
	else //if( CurScene < 12 )
	{
		p= vec3( -33., 33.0 * (1.0-CurTime), -11.0);
		rayDir.yz= rotate( rayDir.yz, -0.5 );
		rayDir.xz= rotate( rayDir.xz, -1.0 );
	}
		
	rayDir = normalize(rayDir);

	cRes= vec3( .0,.0,.0 );
	cFac=1.0;
	
	float t= 0.0,y,z;

	m=0;
    HitMaterial = vec4(-3.0, 8.0, 0.9, 1.0);
    vec3 fog = lightSphere(rayDir, LightColor, HitMaterial.zw);
	while(m++<5)
	{
        float ii = 222.0;
		for (CurStep=1.0;ii >=0.0 && t<999.0 && CurStep>t*.000001;t+=CurStep,RayStep=rayDir*t,--ii )
		{
			CurStep = f(p+RayStep);
		}

        if (ii <= 1)
        {
			ii = 0.;
            t = 999.3 ;
            RayStep=rayDir*t;
            break;
        }
        ii = smoothstep(44., 1., ii);

        		vec3 NextPos = p+RayStep;
		
		// Start point and direction for reflected ray
		p= NextPos;
		
		CurNormal = vec2(0.04, 0.0);
		vec3 n= vec3( fN(p + CurNormal.xyy) - fN(p - CurNormal.xyy), fN(p + CurNormal.yxy) - fN(p - CurNormal.yxy), fN(p + CurNormal.yyx) - fN(p - CurNormal.yyx) );
		
		mat(p);
		n= normalize(n);

		// CurStep == reflection

		if( t > 999.0)
		{
			if( m < 2)
			{
				HitMaterial = vec4(-3.0, 8.0, 0.9, 1.0);
			}
			break;
		}
		
		rayDir= reflect( rayDir, n );

		// ao
		y= 8.0;
		for (z=1.0;y>0.;y--)
		{ 
			z-=.5*(y-f(p+n*y))/exp2(y);
		}
		CurColor*= z;
		CurColor*= lightSphere(rayDir, BackColor, HitMaterial.xy);
    
		cRes+= cFac*mix(CurColor, fog, ii);
		cFac*= CurStep;
		t= 0.5;
		RayStep = rayDir * t;
	}

	gl_FragColor.xyz = step(-12.0, -Y.x) * filter(cRes + cFac*
		(	lightSphere(rayDir, LightColor, HitMaterial.zw) +
			lightSphere(rayDir, BackColor, HitMaterial.xy)));
}
