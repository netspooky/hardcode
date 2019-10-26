#include "config.hpp"

/*CALLBACK ConfigProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{	
	switch(uMsg)
	{				
		case WM_INITDIALOG:
		{				
//			InitCommonControls(); //was ist das?
			
			RECT rect, dlgRect;
			HWND dlg;
			
			// Center the dialog box
			dlg = GetDesktopWindow();			
			if(dlg)
			{				
				GetWindowRect(dlg, &rect);
				GetWindowRect(hwnd, &dlgRect);

				SetWindowPos(hwnd, HWND_TOP, (rect.right/2) - ((dlgRect.right - dlgRect.left) / 2), (rect.bottom/2) - ((dlgRect.bottom - dlgRect.top) / 2), 0, 0, SWP_NOSIZE);
			}			

			// Show the dialog
			ShowWindow(hwnd, SW_SHOW);
			SetActiveWindow(hwnd);
			SetForegroundWindow(hwnd);
			SetFocus(hwnd);

			// Check default values
			SendDlgItemMessage(hwnd, IDC_1024, BM_SETCHECK, wParam, 0);
			SendDlgItemMessage(hwnd, IDC_FULLSCREEN, BM_SETCHECK, wParam, 0);
			SendDlgItemMessage(hwnd, IDC_MUSIC, BM_SETCHECK, wParam, 0);

//			SendMessage(hwnd, WM_SETICON, ICON_SMALL, (LPARAM)LoadIcon(instance, MAKEINTRESOURCE(APPICON)));
//			SendMessage(hwnd, WM_SETICON, ICON_BIG, (LPARAM)LoadIcon(instance, MAKEINTRESOURCE(APPICON)));

		} break;

		case WM_COMMAND:
		{
			switch(LOWORD(wParam))
			{
				case IDC_RUNINTRO:
				{
					if (SendDlgItemMessage(hwnd, IDC_1280, BM_GETSTATE, 0, 0)==BST_CHECKED)
					{
						OPENGL_XRES = 1280;
						OPENGL_YRES = 1024;
					}
					if (SendDlgItemMessage(hwnd, IDC_1024, BM_GETSTATE, 0, 0)==BST_CHECKED)
					{
						OPENGL_XRES = 1024;
						OPENGL_YRES = 768;
					}
					if (SendDlgItemMessage(hwnd, IDC_MUSIC, BM_GETSTATE, 0, 0)==BST_CHECKED)
					{
						musicflag=true;
					}
					else
						musicflag=false;
					if (SendDlgItemMessage(hwnd, IDC_FULLSCREEN, BM_GETSTATE, 0, 0)==BST_CHECKED)
					{
						OPENGL_FULLSCREEN=true;
					}
					else
						OPENGL_FULLSCREEN=false;

					runflag = true;
					EndDialog(hwnd, 0);
				} break;
				
				case IDC_BEALAMER:
				{
					runflag = false;
					SendMessage(hwnd, WM_CLOSE, 0, 0);
				} break;

			} break;

		} break;

		case WM_DESTROY:
		{
			SendMessage(hwnd, WM_CLOSE, 0, 0);
		} break;
		
		case WM_CLOSE:
		{						
			EndDialog(hwnd, 0);
		} 
		break;		
	}
		
	return 0;
}*/
 
