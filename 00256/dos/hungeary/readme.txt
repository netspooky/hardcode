"hungeary" - HellMood^DESiRE
256b msdos entry for Function 2017

Hello =)

If you could test this and ping me if it works / doesn't work, that'd be awesome =)

video for comparison :
https://youtu.be/mPxcCtUnniM

One last note : Tiny intros might hook into the timer interrupt and not "release" it. This
would be still be active after the intro and affect the next one - most likely very badly.
This one here doesn't (it simply syncs to VGA retrace) but others might. In case any
intro suffers unexpectedly from heavy slowdowns or strange side effects, a restart
might solve issues =)

Greetings, HellMood
