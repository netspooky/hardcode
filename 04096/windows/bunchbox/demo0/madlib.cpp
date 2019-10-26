// BUNCHBOX, Brad Smith 9/18/2009

#include "madlib.h"
#include "main4k.h"
#include "math.h"
#include "sound.h"
#include "song.h"

// Madlib data flow:
//   tick executes frames until the output buffer is full
//   each frame:
//     1. read music pattern data
//     2. pattern data updates Driver objects
//     3. Driver objects update Channel objects
//     4. Channel objects generate sound
//     5. frame is copied to tick's output buffer

// NOTE: two's complement integers are directly assumed

namespace Madlib {

// animation sync stats
const uint32 SYNC_FRAMES_BUFFER = Sound::BUFFER_SIZE / FRAME_LEN;
const uint32 SYNC_FRAMES = 2 * SYNC_FRAMES_BUFFER;
uint32 sync_frame_load = 0;
uint32 frame_count = 0;

const Track * track;

// ===============
// wave generation
// ===============

static inline float wave_lookup( float phase )
{
	return fsin( phase * TWO_PI );
}

// ============
// channel data
// ============

struct Channel
{
	// only set to 0 on instruent start
	float phase[2];
	float feed_sample;
	// update these each frame
	float pitch[2];
	float vol_mod;
	float feedback;
	float vol_l;
	//float vol_r;
};

static Channel channel[NUM_CHANNELS];

// ==============
// channel action
// ==============

static inline void fm( Channel & c, float * buffer, uint32 len )
{
	for ( uint32 i=len; i>0; --i )
	{
		// update phase from pitch
		for ( int i=0; i < 2; ++i )
		{
			c.phase[i] = c.phase[i] + c.pitch[i];
			// maintain numerical stability by keeping phase from 0 to 1
			while ( c.phase[i] > 1.0f ) c.phase[i] -= 1.0f;
		}

		// generate modulator (modulate with feedback) and attenuate
		const float wi0 = c.phase[0] + (c.feed_sample*c.feedback);
		const float w0 = wave_lookup(wi0) * c.vol_mod;

		// store feedback
		c.feed_sample = w0;

		// generate carrier with phase adjusted by modulator
		const float wi1 = c.phase[1] +w0;
		const float w1 = wave_lookup(wi1);

		// pan and attenuate, add to buffer
		buffer[0] += (w1 * c.vol_l);
		//buffer[1] += (w1 * c.vol_r);
		//buffer += 2;
		++buffer;
	}
}

// =====
// frame
// =====

static float frame_buffer[FRAME_SIZE];

// ===========
// driver data
// ===========

enum DriverMode
{
	DMODE_OFF,
	DMODE_START,
	DMODE_ATTACK,
	DMODE_RELEASE,
};

struct Driver // driver controls a channel (filled in by pattern commands)
{
	Instrument inst;

	uint8 note; // last note, used for sync
	float pitch;
	float volume; // volume 0 = off
	//uint32 pan;

	// volume enevlope
	DriverMode mode[2];
	uint32 vol_pos[2];
	float vol_cur[2];
	float start_vol[2];

