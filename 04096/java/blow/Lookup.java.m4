BLOW_DEFINE_EFFECT2(lookup,`
	for(int i=0;i<dest.length;i++){
	    dest[i]=src[BLOW_GLOBAL(lookupTable)[i]];
	}
')

BLOW_DEFINE_GLOBAL(`int[]', lookupTable)
BLOW_ADD_INITIALIZER(`initLookupTable();')


dnl here comes some javacode... 
dnl maybe there should be macros for methoddefinitins too,
dnl  so they could be namemageled too.
public void initLookupTable(){
	BLOW_GLOBAL(lookupTable)=new int[height*width];
	for(int y=0;y<height;y++){
	    for(int x=0;x<width;x++){
		BLOW_GLOBAL(lookupTable)[y*width+x]=(((int)((y-height/2)/1.05))+height/2)*width+(((int)((x-width/2)/1.05))+width/2);
		while(BLOW_GLOBAL(lookupTable)[y*width+x]<0){
		    BLOW_GLOBAL(lookupTable)[y*width+x]+=width;
		}
		while(BLOW_GLOBAL(lookupTable)[y*width+x]>=width*height){
		    BLOW_GLOBAL(lookupTable)[y*width+x]-=width;
		}
	    }
	}
    }
