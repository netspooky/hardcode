
#include <stdio.h>

main(int argc,char *argv[])
{
    int c,row=0,first=1;

    printf("unsigned char %s[]={\n",argv[1]);
    do
    {
        c=getchar();
        if(c!=EOF)
        {
            if(first)
            {
                first=0;
                printf("%d",c);
            }
            else
                printf(",%d",c);

            if(++row==16)
            {
                row=0;
                printf("\n");
            }
        }
    }
    while(c!=EOF);

    printf("};\n");
}
