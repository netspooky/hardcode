var D = document;
var title_options = ['Eternal 3am', '3am Eternal', '3am Muumin', 'Justified Leather', '3am Justified', 'Ancient Jetski', 'Eternal Night', 'KLFtro', 'The Jams are back in town', 'Ancient ABBA'];

rand = function(n){
	return 0|(Math.random()*n);
};

var title = title_options[rand(title_options.length)];
D.title = title;

PI = Math.PI;
si = Math.sin;
M = Math.max;
N = Math.min;
Q = Math.sqrt;

var b = D.body;
var Ms = b.style;
Ms.margin='0px';
var blackcolor = Ms.background = "#000";
Ms.overflow = 'hidden';
b.innerHTML = '';
var c = D.createElement('canvas');
b.appendChild(c);
c.style.background = "transparent";
var ctx = c.getContext('2d');

//
// hash canvas context functions larger then 6 characters
// based on a hack documented by cb and p01
// referenced in closure_ctxhash.js
//
//
//for(k in ctx)ctx[k[0]+[k[6]]]=ctx[k];
// not working properly anymore(maybe because of new closure version?)
//
var w = ctx.width = c.width = window.innerWidth;
var h = ctx.height = c.height = window.innerHeight;

var pattern = note = 0;

var noise = [];

var startTime = (new Date()).getTime();

//
// request animation frame, from random place on the internet
//

(function() {
    var lastTime = 0;
    var vendors = ['ms', 'moz', 'webkit', 'o'];
    for(var x = 0; x < vendors.length && !window.requestAnimationFrame; ++x) {
        window.requestAnimationFrame = window[vendors[x]+'RequestAnimationFrame'];
        window.cancelAnimationFrame = window[vendors[x]+'CancelAnimationFrame']
                                   || window[vendors[x]+'CancelRequestAnimationFrame'];
    }
 
    if (!window.requestAnimationFrame)
        window.requestAnimationFrame = function(callback, element) {
            var currTime = new Date().getTime();
            var timeToCall = M(0, 16 - (currTime - lastTime));
            var id = window.setTimeout(function() { callback(currTime + timeToCall); },
              timeToCall);
            lastTime = currTime + timeToCall;
            return id;
        };
 
    if (!window.cancelAnimationFrame)
        window.cancelAnimationFrame = function(id) {
            clearTimeout(id);
        };
}());



//
// ahx replayer, slightly adapted from ahx.js of Cruisin' / Abyss
// hacked for size, some effects werent being used by the song so they were commented
//
// patched in 2015 to only use AudioContext() instead of deprecated functions in Firefox and webkit 
//

function AHXMaster() {
	if(typeof(AudioContext) != 'undefined')
		return new AHXMasterAudioContext();
	else
		return new AHXMasterNull();
}

AHXSong = function() {};

AHXSong.prototype = {
	Name: '',
	Restart: 0,
	PositionNr: 0,
	TrackLength: 0,
	TrackNr: 0,
	InstrumentNr: 0,
	SubsongNr: 0,
	Revision: 0,
	SpeedMultiplier: 0,
	Positions: [],
	Tracks: [],
	Instruments: [],
	Subsongs: [],

	LoadSong: function(url, completionHandler) {
		var Song = this;
		var binString = new dataType();
		binString.data = url;
		Song.InitSong(binString);
		completionHandler();
	},
	
	InitSong: function(stream) { // stream = dataType()
		stream.pos = 3;
		this.Revision = stream.readByte();
		//var streamreadByte = stream.readByteAt;
		//this replace lowers closure but increases png :S
		var SBPtr = 14;
		
		// Header ////////////////////////////////////////////
		// Songname
		var NamePtr = stream.readShort();
		this.Name = stream.readStringAt(NamePtr);
		NamePtr += this.Name.length + 1;
		this.SpeedMultiplier = ((stream.readByteAt(6)>>5)&3)+1;
		
		this.PositionNr = ((stream.readByteAt(6)&0xf)<<8) | stream.readByteAt(7);
		this.Restart = (stream.readByteAt(8)<<8) | stream.readByteAt(9);
		this.TrackLength = stream.readByteAt(10);
		this.TrackNr = stream.readByteAt(11);
		this.InstrumentNr = stream.readByteAt(12);
		this.SubsongNr = stream.readByteAt(13);
		
		// Subsongs //////////////////////////////////////////
		for(var i = 0; i < this.SubsongNr; i++) {
			this.Subsongs.push((stream.readByteAt(SBPtr+0)<<8)|stream.readByteAt(SBPtr+1));
			SBPtr += 2;
		}
		
		// Position List /////////////////////////////////////
		for(var i = 0; i < this.PositionNr; i++) {
			var Pos = AHXPosition();
			for(var j = 0; j < 4; j++) {
				Pos.Track.push(stream.readByteAt(SBPtr++));
				var Transpose = stream.readByteAt(SBPtr++);
				if(Transpose & 0x80) Transpose = (Transpose & 0x7f) - 0x80; // signed char
				Pos.Transpose.push(Transpose);
			}
			this.Positions.push(Pos);
		}

		// Tracks ////////////////////////////////////////////
		var MaxTrack = this.TrackNr;
		//Song.Tracks = new AHXStep*[MaxTrack+1];
		for(var i = 0; i < MaxTrack+1; i++) {
			var Track = [];
			if((stream.readByteAt(6)&0x80)==0x80 && i==0) { // empty track
				for(var j = 0; j < this.TrackLength; j++)
					Track.push(AHXStep());
			} else {
				for(var j = 0; j < this.TrackLength; j++) {
					var Step = AHXStep();
					Step.Note = (stream.readByteAt(SBPtr)>>2)&0x3f;
					Step.Instrument = ((stream.readByteAt(SBPtr)&0x3)<<4) | (stream.readByteAt(SBPtr+1)>>4);
					Step.FX = stream.readByteAt(SBPtr+1)&0xf;
					Step.FXParam = stream.readByteAt(SBPtr+2);
					Track.push(Step);
					SBPtr += 3;
				}
			}
			this.Tracks.push(Track);
		}

		// Instruments ///////////////////////////////////////
		//Song.Instruments = new AHXInstrument[Song.InstrumentNr+1];
		this.Instruments.push(AHXInstrument()); // empty instrument 0
		for(var i = 1; i < this.InstrumentNr+1; i++) {
			var Instrument = AHXInstrument();
			Instrument.Name = stream.readStringAt(NamePtr);
			NamePtr += Instrument.Name.length + 1;
			Instrument.Volume = stream.readByteAt(SBPtr+0);
			Instrument.FilterSpeed = ((stream.readByteAt(SBPtr+1)>>3)&0x1f) | ((stream.readByteAt(SBPtr+12)>>2)&0x20);
			Instrument.WaveLength = stream.readByteAt(SBPtr+1)&0x7;
			Instrument.Envelope.aFrames = stream.readByteAt(SBPtr+2);
			Instrument.Envelope.aVolume = stream.readByteAt(SBPtr+3);
			Instrument.Envelope.dFrames = stream.readByteAt(SBPtr+4); //4
			Instrument.Envelope.dVolume = stream.readByteAt(SBPtr+5);
			Instrument.Envelope.sFrames = stream.readByteAt(SBPtr+6);
			Instrument.Envelope.rFrames = stream.readByteAt(SBPtr+7); //7
			Instrument.Envelope.rVolume = stream.readByteAt(SBPtr+8);
			Instrument.FilterLowerLimit = stream.readByteAt(SBPtr+12)&0x7f;
			Instrument.VibratoDelay = stream.readByteAt(SBPtr+13); //13
			Instrument.HardCutReleaseFrames = (stream.readByteAt(SBPtr+14)>>4)&7;
			Instrument.HardCutRelease = stream.readByteAt(SBPtr+14)&0x80?1:0;
			Instrument.VibratoDepth = stream.readByteAt(SBPtr+14)&0xf; //14
			Instrument.VibratoSpeed = stream.readByteAt(SBPtr+15);
			Instrument.SquareLowerLimit = stream.readByteAt(SBPtr+16);
			Instrument.SquareUpperLimit = stream.readByteAt(SBPtr+17); //17
			Instrument.SquareSpeed = stream.readByteAt(SBPtr+18);
			Instrument.FilterUpperLimit = stream.readByteAt(SBPtr+19)&0x3f; //19
			Instrument.PList.Speed = stream.readByteAt(SBPtr+20);
			Instrument.PList.Length= stream.readByteAt(SBPtr+21);
			SBPtr += 22;
			//Instrument.PList.Entries=new AHXPListEntry[Instrument.PList.Length);
			for(var j = 0; j < Instrument.PList.Length; j++) {
				var Entry = AHXPlistEntry();
				Entry.FX[0] = (stream.readByteAt(SBPtr+0)>>2)&7;
				Entry.FX[1] = (stream.readByteAt(SBPtr+0)>>5)&7;
				Entry.Waveform = ((stream.readByteAt(SBPtr+0)<<1)&6) | (stream.readByteAt(SBPtr+1)>>7);
				Entry.Fixed = (stream.readByteAt(SBPtr+1)>>6)&1;
				Entry.Note = stream.readByteAt(SBPtr+1)&0x3f;
				Entry.FXParam[0] = stream.readByteAt(SBPtr+2);
				Entry.FXParam[1] = stream.readByteAt(SBPtr+3);
				Instrument.PList.Entries.push(Entry);
				SBPtr += 4;
			}
			this.Instruments.push(Instrument);
		}
	}
}

function AHXPosition() {
	return {
		Track: [],
		Transpose: []
	}
}

function AHXStep() {
	return {
		Note: 0,
		Instrument: 0,
		FX: 0,
		FXParam: 0
	}
}

function AHXPlistEntry() {
	return {
		Note: 0,
		Fixed: 0,
		Waveform: 0,
		FX: [0, 0],
		FXParam: [0, 0]
	}
}

function AHXPList() {
	return {
		Speed: 0,
		Length: 0,
		Entries: []
	}
}

function AHXEnvelope() {
	return {
		aFrames: 0, aVolume: 0,
		dFrames: 0, dVolume: 0,
		sFrames: 0,
		rFrames: 0, rVolume: 0
	}
}

function AHXInstrument() {
	return {
		Name: '',
		Volume: 0,
		WaveLength: 0,
		Envelope: AHXEnvelope(),
		FilterLowerLimit: 0, FilterUpperLimit: 0, FilterSpeed: 0,
		SquareLowerLimit: 0, SquareUpperLimit: 0, SquareSpeed: 0,
		VibratoDelay: 0, VibratoDepth: 0, VibratoSpeed: 0,
		HardCutRelease: 0, HardCutReleaseFrames: 0,
		PList: AHXPList()
	}
}


function AHXVoice() {
	return {
		// Read those variables for mixing!
		VoiceVolume: 0, VoicePeriod: 0,
		VoiceBuffer: [], //char VoiceBuffer[0x281]; // for oversampling optimization!

		Track: 0, Transpose: 0,
		NextTrack: 0, NextTranspose: 0,
		ADSRVolume: 0, // fixed point 8:8
		ADSR: AHXEnvelope(), // frames/delta fixed 8:8
		Instrument: null, // current instrument
		InstrPeriod: 0, TrackPeriod: 0, VibratoPeriod: 0,
		NoteMaxVolume: 0, PerfSubVolume: 0, TrackMasterVolume: 0x40,
		NewWaveform: 0, Waveform: 0, PlantSquare: 0, PlantPeriod: 0, IgnoreSquare: 0,
		TrackOn: 1, FixedNote: 0,
		VolumeSlideUp: 0, VolumeSlideDown: 0,
		HardCut: 0, HardCutRelease: 0, HardCutReleaseF: 0,
		PeriodSlideSpeed: 0, PeriodSlidePeriod: 0, PeriodSlideLimit: 0, PeriodSlideOn: 0, PeriodSlideWithLimit: 0,
		PeriodPerfSlideSpeed: 0, PeriodPerfSlidePeriod: 0, PeriodPerfSlideOn: 0,
		VibratoDelay: 0, VibratoCurrent: 0, VibratoDepth: 0, VibratoSpeed: 0,
		SquareOn: 0, SquareInit: 0, SquareWait: 0, SquareLowerLimit: 0, SquareUpperLimit: 0, SquarePos: 0, SquareSign: 0, SquareSlidingIn: 0, SquareReverse: 0,
		FilterOn: 0, FilterInit: 0, FilterWait: 0, FilterLowerLimit: 0, FilterUpperLimit: 0, FilterPos: 0, FilterSign: 0, FilterSpeed: 0, FilterSlidingIn: 0, IgnoreFilter: 0,
		PerfCurrent: 0, PerfSpeed: 0, PerfWait: 0,
		WaveLength: 0,
		PerfList: null,
		NoteDelayWait: 0, NoteDelayOn: 0, NoteCutWait: 0, NoteCutOn: 0,
		AudioSource: [],
		//char* AudioSource,
		AudioPeriod: 0, AudioVolume: 0,
		//SquareTempBuffer: new Array(0x80), //char SquareTempBuffer[0x80]: 0,
		
		CalcADSR: function() {
			var tA = this.ADSR;
			var tiE = this.Instrument.Envelope;
			tA.aFrames = tiE.aFrames;
			tA.aVolume = tiE.aVolume*256/tA.aFrames;
			tA.dFrames = tiE.dFrames;
			tA.dVolume = (tiE.dVolume-tiE.aVolume)*256/tA.dFrames;
			tA.sFrames = tiE.sFrames;
			tA.rFrames = tiE.rFrames;
			tA.rVolume = (tiE.rVolume-tiE.dVolume)*256/tA.rFrames;
		}
	}
}

function AHXWaves() {
	this.GenerateTriangle = function(Len) {
		var Buffer = [];
		var d2 = Len;
		var d5 = d2 >> 2;
		var d1 = 128/d5;
		var d4 = -(d2 >> 1);
		var eax = 0;
		for(var ecx = 0; ecx < d5; ecx++) {
			Buffer.push(eax);
			eax += d1;
		}
		Buffer.push(0x7f);
		if(d5 != 1) {
			eax = 128;
			for(var ecx = 0; ecx < d5-1; ecx++) {
				eax -= d1;
				Buffer.push(eax);
			}
		}
		var esi = Buffer.length + d4;
		for(var ecx = 0; ecx < d5*2; ecx++) {
			var neu = Buffer[esi++]
			if(neu == 0x7f) 
				neu = -0x80;
			else 
				neu = -neu;
			Buffer.push(neu);
		}
		return Buffer;
	}
	this.GenerateSquare = function() {
		var Buffer = [];
		for(var ebx = 1; ebx <= 0x20; ebx++) {
			for(var ecx = 0; ecx < (0x40-ebx)*2; ecx++) Buffer.push(-0x80);
			for(var ecx = 0; ecx <       ebx *2; ecx++) Buffer.push(0x7f);
		}
		return Buffer;
	}
	this.GenerateSawtooth = function(Len) {
		var Buffer = [];
		var ebx = 0|(256/(Len-1)), eax = -128;
		for(var ecx = 0; ecx < Len; ecx++) {
			Buffer.push(eax);
			eax += ebx;
		}
		return Buffer;
	}

/*	
	this.GenerateWhiteNoise = function(Len) {
//
// bartMan says this is the original code, but i suck at opcode porting
// so based on analysing the noise table i hacked an estimated function instead
// but left this code commented here for reference
//
//	void AHXWaves::GenerateWhiteNoise(char* Buffer, int Len)
//	{
//	  __asm {
//		  mov edi, Buffer
//		  mov ecx, Len
//		  mov eax, 0x41595321 // AYS!
//	loop0:    test eax, 0x100
//		  je lower
//		  cmp ax, 0
//		  jl mi
//		  mov byte ptr [edi], 0x7f
//		  jmp weida
//	mi:        mov byte ptr [edi], 0x80
//		  jmp weida
//	lower:    mov byte ptr [edi], al
//	weida:    inc edi
//		  ror eax, 5
//		  xor al, 10011010b
//		  mov bx, ax
//		  rol eax, 2
//		  add bx, ax
//		  xor ax, bx
//		  ror eax, 3
//		  dec ecx
//		  jnz loop0
//	  }
//	}
	
		var noise = [];
		var size = Len;
		var eax = 0x41595321;
		var al = bx = ax = 0;
		
		for(var edi = size-1; edi>0; edi--)
		{
			if (eax == 0x100) {
				noise[edi] = al;
			} else {
				if (ax < 0) {
					noise[edi] = 0x80;
				 } else {
					noise[edi] = 0x7f;
				 }
			}		
			eax = eax >>> 5; //this should be ror eax, 5...
			al ^= (2+8+16+128);
			bx = ax;
			var shift = 2 & 31;
			if(shift) {
			  var maskLeft = 1 << (32 - shift);
			  var thisShiftLeft = eax & ~maskLeft;
			  var shiftedLeft = (thisShiftLeft) << shift;
			  var rightStuff = eax >>> (32 - shift);
			  eax = shiftedLeft | rightStuff;
			}  
			bx += ax;
			ax ^= bx;
			eax = eax >>> 3; //this should be ror eax, 3...
		}
		return noise;
	}*/
	
	//
	// estimated function hack, not accurate to original
	//
	this.GenerateWhiteNoise = function(Len) {
		//var noise = [];
		var size = Len;
		
		for(var i = 0; i<Len; i++)
		{
			noise[i] = rand(255);
			if (rand(10) < 6) noise[i] = 0x80 - rand(2);
		}
		return noise;
	}
	this.Filter = function(input, fre, lowOrHigh) { // 0 = low, 1 = high
		var high, mid = .0, low = .0;
		var output = [];
		for(var i = 0; i < input.length; i++) {
			high = input[i] - mid - low; high = N(127.0, M(-128.0, high));
			mid += high*fre;  mid = N(127.0, M(-128.0, mid));
			low += mid*fre;  low = N(127.0, M(-128.0, low));
		}
		for(var i = 0; i < input.length; i++) {
			high = input[i] - mid - low; high = N(127.0, M(-128.0, high));
			mid += high*fre;  mid = N(127.0, M(-128.0, mid));
			low += mid*fre;  low = N(127.0, M(-128.0, low));
			if(lowOrHigh)
				output.push(0|(high));
			else
				output.push(0|(low));
		}
		return output;
	}
	
	this.GenerateFilterWaveforms = function() {
		var src = this.FilterSets[31];
		var tfs = this.Filter;
		var freq = 8;
		var temp = 0;
		while(temp < 31) {
			var dstLow = {};
			dstLow.Sawtooth = [];
			dstLow.Triangle = [];
			var dstHigh = {};
			dstHigh.Sawtooth = [];
			dstHigh.Triangle = [];
			var fre = freq * 1.25 / 100.0;
			for (var i=0; i<=5; i++) {
				dstLow.Sawtooth[i] = tfs(src.Sawtooth[i], fre, 0);
				dstLow.Triangle[i] = tfs(src.Triangle[i], fre, 0);
				dstHigh.Sawtooth[i] = tfs(src.Sawtooth[i], fre, 1);
				dstHigh.Triangle[i] = tfs(src.Triangle[i], fre, 1);
			}
			dstLow.Squares = [];
			dstHigh.Squares = [];
			// squares alle einzeln filtern
			for(var i = 0; i < 0x20; i++) {
				dstLow.Squares = dstLow.Squares.concat(this.Filter(src.Squares.slice(i*0x80, (i+1)*0x80), fre, 0));
				dstHigh.Squares = dstHigh.Squares.concat(this.Filter(src.Squares.slice(i*0x80, (i+1)*0x80), fre, 1));
			}
			dstLow.WhiteNoiseBig = this.Filter(src.WhiteNoiseBig, fre, 0);
			dstHigh.WhiteNoiseBig = this.Filter(src.WhiteNoiseBig, fre, 1);
			
			this.FilterSets[temp] = dstLow;
			this.FilterSets[temp+32] = dstHigh;
			
			temp++;
			freq += 3;
		}
	}

	this.FilterSets = new Array(31+1+31);
	this.FilterSets[31] = {};
	this.FilterSets[31].Sawtooth = [];
	this.FilterSets[31].Sawtooth[0] = this.GenerateSawtooth(0x04);
	this.FilterSets[31].Sawtooth[1] = this.GenerateSawtooth(0x08);
	this.FilterSets[31].Sawtooth[2] = this.GenerateSawtooth(0x10);
	this.FilterSets[31].Sawtooth[3] = this.GenerateSawtooth(0x20);
	this.FilterSets[31].Sawtooth[4] = this.GenerateSawtooth(0x40);
	this.FilterSets[31].Sawtooth[5] = this.GenerateSawtooth(0x80);
	this.FilterSets[31].Triangle = [];
	this.FilterSets[31].Triangle[0] = this.GenerateTriangle(0x04);
	this.FilterSets[31].Triangle[1] = this.GenerateTriangle(0x08);
	this.FilterSets[31].Triangle[2] = this.GenerateTriangle(0x10);
	this.FilterSets[31].Triangle[3] = this.GenerateTriangle(0x20);
	this.FilterSets[31].Triangle[4] = this.GenerateTriangle(0x40);
	this.FilterSets[31].Triangle[5] = this.GenerateTriangle(0x80);
	this.FilterSets[31].Squares = this.GenerateSquare();
	this.FilterSets[31].WhiteNoiseBig = this.GenerateWhiteNoise(0x280*3);
	this.GenerateFilterWaveforms();

	return this;
}


