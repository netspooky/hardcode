//Spiegeley aus Jux
//0a000h 2003 raytracing entry made in povray
#include "textures.inc"
#include "glass.inc"

#version 3.5;

#declare Radiosity=on;

global_settings
{
 assumed_gamma 1.0
 max_trace_level 25
 max_intersections 128
 #if (Radiosity) radiosity
 {
  pretrace_start 0.08           // start pretrace at this size
  pretrace_end   0.04           // end pretrace at this size
  count 35                      // higher -> higher quality (1..1600) [35]
  nearest_count 5               // higher -> higher quality (1..10) [5]
  error_bound 1.8               // higher -> smoother, less accurate [1.8]
  recursion_limit 3             // how much interreflections are calculated (1..5+) [3]
  low_error_factor .5           // reduce error_bound during last pretrace step
  gray_threshold 0.0            // increase for weakening colors (0..1) [0]
  minimum_reuse 0.015           // reuse of old radiosity samples [0.015]
  brightness 1                  // brightness of radiosity effects (0..1) [1]

  adc_bailout 0.01/2
  //normal on                   // take surface normals into account [off]
  //media on                    // take media into account [off]
  //always_sample off           // turn sampling in final trace off [on]
 }
 #end
}

camera{location <0, 0.7, -3.5> look_at <0, 0.3, 0> angle 60}

light_source {<-3, 4, -5> rgb 1.3 fade_distance 6 fade_power 1 spotlight point_at <-2, 0, -2>}

sky_sphere 
{
 pigment
 {
  gradient y
  color_map { [0.0 color rgb <0.25,0.15,0.25>] [1.0 color blue 0.5] }
 }
}

#declare Ei = union
//egg object provided by Ingo Schaefer
{
 difference
 {
  sphere{<0, 0, 0> 0.999}
  box{<-1, 0, -1> <1, 1, 1>}
 }
 difference
 {
  sphere{<0, 0, 0> 0.999 scale<1, 1.7, 1>}
  box{<-1, 0, -1> <1, -1.7, 1>}
 }
 pigment{rgb 1}
 normal{bozo 1 scale 0.02}
}

#declare Floor = plane {y,0}

#declare Mirror =
union
{
 object
 {
  box{<-3, 0, 0>,<3.2, 3.2, 0.05>}
  texture{T_Glass3}
  interior{I_Glass}
  pigment{rgbt<0.4, 0.4, 1, 0.5>}
  finish{specular 0.3 reflection rgb <0.6,0.8,0.7>}
 }
 object
 {
  box{<-3, 0, 0.05>,<3.2, 3.2, 0.06>}
  pigment{rgbt<0, 0, 0, 0>}
  finish{specular 0 reflection 0}
 }
 rotate<2, 30, 0>
 translate<0, 0, 2>
}

#declare Mirroregg =
union
{
 object
 {
  sphere{<-0.15, 0, 0>, 0.5}
  pigment{rgbt<0.8, 0.6, 0, 0.1>}
  finish{specular 0.8 reflection 0.2}
  scale <1.0, 0.3, 1.0>
  translate<0, 0.05, 0>
  no_image
  no_shadow
 }
 object
 {
  sphere{<0, 0, 0>, 0.5}
  pigment{rgbt<0.8, 0.8, 1, 0.2>}
  finish{specular 0.8 reflection 0.02}
  scale <2.0, 0.2, 3.0>
  no_image
  no_shadow
 }
 scale 1.2
 translate<0, 0, -0.5>
}

union
{
 object{Ei rotate<30, 30, 30> translate<-0.7, 0.7, 1>}
 object
 {
  Floor
  pigment{rgbt<0.4, 0.5, 0.2, 0>}
  finish{specular 0.6 reflection 0.1 ambient 0.05}
  normal{granite 0.5 scale 4}
 }
 object{Mirror}
 object{Mirroregg}
 translate<-0.8, -1.5, 0.8>
}