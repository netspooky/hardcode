#include "base.h"
#include "color.h"
#include "globals.h"

#include "addition.h"
#include "resource.h"
#include "video.h"

#include ".\z3d\z3d.h"
#include "sound.h"
#include "txgen.h"

#define TL_TICKS_PER_ROW       3
#define TL_ROWS_PER_PATTERN    64

#define TL_PR(p,r) (TL_TICKS_PER_ROW*(r+TL_ROWS_PER_PATTERN*p)) //pattern-row
#define TL_R(r) (TL_TICKS_PER_ROW*r)

#define NEEDFPS 20
#define MEASUREFPS 10 //measure fps each MEASUREFPS frames
//#define CALC_FPS //calculate fps or not

DWORD           tstart,tend;
DWORD           frames=0;
double          fps=0;

HWND            mainWnd;
HRESULT         hresult;
VideoDevice     *mainVD;
int             v=100;
int             i = 50;
int             pause=0;
int             t=0;
int             StartupExit=0;
int             Finished=0;



Z3D *z3d;
CSYSTEM *blobcs;
DECAL *decal;
DECAL *bubble;
DECAL *grd;
FONT /**font40,*/*font20,*font20ni,*font20yellow,*font20white,*font20grey;

LIGHT *light;


void CALLBACK TimeProc(UINT uID,UINT uMsg,DWORD dwUser,DWORD dw1,DWORD dw2){
  needframes++;
}

long FAR PASCAL
WindowProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam) {
  switch (message) {
    case WM_DESTROY:
    case WM_CLOSE:
    case WM_QUIT:	
      PostQuitMessage(0);
      break;
    case WM_SIZE:
      if(mainVD->Exist())
        MoveWindow(mainWnd,mainVD->v_rcWindow.left,mainVD->v_rcWindow.top,
                   mainVD->width,mainVD->height,TRUE);
      return 0;
      break;
    case WM_NCPAINT: if (FullScreen) return 0;
                     else return DefWindowProc(hWnd, message, wParam, lParam);
    case WM_MOVE:
      mainVD->UpdateBounds();
      break;

    case WM_KEYDOWN:
#ifdef _DEBUG
        OBJECT *objct=z3d->scene[7].object[0];
        CAMERA *camr=z3d->scene[7].camera[0];
#endif
      switch (wParam) {
#ifdef _DEBUG

        case VK_F1:objct->shade=0;break;
        case VK_F2:objct->shade=1;break;
        case VK_F3:objct->shade=2;break;
        case VK_F4:objct->shade=3;break;
        case VK_F5:objct->shine=0;break;
        case VK_F6:objct->shine=1;break;
        case VK_F7:objct->shininess -=.01;break;
        case VK_F8:objct->shininess +=.01;break;

        case VK_HOME:camr->z +=20L<<16;break;
        case VK_END:camr->z -=20L<<16;break;
        case VK_DELETE:camr->x -=20L<<16;break;
        case VK_NEXT:camr->x +=20L<<16;break;
        case VK_INSERT:camr->y -=20L<<16;break;
        case VK_PRIOR:camr->y +=20L<<16;break;

        case VK_UP:camr->ax -=5L<<8;break;
        case VK_DOWN:camr->ax +=5L<<8;break;
        case VK_LEFT:camr->ay -=5L<<8;break;
        case VK_RIGHT:camr->ay +=5L<<8;break;
        case VK_DIVIDE:camr->az +=5L<<8;break;
        case VK_MULTIPLY:camr->az -=5L<<8;break;

        case VK_ADD:needframes+=200;break;

        case VK_F11:objct->z -=50L<<16;break;
        case VK_F12:objct->z +=50L<<16;break;
        case '1':objct->ax +=5L<<8;break;
        case '2':objct->ay +=5L<<8;break;
        case '3':objct->az +=5L<<8;break;
        case 'Q':objct->ax -=5L<<8;break;
        case 'W':objct->ay -=5L<<8;break;
        case 'E':objct->az -=5L<<8;break;
#endif
        case VK_ESCAPE:
          PostMessage(hWnd, WM_CLOSE, 0, 0);
          break;
#ifdef _DEBUG
        default: pause=!pause;
#endif
      };
  };

  return DefWindowProc(hWnd, message, wParam, lParam);

}

HWND CreateWindowFS(int width, int height,const char *name,HINSTANCE hInstance)
{
  WNDCLASS				wc;
	wc.style = CS_HREDRAW | CS_VREDRAW;
	wc.lpfnWndProc = WindowProc;
	wc.cbClsExtra = 0;
	wc.cbWndExtra = 0;
	wc.hInstance = hInstance;
	wc.hIcon = LoadIcon(hInstance, MAKEINTRESOURCE(IDI_ICON));
	wc.hCursor = LoadCursor(NULL, IDC_ARROW);
	wc.hbrBackground = (HBRUSH )GetStockObject(BLACK_BRUSH);
	wc.lpszMenuName = NULL;
	wc.lpszClassName = name;
	RegisterClass(&wc);

  // Create a window
	return CreateWindow(name,
                        name,
                        WS_VISIBLE|WS_SYSMENU|WS_OVERLAPPED,
                        (GetSystemMetrics(SM_CXSCREEN)-width)/2,
                        (GetSystemMetrics(SM_CYSCREEN)-height)/2,
                        width,
                        height,
                        NULL,
                        NULL,
                        hInstance,
                        NULL);
};

LRESULT CALLBACK Dlg(HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam)
{
	switch (message)
	{
		case WM_INITDIALOG:{
        SetClassLong(hDlg,          // window handle 
          GCL_HICON,              // changes icon 
          (LONG) LoadIcon(GetModuleHandle(NULL), MAKEINTRESOURCE(IDI_ICON))
        );
        CheckRadioButton(hDlg,IDC_RADIO1,IDC_RADIO3,IDC_RADIO1);
        #ifndef _DEBUG
    			CheckRadioButton(hDlg,IDC_RADIO4,IDC_RADIO6,IDC_RADIO6);
        #else
    			CheckRadioButton(hDlg,IDC_RADIO4,IDC_RADIO6,IDC_RADIO4);
        #endif
        #ifndef _DEBUG
          CheckDlgButton(hDlg,IDC_CHECK1,1);
        #endif
        CheckDlgButton(hDlg,IDC_CHECK2,1);
        return TRUE;
    }
/*    case WM_MOUSEMOVE:{
      static int col=0;
      static int inc=0;
      //inc+=100;
      //col+=inc;

      int xPos =lParam&0xffff;
      int yPos =lParam>>16;
      HDC hdc=GetDC(hDlg);
      col=GetPixel(hdc,xPos,yPos);
      col-=1;
      SetPixel(hdc,xPos,yPos,col);
      col-=1;
      SetPixel(hdc,xPos+1,yPos-1,col);
      SetPixel(hdc,xPos+1,yPos+1,col);
      SetPixel(hdc,xPos-1,yPos-1,col);
      SetPixel(hdc,xPos-1,yPos+1,col);
    };break;*/
		case WM_COMMAND:
			if (LOWORD(wParam) == IDCANCEL||LOWORD(wParam) == IDOK){
				StartupExit=(LOWORD(wParam) == IDCANCEL);
        if (IsDlgButtonChecked(hDlg,IDC_RADIO1)==BST_CHECKED){
          DEMO_BB_WIDTH=640;
          DEMO_BB_HEIGHT=480;
        } else
        if (IsDlgButtonChecked(hDlg,IDC_RADIO2)==BST_CHECKED){
          DEMO_BB_WIDTH=512;
          DEMO_BB_HEIGHT=384;
        } else
        if (IsDlgButtonChecked(hDlg,IDC_RADIO3)==BST_CHECKED){
          DEMO_BB_WIDTH=320;
          DEMO_BB_HEIGHT=240;
        }

        if (IsDlgButtonChecked(hDlg,IDC_RADIO4)==BST_CHECKED){
          soundfreq=0;
        } else
        if (IsDlgButtonChecked(hDlg,IDC_RADIO5)==BST_CHECKED){
          soundfreq=22050;
        } else
        if (IsDlgButtonChecked(hDlg,IDC_RADIO6)==BST_CHECKED){
          soundfreq=44100;
        }

        FullScreen=(IsDlgButtonChecked(hDlg,IDC_CHECK1)==BST_CHECKED);
        ResizeToFullScreen=(IsDlgButtonChecked(hDlg,IDC_CHECK2)==BST_CHECKED);
        if (ResizeToFullScreen){
          DEMO_WIDTH=DEMO_BB_WIDTH;
          DEMO_HEIGHT=DEMO_BB_HEIGHT;
        }
        EndDialog(hDlg, LOWORD(wParam));
				return TRUE;
			}
    }
    return FALSE;
}


