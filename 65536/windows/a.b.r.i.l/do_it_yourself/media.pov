camera{
location<0,1,-7>
direction<0,0,1>
look_at<0,1.5,0>
}
light_source{<0,3,0>colour<1,1,1>}
light_source{<0,3,-5>colour<.2,.2,.2>}
plane{z,4 pigment{rgb<.5,.5,.5 >}no_shadow}
plane{x,-2 pigment{rgb<.5,.5,.5>}no_shadow}
plane{x,2 pigment{rgb<.5,.5,.5>}no_shadow}
cylinder{< 0,3.25,0 >,< 0,3.5,0 >,1
open
pigment{rgb<1,1,1>}
}
cylinder{< -1.5,0,-3 >,< -1.5,3.5,-3 >,.1
pigment{rgb<1,1,1>}
}
cylinder{< -.75,0,-3 >,< -.75,3.5,-3 >,.1
pigment{rgb<1,1,1>}
}
cylinder{< 0,0,-3 >,< 0,3.5,-3 >,.1
pigment{rgb<1,1,1>}
}
cylinder{<.75,0,-3 >,< .75,3.5,-3 >,.1
pigment{rgb<1,1,1>}
}
cylinder{< 1.5,0,-3 >,< 1.5,3.5,-3 >,.1
pigment{rgb<1,1,1>}
}
disc{<0,3.5,0 >,< 0,1,0 >,200,1
pigment{rgb<1,1,1>}
no_shadow
}
plane{y,0 pigment{rgb<.5,.5,.5>}no_shadow}
box{<-.5,1,-.5 >,< .5,2,.5 >
pigment{image_map blah}
}
// EOF
