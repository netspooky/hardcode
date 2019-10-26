#include <windows.h>
#include "muziks.h"
#include "tune.h"

mData lastplayed;

int _main() {
	mPlay(&tune);
	while (1) {
		mGetData(&lastplayed,1,500);
		printf("channel: %d, note: %d, velocity: %d\n",lastplayed.chan,lastplayed.note,lastplayed.vel);
		Sleep(100);
		if (GetAsyncKeyState(VK_ESCAPE)) {
			mStop();
			ExitProcess(0);
		}
	}
}

