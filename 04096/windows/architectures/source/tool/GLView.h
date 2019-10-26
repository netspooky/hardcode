#ifndef GLView_h
#define GLView_h

#include <stdint.h>
#include <QtGui>
#include <QGLWidget>

#include "project.h"

namespace aurora {

// opengl view
class GLWidget : public QGLWidget
{
	Q_OBJECT

public:

	GLWidget(const QGLWidget* shareWidget = 0);
	~GLWidget();


	project::Project *project;

	QSize minimumSizeHint() const;
	QSize sizeHint() const;

signals:

	void initialize();

protected:

	void initializeGL();
	void resizeGL(int width, int height);
	void paintGL();
	
	void mousePressEvent(QMouseEvent *event);
	void mouseMoveEvent(QMouseEvent *event);
};


// opengl viewport with menu bar (e.g. for camera selection) and opengl view
class GLView : public QWidget
{

public:

	GLView(QMenu* cameraMenu, const QGLWidget* shareWidget = 0);
	
	virtual ~GLView();

	virtual void paintEvent(QPaintEvent* e);

	GLWidget* inner;
};

} // namespace aurora

#endif
