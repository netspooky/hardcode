// Time
varying float T;

// Camera data
varying vec3 cameraPos;

// Position of the fragment
varying vec2 Z; 

// Forward declarations
vec4 traceRay(vec3, vec3, int);
vec3 shade(vec4, vec3, vec3);


// All data of our world
vec3 lightDir, lightColor, waterColor, ro, rd, interlacing;
float gf_DetailLevel, pi, eps, bigeps;


// Pseudo random number base generator (credits go to iq/rgba)
float rnd(vec2 x) 
{
	int n = int(x.x * 40 + x.y * 6400);
	n = (n << 13) ^ n;
	return 1 - float( (n * (n * n * 15731 + 789221) + 1376312589) & 0x7fffffff) / 1073741824;
}


// Generate cubic interpolated random values
float smoothrnd(vec2 x)
{
	x = mod(x,1000.0);
    vec2 a = fract(x);
    x -= a;
    vec2 u = a*a*(3.0-2.0*a);
    return mix(
	mix(rnd(x+vec2(0,0)),rnd(x+vec2(1,0)), u.x),
	mix(rnd(x+vec2(0,1)),rnd(x+vec2(1,1)), u.x), u.y);
}


// Convert the cipher range from [-1,1] to [0,1]
float norm(float x)
{
	return x * 0.5 + 0.5;
}


// Generate animated (t) caustic values
float caustic(float u, float v, float t)
{
	float a = (
	norm(sin(pi * 2 * (u + v + T*t))) +
	norm(sin(pi     * (v - u - T*t))) +
	norm(sin(pi     * (v     + T*t))) +
	norm(sin(pi * 3 * (u     - T*t)))) * 0.3;
	return pow(a, 2.0);
}


// Calculate our TV effects (interlacing, RGB mask and film grain)
vec3 pp(vec3 color)
{
	int c = int(mod(gl_FragCoord.x, 3.0));
	if (c==0) color *= interlacing.xyz;
	if (c==1) color *= interlacing.yzx;
	if (c==2) color *= interlacing.zxy;
	return mix(color, vec3(norm(smoothrnd(Z * 333 + rnd(vec2(T)) * 33333))), 0.03);
}


// Our fake godray effect (bad if moving fast, but awesome any other time)
vec3 godrays(vec3 color)
{
	vec2 dpos = Z*2-1;
	float g = dpos.x * (dpos.y +  3);
	return color + lightColor * 
		caustic(g + 50 * ro.x, g + 50 * ro.z, 1.5) * 
		(norm(dpos.y)) * min(-ro.y * 30, 0.3);
}


// Our heightmap calculation function, we could use some perlin noise here if it wouldn't be so performance killing
float height(vec2 x)
{
	return (-0.035 + pow((caustic(x.x * 10, x.y * 10, 0.0) * 2 - 1), 2.0) * 0.05) 
		- (x.x - 0.1) * 0.2; // This line creates one entire continent and a big ocean!
}


// Gets the terrain normal
vec3 getTerrainNormal(vec3 p)
{
    return normalize(vec3(
		height(p.xz - vec2(bigeps, 0)) - height(p.xz + vec2(bigeps, 0)),
        2 * bigeps,
        height(p.xz - vec2(0, bigeps)) - height(p.xz + vec2(0, bigeps))));
}


// Global diffuse lighting formula
vec3 diffuseLight(vec3 incolor, vec3 normal)
{
	return (0.3 + 0.7 * max(dot(normal, lightDir), 0.0)) * lightColor * incolor;
}


// Calculates the water "waves". To reduce the bumpiness, increment the y-axis
vec3 getWaterNormal(vec3 p)
{
	return normalize(vec3(
		caustic(p.x * 160 - cos(p.z * 10) * 12, p.z * 140, 4.0),
		8,
		caustic(p.z * 160 - sin(p.x * 10) * 12, p.x * 140, 4.0)) * 2 - 1);
}


// Calculate the terrain color for the given voxel
vec3 shadeTerrain(vec3 p, vec3 rd)
{
	vec3 n = getTerrainNormal(p);
	vec3 color = mix(
			// sandy color
		vec3(0.66, 0.55, 0.4)
			
			// basic color (big random color spots)
		- 0.2 * smoothrnd(abs(p.xz * 150))
			
			// texture (sediment lines)
		- 0.2 * smoothrnd(abs(p.yy + 0.002 * smoothrnd(abs(p.xz * 150))) * 3000),
		
			// interleaved grass, hight dependant
		vec3(0.1, 0.3, 0) * (smoothrnd(p.xz * 7000.0) * 0.4 + 0.5),
		
			// mixing for the sand/grass transition
		clamp(n.y * (caustic(p.x * 111, p.z * 111, 0.0) * 0.5 - p.y * 40), 0.0, 1.0));

	// caustics, only underwater (no cloudshadows, though)
	if (p.y <= 0)
		color += 5 * getWaterNormal(0.8 * p).x * min(0.3, -p.y * 8);
	
	// Light
	return diffuseLight(color, n);
}