function AHXPlayer(waves) {
	return {
		StepWaitFrames: 0, GetNewPosition: 0, SongEndReached: 0, TimingValue: 0,
		PatternBreak: 0,
		MainVolume: 0,
		Playing: 0, Tempo: 0,
		PosNr: 0, PosJump: 0,
		NoteNr: 0, PosJumpNote: 0,
		WaveformTab: [], //char* WaveformTab[4];
		Waves: waves || new AHXWaves(),
		Voices: [],
		WNRandom: 0,
		Song: AHXSong(),
		PlayingTime: 0,

		//
		// hacked the functions calling VibratoTable to calculate the mirrored values instead of using the lookup
		//
		VibratoTable: [
			0,24,49,74,97,120,141,161,180,197,212,224,235,244,250,253,255,
			253,250,244,235,224,212,197,180,161,141,120,97,74,49,24
//			,0,-24,-49,-74,-97,-120,-141,-161,-180,-197,-212,-224,-235,-244,-250,-253,-255,
//			-253,-250,-244,-235,-224,-212,-197,-180,-161,-141,-120,-97,-74,-49,-24
		],

		PeriodTable: [
			0x0000, 0x0D60, 0x0CA0, 0x0BE8, 0x0B40, 0x0A98, 0x0A00, 0x0970,
			0x08E8, 0x0868, 0x07F0, 0x0780, 0x0714, 0x06B0, 0x0650, 0x05F4,
			0x05A0, 0x054C, 0x0500, 0x04B8, 0x0474, 0x0434, 0x03F8, 0x03C0,
			0x038A, 0x0358, 0x0328, 0x02FA, 0x02D0, 0x02A6, 0x0280, 0x025C,
			0x023A, 0x021A, 0x01FC, 0x01E0, 0x01C5, 0x01AC, 0x0194, 0x017D,
			0x0168, 0x0153, 0x0140, 0x012E, 0x011D, 0x010D, 0x00FE, 0x00F0,
			0x00E2, 0x00D6, 0x00CA, 0x00BE, 0x00B4, 0x00AA, 0x00A0, 0x0097,
			0x008F, 0x0087, 0x007F, 0x0078, 0x0071
		],

		InitSong: function(song) { // song: AHXSong()
			this.Song = song;
		},
		
		InitSubsong: function(Nr) {
			if(Nr > this.Song.SubsongNr) return 0;
		
			if(Nr == 0) this.PosNr = 0;
			       else this.PosNr = Song.Subsongs[Nr-1];
		
			this.PosJump = 0;
			this.PatternBreak = 0;
			this.MainVolume = 0x40;
			this.Playing = 1;
			this.NoteNr = this.PosJumpNote = 0;
			this.Tempo = 6;
			this.StepWaitFrames = 0;
			this.GetNewPosition = 1;
			this.SongEndReached = 0;
			this.TimingValue = this.PlayingTime = 0;

			this.Voices = [ AHXVoice(), AHXVoice(), AHXVoice(), AHXVoice() ];		
		
			return 1;
		},
		
		PlayIRQ: function() {
			if(this.StepWaitFrames <= 0) {
				if(this.GetNewPosition) {
					var NextPos = (this.PosNr+1==this.Song.PositionNr)?0:(this.PosNr+1);
					for(var i = 0; i < 4; i++) {
						this.Voices[i].Track = this.Song.Positions[this.PosNr].Track[i];
						this.Voices[i].Transpose = this.Song.Positions[this.PosNr].Transpose[i];
						this.Voices[i].NextTrack = this.Song.Positions[NextPos].Track[i];
						this.Voices[i].NextTranspose = this.Song.Positions[NextPos].Transpose[i];
					}
					//console.log("pattern:" + NextPos);
					pattern = NextPos;
					this.GetNewPosition = 0;
				}
				for(var i = 0; i < 4; i++) this.ProcessStep(i);
				this.StepWaitFrames = this.Tempo;
			}
			//DoFrameStuff
			for(var i = 0; i < 4; i++) this.ProcessFrame(i);
			this.PlayingTime++;
			if(this.Tempo > 0 && --this.StepWaitFrames <= 0) {
				if(!this.PatternBreak) {
					this.NoteNr++;
					if(this.NoteNr >= this.Song.TrackLength) {
						this.PosJump = this.PosNr+1;
						this.PosJumpNote = 0;
						this.PatternBreak = 1;
					}
				}
				if(this.PatternBreak) {
					this.PatternBreak = 0;
					this.NoteNr = this.PosJumpNote;
					this.PosJumpNote = 0;
					this.PosNr = this.PosJump;
					this.PosJump = 0;
					if(this.PosNr == this.Song.PositionNr) {
						this.SongEndReached = 1;
						this.PosNr = this.Song.Restart;
					}
					this.GetNewPosition = 1;
				}
				//console.log("note:" + this.NoteNr);
				note = this.NoteNr;
			}
			//RemainPosition
			for(var a = 0; a < 4; a++) this.SetAudio(a);
		},

		NextPosition: function() {
			this.PosNr++;
			if(this.PosNr == this.Song.PositionNr) this.PosNr = 0;
			this.StepWaitFrames = 0;
			this.GetNewPosition = 1;
		},
		
		PrevPosition: function() {
			this.PosNr--;
			if(this.PosNr < 0) this.PosNr = 0;
			this.StepWaitFrames = 0;
			this.GetNewPosition = 1;
		},
		
		JumpPosition: function(pos) {
			this.PosNr = pos;
			this.StepWaitFrames = 0;
			this.GetNewPosition = 1;
		},

		ProcessStep: function(v) {
			var tV = this.Voices[v];
			if(!tV.TrackOn) return;
			//console.log("note: " + this.NoteNr);
			//note = this.NoteNr;
			tV.VolumeSlideUp = tV.VolumeSlideDown = 0;
		
			var Note = this.Song.Tracks[this.Song.Positions[this.PosNr].Track[v]][this.NoteNr].Note;
			var Instrument = this.Song.Tracks[this.Song.Positions[this.PosNr].Track[v]][this.NoteNr].Instrument;
			var FX = this.Song.Tracks[this.Song.Positions[this.PosNr].Track[v]][this.NoteNr].FX;
			var FXParam = this.Song.Tracks[this.Song.Positions[this.PosNr].Track[v]][this.NoteNr].FXParam;
		
			switch(FX) {
				case 0x0: // Position Jump HI
					if((FXParam & 0xf) > 0 && (FXParam & 0xf) <= 9)
						this.PosJump = FXParam & 0xf;
					break;
				case 0x5: // Volume Slide + Tone Portamento
				case 0xa: // Volume Slide
					tV.VolumeSlideDown = FXParam & 0x0f;
					tV.VolumeSlideUp   = FXParam >> 4;
					break;
				case 0xb: // Position Jump
					this.PosJump = this.PosJump*100 + (FXParam & 0x0f) + (FXParam >> 4)*10;
					this.PatternBreak = 1;
					break;
				case 0xd: // Patternbreak
					this.PosJump = this.PosNr + 1;
					this.PosJumpNote = (FXParam & 0x0f) + (FXParam >> 4)*10;
					if(this.PosJumpNote > this.Song.TrackLength) this.PosJumpNote = 0;
					this.PatternBreak = 1;
					break;
				case 0xe: // Enhanced commands
					switch(FXParam >> 4) {
						case 0xc: // Note Cut
							if((FXParam & 0x0f) < this.Tempo) {
								tV.NoteCutWait = FXParam & 0x0f;
								if(tV.NoteCutWait) {
									tV.NoteCutOn = 1;
									tV.HardCutRelease = 0;
								}
							}
							break;
						case 0xd: // Note Delay
							if(tV.NoteDelayOn) {
								tV.NoteDelayOn = 0;
							} else {
								if((FXParam & 0x0f) < this.Tempo) {
									tV.NoteDelayWait = FXParam & 0x0f;
									if(tV.NoteDelayWait) {
										tV.NoteDelayOn = 1;
										return;
									}
								}
							}
							break;
					}
					break;
				case 0xf: // Speed
					this.Tempo = FXParam;
					break;
			}
			if(Instrument) {
				tV.PerfSubVolume = 0x40;
				tV.PeriodSlideSpeed = tV.PeriodSlidePeriod = tV.PeriodSlideLimit = 0;
				tV.ADSRVolume = 0;
				tV.Instrument = this.Song.Instruments[Instrument];
				tV.CalcADSR();
				//InitOnInstrument
				tV.WaveLength = tV.Instrument.WaveLength;
				tV.NoteMaxVolume = tV.Instrument.Volume;
				//InitVibrato
				tV.VibratoCurrent = 0;
				tV.VibratoDelay = tV.Instrument.VibratoDelay;
				tV.VibratoDepth = tV.Instrument.VibratoDepth;
				tV.VibratoSpeed = tV.Instrument.VibratoSpeed;
				tV.VibratoPeriod = 0;
				//InitHardCut
				tV.HardCutRelease = tV.Instrument.HardCutRelease;
				tV.HardCut = tV.Instrument.HardCutReleaseFrames;
				//InitSquare
				tV.IgnoreSquare = tV.SquareSlidingIn = 0;
				tV.SquareWait = tV.SquareOn = 0;
				var SquareLower = tV.Instrument.SquareLowerLimit >> (5-tV.WaveLength);
				var SquareUpper = tV.Instrument.SquareUpperLimit >> (5-tV.WaveLength);
				if(SquareUpper < SquareLower) { var t = SquareUpper; SquareUpper = SquareLower; SquareLower = t; }
				tV.SquareUpperLimit = SquareUpper;
				tV.SquareLowerLimit = SquareLower;
				//InitFilter
				tV.IgnoreFilter = tV.FilterWait = tV.FilterOn = 0;
				tV.FilterSlidingIn = 0;
				var d6 = tV.Instrument.FilterSpeed;
				var d3 = tV.Instrument.FilterLowerLimit;
				var d4 = tV.Instrument.FilterUpperLimit;
				if(d3 & 0x80) d6 |= 0x20;
				if(d4 & 0x80) d6 |= 0x40;
				tV.FilterSpeed = d6;
				d3 &= ~0x80;
				d4 &= ~0x80;
				if(d3 > d4) { var t = d3; d3 = d4; d4 = t; }
				tV.FilterUpperLimit = d4;
				tV.FilterLowerLimit = d3;
				tV.FilterPos = 32;
				//Init PerfList
				tV.PerfWait  = tV.PerfCurrent = 0;
				tV.PerfSpeed = tV.Instrument.PList.Speed;
				tV.PerfList  = tV.Instrument.PList;
			}
			//NoInstrument
			tV.PeriodSlideOn = 0;
		
			switch(FX) {
				case 0x4: // Override filter
					break;
				case 0x9: // Set Squarewave-Offset
					tV.SquarePos = FXParam >> (5 - tV.WaveLength);
					tV.PlantSquare = 1;
					tV.IgnoreSquare = 1;
					break;
				case 0x5: // Tone Portamento + Volume Slide
				case 0x3: // Tone Portamento (Period Slide Up/Down w/ Limit)
					if(FXParam != 0) tV.PeriodSlideSpeed = FXParam;
					if(Note) {
						var Neue = this.PeriodTable[Note];
						var Alte = this.PeriodTable[tV.TrackPeriod];
						Alte -= Neue;
						Neue = Alte + tV.PeriodSlidePeriod;
						if(Neue) tV.PeriodSlideLimit = -Alte;
					}
					tV.PeriodSlideOn = 1;
					tV.PeriodSlideWithLimit = 1;
					Note = 0;
			}
		
			// Note anschlagen
			if(Note) {
				tV.TrackPeriod = Note;
				tV.PlantPeriod = 1;
			}

			switch(FX) {
				case 0x1: // Portamento up (Period slide down)
					tV.PeriodSlideSpeed = -FXParam;
					tV.PeriodSlideOn = 1;
					tV.PeriodSlideWithLimit = 0;
					break;
				case 0x2: // Portamento down (Period slide up)
					tV.PeriodSlideSpeed = FXParam;
					tV.PeriodSlideOn = 1;
					tV.PeriodSlideWithLimit = 0;
					break;
				case 0xc: // Volume
					if(FXParam <= 0x40) 
						tV.NoteMaxVolume = FXParam;
					else {
						FXParam -= 0x50;
						if(FXParam <= 0x40)
							for(var i = 0; i < 4; i++) this.Voices[i].TrackMasterVolume = FXParam;
						else {
							FXParam -= 0xa0 - 0x50;
							if(FXParam <= 0x40)
								tV.TrackMasterVolume = FXParam;
						}
					}
					break;
				case 0xe: // Enhanced commands
					switch(FXParam >> 4) {
						case 0x1: // Fineslide up (Period fineslide down)
							tV.PeriodSlidePeriod = -(FXParam & 0x0f);
							tV.PlantPeriod = 1;
							break;
						case 0x2: // Fineslide down (Period fineslide up)
							tV.PeriodSlidePeriod = FXParam & 0x0f;
							tV.PlantPeriod = 1;
							break;
						case 0x4: // Vibrato control
							tV.VibratoDepth = FXParam & 0x0f;
							break;
						case 0xa: // Finevolume up
							tV.NoteMaxVolume += FXParam & 0x0f;
							if(tV.NoteMaxVolume > 0x40) tV.NoteMaxVolume = 0x40;
							break;
						case 0xb: // Finevolume down
							tV.NoteMaxVolume -= FXParam & 0x0f;
							if(tV.NoteMaxVolume < 0) tV.NoteMaxVolume = 0;
							break;
					}
					break;
			}
		}, // ProcessStep
		
		ProcessFrame: function(v) {
			var tV = this.Voices[v];
			
			if(!tV.TrackOn) return;
		
			if(tV.NoteDelayOn) {
				if(tV.NoteDelayWait <= 0) 
					this.ProcessStep(v);
				else 
					tV.NoteDelayWait--;
			}
			if(tV.HardCut) {
				var NextInstrument;
				if(this.NoteNr+1 < this.Song.TrackLength) 
					NextInstrument = this.Song.Tracks[tV.Track][this.NoteNr+1].Instrument;
				else 
					NextInstrument = this.Song.Tracks[tV.NextTrack][0].Instrument;
				if(NextInstrument) {
					var d1 = this.Tempo - tV.HardCut;
					if(d1 < 0) d1 = 0;
					if(!tV.NoteCutOn) {
						tV.NoteCutOn = 1;
						tV.NoteCutWait = d1;
						tV.HardCutReleaseF = -(d1 - this.Tempo);
					} else 
						tV.HardCut = 0;
				}
			}
			if(tV.NoteCutOn) {
				if(tV.NoteCutWait <= 0) {
					tV.NoteCutOn = 0;
					if(tV.HardCutRelease) {
						tV.ADSR.rVolume = -(tV.ADSRVolume - (tV.Instrument.Envelope.rVolume << 8))/tV.HardCutReleaseF;
						tV.ADSR.rFrames = tV.HardCutReleaseF;
						tV.ADSR.aFrames = tV.ADSR.dFrames = tV.ADSR.sFrames = 0;
					} else 
						tV.NoteMaxVolume = 0;
				} else 
					tV.NoteCutWait--;
			}
			//adsrEnvelope
			if(tV.ADSR.aFrames) {
				tV.ADSRVolume += tV.ADSR.aVolume; // Delta
				if(--tV.ADSR.aFrames <= 0) tV.ADSRVolume = tV.Instrument.Envelope.aVolume << 8;
			} else if(tV.ADSR.dFrames) {
				tV.ADSRVolume += tV.ADSR.dVolume; // Delta
				if(--tV.ADSR.dFrames <= 0) tV.ADSRVolume = tV.Instrument.Envelope.dVolume << 8;
			} else if(tV.ADSR.sFrames) {
				tV.ADSR.sFrames--;
			} else if(tV.ADSR.rFrames) {
				tV.ADSRVolume += tV.ADSR.rVolume; // Delta
				if(--tV.ADSR.rFrames <= 0) tV.ADSRVolume = tV.Instrument.Envelope.rVolume << 8;
			}
			//VolumeSlide
			tV.NoteMaxVolume = tV.NoteMaxVolume + tV.VolumeSlideUp - tV.VolumeSlideDown;
			if(tV.NoteMaxVolume < 0) tV.NoteMaxVolume = 0;
			if(tV.NoteMaxVolume > 0x40) tV.NoteMaxVolume = 0x40;
			//Portamento
			if(tV.PeriodSlideOn) {
				if(tV.PeriodSlideWithLimit) {
					var d0 = tV.PeriodSlidePeriod - tV.PeriodSlideLimit;
					var d2 = tV.PeriodSlideSpeed;
					if(d0 > 0) d2 = -d2;
					if(d0) {
						var d3 = (d0 + d2) ^ d0;
						if(d3 >= 0) d0 = tV.PeriodSlidePeriod + d2;
						       else d0 = tV.PeriodSlideLimit;
						tV.PeriodSlidePeriod = d0;
						tV.PlantPeriod = 1;
					}
				} else {
					tV.PeriodSlidePeriod += tV.PeriodSlideSpeed;
					tV.PlantPeriod = 1;
				}
			}
			//Vibrato
			if(tV.VibratoDepth) {
				if(tV.VibratoDelay <= 0) {
					//tV.VibratoPeriod = (this.VibratoTable[tV.VibratoCurrent] * tV.VibratoDepth) >> 7;
					var vc = tV.VibratoCurrent;
					var vt;
					if (tV.VibratoCurrent > 31) vt = -this.VibratoTable[32-tV.VibratoCurrent];
						else vt = this.VibratoTable[tV.VibratoCurrent];
				
					tV.VibratoPeriod = (vt * tV.VibratoDepth) >> 7;
					tV.PlantPeriod = 1;
					tV.VibratoCurrent = (vc + tV.VibratoSpeed) & 0x3f;
				} else tV.VibratoDelay--;
			}
			//PList
			if(tV.Instrument && tV.PerfCurrent < tV.Instrument.PList.Length) {
				if(--tV.PerfWait <= 0) {
					var Cur = tV.PerfCurrent++;
					tV.PerfWait = tV.PerfSpeed;
					if(tV.PerfList.Entries[Cur].Waveform) {
						tV.Waveform = tV.PerfList.Entries[Cur].Waveform-1;
						tV.NewWaveform = 1;
						tV.PeriodPerfSlideSpeed = tV.PeriodPerfSlidePeriod = 0;
					}
					//Holdwave
					tV.PeriodPerfSlideOn = 0;
					for(var i = 0; i < 2; i++) this.PListCommandParse(v, tV.PerfList.Entries[Cur].FX[i], tV.PerfList.Entries[Cur].FXParam[i]);
					//GetNote
					if(tV.PerfList.Entries[Cur].Note) {
						tV.InstrPeriod = tV.PerfList.Entries[Cur].Note;
						tV.PlantPeriod = 1;
						tV.FixedNote = tV.PerfList.Entries[Cur].Fixed;
					}
				}
			} else {
				if(tV.PerfWait) tV.PerfWait--;
				                  else tV.PeriodPerfSlideSpeed = 0;
			}
			//PerfPortamento
			if(tV.PeriodPerfSlideOn) {
				tV.PeriodPerfSlidePeriod -= tV.PeriodPerfSlideSpeed;
				if(tV.PeriodPerfSlidePeriod) tV.PlantPeriod = 1;
			}
			if(tV.Waveform == 3-1 && tV.SquareOn) {
				if(--tV.SquareWait <= 0) {
					var d1 = tV.SquareLowerLimit;
					var	d2 = tV.SquareUpperLimit;
					var d3 = tV.SquarePos;
					if(tV.SquareInit) {
						tV.SquareInit = 0;
						if(d3 <= d1) { 
							tV.SquareSlidingIn = 1;
							tV.SquareSign = 1;
						} else if(d3 >= d2) {
							tV.SquareSlidingIn = 1;
							tV.SquareSign = -1;
						}
				}
					//NoSquareInit
					if(d1 == d3 || d2 == d3) {
						if(tV.SquareSlidingIn) {
							tV.SquareSlidingIn = 0;
						} else {
							tV.SquareSign = -tV.SquareSign;
						}
					}
					d3 += tV.SquareSign;
					tV.SquarePos = d3;
					tV.PlantSquare = 1;
					tV.SquareWait = tV.Instrument.SquareSpeed;
				}
			}
			if(tV.FilterOn && --tV.FilterWait <= 0) {
				var d1 = tV.FilterLowerLimit;
				var d2 = tV.FilterUpperLimit;
				var d3 = tV.FilterPos;
				if(tV.FilterInit) {
					tV.FilterInit = 0;
					if(d3 <= d1) {
						tV.FilterSlidingIn = 1;
						tV.FilterSign = 1;
					} else if(d3 >= d2) {
						tV.FilterSlidingIn = 1;
						tV.FilterSign = -1;
					}
				}
				//NoFilterInit
				var FMax = (tV.FilterSpeed < 3)?(5-tV.FilterSpeed):1;
				for(var i = 0; i < FMax; i++) {
					if(d1 == d3 || d2 == d3) {
						if(tV.FilterSlidingIn) {
							tV.FilterSlidingIn = 0;
						} else {
							tV.FilterSign = -tV.FilterSign;
						}
					}
					d3 += tV.FilterSign;
				}
				tV.FilterPos = d3;
				tV.NewWaveform = 1;
				tV.FilterWait = tV.FilterSpeed - 3;
				if(tV.FilterWait < 1) tV.FilterWait = 1;
			}
			if(tV.Waveform == 3-1 || tV.PlantSquare) {
				//CalcSquare
				var SquarePtr = this.Waves.FilterSets[tV.FilterPos-1].Squares;
				var SquareOfs = 0;
				var X = tV.SquarePos << (5 - tV.WaveLength);
				if(X > 0x20) {
					X = 0x40 - X;
					tV.SquareReverse = 1;
				}
				//OkDownSquare
				if(X--) SquareOfs = X*0x80; // <- WTF!?
				var Delta = 32 >> tV.WaveLength;
				//WaveformTab[3-1] = tV.SquareTempBuffer;
				var AudioLen = (1 << tV.WaveLength)*4;
				tV.AudioSource = new Array(AudioLen);
				for(var i = 0; i < AudioLen; i++) {
					tV.AudioSource[i] = SquarePtr[SquareOfs];
					SquareOfs += Delta;
				}
				tV.NewWaveform = 1;
				tV.Waveform = 3-1;
				tV.PlantSquare = 0;
			}
			if(tV.Waveform == 4-1) // white noise
				tV.NewWaveform = 1;
		
			if(tV.NewWaveform) {
				if(tV.Waveform != 3-1) { // don't process square
					var FilterSet = 31;
					FilterSet = tV.FilterPos-1;
					//console.log(tV.FilterPos);
					
					// Syphus .ahx crashing the player, requires this check
					if (FilterSet in this.Waves.FilterSets) {

						if(tV.Waveform == 4-1) { // white noise
							var WNStart = (this.WNRandom & (2*0x280-1)) & ~1;
							//console.log(FilterSet);
							tV.AudioSource = this.Waves.FilterSets[FilterSet].WhiteNoiseBig.slice(WNStart, WNStart + 0x280);
							//AddRandomMoving
							//GoOnRandom
							this.WNRandom += 2239384;
							this.WNRandom = ((((this.WNRandom >> 8) | (this.WNRandom << 24)) + 782323) ^ 75) - 6735;
						} else if(tV.Waveform == 1-1) { // triangle
							tV.AudioSource = this.Waves.FilterSets[FilterSet].Triangle[tV.WaveLength].slice(); 
						} else if(tV.Waveform == 2-1) { // sawtooth
							tV.AudioSource = this.Waves.FilterSets[FilterSet].Sawtooth[tV.WaveLength].slice();
						}
					}
				}
			}
			//StillHoldWaveform
			//AudioInitPeriod
			tV.AudioPeriod = tV.InstrPeriod;
			if(!tV.FixedNote) tV.AudioPeriod += tV.Transpose + tV.TrackPeriod-1;
			if(tV.AudioPeriod > 5*12) tV.AudioPeriod = 5*12;
			if(tV.AudioPeriod < 0)    tV.AudioPeriod = 0;
			tV.AudioPeriod = this.PeriodTable[tV.AudioPeriod];
			if(!tV.FixedNote) tV.AudioPeriod += tV.PeriodSlidePeriod;
			tV.AudioPeriod += tV.PeriodPerfSlidePeriod + tV.VibratoPeriod;
			if(tV.AudioPeriod > 0x0d60) tV.AudioPeriod = 0x0d60;
			if(tV.AudioPeriod < 0x0071) tV.AudioPeriod = 0x0071;
			//AudioInitVolume
			tV.AudioVolume = ((((((((tV.ADSRVolume >> 8) * tV.NoteMaxVolume) >> 6) * tV.PerfSubVolume) >> 6) * tV.TrackMasterVolume) >> 6) * this.MainVolume) >> 6;
		}, // ProcessFrame

		SetAudio : function(v) {
			var tV = this.Voices[v];

			if(!tV.TrackOn) {
				tV.VoiceVolume = 0;
				return;
			}
		
			tV.VoiceVolume = tV.AudioVolume;
			if(tV.PlantPeriod) {
				tV.PlantPeriod = 0;
				tV.VoicePeriod = tV.AudioPeriod;
			}
			if(tV.NewWaveform) {
				if(tV.Waveform == 4-1) { // for white noise, copy whole 0x280 samples
					tV.VoiceBuffer = tV.AudioSource.slice();
				} else {
					var WaveLoops = (1 << (5-tV.WaveLength))*5;
					var LoopLen = 4*(1 << tV.WaveLength);
					if(!tV.AudioSource.length) {
						tV.VoiceBuffer = new Array(WaveLoops * LoopLen);
						for(var i = 0; i < WaveLoops * LoopLen; i++) {
							tV.VoiceBuffer = 0;
						}
					} else {
						tV.VoiceBuffer = [];
						for(var i = 0; i < WaveLoops; i++) {
							tV.VoiceBuffer = tV.VoiceBuffer.concat(tV.AudioSource.slice(0, LoopLen));
						}
					}
				}
				//tV.VoiceBuffer[0x280] = tV.VoiceBuffer[0];
			}
		}, // SetAudio
		
		PListCommandParse: function(v, FX, FXParam) {
			var tV = this.Voices[v];

			switch(FX) {
				case 0: 
					if(this.Song.Revision > 0 && FXParam != 0) {
						if(tV.IgnoreFilter) {
							tV.FilterPos = tV.IgnoreFilter;
							tV.IgnoreFilter = 0;
						} else tV.FilterPos = FXParam;
						tV.NewWaveform = 1;
					}
					break;
				case 1:
					tV.PeriodPerfSlideSpeed = FXParam;
					tV.PeriodPerfSlideOn = 1;
					break;
				case 2:
					tV.PeriodPerfSlideSpeed = -FXParam;
					tV.PeriodPerfSlideOn = 1;
					break;
				case 3: // Init Square Modulation
					if(!tV.IgnoreSquare) {
						tV.SquarePos = FXParam >> (5-tV.WaveLength);
					} else tV.IgnoreSquare = 0;
					break;
				case 4: // Start/Stop Modulation
					if(this.Song.Revision == 0 || FXParam == 0) {
						tV.SquareInit = (tV.SquareOn ^= 1);
						tV.SquareSign = 1;
					} else {
						if(FXParam & 0x0f) {
							tV.SquareInit = (tV.SquareOn ^= 1);
							tV.SquareSign = 1;
							if((FXParam & 0x0f) == 0x0f) tV.SquareSign = -1;
						}
						if(FXParam & 0xf0) {
							tV.FilterInit = (tV.FilterOn ^= 1);
							tV.FilterSign = 1;
							if((FXParam & 0xf0) == 0xf0) tV.FilterSign = -1;
						}
					}
					break;
				case 5: // Jump to Step [xx]
					tV.PerfCurrent = FXParam;
					break;
				case 6: // Set Volume
					if(FXParam > 0x40) {
						if((FXParam -= 0x50) >= 0) {
							if(FXParam <= 0x40) tV.PerfSubVolume = FXParam;
							else 
								if((FXParam -= 0xa0-0x50) >= 0) 
									if(FXParam <= 0x40) tV.TrackMasterVolume = FXParam;
						}
					} else tV.NoteMaxVolume = FXParam;
					break;
				case 7: // set speed
					tV.PerfSpeed = tV.PerfWait = FXParam;
					break;
			}
		}, // PListCommandParse
		
		VoiceOnOff: function(Voice, OnOff) {
			if(Voice < 0 || Voice > 3) return;
			this.Voices[Voice].TrackOn = OnOff;
		} // VoiceOnOff
	}
}