int WINAPI WinMain(HINSTANCE hInstance,
                     HINSTANCE hPrevInstance,
                     LPSTR     lpCmdLine,
                     int       nCmdShow){

  uint ii;
  uint ic;

  DialogBox(hInstance, (LPCTSTR)IDD_DIALOG1, NULL, (DLGPROC)Dlg);
  if (StartupExit) return 0;
  mainVD=new VideoDevice;
  mainWnd = CreateWindowFS(DEMO_BB_WIDTH,DEMO_BB_HEIGHT,DEMO_CODENAME,hInstance);
  if(mainWnd==NULL){
#ifdef _DEBUG
    ShowLastError ();
#endif
    PostMessage(mainWnd, WM_CLOSE, 0, 0);
  }
	//ShowWindow(mainWnd, SW_SHOW);
	//SetFocus(mainWnd);

  if (FullScreen){
    hresult = mainVD->CreateFullScreen(mainWnd,DEMO_WIDTH,DEMO_HEIGHT,DEMO_BB_WIDTH,DEMO_BB_HEIGHT,32);
    if(FAILED(hresult))
      hresult = mainVD->CreateFullScreen(mainWnd,DEMO_WIDTH,DEMO_HEIGHT,DEMO_BB_WIDTH,DEMO_BB_HEIGHT,24);
  }
  else {
    hresult = mainVD->CreateWindowed(mainWnd,DEMO_BB_WIDTH,DEMO_BB_HEIGHT,32);
    if(FAILED(hresult))
      hresult = mainVD->CreateWindowed(mainWnd,DEMO_BB_WIDTH,DEMO_BB_HEIGHT,24);
  }

  DDPIXELFORMAT _pf;
  ZeroMemory(&_pf,sizeof(_pf));
  _pf.dwSize=sizeof(_pf);
  mainVD->GetFrontBuffer()->GetPixelFormat(&_pf);
  bpp=_pf.dwRGBBitCount; //bits per pixel
  if ((bpp!=24&&bpp!=32)/*||*/){
    MessageBox(mainWnd,"Unable to set 24 or 32bit mode...","Info...",MB_OK|MB_ICONINFORMATION);
    PostMessage(mainWnd, WM_CLOSE, 0, 0);
//    return 1;
  }
  if (FAILED(hresult)){
    PostMessage(mainWnd, WM_CLOSE, 0, 0);
    //mainVD->Destroy();
//    MessageBox(mainWnd,"Unable to set video mode, try unchecking \"Resize to fullscreen\"","Info...",MB_OK|MB_ICONINFORMATION);
//    return 1;
  }

  z3d=new Z3D;
  z3d->Init();

  int font_interlaced=DEMO_BB_WIDTH==DEMO_FIXED_WIDTH?FONT_INTERLACED:0;
  int font_blue=DEMO_BB_WIDTH==DEMO_FIXED_WIDTH?0x7fdfdf:0x5fafaf;
  int font_white=DEMO_BB_WIDTH==DEMO_FIXED_WIDTH?0xdfdfdf:0xafafaf;
  int font_yellow=DEMO_BB_WIDTH==DEMO_FIXED_WIDTH?0xffff00:0xdfdf00;
  int font_grey=DEMO_BB_WIDTH==DEMO_FIXED_WIDTH?0x8f8f8f:0x5f5f5f;

  FONT *tmpf=new FONT;
  tmpf->Unpack(font_abc,font_data,40,font_white,12,font_interlaced|FONT_FADEINOUT);
  ShowCursor(FALSE);

  char decr[200]="decrunchinG...";
  int decrframe=6;
  
  mainVD->Clear();
  tmpf->PutsToSurface(0,0,decr,mainVD->GetBackBuffer(),&mainVD->rect,decrframe);
  mainVD->Show();
  
  //font40=new FONT;
  font20=new FONT;
  font20yellow=new FONT;
  font20white=new FONT;
  font20grey=new FONT;

  //font40->Unpack(font_abc,font_data,40,font_blue,64,font_interlaced|FONT_FADEINOUT);
  font20->Unpack(font_abc,font_data,20,font_blue,64,font_interlaced|FONT_FADEINOUT);

  strcat(decr,".");
  decrframe++;
  mainVD->Clear();
  tmpf->PutsToSurface(0,0,decr,mainVD->GetBackBuffer(),&mainVD->rect,decrframe);
  mainVD->Show();

  font20white->Unpack(font_abc,font_data,20,font_white,64,font_interlaced|FONT_FADEINOUT);

  strcat(decr,".");
  decrframe++;
  mainVD->Clear();
  tmpf->PutsToSurface(0,0,decr,mainVD->GetBackBuffer(),&mainVD->rect,decrframe);
  mainVD->Show();

  font20grey->Unpack(font_abc,font_data,20,font_grey,64,font_interlaced|FONT_FADEINOUT);

  strcat(decr,".");
  decrframe++;
  mainVD->Clear();
  tmpf->PutsToSurface(0,0,decr,mainVD->GetBackBuffer(),&mainVD->rect,decrframe);
  mainVD->Show();

  font20yellow->Unpack(font_abc,font_data,20,font_yellow,64,font_interlaced|FONT_FADEINOUT);
#ifdef CALC_FPS
  font20ni=new FONT;
  font20ni->Unpack(font_abc,font_data,20,0x7f7f7f,64,FONT_FADEINOUT);
#endif  

  strcat(decr,".");
  decrframe++;
  mainVD->Clear();
  tmpf->PutsToSurface(0,0,decr,mainVD->GetBackBuffer(),&mainVD->rect,decrframe);
  mainVD->Show();

  z3d->scene[0].camera[0]=new CAMERA;
  z3d->scene[0].camera[0]->Create(mainVD->GetBackBuffer(),&mainVD->rect);
  z3d->scene[1].camera[0]=new CAMERA;
  z3d->scene[1].camera[0]->Create(mainVD->GetBackBuffer(),&mainVD->rect);
  z3d->scene[1].camera[0]->fog=FOG_WATER;
  z3d->scene[1].camera[0]->ax=10L<<8;

  z3d->scene[2].camera[0]=new CAMERA;
  z3d->scene[2].camera[0]->fog=FOG_FOG;
  z3d->scene[2].camera[0]->y=50L<<16;
  z3d->scene[2].camera[0]->z=5250L<<16;
 // z3d->scene[2].camera[0]->z=3000L<<16;
  z3d->scene[2].camera[0]->Create(mainVD->GetBackBuffer(),&mainVD->rect);

  z3d->scene[3].camera[0]=new CAMERA;
  z3d->scene[3].camera[0]->y=3000L<<16;
  z3d->scene[3].camera[0]->z=0;
  
  z3d->scene[3].camera[0]->ax=64L<<8;
  z3d->scene[3].camera[0]->Create(mainVD->GetBackBuffer(),&mainVD->rect);

  z3d->scene[4].camera[0]=new CAMERA;
  z3d->scene[4].camera[0]->Create(mainVD->GetBackBuffer(),&mainVD->rect);

  z3d->scene[7].camera[0]=new CAMERA;
  z3d->scene[7].camera[0]->Create(mainVD->GetBackBuffer(),&mainVD->rect);

  uint f;
  uint j;

//=======================================TEXTURES
  
  txProcP txp;

  txp.param1 = 10;
  txp.param3 = 1;

  TEXTURE_Z *tex=new TEXTURE_Z;
  tex->Create(256,256);
  txp.param2 = 1;
  txgSubplasma(tex,&txp);
  txp.param2 = 2;
  txgSubplasma(tex,&txp);
  z3d->texture[0]=tex;

  tex=new TEXTURE_Z;
  tex->Create(256,256);
  txp.param2 = 2;
  txgSubplasma(tex,&txp);
  txp.param2 = 1;
  txgSubplasma(tex,&txp);
  z3d->texture[5]=tex;

  tex=new TEXTURE_Z;
  tex->Create(2,2);
  tex->SetPixel(0,0,0x8f954f);
  tex->SetPixel(0,1,0x7f7f4f);
  tex->SetPixel(1,0,0x7f7f4f);
  tex->SetPixel(1,1,0x858f4f);
  z3d->texture[1]=tex;

  tex=new TEXTURE_Z;
  tex->Create(50,50);
  for (i=0;i<50;i++){
    for (j=0;j<10;j++){
      //tex->SetPixel(j,i,0xffffff);
      tex->SetPixel(i,j,0x7f7f7f);
    }
  }
  z3d->texture[2]=tex;

  //==============================METOHREN'
  OBJECT *mho;
  SHAPE mhs;
  MATRIX mhm;

  LIGHT *mlight=new LIGHT;
  mlight->Set(LIGHT_SPECULAR,0,1L<<3,-1L<<4,0x7f7f7f);
  z3d->scene[7].light[0]=mlight;

  mho=new OBJECT;
  mhs.gnCircle(0,0,150,20,11);
  char   mhpm4[18]={96,6,28,-4,0,0,-116,-45,-1,-1,116,44,0,0,28,-4,0,0};
  mhm.Unpack(mhpm4);

  mho->Loft(36,&mhm,&mhs,LOFT_ENCLOSE);
  mho->color=0xf0017;
  mho->shade=SHADE_GOURAUD;
  mho->translucent=1;
  mho->visible=0;
  z3d->scene[7].object[0]=mho;
  
  z3d->scene[7].object[2]=new OBJECT;
  z3d->scene[7].object[2]->Clone(mho);

  z3d->scene[7].object[4]=new OBJECT;
  z3d->scene[7].object[4]->Clone(mho);

  mho->visible=1;

  z3d->TexturizeObject(TEXTURIZE_SPHERE,7,0,5);

  for (int tt=1;tt<=5;tt+=2){

    DECAL_SPAWNER *mhds=new DECAL_SPAWNER;

    DECAL *mhd=new DECAL;
    mhd->Create(20,20,1);
    mhd->cx=10;
    mhd->cy=10;
    mhd->framedelay=1;
    for (i=0;i<(int)mhd->h;i++)
      for (j=0;j<(int)mhd->w;j++){
        mhd->frame[0][(i*mhd->w+j)].color=0;
        double c=64-0.25*pow(25*sqrt(pow((double)i-mhd->h/2,2)+pow((double)j-mhd->w/2,2)),1.1);
        if (c<0) c=0;
        double cx=c;
        switch (tt){
          case 1:{
            mhd->frame[0][(i*mhd->w+j)].r=cx;
            mhd->frame[0][(i*mhd->w+j)].g=cx/4;
            mhd->frame[0][(i*mhd->w+j)].b=cx/2;
          };break;
          case 3:{
            mhd->frame[0][(i*mhd->w+j)].g=cx;
          };break;
          case 5:{
            mhd->frame[0][(i*mhd->w+j)].r=cx/4;
            mhd->frame[0][(i*mhd->w+j)].g=cx/4;
            mhd->frame[0][(i*mhd->w+j)].b=cx;
          };break;
        }
      }

    mhds->bind_csystem=z3d->scene[7].object[tt-1];
    mhds->decal=mhd;
    mhds->Create(1000);
  
    z3d->scene[7].object[tt]=mhds;
  }

  //  mho->y=172<<16;


 

  //==============================GREETZ

  OBJECT *gro;
  SHAPE grs;
  MATRIX grm;

  LIGHT *glight=new LIGHT;
  glight->Set(LIGHT_SPECULAR,0,1L<<3,-1L<<4,0x1f1f1f);
  z3d->scene[4].light[0]=glight;

  grs.gnCircle(300,0,256,4,4,PI/4);
  grm.MakeEquality();
  
  gro=new OBJECT;
  gro->Loft(1,&grm,&grs,LOFT_COVER);
  gro->color=0x090909;
  gro->translucent=1;
  gro->translucent_doublesided=1;
  
  char grpm1[18]={-96,-96,0,-128,0,0,77,34,-1,-1,-77,-35,0,0,0,-128,0,0};
  grm.Unpack(grpm1);
  gro->Array(5,&grm);
  
  z3d->scene[4].object[1]=gro;

  DECAL *grd=new DECAL;
  DECAL_SPAWNER *grds=new DECAL_SPAWNER;

  grd->Create(20,20,1);
  grd->cx=10;
  grd->cy=10;
  grd->framedelay=1;
  for (i=0;i<(int)grd->h;i++)
    for (j=0;j<(int)grd->w;j++){
      grd->frame[0][(i*grd->w+j)].color=0;
      double c=64-0.25*pow(25*sqrt(pow((double)i-grd->h/2,2)+pow((double)j-grd->w/2,2)),1.1);
      if (c<0) c=0;
      double cx=c;
      grd->frame[0][(i*grd->w+j)].r=cx;
      grd->frame[0][(i*grd->w+j)].g=cx;
      grd->frame[0][(i*grd->w+j)].b=cx;
    }

  grds->bind_csystem=z3d->scene[4].object[1];
  grds->decal=grd;
  grds->killonend=1;
  grds->Create(40000);
  
  z3d->scene[4].object[0]=grds;

  gro=new OBJECT;

  grs.gnCircle(300,0,200,60,2,0);
  char grpm2[18]={-96,-96,28,-4,0,0,-116,-45,-1,-1,116,44,0,0,28,-4,0,0};
  grm.Unpack(grpm2);
  gro->Loft(2,&grm,&grs,LOFT_COVER);
  gro->color=0x1f1f1f;

  char grpm3[18]={-96,-96,6,-1,0,0,79,22,0,0,-79,-23,-1,-1,6,-1,0,0};
  grm.Unpack(grpm3);
  gro->Transform(&grm);

  grm.Unpack(grpm1);
  gro->Array(5,&grm);

  gro->y=-172L<<16;
  gro->shade=SHADE_GOURAUD;
  
  z3d->scene[4].object[2]=gro;

  gro=new OBJECT;
  grs.gnCircle(0,0,110,20,11);
  char   grpm4[18]={96,6,28,-4,0,0,-116,-45,-1,-1,116,44,0,0,28,-4,0,0};
  grm.Unpack(grpm4);

  gro->Loft(36,&grm,&grs,LOFT_ENCLOSE);
  gro->color=0x1f1f1f;
  gro->shade=SHADE_GOURAUD;
  gro->y=172<<16;
  
  z3d->scene[4].object[3]=gro;

  grd=new DECAL;
  grd->Create(20,20,10);
  grd->cx=10;
  grd->cy=10;
  grd->framedelay=1;
  for (f=0;f<grd->framecount;f++){
    for (i=0;i<(int)grd->h;i++)
      for (j=0;j<(int)grd->w;j++){
        grd->frame[f][(i*grd->w+j)].color=0;
        double c=64-0.25*pow(25*sqrt(pow((double)i-grd->h/2,2)+pow((double)j-grd->w/2,2)),1.1);
        if (c<0) c=0;
        double cx=((double)(grd->framecount-f)/grd->framecount)*c;
        grd->frame[f][(i*grd->w+j)].r=cx;
        grd->frame[f][(i*grd->w+j)].g=cx;
        grd->frame[f][(i*grd->w+j)].b=cx;
      }
  }

  grds=new DECAL_SPAWNER;
  
  grds->bind_csystem=new CSYSTEM;
  grds->bind_csystem->y=172L<<16;
  
  grds->decal=grd;
  grds->killonend=1;
  grds->Create(10000);

  grds->Spawn(100L<<16,172L<<16,0);

  z3d->scene[4].object[4]=grds;


//==============================CLOCK
  SHAPE clksh;
  clksh.gnCircle(0,0,10,10,10,0);
  MATRIX clkm;
  char   clkmp[6]={16,0,0,0,100,0};
  clkm.Unpack(clkmp);
  OBJECT *clko=new OBJECT;
  clko->Loft(2,&clkm,&clksh,LOFT_COVER);
  clko->color=0x7f7f00;
  clko->translucent=1;
  clko->translucent_stainglass=1;
  clko->translucent_doublesided=1;

  char   clkmp2[6]={16,0,0,0,-24,3};
  clkm.Unpack(clkmp2);
  clko->Transform(&clkm);

  char   clkmp3[18]={-96,-96,-104,-2,0,0,62,-27,-1,-1,-62,26,0,0,-104,-2,0,0};
  clkm.Unpack(clkmp3);
  clko->Array(59,&clkm);

  z3d->scene[3].object[0]=clko;

  clko=new OBJECT;
  clksh.gnCircle(0,0,1000,60,2,PI/2-0.1047/2);
  char   clkmp5[6]={16,0,0,0,20,0};
  clkm.Unpack(clkmp5);
  clko->Loft(2,&clkm,&clksh,LOFT_COVER);
  //clko->color=0x7f7f00;
  clko->translucent=1;
  clko->translucent_stainglass=1;
  clko->translucent_doublesided=1;

  char   clkmp4[22]={112,6,0,0,0,0,-1,-1,0,0,1,0,-1,-1,0,0,0,0,0,0,-18,2};
  clkm.Unpack(clkmp4);
  clko->Transform(&clkm);

  z3d->scene[3].object[1]=clko;

  clko=new OBJECT;
  clksh.gnCircle(0,0,750,60,2,PI/2-0.1047/2);
  clkm.Unpack(clkmp5);

  clko->Loft(2,&clkm,&clksh,LOFT_COVER);
  //clko->color=0x7f7f00;
  clko->translucent=1;
  clko->translucent_stainglass=1;
  clko->translucent_doublesided=1;

  clkm.Unpack(clkmp4);
  clko->Transform(&clkm);

  clko->y=-20L<<16;
  clko->ay=64L<<8;

  z3d->scene[3].object[2]=clko;

  DECAL *clkd=new DECAL;
  DECAL_SPAWNER *clkds=new DECAL_SPAWNER;

  clkd->Create(200,200,10);
  clkd->cx=100;
  clkd->cy=100;
  clkd->framedelay=1;
  for (f=0;f<clkd->framecount;f++){
    for (i=0;i<(int)clkd->h;i++)
      for (j=0;j<(int)clkd->w;j++){
        clkd->frame[f][(i*clkd->w+j)].color=0;
        double c=255-pow(2*sqrt(pow((double)i-clkd->h/2,2)+pow((double)j-clkd->w/2,2)),1.1);
        if (c<0) c=0;
        double cx=((double)(clkd->framecount-f)/clkd->framecount)*c;
        clkd->frame[f][(i*clkd->w+j)].r=cx;
        clkd->frame[f][(i*clkd->w+j)].g=cx;
      }
  }

  clkds->bind_csystem=new CSYSTEM;
  clkds->decal=clkd;
  clkds->killonend=1;
  clkds->Create(1000);
  
  z3d->scene[3].object[3]=clkds;

  clko=new OBJECT;

  clksh.gnCircle(0,0,20,10,10,0);
  char   clkmp6[6]={16,0,0,0,-24,3}; //tr 0 0 1000
  clkm.Unpack(clkmp6);
  clko->Loft(2,&clkm,&clksh,LOFT_COVER);
  char   clkmp7[18]={96,6,0,0,0,0,1,0,-1,-1,-1,-1,0,0,0,0,0,0};//rx90
  clkm.Unpack(clkmp7);
  clko->Transform(&clkm);
  clko->translucent=1;
  clko->translucent_stainglass=1;
  clko->translucent_doublesided=1;

  z3d->scene[3].object[4]=clko;

  clko=new OBJECT;
  clko->Clone(z3d->scene[3].object[4]);
  clko->y=-1000L<<16;
  clko->z=-390L<<16;
  clko->x=390L<<16;
  //clko->color=0x7f7f00;
  z3d->scene[3].object[10]=clko;

  clko=new OBJECT;

  clksh.gnCircle(0,0,300,50,50,0);
  char   clkshmp1[14]={32,-124,-52,-52,0,0,-52,-52,0,0,-52,-52,0,0};
  clkm.Unpack(clkshmp1);
  clksh.Transform(&clkm,2);
  char   clkmp8[6]={16,0,0,0,50,0}; //tr 0 0 50
  clkm.Unpack(clkmp8);
  clko->Loft(2,&clkm,&clksh,LOFT_COVER);
  char   clkmp9[22]={96,7,0,0,0,0,1,0,-1,-1,-24,3,24,-4,-1,-1,0,0,0,0,0,0};
  clkm.Unpack(clkmp9);
  clko->Transform(&clkm);
  //clko->color=0x7f7f00;
  clko->translucent=1;
  clko->translucent_stainglass=1;
  clko->translucent_doublesided=1;

  z3d->scene[3].object[5]=clko;

  clko=new OBJECT;
  clko->Clone(z3d->scene[3].object[5]);
  clko->z=550L<<16;
  clko->ay=1200;

  z3d->scene[3].object[6]=clko;

  clko=new OBJECT;
  clko->Clone(z3d->scene[3].object[5]);
  clko->z=-390L<<16;
  clko->x=390L<<16;
  clko->ay=500;
  char clkmp11[10]={0,5,0,0,5,0,0,0,-96,15};
  clkm.Unpack(&clkmp11);
  clko->Transform(&clkm);

  z3d->scene[3].object[7]=clko;

  clko=new OBJECT;
  clko->Clone(z3d->scene[3].object[5]);
  clko->translucent_doublesided=0;
  clko->z=550L<<16;
  char clkmp10[18]={32,-123,0,-128,0,0,0,0,4,0,0,0,-128,12,0,-128,0,0};
  clkm.Unpack(&clkmp10);
  clko->Transform(&clkm);

  z3d->scene[3].object[8]=clko;

  clko=new OBJECT;
  clko->Clone(z3d->scene[3].object[8]);
  clko->z=355L<<16;
  clko->x=195L<<16;
  clko->ay=500;
  z3d->scene[3].object[9]=clko;

  clko=new OBJECT;
  clksh.gnCircle(20,0,20,2,2,PI/2);
  char clkmp12[18]={-96,-96,-31,-2,0,0,15,-45,-1,-1,-15,44,0,0,-31,-2,0,0};
  clkm.Unpack(clkmp12);
  clko->Loft(400,&clkm,&clksh,LOFT_COVER);
  clko->translucent=1;
  clko->translucent_doublesided=1;
  clko->translucent_stainglass=1;
  //clko->color=0x7f7f00;
  clko->z=-390L<<16;
  clko->y=-2000L<<16;
  clko->x=390L<<16;
  z3d->scene[3].object[11]=clko;


  //==============================BUBBLES
  bubble=new DECAL;
  bubble->Create(10,10,1);
  for (i=0;i<bubble->h;i++){
    for (j=0;j<bubble->w;j++){
      uint crdn=i*bubble->w+j;
      bubble->frame[0][crdn].r=
      bubble->frame[0][crdn].g=
      bubble->frame[0][crdn].b=bubble_pic[i*10+j];
    }
  }
  
  BUBBLE_SPAWNER *bs;
  z3d->scene[1].object[0]=new BUBBLE_SPAWNER;
  bs=(BUBBLE_SPAWNER *)z3d->scene[1].object[0];
  bs->bind_csystem=bs;
  bs->bind_csystem->y=770L<<16;
  bs->bind_csystem->z=145L<<16;
  bs->decal=bubble;
  bs->Create(200);

  z3d->scene[1].object[1]=new BUBBLE_SPAWNER;
  bs=(BUBBLE_SPAWNER *)z3d->scene[1].object[1];
  bs->bind_csystem=bs;
  bs->bind_csystem->y=770L<<16;
  bs->bind_csystem->x=-140L<<16;
  bs->bind_csystem->z=-65L<<16;
  bs->decal=bubble;
  bs->Create(200);

  z3d->scene[1].object[2]=new BUBBLE_SPAWNER;
  bs=(BUBBLE_SPAWNER *)z3d->scene[1].object[2];
  bs->bind_csystem=bs;
  bs->bind_csystem->y=770L<<16;
  bs->bind_csystem->x=100L<<16;
  bs->bind_csystem->z=-50L<<16;

  bs->decal=bubble;
  bs->Create(100);

  z3d->scene[1].object[7]=new BUBBLE_SPAWNER;
  bs=(BUBBLE_SPAWNER *)z3d->scene[1].object[7];
  bs->bind_csystem=bs;
//  bs->bind_csystem->y=-400L<<16;
//  bs->bind_csystem->x=90L<<16;
//  bs->bind_csystem->z=-100L<<16;
  bs->bind_csystem->az=-64L<<8;
  bs->end_y=130L<<16;
  bs->decal=bubble;
  bs->Create(200);

  z3d->scene[1].object[13]=new BUBBLE_SPAWNER;
  bs=(BUBBLE_SPAWNER *)z3d->scene[1].object[13];
  bs->bind_csystem=bs;
  bs->bind_csystem->y=-1000L<<16;
  bs->end_y=2000L<<16;
  bs->decal=bubble;
  bs->Create(200);

//========================================BUILDINGS
  SHAPE bshape;
  bshape.gnCircle(0,0,30,4,4,PI/4);
  char   bmtr1[6]={16,0,0,0,-24,3};
  char   bmtr2[30]={112,23,0,0,-6,0,0,0,0,0,1,0,-1,-1,-106,0,106,-1,-1,-1,0,0,0,0,0,0,0,0,-120,19};
  char   bmtr3[6]={0,16,0,0,-100,-1};
  char   bmtr4[6]={16,0,0,0,100,0};
  MATRIX bmtr;
  bmtr.Unpack(bmtr1);
  OBJECT *bobj;
  bobj=new OBJECT;
  bobj->Loft(2,&bmtr,&bshape,LOFT_COVER);
  
  bmtr.Unpack(bmtr2);
  bobj->Transform(&bmtr);
  
  bobj->shade=SHADE_FLAT;


  bmtr.Unpack(bmtr3);
  bobj->Array(5,&bmtr);

  bmtr.Unpack(bmtr4);
  bobj->Array(5,&bmtr);

//  bobj->color=0x101010;

  //bobj->translucent=0;
  bobj->translucent_doublesided=1;

  z3d->scene[2].object[0]=bobj;
 
  z3d->TexturizeObject(TEXTURIZE_CYLINDER,2,0,2);
 
  LIGHT *blight=new LIGHT;
  blight->Set(LIGHT_AMBIENT,0,0,0,0);
  z3d->scene[2].light[0]=blight;
  blight=new LIGHT;
  blight->Set(LIGHT_SPECULAR,0,1L<<3,1L<<4,0);
  z3d->scene[2].light[1]=blight;
  blight=new LIGHT;
  //blight->Set(LIGHT_SPECULAR,1L<<3,0,-1L<<4,0);
  //z3d->scene[2].light[2]=blight;
//========================================MEDUSA
  SHAPE shape;
  shape.gnCircle(0,0,100,20,11);
  char   mtr[18]={96,6,28,-4,0,0,-116,-45,-1,-1,116,44,0,0,28,-4,0,0};
  MATRIX mmtr;
  mmtr.Unpack(mtr);
  OBJECT *obj;
  obj=new OBJECT;
  obj->Loft(19,&mmtr,&shape,0);
  obj->translucent=1;
  obj->ay=(-64)<<8;
  obj->color=0x303030;
  obj->shade=SHADE_SOLID;
  z3d->scene[1].object[3]=obj;
  char   mtr2[18]={48,-124,51,-77,0,0,51,-77,0,0,-52,76,1,0,0,0,-45,-1};
  mmtr.Unpack(mtr2);
  obj=new OBJECT;
  obj->Clone(z3d->scene[1].object[3]);
  obj->Transform(&mmtr);
  z3d->scene[1].object[4]=obj;

  obj=new OBJECT;
  obj->Clone(z3d->scene[1].object[4]);

  obj->Transform(&mmtr);
  z3d->scene[1].object[5]=obj;

  z3d->scene[1].object[3]->z=400L<<16;
  z3d->scene[1].object[4]->z=400L<<16;
  z3d->scene[1].object[5]->z=400L<<16;
  z3d->scene[1].object[7]->z=400L<<16;

  z3d->scene[1].object[3]->x=400L<<16;
  z3d->scene[1].object[4]->x=400L<<16;
  z3d->scene[1].object[5]->x=400L<<16;
  z3d->scene[1].object[7]->x=460L<<16;

  z3d->scene[1].object[3]->y=-200L<<16;
  z3d->scene[1].object[4]->y=-200L<<16;
  z3d->scene[1].object[5]->y=-200L<<16;
  z3d->scene[1].object[7]->y=-200L<<16;

  LIGHT *light=new LIGHT;
  light->Set(LIGHT_AMBIENT,0,0,0,0x2f2f2f);
  z3d->scene[1].light[0]=light;
  light=new LIGHT;
  light->Set(LIGHT_SPECULAR,0,1L<<4,0,0x5f5f5f);
  z3d->scene[1].light[1]=light;

  SHAPE shape2;
  shape2.gnCircle(0,0,12,5,5);
  char   mtr3[14]={16,-124,0,-128,0,0,0,-128,0,0,0,0,60,0};

  mmtr.Unpack(mtr3);
  obj=new OBJECT;
  obj->Loft(2,&mmtr,&shape2,LOFT_COVER);

  char   mtr4[6]={16,0,0,0,100,0};
  mmtr.Unpack(mtr4);
  obj->Transform(&mmtr);
  char   mtr5[18]={96,6,4,-75,0,0,4,-75,0,0,-4,74,-1,-1,4,-75,0,0};
  mmtr.Unpack(mtr5);
  obj->Array(6,&mmtr);

  char   mtr8[18]={96,6,4,-75,0,0,-4,74,-1,-1,4,-75,0,0,4,-75,0,0};
  mmtr.Unpack(mtr8);
  obj->Transform(&mmtr);

  char   mtr7[18]={-96,-96,4,-75,0,0,-4,74,-1,-1,4,-75,0,0,4,-75,0,0};
  mmtr.Unpack(mtr7);
  obj->Array(3,&mmtr);
  obj->Cleanup();
  obj->y=800L<<16;
  z3d->scene[1].object[6]=obj;

  SHAPE shape3;
  shape3.gnCircle(0,0,110,20,11);
  char   mtr9[18]={96,6,28,-4,0,0,-116,-45,-1,-1,116,44,0,0,28,-4,0,0};
  mmtr.Unpack(mtr9);

  obj=new OBJECT;
  obj->Loft(36,&mmtr,&shape3,LOFT_ENCLOSE);
  *z3d->scene[1].object[6]+=*obj;
  z3d->scene[1].object[6]->Cleanup();

  z3d->TexturizeObject(TEXTURIZE_PLANAR,1,3,0);
  z3d->TexturizeObject(TEXTURIZE_PLANAR,1,4,0);
  z3d->TexturizeObject(TEXTURIZE_CYLINDER,1,5,0);
  z3d->TexturizeObject(TEXTURIZE_SPHERE,1,6,1);

  strcat(decr,".");
  decrframe++;
  mainVD->Clear();
  tmpf->PutsToSurface(0,0,decr,mainVD->GetBackBuffer(),&mainVD->rect,decrframe);
  mainVD->Show();

//==========================================MORE BOMBS
  for (i=8;i<8+5;i++){
    z3d->scene[1].object[i]=new OBJECT;
    z3d->scene[1].object[i]->Clone(z3d->scene[1].object[6]);
    z3d->scene[1].object[i]->y=((i-8)*200L<<16)+(2700L<<16);
    z3d->scene[1].object[i]->x=((long)(sin(i+1)*cos(i+1)*500L)<<16);
    z3d->scene[1].object[i]->z=((long)(sin(i+1)*500L)<<16);
  }
  
  z3d->scene[0].object[0]=new OBJECT;


//===========================================DECALS  (LOGO)
  decal=new DECAL;
  DECAL *decal2=new DECAL;
  DECAL_SPAWNER *ds=new DECAL_SPAWNER;

  decal->Create(50,50,40);
  decal->framedelay=1;
 
  decal->frame[0][(decal->w*(decal->h/2)+(decal->w/2))].color=0x112288;

  for (f=1;f<=decal->framecount>>1;f++)
    for (i=2;i<decal->h-2;i++)
      for (j=2;j<decal->w-2;j++)
        for(ii=0;ii<3;ii++) {
          ic  = decal->frame[f-1][(i*decal->w+j)].color_index[ii]<<2;
          ic += decal->frame[f-1][(i*decal->w+j+1)].color_index[ii];
          ic += decal->frame[f-1][(i*decal->w+j-1)].color_index[ii];
          ic += decal->frame[f-1][((i+1)*decal->w+j)].color_index[ii];
          ic += decal->frame[f-1][((i-1)*decal->w+j)].color_index[ii];

          ic += decal->frame[f-1][((i-1)*decal->w+j-1)].color_index[ii];
          ic += decal->frame[f-1][((i-1)*decal->w+j+1)].color_index[ii];
          ic += decal->frame[f-1][((i+1)*decal->w+j+1)].color_index[ii];
          ic += decal->frame[f-1][((i+1)*decal->w+j-1)].color_index[ii];

          ic /= 6;
          if(ic>255)
            ic = 255;
          decal->frame[f][(i*decal->w+j)].color_index[ii]= ic;
          decal->frame[decal->framecount-f][(i*decal->w+j)].color_index[ii] = ic;
        }

  decal2->Create(20,20,48);
  decal2->framedelay=1;
  for (f=0;f<decal2->framecount;f++){
    for (i=0;i<(int)decal2->h;i++)
      for (j=0;j<(int)decal2->w;j++){
        decal2->frame[f][(i*decal2->w+j)].color=0;
        double c=255-pow(25*sqrt(pow((double)i-decal2->h/2,2)+pow((double)j-decal2->w/2,2)),1.1);
        if (c<0) c=0;
        double cx=((double)(decal2->framecount-f)/decal2->framecount)*c;
        decal2->frame[f][(i*decal2->w+j)].g=cx;
      }
  }

  blobcs=new CSYSTEM;
  ds->bind_csystem=blobcs;
  ds->decal=decal;
  ds->killonend=0;
  ds->Create(200);
  z3d->scene[0].object[1]=ds;

  for (int d=0;d<10;d++){
    DECAL_SPAWNER *ds2=new DECAL_SPAWNER;
    ds2->bind_csystem=blobcs;
    ds2->decal=decal2;
    ds2->killonend=1;
    ds2->Create(1000);
    z3d->scene[0].object[d+2]=ds2;
    
    for (i=0;i<64;i++){
      for (int j=0;j<8;j++){
        for (int f=0;f<8;f++){
          if ((bitmap[(i<<3)+j]&(1L<<f))!=0){
            if (((j<<3)+f)%(10-d)==0&&i%(10-d)==0)
              ((DECAL_SPAWNER *)z3d->scene[0].object[d+2])->Spawn(
                         -(long)(((j<<3)+f)<<19)+(64L<<18),
                         -(long)(i<<19)+(64L<<18),0);
              z3d->scene[0].object[d+2]->visible=0;
          }
        }
      }
    }
  }
  strcat(decr,".");
  decrframe++;
  mainVD->Clear();
  tmpf->PutsToSurface(0,0,decr,mainVD->GetBackBuffer(),&mainVD->rect,decrframe);
  mainVD->Show();
  delete tmpf;

//=====================================================OBJECTS DONE
  UINT timer_event_id;
  MSG							msg;
  if (soundfreq){
    SoundStart(MAKEINTRESOURCE(MUSIC));
    SoundPlay();
  }
  else{
    UINT timer_res_id=timeBeginPeriod(22);
    timer_event_id=timeSetEvent(22,22,&TimeProc,0,TIME_PERIODIC);
  }
	
  needframes=0;
  do {
    if(PeekMessage(&msg, NULL, 0, 0, PM_NOREMOVE)) {
			if(GetMessage(&msg, NULL, 0, 0)) {
				TranslateMessage(&msg);
				DispatchMessage(&msg);
			}
		}
    if (needframes){
      TimeLine();
    }
  } while(msg.message != WM_QUIT && !Finished);
  
  timeKillEvent(timer_event_id);
  timeEndPeriod(22);
  SoundStop();
  delete z3d;
  mainVD->Destroy();
  return 0;
}