// Create a blueish sky transition from navy blue to badass dark blue
vec3 shadeSky(vec3 ro, vec3 rd)
{
	return ro.y <= -eps*eps ?
		waterColor : 
		mix(vec3(-0.5, -0.25, 0), vec3(2), 1 - (rd.y * 0.5 + 0.5));
}


// Calculates the refraction and reflection of the water surface.
// Also mixes both values by the depth of the water and the fresnel term.
// Possible improvements: fix fake underwater reflection and refraction
vec3 shadeWaterRefl(vec3 p, vec3 newrd)
{
	vec3 waterNormal = getWaterNormal(p);
	
	// perform raytracing/raymarching for both reflection and refraction
	// calc the water refraction, the refraction index (0.9) will decrease with the distance to allow a better over/under water transition
	vec4 refracted = traceRay(p, refract(newrd, waterNormal, 0.9), 2);//mix(0.9, 1.0, smoothstep(0.01, 0.0, length(p-ro)))), 2);
	
	// calculate the depth factor (water entry point to terrain voxel) (black magic involved here!)
	float depth = clamp(pow(1.03 * (1 - length(refracted.xyz - p)), 16.0), 0.0, 1.0);
	
	// Finally stir the pot =)
	return mix(
		ro.y < 0 ? shadeSky(p, newrd) : waterColor, // Water color 
		mix(
			shade(traceRay(p, reflect(newrd, waterNormal), 2), p, newrd), // Reflection color 
			shade(refracted, p, newrd), // Refraction color 
			clamp(-rd.y + depth, 0.0, 1.0)), // fresnel term
		refracted.w == 3.0 ? 0.5 : pow(depth, 0.5)); // water color contribution

}


// Raymarch the terrain function, returns the distance from the ray origin to the terrain voxel
// This function was originally adopted from an implementation by iq/rgba
float traceTerrain(vec3 ro, vec3 rd, float maxt)
{
    float delt, lh, ly, samplePosY;
    delt = 0; // If the world would consist of only nVidia GPUs, this line wouldn't exist.
    vec3 samplePos = ro;

    // advance our sample position from our nearplane to our farplane
    for (float t = 0; t < maxt; t += delt)
    {
		// advance our ray
        samplePos += rd * delt;
		samplePosY = samplePos.y;

        // get the height at the given sample 2d (!) position (we could enhance this by sampling a voxel and returning only the distance to the voxel)
        float h = height(samplePos.xz);
        
        if (samplePosY <= h)
        {
			// we need to know our improved (more accuracy here) real terrainposition and the old sampleposition
			// also we precalculate the traveled ray distance (its not a ray anymore if we use stuff like refraction, eg but hey lets stick to this word)
			return t - delt + delt*(lh-ly)/(samplePosY-h+lh-ly);
        }
        
        // store our last height and last sampleposition on the y-axis
        // we need this to calculate the improved terrainposition which will give us a smoother transition between our samplesteps (rd*delt)
		lh = h;
		ly = samplePosY;
 
		// advance our steplength the more we travel the bigger our stepsize should be
		// with this we are able to sample finer details near to our camera
        delt = 0.002 + (t/gf_DetailLevel);
    }
    
    // we hit nothing
    return 9.0;
}


// Ray vs. plane intersection function
float traceWater(vec3 ro, vec3 rd)
{
	float tPlane = -ro.y / rd.y;
	return tPlane >= eps ? tPlane : 9.0;
}


