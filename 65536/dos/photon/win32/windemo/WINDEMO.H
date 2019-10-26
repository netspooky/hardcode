typedef struct{
	void * lfb;
	int pitch;
}lfbstruct;

#ifdef __cplusplus
extern "C" {
#endif
void Mso();
BOOL VideoLock(lfbstruct * lfb);
void VideoUnlock(void);
BOOL VideoOpen(int x, int y, int depth);
BOOL VideoClose(void);
void timerpoll();
void VideoFrame(void *vscr);
int os_stuff(void);
#ifdef __cplusplus
};
#endif
