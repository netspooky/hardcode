varying vec3 h,n,l,c;

void main()
{
	// vec3(.34,.2,.1)
	gl_FragColor.rgb=(clamp(dot(normalize(n),normalize(l)),0.,1.)*.6+.4)*(c+sin(h.y*15.)*.05);
}