function AHXOutput(player) {
	return {
		Player: player || AHXPlayer(),
		Init: function(Frequency, Bits) {
			this.Frequency = Frequency;
			this.Bits = Bits;
			this.BufferSize = 0|(Frequency/50);
			this.MixingBuffer = new Array(this.BufferSize);
		},
		pos: [0, 0, 0, 0],
		MixChunk: function(NrSamples, mb) {
			for(var v = 0; v < 4; v++) {
				if(this.Player.Voices[v].VoiceVolume == 0) continue;
				var freq = 3579545.25 / this.Player.Voices[v].VoicePeriod; // #define Period2Freq(period) (3579545.25f / (period))
				var delta = 0|(freq * (1 << 16) / this.Frequency);
				var samples_to_mix = NrSamples;
				var mixpos = 0;
				while(samples_to_mix) {
					if(this.pos[v] >= (0x280 << 16)) this.pos[v] -= 0x280 << 16;
					var thiscount = N(samples_to_mix, 0|(((0x280 << 16)-this.pos[v]-1) / delta) + 1);
					samples_to_mix -= thiscount;
					//int* VolTab = &VolumeTable[Player->Voices[v].VoiceVolume][128];
					//INNER LOOP
					/*if(Oversampling) {
						for(int i = 0; i < thiscount; i++) {
							int offset = pos[v] >> 16;
							int sample1 = VolTab[Player->Voices[v].VoiceBuffer[offset]];
							int sample2 = VolTab[Player->Voices[v].VoiceBuffer[offset+1]];
							int frac1 = pos[v] & ((1 << 16) - 1);
							int frac2 = (1 << 16) - frac1;
							(*mb)[mixpos++] += ((sample1 * frac2) + (sample2 * frac1)) >> 16;
							pos[v] += delta;
						}
					} else*/ {
						for(var i = 0; i < thiscount; i++) {
							this.MixingBuffer[mb + mixpos++] += this.Player.Voices[v].VoiceBuffer[this.pos[v] >> 16] * this.Player.Voices[v].VoiceVolume >> 6;
							this.pos[v] += delta;
						}
					}
				} // while
			} // v = 0-3
			mb += NrSamples;
			return mb;
		}, // MixChunk
		MixBuffer: function() { // Output: 1 amiga(50hz)-frame of audio data
			for(var i = 0; i < this.BufferSize; i++)
				this.MixingBuffer[i] = 0;
			var mb = 0;
			var NrSamples = 0|(this.BufferSize / this.Player.Song.SpeedMultiplier);
			for(var f = 0; f < this.Player.Song.SpeedMultiplier; f++) {
				this.Player.PlayIRQ();
				mb = this.MixChunk(NrSamples, mb);
			} // frames
		}
	}
}

//AHXMasterWebKit = function(output) {
AHXMasterAudioContext = function(output) {
	this.Output = output || AHXOutput();
	this.AudioContext = null;
	this.AudioNode = null;
};

//AHXMasterWebKit.prototype = {
AHXMasterAudioContext.prototype = {
	Play: function(song) { // song = AHXSong()
		this.Output.Player.InitSong(song);
		this.Output.Player.InitSubsong(0);
		if(!this.AudioContext) 
			this.AudioContext = new AudioContext();
		this.Output.Init(this.AudioContext.sampleRate, 16);
		//this.bufferSize = 8192;
		this.bufferSize = 4096;
		this.bufferFull = 0;
		this.bufferOffset = 0;
		if(this.AudioNode) 
			this.AudioNode.disconnect();
		this.AudioNode = this.AudioContext.createScriptProcessor(this.bufferSize);
		var theMaster = this;
		this.AudioNode.onaudioprocess = function (event) {
			theMaster.mixer(event);
		}
		this.AudioNode.connect(this.AudioContext.destination);
	},

	mixer: function(e) {
		var want = this.bufferSize;

		var buffer = e.outputBuffer;
		var left = buffer.getChannelData(0);
		var right = buffer.getChannelData(1);
		var out = 0;

		while(want > 0) {
			if(this.bufferFull == 0) {
				this.Output.MixBuffer();
				this.bufferFull = this.Output.BufferSize;
				this.bufferOffset = 0;
			}

			var can = N(this.bufferFull - this.bufferOffset, want);
			want -= can;
			while(can-- > 0) {
				var thissample = this.Output.MixingBuffer[this.bufferOffset++] / (128*4);
				left[out] = right[out] = thissample;
				out++;
			}
			if(this.bufferOffset >= this.bufferFull) {
				this.bufferOffset = this.bufferFull = 0;
			}
		}
	},

	init: function() {
	},

	reset: function() {
	},

	Stop: function() {
		this.AudioNode.disconnect();
	}

}

function AHXMasterNull() {
	this.Play = function(stream) {
	}

	this.init = function() {
	}

	this.reset = function() {
	}

	this.Stop = function() {
	}
	
	return this;
}

dataType = function() {};
var cC = Array.charCodeAt;

dataType.prototype = {
	data: null,
	pos: 0,
	endian:"BIG",

	readBytes: function(offset, nb){
		var tmp="";
		for(var i=0;i<nb;i++){
			tmp+=this.data[offset+this.pos++];
		}
		return tmp;
	},

	readMultiByte: function(nb, type){
		if(type=="txt"){
			var tmp="";
			for(var i=0; i<nb; i++){
				tmp+=this.data[this.pos++]
			}
			return tmp;
		}
	},

	readInt: function(){
		var tmp1 = parseInt(this.data[this.pos+0].cC(0).toString(16),16);
		var tmp2 = parseInt(this.data[this.pos+1].cC(0).toString(16),16);
		var tmp3 = parseInt(this.data[this.pos+2].cC(0).toString(16),16);
		var tmp4 = parseInt(this.data[this.pos+3].cC(0).toString(16),16);
		if(this.endian=="BIG")
			var tmp = (tmp1<<24)|(tmp2<<16)|(tmp3<<8)|tmp4;
		else
			var tmp = (tmp4<<24)|(tmp3<<16)|(tmp2<<8)|tmp1;
		this.pos+=4;
		return tmp;
	},

	readShort: function(){
		var tmp1 = parseInt(this.data[this.pos+0].charCodeAt(0).toString(16),16);
		var tmp2 = parseInt(this.data[this.pos+1].charCodeAt(0).toString(16),16);
		var tmp = (tmp1<<8)|tmp2;
		this.pos+=2;
		return tmp;
	},
	readByte: function(){
		var tmp =  parseInt(this.data[this.pos].charCodeAt(0).toString(16),16)
		this.pos+=1;
		return tmp;
	},
	
	readByteAt: function(atPos) {
		return parseInt(this.data[atPos].charCodeAt(0).toString(16),16)
		return tmp;
	},
	
	readStringAt: function(atPos){
		var tmp="";
		while(1){
			if(this.data[atPos++].charCodeAt(0) !=0)
				tmp+=this.data[atPos-1];
			else
				return tmp;
		}
	},

	substr: function(start, nb){
		return this.data.substr(start,nb);
	},

	bytesAvailable:function(){
		return this.length-this.pos;
	}
}


var ahxMaster, ahxSong;

