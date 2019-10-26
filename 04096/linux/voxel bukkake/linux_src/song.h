/*
   Voxel Bukkake - A 4k intro for BCNparty'101.
   Copyright (C) 2005 Jorge Gorbe (aka slack/Necrostudios)

   This program is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License version 2
   as published by the Free Software Foundation.
*/

Song song={
	// row_duration (in seconds)
	0.12, 
	// Playlist
	{8,9,10,11,16,17,18,19,4,5,6,7,0,1,2,3,8,9,10,11,8,9,18,19,4,5,6,7,20,255},
	// Rhythms
	{
		{{0x0809,0x0809,0x0809,0x0809, 0x0809,0x0809,0x0809,0x0809,
		 0x0849,0x0809,0x0809,0x084B, 0x0809,0x0809,0x0809,0x0809,
		 0x0809,0x0809,0x0808,0x222B, 0x0000,
		}},
		{{0x9222,0x9222,0x9222,0x9222, 0x9222,0x9222,0x9222,0x9222, 
		 0x9222,0x9222,0x9222,0x9222, 0x9222,0x9222,0x9222,0x9222,
		 0x9222,0x9222,0x9220,0x888A, 0x9A00,
		}},
		{{0}},
		{{0}},
	},

	// Chans
	{
		{{0}},
		{{0}},
		{{0}},
		{{0x01,0x31,0xA1,0xA1, 0x03,0x33,0xA3,0xA3,
		 0x01,0x31,0xA1,0xA1, 0x00,0x00,0x00,0x00,
		 0x01,0x31,0xA1,0xA1, 0x00
		}},
		{{0x92,0xA2,0x92,0x72, 0x92,0xA2,0x92,0x72,
		 0x92,0xA2,0x92,0x72, 0x92,0xA2,0x92,0x72,
		 0x92,0xA2,0x92,0x72, 0x00
		}},
		{{0x52,0x52,0x52,0x42, 0x52,0x52,0x52,0x42,
		 0x52,0x52,0x52,0x42, 0x52,0x52,0x52,0x42,
		 0x52,0x52,0x52,0x42, 0x00
		}},
		{{0x22,0x22,0x02,0x02, 0x22,0x22,0x02,0x02,
		 0x22,0x22,0x02,0x02, 0x22,0x22,0x02,0x02,
		 0x22,0x22,0x02,0x02, 0x00
		}},
		{{0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00,
		 0x04,0x05,0x06,0x07, 0x00,0x00,0x00,0x00,
		 0x08,0x09,0x0A,0x0B, 0x00
		}},
	},
	// Drum settings
	{173,2,0,0},{0,1,0,0},
	// Tracks
	{
		{ {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, 0}, // Track 0
		{ {21,21,21,0,0,0,21,21,21,21,21,0,21,21,21,0},2}, // Track 1
		{ {171,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, 3}, // Track 2
		{ {21,149,0,21,149,0,21,149,0,21,149,0,21,149,0,21},2}, // Track 3
		{ {57,0,0,0,59,0,60,0,0,0,0,0,0,0,0,0}, 4}, // Track 4
		{ {0,0,57,0,0,0,0,0,59,0,0,0,60,0,0,0}, 4}, // Track 5
		{ {52,0,0,0,53,0,55,0,0,0,0,0,0,0,0,0}, 4}, // Track 6
		{ {50,0,43,0,55,0,57,0,59,0,57,0,55,0,53,0}, 4}, // Track 7
		{ {52,0,0,0,55,0,57,0,0,0,0,0,0,0,0,0}, 4}, // Track 8
		{ {57,0,53,0,59,0,60,0,0,0,0,0,0,0,0,0}, 4}, // Track 9
		{ {52,53,55,0,0,0,0,0,0,0,0,0,55,57,55,50}, 4}, // Track 10
		{ {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, 4}, // Track 11
		
	}, 
	// Instruments
	{
		// Ins 0 (hihat)
		{
			1, 5, 15, 50, // ADSR en centesimas de segundo
			0, // sus. time igual que el ADSR
			-12000.0f, // cutoff
			1.1f, // res
			1.5f,  // lfo_freq
			8000.0f, // lfo_amp
			1.0,0.5, // detune
			0.5,0.3, // vols
			1.2//noise
		}, 
		// Ins 1 (bombo)
		{
			1, 15, 40, 5, // ADSR
			0, // sus. time
			20.0f, // cutoff
			1.0f, // res
			1.0f,  // lfo_freq
			200.0f, // lfo_amp
			1.5,1.0, // detune
			1.0,0.5, // vols
			2.4 //noise
		}, 
		// Ins 2 (bajo)
		{
			1, 15, 40, 5, // ADSR
			0, // sus. time
			800.0f, // cutoff
			1.0f, // res
			-0.5f,  // lfo_freq
			-600.0f, // lfo_amp
			1.0,1.0, // detune
			0.4,0.7, // vols
			0.0 //noise
		}, 
		// Ins 3 (pad)
		{
			50, 30, 45, 100, // ADSR
			40, // sus. time
			-1150.0f, // cutoff
			1.0f, // res
			-8.333f,  // lfo_freq
			-950.0f, // lfo_amp
			0.501,1.0, // detune
			0.5,0.7, // vols
			0.0 //noise
		}, 
		
		// Ins 4 (lead)
		{
			0, 10, 50, 40, // ADSR
			20, // sus. time
			900.0f, // cutoff
			1.0f, // res
			1.5f,  // lfo_freq
			900.0f, // lfo_amp
			0.5,1.0, // detune
			0.8,0.4, // vols
			0.0 //noise
		}, 
		

	},
};
