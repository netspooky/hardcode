precision highp float;

// Takes time as parameter
uniform float F;

void main() {
	vec3 result = vec3(0);
	
	// When seed is constant, time in this case, you get massive artifacts, using screen space
	// coordinates multiplied gives smooth noise, varying between these two gives the funky effect
	float distance, radius, seed = .7 < sin(F*.2) ? F : gl_FragCoord.x*gl_FragCoord.y;
	
	// We shoot 100 rays per pixel to smoothen out noise
	for (int j=0; j<100; j++) {
		vec3 spherePos;
		vec3 mat;
		vec3 tint = vec3(1);
		vec3 rayO = vec3(0,.7,.1);

		// Calculate ray direction based on screen space coordinates
		vec3 rayD = normalize(gl_FragCoord.xzy/1440. - vec3(.44,-.2,.25) - rayO);
		
		// WebGL doesn't support recursion in shaders, so we use for loop to calcualte multiple
		// light bounces in the scene
		for (int a=0; a<4; a++) {
			// Wall positions, we swap axis to get different sphere positions
			vec3 walls = vec3(0, 10.25,0);
			distance=100.;
			for (int k=0; k<8; k++) { // Go through all spheres
				// Setup sphere and materials 
				vec3 sphere = vec3(.2 * cos(F), .2 * sin(F), .34 - F*.004); // Default to light
				// Just use some random vector to detect lights, m=x, if (m==x) light
				vec3 m = walls; 
				radius=.005;
				if (k<7) // Diffuse sphere
					m = vec3(0,.7,.1).yyz,
					sphere=vec3(.12 * cos(F*.7+3.), .12 * sin(F*.7+3.),sin(F*.12)*.12);
				if (k<6) // Mirror sphere
					m = vec3(1),
					sphere=vec3(.12 * cos(F*.7), .12 * sin(F*.7),-sin(F*.12)*.12),
					radius = .012;
				if (k<5) // Walls
					m = vec3(0,.7,.1).yyy,
					// Here we do walls=-walls.zxy which basically over 5 iterations gives us all
					// 5 walls you see, left, right, top, bottom and back wall
					sphere=walls=-walls.zxy, 
					radius = 100.;
				if (k==1)
					m = vec3(0,.7,.1).zyy;
				if (k==4)
					m = vec3(0,.7,.1).yzy;
				// Intersect sphere
				float d, b=dot(rayD, sphere - rayO),
					det=b*b-dot(sphere - rayO, sphere - rayO)+radius;
				// Check if we hit something
				if (.0 < det)
					if (.0001 < (d=b-sqrt(det)))
						if (d < distance) { 
							// If we did, set the materials, sphere position and hit distance
							distance = d;
							mat = m;
							spherePos = sphere;
						}
			}
			if (distance == 100.) // Ray missed scene, it bounces no more
				break;
			if (mat == walls) { // We hit light, add tinted color to result
				result += 12. * tint;
				break;
			}
			rayO += rayD * distance; // Calculate intersection point
			tint *= mat; // Apply color
			
			// Store normal of the intersection into spherePos
			spherePos = normalize(rayO - spherePos); 
			
			// Decide if material is white which means its mirror or something else then its diffuse
			rayD = mat == vec3(1) ? 
				// Reflection
				reflect(rayD, spherePos) :
				// Diffuse
				// fract(sin(seed += .7)*seed) is our random function
				// We create random vector then check if it is facing same way as normal,
				// if not then we flip it
				sign(dot(walls=normalize(vec3(fract(sin(seed += .7)*seed)-.5, 
												fract(sin(seed += .7)*seed)-.5, 
												fract(sin(seed += .7)*seed)-.5)),
									spherePos))*walls; 
		}
	}
	// Set color, if time is over 166. then set color to black, otherwise some artifacts keep
	// appearing from inaccurate sphere interscetions that show even after the light has moved
	// outside of the box, sign(166. - F) returns 1 when F is below 166. and -1 when its above, so
	// multiplying color with that gives us the effect we want
	gl_FragColor = vec4(.02 * result * sign(166. - F), 1);
}