b.onload = function()
{
		ahxMaster = AHXMaster(); 
		ahxSong = new AHXSong();
		
		//
		// song was converted to urlencoded string from THX using Gasman's binhexjs.rb
		//
		
	// jetski
	//ahxSong.LoadSong("5448580120ee00150000401f140015001600170011000400050000000600040000000000060001000200000003000100020000000300040005000000060004001b00000006000700080009000a0007001c001d000a00010018000000030001000200000003000c000d000e000f00100008000b000a0012001c000b000a001200130014000a0012001e001f000a0001000200000003000100020019000300010002001a0003000100020019000300010002001a000300000a0a000a0a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005c6000000a0a0000005c50006470008c5000bc50008c5a0a5c60008c5000bc5000585000947000885000585000000a0a506000000a0a000000505000947000805000b05000805a0a506000805000b05000805000947000885000b85000885a0a5c6000000a0a0000005c50009c70008c5000bc50008c5a0a5c60008c5000bc50005850009c7000885000585000000a0a506000000a0a0000005050009c7000805000b05000805a0a506000805000b050008050009c7000885000b85000885a0a000a0a000a0a000000b01ed2b80310000ec1a82000b83c10b04000000000a83c10c42000000000000000b81000000a0a000000000210c42c10b03ed2b84000000a0aa83000b82c10b01000000000000a0ab82c10a430000000000002109c4000000000000000000000b03ed2b80310000a0aa82000b81c10b02000000000a83c10c44000000000cc3000b82000000a0ac41c10cc2c10c43c10b04ed2b83000000a0aa82000b81c10b02000000000000a0ab83c10a440000000000002109c3000489f08000f05000f08000f05000f08000f05489f08000f05000f08000f05000f08000f05489f08000f05000f08000f053caf08000f05000f08000f05000f08000f053caf08000f05000f08000f05000f08000f053caf083caf05000f08000f05489f08000f05000f08000f05000f08000f05489f08000f05000f08000f05000f08000f05489f08000f05000f08000f053caf08000f05000f08000f05000f08000f053caf08000f05000f08000f05000f08000f053caf083caf05000f08000f05646ec46450007850006c50006470007850006c5000000a0a646ec46450007850006c5000647000785000805000885000646ec46450007850006c50006470007850006c5000000a0a646ec46450007850006c5000647000785000805000885000646ec46450007850006c50006470007850006c5000000a0a646ec46450007850006c5000647000785000805000885000646ec46450007850006c50006470007850006c5000000a0a646ec46450007850006c5000647000785000805000885000000a04000a04000a0a0000000000000000000000009c4ed3a440000000009c4000a44c209440009c4c209c4ed2884000000000000000000000000210944000884c20804000000000000000000210884000000000000000804c209440000000000000000000000000000000000000000000000002109c4ed3a440000000009c4000a44c20944000b04ed3b84000b04000000000000000000000000000000210a84000a440009440000000000000000000000000000002108840009440009c400058af08000f05000f08000f05000f08000f05000f08000f0558af08000f05000f08000f05509f08000f05000f0858af05000f08000f05000f08000f05000f08000f05000f08000f05509f08000f05000f08000f05000f08000f05000f08000f0558af08000f05000f08000f05000f08000f05000f08000f0558af08000f05000f08000f05509f08000f05000f0858af05000f08000f05000f08000f05000f08000f05000f08000f05649f08000f05000f08000f0574af08000f05000f08000f05806000806000806000805000787000805000000000000000806000000000000000805000787000885000000000000000646000000a0a645000000000787000645000000000000000646000000000000000000000787000885000000000647000806000806ed1806000805000787000805000000000000000806000000000000000805000787000885000000000000000646000000a0a64500000000078700064500000000000000064600000000000000000000078700088500064700064700094e1049c0320000300000000000000000000000000000000000000000000000000000000c40320000300000000000000b003180003000000000000000000000000000000000000000000000000000000000000009c0330a403100003009c0300000300000000000000000000000000000000000000000000000000000000000000000000c40320000000000000000300b00318000300000000000000000000000000b80300000300a40300000300000000a80300000300000000a4030000030000000000000000000094f1049c0320000300000000000000000000000000000000000000000000000000000000c40320000300000000000000b003180003000000000000000000000000000000000000000000000000000000000000009c0330a403100003009c0300000300000000000000000000000000000000000000000000000000000000000000000000c40320000000000000000300b00318000300000000000000000000000000b80300000300a40300000300000000a803000003005ccf08000f05000f08000f055ccf085ccf05000f08000f055ccf08000f05000f08000f058ccf08000f05000f08000f0564cf08000f05000f08000f0594cf0864cf05000f08000f0564cf08000f05000f08000f0594cf08000f05000f08000f055ccf08000f05000f08000f058ccf085ccf05000f08000f055ccf08000f05000f08000f058ccf08000f05000f08000f0564cf08000f05000f08000f0594cf0864cf05000f08000f0564cf08000f05000f08000f0594cf08000a0a000f08000f05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000946ec400000000000094dec2947000000000946ec4000000946ec400000000000094dec294700000000094dec2000000946ec4946ec400000094dec2947000000000946ec4000000946ec400000000000094dec2947000946ec4000000000000946ec400000000000094dec2947000000000946ec4000000946ec400000000000094dec294700000000094dec2000000946ec4946ec400000094dec2947000000000946ec4000000946ec400000000000094dec2947000946ec4000000000000350000000000000000000000650000000000950000000000000000000000511ed2000000000000000000651000000000000000000000950ed2000000000000000000000000000000000000000000c500000000000000000000006d1000000000350000000000000000000000650000000000950000000000000000000000511ed2000000000000000000651000000000000000000000950ed2000000000000000000000000000000000000000000c500000000000000000000006d1000000000000000000000000000000000000000350c10000000000000000000650c10000000950c10000000000000000000511c10000000000000000000651c10000000000000000000950c10000000000000000000000000000000000000000000c50c100000000000000000006d1c10000000350c10000000000000000000650c10000000950c10000000000000000000511c10000000000000000000651c10000000000000000000950c10000000000000000000000000000000000000000000c50c1028af08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f05209f08000f05000f08000f0528af08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08349f05000f08000f05000f08000f0528af08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f0564d00000000000000000000094f1049c0320000300000000000000000000000000000000000000000000000000000000c40320000300000000000000b003180003000000000000000000000000000000000000000000000000000000000000009c0330a403100003009c0300000300000000000000000000000000000000000000000000000000000000000000000000c40320000000000000000300b00318000300000000000000807000807000000000807000000000000000807000000000948f08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f05000f08000f0550600000000000000094dec294700000000050600000000050600000000000000094dec294700000000094dec200000064600064600000000094dec2947000000000946ec400000064600000000000000094dec294700034600000000000000050600000000000000094dec294700000000050600000000050600000000000000094dec294700000000094dec200000064600064600000000094dec294700000000064600000000058600000000000000094dec29470005c60006460006460005d20000000007920007920007520000000006d20000000006520006d20000000006520000000000000006520006d20000000000000007920007520006d20000000006d20000000006520006d20000000007520000000000000005920005d20005d20000000007920007920007520000000006d20000000006520006d20000000006520000000000000006520006d20000000000000007920007520006d20000000006d20000000006520006d20000000007520000000000000007920000000006d20000000008920008920008120000000007920000000007520007920000000007520000000000000007520007920000000000000006d20008920008120000000007920000000007520007920000000009520000000000000007520006d20006d20000000008920008920008120000000007920000000007520007920000000007520000000000000007520007920000000000000006d20008920008120000000007920000000007520007920000000009520000000000000009d2000000000354000000a0a4940003d40000000004940003d4000000a0a354ec43540004940003d40000000004940005140005940003540000002104940003d40000000004940003d4000000a0a354ec43540004940003d4000000000494000514000594000354000000a0a4940003d40000000004940003d4000000a0a354ec43540004940003d4000000000494000514000594000354a0a3540004940003d40000000004940003d4000000a0a354ec43540004940003d4000000000494000514000594000514000000a0a654000594000000000654000594000000a0a514ec45140006540005940000000006540006d4000754000514000000210654000594000000000654000594000000a0a514ec45140006540005940000000006540006d4000754000514000000a0a654000594000000000654000594000000a0a514ec45140006540005940000000006540006d4000754000514a0a514000654000594000000000654000594000000a0a514ec45140006540005940000000006540006d4000754000000000000000648c10648c20000000648c10648c20000000648000000000648c10648c20000000648c10648c20000000648000000000648c10648c20000000648c10648c20000000648000000000648c10648c20000000648c10648c20000000648000000000648c10648c20000000648c10648c20000000648000000000648c10648c20000000648c10648c20000000648000000000648c10648c20000000648c10648c20000000648000000000648c10648c206cd2040002040002040002049ce000000a0a000210b01ed2b80310000ec1a82000b83c10b04000000000a83c10c42000000000000000b81000000a0a000000000210c42c10b03ed2b84000000a0aa83000b82c10b01000000000000a0ab82c10a430000000000002109c4000000000000000000000b03ed2b80310000a0aa82000b81c10b02000000000a83c10c44000000000cc3000b82000000a0ac41c10cc2c10c43c10b04ed2b83000000a0aa82000b81c10b02000000000000a0ab83c10a440000000000002109c3000b13104000000000000000000b13104000000000000000000b13104000000000000b13000a80310b13000b93000000000000000000000000000000000000000000000c53000d93000d53000c53000a93000a53000000000000210000210000a0aa53000a80320a40300000300940300000300813000880310000000953000000000893c10953c10000000b13000000000000000000000a93000b13000b93000b13000a93000a53000000104000204953000000000000000000000000210000210cd3100d40310000000c13ed2c40310000000000210000000b93000000000000000000000000000000000000000000000000210000210b13000a93000b13000b93000b13c20000000000000000000000000000000000000a93000a53000953000893000000000000000000000000000000000000000000000000000000000813000793000753000793000953000000000000000000000000000000000000000000000000000000000000000000000000000000000c40320000300000220000220000a04000a04000a0a0000000000000000000000009c4ed3a440000000009c4000a44c209440009c4c209c4ed2884000000000000000000000000210944000884c20804000000000000000000210884000000000000000804c209440000000000000000000000000000000000000000000000002109c4ed3a440000000009c4000a44c20944000b04ed3b84000b04000000000000000000000000000000210a84000a4400094400000000000000000000000000000021000021000021000021094e1049c0320000300000000000000000000000000000000000000000000000000000000c40320000300000000000000b003180003000000000000000000000000000000000000000000000000000000000000009c0330a403100003009c0300000300000000000000000000000000000000000000000000000000000000000000000000c40320000000000000000300b00318000300000000000000000000000000000000000000a40300000300000000a80300000300000000a4030000030000000000000000000094f1049c0320000300000000000000000000000000000000000000000000000000000000c40320000300000000000000b003180003000000000000000000000000000000000000000000000000000000000000009c0330a403100003009c0300000300000000000000000000000000000000000000000000000000000000000000000000c40320000000000000000300b00318000300000000000000000000000000000000000000a40300000300000000a80300000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000403201400140090140000000010f0508203f031802198d810a10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000403201400140090140000000010f0508203f031802198d811210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000403201400140090140000000010f0508203f031802198d811a10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000403201400140090140000000010f0508203f031802198d81221000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040340140014009014000000001001000043f031802198d81330080000000800000008000004080000030800000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040040140044015820000000000000000043f040001097a6d322019e6400000620000005d00008c01330080000000800000008000004080000030400301400240010b0000000000000000083f010001057a6e402001e30000005f0000005b00001a6e30001c030140023c01010000000000008000203f040001011259105028320140014009201000000001000000203f051802198d860a00000a0000000d00000011000014160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000028320140044009201000000001000000203f051802198d860a0000090000000d00000010000014140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040320140013609160c00000001000000203f051802198d840a0000080000000d00000010000014140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040320140013609160c00000001000000203f051802198d850a0000080000000d00000014000014190000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040200140014001014000000001000000203f011f0101821920102c3201400140090140000000010f0008203f031802198d812210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000163201400140090140000000010f0008203f031802198d81221000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000028320140044009202400000001000000203f051804198d010a00e0030003f40600040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000028320140044009202400000001000000203f051804198d060a00e0080003f40d00040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040320140040e090f00000000010f0508203f031802198d812010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000402a01400140090140000000010010001039041802198d813300800000008000000080000040800000308000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000223301400140090140000000010f0008203f031802190d8120011400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005359532d6a6574736b694f50542e414858002d3d4a6574736b693d2d00002062790000205457494e204245414d000041485820636f766572206279007379706875732f557020526f75676800006563686f6c6576656c2e636f2e756b0000000000000000000000".replace(/../g, function(r) {return String.fromCharCode(parseInt(r,16))})
		
	//flava by kaneel
	//ahxSong.LoadSong("54485801115a8011000040140c000100000000000000010000000000000008000200000000000900030000000000120001000000000007000200050004000a0003000600040007000200100004000a0003001100040001000b0010000d0001000b0011000000130002000500040014000200060004001300020010000400140003001100040001000b000c000d000f0000000e00000034640100040100040100040100040100040100040100040100040000040f00040000040000040000040300040000040000040300040000040000040100040100040100040100040100040100040100040100040100040100040100040100040100040f00040000040000040100040000040300040000040f000400000400000403000400000401000401000401000401000401000401000401000401000400000402000403000400000400000404000400000400000405000400000406000400041f04000000342000348000644000000000943000943000942000000000644000000000342000000000c42000000000041000000000342000348000644000000000943000943000942000000000041000000000644000000000643000000000041000000000342000348000644000000000943000943000942000000000644000000000342000000000c42000000000041000000000342000348000644000000000943000943000942000000000041000000000c43c05c43c10c43c20c43c40041000000000342000348000644000000000943000943000945000000000644000000000342000000000c42000000000041000000000342000348000644000000000345000000000000000000000041000000000644000000000643000000000041000000000342000348000644000000000943000943000942000000000644000000000342000000000c42000000000041000000000342000348000644000000000943000943000942000000000346000000000000000000000000000000000c43000000000c43000000000785000000000c43000000000c43000000000485000000000c43000000000c43000000000c43000000000c430000000006c5000000000c43000000000c43000000000c430000000003c5000000000c43000000000c43000000000c43000000000785000000000c43000000000c43000000000485000000000c43000000000c43000000000c43000000000c430000000006c5000000000c43000000000c43000000000c430000000003c5000000000c430000000007480000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007480000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006c800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044700000000000000000000014700000000000000000000044900000000044a00000000000000000000000000090bc2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000048700000000000000000000018700000000000000000000044900000000044a00000000000000000000000000088bc20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000447000000000000000000000000000000000000000000000147000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000487000000000000000000000000000000000000000000000000000000000000000000000000000000000147c200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004470000000000000000000000000000000000000000000001470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003c70000000000000000000000000000000000000000000000000000000000000000000000000000000009cbc2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044700000000000000000000014700000000000000000000044900000000044a00000000000000000000000000090bc200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003c70000000000000000000000c70000000000000000000003c90000000003ca000000000000000000000000000a4bc2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000034b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000045000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b1600040100040100040100040100040100040100040100040100040000040f00040000040000040000040300040000040000040300040000040000040100040100040100040100040100040100040100040100040100040100040100040100040100040f00040000040000040100040000040300040000040f00040000040000040300040000040100040100040100040100040100040100040100040100040000040200040300040000040000040400040000040000040500040000040600040074c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000078c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000074c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010f00020f00010f00020f00028000028000028000028000028000028000028000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044700000000000000000000014700000000000000000000044900000000044a00000000000000000000000000090bc20000000000000000000000000c0b000000000000000000000000000000000a4b00000000000000000000000000000000048700000000000000000000018700000000000000000000044900000000044a00000000000000000000000000088bc20000000000000000000000000000000000000b8b000000000000000000000c0b00000000000000000000000000000000044700000000000000000000014700000000000000000000044900000000044a00000000000000000000000000090bc20000000000000000000000000000000000000ccb000000000000000000000000000b8b0000000000000000000000000003c70000000000000000000000c70000000000000000000003c90000000003ca000000000000000000000000000a4bc20000000000000000000000000000000000000000000ccb000000000000000000000000000d4b00000000000000000000040250140080001010000000001000000203f011f02030da520080800ff040a00ff0037650131050001010000000001000e10203f011f010382190fff0d8020001980100040220140030001010000000001000000203f011f010202250f00410002ff40040140074001080000000000000000043f010001060e7a20100dec20104a19ffff19faf0281a4070101400000040250140100001010000000001000000203f011f0103012503000200040002000f0040a240404d3aff450000000001000000203f01220502020d0000a000080038240131130001010000000001000000203f071f01040d8d5008820000010d80200400000000355c0134122378300000000001002000203f011f0406010d080000190b00001204000019000c0d8d400f151200081f2401231a2c69120000000001000004023f061f0703718d013000000900a00002013123083919001b1d0000000001000000043f091f010461990f208225030100990f00a1a502002e0d012101400810200000001e0826070114010101058e7a3f001d810800800000108000001100000000354c01341a2f78300000000001002000203f041f0406718d012001990f030112040f008f000f0d8d400615120008666c617661342d7300000000534e414152320000000000000046696c74657265642042617373310000".replace(/../g, function(r) {return String.fromCharCode(parseInt(r,16))})

	//karma by someone who i dont recall right now but found this off hivelys song example directory
	//	ahxSong.LoadSong("544858013d7000260000404a1f000c000d00170038000a000b00170038000a000b00170038000000010017000200030001001700040005000100170009000600010017001800460008003a0047000f0039003b003d00070008003a003e000f0010003f003d0012000100490041004400010049004200480014004900430024001900250026f92a004a002b002cf924001900250026f92a004a002b002cf91c001d001e001ff927002100280029f92d001d001e001ff920002100220023f940001900250026f91c001d001e001ff927002100280029f92d001d001e001ff920002100220023f945001900250026f920002100220023f940001900250026f924001900250026f92a004a002b002cf924001900250026f92a004a002b002cf92e0019001e031ff031002100280329f0340019001e031ff035002100220323f09d00000000009d00000000009d0000000000000000000000e83000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e03000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cc300000000000000000000089200000000000000000000089200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000065a000000000000000000000000000000000000000000000000000000000000000e83c10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e03c10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cc3c10d43000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b83000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d43c10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b83c10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e83f04000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cc3000000000d43000000000e03000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cc3000000000000000000000d43000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b83000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b01000000000b81000000000c41000000000000000000000000000000000000000000000000000000a03000000000000b81000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d41000000000000000000000cc1000000000000000000000000000000000000000000000000000000000000000000000b01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000792000000000000000000000792000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000752000000000000000000000752000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e83c10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cc3c10000000d43c10000000e03c10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cc3c10cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000892000000000000000000000892000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000892000000000000000000000892000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cd0f04000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000cd0000000000892000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d41000000000000000000000000000000000000000000000000000000000000000000000b81000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e81000000000000000000000e01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000792000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000812000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000794c27814c27894c27954c27795c17815c17895c17955c17796c0d816c0d896c0d956c0d797c06817c06897c06957c06798c03818c03898c03958c03799c03819c03899c03959c03799c02819c02899c02959c02798c02818c02898c02958c02814c27954c279d4c27b14c27815c17955c179d5c17b15c17816c0d956c0d9d6c0db16c0d817c06957c069d7c06b17c06818c03958c039d8c03b18c03819c03959c039d9c03b19c03819c02959c029d9c02b19c02818c02958c029d8c02b18c02b84000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c84000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bc4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b1da07000a07000a07000a07000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000892000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a01000000000000000000000a01000000000000000000000a01000000000000000000000a01000000000000000000000a01000000000000000000000000000000000000000000811000000000000a04000000811000000000000a04000000891000012000013000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000811000012000013000000a08811000012000013000000a08000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000894c279d4c27a54c27b94c27895c179d5c17a55c17b95c17896c0d9d6c0da56c0db96c0d897c069d7c06a57c06b97c06898c039d8c03a58c03b98c03899c039d9c03a59c03b99c03899c029d9c02a59c02b99c02898c029d8c02a58c02b98c02897c019d7c01a57c01b97c01000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000353000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000353000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d43c10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b83c10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b01c10b1d000000000ccf000000000ccf000000000000000000000c5f000000000ccf000000000b1d000000000ccf000000000ccf000000000b1d000000000b1d000000000ccf000000000c5f000000000ccf000000000000000000000ccf000000000b1d000000000ccf000000000ccf000000000000000000000c5f000000000ccf000000000b1d000000000ccf000000000ccf000000000b1d000000000b1d000000000ccf000000000c5f000000000ccf000000000000000000000ccf000000000951000012000951000012000c51000012000bd1000012000013000012a0ab11000012000013000012a0abd1000012000013000012a0ab11000012000013000012000011000012a0abd1000012000013000012a0ab11000012000bd1000012000951000012000951000012000c51000012000bd1000012000013000012a0ab11000012000013000012a0abd1000012000013000012a0ab11000012000013000012000011000012a0abd1000012000013000012a0ab11000012000bd1000012000b14000015000016000017000b14000015000b14000015000016000017000b14000015000b14000015000016000017000b14000015000b14000015000016000017000b14000015000016000017000b14000015000b14000015000016000017000b14000015000016000017000b14000015000b14000015000016000017000b14000b14000b14000015000016000017000b14000015000b14000015000016000017000b14000015000016000017000b14000015000b14000015000016000017000882000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b82000000000b02000000000a42000000000b02000000000a420000000000000000000000000000000000000000000000000000000000000000000009c2000000000a420000000009c2000000000000000000000000000000000a420000000009c2000000000000000000000802000000000000000000000b1d000000000ccf000000000ccf000000000000000000000c5f000000000ccf000000000b1d000000000ccf000000000ccf000000000b1d000000000b1d000000000ccf000000000c5f000000000ccf000000000000000000000ccf000000000b1d000000000ccf000000000ccf000000000000000000000c5f000000000ccf000000000b1d000000000ccf000000000ccf000000000b1d000000000b1d000000000ccf000000000c5f000000000ccf000000000000000000000ccf000000000891000000000891000000000b91000000000b11000000000000000000000a51000000000000000000000b11000000000000000000000a5b000000000000000000000000000000000b11000000000000000000000a51000000000b11000000000a51000000000a51000000000d51000000000cd1000000000000000000000c11000000000000000000000cd1000000000000000000000c1b000000000000000000000000000000000cd1000000000000000000000c11000000000cd1000000000a54000000000000000000000a54000000000a54000000000000000000000a54000000000a54000000000000000000000a54000000000a54000000000000000000000a54000000000000000000000a54000000000a54000000000000000000000914000000000000000000000914000000000914000000000000000000000914000000000914000000000000000000000914000000000914000000000000000000000914000000000000000000000914000000000914000000000000000000000b82000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d42000000000000000000000000000000000cc2000000000000000000000000000000000c42000000000cc2000000000e02000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cc2000000000000000000000000000000000000000000000d42000000000000000000000b1d000000000ccf000000000ccf000000000000000000000c5f000000000ccf000000000b1d000000000ccf000000000ccf000000000b1d000000000b1d000000000ccf000000000c5f000000000ccf000000000000000000000ccf000000000b1d000000000ccf000000000ccf000000000000000000000c5f000000000ccf000000000b1d000000000ccf000000000ccf000000000b1d000000000b1d000000000ccf000000000c5f000000000ccf000000000c5f000000000c5f000000000791000000000791000000000a910000000009d1000000000000000000000891000000000000000000000a910000000000000000000009db000000000000000000000000000000000891000000000000000000000791000000000a91000000000811000000000811000000000b110000000009d1000000000000000000000911000000000000000000000811000000000000000000000b1b0000000000000000000000000000000009d10000000000000000000009110000000009d10000000006550000000000000000000006550000000006550000000000000000000006550000000006550000000000000000000006550000000006550000000000000000000006550000000000000000000006550000000006550000000000000000000006d50000000000000000000006d50000000006d50000000000000000000006d50000000006d50000000000000000000006d50000000006d50000000000000000000006d50000000000000000000006d50000000006d5000000000000000000000887000000000000000000000b87000000000000000000000a47000000000000000000000887000000000000000000000b87000000000000000000000a47000000000000000000000887000000000000000000000b87000000000000000000000887000000000000000000000b87000000000000000000000a47000000000000000000000887000000000000000000000b87000000000000000000000a47000000000000000000000887000000000000000000000b87000000000000000000000891000000000891000000000b91000000000b11000000000000000000000a51000000000000000000000b11000000000000000000000a5b000000000000000000000000000000000b11000000000000000000000a51000000000b11000000000891000000000891000000000b91000000000b11000000000000000000000a51000000000000000000000b11000000000000000000000a5b000000000000000000000000000000000b11000000000000000000000a51000000000b11000000000754000000000000000000000754000000000754000000000000000000000754000000000754000000000000000000000754000000000754000000000000000000000754000000000000000000000754000000000754000000000000000000000754000000000000000000000754000000000754000000000000000000000754000754000754000000000000000000000754000000000754000000000000000000000754000000000000000000000754000000000754000000000000000000000882000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d42000000000000000000000000000000000cc2000000000000000000000000000000000c42000000000000000000000b02000000000000000000000000000000000000000000000e82000000000000000000000e02000000000000000000000000000000000000000000000cc2000000000000000000000000000000000000000000000d42000000000000000000000791000000000791000000000a910000000009d1000000000000000000000891000000000000000000000a910000000000000000000009db000000000000000000000000000000000891000000000000000000000791000000000a91000000000751000000000751000000000a51000000000911000000000000000000000811000000000000000000000751000000000000000000000a5b000000000000000000000000000000000911000000000000000000000811000000000911000000000955000000000000000000000955000000000955000000000000000000000955000000000955000000000000000000000955000000000955000000000000000000000955000000000000000000000955000000000955000000000000000000000914000000000000000000000914000000000914000000000000000000000914000000000914000000000000000000000914000000000914000000000000000000000914000000000000000000000914000000000914000000000000000000000747000000000000000000000a47000000000000000000000907000000000000000000000747000000000000000000000a47000000000000000000000907000000000000000000000747000000000000000000000a47000000000000000000000747000000000000000000000a47000000000000000000000907000000000000000000000747000000000000000000000a47000000000000000000000907000000000000000000000747000000000000000000000a47000000000000000000000a51000000000a51000000000d51000000000cd1000000000000000000000c11000000000000000000000cd1000000000000000000000c1b000000000000000000000000000000000cd1000000000000000000000c11000000000cd1000000000a51000000000a51000000000d51000000000cd1000000000000000000000c11000000000000000000000cd1000000000000000000000c1b000000000000000000000000000000000cd1000000000000000000000c11000000000cd1000000000914000000000000000000000914000000000914000000000000000000000914000000000914000000000000000000000914000000000914000000000000000000000914000000000000000000000914000000000914000000000000000000000914000000000000000000000914000000000914000000000000000000000914000914000914000000000000000000000914000000000914000000000000000000000914000000000000000000000914000000000914000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e82000000000e02000000000d42000000000e02000000000d42000000000000000000000000000000000000000000000000000000000000000000000cc2000000000d42000000000cc2000000000000000000000000000000000d42000000000cc2000000000000000000000b02000000000000000000000945000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c45000000a02bc5000000a02b05000000a02bc5000000a02b05000000000000000000000000000000000ac5103b00304000304000304000000000000a85000000a02b05000000a02a85000000000000000000000000000000a02b05000000a02a85000000000000000000a028c5000000000000000000000951000012000951000012000c51000012000bd1000012000013000012a0ab11000012000013000012a0abd1000012000013000012a0ab11000012000013000012000011000012a0abd1000012000013000012a0ab11000012000bd1000012000b11000012000b11000012000e11000012000d91000012000013000012a0acd1000012000013000012a0ad91000012000013000012a0acd1000012000013000012000011000012a0ad91000012000013000012a0acd1000012000d91000012000b14000015000016000017000b14000015000b14000015000016000017000b14000015000b14000015000016000017000b14000015000b14000015000016000017000b14000015000016000017000b14000015000b140000150000160000170009d40000150000160000170009d40000150009d40000150000160000170009d40000150009d40000150000160000170009d40000150009d40000150000160000170009d40000150000160000170009d40000150009d4000015000016000017000945000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a02b05000000000000000000000000000000a02a85000000000000000000000000000000a02a05000000000000000000a028c5000000000000000000000000000000000000000000000c45000000000000000000a02bc5000000000000000000000000000000000000000000000a85000000000000000000000000000000000000000000a02b05000000000000000000000851000012000851000012000b51000012000a91000012000013000012a0a951000012000013000012a0ab51000012000013000012a0aa91000012000013000012000011000012a0a951000012000013000012a0a851000012000b51000012000811000012000811000012000b110000120009d1000012000013000012a0a8d1000012000013000012a0a811000012000013000012a0ab11000012000013000012000011000012a0a9d1000012000013000012a0a8d10000120009d1000012000a14000015000016000017000a14000015000a14000015000016000017000a14000015000a14000015000016000017000a14000015000a14000015000016000017000a14000015000016000017000a14000015000a140000150000160000170009d40000150000160000170009d40000150009d40000150000160000170009d40000150009d40000150000160000170009d40000150009d40000150000160000170009d40000150000160000170009d40000150009d4000015000016000017000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a02e05000000a02d85000000a02d05000000000e05000000000d85000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d45000d80304000304000000000000000000d45000d80304000304000000d45000d80000d05000000000cc5000000000c45000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a02e05000000000000000000000000000000a02d85000000000000000000000000000000a02d05000000a02d85000000a02ec5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a02d85000000000000000000000000000000000000000000a02e05000000000000000000000851000012000851000012000b51000012000a91000012000013000012a0a951000012000013000012a0ab51000012000013000012a0aa91000012000013000012000011000012a0a951000012000013000012a0a851000012000b510000120008d10000120008d1000012000bd1000012000a91000012000013000012a0a9d1000012000013000012a0a8d1000012000013000012a0abd1000012000013000012000011000012a0aa91000012000013000012a0a9d1000012000a91000012000a14000015000016000017000a14000015000a14000015000016000017000a14000015000a14000015000016000017000a14000015000a14000015000016000017000a14000015000016000017000a14000015000a14000015000016000017000a94000015000016000017000a94000015000a94000015000016000017000a94000015000a94000015000016000017000a94000015000a94000015000016000017000a94000015000016000017000a94000015000a9400001500001600001700029600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000065a00000000000000000000065a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007920000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003d80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003d8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c43c10000000000000000000000000000000000000000000cc3c10000000000000000000b83c10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d43c10000000000000000000cc3c10000000000000000000000000000000000000000000000000000000000000000000b03c10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d41c10000000000000000000000000000000000000000000000000000000000000000000b81c10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e81c10000000000000000000e01c10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c41c10000000000000000000000000000000000000000000000000000a02000000000000b81c10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d41c10000000000000000000cc1c10000000000000000000000000000000000000000000000000000000000000000000b01c10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000417000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000497000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b19000000000000000000000b19000000000b19000000000000000000000000000000000b19000000000b19000000000000000000000b19000000000000000000000b19000000000b19000000000000000000000000000000000000000000000000000000000000000000000cc4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b84000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b04000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b81c10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bc1c10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b81c10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a01000000000000000000000a010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006da0000000000000000000006da000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cc1c10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a01000000000a01000000000a01000000000a01000000000a01000000000a01000000000a01000000000a01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c41000000000000000000000000000000000000000000000000000000000000000000000b81000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d41000000000000000000000cc1000000000000000000000000000000000000000000000000000000000000000000000b01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c41c10000000000000000000000000000000000000000000000000000000000000000000b81c10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d41c10000000000000000000cc1c10000000000000000000000000000000000000000000000000000000000000000000b01c10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d41c10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a01000000000000000000000a01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000353000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a01000000000000000000000a01000000000000000000000a01000000000000000000000a01000000000000000000000a01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b1d000000000ccf000000000ccf000000000000000000000c5f000000000ccf000000000b1d000000000ccf000000000ccf000000000b1d000000000b1d000000000ccf000000000c5f000000000ccf000000000000000000000ccf000000000b1d000000000ccf000000000ccf000000000000000000000c5f000000000ccf000000000b1d000000000ccf000ccf000ccf000000000b1d000000000b1d000000000ccf000000000c5f000000000ccf00000000095f00000000095f00000000026030340032801650e00000000111208043f020003038c813f0000000000000000002d3302400627015b1300000001111208083f022101038d811f11010000000000000026030340032801650e00000000110208043f020003038d013f00008000000000000018330340092301650e00000001150208043f023f02038c813f1101000000000000002d3302400627015b1300000001111208083f022102038d811f11010000000000000037050140014001014000000001000000203f011f0101010100001722011b060601010000000001000000103f013f02021a3a19009901400000050140014001014000000001000000203f011f01010101000000050140014001014000000001000000203f011f01010101000000050140014001014000000001000000203f011f01010101000000050140014001014000000001000000203f011f01010101000000050140014001014000000001000000203f011f01010101000000050140014001014000000001000000203f011f0101010100001e2501406f1e016f2e00000001100507013f022101029a7a1611798120020d020140040507030000000000000000083f010001051a7a1200cc831122000f0400000a00000016000018050140014001010000000000000000043f01000105c23a2068c0003f58c00000500000000000000000142d0140161101580300000001061208013f021b01029a7a080179812030140501406f1e016f2e00000000100507013f020001029a7a13007981170214020140014001791200000001000000203f011f040401160000001b0000001d00001422000037020119110001800400000000000000083f04000204610d002000100000001400001419000037020119110001800400000000000000083f04000204610d002000110000001400001419000014010119a70001800400000000000000103f04000304610d001000100000001400001419000014020140014001791200000001000000203f011f040400160000001b0000001f00001422000014020140014001791200000001000000203f011f040400160000001b0000001e000014220000280501400214010a0000000000000000013f0100020200fc200faa000f010d0402403d1401290a00000000011000203f02000403820112000000000000000000142d0240271101580300000001061208013f021b01029a7a08017981203000050140014001014000000001000000203f011f0101010100002c05012d060001010000000000000000013f01000106ce7a202019f12019006c000000650000006000000059000032050140014001014000000001000000203f011f0101010100001e040140050a01030000000000000000043f010001030de52000018010001a7a25304b61726d6100234f786964652f536f6e696b000000000000000000000000000000000000000000000000746f6d00000000666173746472756d000000".replace(/../g, function(r) {return String.fromCharCode(parseInt(r,16))})

	ahxSong.LoadSong("5448580124664028000040291c000e000d000c000b000a0009000800070006000500040001000600030002000f0006000500040001000600030002000f0006000500120001000600030010000f001100130015001a0011001600180017001100130018001a001900160018001400110013001b001a00110016001c0017001100130000001a0006000500040001000600030002000f0006000500040001000600030002000f00110013001b001a00110016001c001700110013001e001a000600050004001f0006000300020020000600050004001d000600030002000f000e000d000c000b00210009000800070022000d000c000b000a0009000800070006000500040001000600030002000f0006000500040001000600030002000f0006000500040001000600030002000f0006000500040001000600030002000f0023002400250026002700280000002900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a01000000000000000a01000000000000000a01000000000000000a01000000000000000a01000000000000000a01000000000000000a0164a0000000000000000000000000000000000000000000005ca00000000000000000000064a000000000000000000000000000000000000000000000000000000a01000a01000a01000a01000a01000a01000a018c6000000000000c100000009460000000008c6c100000008c6000000000946c100000009460000000008c6c100000008c6c10000000946c08000000946c080000008c6c06000000946c06000000946c040000008c6c040000008c6c02000000946c02000000000000000000208000000000000000000000000000000000000000000000000c100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020000000000000000000000000000000000000000000001820000000000000000000002020000000000000000000000000000000000000000000002c7000000000000000000000000101000101000101000101182000000000000c20000000202000000000000000000000502000000000000000000000182000000000000000000000202000000000000000000000000000000000000000000000202000000000000000000000502000000000000000000000202000000000000000000000348000000000000000000000000000000000000000000000000c200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003420000000000000000000000000000000000000000000002c20000000000000000000003420000000000000000000000000000000000000000000004070000000000000000000000001010001010001010001012c7000000000000c200000003470000000000000000000000000000000000000000000002c20000000000000000000003420000000000000000000000000000000000000000000002c20000000000000000000003420000000000000000000002c2000000000000000000000341000000ec3000000000000344c08000000000000000000345000000000000000000000344c20000000345c20000000344c20000000345c20000000341000000ec3000000000000345000000000341000000ec3000000000000000000000000341000000ec3000000000000344c08000000000000000000345000000000000000000000344c20000000345c20000000344c20000000345c20000000341000000ec3000000000000345000000000341000000ec30000000000000000000000009c6c200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008c6c20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000806c20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000000000000000000000060d000000000000000000c0060dc08000000000000000c0030d000000000000000000c0030dc08000000000000000c0000000000000000000000000000000000000000000000000000000000000030d000000000000000000c0030dc08000000000000000c0060d000000000000000000c0060dc08000000000000000c0000000000000020a00050a330000330000330000330000330806c20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000946c20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000706c20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000886c20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000646c20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000786c20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000947f08000000000000000c08947000000000000000000000000c18000000000000000000a07000000000000000000000947c08000000000000000000a07c080000000000000000000000000000000000000000008c70000000000000000000009470000000000000000000008c7c18000000000000000000947c180000000000000000008c7c10000000000000000000947c100000000000000000008c7c08000000000000000000947c080000000000000000008c7c0800000000000000000050a00000000000000000000000000000000000000000000048a00000000000000000000050a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a01000a01000a01000a01000a01000a01000a01000a01000a01000a01000a01000a01000a01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080a0000000000000000000008c00000000000000000000000000000000000000000000008000000000000000000000007800000000000000000000008000000000000000000000009c0000000000000000000000940000000000000000000000000000000000000000000000041000000ec3000000000000344c08000000000000000000345000000000000000000000341000000ec3000000000000344c08000000000000000000341000000ec3000000000000345000000000342ec2000ec33c4c08000000000000000000341000000ec3000000000000344c08000000000000342ec2345000000000000000000000341000000ec3000000000000344c08000000000000000000341000000ec3000000000000345000000000342ec2000ec33c4c08000000000000000000947cc0000000000000000c08947000000000000000000000000c18000000000000000000a07000000000000000000000947c08000000000000000000a07c080000000000000000000000000000000000000000008c70000000000000000000009470000000000000000000008c7c18000000000000000000947c180000000000000000008c7c10000000000000000000947c100000000000000000008c7c08000000000000000000947c080000000000000000008c7c08000000000000000000210cd0000c40000000000c40000000000c40000000000c40000000000c40000000000c3c000000000c39000000000c36000000000c33000000000c31000000000c2c000000000c29000000000c26000000000c23000000000c21000000000c1c000000000c19000000000c16000000000c13000000000c11000000000c0c000000000c09000000000c06000000000c03000000000c01000000000c0000000000000000000000000000000000000000000000000000000000000000000000000020e0000000000000000000000000000000000000000000002ce0000000000000000000003ce00000000000000000000000000000000000000000000034e0000000000000000000000000000000002ce00000000000000000000000000000000020e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000018e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a01000000000a01000000000a01000000000a01000000000a01000000000a01000000000a01000000000a01000000000000000000000000000000000000508cc0000000000a0a000a0a508c30000000508000000000000a0a000a0a508c30000a0a508000000000000a0a000a0a000000000000508000000000588000000000000a0a000a0a588000000000588c30000a0a588000000000588c30000a0a210cd0000c40000000000c40000000000c40000000000c40000000000c40000000000c3c000000000c39000000000c36000000000c33000000000c31000000000c2c000000000c29000000000c26000000000c23000000000c21000000000c1c000000000c19000000000c16000000000c13000000000c11000000000c0c000000000c09000000000c06000000000c03000000000c01000000000c0000000000000000000000000021000000000028f00000000000000000000000000000000020e0000000000000000000000000000000000000000000002ce0000000000000000000003ce00000000000000000000000000000000000000000000034e0000000000000000000000000000000002ce00000000000000000000000000000000020e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002ce00000000000000000000034e0000000000000000000003ce000000000000000000000508cc0000000000a0a000a0a508c30000000508000000000000a0a000a0a508c30000a0a508000000000000a0a000a0a000000000000508000000000508000000000000a0a000a0a508000000000508c30000a0a508000000000508c30000a0a508000000000000a0a000a0a508c30000000508000000000000a0a000a0a508c30000a0a508000000000000a0a000a0a000000000000508000000000588000000000000a0a000a0a588000000000588c30000a0a588000000000588c30000a0a041000000ec3000000000000344c08000000000000000000345000000000000000000000341000000ec3000000000000344c08000000000000000000341000000ec3000000000000345000000000342ec2000ec33c4c08000000000000000000341000000ec3000000000000344c08000000000000342ec2345000000000000000000000341000000ec300000000000000000000000000000000000034100000000000000000000000000000000004100000000000000000000000000000000020e0000000000000000000000000000000000000000000002ce0000000000000000000003ce00000000000000000000000000000000000000000000034e0000000000000000000000000000000002ce00000000000000000000000000000000020e0000000000000000000000000000000000000000000002ce00000000000000000000034e00000000000000000000000000000000000000000000034e0000000000000000000000000000000003ce0000000000000000000000000000000008cace00000000000000000008800000000000000000000008c000000000000000000000088000000000000000000000080a0000000000000000000000000000000000000000000000000000000000000000000009c000000000000000000000080000000000000000000000078000000000000000000000080000000000000000000000088000000000000000000000080000000000000000000000000000000000000000000000000000000000000000000000080a0000000000000000000008c00000000000000000000008800000000000000000000008ca00000000000000000000088000000000000000000000080000000000000000000000000000000000000000000000000000000000000000000000080a0000000000000000000008c00000000000000000000000000000000000000000000008000000000000000000000007800000000000000000000008000000000000000000000009ca00000000000000000000094a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a01000000000000000a01000000000000000a01000000000000000a01000000000000000a010000000000000000008c6000000000000c100000009460000000008c6c100000008c6000000000946c100000009460000000008c6c100000008c6c10000000946c08000000946c080000008c6c06000000946c06000000946c040000008c6c040000008c6c02000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a01000000000a01000000000a01000000000a01000000000a0100000094b000000c2094bc20000c2094b000000000000c10000000a0b000000c20a0bc20000c20a0b00000000094bc08000000a8b000000000a8bc20000000a8bc30000000a0bc08000000a8b102b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a01000a01000a01000a01000a01000a01000000000000000000000000a0b0009cb000000000000c10000000000000000000a0b0009cb000000000000c1000000000000000000000000000000094b0000000009cbc100000009cb00000000094bc100000008cb00000000094bc100000008cb00094b00078b10280b000000000000000000000000000000000000000000000000000000000000000000a01000000000a01000000000a01000000000a01000000000a01000000000000000000000000000000000000000000000000a0b0009cb000000000a0bc100000008cb0000000009cbc1000000078b00080b0000000000000000000000000000000000000008cb00000000080bc1000000080b0000000008cbc1000000094b0000000008cbc1000000080b000000000000000000000641000000000641c04000000641c03000000641c02000000041c02000000041c0100000000000000000060d000000000000c0000000060dc08000000000000000c0030d000000000000000000c0030dc08000000000000000c0000000000000000000000000000000000000000000000000000000000000030d000000000000000000c0030dc08000000000000000c0060d000000000000000000c0060dc08000000000000000c0000000000000000000000000000000000000000000000000050d000000000000000000c0050dc08000000000000000c0000000000000000000000000020d000000000000000000c0020dc08000000000000000c0050d000000000000000000c0050dc08000000000000000c0000000000000000000000000000000000000000000000000000000000000000000000000028d000000000000000000c0028dc08000000000000000c0058d000000000000000000c0058dc08000000000000000c00000000000000000000000000000000000000000000000000341000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000947f08000000000000000c08947000000000000000000000000c18000000000000000000a07000000000000000000000947c08000000000000000000a07c08000000000000000000947c04000000000000000000a07c04000000000000000000042000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000647f08000000000000000c08647000000000000000000000000c18000000000000000000707000000000000000000000647c08000000000000000000707c08000000000000000000647c04000000000000000000707c04000000000000000000083000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000344000000000000000000000000000000000000000351c01000000000c02000000000c03000000000c04000000000c05000000000c06000000000c07000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000947c03000000000000000000a07c03000000000000000000947c02000000000000000000a07c02000000000000000000947c01000000000000000000a07c01000000000000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000647c03000000000000000000707c03000000000000000000647c02000000000000000000707c02000000000000000000647c01000000000000000000707c01000000000000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c07000000000000000000000c06000000000000000000000c05000000000000000000000c04000000000000000000000000000c03000000000000000000000000000c02000000000000000000000000000c01000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040040140044001140000000000000000043f0400010a626d002001e6000000620000005d00008c593300080070000800700008007000080070000800700040040140043c08100300000000000000043f040001027a7822349989400040040140043c014c0000000000000000043f040001028d8934000000000040050140040001010000000000000000013f01000103027a3f000df1200a5400021f400301400240010b0000000000000000083f01000105626e002001e30000005f0000005b0000026e0000322b024001400101400000001f200004043f0c3f0202810900ff0109002032030240014001014000000000200105083f03000102808900000d89202040610140014007074000000004000000103f0e3505030d891230100c0100141000004061014001400707400000000400000010350e3505030d891230100e01001410000032330240014001014000000001200105083f031f0102108910308d8920003202024001400101400000000034040220330d000102808900000d89202040390140040e011f0000000001000000203f0a1f01020d892020800000004021014001401f290000000001000000203f011f04020d91241200050000402b014001403329000000000b000000203f013d01071089f02500000000000000000000000000000000000000000000000040610140014007074000000004000000103f0e3505040d8c123010100100141500001417000040610140014007074000000004000000103f0e3505040d8c12301010010000150000141700000e210140014047294000000001000000203f011f0e130219002a0016000000170000001a0000001d0000001a0000001c0000001e000000190000001a0000001d0000001b0000001d000000190000001a0000001d0000001c0000141b00000000000000200100010001010000000001000000203f011f010000200100010001010000000001000000203f011f010000200100010001010000000001000000203f011f010000200100010001010000000001000000203f011f010000200100010001010000000001000000203f011f010000200100010001010000000001000000203f011f010000200100010001010000000001000000203f011f010000200100010001010000000001000000203f011f010000200100010001010000000001000000203f011f010000200100010001010000000001000000203f011f01003203024001400101400000000020010b043f0c00020281010000010100207379706875732d33616d457465726e616c2e6168780033616d20457465726e616c00284b4c4620636f766572290000627920535950485553000045722e2e2e746869732077617320636f6d6d697373696f6e65640061626f757420332079656172732061676f207768656e00476c6f6d616720616e64204a756c69616e2077616e74656420746f00646f2061204b4c4620636f7665727320636f6d70696c6174696f6e2e004265696e672061206469636b686561642c20616e6420686176696e6720686164006c6f616473206f662073686974206f6e206d79206d696e640073696e6365207468656e2c2049206469642031207061747465726e00616e64206e657665722066696e69736865642074686520636f76657200756e74696c20746f6461792e2044414d4e204d4520544f2048454c4c2e00004e6f7420313030252068617070792077697468206974202d20007769736820414858206861642061206465646963617465642052415020006368616e6e656c2c20616e6420492070726f6261626c790073686f756c646120646f6e6520697420696e20486976656c79547261636b6572006275742e2e2e49206c6f76652041485820616e642077616e74656400746f2067657420646f776e207769746820697420616674657220746f6f006c6f6e67206170617274203a290044656469636174656420746f20476c6f6d616720616e64004a756c69616e2028432d4d656e29202d20736f72727920666f72006265696e6720736f20736869742c20677579732e0000687474703a2f2f7379706875732e6e65740046494c544552525900".replace(/../g, function(r) {return String.fromCharCode(parseInt(r,16))})
	
	,
			function() {
				ahxMaster.Play(ahxSong);
				drawCanvas();
			}
		);

//drawCanvas();
}

