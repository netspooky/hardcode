float t = 300*gl_Color.x,y;
void F(vec3 v) {
	y=4;
	for(int i=0; i<9; ++i)
		y -= 1/length(2*sin(.4*t*sin(vec3(i,1+i,2-i)))-v+vec3(.04*sin(10*v.y),.04*sin(10*v.z+t+v.x),9+exp(.1*t-18)));
}
void main() {
//	float y,o;//,e=1e-3;
	vec3 v = vec3(gl_FragCoord.xy/vec2(WIDTH,HEIGHT)-.5,1), c=0, g, h=0;
	h.x=.001;

	for(int i=0; i<50; ++i)
		g = vec3((F(c+h),y), (F(c+h.yxz),y), (F(c+h.yzx),y))-(F(c),y),
		c += min(.0001*y/length(g),1)*v;

	g = normalize(g);
	h = normalize(sin(vec3(t,1.1*t,-1)));
//	h = normalize(vec3(sin(t),sin(1.1*t),-1));
	y = dot(v, reflect(h, g)); //*max(0.1*t-20,1);
	gl_FragColor = y*y;
	gl_FragColor.y+=dot(h,g);
	gl_FragColor.x += sin(length(c)/2-t);
//	gl_FragColor.x += sin(c.x)*sin(c.z+t)*sin(t/5);
}