void __cdecl main();
void __cdecl main(){

};

extern "C" int __cdecl _heap_init(int);

void EntryPoint(){
  if (_heap_init(0)){
    WinMain(GetModuleHandle(NULL),NULL,NULL,1);
  }
  ExitProcess(0);
};

//===========================================
//TIMELINE & SCENES
//===========================================

#define TL_SC1 TL_PR(14,0)          //"KCN" logo scene start frame (14)
#define TL_SC1_LEN TL_PR(5,0)

#define TL_SC2 TL_PR(0,0)           //"Medusa" start frame (0)
#define TL_SC2_LEN TL_PR(14,0)

#define TL_SC3 TL_PR(43,0)       //buildings scene (43)
#define TL_SC3_LEN TL_PR(11,0)

#define TL_SC4 TL_PR(19,0)    //clock scene (19)
#define TL_SC4_LEN TL_PR(24,0)

#define TL_SC5 TL_PR(62,0)    //greetz scene (54)
#define TL_SC5_LEN TL_PR(14,0)

#define TL_SC7 TL_PR(54,0)    //metahren' scene
#define TL_SC7_LEN TL_PR(8,0)

#define TL_EXIT TL_SC5+TL_SC5_LEN    //exit frame

//===========================================
void TimeLine(){

  int ndfrms=needframes;
  int isbreaked;
  uint ii;
#ifdef _DEBUG
  if (!pause){
#endif
  //TRANSFORMATIONS
  while (needframes>0){  
    //========================================================SC7 PART (METAHREN')
    if (currentframe>=TL_SC7&&currentframe<TL_SC7+TL_SC7_LEN){
      OBJECT *obj;
      obj=z3d->scene[7].object[0];
      obj->ax+=1L<<5;
      obj->ay+=1L<<6;
      obj->az-=1L<<5;

      obj=z3d->scene[7].object[2];
      obj->ax-=1L<<6;
      obj->ay+=1L<<5;
      obj->az+=1L<<5;

      obj=z3d->scene[7].object[4];
      obj->ax+=1L<<5;
      obj->ay-=1L<<5;
      obj->az+=1L<<6;

      if (currentframe%TL_R(4)==0){
        for (i=0;i<obj->vertexcount;i++){
          obj=z3d->scene[7].object[0];
          ((DECAL_SPAWNER*)z3d->scene[7].object[1])->Spawn(obj->vertex[i].x,
                                                           obj->vertex[i].y,
                                                           obj->vertex[i].z);

          obj=z3d->scene[7].object[2];
          ((DECAL_SPAWNER*)z3d->scene[7].object[3])->Spawn(obj->vertex[i].x,
                                                           obj->vertex[i].y,
                                                           obj->vertex[i].z);

          obj=z3d->scene[7].object[4];
          ((DECAL_SPAWNER*)z3d->scene[7].object[5])->Spawn(obj->vertex[i].x,
                                                           obj->vertex[i].y,
                                                           obj->vertex[i].z);
        } 
      }
      if (currentframe%TL_R(2)==0){
        for (int tt=1;tt<=5;tt+=2){
          DECAL_SPAWNER *ds=(DECAL_SPAWNER *)z3d->scene[7].object[tt];
          for (i=0;i<ds->spawncount;i++){
            if (ds->present[i]){
              double koeff;
              switch (tt){
                case 1: koeff=1.01;break;
                case 3: koeff=1.005;break;
                case 5: koeff=1.001;
              }
              ds->spawnpoint[i].x*=koeff;
              ds->spawnpoint[i].y*=koeff;
              ds->spawnpoint[i].z*=koeff;
            }
          }
        }
      }

    }

    //========================================================SC5 PART (GREETZ)
    if (currentframe>=TL_SC5&&currentframe<TL_SC5+TL_SC5_LEN){
      if (currentframe%TL_R(1)==0){
        for (i=0;i<6;i++){
          long x,z;
          double R=(600L<<16)/RAND_MAX*rand();
          if (R<(100L<<16)) R=100L<<16;
          if (R>(480L<<16)) R=480L<<16;
        
          x=R*cos(PI/3*i);
          z=R*sin(PI/3*i);

          ((DECAL_SPAWNER *)z3d->scene[4].object[0])->Spawn(x,-172L<<16,z);
        }
      }
      for (i=0;i<((DECAL_SPAWNER *)z3d->scene[4].object[0])->spawncount;i++){
        if (((DECAL_SPAWNER *)z3d->scene[4].object[0])->present[i]){
          ((DECAL_SPAWNER *)z3d->scene[4].object[0])->spawnpoint[i].y+=1L<<15;
        }
      }
      z3d->scene[4].object[1]->ay-=2L<<3;
      z3d->scene[4].object[2]->ay-=2L<<3;

      z3d->scene[4].object[3]->ay-=2L<<8;
      z3d->scene[4].object[3]->ax+=2L<<8;
      z3d->scene[4].object[3]->az-=1L<<8;

      CSYSTEM *csystem=z3d->scene[4].object[3];
      VECTOR vec;

      #define SPAWN_DISTANCE 120L<<16

      vec.x=SPAWN_DISTANCE;
      vec.y=0;
      vec.z=0;
      ((DECAL_SPAWNER *)z3d->scene[4].object[4])->Spawn(csystem,vec);

      vec.x=0;
      vec.y=SPAWN_DISTANCE;
      vec.z=0;
      ((DECAL_SPAWNER *)z3d->scene[4].object[4])->Spawn(csystem,vec);

      vec.x=0;
      vec.y=0;
      vec.z=SPAWN_DISTANCE;
      ((DECAL_SPAWNER *)z3d->scene[4].object[4])->Spawn(csystem,vec);

      vec.x=-SPAWN_DISTANCE;
      vec.y=0;
      vec.z=0;
      ((DECAL_SPAWNER *)z3d->scene[4].object[4])->Spawn(csystem,vec);

      vec.x=0;
      vec.y=-SPAWN_DISTANCE;
      vec.z=0;
      ((DECAL_SPAWNER *)z3d->scene[4].object[4])->Spawn(csystem,vec);

      vec.x=0;
      vec.y=0;
      vec.z=-SPAWN_DISTANCE;
      ((DECAL_SPAWNER *)z3d->scene[4].object[4])->Spawn(csystem,vec);



      ((DECAL_SPAWNER *)z3d->scene[4].object[4])->Play();

      z3d->scene[4].camera[0]->z-=1L<<16;
      z3d->scene[4].camera[0]->y+=1L<<13;
    }
    //========================================================SC2 PART (MEDUSA)
    if (currentframe>=TL_SC2&&currentframe<TL_SC2+TL_SC2_LEN){
      z3d->scene[1].object[6]->y-=(1L<<17);
      z3d->scene[1].object[6]->ay+=(1L<<7);
      for (i=8;i<8+5;i++){
        z3d->scene[1].object[i]->y-=(1L<<17);
        z3d->scene[1].object[i]->ay+=((i-10)<<6);
      }
      if (currentframe%TL_R(1)==0){
        for(ii=0;ii<3;ii++) {
          if (currentframe<TL_PR(5,0)+TL_SC2){
          ((BUBBLE_SPAWNER *)z3d->scene[1].object[ii])->Spawn();
          }
          ((BUBBLE_SPAWNER *)z3d->scene[1].object[ii])->Play();
        }
        ((BUBBLE_SPAWNER *)z3d->scene[1].object[7])->Play();
        ((BUBBLE_SPAWNER *)z3d->scene[1].object[13])->Play();
      }
      if (currentframe%TL_R(16)==0)
        ((BUBBLE_SPAWNER *)z3d->scene[1].object[13])->Spawn();

      MATRIX med1,med2;
      char   medt1[14]={32,-124,-60,0,1,0,-60,0,1,0,59,-1,0,0};
      med1.Unpack(medt1);
      char   medt2[14]={32,-124,59,-1,0,0,59,-1,0,0,-60,0,1,0};
      med2.Unpack(medt2);

      uint cfr=currentframe%TL_R(64);
    
      z3d->scene[1].object[0]->y-=1L<<17;
      z3d->scene[1].object[1]->y-=1L<<17;
      z3d->scene[1].object[2]->y-=1L<<17;
      if (currentframe>TL_PR(8,0)+TL_SC2&&
          currentframe<TL_PR(12,0)+TL_SC2&&
          (currentframe%TL_R(32)==TL_R(0)||
           currentframe%TL_R(32)==TL_R(12))){
        z3d->scene[1].camera[0]->az-=5L<<8;
      }
  
      if (cfr<TL_R(32)){
        z3d->scene[1].object[3]->Transform(&med1);
        if (cfr&1) *(COLOR *)z3d->scene[1].object[3]-=COLOR(0x010101);
        z3d->scene[1].object[3]->x-=1L<<14;
        z3d->scene[1].object[4]->x-=1L<<14;
        z3d->scene[1].object[5]->x-=1L<<14;
        z3d->scene[1].object[7]->x-=1L<<14;
      }
      else {
        z3d->scene[1].object[3]->Transform(&med2);
        if (cfr&1) *(COLOR *)z3d->scene[1].object[3]+=COLOR(0x010101);
        z3d->scene[1].object[3]->x-=1L<<15;
        z3d->scene[1].object[4]->x-=1L<<15;
        z3d->scene[1].object[5]->x-=1L<<15;
        z3d->scene[1].object[7]->x-=1L<<15;
      }

      if (cfr>TL_R(8)&&cfr<TL_R(40)){
        z3d->scene[1].object[4]->Transform(&med1);
        if (cfr&1) *(COLOR *)z3d->scene[1].object[4]-=COLOR(0x010101);
      }
      else {
        z3d->scene[1].object[4]->Transform(&med2);
        if (cfr&1) *(COLOR *)z3d->scene[1].object[4]+=COLOR(0x010101);
        z3d->scene[1].object[3]->x-=1L<<15;
        z3d->scene[1].object[4]->x-=1L<<15;
        z3d->scene[1].object[5]->x-=1L<<15;
        z3d->scene[1].object[7]->x-=1L<<15;
        ((BUBBLE_SPAWNER *)z3d->scene[1].object[7])->Spawn();
      }

      if (cfr>TL_R(16)&&cfr<TL_R(48)){
        z3d->scene[1].object[5]->Transform(&med1);
        if (cfr&1) *z3d->scene[1].object[5]-=COLOR(0x010101);
      }
      else {
        z3d->scene[1].object[5]->Transform(&med2);
        if (cfr&1) *(COLOR *)z3d->scene[1].object[5]+=COLOR(0x010101);
        z3d->scene[1].object[3]->x-=1L<<15;
        z3d->scene[1].object[4]->x-=1L<<15;
        z3d->scene[1].object[5]->x-=1L<<15;
        z3d->scene[1].object[7]->x-=1L<<15;
      }
      if (currentframe%TL_R(2)==0){
        MATRIX mtr;
        char   mtrx[18]={-96,-96,-10,-1,0,0,-119,-5,-1,-1,119,4,0,0,-10,-1,0,0};
        mtr.Unpack(mtrx);
        *(VECTOR*)z3d->scene[1].object[0]*=mtr;
        *(VECTOR*)z3d->scene[1].object[1]*=mtr;
        *(VECTOR*)z3d->scene[1].object[2]*=mtr;
        z3d->scene[1].camera[0]->az+=1L<<6;
        z3d->scene[1].camera[0]->ax+=1L<<5;
        z3d->scene[1].camera[0]->z+=1L<<14;
      }
    }  
    //========================================================SC1 PART (LOGO)
    if (currentframe>=TL_SC1&&currentframe<TL_SC1+TL_SC1_LEN){
      
      int d=(currentframe-TL_SC1)/48;
      if (d<10){
        if (currentframe<TL_PR(2,32)+TL_SC1&&
          (
          currentframe%TL_R(32)==TL_R(14)||
          currentframe%TL_R(32)==TL_R(20)//||
          )){
          for (i=0;i<10;i++)
            z3d->scene[0].object[i+2]->visible=(i==d);
        }
      }
      if (d<9){
        if ((currentframe&3)==0)
          ((DECAL_SPAWNER*)z3d->scene[0].object[d+2])->Play();
      }
      if (currentframe>TL_PR(4,32)+TL_SC1)
        ((DECAL_SPAWNER*)z3d->scene[0].object[11])->Play();

      blobcs->az+=0x80;
      blobcs->ay+=0x80;

      if (currentframe==TL_PR(3,32)+TL_SC1){
        ((DECAL_SPAWNER*)z3d->scene[0].object[1])->killonend=1;
        ((DECAL_SPAWNER*)z3d->scene[0].object[1])->Modulo();
      }

      if (currentframe>TL_PR(2,32)+TL_SC1){
        z3d->scene[0].camera[0]->z-=(currentframe-TL_SC1-TL_PR(2,32))<<10;
      }

      if ((currentframe&3)==0){

        z3d->scene[0].object[0]->ax+=5<<8;
        z3d->scene[0].object[0]->ay+=5<<8;
        z3d->scene[0].object[0]->az+=5<<8;

        ((DECAL_SPAWNER*)z3d->scene[0].object[1])->Play();
        if (currentframe<TL_PR(3,32)+TL_SC1){
          VECTOR v1;
          v1.x=200L<<16;
          v1.y=0;
          v1.z=0;
          ((DECAL_SPAWNER*)z3d->scene[0].object[1])->Spawn(z3d->scene[0].object[0],v1);
          v1.x=0;
          v1.z=200L<<16;
          ((DECAL_SPAWNER*)z3d->scene[0].object[1])->Spawn(z3d->scene[0].object[0],v1);
          v1.x=-200L<<16;
          v1.y=0;
          v1.z=0;
          ((DECAL_SPAWNER*)z3d->scene[0].object[1])->Spawn(z3d->scene[0].object[0],v1);
          v1.z=-200L<<16;
          v1.y=0;
          v1.x=0;
          ((DECAL_SPAWNER*)z3d->scene[0].object[1])->Spawn(z3d->scene[0].object[0],v1);
        }
      }
    }
    
    //========================================================SC3 PART (buildings)
    if (currentframe>=TL_SC3&&currentframe<TL_SC3+TL_SC3_LEN){
      if (currentframe<TL_SC3+TL_PR(2,0))
        z3d->scene[2].camera[0]->dusk+=128;
      
      if (currentframe>=TL_SC3+TL_PR(7,0)){
        z3d->scene[2].camera[0]->dusk-=64;
        if (z3d->scene[2].camera[0]->dusk<0)
          z3d->scene[2].camera[0]->dusk=0;
      }

      if (currentframe<TL_SC3+TL_PR(2,0)&&currentframe%TL_R(6)==0){
        z3d->scene[2].light[0]->color+=0x010101;
        z3d->scene[2].light[1]->color+=0x010101;
      }
      if (currentframe>=TL_SC3+TL_PR(5,0)&&currentframe<TL_SC3+TL_PR(6,0)){
        int local=currentframe-TL_SC3-TL_PR(5,0);
        if (local==TL_R(0)||local==TL_R(14)||local==TL_R(20)||
            local==TL_R(32)||local==TL_R(46)||local==TL_R(52)){
          z3d->scene[2].object[0]->translucent=1;
        }
        if (local==TL_R(0)+1||local==TL_R(14)+1||local==TL_R(20)+1||
            local==TL_R(32)+1||local==TL_R(46)+1)
          z3d->scene[2].object[0]->translucent=0;
      }

      if (currentframe>=TL_SC3+TL_PR(6,0)&&currentframe<TL_SC3+TL_PR(7,0)){
        *(COLOR *)z3d->scene[2].light[0]%=COLOR(0x010101);
        *(COLOR *)z3d->scene[2].light[1]%=COLOR(0x010101);
      }
      if (currentframe>=TL_SC3+TL_PR(7,0)){
        *(COLOR *)z3d->scene[2].light[1]-=COLOR(0x010000);
      }

      if (currentframe<TL_SC3+TL_PR(5,0)){
        z3d->scene[2].camera[0]->ax+=1L<<4;
      }
      else {
        z3d->scene[2].camera[0]->y+=1L<<16;
        z3d->scene[2].camera[0]->ax+=1L<<3;
        z3d->scene[2].camera[0]->az+=1L<<4;
      }
    }
    //========================================================SC4 PART (CLOCK)
    if (currentframe>=TL_SC4&&currentframe<TL_SC4+TL_SC4_LEN){
      z3d->scene[3].object[2]->ay-=10L<<3;
      z3d->scene[3].object[1]->ay-=60L<<4;
      z3d->scene[3].object[4]->ay-=10L<<4;

      z3d->scene[3].object[5]->ay-=10L<<4;
      z3d->scene[3].object[6]->ay+=10L<<4;
      z3d->scene[3].object[7]->ay+=10L<<4;
      z3d->scene[3].object[10]->ay+=10L<<4;

      z3d->scene[3].object[8]->ay+=10L<<4;
      z3d->scene[3].object[9]->ay-=10L<<4;

      z3d->scene[3].camera[0]->az+=1L<<2;
      int localframe=currentframe-TL_SC4;
      if (currentframe%TL_R(2)==0){
        if (localframe<TL_PR(4,0)){
          z3d->scene[3].object[2]->color+=0x010100;
          z3d->scene[3].object[1]->color+=0x010100;
          z3d->scene[3].object[0]->color+=0x010100;
        }
        if (localframe>TL_PR(6,0)&&localframe<TL_PR(10,0)){
          z3d->scene[3].object[4]->color+=0x010100;
        }
        if (localframe>TL_PR(7,0)&&localframe<TL_PR(11,0)){
          z3d->scene[3].object[5]->color+=0x010100;
        }
        if (localframe>TL_PR(8,0)&&localframe<TL_PR(12,0)){
          z3d->scene[3].object[6]->color+=0x010100;
        }
        if (localframe>TL_PR(9,0)&&localframe<TL_PR(13,0)){
          z3d->scene[3].object[7]->color+=0x010100;
        }
        if (localframe>TL_PR(10,0)&&localframe<TL_PR(14,0)){
          z3d->scene[3].object[8]->color+=0x010100;
        }
        if (localframe>TL_PR(11,0)&&localframe<TL_PR(15,0)){
          z3d->scene[3].object[9]->color+=0x010100;
        }
        if (localframe>TL_PR(12,0)&&localframe<TL_PR(16,0)){
          z3d->scene[3].object[10]->color+=0x010100;
        }
        if (localframe>TL_PR(13,0)&&localframe<TL_PR(17,0)){
          z3d->scene[3].object[11]->color+=0x010100;
        }
        if (localframe>TL_PR(19,0)&&localframe<TL_PR(23,0)){
          for (i=0;i<=11;i++)
            z3d->scene[3].object[i]->color-=0x010100;
        }
      }

      if (localframe>=TL_PR(23,0)){
        *((COLOR *)z3d->scene[3].object[0])-=COLOR(0x010100);
      }
        
      VECTOR v1;
      for (i=400L<<16;i<=800L<<16;i+=100L<<16){
        v1.z=i;
        if (localframe<TL_PR(23,0))
          ((DECAL_SPAWNER*)z3d->scene[3].object[3])->Spawn(z3d->scene[3].object[1],v1);
      }
      ((DECAL_SPAWNER*)z3d->scene[3].object[3])->Play();

      z3d->scene[3].camera[0]->y-=1L<<16;
      z3d->scene[3].camera[0]->ax-=1L<<2;
      z3d->scene[3].camera[0]->z-=1L<<16;
    }

    //========================================================EXIT PART
    if (currentframe==TL_EXIT){
      Finished=1;
      return;
    }
    needframes--;
    
    //========================================================BREAK PART
    
    //IF CURRENT FRAME NEEDS TO BE DRAWN - BREAK HERE
    isbreaked=1;
    if (currentframe>TL_SC2&&currentframe<TL_SC2+TL_SC2_LEN){
      if (currentframe>TL_PR(8,0)+TL_SC2&&
          currentframe<TL_PR(12,0)+TL_SC2&&
          (currentframe%TL_R(32)==TL_R(0)||
           currentframe%TL_R(32)==TL_R(12)))
        break;
    }

    if (currentframe>TL_SC1&&currentframe<TL_SC1+TL_PR(2,32)&&
      (
      currentframe%TL_R(32)==TL_R(14)||
      currentframe%TL_R(32)==TL_R(20)
      ))
    break;

    if (currentframe>=TL_SC3+TL_PR(5,0)&&currentframe<TL_SC3+TL_PR(6,0)){
      int local=currentframe-TL_SC3-TL_PR(5,0);
        if (local==TL_R(0)||local==TL_R(14)||local==TL_R(20)||
            local==TL_R(32)||local==TL_R(46)||local==TL_R(52)){
          break;
        }
    }


    isbreaked=0;

    currentframe++;
  } //end of needframes

#ifdef _DEBUG
  } //pause
#endif

  //========================================================RENDER PART
  //===============SC1
  if (currentframe>TL_SC1&&currentframe<TL_SC1+TL_SC1_LEN){
    if (currentframe<TL_PR(2,32)+TL_SC1&&
      (
      currentframe%TL_R(32)==TL_R(14)||
      currentframe%TL_R(32)==TL_R(20)
      ))
      z3d->scene[0].camera[0]->Clear(0xffffff);
    else
      z3d->scene[0].camera[0]->Clear();
    z3d->scene[0].render(0);
  }
  //===============SC2
  if (currentframe>TL_SC2&&currentframe<TL_SC2+TL_SC2_LEN){
    z3d->scene[1].render(0);
  }
  //===============SC7
  if (currentframe>TL_SC7&&currentframe<TL_SC7+TL_SC7_LEN){
    z3d->scene[7].camera[0]->Clear();
    z3d->scene[7].render(0);
  }
  //===============SC3
  if (currentframe>TL_SC3&&currentframe<TL_SC3+TL_SC3_LEN){
    z3d->scene[2].render(0);
  }
  //===============SC4 clock
  if (currentframe>TL_SC4&&currentframe<TL_SC4+TL_SC4_LEN){
    z3d->scene[3].camera[0]->Clear();
    z3d->scene[3].camera[0]->InitAndLock();
    if (z3d->scene[3].camera[0]->data){
      int local=currentframe-TL_SC4;
      for (int j=0;j<z3d->scene[3].camera[0]->width;j++){
        if (local%(j+1)==0){
          for (i=0;i<z3d->scene[3].camera[0]->height;i++){
            char *dt=(char *)z3d->scene[3].camera[0]->data;
            int pitch=z3d->scene[3].camera[0]->pitch;
            dt[i*pitch+j*(bpp==32?4:3)+2]=0x10;
            dt[i*pitch+j*(bpp==32?4:3)+1]=0x10;
          }
        }
      }
    }
    z3d->scene[3].camera[0]->Unlock();
    z3d->scene[3].render(0);
  }
  //===============SC5
  if (currentframe>TL_SC5){
    if (currentframe<TL_SC5+TL_SC5_LEN)
      z3d->scene[4].camera[0]->Clear();
    if (currentframe<TL_SC5+TL_PR(12,0))
      z3d->scene[4].render(0);
  }
  
  
  //========================================================REMOVE PART
  //if (currentframe==TL_SC1+TL_SC1_LEN){
//    z3d->scene[0].Remove();
//  }else
//  if (currentframe==TL_SC2+TL_SC2_LEN){
    //z3d->scene[1].Remove();
  //}  
//  if (currentframe==TL_SC3+TL_SC3_LEN){
//    z3d->scene[3].Remove();
//  }  
//  if (currentframe==TL_SC4+TL_SC4_LEN){
//    z3d->scene[2].Remove();
//  }  

#ifdef CALC_FPS
  char tmp[100];
  itoa(fps,tmp,10);
  //sprintf(tmp,"Fps:%6.2f Nd:%d Cf:%d",fps,ndfrms,currentframe);
  font20ni->PutsToSurface(10,10,tmp,mainVD->GetBackBuffer(),&mainVD->rect,32);
#endif
  
//==================================================TEXT PART
  //=====SC1
  if (currentframe>TL_SC1&&currentframe<TL_SC1+TL_SC1_LEN){
    if (currentframe>TL_SC1+TL_PR(4,0)&&currentframe<TL_SC1+TL_PR(4,32))
      font20white->PutsToSurface(10,400,"code: zZz, Elmm",mainVD->GetBackBuffer(),&mainVD->rect,
        (currentframe-(TL_SC1+TL_PR(4,0)))*2/TL_R(1));

    if (currentframe>TL_SC1+TL_PR(4,16)&&currentframe<TL_SC1+TL_PR(4,48))
      font20white->PutsToSurface(10,430,"muzeek: Ygrek",mainVD->GetBackBuffer(),&mainVD->rect,
        (currentframe-(TL_SC1+TL_PR(4,16)))*2/TL_R(1));
  }
  //=====SC2
  if (currentframe>TL_SC2&&currentframe<TL_SC2+TL_SC2_LEN){
    if (currentframe>TL_SC2+TL_PR(0,0)&&currentframe<TL_SC2+TL_PR(4,0))
      font20->PutsToSurface(10,240,"hydrogen gave birth to wateR",mainVD->GetBackBuffer(),&mainVD->rect,
        (currentframe-(TL_SC2+TL_PR(0,0)))/TL_R(4));

    if (currentframe>TL_SC2+TL_PR(3,0)&&currentframe<TL_SC2+TL_PR(7,0))
      font20->PutsToSurface(30,270,"water gave birth to lifE",mainVD->GetBackBuffer(),&mainVD->rect,
        (currentframe-(TL_SC2+TL_PR(3,0)))/TL_R(4));

    if (currentframe>TL_SC2+TL_PR(5,0)&&currentframe<TL_SC2+TL_PR(13,0))
      font20->PutsToSurface(50,300,"life brought death to hydrogeN",mainVD->GetBackBuffer(),&mainVD->rect,
        (currentframe-(TL_SC2+TL_PR(5,0)))/TL_R(8));

  }
  //=====SC5
  if (currentframe>TL_SC5&&currentframe<TL_SC5+TL_SC5_LEN){
    if (currentframe>TL_SC5+TL_PR(0,0)&&currentframe<TL_SC5+TL_PR(4,0))
      font20grey->PutsToSurface(10,10,"personal greetZ",mainVD->GetBackBuffer(),&mainVD->rect,
        (currentframe-(TL_SC5+TL_PR(0,0)))/TL_R(4));

    if (currentframe>TL_SC5+TL_PR(0,16)&&currentframe<TL_SC5+TL_PR(4,16))
      font20grey->PutsToSurface(10,50,"Adok::Hugi",mainVD->GetBackBuffer(),&mainVD->rect,
        (currentframe-(TL_SC5+TL_PR(0,16)))/TL_R(4));

    if (currentframe>TL_SC5+TL_PR(0,32)&&currentframe<TL_SC5+TL_PR(4,32))
      font20grey->PutsToSurface(10,80,"Sketch Rimanez::secular",mainVD->GetBackBuffer(),&mainVD->rect,
        (currentframe-(TL_SC5+TL_PR(0,32)))/TL_R(4));

    if (currentframe>TL_SC5+TL_PR(0,48)&&currentframe<TL_SC5+TL_PR(4,48))
      font20grey->PutsToSurface(10,110,"LSD",mainVD->GetBackBuffer(),&mainVD->rect,
        (currentframe-(TL_SC5+TL_PR(0,48)))/TL_R(4));

    if (currentframe>TL_SC5+TL_PR(1,0)&&currentframe<TL_SC5+TL_PR(5,0))
      font20grey->PutsToSurface(10,140,"Keen",mainVD->GetBackBuffer(),&mainVD->rect,
        (currentframe-(TL_SC5+TL_PR(1,0)))/TL_R(4));

    if (currentframe>TL_SC5+TL_PR(1,16)&&currentframe<TL_SC5+TL_PR(5,16))
      font20grey->PutsToSurface(10,170,"NIK Haken",mainVD->GetBackBuffer(),&mainVD->rect,
        (currentframe-(TL_SC5+TL_PR(1,16)))/TL_R(4));

    if (currentframe>TL_SC5+TL_PR(1,32)&&currentframe<TL_SC5+TL_PR(5,32))
      font20grey->PutsToSurface(10,200,"Roott",mainVD->GetBackBuffer(),&mainVD->rect,
        (currentframe-(TL_SC5+TL_PR(1,32)))/TL_R(4));

    if (currentframe>TL_SC5+TL_PR(1,48)&&currentframe<TL_SC5+TL_PR(5,48))
      font20grey->PutsToSurface(10,230,"Heaven Aeroplane",mainVD->GetBackBuffer(),&mainVD->rect,
        (currentframe-(TL_SC5+TL_PR(1,48)))/TL_R(4));

    if (currentframe>TL_SC5+TL_PR(2,0)&&currentframe<TL_SC5+TL_PR(6,0))
      font20grey->PutsToSurface(10,260,"StyX::HeadcrasH",mainVD->GetBackBuffer(),&mainVD->rect,
        (currentframe-(TL_SC5+TL_PR(2,0)))/TL_R(4));

    if (currentframe>TL_SC5+TL_PR(2,16)&&currentframe<TL_SC5+TL_PR(6,16))
      font20grey->PutsToSurface(10,290,"COTDT",mainVD->GetBackBuffer(),&mainVD->rect,
        (currentframe-(TL_SC5+TL_PR(2,16)))/TL_R(4));


    if (currentframe>TL_SC5+TL_PR(2,0)&&currentframe<TL_SC5+TL_PR(6,0))
      font20grey->PutsToSurface(400,10,"global greetZ",mainVD->GetBackBuffer(),&mainVD->rect,
        (currentframe-(TL_SC5+TL_PR(2,0)))/TL_R(4));

    if (currentframe>TL_SC5+TL_PR(2,16)&&currentframe<TL_SC5+TL_PR(6,16))
      font20grey->PutsToSurface(400,50,"t-REX",mainVD->GetBackBuffer(),&mainVD->rect,
        (currentframe-(TL_SC5+TL_PR(2,16)))/TL_R(4));

    if (currentframe>TL_SC5+TL_PR(2,32)&&currentframe<TL_SC5+TL_PR(6,32))
      font20grey->PutsToSurface(400,80,"Sands",mainVD->GetBackBuffer(),&mainVD->rect,
        (currentframe-(TL_SC5+TL_PR(2,32)))/TL_R(4));

    if (currentframe>TL_SC5+TL_PR(2,48)&&currentframe<TL_SC5+TL_PR(6,48))
      font20grey->PutsToSurface(400,110,"Proxium",mainVD->GetBackBuffer(),&mainVD->rect,
        (currentframe-(TL_SC5+TL_PR(2,48)))/TL_R(4));

    if (currentframe>TL_SC5+TL_PR(3,0)&&currentframe<TL_SC5+TL_PR(7,0))
      font20grey->PutsToSurface(400,140,"Throb",mainVD->GetBackBuffer(),&mainVD->rect,
        (currentframe-(TL_SC5+TL_PR(3,0)))/TL_R(4));

    if (currentframe>TL_SC5+TL_PR(3,16)&&currentframe<TL_SC5+TL_PR(7,16))
      font20grey->PutsToSurface(400,170,"Psycho",mainVD->GetBackBuffer(),&mainVD->rect,
        (currentframe-(TL_SC5+TL_PR(3,16)))/TL_R(4));

    /*if (currentframe>TL_SC5+TL_PR(3,32)&&currentframe<TL_SC5+TL_PR(7,32))
      font20grey->PutsToSurface(400,200,"???",mainVD->GetBackBuffer(),&mainVD->rect,
        (currentframe-(TL_SC5+TL_PR(3,32)))/TL_R(4));*/

    if (currentframe>TL_SC5+TL_PR(3,48)&&currentframe<TL_SC5+TL_PR(7,48))
      font20grey->PutsToSurface(200,370,"zdes mogla byt vasha reklama ;?",mainVD->GetBackBuffer(),&mainVD->rect,
        (currentframe-(TL_SC5+TL_PR(3,48)))/TL_R(4));

    if (currentframe>TL_SC5+TL_PR(7,0)&&currentframe<TL_SC5+TL_PR(11,0))
      font20grey->PutsToSurface(500,400,"the enD",mainVD->GetBackBuffer(),&mainVD->rect,
        (currentframe-(TL_SC5+TL_PR(7,0)))/TL_R(4));

    if (currentframe>TL_SC5+TL_PR(12,0)&&currentframe<TL_SC5+TL_PR(14,0))
      font20white->PutsToSurface(268,225,"hydrogeN",mainVD->GetBackBuffer(),&mainVD->rect,
        32+(currentframe-(TL_SC5+TL_PR(12,0)))/TL_R(4));

  }
  //=====SC3
  if (currentframe>TL_SC3&&currentframe<TL_SC3+TL_SC3_LEN){
    if (currentframe>TL_SC3+TL_PR(1,0)&&currentframe<TL_SC3+TL_PR(3,0)){
      int local=(currentframe-(TL_SC3+TL_PR(1,0)))/TL_R(2);
      font20white->PutsToSurface(200-local,300-local,"and if we do not stop noW",mainVD->GetBackBuffer(),&mainVD->rect,
        local);
    }
    if (currentframe>TL_SC3+TL_PR(2,0)&&currentframe<TL_SC3+TL_PR(4,0)){
      int local=(currentframe-(TL_SC3+TL_PR(2,0)))/TL_R(2);
      font20white->PutsToSurface(100+local,200+local,"it might be the daY",mainVD->GetBackBuffer(),&mainVD->rect,
        local);
    }
    if (currentframe>TL_SC3+TL_PR(3,0)&&currentframe<TL_SC3+TL_PR(5,0)){
      int local=(currentframe-(TL_SC3+TL_PR(3,0)))/TL_R(2);
      font20white->PutsToSurface(20+local,400-local,"when we will noT",mainVD->GetBackBuffer(),&mainVD->rect,
        local);
    }
    if (currentframe>TL_SC3+TL_PR(4,0)&&currentframe<TL_SC3+TL_PR(6,0)){
      int local=(currentframe-(TL_SC3+TL_PR(4,0)))/TL_R(2);
      font20white->PutsToSurface(20+local,200,"see the light of dawN",mainVD->GetBackBuffer(),&mainVD->rect,
        local);
    }
    if (currentframe>TL_SC3+TL_PR(5,0)&&currentframe<TL_SC3+TL_PR(9,0)){
      int local=(currentframe-(TL_SC3+TL_PR(5,0)))/TL_R(2);
      font20white->PutsToSurface(300-local,10,"because of a skY",mainVD->GetBackBuffer(),&mainVD->rect,
        local/2);
    }
    if (currentframe>TL_SC3+TL_PR(7,0)&&currentframe<TL_SC3+TL_PR(11,0)){
      int local=(currentframe-(TL_SC3+TL_PR(7,0)))/TL_R(2);
      font20white->PutsToSurface(100+local,60,"nuked by uS",mainVD->GetBackBuffer(),&mainVD->rect,
        local/2);
    }
  }
  //====SC7 (metahren')
  if (currentframe>TL_SC7&&currentframe<TL_SC7+TL_SC7_LEN){
    if (currentframe>TL_SC7+TL_PR(0,0)&&currentframe<TL_SC7+TL_PR(4,0)){
      int local=(currentframe-(TL_SC7+TL_PR(0,0)))/TL_R(2);
      font20white->PutsToSurface(100+local,260+local,"our world can diE",mainVD->GetBackBuffer(),&mainVD->rect,
        local/2);
    }
    if (currentframe>TL_SC7+TL_PR(3,0)&&currentframe<TL_SC7+TL_PR(7,0)){
      int local=(currentframe-(TL_SC7+TL_PR(3,0)))/TL_R(2);
      font20white->PutsToSurface(300-local,260+local,"so we must stop the nukE",mainVD->GetBackBuffer(),&mainVD->rect,
        local/2);
    }
  }

  //=====SC4
  if (currentframe>TL_SC4&&currentframe<TL_SC4+TL_SC4_LEN){
    if (currentframe>TL_SC4+TL_PR(1,0)&&currentframe<TL_SC4+TL_PR(5,0)){
      int local=(currentframe-(TL_SC4+TL_PR(1,0)))/TL_R(2);
      font20yellow->PutsToSurface(50+local,300-local,"we are unablE",mainVD->GetBackBuffer(),&mainVD->rect,
        local/2);
    }
    
    if (currentframe>TL_SC4+TL_PR(4,0)&&currentframe<TL_SC4+TL_PR(8,0)){
      int local=(currentframe-(TL_SC4+TL_PR(4,0)))/TL_R(2);
      font20yellow->PutsToSurface(10+local,240+local/TL_R(1),"to turn time bacK",mainVD->GetBackBuffer(),&mainVD->rect,
        local/2);
    }
    
    if (currentframe>TL_SC4+TL_PR(7,0)&&currentframe<TL_SC4+TL_PR(11,0)){
      int local=(currentframe-(TL_SC4+TL_PR(7,0)))/TL_R(2);
      font20yellow->PutsToSurface(200,10+local,"as we start the countdowN",mainVD->GetBackBuffer(),&mainVD->rect,
        local/2);
    }

    if (currentframe>TL_SC4+TL_PR(10,0)&&currentframe<TL_SC4+TL_PR(14,0)){
      int local=(currentframe-(TL_SC4+TL_PR(10,0)))/TL_R(2);
      font20yellow->PutsToSurface(20,410-local,"of a hydrogen bomB",mainVD->GetBackBuffer(),&mainVD->rect,
        local/2);
    }

    if (currentframe>TL_SC4+TL_PR(13,0)&&currentframe<TL_SC4+TL_PR(17,0)){
      int local=(currentframe-(TL_SC4+TL_PR(13,0)))/TL_R(2);
      font20yellow->PutsToSurface(40,50+local,"we need to stop destructinG",mainVD->GetBackBuffer(),&mainVD->rect,
        local/2);
    }

    if (currentframe>TL_SC4+TL_PR(16,0)&&currentframe<TL_SC4+TL_PR(24,0)){
      int local=(currentframe-(TL_SC4+TL_PR(16,0)))/TL_R(2);
      font20yellow->PutsToSurface(350-local,10,"and start creatinG",mainVD->GetBackBuffer(),&mainVD->rect,
        local/4);
    }
  }

  mainVD->Show();
  if (isbreaked) currentframe++;

#ifdef CALC_FPS
  if (frames==0) tstart=GetTickCount();
  frames++;
  if (frames==MEASUREFPS) {
    tend=GetTickCount();
    fps=frames/((tend-tstart)/1000.0);
    frames=0;
  }
#endif
}

