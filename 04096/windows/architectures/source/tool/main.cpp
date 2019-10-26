#include <digi/System/Log.h>
#include <digi/System/ConsoleLogChannel.h>

#include <QApplication>
#include <QDesktopWidget>
#include <QGLFormat>

#include "MainWindow.h"

using namespace aurora;

int main(int argc, char *argv[])
{
	QApplication app(argc, argv);
	app.setOrganizationName("exozet");
	app.setApplicationName("Aurora");
	MainWindow *mainWin = new MainWindow();
	mainWin->show();
	return app.exec();
/*
	QApplication app(argc, argv);
	MainWindow* window = new MainWindow();
	window->resize(window->sizeHint());
	int desktopArea = QApplication::desktop()->width() * QApplication::desktop()->height();
	int widgetArea = window->width() * window->height();
	if (((float)widgetArea / (float)desktopArea) < 0.75f)
		window->show();
	else
		window->showMaximized();
	return app.exec();
*/
}