//
// init general variables
//

var r="rgba(";
var c1 = r+"0,0,0,1)", c2 = r+"0,0,0,.1)", c3 = r+"254,147,88,1)", c4 = r+"94,88,254,1)", c5 = r+"254,229,88,1)";		

//
// init dom side text
//

var elem = D.createElement("div");
var S = elem.style;
S.background = "#fff";
S.position = "absolute";
//elem.style.top = "45%";
//elem.style.left = "0";
//elem.style.width = "100%";
S.height = "100px";
S.lineHeight = elem.style.height;
//elem.style.marginTop = "-20px";
S.letterSpacing = "-3px";
S.textAlign = "center";
S.fontSize = "60px";
S.border = "solid #49b249";//"solid #fe9358";
S.borderWidth = "5px 0";
//elem.style.textTransform = "lowercase";
//elem.style.color = "#333";
S.fontFamily = "Helvetica";
b.appendChild(elem);
			
function fText(text,styles) {
	S.display = "";
	if (styles) {
		for(style in styles) {
			S[style] = styles[style];
		}
	}
	elem.innerHTML = text;
	//ctx.fillText(text, w*0.5, (h*0.5) + pad);
}

function s(){
	S.display="none";
}

function distance(x1, y1, x2, y2) {
	return Math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))
}

// original from http://stackoverflow.com/questions/9043805/test-if-two-lines-intersect-javascript-function
function lineIntersect(x1,y1,x2,y2,x3,y3,x4,y4) {
    var x=((x1*y2-y1*x2)*(x3-x4)-(x1-x2)*(x3*y4-y3*x4))/((x1-x2)*(y3-y4)-(y1-y2)*(x3-x4));
    var y=((x1*y2-y1*x2)*(y3-y4)-(y1-y2)*(x3*y4-y3*x4))/((x1-x2)*(y3-y4)-(y1-y2)*(x3-x4));
	//x = parseFloat(x.toFixed(7));
	//y = parseFloat(y.toFixed(7));
	
	//TODO: sometimes the point outside of segment comparison tests fails, when testing against a very long straight line
	
    //console.log(x + ' ' + y);
	if (isNaN(x)||isNaN(y)) {
        return false;
    } else {
        if (x1>=x2) {
            if (!(x2<=x&&x<=x1)) {return false;}
        } else {
            if (!(x1<=x&&x<=x2)) {return false;}
        }
        if (y1>=y2) {
            if (!(y2<=y&&y<=y1)) {return false;}
        } else {
            if (!(y1<=y&&y<=y2)) {return false;}
        }
        if (x3>=x4) {
            if (!(x4<=x&&x<=x3)) {return false;}
        } else {
            if (!(x3<=x&&x<=x4)) {return false;}
        }
        if (y3>=y4) {
            if (!(y4<=y&&y<=y3)) {return false;}
        } else {
            if (!(y3<=y&&y<=y4)) {return false;}
        }
    }
    return {'x':x, 'y':y};
}

var maxlines = 350;
var maxactivelines = 16;

var lines = [];
/*
lines[0] = [];
lines[0][0] = { 'x': 300.0, 'y': 400.0, 'direction': Math.PI*0.33, 'curve': Math.PI*0.05, 'step': 6.0, 'visible': true };

lines[1] = [];
lines[1][0] = { 'x': 100.0, 'y': 100.0, 'direction': 0.0, 'curve': Math.PI*0.025, 'step': 6.0, 'visible': true };

lines[2] = [];
lines[2][0] = { 'x': 500.0, 'y': 500.0, 'direction':  Math.PI, 'curve': Math.PI*0.015, 'step': 6.0, 'visible': true };

lines[3] = [];
lines[3][0] = { 'x': 800.0, 'y': 800.0, 'direction':  Math.PI*1.2, 'curve': -Math.PI*0.015, 'step': 6.0, 'visible': true };

lines[4] = [];
lines[4][0] = { 'x': 500.0, 'y': 500.0, 'direction':  -Math.PI, 'curve': -Math.PI*0.015, 'step': 6.0, 'visible': true };
*/

/*var nbars = 3;
var wbar = w/(nbars+1);
for (var i=0; i<nbars; i++) {
	lines[i] = [];
	lines[i][0] = { 'x': (i+1)*wbar, 'y': 0.0, 'direction': 0, 'curve': 0, 'step': 0.0, 'visible': true };
	lines[i][1] = { 'x': (i+1)*wbar, 'y': h, 'direction': 0, 'curve': 0, 'step': 0.0, 'visible': true };
}*/

/*var nlines = 12;
var ang = (Math.PI*2) / 12.0;
for (var j=0; j<nlines; j++) {
	lines[lines.length] = [];
	lines[lines.length-1][0] = { 'x': w*.5+Math.sin(ang*j), 'y': h*.5+Math.cos(ang*j), 'direction':  ang*j, 'curve': ang*Math.PI*0.015, 'step': 6.0, 'visible': true };
}*/

var nlines = 8;
var ang = (Math.PI*2) / 12.0;
for (var j=0; j<nlines; j++) {
	lines[lines.length] = [];
	lines[lines.length-1][0] = { 'x': 1.0, 'y': j*(h/nlines), 'direction':  Math.PI*0.5, 'curve': ang*Math.PI*0.015, 'step': 6.0, 'visible': true };
}

var nlines = 8;
var ang = (Math.PI*2) / 12.0;
for (j=0; j<nlines; j++) {
	lines[lines.length] = [];
	lines[lines.length-1][0] = { 'x': w-1.0, 'y': j*(h/nlines), 'direction':  -Math.PI*0.5, 'curve': -ang*Math.PI*0.015, 'step': 6.0, 'visible': true };
}

var stars = [];
let nstars = 200;
for (let i=0; i<nstars; i++) {
	stars[i] = { 'x': Math.random()*w, 'y': Math.random()*h };
}

