camera{
location<-5,3.5,-10>
direction<0,0,1>
look_at<0,2,0>
}
//light_source{<0,5,-1.5>color<1,1,1>}
light_source{<0,2,-1.5>color<1,1,1>}
background{color<.5,.5,1>}
fog{                                    
color rgb<.5,.5,1>
distance 10
}
plane{y, 0
pigment{rgb<1,1,1>}
finish{reflection<.2,.2,.2>}
// normal{perlin 1}
}
cylinder{<-1.8,0,0>,<-1.8,2.5,0>,.25
pigment{color rgb<1,1,1>}
}
cylinder{<-1.8,0,2>,<-1.8,2.5,2>,.25
pigment{color rgb<1,1,1>}
}
cylinder{<-1.8,0,4>,<-1.8,2.5,4>,.25
pigment{color rgb<1,1,1>}
}

cylinder{<1.8,0,0>,<1.8,2.5,0>,.25
pigment{color rgb<1,1,1>}
}
cylinder{<1.8,0,2>,<1.8,2.5,2>,.25
pigment{color rgb<1,1,1>}
}
cylinder{<1.8,0,4>,<1.8,2.5,4>,.25
pigment{color rgb<1,1,1>}
}

box{<-2.75, 0, -1.4>,<2.75,0.1, 5>
pigment{color rgb<1,1,1>}
no_shadow
}
box{<-2.5, 0, -1.2>,<2.5,0.2, 5>
pigment{color rgb<1,1,1>}
no_shadow
}
box{<-2.25, 0, -1>,<2.25,0.3, 5>
pigment{color rgb<1,1,1>}
no_shadow
}

box{<-2.25, 2.5, -1>,<2.25,2.75, 5>
pigment{color rgb<1,1,1>}
}

sphere{<0,1.5,2>,0.5
pigment{rgb<0,0,0>}
finish{reflection<.5,.5,.5> metallic}
}

cylinder{<0,0,2>,<0,1,2>,0.5
pigment{rgb<.75,.5,.25>}
finish{reflection<.5,.5,.5> metallic}
}

triangle{
<-2.25,2.75,-1>,<2.25,2.75,-1>,<0,3.5,-1>
pigment{color rgb<1,1,1>}
no_shadow
}
triangle{
<-2.25,2.75,5>,<2.25,2.75,5>,<0,3.5,5>
pigment{color rgb<1,1,1>}
no_shadow
}
triangle{
<-2.25,2.75,-1>,<-2.25,2.75,5>,<0,3.5,-1>
pigment{color rgb<1,1,1>}
no_shadow
}
triangle{
<0,3.5,5>,<-2.25,2.75,5>,<0,3.5,-1>
pigment{color rgb<1,1,1>}
no_shadow
}
triangle{
<2.25,2.75,-1>,<2.25,2.75,5>,<0,3.5,-1>
pigment{color rgb<1,1,1>}
no_shadow
}
triangle{
<0,3.5,5>,<2.25,2.75,5>,<0,3.5,-1>
pigment{color rgb<1,1,1>}
no_shadow
}


// EOF 
