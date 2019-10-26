/*

	Something something by Tick of Excess^TEC
	Made at Solskogen for the one effect web compo-thingy.
	License in LICENSE file.
	
*/

import processing.opengl.* ;

PImage tex;
void setup()
{
	size(1280, 720, OPENGL);
	background(255);
	tex = createImage(256, 256, RGB);
	updateTexture(tex);
}

void updateTexture(PImage tex)
{
	tex.loadPixels();
	for(int i = 0; i < tex.pixels.length; i++)
	{
		tex.pixels[i] = 0xff000000 | ((i&255)<<16) | ((i&255)<<8) | (i&255);
	}
	
	for(int i = 0; i < tex.width; i++)
	{
		tex.pixels[i] = 0xff000000;
		tex.pixels[(tex.width*(tex.height-1)) + i] = 0xff000000;
		tex.pixels[(tex.width*i) + 0] = 0xff000000;
		tex.pixels[(tex.width*i) + (tex.width-1)] = 0xff000000;
		
		
	}
	
	tex.updatePixels();
}

PVector pol2cart(float a, float r)
{
	return new PVector(r*cos(a), r*sin(a));
}

float time;

void draw2()
{
	fill(255, 255, 0, 255);
	textureMode(NORMALIZED);
	stroke(0, 255);
	beginShape(QUAD);
	texture(tex);
	vertex(10, 20, 0, 0);
	vertex(80, 5, 1, 0);
	vertex(95, 90, 1, 1);
	vertex(40, 95, 0, 1);
	endShape();
}

void draw()
{
	time = millis() / (100.0);
	noStroke();
	background(255);
	stroke(0, 255);
	camera(0.0, 100.0, 120.0, 0.0, 0.0, 0.0, 
		0.0, 1.0, 0.0);


	rotateZ(time/123.0);
	rotateY(time/100.0);
	rotateX(time/117.0);
		
	lightSpecular(200, 200, 200);
	directionalLight(204, 204, 204, 0, 0, -1);
	pointLight(240, 240, 240, 1000, 1000, 1000);
	
	
	rotateX(time/43.0);
	rotateY(time/27.0);
	rotateZ(time/33.0);

	// Draw sphere
	noStroke();
	
	specular(255, 100, 100);
	shininess(1.0);
	fill(202, 0, 0);

	pushMatrix();
	rotateZ(time/80.0);
	rotateY(time/94.0);
	rotateX(time/87.0);
	sphere(39.0 + sin(time/327.0)*10.0);
	popMatrix();
	drawCircles(50);


	pushMatrix();
	translate(80, 0, 0);
	rotateZ(-time/32.0);
	rotateY(-time/41.0);
	rotateX(-time/37.0);
	fill(0, 255, 0);
	box(15);
	drawCircles(20);
	popMatrix();

	pushMatrix();
	translate(-80, 0, 0);
	rotateZ(-time/39.0);
	rotateY(-time/31.0);
	rotateX(-time/27.0);
	fill(0, 255, 0);
	box(15);
	drawCircles(20);
	popMatrix();

	drawCircles(50);
	pushMatrix();
	translate(0, 80, 0);
	rotateZ(-time/32.0);
	rotateY(-time/41.0);
	rotateX(-time/37.0);
	fill(0, 255, 0);
	box(15);
	drawCircles(20);
	popMatrix();

	pushMatrix();
	translate(0, -80, 0);
	rotateZ(-time/39.0);
	rotateY(-time/31.0);
	rotateX(-time/27.0);
	fill(0, 255, 0);
	box(15);
	drawCircles(20);
	popMatrix();

	pushMatrix();
	drawBox(200, tex);
	popMatrix();


}

void drawCircles(float s)
{	
	// Draw circles
	stroke(0);
	noFill();
	pushMatrix();
	translate(0.0, 0.0, cos(time/23.0)*s);
	ellipse(0, 0, abs(sin(time/23.0))*(s+s), abs(sin(time/23.0))*(s+s));
	popMatrix();

	pushMatrix();
	translate(0.0, 0.0, sin(time/53.0)*s);
	ellipse(0, 0, abs(cos(time/53.0))*(s+s), abs(cos(time/53.0))*(s+s));
	popMatrix();

	pushMatrix();
	rotateY(HALF_PI);
	translate(0.0, 0.0, cos(time/20.0)*s);
	ellipse(0, 0, abs(sin(time/20.0))*(s+s), abs(sin(time/20.0))*(s+s));
	popMatrix();

	pushMatrix();
	rotateY(HALF_PI);
	translate(0.0, 0.0, sin(time/31.0)*s);
	ellipse(0, 0, abs(cos(time/31.0))*(s+s), abs(cos(time/31.0))*(s+s));
	popMatrix();

	pushMatrix();
	rotateX(HALF_PI);
	translate(0.0, 0.0, cos(time/27.0)*s);
	ellipse(0, 0, abs(sin(time/27.0))*(s+s), abs(sin(time/27.0))*(s+s));
	popMatrix();

	pushMatrix();
	rotateX(HALF_PI);
	translate(0.0, 0.0, sin(time/47.0)*s);
	ellipse(0, 0, abs(cos(time/47.0))*(s+s), abs(cos(time/47.0))*(s+s));
	popMatrix();
}

void drawBox(float size, PImage tex)
{
	textureMode(NORMALIZED);
	beginShape(QUADS);
 
	if(tex != null)
	{
		noStroke();
		fill(255, 255);
		texture(tex);
	}
 
  // -Z "back" face
  vertex( size, -size, -size, 0, 0);
  vertex(-size, -size, -size, 1, 0);
  vertex(-size,  size, -size, 1, 1);
  vertex( size,  size, -size, 0, 1);
 
  // +Z "front" face
  vertex(-size, -size,  size, 0, 0);
  vertex( size, -size,  size, 1, 0);
  vertex( size,  size,  size, 1, 1);
  vertex(-size,  size,  size, 0, 1);
 
  // +Y "bottom" face
  vertex(-size,  size,  size, 0, 0);
  vertex( size,  size,  size, 1, 0);
  vertex( size,  size, -size, 1, 1);
  vertex(-size,  size, -size, 0, 1);
 
  // -Y "top" face
  vertex(-size, -size, -size, 0, 0);
  vertex( size, -size, -size, 1, 0);
  vertex( size, -size,  size, 1, 1);
  vertex(-size, -size,  size, 0, 1);
 
  // +X "right" face
  vertex( size, -size,  size, 0, 0);
  vertex( size, -size, -size, 1, 0);
  vertex( size,  size, -size, 1, 1);
  vertex( size,  size,  size, 0, 1);
 
  // -X "left" face
  vertex(-size, -size, -size, 0, 0);
  vertex(-size, -size,  size, 1, 0);
  vertex(-size,  size,  size, 1, 1);
  vertex(-size,  size, -size, 0, 1);
 
  endShape();

}