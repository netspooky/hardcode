camera{
location<0,3.5,-10>
direction<0,0,1>
look_at<0,2,0>
}
light_source{<0,5,-1.5>color<1,1,1>}
fog{                                    
color rgb<.9,.9,.8>
distance 10
}
plane {y,0
pigment{color rgb<.45,.45,.4>}
}
sphere{<0,4,0>,1
pigment{color rgb<.45,.45,.4>}
finish{reflection<.5,.5,.5>}
}
cylinder{<0,0,0>,<0,4,0>,.25
pigment{rgb<0,0,0>}
}
sphere{<0,2,-2>,1
pigment{color rgb<.45,.45,.4>}
finish{reflection<.5,.5,.5>}
}
sphere{<-2,2,0>,1
pigment{color rgb<.45,.45,.4>}
finish{reflection<.5,.5,.5>}
}
sphere{<2,2,0>,1
pigment{color rgb<.45,.45,.4>}
finish{reflection<.5,.5,.5>}
}
sphere{<0,2,2>,1
pigment{color rgb<.45,.45,.4>}
finish{reflection<.5,.5,.5>}
}
// EOF
