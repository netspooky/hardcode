The Essence of Jazz
1k intro
for Windows
by Yzi/Fit
Released at Demodays 2012 a.k.a. Buenzli, placed 5th in the realtime size-limited compo.


As is usual in 1k intros, the music timing is done with Sleep() between frames (and/or vsync if it happens to get activated on your system). 
I compiled versions with different resolutions and Sleep() time values, so try out what if any works for you. 
The version I sent to the compo was 1920x1080 and 16ms sleep, but in the compo it looked like it was too slow. With 16ms of sleep, there isn't much time left for the visuals to make it 60fps. My dev/test pc had GTX670 and the compo machine had GTX680, so I figured it would be at least as fast, but apparently not then.