	// sync data
	Sync sync[SYNC_FRAMES];
};

static Driver driver[NUM_CHANNELS];

// =============
// driver action
// =============

// interpolation helper
static float env_int( uint32 pos, uint32 len, float a, float b )
{
	float blend_a = float(len - pos);
	float blend_b = float(pos);
	return 
		( ( blend_a * a ) +
		  ( blend_b * b ) )
		/ float(len);
}

static void drive( Driver & d, Channel & c )
{
	for ( int i=0; i < 2; ++i )
	{
		switch ( d.mode[i] )
		{
			case DMODE_OFF:
				d.vol_cur[i] = 0.0f;
				break;
			case DMODE_START:
				d.vol_pos[i] = 0;
				d.start_vol[i] = d.vol_cur[i];
				d.mode[i] = DMODE_ATTACK;
				c.phase[i] = 0.0f; // eliminates pop at start a little
				// fallthrough
			case DMODE_ATTACK:
				d.vol_pos[i]++;
				if ( d.vol_pos[i] > d.inst.ar_len[i][0] )
				{
					d.mode[i] = DMODE_RELEASE;
					d.vol_pos[i] = 0;
					// fallthrough
				}
				else
				{
					d.vol_cur[i] = env_int( d.vol_pos[i], d.inst.ar_len[i][0], d.start_vol[i], d.inst.ar_vol[i][0] );
					break;
				}
				// fallthrough
			case DMODE_RELEASE:
				d.vol_pos[i]++;
				if ( d.vol_pos[i] > d.inst.ar_len[i][1] )
				{
					d.mode[i] = DMODE_OFF;
				}
				else
				{
					d.vol_cur[i] = env_int( d.vol_pos[i], d.inst.ar_len[i][1], d.inst.ar_vol[i][0], d.inst.ar_vol[i][1] );
				}
				break;
		}
	}

	float mod_vol = d.vol_cur[0];
	float car_vol = d.vol_cur[1];

	d.sync[sync_frame_load].note = d.note; // sync
	d.sync[sync_frame_load].vol = car_vol; // sync

	float pitch = d.pitch;

	// panning
	//uint32 pan_l = 127;
	//uint32 pan_r = 127;
	//if ( d.pan != 0 )
	//{
	//	if ( d.pan > 128 ) pan_l = 255 - d.pan;
	//	if ( d.pan < 128 ) pan_r = d.pan - 1;
	//}

	// update channel
	c.pitch[0] = ( d.inst.mod_pitch_d != 0.0f ) ?
		( pitch * d.inst.mod_pitch_n / d.inst.mod_pitch_d ) : // relative pitch
		( track->scale[(int)d.inst.mod_pitch_n] ); // absolute
	c.pitch[1] = pitch;
	c.vol_mod = mod_vol;
	//c.vol_l = ((car_vol * d.volume * float(pan_l)) / 127.0f );
	//c.vol_r = ((car_vol * d.volume * float(pan_r)) / 127.0f );
	c.vol_l = car_vol * d.volume;
	c.feedback = d.inst.feedback;

	// render sound
	fm( c, frame_buffer, FRAME_LEN );
}

// ==============
// music playback
// ==============

struct Playback
{
	uint32 speed;
	uint32 skip;
	uint32 row;
	uint32 order;
	uint32 next;
};

static Playback playback;

static uint32 pattern_skip[NUM_CHANNELS];
static const uint8 * pattern_buffer[NUM_CHANNELS];

void read_row( uint32 channel )
{
	ASSERT( channel < NUM_CHANNELS );
	Driver & d = driver[channel];

	const uint8 * buffer = pattern_buffer[channel];
	if ( buffer == NULL ) return; // empty pattern

	pattern_skip[channel]--;
	while ( pattern_skip[channel] == 0 )
	{
		uint8 param = buffer[0];
		++buffer;

		if ( param > 0 )
		{
			ASSERT( track );
			ASSERT( track->scale );
			d.mode[0] = DMODE_START;
			d.mode[1] = DMODE_START;
			d.pitch = track->scale[param];
			d.note = param; // store note for sync
		}

		pattern_skip[channel] = uint32(buffer[0]);
		++buffer;
	}

	pattern_buffer[channel] = buffer;
}

static void jump_track( uint32 order )
{
	if ( order >= track->order_len )
	{
		order = 0; // loop
	}

	for ( uint32 c=0; c < track->num_channels; ++c )
	{
		pattern_buffer[c] = track->pattern[(track->order[order] * track->num_channels)+c];
		pattern_skip[c] = 1;
	}
	playback.row = 0;
	playback.skip = 0;
	playback.order = order;
	playback.next = order + 1;
}

// ==========
// music loop
// ==========

static void make_frame()
{
	ASSERT( track != NULL );

	// if not skipping frames (p.track->speed skipped at a time)
	if ( playback.skip == 0 )
	{
		// if at the end of the pattern, jump to the next one
		if ( playback.row >= track->pattern_len )
		{
			jump_track( playback.next );
		}

		// read a row for all drivers assigned to the track
		for ( uint32 c=0; c < track->num_channels; ++c )
		{
			read_row( c );
		}
		++playback.row;

		// reset the frame skip
		playback.skip = playback.speed;
	}
	// advance the frame
	--playback.skip;

	// update all channels from drivers, render frame
	::memset(frame_buffer,0,sizeof(frame_buffer));
	for ( uint32 i=0; i < NUM_CHANNELS; ++i )
	{
		drive( driver[i], channel[i] );
	}
}

// ====
// tick
// ====

void tick( sint16 * buffer, unsigned int samples )
{
	// copy leftover old frame
	//ASSERT( frame_left < samples );
	//::memcpy( buffer, frame_buffer + (FRAME_SIZE-(2*frame_left)), sizeof(sint16)*2*frame_left );
	//samples -= frame_left;
	//frame_left = 0;
	ASSERT( 0 == ((FRAME_SIZE-1) & samples) );

	// fill and copy frames
	while ( samples )
	{
		make_frame(); // reads music data and updates output channels, renders sound into frame_buffer

		// copy the frame
		for ( uint32 i=0; i < FRAME_SIZE; ++i )
		{
			buffer[i] = sint32( frame_buffer[i] * ( 32767.0f / 8.0f ) );
		}

		samples -= FRAME_LEN;
		buffer += FRAME_SIZE;
		sync_frame_load = ( sync_frame_load + 1 ) & (SYNC_FRAMES-1);
	}

	frame_count += SYNC_FRAMES;
}

// =====
// setup
// =====

void setup( const Track * t )
{
	::memset( &driver, 0, sizeof(driver) );

	for ( int i=0; i < 6; ++i )
	{
		driver[i].volume = 1.0f;
	}

	// channel instrument and panning hard coded
	driver[CHANNEL_PAD1 ].inst = t->instrument[4];
	driver[CHANNEL_PAD2 ].inst = t->instrument[4];
	driver[CHANNEL_BASS ].inst = t->instrument[0];
	driver[CHANNEL_KICK ].inst = t->instrument[1];
	driver[CHANNEL_SNARE].inst = t->instrument[2];
	driver[CHANNEL_HAT  ].inst = t->instrument[3];
	//driver[CHANNEL_PAD1 ].pan = 1;
	//driver[CHANNEL_PAD2 ].pan = 255;
	//driver[CHANNEL_BASS ].pan = 25;
	//driver[CHANNEL_KICK ].pan = 245;
	//driver[CHANNEL_SNARE].pan = 200;
	//driver[CHANNEL_HAT  ].pan = 80;

	ASSERT( t );
	track = t;
	jump_track( 0 );
	playback.speed = track->speed;
}

// ====
// sync
// ====

void get_sync( uint32 * frame, Sync * sync_out )
{
	const uint32 pos = Sound::sound_pos();
	ASSERT( frame );
	*frame = pos / FRAME_LEN;
	const uint32 partial = *frame & ((SYNC_FRAMES_BUFFER*2)-1);

	for ( uint32 i=0; i < NUM_CHANNELS; ++i )
	{
		ASSERT( (partial) < SYNC_FRAMES );
		sync_out[i] = driver[i].sync[partial];
	}
}

} // namespace Madlib
