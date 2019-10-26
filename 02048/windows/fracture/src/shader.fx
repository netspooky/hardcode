texture Tex;
sampler t0=sampler_state{Texture=(Tex);MipFilter=NONE;MinFilter=NONE;MagFilter=NONE;};
float2 reso;
float time;
struct vs2ps{float4 op:POSITION0;float4 np:TEXCOORD0;};
vs2ps VS(float4 In:POSITION0){vs2ps Out;Out.op=Out.np=sign(In);Out.np*=float4(1.,-1.,1.,1.);return Out;}
float2 r(float a,float2 xy){return float2(xy.x*cos(a)-xy.y*sin(a),xy.x*sin(a)+xy.y*cos(a));}
float2 m(float2 a, float2 b){return float2(a.x*b.x-a.y*b.y,a.x*b.y+b.x*a.y);}
float4 p(float4 np,float t){
       float4 c=tex2D(t0,np.xy*.5+.5+.25/reso);
       c.xyz=lerp(c.xyz,float3(lerp(m(c,c),m(c,m(c,c)),smoothstep(-1.0,1.0,sin(t*1.7))*smoothstep(0.0,1.0,smoothstep(-1.0,1.0,sin(t*7.3))))*(1.+.75*sin(t*31.4)*sin(t*7.))+1.5*sin((t+sin(t*float2(3.6,2.2)))*float2(13.1,17.4)),c.z+.3+0.15*sin(t*7.3)),pow(smoothstep(69.+50.*sin(t*8.),2.,length(c.xy)),.7));
       c.xy=lerp(r(t*8.,np.yx*float2(1.,reso.x/reso.y)*(5.+4.*sin(t*47.3)))+3.*sin(t*float2(45.2,27.5)),c.xy,(0.63+0.25*sin(t*9.3+sin(t*2.2)))*smoothstep(0.9,-0.9,sin(t*44.3+3.0*sin(t*4.1))));
       if(sin((time+sin(t*5.0))*17.)>.999)c.xyz=.0;
       c.z*=pow(.5+.5*sin(t*8.),.01);
       return float4(c.xyz,1.);
}
float4 f(float4 c){
       return float4(.5+.5*sin((1.-sin(float3(.15,.17,.2)*(c.z+1.0)+time*3.3)*2.)+c.z*.7+4./pow(length(c.xy),.2)+time*38.+sin(time*4.6)*8.*pow(dot(1./abs(c.xy),0.3),.03)),1.);

}
float4 PX(float4 np:TEXCOORD0):COLOR0{
       return p(np,time);
}
float4 PY(float4 np:TEXCOORD0):COLOR0{
       return f(tex2D(t0,np.xy*.5+.5+.25/reso));
}
float4 Pm(float4 np:TEXCOORD0):COLOR0{
       float4 d=0.0;
       for (float i=0.0;i<=1.0;i+=1.0/12.0){
       float off=(i-0.5);
       float2 aa=sin(3.1415*2.0*(i*2.0+float2(0.25,0.0)))*(0.75+0.75*i)/reso;
       float4 c=p(np+aa.xyyy,time+(off-0.5)*0.009);
       c=f(c);
       d+=saturate(c)*2.0*smoothstep(0.499,0.0,abs(off));
       }
       d=d/(12.0);
       return d;
}
technique feedback
{
    pass x
    {
        VertexShader = compile vs_2_0 VS();
        PixelShader  = compile ps_2_0 PX();
    }
}
technique noblur
{
    pass y
    {
        VertexShader = compile vs_2_0 VS();
        PixelShader  = compile ps_2_0 PY();
    }
}
technique motionblur
{
    pass m
    {
        VertexShader = compile vs_3_0 VS();
        PixelShader  = compile ps_3_0 Pm();
    }

}