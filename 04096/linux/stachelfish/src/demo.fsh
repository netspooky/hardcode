#version 120
#extension GL_EXT_gpu_shader4 : enable
#define c0(x) (x>0.0?x:0)
#define t1(x,y) (texture1D(x,y))
uniform float t;
uniform isampler1D p;
float wd=1280;
float ht=720;
float asp=wd/ht;
vec3 sc=vec3(0,0,-3);
float sr=1.5;
float fd(float t){return t*t*t*(t*(t*6.0-15.0)+10.0);}
float gr(int hash,vec3 vec){int h=hash&15;float u=h<8?vec.x:vec.y,v=h<4?vec.y:h==12||h==14?vec.x:vec.z;return((h&1)==0?u:-u)+((h&2)==0?v:-v);}
float ns(vec3 Q) 
{
    ivec3 V=ivec3(floor(Q))&255;
    Q-=floor(Q);
    float u=fd(Q.x),v=fd(Q.y),w=fd(Q.z);
    int A=t1(p,V.x/256.0).x+V.y,
        AA=t1(p,A/256.0).x+V.z,
        AB=t1(p,(A+1)/256.0).x+V.z,
        B=t1(p,(V.x+1)/256.0).x+V.y,
        BA=t1(p,B/256.0).x+V.z,
        BB=t1(p,(B+1)/256.0).x+V.z;

    return mix(mix(mix(gr(t1(p,AA/256.0).x,vec3(Q.x,Q.y,Q.z)),
                       gr(t1(p,BA/256.0).x,vec3(Q.x-1,Q.y,Q.z)),
                       u),
                   mix(gr(t1(p,AB/256.0).x,vec3(Q.x,Q.y-1,Q.z)),
                       gr(t1(p,BB/256.0).x,vec3(Q.x-1,Q.y-1,Q.z)),
                       u),
                   v),
               mix(mix(gr(t1(p,(AA+1)/256.0).x,vec3(Q.x,Q.y,Q.z-1)),
                       gr(t1(p,(BA+1)/256.0).x,vec3(Q.x-1,Q.y,Q.z-1)),
                       u),
                   mix(gr(t1(p,(AB+1)/256.0).x,vec3(Q.x,Q.y-1,Q.z-1)),
                       gr(t1(p,(BB+1)/256.0).x,vec3(Q.x-1,Q.y-1,Q.z-1)),
                       u),
                   v),
               w);
}

vec3 sn(vec3 p) {
    return normalize(p-sc);
}

float ss(vec3 p) {return length(p-sc)-sr+sin(t)*0.2*sin(20.0*normalize(p-sc).x+t)+sin(t)*0.2*sin(20.0*normalize(p-sc).y+t);}

float bs(vec3 p){return length(p-sc)-1.0+1.0*sin(2.0*p.y+t);}

void main()
{
    vec4 r=normalize(mat4(2.0*asp/wd,0.0,0.0,0.0,0.0,2.0/ht,0.0,0.0,0.0,0.0,0.0,0.0,-asp,-1.0,-1.0,1.0)*gl_FragCoord);

    vec3 r_s=vec3(r);
    int n_steps=int(3.0/0.1);
    vec3 r_inc=r_s*0.1;

    float s=1.0,ms=0.05;
    int i=0,imax=30;
    while((s>ms)&&(i<imax)){
        s=mix(ss(r_s),bs(r_s),(sin(t)+1.0)/2.0);
        r_s+=vec3(r.xyz)*s;
        i++;
    }

    vec4 fc=vec4(0.0);
    if(s<=ms){
        vec3 n=sn(r_s);
        fc=(c0(dot(n,normalize(vec3(sin(t),cos(t),0.0)-r_s)))*vec4(1.0)
                      +c0(dot(n,normalize(vec3(-sin(t),sin(t),cos(t))-r_s)))*vec4(0.1,0.8,0.9,1.0)+0.25)
            *mix(vec4(1.0,0.6,0.25,1.0),
                 vec4(1.0,1.0,1.0,1.0),
                 ns((r_s-vec3(0.1*t,0.1,-0.1))*10.0));
    }

    float z=-r.z;
    vec3 c=vec3(0.407,0.615,0.725)*vec3(sin(t),sin(0.5*t),cos(0.75*t));
    gl_FragColor=mix(vec4(c,1.0),vec4(1.0),ns(r.xyz*3.0+vec3(t,0.0,0.0))) + fc * (0.75+sin(t)*0.25);
}
