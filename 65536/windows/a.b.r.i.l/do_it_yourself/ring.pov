camera{
location<-3.5,3.5,-5>
direction<0,0,1>
look_at<0,1,0>
}
light_source{<0,5,-1.5>color<1,1,1>}
background{color<.3,.3,.3>}
box{<-2, -1, -2>,<2, 0, 2>
// pigment{perlin}
}
cylinder{<0,0,0>,<0,0.5,0>,1
open
pigment{rgb<.75,.75,.25>}
finish{reflection<0.5,0.5,0.5>}
}      
cylinder{< 0,0,0>,< 0,0.5,0 >,0.9
open
pigment{rgb<.75,.75,.25>}
finish{reflection<0.5,0.5,0.5>}
}             
disc{< 0,0.5,0>,<0,1,0>,1,.9
pigment{rgb<.75,.75,.25>}
finish{reflection<0.5,0.5,0.5>}
}
// EOF 