function drawCanvas() {
		
	var d = new Date();
	var n = d.getTime();

	function drawBackground(timer, gradstart) {
		// background
		ctx.globalCompositeOperation="source-over";
		var lingrad = ctx.createLinearGradient(0,0,0,h);
		//lingrad.addColorStop(0, '#00ABEB');
		//lingrad.addColorStop(1, '#fff');
		lingrad.addColorStop(0, gradstart);
		lingrad.addColorStop(1, '#115');
		ctx.fillStyle = lingrad;
		ctx.fillRect(0,0,w,h);
		
		for (let i=0; i<nstars; i++) {
			ctx.fillStyle = "rgba("+parseInt(200+Math.sin(timer*0.05)*(i%20+10),10)+",255,255,"+((Math.sin(timer*0.001 + i%5)+1.0)*0.5)+")";
			ctx.fillRect(stars[i]['x'], stars[i]['y'], 1, 1);
		}
	}
	
	function drawSun(posX, posY) {
		var grd=ctx.createRadialGradient(posX, posY, 10 ,posX,posY,100);
		grd.addColorStop(0,"rgba(250,250,80,1.0)");
		grd.addColorStop(0.7,"rgba(250,250,200,1.0)");
		grd.addColorStop(1.0,"rgba(255,255,255,0.0)");
		//grd.addColorStop(1.0,"transparent");
		ctx.fillStyle = grd; //"rgba(250,250,200,0.8)";
		ctx.beginPath();
		ctx.arc(posX, posY, 80, 0, 2 * Math.PI, false);
		ctx.closePath();
		ctx.fill();
	}
	
	let repulsion = 5000;
	let effect = 3;
				
	function drawLines(timer, klfx, klfy) {
		// stroke
		ctx.globalCompositeOperation="source-over";
		ctx.lineCap="round";
		ctx.lineWidth=2;
		var gradient=ctx.createLinearGradient(0,0,w,0);
		gradient.addColorStop("0","magenta");
		gradient.addColorStop("0.5","blue");
		gradient.addColorStop("1.0","red");
		ctx.strokeStyle=gradient;		
		
		var activelinecount = 0;
		
		// draw lines
		for (let i=0; i<lines.length; i++) 
		{
			// add next line segment
			let ref = lines[i][lines[i].length-1];
			
			// stop adding lines if it's already out of bounds
			if (!((ref['x'] <= 0) || (ref['x'] >= w) || (ref['y'] <= 0) || (ref['y'] >= h)) && (activelinecount < maxactivelines))
			{
				activelinecount++;
				
				// calculate next line step
				// TODO: fix this to calculate position based on timer and not frames
				let thisx = ref['x'] + Math.sin(ref['direction'])*ref['step'];
				let thisy = ref['y'] + Math.cos(ref['direction'])*ref['step'];
				
				// test if this new line segment will cross any previous lines existing
				let intersect = false;
				for (let k=0; k<lines.length && intersect == false; k++) 
				{
					for (let p=0; p<lines[k].length-1; p++) 
					{
						let r1 = lines[k][p];
						
						// dont bother checking intersection of two invisible lines
						if (!r1['visible']) continue;
						
						let r2 = lines[k][p+1];
						
						let li = lineIntersect(r1['x'],r1['y'],r2['x'],r2['y'],ref['x'],ref['y'],thisx,thisy);
						if (li != false) {
							intersect = li;
							break;
						}
					}
				}
				
				// calculate visibility switch
				// default same as previous segment
				let visible = ref['visible'];
				if (intersect) {

					// snap to line intersection point
					// snap the previous point if moving from visible to invisible
					// snap the new point if its becoming visible
					if (visible) {
						ref['x'] = intersect['x'];
						ref['y'] = intersect['y'];
					} else {
						thisx = intersect['x'];
						thisy = intersect['y'];
					}
					
					// chance it doesn't switch invisibility despite intersecting something
					if (Math.random()<0.2) {
						// as you were
					} else {
						// toggle on and offf
						visible = !ref['visible'];
					}
				}
				
				lines[i][lines[i].length] = {
					'x': thisx,
					'y': thisy,
					'direction': ref['direction']+ref['curve'],
					'curve': lines[i][0]['curve'] * Math.sin(timer*0.005),
					'step': ref['step'],
					'visible': visible };
					//'visible': (Math.random()<0.10)?(ref['visible']):(!ref['visible']) };
					
				// spawn new lines within a certain probability
				if ((ref['visible']) && (Math.random()<0.04)) {
					var thissize = lines.length;
					if (thissize < maxlines) {
						lines[thissize] = [];
						lines[thissize][0] ={
						'x': thisx,
						'y': thisy,
						'direction': ref['direction']+ref['curve']*2,
						'curve': -lines[i][0]['curve'] ,
						'step': ref['step'],
						'visible': true };
					}
				}
			}

			// plot whole line
			let prev = false;
			for (let j=0; j<lines[i].length; j++) {

				let thisx = lines[i][j]['x'];
				let thisy = lines[i][j]['y'];
				let angle = Math.atan2(thisx - klfx, thisy - klfy);
				let baseDiff = distance(klfx, klfy, thisx, thisy);
				let dist = repulsion / baseDiff;
				let size = ~~(Math.round(dist * 0.5)) * (effect * 2);
				//this.radius = size > 100 ? this.radius : size;
				thisx += ((Math.sin(angle) * dist)) * effect;
				thisy += ((Math.cos(angle) * dist)) * effect;
				
				
				// was invisible, now it's visible, lets start drawing the line
				if ((prev == false) && (lines[i][j]['visible'])) {
					// flash lines white when the timer equals the index
					if ((timer % lines[i].length) == i) {
						ctx.strokeStyle="rgba(255,255,255,1.0)";
					} else {
						ctx.strokeStyle=gradient;
					}
					// start line
					ctx.beginPath();
					ctx.moveTo(thisx, thisy);
					prev = true;
				// was already visible and still is, lets keep drawing the line
				} else if ((prev == true) && (lines[i][j]['visible'])) {
					ctx.lineTo(thisx, thisy);
				// was already visible and now it's not, lets stop drawing at this segment of the line
				} else if ((prev == true) && (!lines[i][j]['visible'])) {
					//ctx.closePath();
					ctx.stroke();
					prev = false;
				}
			}
			// make sure it's closed when it's ended
			if (prev == true) {
				//ctx.closePath();
				ctx.stroke();
			}
		}
	}
	
	function drawSunRays(timer, posX, posY) {
		var phase1 = timer/25000;
		var phase2 = timer/2500;
		var num = 15;
		var angle = (Math.PI*2)/num;
		var numt = 11;
		for (let j=0; j<numt; j++) {
			var thisb = parseInt(Math.sin(phase2*0.5 + j)*35+140, 10);
			ctx.fillStyle = "rgba(240,240,"+thisb+","+0.015+")";
			for (var i=0; i<num; i++) {					
					var opening = Math.sin(i*angle)*10 + j*10;
					size = 50+sizebump+Math.sin(timer/1000)*3+Math.sin(timer*(j-numt*.5)/1000)*2;
					ctx.save();
					ctx.translate( posX+Math.sin(i*angle+phase1)*opening, posY+Math.cos(i*angle+phase1)*opening );
					ctx.rotate(i*angle+Math.sin(phase2+Math.sin(i*angle))*3);
					ctx.beginPath();
					ctx.moveTo(-size*.5*j,-size*.5*j);
					ctx.lineTo(0,size);
					ctx.lineTo(size*.5*j,-size*.5*j);
					//ctx.lineTo(size*.5,size/2*Math.sqrt(3));
					ctx.closePath();
					ctx.fill();
					//ctx.stroke();
					ctx.restore();
			}
		}
	}

	function drawLogo(klfx, klfy) {
		ctx.save();
		ctx.translate(klfx, klfy);
		ctx.fillStyle = "rgba(255,255,255,1.0)";
		ctx.beginPath();
		ctx.arc(0, 0, 220, 0, 2 * Math.PI, false);
		ctx.translate(-170,-160);
		ctx.closePath();
		ctx.fill();
		draw(ctx);
		ctx.restore();
	}
	
	function drawOcean(timer, vpad) {
		ctx.globalCompositeOperation="xor";
		//ctx.fillStyle="#8080FF";
		ctx.fillStyle="#32f";
		let startnum = 30;
		let num = startnum;
		for (var i=0; i < num; i++) 
		{
			var thisx = i*(w/num);
			var thisy = h*0.6-vpad+Math.sin(timer*0.01 + i + num)*10;
			var thisw = (w/num)*(1.0+(Math.sin(timer*0.001 + i*num)+1.0)*0.5);
			var thish = h-thisy;
			ctx.fillRect( thisx, thisy, thisw, thish);
		}				
		num = startnum*0.8;
		for (i=0; i < num; i++) 
		{
			var thisx = i*(w/num);
			var thisy = h*0.65-vpad+Math.sin(timer*0.01 + i + num)*20;
			var thisw = (w/num)*(1.0+(Math.sin(timer*0.001 + i*num)+1.0)*0.5);
			var thish = h-thisy;
			ctx.fillRect( thisx, thisy, thisw, thish);
		}
		num = startnum*0.6;
		for (i=0; i < num; i++) 
		{
			var thisx = i*(w/num);
			var thisy = h*0.7-vpad+Math.sin(timer*0.01 + i + num)*30;
			var thisw = (w/num)*(1.0+(Math.sin(timer*0.001 + i*num)+1.0)*0.5);
			var thish = h-thisy;
			ctx.fillRect( thisx, thisy, thisw, thish);
		}
		num = startnum*0.4;
		for (i=0; i < num; i++) 
		{
			var thisx = i*(w/num);
			var thisy = h*0.75-vpad+Math.sin(timer*0.01 + i + num)*40;
			var thisw = (w/num)*(1.0+(Math.sin(timer*0.001 + i*num)+1.0)*0.5);
			var thish = h-thisy;
			ctx.fillRect( thisx, thisy, thisw, thish);
		}
		num = startnum*0.2;
		for (i=0; i < num; i++) 
		{
			var thisx = i*(w/num);
			var thisy = h*0.8-vpad+Math.sin(timer*0.01 + i + num)*50;
			var thisw = (w/num)*(1.0+(Math.sin(timer*0.001 + i*num)+1.0)*0.5);
			var thish = h-thisy;
			ctx.fillRect( thisx, thisy, thisw, thish);
		}
		num = startnum*0.1;
		for (i=0; i < num; i++) 
		{
			var thisx = i*(w/num);
			var thisy = h*0.85-vpad+Math.sin(timer*0.01 + i + num)*60;
			var thisw = (w/num)*(1.0+(Math.sin(timer*0.001 + i*num)+1.0)*0.5);
			var thish = h-thisy;
			ctx.fillRect( thisx, thisy, thisw, thish);
		}
	}

	let gradstart;
	let sizebump;	
	function drawThis() {
		
		let d2 = new Date();
		let n2 = d2.getTime();
		let timer = n2-n;
		
		//console.log(pattern + ' ' + note);
		
		// sync flash background
		gradstart = '#000';
		if ((pattern >= 3) && (pattern <= 8)) {
			let value = (9-note);
			if (value < 0) value = 0;
			gradstart = '#'+value+''+value+''+value;
		}
		
		// sync flash logo background with key dialing
		sizebump = 0;
		if ( (((pattern == 2) || (pattern == 28) || (pattern == 30)) && (((note > 13) && (note <= 16)) || ((note > 21) && (note <= 24)) || ((note > 39) && (note <= 42)) || ((note > 47) && (note <= 50)))) ||
		     ((pattern == 29) && (((note >= 0) && (note < 3)) || ((note > 11) && (note < 14)) || ((note > 19) && (note < 22)) || ((note > 39) && (note < 42)) || ((note > 47) && (note < 50))) ) )
		{
			sizebump = 30;
		}
		
		if (((pattern % 10) == 0) && (note < 10)) {
			// delete random lines, not the core 16
			//lines.splice(rand(lines.length-17)+16, 1);
			// delete all lines, not the core 16
			lines.splice(16, lines.length-16);
			// restart core 16
			for (let i=0; i<16; i++) spliceline(i);
		}
		
		drawBackground(timer, gradstart);
		
		switch(pattern) {
			case 0:
			case 1:
			case 2: {
				let klfx = w*0.5;
				let klfy = h*0.4;
				drawSunRays(timer, klfx, klfy);
				drawLogo(klfx, klfy);
			}
			break;
			case 3:
			case 4:	{
				if (pattern == 3) {
					fText("KLF is gonna rock you!",{"left":"0","top":"90%","marginTop":"-50px","bottom":"","width":"100%","height":"100px","color":"#000"});
				} else if ((pattern == 4)) {
					fText("the justified ancients of mu(min) are back");
				} else {
					s();
				}
				let klfx = w*0.5;
				let klfy = h*0.4;
				drawLines(timer, klfx, klfy);				
				drawSunRays(timer, klfx, klfy);
				drawLogo(klfx, klfy);
			}
			break;
			case 5:
			case 6: {
				if ((pattern == 5) && (note < 64)) {
					fText("with an intro not called variform");
				} else if ((pattern == 6) && (note < 64)) {
					fText("but \""+title+"\"");
				} else {
					s();
				}
				
				let klfx = w*0.5;
				let klfy = h*0.4;
				drawLines(timer, klfx, klfy);				
				drawSunRays(timer, klfx, klfy);
				drawLogo(klfx, klfy);
				drawOcean(timer, -h*0.15 + Math.sin(timer*0.001)*50);
			}
			break;
			
			default:				
				if (pattern == 7) {
					fText("you thought we were dead");
				} else if (pattern == 8) {
					fText("we kinda are...");
				} else if (pattern == 9) {
					fText("but KLF are coming back");
				} else if (pattern == 10) {
					fText("so here is a KLFtro!");
				} else if (pattern == 11) {
					fText("greets fly out to:");
				} else if (pattern == 12) {
					fText("Accession . [BrCr] . ASD . Astroidea");
				} else if (pattern == 13) {
					fText("ate bit . TPOLM . Bomb . BSDE");
				} else if (pattern == 14) {
					fText("CPU . Calodox . Collapse . Cocoon");
				} else if (pattern == 15) {
					fText("Conspiracy . coprocessor . Darklite");
				} else if (pattern == 16) {
					fText("deMarche . DESiRE . Epoch . Fairlight");
				} else if (pattern == 17) {
					fText("Farbrausch . flo . Fulcrum . Glenz");
				} else if (pattern == 18) {
					fText("Haujobb . Hornet . Hooy-Program . Jugz");
				} else if (pattern == 19) {
					fText("Kosmoplovci . TPOLM . Logicoma . MaWi");
				} else if (pattern == 20) {
					fText("Marshals . Mercury . MFX . Orange");
				} else if (pattern == 21) {
					fText("Quadtrip . Quite . Razor 1911 . Rebels");
				} else if (pattern == 22) {
					fText("Rift . Satori . Spontz . Still");
				} else if (pattern == 23) {
					fText("thesuper . TPOLM . TRSI . TRBL");
				} else if (pattern == 24) {
					fText("Unique . Unstable Label . TPOLM");
				} else if (pattern == 25) {
					fText("and you... ");
				} else if (pattern == 26) {
					fText("and your mother... (the giraffe)");
				} else if (pattern == 27) {
					fText("Enjoy Demobit 2017!");
				} else if (pattern == 30) {
					fText("message for Antti:");
				} else if (pattern == 31) {
					fText("A Koala can sleep up to 20 hours per day!");
				} else if (pattern == 32) {
					fText("so does the Emperor Penguin!");
				} else if (pattern == 37) {
					fText("credits");
				} else if (pattern == 38) {
					fText("code: ps - music: syphus");
				} else if (pattern == 39) {
					fText("looping..."); // until 23rd of August 2017
				} else {
					s();
				}
			
				// calculate klf logo position
				let klfx = w*0.5 + Math.sin(timer*0.00075)*w*0.15;
				let klfy = h*0.3 + Math.sin(timer*0.0005)*h*0.2;

				// lines
				drawLines(timer, klfx, klfy);
				
				// sun rays
				drawSunRays(timer, klfx, klfy);
				
				// klf logo
				drawLogo(klfx, klfy);
				
				// ocean waves
				drawOcean(timer, -h*0.15 + Math.sin(timer*0.001)*50);
		
			break;

		}	
		
	}
	
	(loop = function() {
		requestAnimationFrame(loop);
		drawThis();
	})();

}


function spliceline(lineid) {
	if (lineid in lines) {
		//console.log(lines[lineid].length);
		lines[lineid] = lines[lineid].splice(0, 1);
		//console.log(lines[lineid].length);
	}	
}

/*
// was going to be used for secret part, abandoned
document.onkeydown = checkKeycode;

function checkKeycode(e) {
	var keycode;
	if (window.event) keycode = window.event.keyCode;
		else if (e) keycode = e.which;
	console.log(keycode);
	if (keycode == 83) {
		for (var j=0; j<16; j++) {
			spliceline(j);
		}
	}
}*/

