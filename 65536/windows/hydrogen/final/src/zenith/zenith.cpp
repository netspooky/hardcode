//#define WIN32_LEAN_AND_MEAN		// Exclude rarely-used stuff from Windows headers

#include <windows.h>
#include "resource.h"
#include "zn_types.h"
#include <ddraw.h>
#include <stdio.h>
#include <string.h>
#include "..\globals.h"
#include "..\z3d\z3d.h"

char script[65536];
char result[65536];
char *line[65536];
char temp[500];

MATRIX work;

void MatrixMultiply(MATRIX *ma,MATRIX *mb){
  MATRIX m;
  for (int i=0;i<4;i++)
    for (int j=0;j<4;j++){
      m.a[i][j]=0;
      for (int k=0;k<4;k++){
        m.a[i][j]+=(long)(((double)ma->a[k][j]*(double)mb->a[i][k])/65536);
      }
    }
  *ma=m;
}

MATRIX MatrixScriptExec(char *script){
  MATRIX work;
  int totlines=1;
  line[0]=script;
  for (int i=0;i<(int)strlen(script);i++){
    if (script[i]==';')
      line[totlines++]=&script[i+1];
    if (script[i]<' ') script[i]=' ';
  }
  work.MakeEquality();
  for (i=0;i<totlines;i++){
    while (line[i][0]==' ') line[i]++;
    MATRIX m;
    m.MakeEquality();
    double angle;
    if (!memcmp(line[i],"rx",strlen("rx"))){
      char *s=strchr(line[i],' ');
      if (!sscanf(s,"%lg",&angle)){
        MessageBox(NULL,"rx: Angle value expected","Error",MB_ICONERROR);
        goto lab1;
      }
      
      angle=angle*PI/180;
      m.a[1][1]=(long)(cos(angle)*65536);
      m.a[2][1]=(long)(-sin(angle)*65536);
      m.a[1][2]=(long)(sin(angle)*65536);
      m.a[2][2]=(long)(cos(angle)*65536);

    } else
    if (!memcmp(line[i],"ry",strlen("ry"))){
      char *s=strchr(line[i],' ');
      if (!sscanf(s,"%lg",&angle)){
        MessageBox(NULL,"ry: Angle value expected","Error",MB_ICONERROR);
        goto lab1;
      }
      angle=angle*PI/180;
      m.a[0][0]=(long)(cos(angle)*65536);
      m.a[0][2]=(long)(-sin(angle)*65536);
      m.a[2][0]=(long)(sin(angle)*65536);
      m.a[2][2]=(long)(cos(angle)*65536);

    } else
    if (!memcmp(line[i],"rz",strlen("rz"))){
      char *s=strchr(line[i],' ');
      if (!sscanf(s,"%lg",&angle)){
        MessageBox(NULL,"rz: Angle value expected","Error",MB_ICONERROR);
        goto lab1;
      }
      angle=angle*PI/180;
      m.a[0][0]=(long)(cos(angle)*65536);
      m.a[1][0]=(long)(-sin(angle)*65536);
      m.a[0][1]=(long)(sin(angle)*65536);
      m.a[1][1]=(long)(cos(angle)*65536);
    }else
    if (!memcmp(line[i],"tr",strlen("tr"))){
      char *s=strchr(line[i],' ');
      double dx,dy,dz;
      if (sscanf(s,"%lg%lg%lg",&dx,&dy,&dz)!=3){
        MessageBox(NULL,"tr: \"X Y Z\" displacement values expected","Error",MB_ICONERROR);
        goto lab1;
      }
      dx*=65536;
      dy*=65536;
      dz*=65536;
      m.a[0][3]=(long)dx;
      m.a[1][3]=(long)dy;
      m.a[2][3]=(long)dz;
    }else
    if (!memcmp(line[i],"sc",strlen("sc"))){
      char *s=strchr(line[i],' ');
      double dx,dy,dz;
      if (sscanf(s,"%lg%lg%lg",&dx,&dy,&dz)!=3){
        MessageBox(NULL,"sc: \"X Y Z\" scale values expected","Error",MB_ICONERROR);
        goto lab1;
      }
      dx*=65536;
      dy*=65536;
      dz*=65536;
      m.a[0][0]=(long)dx;
      m.a[1][1]=(long)dy;
      m.a[2][2]=(long)dz;
    }
    MatrixMultiply(&work,&m);
  }
  return work;
  lab1:
  work.MakeEquality();
  return work;
}

