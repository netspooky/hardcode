Runtime Captain Pike, a runtime tune by SigFlup(Thea DeSilva) 
for release at Block-Party '08

Not everyone has a 9600 baud modem, so you're in luck. This is 
reasonably small. Not everyone has the IBM extended character-
set, holy-shit smalls! You're in luck again. You do however 
need a 80x40 vt100 terminal!

If we are unable to get playback or the user has given us the "-d" 
argument, no graphics will be shown. We'll dump audio to run.dump 
and exit. run.dump is raw 22050Hz signed-16bit
samples with one channel. 

sox -t raw -r 22050 -sw -c 1 run.dump out.wav

ought to do the trick to convert it. 
 

User license: Do whatever the fuck you want with this
              Just don't hurt any cats or babies.
              If you have more then one hundred employees
              don't use this in any advertising. Thanks
