
#define TICK 30
#define LENGTH 45000

#define EVENTS 4

/**
 * Which visual effect function to run for what time.
 */
struct Event
{
	int start;
	int stop;
	void (*effect)(int t);
};

/**
 * Declaration of the event array.
 * See seq.c for the actual definition.
 */
struct Event events[EVENTS];

void sequencer_loop();
//void init_seq();