//returns number of bytes, stored to buffer
int MatrixPack(MATRIX *matrix,void *packbuffer){
  ushort *bits=(ushort *)packbuffer;
  MATRIX m;
  m.MakeEquality();
  long *eq=(long *)m.a;
  long *mq=(long *)matrix->a;
  long *dst=(long *)((char *)packbuffer+2);
  *bits=0;
  int cnt=2;
  for (int i=0;i<16;i++){
    *bits<<=1;
    if (eq[i]!=mq[i]){
      *dst=mq[i];
      dst++;
      cnt+=4;
      *bits|=1;
    }

  }
  return cnt;
}

LRESULT CALLBACK Dlg(HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam)
{
	switch (message)
	{
		case WM_INITDIALOG:
				return TRUE;

		case WM_COMMAND:
      switch(LOWORD(wParam)) {
        case IDCANCEL: {
				  EndDialog(hDlg, LOWORD(wParam));
				  return TRUE;
			  }
        case IDC_CALC:
			  {
          GetDlgItemText(hDlg,IDC_SCRIPT,script,65535);
          work=MatrixScriptExec(script);
          sprintf(result,"%08lx\t%08lx\t%08lx\t%08lx\r\n%08lx\t%08lx\t%08lx\t%08lx\r\n%08lx\t%08lx\t%08lx\t%08lx\r\n%08lx\t%08lx\t%08lx\t%08lx",
            work.a[0][0],work.a[0][1],work.a[0][2],work.a[0][3],
            work.a[1][0],work.a[1][1],work.a[1][2],work.a[1][3],
            work.a[2][0],work.a[2][1],work.a[2][2],work.a[2][3],
            work.a[3][0],work.a[3][1],work.a[3][2],work.a[3][3]);
          SetDlgItemText(hDlg,IDC_RESULT,result);
          return TRUE;
			  }
        case IDC_COPY:
			  {
          sprintf(temp,"{%lx,%lx,%lx,%lx,%lx,%lx,%lx,%lx,%lx,%lx,%lx,%lx,%lx,%lx,%lx,%lx}",
            work.a[0][0],work.a[0][1],work.a[0][2],work.a[0][3],
            work.a[1][0],work.a[1][1],work.a[1][2],work.a[1][3],
            work.a[2][0],work.a[2][1],work.a[2][2],work.a[2][3],
            work.a[3][0],work.a[3][1],work.a[3][2],work.a[3][3]);
          return TRUE;
			  }
        case IDC_COPYPACKED:
			  {
          char pck[66];
          int cnt;
          char tmp2[20];
          long pos=0;

          GetDlgItemText(hDlg,IDC_SCRIPT,script,65535);
          if(!strlen(script)) {
            SetDlgItemText(hDlg,IDC_RESULT_P,"Error - no script to pack!");
            return TRUE;
          }
          work=MatrixScriptExec(script);
          sprintf(result,"%08lx\t%08lx\t%08lx\t%08lx\r\n%08lx\t%08lx\t%08lx\t%08lx\r\n%08lx\t%08lx\t%08lx\t%08lx\r\n%08lx\t%08lx\t%08lx\t%08lx",
            work.a[0][0],work.a[0][1],work.a[0][2],work.a[0][3],
            work.a[1][0],work.a[1][1],work.a[1][2],work.a[1][3],
            work.a[2][0],work.a[2][1],work.a[2][2],work.a[2][3],
            work.a[3][0],work.a[3][1],work.a[3][2],work.a[3][3]);
          SetDlgItemText(hDlg,IDC_RESULT,result);
          cnt=MatrixPack(&work,pck);

          char *str_name = strstr(script, "name");
          if(str_name&&(str_name!=script)) {
            str_name+=5;
            while(str_name[pos]!=';'&&str_name[pos]!='\n'&&str_name[pos])
              tmp2[pos] = str_name[pos++];
            tmp2[pos] = 0;
          }
          else {
            *tmp2=0;
          }
          sprintf(temp,"char   %s[%d]={",tmp2,cnt);
          for (int i=0;i<cnt;i++){
            sprintf(tmp2,"%d",(int)pck[i]);
            strcat(temp,tmp2);
            if (i!=cnt-1) strcat(temp,",");
            else strcat(temp,"};");
          }
          OpenClipboard(NULL);
          HANDLE txt=GlobalAlloc(GMEM_MOVEABLE,strlen(temp)+1);
          void *tp=GlobalLock(txt);
          memcpy(tp,temp,strlen(temp)+1);
          GlobalUnlock(txt);
          EmptyClipboard();
          SetClipboardData(CF_TEXT,txt);
          CloseClipboard();
          SetDlgItemText(hDlg,IDC_RESULT_P,temp);
          return TRUE;
			  }
        case IDC_SAVE:
			  {
          OPENFILENAME SaveFileName;
          TCHAR         szFile[MAX_PATH]      = "\0";
          strcpy( szFile, "");
  

          // Fill in the OPENFILENAME structure to support a template and hook.
          SaveFileName.lStructSize       = sizeof(OPENFILENAME);
          SaveFileName.hwndOwner         = hDlg;
          SaveFileName.lpstrFilter       = "Text files [*.txt]\0*.txt;\0*.*\0*.*\0\0";
          SaveFileName.lpstrCustomFilter = NULL;
          SaveFileName.nMaxCustFilter    = 0;
          SaveFileName.nFilterIndex      = 0;
          SaveFileName.lpstrFile         = szFile;
          SaveFileName.nMaxFile          = sizeof(szFile);
          SaveFileName.lpstrFileTitle    = NULL;
          SaveFileName.nMaxFileTitle     = 128;
          SaveFileName.lpstrInitialDir   = NULL;
          SaveFileName.lpstrTitle        = "Save script as...";
          SaveFileName.nFileOffset       = 0;
          SaveFileName.nFileExtension    = 0;
          SaveFileName.lpstrDefExt       = "txt";
          SaveFileName.Flags             = 0;

          // Call the common dialog function.
          if(GetSaveFileName(&SaveFileName)) {	
            FILE *f;
            f = fopen(SaveFileName.lpstrFile, "wb");
            if(!f)
              MessageBox(hDlg,"Can't open file for writing!","Zenith save file error!",MB_OK|MB_ICONERROR);
            GetDlgItemText(hDlg,IDC_SCRIPT,script,65535);
            fwrite(script, 1, strlen(script), f);
            fclose(f);
          }
          return TRUE;
        }
        case IDC_LOAD:
			  {
          OPENFILENAME OpenFileName;
          TCHAR         szFile[MAX_PATH]      = "\0";
          strcpy( szFile, "");
  

          // Fill in the OPENFILENAME structure to support a template and hook.
          OpenFileName.lStructSize       = sizeof(OPENFILENAME);
          OpenFileName.hwndOwner         = hDlg;
          OpenFileName.lpstrFilter       = "Text files [*.txt]\0*.txt;\0*.*\0*.*\0\0";
          OpenFileName.lpstrCustomFilter = NULL;
          OpenFileName.nMaxCustFilter    = 0;
          OpenFileName.nFilterIndex      = 0;
          OpenFileName.lpstrFile         = szFile;
          OpenFileName.nMaxFile          = sizeof(szFile);
          OpenFileName.lpstrFileTitle    = NULL;
          OpenFileName.nMaxFileTitle     = 128;
          OpenFileName.lpstrInitialDir   = NULL;
          OpenFileName.lpstrTitle        = "Opne script";
          OpenFileName.nFileOffset       = 0;
          OpenFileName.nFileExtension    = 0;
          OpenFileName.lpstrDefExt       = NULL;
          OpenFileName.Flags             = 0;

          // Call the common dialog function.
          if(GetOpenFileName(&OpenFileName)) {	
            FILE *f;
            long pos=0;

            f = fopen(OpenFileName.lpstrFile, "rb");
            if(!f)
              MessageBox(hDlg,"Can't open file for writing!","Zenith save file error!",MB_OK|MB_ICONERROR);
            while(fread(&script[pos], 1, 1, f))
              pos++;
            SetDlgItemText(hDlg,IDC_SCRIPT,script);
            fclose(f);
          }
          return TRUE;
        }
        default: break;
      }
	}
    return FALSE;
}

int APIENTRY WinMain(HINSTANCE hInstance,
                     HINSTANCE hPrevInstance,
                     LPSTR     lpCmdLine,
                     int       nCmdShow)
{
  DialogBox(hInstance, (LPCTSTR)IDD_CALC, NULL, (DLGPROC)Dlg);
	return 0;
}