// Raytracing entry point, returns voxel and object ID
// IDs:
// 0 = sky (not the armageddon, xTr1m!!)
// 1 = terrain
// 2 = water
vec4 traceRay(vec3 ro, vec3 rd, int ignore)
{	
	float water, terrain, minDist;

	// trace only the objects we need (only one could maximally be ignored)
	water = ignore != 2 ? traceWater(ro, rd) : 9.0;
	terrain = ignore != 1 ? traceTerrain(ro, rd, min(0.5, 0.002 + water)) : 9.0;
	
	// auto detail level reducing (common dude, give the GPU some breathing room)
	gf_DetailLevel *= 0.75;
	
	// find the nearest distance
	minDist = min(terrain, min(water, 9.0));
	
	// we hit nothing or the hitpoint is too far
	if (minDist == 9)
		return vec4(0);

	// calculate the hit/voxel position
	vec3 hitPos = ro + rd * minDist;

	// check what we might have hit
	if (minDist == terrain) 
		return vec4(hitPos, 1);
	if (minDist == water) 
		return vec4(hitPos, 2);

	// Panic, worry, die to death! Probably we'll land on the moon (this should never happen)
	//return vec4(0);
}


// Entrypoint for color calculation
vec3 shadeRefl(vec4 hitPoint, vec3 newRo, vec3 rd)
{
	// determine the fog color for this very precise point in the space time continuum
	vec3 myFog = newRo.y < eps ? waterColor : shadeSky(ro, rd);
	
	// generate the distance value for the fog calculation
	float distance = clamp(length(hitPoint.xyz - newRo) * (ro.y <= 0 ? 4 : 2), 0.0, 1.0);

	// get the color of the hit object and mix it with the fog
	// in most cases we allow further raytracing here (not for the terrain, its not shiny enough)
	if (hitPoint.w == 1)
		return mix(shadeTerrain(hitPoint.xyz, rd), myFog, distance);
	if (hitPoint.w == 2)
		return mix(shadeWaterRefl(hitPoint.xyz, rd), myFog, distance);
		
	return shadeSky(newRo, rd);
}


// Get the color from the object we just hit (without further raytraces)
// this is necessary because no recursion is allowed in GLSL (damn you!)
vec3 shade(vec4 hitPoint, vec3 newRo, vec3 rd)
{
	// determine the fog color for the very same point we discussed earlier
	vec3 myFog = newRo.y < eps ? waterColor : shadeSky(ro, rd);
	
	// generate the other distance value. Paid attention? If you don't know what value I'm talking about, rtfm or gtfo.
	float distance = clamp(length(hitPoint.xyz - newRo) * (ro.y <= 0 ? 4 : 2), 0.0, 1.0);

	// get the color of the hit object and mix it with the fog
	if (hitPoint.w == 1)
		return mix(shadeTerrain(hitPoint.xyz, rd), myFog, distance);
	if (hitPoint.w == 2)
		return mix(waterColor, myFog, distance);
		
	return myFog;
}


// Now we're just being copycats. We're not creative enough to define own entry points
// Sure, we could "#define MYENTRYPOINT main"! Or just void main(){MyEntryPoint();}
// None of that would help us win the compo, would it?
void main()
{
	// Set the quality setting for the raymarcher, a higher value results in a longer processing time
	// try to find a good balance between these two, low values will result in a wobbling endresult
	// low quality = 50.0 (visual results are ok at 640x480)
	// mid quality = 100.0
	// high quality = 200.0
	gf_DetailLevel = 200;
	
	// Give our saviour global variables some life!
	pi = 3.1416;
	interlacing = vec3(1.2, 0.9, 0.9);
	eps = 0.0001;
	bigeps = 0.01;
		
	// Get the look direction for the current pixel (always look forwards)
	ro = cameraPos;     //set ray origin
	if (ro.y < height(ro.xz) + 0.01f)
	{
		ro.y = height(ro.xz) + 0.01f;
	}

	rd = vec3(gl_ModelViewMatrix * vec4((Z.xy - 0.5), 1, 1));
	
	// Make our world pretty and worthy to live in (you can cultivate algae and eat them, they're surely enough for survival)
	lightDir = vec3(0.58, 0.58, -0.58);
	lightColor = vec3(1.2);
	waterColor = vec3(0.3, 0.33, 0.4);
	
	// Our GPU feels good underwater, almost like a refreshing experience :) cool, eh?
	if (ro.y <= 0)
	{
		// Less work to do...
		gf_DetailLevel *= 0.75;
		
		// ...and a cozy darker atmosphere
		lightColor *= 0.8;
	}
	
	// Here we go, shoot'em rays and get the color of our fragment!
	vec3 color = shadeRefl(traceRay(ro, rd, 0), ro, rd);
	
	// Underwater there are beams of light emanating from god (so called "god" rays...)
	// ...this prooves that god is nothing less than a water surface.
	if (ro.y <= 0)
		color = godrays(color);
		
	// Apply post processing and fade effects to the color, and finally return it.
	gl_FragColor.xyz = pp(color);
}
