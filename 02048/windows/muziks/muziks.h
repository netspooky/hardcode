#ifdef __cplusplus
extern "C"
{
#endif

typedef struct mData {
	int chan;
	int note;
	int vel;
} mData;

extern void __stdcall mPlay(void *);
extern void __stdcall mStop();
extern void __stdcall mGetData(mData *,int,int);
//first int is a channel number, second int is 'fake velocity' fadeout (from max to 0 in ms)
//returns last played note number, together with it's 'fake velocity'

#ifdef __cplusplus
}
#endif

