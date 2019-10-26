#include "gl.h"
#include "demo.h"

int main(int argc, char **argv) {
	gl::init(argc, argv);
	demo::init();
	demo::run();
	return 0;
}