// KLF logo converted
// https://upload.wikimedia.org/wikipedia/en/e/ec/Pyramid_Blaster.png
// https://convertio.co/pt/png-svg/
// http://www.professorcloud.com/svg-to-canvas/
var draw = function(ctx) {
ctx.save();
ctx.beginPath();
ctx.moveTo(0,0);
ctx.lineTo(375,0);
ctx.lineTo(375,311.25);
ctx.lineTo(0,311.25);
ctx.closePath();
ctx.clip();
ctx.translate(0,0);
ctx.translate(0,0);
ctx.scale(1.25,1.25);
ctx.translate(0,0);
ctx.strokeStyle = 'rgba(0,0,0,0)';
ctx.lineCap = 'butt';
ctx.lineJoin = 'miter';
ctx.miterLimit = 4;
ctx.save();
ctx.fillStyle = "#000000";
ctx.strokeStyle = "rgba(0, 0, 0, 0)";
ctx.translate(0,249);
ctx.scale(0.1,-0.1);
ctx.save();
ctx.beginPath();
ctx.moveTo(1489,2412);
ctx.bezierCurveTo(1470,2386,1406,2300,1345,2222);
ctx.bezierCurveTo(1236,2082,1235,2080,1195,2080);
ctx.bezierCurveTo(1157,2080,790,2116,580,2141);
ctx.lineTo(485,2152);
ctx.lineTo(316,2106);
ctx.bezierCurveTo(223,2081,143,2057,139,2053);
ctx.bezierCurveTo(135,2048,127,1971,121,1880);
ctx.bezierCurveTo(92,1427,78,1178,83,1167);
ctx.bezierCurveTo(86,1159,163,1138,269,1115);
ctx.bezierCurveTo(369,1093,450,1072,450,1068);
ctx.bezierCurveTo(450,1061,374,959,124,632);
ctx.bezierCurveTo(60,548,10,477,13,474);
ctx.bezierCurveTo(15,471,195,427,411,374);
ctx.bezierCurveTo(788,284,1663,70,1820,30);
ctx.lineTo(1895,11);
ctx.lineTo(2028,113);
ctx.bezierCurveTo(2211,253,2319,336,2581,540);
ctx.bezierCurveTo(2705,636,2836,738,2872,765);
ctx.bezierCurveTo(2909,793,2939,817,2939,820);
ctx.bezierCurveTo(2940,826,2831,955,2635,1180);
ctx.bezierCurveTo(2553,1275,2454,1390,2415,1435);
ctx.bezierCurveTo(2377,1481,2323,1543,2297,1573);
ctx.lineTo(2249,1628);
ctx.lineTo(2257,1777);
ctx.lineTo(2265,1925);
ctx.lineTo(2240,1952);
ctx.bezierCurveTo(2217,1977,2206,1980,2090,1990);
ctx.bezierCurveTo(2021,1996,1955,2003,1943,2006);
ctx.bezierCurveTo(1930,2008,1847,2096,1737,2223);
ctx.bezierCurveTo(1635,2340,1545,2441,1537,2448);
ctx.bezierCurveTo(1525,2458,1517,2452,1489,2412);
ctx.closePath();
ctx.moveTo(1524,2303);
ctx.bezierCurveTo(1533,2271,1563,2050,1559,2046);
ctx.bezierCurveTo(1550,2038,1330,2064,1330,2073);
ctx.bezierCurveTo(1330,2085,1502,2319,1512,2319);
ctx.bezierCurveTo(1516,2320,1521,2312,1524,2303);
ctx.closePath();
ctx.moveTo(423,2024);
ctx.bezierCurveTo(438,2021,455,2010,460,2000);
ctx.bezierCurveTo(474,1974,473,1917,458,1902);
ctx.bezierCurveTo(448,1892,450,1886,464,1872);
ctx.bezierCurveTo(481,1856,481,1856,478,1875);
ctx.bezierCurveTo(476,1890,481,1895,500,1896);
ctx.bezierCurveTo(535,1896,550,1907,550,1934);
ctx.bezierCurveTo(550,1946,562,1967,576,1979);
ctx.lineTo(602,2002);
ctx.lineTo(595,1928);
ctx.bezierCurveTo(591,1888,584,1851,578,1845);
ctx.bezierCurveTo(572,1838,569,1843,572,1860);
ctx.bezierCurveTo(574,1877,570,1886,558,1888);
ctx.bezierCurveTo(544,1891,540,1885,540,1862);
ctx.bezierCurveTo(540,1846,538,1831,535,1829);
ctx.bezierCurveTo(531,1824,198,1869,192,1874);
ctx.bezierCurveTo(191,1876,193,1909,196,1949);
ctx.bezierCurveTo(201,2001,207,2020,217,2020);
ctx.bezierCurveTo(228,2020,231,2006,229,1958);
ctx.lineTo(226,1896);
ctx.lineTo(291,1884);
ctx.bezierCurveTo(326,1877,368,1871,383,1871);
ctx.lineTo(411,1870);
ctx.lineTo(408,1943);
ctx.lineTo(405,2015);
ctx.lineTo(350,2018);
ctx.bezierCurveTo(320,2020,291,2026,285,2031);
ctx.bezierCurveTo(275,2041,351,2037,423,2024);
ctx.closePath();
ctx.moveTo(544,2030);
ctx.bezierCurveTo(558,2025,570,2014,570,2005);
ctx.bezierCurveTo(570,1993,562,1990,535,1993);
ctx.bezierCurveTo(493,1998,485,2004,493,2025);
ctx.bezierCurveTo(500,2043,509,2044,544,2030);
ctx.closePath();
ctx.moveTo(765,1990);
ctx.bezierCurveTo(892,1975,892,1975,886,1932);
ctx.bezierCurveTo(883,1911,878,1864,875,1827);
ctx.bezierCurveTo(870,1782,864,1760,857,1763);
ctx.bezierCurveTo(850,1765,847,1782,848,1804);
ctx.bezierCurveTo(851,1833,846,1848,829,1866);
ctx.bezierCurveTo(817,1879,810,1893,813,1897);
ctx.bezierCurveTo(817,1900,820,1898,820,1892);
ctx.bezierCurveTo(820,1885,829,1880,841,1880);
ctx.bezierCurveTo(857,1880,861,1885,858,1907);
ctx.bezierCurveTo(854,1942,802,1960,783,1933);
ctx.bezierCurveTo(764,1908,767,1872,790,1853);
ctx.bezierCurveTo(801,1843,810,1829,810,1821);
ctx.bezierCurveTo(810,1810,807,1811,797,1825);
ctx.bezierCurveTo(780,1848,760,1837,760,1804);
ctx.bezierCurveTo(760,1791,755,1780,749,1780);
ctx.bezierCurveTo(742,1780,740,1806,745,1866);
ctx.bezierCurveTo(752,1947,751,1952,734,1948);
ctx.bezierCurveTo(719,1946,713,1932,708,1886);
ctx.bezierCurveTo(697,1801,688,1803,696,1889);
ctx.bezierCurveTo(703,1957,702,1962,684,1958);
ctx.bezierCurveTo(668,1955,664,1942,656,1877);
ctx.bezierCurveTo(651,1827,643,1800,635,1800);
ctx.bezierCurveTo(626,1800,625,1811,630,1843);
ctx.bezierCurveTo(634,1866,641,1911,645,1943);
ctx.bezierCurveTo(649,1976,656,2000,663,2000);
ctx.bezierCurveTo(670,2000,716,1995,765,1990);
ctx.closePath();
ctx.moveTo(976,1943);
ctx.bezierCurveTo(986,1928,991,1927,1001,1938);
ctx.bezierCurveTo(1032,1967,1033,1956,1014,1803);
ctx.bezierCurveTo(1011,1779,1004,1760,998,1760);
ctx.bezierCurveTo(991,1760,990,1787,995,1841);
ctx.bezierCurveTo(1002,1917,1001,1922,984,1918);
ctx.bezierCurveTo(969,1915,963,1900,954,1842);
ctx.bezierCurveTo(943,1769,936,1751,923,1764);
ctx.bezierCurveTo(912,1775,918,1881,930,1895);
ctx.bezierCurveTo(936,1902,938,1920,934,1934);
ctx.bezierCurveTo(929,1955,931,1960,945,1960);
ctx.bezierCurveTo(955,1960,969,1952,976,1943);
ctx.closePath();
ctx.moveTo(1115,1923);
ctx.bezierCurveTo(1126,1909,1131,1908,1143,1919);
ctx.bezierCurveTo(1155,1929,1175,1929,1235,1921);
ctx.bezierCurveTo(1323,1908,1331,1905,1324,1885);
ctx.bezierCurveTo(1320,1877,1314,1872,1310,1875);
ctx.bezierCurveTo(1290,1887,1272,1866,1266,1822);
ctx.bezierCurveTo(1253,1733,1248,1710,1240,1715);
ctx.bezierCurveTo(1236,1717,1235,1730,1237,1744);
ctx.bezierCurveTo(1243,1773,1225,1786,1203,1769);
ctx.bezierCurveTo(1190,1757,1188,1758,1192,1775);
ctx.bezierCurveTo(1195,1789,1203,1794,1218,1793);
ctx.bezierCurveTo(1242,1790,1254,1819,1248,1861);
ctx.bezierCurveTo(1245,1882,1239,1885,1205,1885);
ctx.lineTo(1165,1885);
ctx.lineTo(1155,1818);
ctx.bezierCurveTo(1140,1721,1127,1721,1135,1818);
ctx.bezierCurveTo(1142,1896,1141,1902,1124,1898);
ctx.bezierCurveTo(1109,1896,1103,1880,1095,1825);
ctx.bezierCurveTo(1087,1769,1081,1754,1066,1752);
ctx.bezierCurveTo(1049,1748,1048,1753,1054,1811);
ctx.bezierCurveTo(1058,1846,1066,1878,1072,1881);
ctx.bezierCurveTo(1078,1885,1080,1895,1077,1903);
ctx.bezierCurveTo(1074,1911,1077,1923,1083,1929);
ctx.bezierCurveTo(1098,1944,1101,1943,1115,1923);
ctx.closePath();
ctx.moveTo(1464,1921);
ctx.bezierCurveTo(1481,1915,1549,1904,1614,1896);
ctx.bezierCurveTo(1680,1887,1736,1878,1739,1874);
ctx.bezierCurveTo(1742,1871,1738,1865,1730,1860);
ctx.bezierCurveTo(1720,1854,1728,1850,1756,1848);
ctx.lineTo(1795,1845);
ctx.lineTo(1792,1786);
ctx.bezierCurveTo(1790,1748,1793,1724,1801,1720);
ctx.bezierCurveTo(1807,1716,1814,1696,1815,1676);
ctx.lineTo(1817,1639);
ctx.lineTo(1776,1644);
ctx.bezierCurveTo(1701,1654,1552,1667,1480,1671);
ctx.bezierCurveTo(1466,1671,1450,1676,1443,1682);
ctx.bezierCurveTo(1436,1687,1421,1689,1409,1685);
ctx.bezierCurveTo(1394,1680,1390,1681,1395,1689);
ctx.bezierCurveTo(1400,1697,1393,1700,1373,1698);
ctx.bezierCurveTo(1346,1695,1345,1696,1348,1740);
ctx.bezierCurveTo(1350,1765,1355,1788,1358,1791);
ctx.bezierCurveTo(1362,1794,1387,1790,1413,1783);
ctx.bezierCurveTo(1458,1769,1461,1767,1446,1751);
ctx.bezierCurveTo(1435,1739,1420,1735,1400,1738);
ctx.bezierCurveTo(1379,1741,1370,1738,1370,1728);
ctx.bezierCurveTo(1370,1719,1384,1714,1415,1712);
ctx.bezierCurveTo(1465,1710,1464,1708,1474,1838);
ctx.bezierCurveTo(1478,1901,1469,1915,1443,1889);
ctx.bezierCurveTo(1428,1874,1360,1886,1360,1904);
ctx.bezierCurveTo(1360,1911,1363,1920,1367,1923);
ctx.bezierCurveTo(1376,1933,1429,1932,1464,1921);
ctx.closePath();
ctx.moveTo(1438,1833);
ctx.bezierCurveTo(1441,1812,1437,1810,1401,1810);
ctx.bezierCurveTo(1364,1810,1360,1812,1360,1836);
ctx.bezierCurveTo(1360,1859,1363,1861,1398,1858);
ctx.bezierCurveTo(1428,1856,1436,1851,1438,1833);
ctx.closePath();
ctx.moveTo(1311,1794);
ctx.bezierCurveTo(1302,1756,1302,1756,1301,1787);
ctx.bezierCurveTo(1300,1820,1311,1861,1317,1844);
ctx.bezierCurveTo(1319,1838,1316,1816,1311,1794);
ctx.closePath();
ctx.moveTo(364,1823);
ctx.bezierCurveTo(391,1820,422,1814,434,1810);
ctx.bezierCurveTo(455,1801,455,1801,433,1801);
ctx.bezierCurveTo(419,1800,410,1794,410,1785);
ctx.bezierCurveTo(410,1777,406,1770,400,1770);
ctx.bezierCurveTo(395,1770,390,1780,390,1793);
ctx.bezierCurveTo(389,1814,389,1815,375,1796);
ctx.bezierCurveTo(362,1779,360,1778,360,1793);
ctx.bezierCurveTo(360,1813,344,1816,337,1798);
ctx.bezierCurveTo(333,1788,329,1789,321,1800);
ctx.bezierCurveTo(314,1810,310,1811,310,1803);
ctx.bezierCurveTo(310,1782,289,1788,263,1816);
ctx.lineTo(238,1843);
ctx.lineTo(277,1836);
ctx.bezierCurveTo(298,1832,337,1826,364,1823);
ctx.closePath();
ctx.moveTo(250,1790);
ctx.bezierCurveTo(250,1775,231,1768,210,1775);
ctx.bezierCurveTo(185,1783,184,1797,208,1802);
ctx.bezierCurveTo(229,1807,250,1801,250,1790);
ctx.closePath();
ctx.moveTo(490,1802);
ctx.bezierCurveTo(490,1797,483,1785,475,1774);
ctx.bezierCurveTo(461,1755,461,1755,460,1776);
ctx.bezierCurveTo(460,1787,463,1800,467,1803);
ctx.bezierCurveTo(476,1813,490,1812,490,1802);
ctx.closePath();
ctx.moveTo(440,1780);
ctx.bezierCurveTo(440,1775,436,1770,430,1770);
ctx.bezierCurveTo(425,1770,420,1775,420,1780);
ctx.bezierCurveTo(420,1786,425,1790,430,1790);
ctx.bezierCurveTo(436,1790,440,1786,440,1780);
ctx.closePath();
ctx.moveTo(638,1780);
ctx.bezierCurveTo(650,1780,660,1775,660,1769);
ctx.bezierCurveTo(660,1761,646,1759,620,1763);
ctx.bezierCurveTo(593,1766,580,1764,580,1757);
ctx.bezierCurveTo(580,1749,577,1749,572,1758);
ctx.bezierCurveTo(567,1765,556,1768,547,1764);
ctx.bezierCurveTo(538,1761,530,1762,530,1767);
ctx.bezierCurveTo(530,1786,546,1792,580,1786);
ctx.bezierCurveTo(599,1783,625,1780,638,1780);
ctx.closePath();
ctx.moveTo(460,1749);
ctx.bezierCurveTo(545,1737,625,1724,638,1719);
ctx.bezierCurveTo(665,1709,666,1682,650,1425);
ctx.bezierCurveTo(635,1185,629,1130,621,1130);
ctx.bezierCurveTo(614,1130,615,1181,626,1415);
ctx.lineTo(632,1536);
ctx.lineTo(594,1596);
ctx.bezierCurveTo(535,1689,482,1727,391,1745);
ctx.bezierCurveTo(370,1750,360,1749,364,1742);
ctx.bezierCurveTo(367,1737,390,1729,414,1726);
ctx.bezierCurveTo(490,1714,586,1603,606,1502);
ctx.bezierCurveTo(617,1448,593,1465,574,1525);
ctx.bezierCurveTo(564,1558,541,1599,517,1626);
ctx.bezierCurveTo(408,1749,279,1737,182,1594);
ctx.bezierCurveTo(171,1577,170,1580,176,1610);
ctx.bezierCurveTo(184,1655,213,1687,275,1717);
ctx.bezierCurveTo(311,1735,317,1740,295,1735);
ctx.bezierCurveTo(279,1732,248,1718,228,1704);
ctx.bezierCurveTo(181,1674,180,1674,180,1706);
ctx.bezierCurveTo(180,1726,184,1731,196,1726);
ctx.bezierCurveTo(223,1715,234,1732,209,1746);
ctx.bezierCurveTo(186,1759,186,1759,223,1760);
ctx.bezierCurveTo(243,1760,260,1765,260,1770);
ctx.bezierCurveTo(260,1776,270,1778,283,1775);
ctx.bezierCurveTo(295,1773,375,1761,460,1749);
ctx.closePath();
ctx.moveTo(737,1750);
ctx.bezierCurveTo(743,1728,745,1728,860,1710);
ctx.bezierCurveTo(994,1690,1040,1679,1037,1667);
ctx.bezierCurveTo(1036,1661,1043,1655,1052,1652);
ctx.bezierCurveTo(1066,1649,1068,1654,1063,1684);
ctx.bezierCurveTo(1059,1712,1061,1721,1074,1726);
ctx.bezierCurveTo(1100,1736,1140,1714,1140,1690);
ctx.bezierCurveTo(1140,1666,1148,1665,1172,1687);
ctx.bezierCurveTo(1189,1702,1190,1700,1190,1629);
ctx.bezierCurveTo(1190,1517,1169,1026,1164,1021);
ctx.bezierCurveTo(1160,1017,1096,1029,840,1083);
ctx.bezierCurveTo(777,1097,708,1111,688,1114);
ctx.bezierCurveTo(642,1122,635,1149,680,1142);
ctx.bezierCurveTo(705,1138,710,1141,710,1159);
ctx.bezierCurveTo(710,1176,704,1180,680,1180);
ctx.bezierCurveTo(652,1180,650,1183,650,1214);
ctx.bezierCurveTo(650,1233,654,1251,659,1254);
ctx.bezierCurveTo(667,1259,968,1205,1000,1192);
ctx.bezierCurveTo(1008,1189,1023,1186,1032,1185);
ctx.bezierCurveTo(1071,1180,1129,1170,1144,1164);
ctx.bezierCurveTo(1155,1160,1160,1163,1160,1174);
ctx.bezierCurveTo(1160,1194,1123,1209,1057,1215);
ctx.bezierCurveTo(1029,1218,1003,1225,999,1231);
ctx.bezierCurveTo(995,1238,987,1239,981,1236);
ctx.bezierCurveTo(975,1232,966,1231,960,1235);
ctx.bezierCurveTo(947,1243,959,1270,976,1270);
ctx.bezierCurveTo(994,1270,994,1286,975,1294);
ctx.bezierCurveTo(960,1299,930,1266,930,1243);
ctx.bezierCurveTo(930,1225,893,1227,765,1254);
ctx.bezierCurveTo(698,1268,655,1281,656,1288);
ctx.bezierCurveTo(657,1295,658,1318,659,1340);
ctx.bezierCurveTo(660,1368,664,1380,675,1380);
ctx.bezierCurveTo(683,1380,690,1371,690,1360);
ctx.bezierCurveTo(690,1337,686,1338,800,1316);
ctx.bezierCurveTo(903,1297,900,1297,900,1314);
ctx.bezierCurveTo(900,1324,881,1332,843,1339);
ctx.bezierCurveTo(739,1359,735,1361,732,1404);
ctx.lineTo(729,1443);
ctx.lineTo(794,1436);
ctx.bezierCurveTo(894,1426,910,1417,910,1375);
ctx.bezierCurveTo(910,1356,911,1340,913,1340);
ctx.bezierCurveTo(914,1339,969,1329,1035,1316);
ctx.bezierCurveTo(1101,1303,1158,1295,1163,1297);
ctx.bezierCurveTo(1167,1299,1170,1319,1170,1340);
ctx.bezierCurveTo(1170,1368,1165,1380,1153,1384);
ctx.bezierCurveTo(1136,1389,774,1455,703,1466);
ctx.lineTo(670,1471);
ctx.lineTo(670,1565);
ctx.bezierCurveTo(670,1628,674,1660,681,1660);
ctx.bezierCurveTo(687,1660,690,1651,687,1640);
ctx.bezierCurveTo(684,1629,686,1617,691,1614);
ctx.bezierCurveTo(696,1611,700,1613,700,1619);
ctx.bezierCurveTo(700,1624,703,1635,706,1643);
ctx.bezierCurveTo(709,1651,705,1664,697,1671);
ctx.bezierCurveTo(690,1679,681,1704,678,1728);
ctx.bezierCurveTo(672,1769,672,1770,702,1770);
ctx.bezierCurveTo(724,1770,733,1764,737,1750);
ctx.closePath();
ctx.moveTo(827,1744);
ctx.bezierCurveTo(824,1741,815,1740,808,1743);
ctx.bezierCurveTo(800,1746,803,1749,814,1749);
ctx.bezierCurveTo(825,1750,831,1747,827,1744);
ctx.closePath();
ctx.moveTo(959,1734);
ctx.bezierCurveTo(976,1730,990,1723,990,1718);
ctx.bezierCurveTo(990,1707,930,1717,916,1731);
ctx.bezierCurveTo(904,1742,915,1742,959,1734);
ctx.closePath();
ctx.moveTo(1310,1660);
ctx.bezierCurveTo(1310,1655,1299,1650,1285,1650);
ctx.bezierCurveTo(1271,1650,1260,1655,1260,1660);
ctx.bezierCurveTo(1260,1666,1271,1670,1285,1670);
ctx.bezierCurveTo(1299,1670,1310,1666,1310,1660);
ctx.closePath();
ctx.moveTo(1360,1640);
ctx.bezierCurveTo(1372,1632,1371,1630,1353,1630);
ctx.bezierCurveTo(1340,1630,1330,1635,1330,1640);
ctx.bezierCurveTo(1330,1653,1341,1653,1360,1640);
ctx.closePath();
ctx.moveTo(1301,1621);
ctx.bezierCurveTo(1331,1616,1422,1601,1504,1588);
ctx.bezierCurveTo(1610,1572,1658,1560,1674,1547);
ctx.bezierCurveTo(1691,1532,1705,1529,1748,1533);
ctx.bezierCurveTo(1784,1537,1800,1535,1801,1527);
ctx.bezierCurveTo(1805,1482,1797,1342,1789,1330);
ctx.bezierCurveTo(1779,1312,1778,1321,1780,1426);
ctx.bezierCurveTo(1781,1506,1778,1510,1697,1510);
ctx.bezierCurveTo(1675,1510,1646,1518,1632,1528);
ctx.bezierCurveTo(1593,1556,1478,1584,1431,1577);
ctx.bezierCurveTo(1358,1568,1285,1526,1244,1471);
ctx.bezierCurveTo(1223,1443,1204,1422,1202,1424);
ctx.bezierCurveTo(1200,1427,1201,1474,1205,1529);
ctx.bezierCurveTo(1213,1642,1208,1637,1301,1621);
ctx.closePath();
ctx.moveTo(1760,1575);
ctx.bezierCurveTo(1785,1545,1742,1528,1699,1551);
ctx.bezierCurveTo(1683,1559,1681,1564,1691,1576);
ctx.bezierCurveTo(1706,1594,1744,1594,1760,1575);
ctx.closePath();
ctx.moveTo(469,1556);
ctx.bezierCurveTo(538,1520,533,1400,461,1371);
ctx.bezierCurveTo(352,1325,261,1462,345,1546);
ctx.bezierCurveTo(373,1574,425,1578,469,1556);
ctx.closePath();
ctx.moveTo(1564,1539);
ctx.bezierCurveTo(1638,1512,1707,1436,1749,1336);
ctx.bezierCurveTo(1786,1248,1787,1216,1759,1129);
ctx.bezierCurveTo(1734,1054,1703,1010,1647,969);
ctx.bezierCurveTo(1612,943,1599,940,1535,940);
ctx.bezierCurveTo(1449,940,1400,956,1332,1005);
ctx.bezierCurveTo(1268,1050,1199,1156,1192,1218);
ctx.bezierCurveTo(1188,1257,1189,1262,1206,1258);
ctx.bezierCurveTo(1218,1256,1227,1242,1232,1217);
ctx.bezierCurveTo(1260,1083,1363,981,1486,965);
ctx.bezierCurveTo(1589,951,1677,1003,1720,1102);
ctx.bezierCurveTo(1739,1145,1742,1167,1738,1231);
ctx.bezierCurveTo(1727,1423,1587,1556,1423,1530);
ctx.bezierCurveTo(1346,1517,1250,1448,1250,1404);
ctx.bezierCurveTo(1250,1391,1212,1374,1203,1384);
ctx.bezierCurveTo(1197,1389,1249,1460,1282,1493);
ctx.bezierCurveTo(1293,1503,1320,1523,1343,1536);
ctx.bezierCurveTo(1398,1567,1486,1569,1564,1539);
ctx.closePath();
ctx.moveTo(1544,1379);
ctx.bezierCurveTo(1557,1373,1578,1349,1590,1326);
ctx.bezierCurveTo(1619,1272,1608,1225,1560,1193);
ctx.bezierCurveTo(1480,1138,1390,1187,1390,1286);
ctx.bezierCurveTo(1390,1314,1398,1330,1424,1356);
ctx.bezierCurveTo(1461,1393,1498,1400,1544,1379);
ctx.closePath();
ctx.moveTo(190,1340);
ctx.bezierCurveTo(206,1302,290,1223,335,1204);
ctx.bezierCurveTo(423,1168,517,1205,569,1298);
ctx.bezierCurveTo(574,1307,582,1312,586,1308);
ctx.bezierCurveTo(598,1295,542,1222,498,1193);
ctx.bezierCurveTo(426,1145,306,1163,244,1232);
ctx.bezierCurveTo(218,1259,160,1350,160,1362);
ctx.bezierCurveTo(160,1381,179,1368,190,1340);
ctx.closePath();
ctx.moveTo(221,1238);
ctx.bezierCurveTo(234,1215,213,1214,182,1236);
ctx.bezierCurveTo(167,1246,160,1261,160,1283);
ctx.lineTo(161,1315);
ctx.lineTo(186,1285);
ctx.bezierCurveTo(200,1269,215,1247,221,1238);
ctx.closePath();
ctx.moveTo(562,1200);
ctx.bezierCurveTo(545,1170,514,1152,502,1165);
ctx.bezierCurveTo(495,1171,558,1229,572,1230);
ctx.bezierCurveTo(576,1230,571,1216,562,1200);
ctx.closePath();
ctx.moveTo(1786,1018);
ctx.bezierCurveTo(1783,962,1775,911,1770,906);
ctx.bezierCurveTo(1764,900,1760,900,1759,905);
ctx.bezierCurveTo(1759,911,1757,931,1755,950);
ctx.bezierCurveTo(1751,996,1772,1120,1784,1120);
ctx.bezierCurveTo(1789,1120,1790,1079,1786,1018);
ctx.closePath();
ctx.moveTo(686,978);
ctx.bezierCurveTo(696,971,694,930,685,930);
ctx.bezierCurveTo(668,930,500,973,500,978);
ctx.bezierCurveTo(500,981,507,991,515,1000);
ctx.bezierCurveTo(530,1016,536,1016,603,1002);
ctx.bezierCurveTo(643,994,680,983,686,978);
ctx.closePath();
ctx.moveTo(829,951);
ctx.bezierCurveTo(925,928,930,926,923,900);
ctx.bezierCurveTo(916,876,924,875,813,901);
ctx.bezierCurveTo(728,921,720,924,720,946);
ctx.bezierCurveTo(720,975,726,975,829,951);
ctx.closePath();
ctx.moveTo(577,923);
ctx.bezierCurveTo(589,918,591,906,587,873);
ctx.bezierCurveTo(585,849,581,827,578,825);
ctx.bezierCurveTo(573,820,431,856,423,864);
ctx.bezierCurveTo(420,867,430,886,445,906);
ctx.bezierCurveTo(471,940,474,942,518,935);
ctx.bezierCurveTo(542,931,569,926,577,923);
ctx.closePath();
ctx.moveTo(1060,899);
ctx.bezierCurveTo(1150,878,1175,861,1152,838);
ctx.bezierCurveTo(1145,831,1118,833,1063,845);
ctx.bezierCurveTo(949,869,950,869,950,896);
ctx.bezierCurveTo(950,925,947,925,1060,899);
ctx.closePath();
ctx.moveTo(712,893);
ctx.lineTo(790,877);
ctx.lineTo(790,833);
ctx.bezierCurveTo(790,804,785,787,775,784);
ctx.bezierCurveTo(767,781,727,786,685,796);
ctx.lineTo(610,814);
ctx.lineTo(610,862);
ctx.bezierCurveTo(610,917,606,916,712,893);
ctx.closePath();
ctx.moveTo(938,844);
ctx.lineTo(1020,827);
ctx.lineTo(1020,779);
ctx.bezierCurveTo(1020,753,1017,729,1013,727);
ctx.bezierCurveTo(1008,724,965,732,915,744);
ctx.lineTo(825,765);
ctx.lineTo(822,819);
ctx.bezierCurveTo(819,866,821,871,837,866);
ctx.bezierCurveTo(847,864,892,853,938,844);
ctx.closePath();
ctx.moveTo(1290,847);
ctx.bezierCurveTo(1372,828,1385,822,1388,802);
ctx.bezierCurveTo(1392,776,1373,774,1300,791);
ctx.bezierCurveTo(1187,816,1180,820,1180,845);
ctx.bezierCurveTo(1180,875,1172,875,1290,847);
ctx.closePath();
ctx.moveTo(428,824);
ctx.bezierCurveTo(447,818,450,811,450,769);
ctx.bezierCurveTo(450,742,447,720,444,720);
ctx.bezierCurveTo(429,720,344,744,337,750);
ctx.bezierCurveTo(329,757,385,830,399,830);
ctx.bezierCurveTo(402,830,415,827,428,824);
ctx.closePath();
ctx.moveTo(1248,775);
ctx.bezierCurveTo(1267,770,1270,763,1270,720);
ctx.bezierCurveTo(1270,672,1269,670,1243,671);
ctx.bezierCurveTo(1227,671,1177,682,1130,693);
ctx.lineTo(1045,715);
ctx.lineTo(1042,754);
ctx.bezierCurveTo(1036,825,1028,825,1248,775);
ctx.closePath();
ctx.moveTo(1622,749);
ctx.bezierCurveTo(1620,736,1617,724,1617,724);
ctx.bezierCurveTo(1616,723,1572,732,1520,744);
ctx.bezierCurveTo(1432,763,1425,767,1422,791);
ctx.lineTo(1419,816);
ctx.lineTo(1522,795);
ctx.bezierCurveTo(1621,774,1625,772,1622,749);
ctx.closePath();
ctx.moveTo(580,790);
ctx.bezierCurveTo(631,778,677,767,682,764);
ctx.bezierCurveTo(697,755,691,680,675,674);
ctx.bezierCurveTo(667,670,619,678,570,690);
ctx.lineTo(480,712);
ctx.lineTo(480,761);
ctx.bezierCurveTo(480,788,481,810,483,810);
ctx.bezierCurveTo(485,810,528,801,580,790);
ctx.closePath();
ctx.moveTo(1758,717);
ctx.bezierCurveTo(1761,692,1760,691,1728,697);
ctx.bezierCurveTo(1671,708,1650,719,1650,738);
ctx.bezierCurveTo(1650,766,1657,769,1708,756);
ctx.bezierCurveTo(1748,746,1755,740,1758,717);
ctx.closePath();
ctx.moveTo(900,715);
ctx.bezierCurveTo(906,711,902,621,896,613);
ctx.bezierCurveTo(892,608,724,653,716,660);
ctx.bezierCurveTo(711,665,711,689,714,713);
ctx.lineTo(721,758);
ctx.lineTo(807,738);
ctx.bezierCurveTo(854,728,896,717,900,715);
ctx.closePath();
ctx.moveTo(1445,732);
ctx.lineTo(1515,715);
ctx.lineTo(1514,668);
ctx.bezierCurveTo(1514,642,1511,618,1508,614);
ctx.bezierCurveTo(1504,611,1455,619,1398,632);
ctx.bezierCurveTo(1299,654,1295,656,1292,684);
ctx.bezierCurveTo(1290,700,1291,723,1295,737);
ctx.bezierCurveTo(1302,765,1311,764,1445,732);
ctx.closePath();
ctx.moveTo(350,658);
ctx.bezierCurveTo(350,619,347,609,336,613);
ctx.bezierCurveTo(328,616,305,622,286,626);
ctx.bezierCurveTo(244,633,243,638,272,676);
ctx.bezierCurveTo(301,714,309,719,331,713);
ctx.bezierCurveTo(346,709,350,698,350,658);
ctx.closePath();
ctx.moveTo(1025,688);
ctx.bezierCurveTo(1149,658,1140,665,1140,610);
ctx.bezierCurveTo(1140,577,1136,560,1128,560);
ctx.bezierCurveTo(1121,560,1073,570,1023,582);
ctx.lineTo(930,604);
ctx.lineTo(930,657);
ctx.bezierCurveTo(930,717,920,714,1025,688);
ctx.closePath();
ctx.moveTo(1698,671);
ctx.bezierCurveTo(1710,664,1713,650,1711,613);
ctx.bezierCurveTo(1710,587,1707,564,1706,563);
ctx.bezierCurveTo(1704,561,1632,576,1578,591);
ctx.bezierCurveTo(1541,601,1540,602,1540,649);
ctx.bezierCurveTo(1540,675,1542,699,1545,702);
ctx.bezierCurveTo(1552,709,1676,683,1698,671);
ctx.closePath();
ctx.moveTo(449,686);
ctx.bezierCurveTo(480,678,517,669,533,666);
ctx.bezierCurveTo(557,660,560,655,560,615);
ctx.bezierCurveTo(560,591,556,569,552,566);
ctx.bezierCurveTo(548,564,507,571,462,582);
ctx.lineTo(380,602);
ctx.lineTo(380,651);
ctx.bezierCurveTo(380,678,383,700,386,700);
ctx.bezierCurveTo(389,700,418,694,449,686);
ctx.closePath();
ctx.moveTo(1763,653);
ctx.bezierCurveTo(1766,648,1771,624,1774,598);
ctx.bezierCurveTo(1781,554,1780,550,1761,550);
ctx.bezierCurveTo(1742,550,1740,556,1740,605);
ctx.bezierCurveTo(1740,653,1750,675,1763,653);
ctx.closePath();
ctx.moveTo(685,629);
ctx.lineTo(770,608);
ctx.lineTo(770,565);
ctx.bezierCurveTo(770,513,767,510,727,520);
ctx.bezierCurveTo(709,525,669,534,638,540);
ctx.lineTo(580,551);
ctx.lineTo(580,601);
ctx.bezierCurveTo(580,628,585,650,590,650);
ctx.bezierCurveTo(596,650,639,640,685,629);
ctx.closePath();
ctx.moveTo(1285,626);
ctx.lineTo(1375,603);
ctx.lineTo(1372,554);
ctx.bezierCurveTo(1370,527,1367,504,1366,503);
ctx.bezierCurveTo(1365,502,1331,509,1290,519);
ctx.bezierCurveTo(1249,530,1203,541,1188,544);
ctx.bezierCurveTo(1159,551,1152,576,1166,628);
ctx.bezierCurveTo(1174,655,1174,655,1285,626);
ctx.closePath();
ctx.moveTo(345,582);
ctx.lineTo(415,564);
ctx.lineTo(418,517);
ctx.bezierCurveTo(422,463,434,465,305,499);
ctx.lineTo(245,515);
ctx.lineTo(242,558);
ctx.bezierCurveTo(238,608,241,608,345,582);
ctx.closePath();
ctx.moveTo(918,574);
ctx.lineTo(990,558);
ctx.lineTo(990,509);
ctx.bezierCurveTo(990,482,985,460,980,460);
ctx.bezierCurveTo(974,460,931,470,885,481);
ctx.lineTo(800,502);
ctx.lineTo(800,552);
ctx.bezierCurveTo(800,599,801,602,823,596);
ctx.bezierCurveTo(835,593,878,583,918,574);
ctx.closePath();
ctx.moveTo(1598,501);
ctx.lineTo(1601,449);
ctx.lineTo(1563,456);
ctx.bezierCurveTo(1542,460,1498,470,1465,479);
ctx.bezierCurveTo(1406,495,1405,496,1402,534);
ctx.bezierCurveTo(1396,599,1398,600,1502,575);
ctx.lineTo(1595,553);
ctx.lineTo(1598,501);
ctx.closePath();
ctx.moveTo(216,535);
ctx.bezierCurveTo(213,527,203,524,191,527);
ctx.bezierCurveTo(165,534,165,538,193,568);
ctx.lineTo(215,592);
ctx.lineTo(218,570);
ctx.bezierCurveTo(220,558,219,542,216,535);
ctx.closePath();
ctx.moveTo(551,534);
ctx.lineTo(620,518);
ctx.lineTo(620,476);
ctx.bezierCurveTo(620,452,618,431,614,428);
ctx.bezierCurveTo(608,421,458,458,447,469);
ctx.bezierCurveTo(434,482,450,550,467,550);
ctx.bezierCurveTo(475,550,512,543,551,534);
ctx.closePath();
ctx.moveTo(1153,520);
ctx.lineTo(1250,498);
ctx.lineTo(1250,449);
ctx.bezierCurveTo(1250,418,1246,400,1238,400);
ctx.bezierCurveTo(1232,400,1178,412,1118,426);
ctx.lineTo(1010,452);
ctx.lineTo(1010,485);
ctx.bezierCurveTo(1010,531,1019,551,1039,546);
ctx.bezierCurveTo(1048,544,1099,532,1153,520);
ctx.closePath();
ctx.moveTo(1751,520);
ctx.bezierCurveTo(1789,510,1800,487,1800,424);
ctx.bezierCurveTo(1800,397,1807,397,1685,429);
ctx.bezierCurveTo(1628,444,1625,447,1622,479);
ctx.bezierCurveTo(1615,546,1633,551,1751,520);
ctx.closePath();
ctx.moveTo(860,414);
ctx.bezierCurveTo(860,385,856,370,848,370);
ctx.bezierCurveTo(841,370,793,379,743,391);
ctx.lineTo(650,412);
ctx.lineTo(650,455);
ctx.bezierCurveTo(650,478,652,499,655,502);
ctx.bezierCurveTo(658,505,706,496,760,482);
ctx.lineTo(860,458);
ctx.lineTo(860,414);
ctx.closePath();
ctx.moveTo(1410,460);
ctx.lineTo(1475,444);
ctx.lineTo(1478,392);
ctx.bezierCurveTo(1480,363,1478,340,1474,340);
ctx.bezierCurveTo(1471,340,1440,347,1406,356);
ctx.bezierCurveTo(1262,392,1270,389,1270,418);
ctx.bezierCurveTo(1270,433,1273,455,1276,467);
ctx.bezierCurveTo(1283,492,1286,491,1410,460);
ctx.closePath();
ctx.moveTo(964,434);
ctx.bezierCurveTo(1115,396,1100,405,1100,354);
ctx.lineTo(1100,308);
ctx.lineTo(1063,315);
ctx.bezierCurveTo(1042,318,994,329,955,339);
ctx.lineTo(885,356);
ctx.lineTo(882,403);
ctx.bezierCurveTo(878,457,877,456,964,434);
ctx.closePath();
ctx.moveTo(1623,409);
ctx.lineTo(1710,388);
ctx.lineTo(1710,339);
ctx.bezierCurveTo(1710,284,1708,283,1630,301);
ctx.bezierCurveTo(1504,329,1510,325,1510,380);
ctx.bezierCurveTo(1510,413,1514,430,1523,430);
ctx.bezierCurveTo(1529,430,1574,420,1623,409);
ctx.closePath();
ctx.moveTo(1210,374);
ctx.bezierCurveTo(1359,340,1350,345,1350,295);
ctx.bezierCurveTo(1350,265,1346,250,1338,250);
ctx.bezierCurveTo(1331,251,1282,261,1230,274);
ctx.lineTo(1135,297);
ctx.lineTo(1132,344);
ctx.bezierCurveTo(1130,369,1133,390,1137,390);
ctx.bezierCurveTo(1141,390,1174,383,1210,374);
ctx.closePath();
ctx.moveTo(1778,369);
ctx.bezierCurveTo(1809,358,1820,337,1820,287);
ctx.bezierCurveTo(1820,265,1816,260,1803,263);
ctx.bezierCurveTo(1793,266,1773,271,1758,274);
ctx.bezierCurveTo(1733,280,1730,285,1730,324);
ctx.bezierCurveTo(1730,359,1736,380,1745,380);
ctx.bezierCurveTo(1746,380,1761,375,1778,369);
ctx.closePath();
ctx.moveTo(1518,299);
ctx.lineTo(1610,278);
ctx.lineTo(1610,230);
ctx.lineTo(1610,182);
ctx.lineTo(1493,212);
ctx.bezierCurveTo(1428,228,1374,243,1372,244);
ctx.bezierCurveTo(1371,246,1372,266,1376,289);
ctx.bezierCurveTo(1382,326,1386,331,1404,326);
ctx.bezierCurveTo(1416,323,1467,311,1518,299);
ctx.closePath();
ctx.moveTo(1745,244);
ctx.bezierCurveTo(1784,235,1821,220,1828,212);
ctx.bezierCurveTo(1841,195,1845,130,1833,130);
ctx.bezierCurveTo(1828,131,1785,141,1735,153);
ctx.lineTo(1645,175);
ctx.lineTo(1642,223);
ctx.bezierCurveTo(1639,266,1641,271,1657,266);
ctx.bezierCurveTo(1667,263,1707,253,1745,244);
ctx.closePath();
ctx.fill();
ctx.stroke();
ctx.restore();
ctx.save();
ctx.beginPath();
ctx.moveTo(1513,1883);
ctx.bezierCurveTo(1522,1881,1538,1881,1548,1883);
ctx.bezierCurveTo(1557,1886,1549,1888,1530,1888);
ctx.bezierCurveTo(1511,1888,1503,1886,1513,1883);
ctx.closePath();
ctx.fill();
ctx.stroke();
ctx.restore();
ctx.save();
ctx.beginPath();
ctx.moveTo(1663,1863);
ctx.bezierCurveTo(1672,1861,1686,1861,1693,1863);
ctx.bezierCurveTo(1699,1866,1692,1868,1675,1868);
ctx.bezierCurveTo(1659,1868,1653,1866,1663,1863);
ctx.closePath();
ctx.fill();
ctx.stroke();
ctx.restore();
ctx.save();
ctx.beginPath();
ctx.moveTo(1518,1788);
ctx.bezierCurveTo(1516,1748,1516,1713,1517,1711);
ctx.bezierCurveTo(1520,1707,1734,1671,1738,1675);
ctx.bezierCurveTo(1739,1676,1743,1713,1747,1756);
ctx.lineTo(1753,1835);
ctx.lineTo(1659,1848);
ctx.bezierCurveTo(1512,1867,1522,1872,1518,1788);
ctx.closePath();
ctx.fill();
ctx.stroke();
ctx.restore();
ctx.save();
ctx.beginPath();
ctx.moveTo(777,1654);
ctx.bezierCurveTo(768,1644,781,1620,796,1620);
ctx.bezierCurveTo(804,1620,810,1624,810,1629);
ctx.bezierCurveTo(810,1641,784,1661,777,1654);
ctx.closePath();
ctx.fill();
ctx.stroke();
ctx.restore();
ctx.save();
ctx.beginPath();
ctx.moveTo(862,1621);
ctx.bezierCurveTo(876,1598,895,1598,895,1621);
ctx.bezierCurveTo(895,1629,885,1636,872,1638);
ctx.bezierCurveTo(851,1641,850,1640,862,1621);
ctx.closePath();
ctx.fill();
ctx.stroke();
ctx.restore();
ctx.save();
ctx.beginPath();
ctx.moveTo(952,1605);
ctx.bezierCurveTo(964,1578,1000,1570,1000,1595);
ctx.bezierCurveTo(1000,1609,971,1630,951,1630);
ctx.bezierCurveTo(944,1630,944,1622,952,1605);
ctx.closePath();
ctx.fill();
ctx.stroke();
ctx.restore();
ctx.save();
ctx.beginPath();
ctx.moveTo(1040,1621);
ctx.bezierCurveTo(1040,1615,1045,1608,1050,1605);
ctx.bezierCurveTo(1056,1602,1060,1590,1060,1579);
ctx.bezierCurveTo(1060,1567,1065,1560,1073,1562);
ctx.bezierCurveTo(1093,1569,1094,1603,1074,1617);
ctx.bezierCurveTo(1053,1632,1040,1634,1040,1621);
ctx.closePath();
ctx.fill();
ctx.stroke();
ctx.restore();
ctx.save();
ctx.beginPath();
ctx.moveTo(1124,1594);
ctx.bezierCurveTo(1127,1585,1130,1569,1130,1557);
ctx.bezierCurveTo(1130,1537,1130,1537,1144,1555);
ctx.bezierCurveTo(1154,1569,1155,1580,1149,1592);
ctx.bezierCurveTo(1137,1614,1116,1616,1124,1594);
ctx.closePath();
ctx.fill();
ctx.stroke();
ctx.restore();
ctx.save();
ctx.beginPath();
ctx.moveTo(680,1539);
ctx.bezierCurveTo(680,1522,684,1511,690,1515);
ctx.bezierCurveTo(696,1518,700,1532,700,1546);
ctx.bezierCurveTo(700,1559,696,1570,690,1570);
ctx.bezierCurveTo(685,1570,680,1556,680,1539);
ctx.closePath();
ctx.fill();
ctx.stroke();
ctx.restore();
ctx.save();
ctx.beginPath();
ctx.moveTo(732,1530);
ctx.bezierCurveTo(733,1514,737,1503,742,1506);
ctx.bezierCurveTo(753,1513,752,1560,741,1560);
ctx.bezierCurveTo(736,1560,732,1547,732,1530);
ctx.closePath();
ctx.fill();
ctx.stroke();
ctx.restore();
ctx.save();
ctx.beginPath();
ctx.moveTo(784,1523);
ctx.bezierCurveTo(788,1489,804,1490,808,1525);
ctx.bezierCurveTo(810,1542,807,1550,796,1550);
ctx.bezierCurveTo(786,1550,782,1542,784,1523);
ctx.closePath();
ctx.fill();
ctx.stroke();
ctx.restore();
ctx.save();
ctx.beginPath();
ctx.moveTo(850,1530);
ctx.bezierCurveTo(850,1525,860,1510,872,1498);
ctx.bezierCurveTo(892,1478,894,1478,906,1495);
ctx.bezierCurveTo(916,1509,917,1517,909,1527);
ctx.bezierCurveTo(896,1542,850,1545,850,1530);
ctx.closePath();
ctx.fill();
ctx.stroke();
ctx.restore();
ctx.save();
ctx.beginPath();
ctx.moveTo(942,1500);
ctx.bezierCurveTo(949,1489,963,1480,972,1480);
ctx.bezierCurveTo(983,1480,990,1488,990,1500);
ctx.bezierCurveTo(990,1516,983,1520,960,1520);
ctx.bezierCurveTo(932,1520,931,1518,942,1500);
ctx.closePath();
ctx.fill();
ctx.stroke();
ctx.restore();
ctx.save();
ctx.beginPath();
ctx.moveTo(1020,1504);
ctx.bezierCurveTo(1020,1495,1048,1470,1059,1470);
ctx.bezierCurveTo(1076,1470,1083,1492,1069,1501);
ctx.bezierCurveTo(1053,1511,1020,1513,1020,1504);
ctx.closePath();
ctx.fill();
ctx.stroke();
ctx.restore();
ctx.save();
ctx.beginPath();
ctx.moveTo(1126,1484);
ctx.bezierCurveTo(1117,1460,1119,1430,1130,1430);
ctx.bezierCurveTo(1136,1430,1140,1439,1140,1449);
ctx.bezierCurveTo(1140,1460,1143,1475,1146,1484);
ctx.bezierCurveTo(1149,1493,1148,1500,1142,1500);
ctx.bezierCurveTo(1137,1500,1129,1493,1126,1484);
ctx.closePath();
ctx.fill();
ctx.stroke();
ctx.restore();
ctx.save();
ctx.beginPath();
ctx.moveTo(756,1402);
ctx.bezierCurveTo(747,1387,770,1373,825,1362);
ctx.bezierCurveTo(875,1351,890,1353,890,1370);
ctx.bezierCurveTo(890,1393,768,1422,756,1402);
ctx.closePath();
ctx.fill();
ctx.stroke();
ctx.restore();
ctx.save();
ctx.beginPath();
ctx.moveTo(713,1284);
ctx.bezierCurveTo(717,1280,741,1274,767,1269);
ctx.bezierCurveTo(794,1265,830,1258,848,1254);
ctx.bezierCurveTo(865,1251,880,1252,880,1256);
ctx.bezierCurveTo(880,1261,851,1271,815,1278);
ctx.bezierCurveTo(744,1291,703,1294,713,1284);
ctx.closePath();
ctx.fill();
ctx.stroke();
ctx.restore();
ctx.save();
ctx.beginPath();
ctx.moveTo(975,1160);
ctx.bezierCurveTo(978,1155,990,1150,1001,1150);
ctx.bezierCurveTo(1012,1150,1018,1155,1015,1160);
ctx.bezierCurveTo(1012,1166,1000,1170,989,1170);
ctx.bezierCurveTo(978,1170,972,1166,975,1160);
ctx.closePath();
ctx.fill();
ctx.stroke();
ctx.restore();
ctx.save();
ctx.beginPath();
ctx.moveTo(750,1145);
ctx.bezierCurveTo(750,1127,798,1114,812,1128);
ctx.bezierCurveTo(828,1144,812,1160,779,1160);
ctx.bezierCurveTo(760,1160,750,1155,750,1145);
ctx.closePath();
ctx.fill();
ctx.stroke();
ctx.restore();
ctx.save();
ctx.beginPath();
ctx.moveTo(1086,1091);
ctx.bezierCurveTo(1076,1075,1091,1050,1110,1050);
ctx.bezierCurveTo(1129,1050,1140,1067,1133,1088);
ctx.bezierCurveTo(1128,1102,1094,1104,1086,1091);
ctx.closePath();
ctx.fill();
ctx.stroke();
ctx.restore();
ctx.restore();
ctx.restore();
};


var favc = document.createElement('canvas');
favc.width = 16;
favc.height = 16;
var fctx = favc.getContext('2d');
fctx.fillStyle = "#000";
fctx.fillRect(0, 0, 16, 16);

fctx.fillStyle = "rgba(255,255,255,1.0)";
fctx.beginPath();
fctx.arc(8, 8, 8, 0, 2 * Math.PI, false);
fctx.closePath();
fctx.fill();
fctx.translate(2,2);
fctx.scale(0.038,0.038);
draw(fctx);

var link = document.createElement('link');
link.type = 'image/x-icon';
link.rel = 'shortcut icon';
link.href = favc.toDataURL("image/x-icon");
document.getElementsByTagName('head')[0].appendChild(link);

