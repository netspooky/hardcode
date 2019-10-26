#include <stdlib.h>
#include "demo.h"

int main(int argc, char **argv) 
{  
	demo_init(argc, argv);

	demo_main_loop();

	demo_shutdown();

	return EXIT_SUCCESS;
}
