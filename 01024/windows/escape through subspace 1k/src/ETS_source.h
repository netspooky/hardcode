
// ESCAPE THROUGH SUBSPACE 1K by Seven/Fulcrum
// -------------------------------------------

float f, // the number of steps we have marched so far.
	  x=270*gl_Color.x-3, // we are abusing glColor to pass a time value. x=0 is the moment the spaceship starts to appear.
	  z=0, // the distance that we have marched in the main loop, starts at 0
	  n, // temp variable for a fractal
	  m, // distance from the ships *hull*. Will be negative inside the hull. For coloring the ship green and the warp effect purple
	  r; // another temp variable for a fractal

// The distance function. 
float e(vec3 t)
{
  t+=vec3(-.4,.9,x-9);	// The camera motion. The camera moves in a straight line.

  m=9;					// Start distance, initialized to a large enough value.
  
  // Calculate the shape of the ships hull. It is one big saucer, with two smaller saucers as the superstructures,
  // with four smaller saucers as the engines etc.

  vec3 v=t;	// temporary coordinate that will be mutilated by the fractal calculation
  for(float f=0;f<4;f++) // Always use the same control variable in your for loops, if possible.
  {
    v.yx=abs(v.yx); // mirror around the x and y axis. This will also double the amount of saucers in each new pass
    m=min(m, // the hull is the union of all saucers
			pow(.6,f)* // Each new copy of the saucer should be smaller than the previous 
			(length(v+vec3(3,19,1))-20)); // This is a big off-center sphere. Due to the mirroring, we get a big saucer.

    v=1.6*v				// compensate the 0.6 scaling so the distance formula is kept valid
		-vec3(2.7,.8,4); // move each new saucer a bit more off-center and towards the rear of the ship.
    v.yx=vec2(.6*v.y+.8*v.x,-.8*v.y+.6*v.x); // rotate the saucers so they almost alternate between horizontal and vertical
  }

  // speed optimisation: if we're not close to the hull, don't bother intersecting with the fractal.
  if(.01<m)
    return m;

  // The interior of the ship is defined by a modified mandelbox fractal

  r=1; // inital distance value for the fractal

  f+=5;// Another speed optimisation: once we're inside the hull, increase the step counter much faster so we don't do
	   // 100+ iterations of the fractal. Marching the fractal with a high stepcount is too slow and look worse (grainy)
		// from far away

  v=t; // temporary coordinate that will be mutilated by the fractal calculation
  for(float f=0;f<13;f++) // using the same loop variable.
  {
    v=clamp(v,-1,1)*2-v; // box fold
    n=min(max(1.56/dot(v,v),.43),1)*4.2;// ball fold

    v*=n;	// update the coordinate
    v+=t+vec3(0,-2,0); // this extra vector creates the bridge on the main saucer
    r*=n;	// and update the distance
    
  }
  return max(length(v)/r,m); // return the combined hull/fractal distance
}
void main()
{
  vec3 t, // current location that we have reached while marching
		v=vec3(gl_FragCoord.xy*.0015-vec2(1,.55),1); // march direction, hardcoded for 1280*720 resolution.
													// Intentionally not yet normalized

  // This is the simplified camera rotation, which only works for small turn angles. x is time.
  // This looks warped, but that's OK because it amkes the camera motion look more complicated then it is.
  v.xz+=vec2(v.z,-v.x)*.4*sin(.6*x);
  v.yz-=.2+vec2(v.z,-v.y)*.6*sin(.4*x);

  v=normalize(v); // And now we normalize to correct for the errors of the camera rotation

  // the main raymarching loop
  for(f=0;f<200	// we do at most 200 iterations. That is a lot, to ensure we hit the hull at high precision,
				// but once we reach the hull 'f' will be increased inside the distance function as well.
			&& t.z<14*x; // This causes the warp-effect. We simply do not march very far at the start,
						 // causing the ship to be gradually revealed
			f++)
    z+=e(t=v*z); // t = current point that we have reached, z = the distance.

  // We want to calculate the normal for the lighting and reflections, , typically done with
  //		vec3(e(t+vec3(epsilon,0,0)),e(t+vec3(0,epsilon,0)),e(t+vec3(0,0,epsilon)))
  // But fractals have details at different scales. A big epsilon looks good from far away, a
  // small one reveals the details if the camera is very close. So, we use the scaled distance
  // to the ship as epsilon.
  z*=.01; 

  vec3 w=vec3(.2,.2,.96), // the main lightsource direction, gives a nice highlight on the main hull
	   y=normalize(vec3(e(t+vec3(z,0,0)),e(t+vec3(0,z,0)),e(t+vec3(0,0,z)))), // the normal
	   d=pow(max(0,dot(v,reflect(w,y))),100) // specular reflection to make the ship look metalic
		 +vec3(1,-1,1)*m // make the interior of the ship green, and the warp effect purple
		 +vec3(.1,.2,.3)*(max(0,dot(w,y)) // diffuse lighting, blue-ish metal
		 +.3); // ambient lighting

  // This is the classic 'have we hit something, or should I draw the sky?' check. It repeats below.  Usually
  // this is done with a very small value, so there are no gaps in objects if we run out of raymarch steps.
  // Here I use a large value, which causes the warp field effect around the ship. When the raymarch loop halts
  // because of the extra warp-check, at the warp boundary the area closest to the ship will be regarded as part
  // of the ship, and will be colored purple. Later on, when all 200 iterations are used, the raymarching ends
  // either on/inside the ship, or far in space.
  v=e(t)<.2? 
	   reflect(v,y) // If we hit the ship, reflect the raymarch direction to get a reflection of the stars
	  :v;

  // The background is Knightys Cosmos fractal from Shadertoy, mutilated. Changing almost any parameter will
  // change both the size, scale and speed of all stars, so it's a pain to get it to look as you want.
  for(float f=0;f<60;f++)
  {
    w=vec3(.9,.6,fract(floor(f-90*x)*.001)); // this 3D coordinate is not continuous.
								// Slowing the speed 90 down results in a slideshow, even at high framerates.
    w.xy+=f*v.xy*.001;
    for(float f=0;f<13;f++)
      w=abs(w)/(m=dot(w,w))-.82; // calculate the distance to the stars

	// Here, I re-use the normal variable to accumulate the stars color. Since the normal is by definition
	// length 1, we don't bother to clear it to zero. It's initial value will be a rounding error anyway.

    y+=w*-m; // Multiplying the distance with the final coordinate results in surprisingly coherent colors
			 // (I had expected noise)
  }
  // Did we hit the ship? If so add the faint star reflection to the ship color, else draw just the stars.
  gl_FragColor.xyz=e(t)<.2?y*.0004+d:y*.004;

}