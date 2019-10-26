#pragma once

#include <windows.h>

char *ReadFile(char const* filename)
{
	HANDLE file = CreateFile(filename, GENERIC_READ, FILE_SHARE_READ, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);

	if (file == INVALID_HANDLE_VALUE)
		ExitProcess(1);

	char * data = new char[64000];
	DWORD size;
	DWORD bytes_read = 0;
	do
	{
		ReadFile(file, (void*)(data + bytes_read), 16000, &size, 0);
		bytes_read += size;
	} while (size > 0);

	data[bytes_read] = 0;

	CloseHandle(file);

	return data;
}
