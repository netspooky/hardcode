#pragma once

#pragma data_seg(".shaders")
static char* fsh =
	"#define ve return\n" // Line 1
	"#define ec float\n" // Line 1
	"varying vec4 Y;" // Line 6
	"varying vec2 Z;" // Line 9
	"vec4 R(vec3 n,vec3 m,int k);" // Line 12
	"vec3 T(vec4 j,vec3 l,vec3 m);" // Line 13
	"vec3 f,b,a,h,e,d,X;" // Line 17
	"ec g,W,c,V,U;ec A(vec2 j){" // Line 18
	"int i=int(j.x*40+j.y*6400);" // Line 24
	"i=(i<<13)^i;" // Line 25
	"ve 1-ec((i*(i*i*15731+789221)+1376312589)&0x7fffffff)/1073741824;}ec B(vec2 k){" // Line 26
	"k=mod(k,1000.);" // Line 33
	"vec2 i=fract(k);" // Line 34
	"k-=i;" // Line 35
	"vec2 j=i*i*(3.-2.*i);" // Line 36
	"ve mix(" // Line 37
	"mix(A(k+vec2(0,0)),A(k+vec2(1,0)),j.x)," // Line 38
	"mix(A(k+vec2(0,1)),A(k+vec2(1,1)),j.x),j.y);}ec C(ec i){" // Line 39
	"ve i*.5+.5;}ec D(ec k,ec l,ec j){" // Line 46
	"ec i=(" // Line 53
	"C(sin(c*2*(k+l+Y.y*j)))+" // Line 54
	"C(sin(c*(l-k-Y.y*j)))+" // Line 55
	"C(sin(c*(l+Y.y*j)))+" // Line 56
	"C(sin(c*3*(k-Y.y*j))))*.3;" // Line 57
	"ve pow(i,2.);}vec3 E(vec3 j){" // Line 58
	"int i=int(mod(gl_FragCoord.x,3.));" // Line 65
	"if(i==0)j*=X.xyz;" // Line 66
	"if(i==1)j*=X.yzx;" // Line 67
	"if(i==2)j*=X.zxy;" // Line 68
	"ve mix(j,vec3(C(B(Z*333+A(vec2(Y.y))*33333))),Y.x*.3+.03);}vec3 F(vec3 i){" // Line 69
	"vec2 j=Z*2-1;" // Line 76
	"ec k=j.x*(j.y+3);" // Line 77
	"ve i+a*" // Line 78
	"D(k+50*e.x,k+50*e.z,1.5)*" // Line 79
	"(C(j.y))*min(-e.y*30,.3);}ec G(vec2 i){" // Line 80
	"ve (-.035+pow((D(i.x*10,i.y*10,.0)*2-1),2.)*.05)" // Line 87
	"-(i.x-.1)*.2;}vec3 H(vec3 i){" // Line 88
	"ve normalize(vec3(" // Line 95
	"G(i.xz-vec2(U,0))-G(i.xz+vec2(U,0))," // Line 96
	"2*U," // Line 97
	"G(i.xz-vec2(0,U))-G(i.xz+vec2(0,U))));}vec3 I(vec3 i,vec3 j){" // Line 98
	"ve (.3+.7*max(dot(j,b),.0))*a*i;}vec3 J(vec3 i){" // Line 105
	"ve normalize(vec3(" // Line 112
	"D(i.x*160-cos(i.z*10)*12,i.z*140,4.)," // Line 113
	"8," // Line 114
	"D(i.z*160-sin(i.x*10)*12,i.x*140,4.))*2-1);}vec3 K(vec3 k,vec3 l){" // Line 115
	"vec3 j=H(k);" // Line 122
	"vec3 i=mix(" // Line 123
	"vec3(.66,.55,.4)" // Line 125
	"-.2*B(abs(k.xz*150))" // Line 128
	"-.2*B(abs(k.yy+.002*B(abs(k.xz*150)))*3000)," // Line 131
	"vec3(.1,.3,0)*(B(k.xz*7000.)*.4+.5)," // Line 134
	"clamp(j.y*(D(k.x*111,k.z*111,.0)*.5-k.y*40),.0,1.));" // Line 137
	"if(k.y<=0)" // Line 140
	"i+=5*J(.8*k).x*min(.3,-k.y*8);" // Line 141
	"ve I(i,j);}vec3 L(vec3 j,vec3 i){" // Line 144
	"ve j.y<=-V*V?" // Line 151
	"h:" // Line 152
	"(1+Y.z*.3)*mix(vec3(-.5,-.25,0),vec3(2),1-(i.y*.5+.5));}vec3 M(vec3 k,vec3 j){" // Line 153
	"vec3 m=J(k);" // Line 162
	"vec4 l=R(k,refract(j,m,.9),2);" // Line 166
	"ec i=clamp(pow(1.03*(1-length(l.xyz-k)),16.),.0,1.);" // Line 169
	"ve mix(" // Line 172
	"e.y<0?L(k,j):h," // Line 173
	"mix(" // Line 174
	"T(R(k,reflect(j,m),2),k,j)," // Line 175
	"T(l,k,j)," // Line 176
	"clamp(-d.y+i,.0,1.))," // Line 177
	"l.w==3.?.5:pow(i,.5));}vec3 N(vec3 l,vec3 m){" // Line 178
	"vec3 k,j;" // Line 186
	"k=normalize(l-f);" // Line 194
	"vec2 o=.5+.5*vec2(atan(k.z,k.x),acos(k.y))/c;" // Line 197
	"o.x-=Y.y;" // Line 200
	"j=mix(vec3(1),vec3(1,0,0),mod(step(fract(o.x*6),.5)+step(fract(o.y*6),.5),2.));" // Line 203
	"ve I(j,k)" // Line 205
	"+pow(max(dot(k,normalize(b-m)),.0),33.)*a;}ec O(vec3 n,vec3 m,ec l){" // Line 206
	"ec i,j,k,p;" // Line 214
	"i=0;" // Line 215
	"vec3 o=n;" // Line 216
	"for(ec q=0;q<l;q+=i)" // Line 219
	"{" // Line 220
	"o+=m*i;" // Line 222
	"p=o.y;" // Line 223
	"ec r=G(o.xz);" // Line 226
	"if(p<=r)" // Line 228
	"{" // Line 229
	"ve q-i+i*(j-k)/(p-r+j-k);}" // Line 232
	"j=r;" // Line 237
	"k=p;" // Line 238
	"i=.002+(q/W);}" // Line 242
	"ve 9.;}ec P(vec3 m,vec3 l){" // Line 246
	"vec3 k=m-f;" // Line 253
	"ec i,j;" // Line 254
	"i=dot(k,l);" // Line 255
	"if(i>0)" // Line 256
	"ve 9.;" // Line 257
	"j=i*i-dot(k,k)+g*g;" // Line 258
	"if(j>0)" // Line 259
	"{" // Line 260
	"ve -i-sqrt(j);}" // Line 261
	"ve 9.;}ec Q(vec3 j,vec3 i){" // Line 263
	"ec k=-j.y/i.y;" // Line 270
	"ve k>=V?k:9.;}vec4 R(vec3 n,vec3 m,int k){" // Line 271
	"ec p,i,o,l;" // Line 283
	"p=k!=2?Q(n,m):9.;" // Line 286
	"i=k!=3?P(n,m):9.;" // Line 287
	"o=k!=1?O(n,m,min(.5,.002+min(p,i))):9.;" // Line 288
	"W/=20;" // Line 291
	"l=min(o,min(p,min(i,9.)));" // Line 294
	"if(l==9)" // Line 297
	"ve vec4(0);" // Line 298
	"vec3 j=n+m*l;" // Line 301
	"if(l==o)" // Line 304
	"ve vec4(j,1);" // Line 305
	"if(l==p)" // Line 306
	"ve vec4(j,2);" // Line 307
	"if(l==i)" // Line 308
	"ve vec4(j,3);}vec3 S(vec4 j,vec3 l,vec3 m){" // Line 309
	"vec3 k=l.y<V?h:L(e,m);" // Line 320
	"ec i=clamp(length(j.xyz-l)*(e.y<=0?4:2),.0,1.);" // Line 323
	"if(j.w==1)" // Line 327
	"ve mix(K(j.xyz,m),k,i);" // Line 328
	"if(j.w==2)" // Line 329
	"ve mix(M(j.xyz,m),k,i);" // Line 330
	"if(j.w==3)" // Line 331
	"ve mix(" // Line 332
	"mix(N(j.xyz,m),T(R(j.xyz,reflect(m,normalize(j.xyz-f)),3),j.xyz,m),.5)" // Line 334
	",k,i);" // Line 335
	"ve L(l,m);}vec3 T(vec4 j,vec3 l,vec3 m){" // Line 337
	"vec3 k=l.y<V?h:L(e,m);" // Line 346
	"ec i=clamp(length(j.xyz-l)*(e.y<=0?4:2),.0,1.);" // Line 349
	"if(j.w==1)" // Line 352
	"ve mix(K(j.xyz,m),k,i);" // Line 353
	"if(j.w==2)" // Line 354
	"ve mix(h,k,i);" // Line 355
	"if(j.w==3)" // Line 356
	"ve mix(N(j.xyz,m),k,i);" // Line 357
	"ve k;}void main(){" // Line 359
	"W=100;" // Line 373
	"c=3.1416;" // Line 376
	"X=vec3(1.2,.9,.9);" // Line 377
	"V=.0001;" // Line 378
	"U=.01;" // Line 379
	"ec k=10;" // Line 382
	"int j=int(Y.y);" // Line 385
	"d=vec3((Z.xy-.5),1);" // Line 388
	"if(j>22&&j<27)" // Line 391
	"{" // Line 392
	"k=min(1.,sin((Y.y-23)*c*.25)*12);" // Line 393
	"e=vec3(.12,.005,Y.y*.08);" // Line 394
	"d=vec3(gl_ModelViewMatrix*vec4(d,1));" // Line 395
	"d.y+=.1*cos(Y.y*4);}" // Line 396
	"else if(j>14&&j<23)" // Line 399
	"{" // Line 400
	"k=min(1.,sin((Y.y-15)*c*.125)*24);" // Line 401
	"d+=vec3(0,.1*cos(Y.y*4),0);" // Line 402
	"e=vec3(.08,.01*sin(Y.y*4)+.002,Y.y*.11);}" // Line 403
	"else " // Line 407
	"{" // Line 408
	"e=vec3(.1,.004,.0)+vec3(.1,.005,20)" // Line 410
	"*vec3(A(vec2(j,k++)),A(vec2(j,k++)),A(vec2(j,k++)));" // Line 411
	"e=mix(" // Line 414
	"e+vec3(.008)*vec3(A(vec2(j,k++)),A(vec2(j,k++)),A(vec2(j,k++)))," // Line 415
	"e+vec3(.008)*vec3(A(vec2(j,k++)),A(vec2(j,k++)),A(vec2(j,k++)))," // Line 416
	"Y.y-j);" // Line 418
	"e.y+=G(e.xz)+.02;" // Line 421
	"e+=.02*H(e);" // Line 424
	"k=min(1.,step(-28.,-Y.y)*sin((Y.y-j)*c)*3);}" // Line 427
	"d=normalize(d);" // Line 430
	"if(j>22&&j<27)" // Line 434
	"f=e+.1*vec3(gl_ModelViewMatrix*vec4(0,0,1,1));" // Line 435
	"else " // Line 437
	"f=e+.02*vec3(sin(Y.y),0,5+cos(Y.y));" // Line 438
	"f.y+=.01+G(f.xz);" // Line 440
	"g=j<14?.0:U*.5+U*Y.z;" // Line 441
	"f+=2*U*H(f);" // Line 442
	"b=vec3(.58,.58,-.58);" // Line 445
	"a=vec3(1.2)+Y.z;" // Line 446
	"h=(1+Y.z*.3)*vec3(.3,.33,.4);" // Line 447
	"if(e.y<=0)" // Line 450
	"{" // Line 451
	"W*=.75;" // Line 453
	"a*=.8;}" // Line 456
	"vec3 i=S(R(e,d,0),e,d);" // Line 460
	"if(e.y<=0)" // Line 464
	"i=F(i);" // Line 465
	"gl_FragColor.xyz=E(step(2.,Y.y)*k*i);}";
