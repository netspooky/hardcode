var A = window;
b.setAttribute("style","background:#000;position:absolute;top:0;left:0");
B = b.cloneNode(0);
D = B.getContext("2d");
A.onresize = function() {b.width = A.innerWidth;b.height = A.innerHeight;};
A.onresize();
var d = c();
var e = 0;
var m = Math;
var R = m.random;
var points = [];
var S = m.sin;
var C = m.cos;
var F = 2*m.PI;

function draw() {
	var width = b.width;
	b.width = width; // Clear the canvas
	var height = b.height;
	var ratio = width/height;

	// Generate a ring of particles
	e++;
	var x,y,y1,z1,x2,z2,z3,p,r1=.11*e,r2=.043*e,r3=.0081*e,i,x3,y3,R,Z=S(.0048*e);
	for(i=0;i<20;i++) {
		p=points[i];
		// Camera position-adjustment
		
		R = m.pow((i%2?.5:2),S(.027*e));
		x = p.x * C(r1) + S(r1) * p.y;
		x*=R;
		y = p.y * C(r1) - S(r1) * p.x;
		y*=R;

		y1 = y * C(r2) + p.z*S(r2)+Z;
		z1 = p.z * C(r2) - y * S(r2)+Z;

		x2 = x*C(r3)+z1*S(r3);
		z2 = z1*C(r3)-x*S(r3);

		z3 = z2 + S(.0092*e)+1;
		if(z3 > 0) {
			with(d) {
				globalCompositeOperation = "lighter";
				scale(width / 2 / ratio, height / 2);
				translate(ratio, 1);
				fillStyle = p.c;
				beginPath();
				arc(x2/z3,y1/z3,.1/z3,0,F);
				fill();
				closePath();
				translate(-ratio,-1);
				scale(2*ratio/width,2/height);
			}

		}
	}
	

	var n="drawImage";
	for(i=0;i<4;i++) {
		d.globalAlpha /= 2;
		B.width = .5*width;
		B.height = .5*height;
		D[n](b,width/-20,height/-20,.6*width,.6*height);
		d[n](B,0,0,width,height);
	}

}
function createPoints() {
	var f = F/20;
	for(var i=0;i<20;i++) {
		points[i] = {x:C(f*i),y:S(f*i),z:.1*(i%2-.5),c:"rgb("+(256*R() >> 0)+","+(256*R() >> 0)+","+(256*R() >> 0)+")"};
	}
}
createPoints();
A.setInterval(draw,10);

