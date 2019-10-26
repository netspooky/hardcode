#include <stdint.h>
#include <boost/lexical_cast.hpp>

#include <digi/Utility/ArrayUtility.h>
#include <digi/Utility/foreach.h> // include before Qt to define foreach
#include <digi/Utility/MapUtility.h>
#include <digi/System/FileSystem.h>
#include <digi/System/Log.h>
#include <digi/Data/EBMLReader.h>
#include <digi/Data/EBMLWriter.h>
#include <digi/Data/JSONReader.h>
#include <digi/Data/JSONWriter.h>
#include <digi/Data/ReadFunctions.h>
#include <digi/Data/ReadHelper.h>
#include <digi/Data/WriteFunctions.h>

#include <QtGui>

#include "Utility.h"
#include "MainWindow.h"

#undef min
#undef max

using digi::EBMLHeader;
using digi::EBMLReader;
using digi::EBMLWriter;
using digi::JSONReader;
using digi::JSONWriter;
using digi::lexicalCast;

namespace project
{
	using digi::findIndex;

	// ebml read/write float2
/*
	void setOK(QLineEdit* lineEdit)
	{
		QPalette palette = lineEdit->palette(); 
		palette.setBrush(QPalette::Text, QBrush(Qt::black));
		lineEdit->setPalette(palette);
	}

	void setError(QLineEdit* lineEdit)
	{
		QPalette palette = lineEdit->palette(); 
		palette.setBrush(QPalette::Text, QBrush(Qt::red));
		lineEdit->setPalette(palette);
	}
*/
}


#include "project.writeQt.h"
#include "project.initQt.h"
#include "project.changeQt.h"
#include "project.updateQt.h"

#include "project.readEBML.h"
#include "project.writeEBML.h"
#include "project.readJSON.h"
#include "project.writeJSON.h"


