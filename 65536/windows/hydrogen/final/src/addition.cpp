#include "addition.h"

#ifdef _DEBUG
void ShowErrorCode(DWORD error) {
		LPVOID lpMsgBuf;
		FormatMessage( 
			FORMAT_MESSAGE_ALLOCATE_BUFFER | 
			FORMAT_MESSAGE_FROM_SYSTEM | 
			FORMAT_MESSAGE_IGNORE_INSERTS,
			NULL,
			error,
			0, // Default language
			(LPTSTR) &lpMsgBuf,
			0,
      NULL);
		MessageBox(NULL, (LPCTSTR)lpMsgBuf, "Error", MB_OK | MB_ICONERROR);
		// Free the buffer.
		LocalFree( lpMsgBuf );
};

void ShowLastError () {
  ShowErrorCode(GetLastError());
};
#endif

unsigned int memopen(char *name) {
  MEMFILE *memfile;

  memfile = new MEMFILE;

  HRSRC    rec;
  HGLOBAL  handle;
	
  rec = FindResource(NULL, name, name);
#ifdef _DEBUG
  if(rec==NULL){
    MessageBox(NULL,"Can't find resource","Info...",MB_OK|MB_ICONINFORMATION);
  }
#endif
  handle = LoadResource(NULL, rec);
#ifdef _DEBUG
  if(handle==NULL){
    MessageBox(NULL,"Can't load resource","Info...",MB_OK|MB_ICONINFORMATION);
  }
#endif	
  memfile->data = (unsigned char*)LockResource (handle);
  memfile->length = SizeofResource (NULL, rec);
  memfile->pos = 0;

  return (unsigned int)memfile;
}

void memclose(unsigned int handle) {
  MEMFILE *memfile = (MEMFILE *)handle;

  delete (memfile);
}

int memread(void *buffer, int size, unsigned int handle) {
  MEMFILE *memfile = (MEMFILE *)handle;

  if(memfile->pos + size >= memfile->length)
    size = memfile->length - memfile->pos;

  memcpy(buffer, (char *)memfile->data+memfile->pos, size);
  memfile->pos += size;
	
  return size;
}

void memseek(unsigned int handle, int pos, signed char mode) {
  MEMFILE *memfile = (MEMFILE *)handle;

  switch(mode) {
  case SEEK_SET:  memfile->pos = pos; break;
  case SEEK_CUR:  memfile->pos += pos; break;
  case SEEK_END:  memfile->pos = memfile->length + pos; break;
  }

  if(memfile->pos > memfile->length)
   memfile->pos = memfile->length;
}

int memtell(unsigned int handle) {
  MEMFILE *memfile = (MEMFILE *)handle;

  return memfile->pos;
}