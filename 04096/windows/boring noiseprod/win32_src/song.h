Song song={
	// row_duration (in seconds)
	0.24f, 
	// Playlist
	{0,1,0,1,4,5,6,7,8,9,10,11},

	// Chans
	{
		{{0x23,0x33,0xA3,0xA3, 0x21,0x31,0x23,0x53,
		 0x21,0x31,0x23,0x53, 
		}},
		{{0xB2,0xA2,0x92,0x72, 0xB2,0xA2,0xB2,0x72,
		 0xB2,0xA2,0xB2,0x72, 
		}},
		{{0x72,0x52,0x52,0x42, 0x72,0x52,0x72,0x42,
		 0x72,0x52,0x72,0x42, 
		}},
		{{0x42,0x22,0x42,0x02, 0x42,0x22,0x42,0x02,
		 0x42,0x22,0x42,0x02, 
		}},
		{{0x00,0x00,0x00,0x00, 0x04,0x05,0x08,0x00,
		 0x06,0x07,0x08,0x00,
		}},
	},
	// Tracks
	{
		{ {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, 0}, // Track 0
		{ {21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21},2}, // Track 1
		{ {171,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, 3}, // Track 2
		{ {21,149,0,21,149,0,21,149,0,21,149,0,21,149,0,21},2}, // Track 3
		{ {59,0,0,0,54,0,0,0,50,0,0,0,47,0,0,0}, 4}, // Track 4
		{ {48,0,0,0,52,0,0,0,55,0,0,0,60,0,0,0}, 4}, // Track 5
		{ {59,64+54,128+59,192+54,
		   50,64+54,128+50,192+47,
		   50,64+47,128+50,192+47,
		   42,64+47,128+42,192+47}, 1}, // Track 6
		{ {48,43,48,43,52,48,52,48,55,52,55,52,60,55,52,60}, 1}, // Track 7
		{ {59,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, 4}, // Track 8
		
	}, 
	// Instruments
	{
		// Ins 0 (hihat)
		{
			1, 5, 15, 50, // ADSR en centesimas de segundo
			0, // sus. time igual que el ADSR
			12000.0f, // cutoff
			1.1f, // res
			1.5f,  // lfo_freq
			8000.0f, // lfo_amp
			1.0f,0.5f, // detune
			0.1f,0.05f, // vols
			0.5f//noise
		}, 
		// Ins 1 (organ?)
		{
			1, 15, 40, 50, // ADSR
			0, // sus. time
			4000.0f, // cutoff
			1.0f, // res
			1.0f,  // lfo_freq
			200.0f, // lfo_amp
			1.001f,0.999f, // detune
			0.8f,0.5f, // vols
			0.1f //noise
		}, 
		// Ins 2 (bajo)
		{
			1, 15, 40, 5, // ADSR
			0, // sus. time
			800.0f, // cutoff
			1.0f, // res
			-0.5f,  // lfo_freq
			-600.0f, // lfo_amp
			1.0f,1.0f, // detune
			0.4f,0.7f, // vols
			0.0f //noise
		}, 
		// Ins 3 (pad)
		{
			50, 50, 65, 140, // ADSR
			140, // sus. time
			-1150.0f, // cutoff
			1.0f, // res
			-0.333f,  // lfo_freq
			-950.0f, // lfo_amp
			0.501f,1.0f, // detune
			0.5f,0.7f, // vols
			0.0f //noise
		}, 
		
		// Ins 4 (lead)
		{
			0, 10, 50, 160, // ADSR
			80, // sus. time
			900.0f, // cutoff
			1.0f, // res
			21.5f,  // lfo_freq
			300.0f, // lfo_amp
			0.5f,1.0f, // detune
			0.8f,0.4f, // vols
			0.0f //noise
		}, 
		

	},
};
