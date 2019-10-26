camera{
location<-50,3.5,-150>
direction<0,0,1>
look_at<0,2,0>
}

background{color<.5,.5,1>}
fog{                                    
color rgb<.5,.5,1>
distance 400
}
plane{y, -10
pigment{checker rgb<.5,0,1>, rgb<1,0,1>}
finish{reflection<.2,.2,.2>} 
no_shadow
// normal{perlin 1}
}

sphere{<50,0,0>, 10
pigment{perlin}
}
//light_source{<0,5,-1.5>color<1,1,1>}
light_source{<100,20,-250>color<1,1,1>}
    triangle {
      <0,31.96,0>, <28.58,14.29,0>, <8.833,14.29,-27.18>
      pigment{rgb<1,1,1>}
      finish{reflection<.2,.2,.2>}
    }
    triangle {
      <0,31.96,0>, <8.833,14.29,-27.18>, <-23.12,14.29,-16.8>   pigment{rgb<1,1,1>}
      finish{reflection<.2,.2,.2>}
    }
    triangle {
      <0,31.96,0>, <-23.12,14.29,-16.8>, <-23.12,14.29,16.8>  pigment{rgb<1,1,1>}
      finish{reflection<.2,.2,.2>}
    }
    triangle {
      <0,31.96,0>, <-23.12,14.29,16.8>, <8.833,14.29,27.18>   pigment{rgb<1,1,1>}
      finish{reflection<.2,.2,.2>}
    }
    triangle {
      <0,31.96,0>, <8.833,14.29,27.18>, <28.58,14.29,0>   pigment{rgb<1,1,1>}
      finish{reflection<.2,.2,.2>}
    }
    triangle {
      <28.58,14.29,0>, <23.12,-14.29,16.8>, <23.12,-14.29,-16.8>   pigment{rgb<1,1,1>}
      finish{reflection<.2,.2,.2>}
    }
    triangle {
      <8.833,14.29,-27.18>, <23.12,-14.29,-16.8>, <-8.833,-14.29,-27.18>  pigment{rgb<1,1,1>}
      finish{reflection<.2,.2,.2>}
    }
    triangle {
      <-23.12,14.29,-16.8>, <-8.833,-14.29,-27.18>, <-28.58,-14.29,0>  pigment{rgb<1,1,1>}
      finish{reflection<.2,.2,.2>}
    }
    triangle {
      <-23.12,14.29,16.8>, <-28.58,-14.29,0>, <-8.833,-14.29,27.18> pigment{rgb<1,1,1>}
      finish{reflection<.2,.2,.2>}
    }
    triangle {
      <8.833,14.29,27.18>, <-8.833,-14.29,27.18>, <23.12,-14.29,16.8> pigment{rgb<1,1,1>}
      finish{reflection<.2,.2,.2>}
    }
    triangle {
      <23.12,-14.29,-16.8>, <8.833,14.29,-27.18>, <28.58,14.29,0> pigment{rgb<1,1,1>}
      finish{reflection<.2,.2,.2>}
    }
    triangle {
      <-8.833,-14.29,-27.18>, <-23.12,14.29,-16.8>, <8.833,14.29,-27.18>  pigment{rgb<1,1,1>}
      finish{reflection<.2,.2,.2>}
    }
    triangle {
      <-28.58,-14.29,0>, <-23.12,14.29,16.8>, <-23.12,14.29,-16.8> pigment{rgb<1,1,1>}
      finish{reflection<.2,.2,.2>}
    }
    triangle {
      <-8.833,-14.29,27.18>, <8.833,14.29,27.18>, <-23.12,14.29,16.8>  pigment{rgb<1,1,1>}
      finish{reflection<.2,.2,.2>}
    }
    triangle {
      <23.12,-14.29,16.8>, <28.58,14.29,0>, <8.833,14.29,27.18>  pigment{rgb<1,1,1>}
      finish{reflection<.2,.2,.2>}
    }
    triangle {
      <0,-31.96,0>, <-8.833,-14.29,-27.18>, <23.12,-14.29,-16.8>  pigment{rgb<1,1,1>}
      finish{reflection<.2,.2,.2>}
    }
    triangle {
      <0,-31.96,0>, <-28.58,-14.29,0>, <-8.833,-14.29,-27.18>  pigment{rgb<1,1,1>}
      finish{reflection<.2,.2,.2>}
    }
    triangle {
      <0,-31.96,0>, <-8.833,-14.29,27.18>, <-28.58,-14.29,0>   pigment{rgb<1,1,1>}
      finish{reflection<.2,.2,.2>}
    }
    triangle {
      <0,-31.96,0>, <23.12,-14.29,16.8>, <-8.833,-14.29,27.18>  pigment{rgb<1,1,1>}
      finish{reflection<.2,.2,.2>}
    }
    triangle {
      <0,-31.96,0>, <23.12,-14.29,-16.8>, <23.12,-14.29,16.8>   pigment{rgb<1,1,1>}
      finish{reflection<.2,.2,.2>}
    }



// EOF
