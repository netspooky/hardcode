#ifndef _SOUND_HPP_
#define _SOUND_HPP_

typedef struct 
{
	int length;
	int pos;
	unsigned char *data;
} MEMFILE;

class Sound
{
	public:

		Sound();
		~Sound();

		bool init();
		void play();
		void release();
		int getOrder();
		int getRow();
		int getTime();

	private:
		unsigned int fmod_sync;
};

#endif
