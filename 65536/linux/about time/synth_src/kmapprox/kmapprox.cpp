#include <qmainwindow.h>
#include <qapplication.h>

#include "MainWindow.h"

using namespace Mapprox;
using namespace std;

int main(int argc, char* argv[])
{
    QApplication app(argc, argv);

    MainWindow *mainwindow = new MainWindow();
    mainwindow->show();
    return app.exec();
}
