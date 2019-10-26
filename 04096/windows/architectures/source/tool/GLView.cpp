#include <math.h>

#include <QtGui>
#include <QtOpenGL>

#include "GLView.h"
#include "../../architectures/deepflower.h"
#include <boost/lexical_cast.hpp>

void initDemoGL();
void playDemoGL(float cameraTime, float sceneTime, float cameraDistance, int flags);

float toBetterFloat(float val)
{
	float k = val;
	*((unsigned char*)&k+0)=0;
	*((unsigned char*)&k+1)=*((unsigned char*)&k+1) & 0x80; // noch 1 bit mehr = mehr spass !! 
	return k;
}

namespace aurora {

static QGLFormat getFormat()
{
	// multisample full screen anti-aliasing
	QGLFormat fmt(QGL::SampleBuffers);
	
	// opengl 3.2 core profile
	//fmt.setProfile(QGLFormat::CoreProfile);
	//fmt.setVersion(3, 2);
	
	return fmt;
}

GLWidget::GLWidget(const QGLWidget* shareWidget)
	: QGLWidget(getFormat(), NULL, shareWidget)
{
}

GLWidget::~GLWidget()
{
}

QSize GLWidget::minimumSizeHint() const
{
	return QSize(50, 50);
}

QSize GLWidget::sizeHint() const
{
	return QSize(400, 400);
}

void GLWidget::initializeGL()
{
	initDemoGL();
/*
	const char* version = (const char*)glGetString(GL_VERSION);
	QGLFormat fmt =this->format();
	int major = fmt.majorVersion();
	int minor = fmt.minorVersion();
	QGLFormat::OpenGLContextProfile profile = fmt.profile();
*/
	// enable multisample
	//glEnable(GL_MULTISAMPLE);

	//this->compositor->init();
}

void GLWidget::resizeGL(int width, int height)
{
}

#define MAKESCENEFLAG(cubesWhite,cubesBlack,backgroundBlack,divPolys,morph1) (((((cubesBlack) & 1)|(((cubesWhite) & 1)<<1)|(((backgroundBlack) & 1)<<2)|(((divPolys) & 7)<<3)|(morph1<<6) )<<1)+1)

void GLWidget::paintGL()
{
	QSize size = this->size();
	int width = size.width();
	int height = size.height();

	glViewport(0, 0, width, height);

	project->seite.flagsAccu = MAKESCENEFLAG(project->seite.objectsWhite,project->seite.objectsBlackAndFlat,project->seite.backgroundBlack,project->seite.polyDivShift,project->seite.architecture);
	project->seite.cameraScene = toBetterFloat(project->unten.cameraTime+project->unten.cameraTimeFine);
	project->seite.animationScene = toBetterFloat(project->unten.animationTime+project->unten.animationTimeFine);
	float cameraPlay = project->seite.cameraScene;
	float animationPlay = project->seite.animationScene;
	float zoomPlay = toBetterFloat(project->unten.cameraDistance);
	float cameraSpeed = toBetterFloat(project->seite.cameraSpeed);
	float animationSpeed = toBetterFloat(project->seite.animationSpeed);
	float zoomSpeed = toBetterFloat(project->seite.zoomSpeed);

	project->seite.scene =  std::string("0.f, ") + 
		boost::lexical_cast<std::string>(animationPlay)+"f,"+boost::lexical_cast<std::string>(animationSpeed)+"f, "+
		boost::lexical_cast<std::string>(cameraPlay)+"f,"+boost::lexical_cast<std::string>(cameraSpeed)+"f, "+
		boost::lexical_cast<std::string>(zoomPlay)+"f,"+boost::lexical_cast<std::string>(zoomSpeed)+"f, "+
		boost::lexical_cast<std::string>(project->seite.flagsAccu) + "";

	static bool isPlaying = false;
	static int startTime = 0;
	if (project->seite.play && !isPlaying)
	{
		startTime = timeGetTime();
		isPlaying = true;
	}
	if (isPlaying && project->seite.play == false)
	{
		isPlaying = false;
	}
	if (isPlaying)
	{
		float seconds = (float)(timeGetTime() - startTime)/1000.f;
		float beatPos = seconds / 60.f * BPM / 4.f;
		cameraPlay	  += beatPos * cameraSpeed;
		animationPlay += beatPos * animationSpeed;
		zoomPlay	  += beatPos * zoomSpeed;
		project->seite.beat = beatPos;
	}

	playDemoGL(cameraPlay,animationPlay,zoomPlay,project->seite.flagsAccu);

}


void GLWidget::mousePressEvent(QMouseEvent *event)
{
	event->pos();
}

void GLWidget::mouseMoveEvent(QMouseEvent *event)
{
}


// GLView

GLView::GLView(QMenu* cameraMenu, const QGLWidget* shareWidget)
	: QWidget(NULL)
{
	QVBoxLayout* layout = new QVBoxLayout();
	
	// border around view to show selection state
	layout->setMargin(2);
	
	layout->setSpacing(0);
	//QMenuBar* menuBar = new QMenuBar();
	//menuBar->addMenu(cameraMenu);
	//layout->setMenuBar(menuBar);
	//layout->addWidget(menuBar);
	layout->addWidget(this->inner = new GLWidget(shareWidget));
	//layout->addWidget(new QTextEdit());
	this->setLayout(layout);
	
	// accept focus on tab and mouse click
	this->setFocusPolicy(Qt::StrongFocus);
}

GLView::~GLView()
{
}

void GLView::paintEvent(QPaintEvent* e)
{
	QPainter painter(this);

	painter.begin(this);
	if (this->hasFocus())
		painter.fillRect(this->rect(), QBrush(QColor(153, 180, 209)));//Qt::lightGray);
	else
		painter.eraseRect(this->rect());
	painter.end();
}

} // namespace aurora
