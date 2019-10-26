/*
   conversions:

   * multiplex several channels to one
   * enhance chip instruments with pulse stuff, adsr functions,
     toneslides, vibrato etc

     sound_setins(2,VIBRATO|TONESLIDE|FASTSWEEP|SLOWDECAY);

     sound_playsample(BASSDRUM);
     
     sound_loadsample(5,dataptr,length);
     sound_loadstream(4,streamgenerator);

   when samples supported:

   * emulate samples with chip capablities

   if channel-based sound device:
   
   * implement echoes with additional channels
     (if using digital buffer: use another technique)

     sound_echo(delay,shift);

*/