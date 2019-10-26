#ifndef MainWindow_h
#define MainWindow_h

#include <QtGui>
#include <QMainWindow>

#include "LineEdits.h"
#include "GLView.h"

#include "project.h"
#include "project.Qt.h"

namespace aurora {

// main application window
class MainWindow : public QMainWindow
{
	Q_OBJECT

public:
	
	MainWindow();

protected slots:
	
	void initializeGL();

	void newProject();
	void openProject();
	void saveProject();
	void saveProjectAs();
	void openRecentProject();
	void about();

protected:

	void createActions();
	void createMenus();
	
	void loadProject(const QString& fileName);
	void saveProject(const QString& fileName);
	void setCurrentProject(const QString& fileName);
	void updateRecentProjectActions();
	QString strippedName(const QString &fullFileName);

	void loadScenes();

protected slots:

	void setCamera();

	void changed();
	void changed(bool);
	void changed(int);

	void update();

protected:

	// current project
	QString projectFileName;
	project::Project project;
	//project::QtProject qtProject;
	project::QtUnten qtUnten;
	project::QtSeite qtSeite;

	// the widget in the main area of QMainWindow
	QWidget* mainWidget;
	QTextEdit* textEdit;
	
	// file menu
	// recent files example: http://doc.qt.digia.com/qt/mainwindows-recentfiles.html
	QMenu* fileMenu;
	QMenu* recentFilesMenu;
	enum
	{
		MaxRecentProjects = 10
	};
	QAction* newProjectAct;
	QAction* openProjectAct;
	QAction* saveProjectAct;
	QAction* saveProjectAsAct;
	QAction* separatorAct;
	QAction* recentProjectActs[MaxRecentProjects];
	QAction* exitAct;
	
	// help menu
	QMenu* helpMenu;
	QAction* aboutAct;

	// camera menu (used for all views)
	QMenu* camerasMenu;

	// compositor view
	//GLView* compositorView;
	
	// camera view
	//GLView* cameraView;

	// list of views
	std::vector<GLView*> views;


	// render group
	int group;

	struct Scene
	{
		// file handle
		int file;
		
		// scene handle
		int scene;

		Scene()
			: file(-1), scene(-1) {}
	};

	std::vector<Scene> scenes;
};

} // namespace aurora

#endif