namespace aurora {

MainWindow::MainWindow()
{
	// add loaders
	this->setAttribute(Qt::WA_DeleteOnClose);

	// create menu actions
	this->createActions();

	this->mainWidget = new QWidget();
	QVBoxLayout* mainLayout = new QVBoxLayout();

	// oben area
	{
		QHBoxLayout* leftLayout = new QHBoxLayout();

		// cameras menu for all views
		this->camerasMenu = new QMenu(tr("Cameras"));


		// compositor view
		GLView* compositorView = new GLView(this->camerasMenu);
		compositorView->inner->project = &this->project;
		leftLayout->addWidget(compositorView, 1);
		this->views.push_back(compositorView);
 
		QTimer *timer = new QTimer(this);
		connect(timer, SIGNAL(timeout()), this, SLOT(update()));
	    timer->start(10);
	
		// compositor view
		//this->compositorView = new GLView();
		//leftLayout->addWidget(this->compositorView, 1);
		QWidget* w = init(qtSeite, this);
		w->setMinimumWidth(250);
		leftLayout->addWidget(w);

		// set engine compositor
		//compositorView->inner->compositor = new EngineCompositor(this->engine, this->group);
		//compositorView->inner->compositor = new EffectCompositor(this->engine, this->group, this->project);

		// camera view
		//leftLayout->addWidget(this->textEdit = new QTextEdit());
		mainLayout->addLayout(leftLayout, 1);
	}
	
	// unten area
	{
		//QScrollArea* scrollArea = new QScrollArea();
		//scrollArea->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
		//scrollArea->setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOn);

		// init generated project gui
		//scrollArea->setWidget(init(qtProject, this));
		
		//mainLayout->addWidget(scrollArea);

		QWidget* w = init(qtUnten, this);
		w->setMinimumWidth(250);
		//w->setMaximumWidth(250);
		mainLayout->addWidget(w);
	}
	this->mainWidget->setLayout(mainLayout);
	this->setCentralWidget(this->mainWidget);

	this->createMenus();
	
	this->statusBar();
	//this->setWindowFilePath(QString());

	this->resize(1200, 800);

	// deferred invoke of initializeGL()
	QMetaObject::invokeMethod(this, "initializeGL", Qt::QueuedConnection);
}

void MainWindow::initializeGL()
{
	// now the gl views have opengl contexts
	
	// initialize pointers to gl functions
	GLView* mainView = this->views.front();
	mainView->inner->makeCurrent();

	mainView->inner->doneCurrent();
}

void MainWindow::newProject()
{
	if (QMessageBox::question(this, tr("Warning: Project not saved"),
		tr("Discard current project?")) == QMessageBox::Ok)
	{
		this->project = project::Project();
		project::write(this->qtUnten, this->project.unten);
		project::write(this->qtSeite, this->project.seite);

		// delete scenes
		this->loadScenes();
	}
}

void MainWindow::openProject()
{
	QString fileName = QFileDialog::getOpenFileName(this);
	if (!fileName.isEmpty())
		this->loadProject(fileName);
}

void MainWindow::saveProject()
{
	if (this->projectFileName.isEmpty())
		this->saveProjectAs();
	else
		this->saveProject(this->projectFileName);
}

void MainWindow::saveProjectAs()
{
	QString fileName = QFileDialog::getSaveFileName(this);
	if (fileName.isEmpty())
		return;
	this->saveProject(fileName);
}

void MainWindow::openRecentProject()
{
	QAction* action = qobject_cast<QAction*>(this->sender());
	if (action != NULL)
		this->loadProject(action->data().toString());
}

void MainWindow::about()
{
	QMessageBox::about(this, tr("About Recent Files"),
		tr("The <b>Recent Files</b> example demonstrates how to provide a "
		"recently used file menu in a Qt application."));
}

void MainWindow::createActions()
{
	this->newProjectAct = new QAction(tr("&New Project"), this);
	this->newProjectAct->setShortcuts(QKeySequence::New);
	this->newProjectAct->setStatusTip(tr("Create a new project"));
	connect(this->newProjectAct, SIGNAL(triggered()), this, SLOT(newProject()));

	this->openProjectAct = new QAction(tr("&Open Project..."), this);
	this->openProjectAct->setShortcuts(QKeySequence::Open);
	this->openProjectAct->setStatusTip(tr("Open an existing file"));
	connect(this->openProjectAct, SIGNAL(triggered()), this, SLOT(openProject()));

	this->saveProjectAct = new QAction(tr("&Save Project"), this);
	this->saveProjectAct->setShortcuts(QKeySequence::Save);
	this->saveProjectAct->setStatusTip(tr("Save the document to disk"));
	connect(this->saveProjectAct, SIGNAL(triggered()), this, SLOT(saveProject()));

	this->saveProjectAsAct = new QAction(tr("Save Project &As..."), this);
	this->saveProjectAsAct->setShortcuts(QKeySequence::SaveAs);
	this->saveProjectAsAct->setStatusTip(tr("Save the document under a new name"));
	connect(this->saveProjectAsAct, SIGNAL(triggered()), this, SLOT(saveProjectAs()));

	for (int i = 0; i < MaxRecentProjects; ++i)
	{
		this->recentProjectActs[i] = new QAction(this);
		this->recentProjectActs[i]->setVisible(false);
		connect(this->recentProjectActs[i], SIGNAL(triggered()),
			this, SLOT(openRecentProject()));
	}

	this->exitAct = new QAction(tr("E&xit"), this);
	this->exitAct->setShortcuts(QKeySequence::Quit);
	this->exitAct->setStatusTip(tr("Exit the application"));
	connect(this->exitAct, SIGNAL(triggered()), qApp, SLOT(closeAllWindows()));

	this->aboutAct = new QAction(tr("&About"), this);
	this->aboutAct->setStatusTip(tr("Show the application's About box"));
	connect(aboutAct, SIGNAL(triggered()), this, SLOT(about()));
}

void MainWindow::createMenus()
{
	// file menu
	this->fileMenu = menuBar()->addMenu(tr("&File"));
	this->fileMenu->addAction(this->newProjectAct);
	this->fileMenu->addAction(this->openProjectAct);
	this->fileMenu->addAction(this->saveProjectAct);
	this->fileMenu->addAction(this->saveProjectAsAct);
	
	this->separatorAct = fileMenu->addSeparator();
	for (int i = 0; i < MaxRecentProjects; ++i)
		this->fileMenu->addAction(this->recentProjectActs[i]);
	this->updateRecentProjectActions();

	this->fileMenu->addSeparator();
	this->fileMenu->addAction(this->exitAct);

	// help menu
	this->menuBar()->addSeparator();
	this->helpMenu = this->menuBar()->addMenu(tr("&Help"));
	this->helpMenu->addAction(this->aboutAct);
}

void MainWindow::loadProject(const QString& fileName)
{
	// read ebml
	QApplication::setOverrideCursor(Qt::WaitCursor);
	fs::path path = toPath(fileName);
	try
	/*{
		EBMLReader r(path);
		EBMLHeader header;
		r.readHeader(header);
		project::Project project;
		project::project::read(r, project);
		r.close();
		this->project = project;
		project::write(this->qtProject, this->project);
	}*/
	{
		JSONReader r(path);
		project::Project project;
		project::project::read(r, project);
		r.close();
		this->project = project;
		project::write(this->qtUnten, this->project.unten);
		project::write(this->qtSeite, this->project.seite);
	}
	catch (std::exception&)
	{
		// load failed
		QMessageBox::warning(this, tr("Load failed"), tr("Failed to load project") + " '" + fileName + "'");
	}
	QApplication::restoreOverrideCursor();

	this->setCurrentProject(fileName);

	// load scenes
	this->statusBar()->showMessage(tr("Loading scenes"), 2000);
	this->loadScenes();
	
	// show message in status bar for 2000 milli seconds
	this->statusBar()->showMessage(tr("Project loaded"), 2000);
}

void MainWindow::saveProject(const QString &fileName)
{
	// write ebml
	QApplication::setOverrideCursor(Qt::WaitCursor);
	fs::path path = toPath(fileName);
	/*{
		EBMLWriter w(path);
		EBMLHeader header;
		header.docType = "xoz aurora";
		w.writeHeader(header);
		project::project::write(w, this->project);
		w.close();
	}*/
	{
		JSONWriter w(path);
		project::project::write(w, this->project);
		w.close();
	}
	QApplication::restoreOverrideCursor();

	this->setCurrentProject(fileName);
		
	// show message in status bar for 2000 milli seconds
	this->statusBar()->showMessage(tr("File saved"), 2000);
}

void MainWindow::setCurrentProject(const QString &fileName)
{
	this->projectFileName = fileName;
	this->setWindowFilePath(fileName);

	// update persistent recent project list
	QSettings settings;
	QStringList files = settings.value("recentProjectList").toStringList();
	files.removeAll(fileName);
	files.prepend(fileName);
	while (files.size() > MaxRecentProjects)
		files.removeLast();
	settings.setValue("recentProjectList", files);

	foreach (QWidget* widget, QApplication::topLevelWidgets())
	{
		MainWindow* mainWin = qobject_cast<MainWindow*>(widget);
		if (mainWin != NULL)
			mainWin->updateRecentProjectActions();
	}
}

void MainWindow::updateRecentProjectActions()
{
	QSettings settings;
	QStringList files = settings.value("recentProjectList").toStringList();

	int numRecentFiles = qMin(files.size(), (int)MaxRecentProjects);

	// enable used recent project actions
	for (int i = 0; i < numRecentFiles; ++i)
	{
		QString text = tr("&%1 %2").arg(i + 1).arg(strippedName(files[i]));
		recentProjectActs[i]->setText(text);
		recentProjectActs[i]->setData(files[i]);
		recentProjectActs[i]->setVisible(true);
	}
	
	// disable unused recent project actions
	for (int j = numRecentFiles; j < MaxRecentProjects; ++j)
		recentProjectActs[j]->setVisible(false);

	separatorAct->setVisible(numRecentFiles > 0);
}

QString MainWindow::strippedName(const QString& fullFileName)
{
	return QFileInfo(fullFileName).fileName();
}

void MainWindow::loadScenes()
{
}

void MainWindow::setCamera()
{
}

void MainWindow::changed()
{
	// change Qt gui. produces a path that tells us where a change occured
	int path[10];
	digi::fill(path, project::event::null);
	QObject* sender = this->sender();
	project::change(this->qtUnten, this->project.unten, sender, path);
	project::change(this->qtSeite, this->project.seite, sender, path);

	// update views
	if (path[0] != project::event::null)
	{
		foreach (GLView* view, this->views)
		{
			view->inner->updateGL();
		}
	}
}

void MainWindow::changed(bool)
{
	this->changed();
}

void MainWindow::changed(int i)
{
	this->changed();
}

void MainWindow::update()
{
	int path[10];
	path[0] = project::event::cameraScene;
	path[1] = project::event::null;
	project::update(this->qtSeite,this->project.seite,path);
	path[0] = project::event::animationScene;
	path[1] = project::event::null;
	project::update(this->qtSeite,this->project.seite,path);
	path[0] = project::event::beat;
	path[1] = project::event::null;
	project::update(this->qtSeite,this->project.seite,path);
	static std::string toCheckAgainst;
	if (this->project.seite.scene != toCheckAgainst)
	{
		toCheckAgainst = this->project.seite.scene;
		path[0] = project::event::scene;
		path[1] = project::event::null;
		project::update(this->qtSeite,this->project.seite,path);
	}


	foreach (GLView* view, this->views)
	{
		view->inner->updateGL();
	}
}

} // namespace aurora
