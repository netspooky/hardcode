namespace project
{
	QWidget* init(QtUnten& q, QWidget* receiver)
	{
		QWidget* widget = new QWidget();
		QGridLayout* layout = new QGridLayout();
		layout->addWidget(new QLabel(QObject::tr("cameraTime")), 0, 0);
		{
			QHBoxLayout* l = new QHBoxLayout();
			l->addWidget(q.cameraTime = new NumericLineEdit<float>(), 0);
			q.cameraTime->setMaximumWidth(60);
			l->addWidget(q._slider_cameraTime = new QSlider(Qt::Horizontal), 1);
			q._slider_cameraTime->setMinimum(0);
			q._slider_cameraTime->setMaximum(1000);
			QObject::connect(q._slider_cameraTime, SIGNAL(valueChanged(int)), receiver, SLOT(changed(int)));
			layout->addLayout(l, 0, 1);
		}
		QObject::connect(q.cameraTime, SIGNAL(editingFinished()), receiver, SLOT(changed()));
		QObject::connect(q.cameraTime, SIGNAL(returnPressed()), q.cameraTime, SLOT(selectAll()));
		layout->addWidget(new QLabel(QObject::tr("cameraFine")), 1, 0);
		{
			QHBoxLayout* l = new QHBoxLayout();
			l->addWidget(q.cameraTimeFine = new NumericLineEdit<float>(), 0);
			q.cameraTimeFine->setMaximumWidth(60);
			l->addWidget(q._slider_cameraTimeFine = new QSlider(Qt::Horizontal), 1);
			q._slider_cameraTimeFine->setMinimum(0);
			q._slider_cameraTimeFine->setMaximum(1000);
			QObject::connect(q._slider_cameraTimeFine, SIGNAL(valueChanged(int)), receiver, SLOT(changed(int)));
			layout->addLayout(l, 1, 1);
		}
		QObject::connect(q.cameraTimeFine, SIGNAL(editingFinished()), receiver, SLOT(changed()));
		QObject::connect(q.cameraTimeFine, SIGNAL(returnPressed()), q.cameraTimeFine, SLOT(selectAll()));
		layout->addWidget(new QLabel(QObject::tr("animationTime")), 2, 0);
		{
			QHBoxLayout* l = new QHBoxLayout();
			l->addWidget(q.animationTime = new NumericLineEdit<float>(), 0);
			q.animationTime->setMaximumWidth(60);
			l->addWidget(q._slider_animationTime = new QSlider(Qt::Horizontal), 1);
			q._slider_animationTime->setMinimum(0);
			q._slider_animationTime->setMaximum(1000);
			QObject::connect(q._slider_animationTime, SIGNAL(valueChanged(int)), receiver, SLOT(changed(int)));
			layout->addLayout(l, 2, 1);
		}
		QObject::connect(q.animationTime, SIGNAL(editingFinished()), receiver, SLOT(changed()));
		QObject::connect(q.animationTime, SIGNAL(returnPressed()), q.animationTime, SLOT(selectAll()));
		layout->addWidget(new QLabel(QObject::tr("animationFine")), 3, 0);
		{
			QHBoxLayout* l = new QHBoxLayout();
			l->addWidget(q.animationTimeFine = new NumericLineEdit<float>(), 0);
			q.animationTimeFine->setMaximumWidth(60);
			l->addWidget(q._slider_animationTimeFine = new QSlider(Qt::Horizontal), 1);
			q._slider_animationTimeFine->setMinimum(0);
			q._slider_animationTimeFine->setMaximum(1000);
			QObject::connect(q._slider_animationTimeFine, SIGNAL(valueChanged(int)), receiver, SLOT(changed(int)));
			layout->addLayout(l, 3, 1);
		}
		QObject::connect(q.animationTimeFine, SIGNAL(editingFinished()), receiver, SLOT(changed()));
		QObject::connect(q.animationTimeFine, SIGNAL(returnPressed()), q.animationTimeFine, SLOT(selectAll()));
		layout->addWidget(new QLabel(QObject::tr("cameraDistance")), 4, 0);
		{
			QHBoxLayout* l = new QHBoxLayout();
			l->addWidget(q.cameraDistance = new NumericLineEdit<float>(), 0);
			q.cameraDistance->setMaximumWidth(60);
			l->addWidget(q._slider_cameraDistance = new QSlider(Qt::Horizontal), 1);
			q._slider_cameraDistance->setMinimum(0);
			q._slider_cameraDistance->setMaximum(1000);
			QObject::connect(q._slider_cameraDistance, SIGNAL(valueChanged(int)), receiver, SLOT(changed(int)));
			layout->addLayout(l, 4, 1);
		}
		QObject::connect(q.cameraDistance, SIGNAL(editingFinished()), receiver, SLOT(changed()));
		QObject::connect(q.cameraDistance, SIGNAL(returnPressed()), q.cameraDistance, SLOT(selectAll()));
		layout->addWidget(new QLabel(QObject::tr("flags")), 5, 0);
		layout->addWidget(q.flags = new NumericLineEdit<int32_t>, 5, 1);
		QObject::connect(q.flags, SIGNAL(editingFinished()), receiver, SLOT(changed()));
		QObject::connect(q.flags, SIGNAL(returnPressed()), q.flags, SLOT(selectAll()));
		write(q, Unten());
		layout->addItem(new QSpacerItem(0, 0), 6, 0, 1, 2);
		layout->setRowStretch(6, 1);
		widget->setLayout(layout);
		return widget;
	}
	
	QWidget* init(QtSeite& q, QWidget* receiver)
	{
		QWidget* widget = new QWidget();
		QGridLayout* layout = new QGridLayout();
		layout->addWidget(new QLabel(QObject::tr("zoomSpeed")), 0, 0);
		{
			QHBoxLayout* l = new QHBoxLayout();
			l->addWidget(q.zoomSpeed = new NumericLineEdit<float>(), 0);
			q.zoomSpeed->setMaximumWidth(60);
			l->addWidget(q._slider_zoomSpeed = new QSlider(Qt::Horizontal), 1);
			q._slider_zoomSpeed->setMinimum(0);
			q._slider_zoomSpeed->setMaximum(1000);
			QObject::connect(q._slider_zoomSpeed, SIGNAL(valueChanged(int)), receiver, SLOT(changed(int)));
			layout->addLayout(l, 0, 1);
		}
		QObject::connect(q.zoomSpeed, SIGNAL(editingFinished()), receiver, SLOT(changed()));
		QObject::connect(q.zoomSpeed, SIGNAL(returnPressed()), q.zoomSpeed, SLOT(selectAll()));
		layout->addWidget(new QLabel(QObject::tr("cameraSpeed")), 1, 0);
		{
			QHBoxLayout* l = new QHBoxLayout();
			l->addWidget(q.cameraSpeed = new NumericLineEdit<float>(), 0);
			q.cameraSpeed->setMaximumWidth(60);
			l->addWidget(q._slider_cameraSpeed = new QSlider(Qt::Horizontal), 1);
			q._slider_cameraSpeed->setMinimum(0);
			q._slider_cameraSpeed->setMaximum(1000);
			QObject::connect(q._slider_cameraSpeed, SIGNAL(valueChanged(int)), receiver, SLOT(changed(int)));
			layout->addLayout(l, 1, 1);
		}
		QObject::connect(q.cameraSpeed, SIGNAL(editingFinished()), receiver, SLOT(changed()));
		QObject::connect(q.cameraSpeed, SIGNAL(returnPressed()), q.cameraSpeed, SLOT(selectAll()));
		layout->addWidget(new QLabel(QObject::tr("animationSpeed")), 2, 0);
		{
			QHBoxLayout* l = new QHBoxLayout();
			l->addWidget(q.animationSpeed = new NumericLineEdit<float>(), 0);
			q.animationSpeed->setMaximumWidth(60);
			l->addWidget(q._slider_animationSpeed = new QSlider(Qt::Horizontal), 1);
			q._slider_animationSpeed->setMinimum(0);
			q._slider_animationSpeed->setMaximum(1000);
			QObject::connect(q._slider_animationSpeed, SIGNAL(valueChanged(int)), receiver, SLOT(changed(int)));
			layout->addLayout(l, 2, 1);
		}
		QObject::connect(q.animationSpeed, SIGNAL(editingFinished()), receiver, SLOT(changed()));
		QObject::connect(q.animationSpeed, SIGNAL(returnPressed()), q.animationSpeed, SLOT(selectAll()));
		layout->addWidget(new QLabel(QObject::tr("objectsBlackAndFlat")), 3, 0);
		layout->addWidget(q.objectsBlackAndFlat = new QCheckBox(), 3, 1);
		QObject::connect(q.objectsBlackAndFlat, SIGNAL(clicked(bool)), receiver, SLOT(changed(bool)));
		layout->addWidget(new QLabel(QObject::tr("objectsWhite")), 4, 0);
		layout->addWidget(q.objectsWhite = new QCheckBox(), 4, 1);
		QObject::connect(q.objectsWhite, SIGNAL(clicked(bool)), receiver, SLOT(changed(bool)));
		layout->addWidget(new QLabel(QObject::tr("backgroundBlack")), 5, 0);
		layout->addWidget(q.backgroundBlack = new QCheckBox(), 5, 1);
		QObject::connect(q.backgroundBlack, SIGNAL(clicked(bool)), receiver, SLOT(changed(bool)));
		layout->addWidget(new QLabel(QObject::tr("polyDivShift")), 6, 0);
		{
			QHBoxLayout* l = new QHBoxLayout();
			l->addWidget(q.polyDivShift = new NumericLineEdit<int32_t>(), 0);
			q.polyDivShift->setMaximumWidth(60);
			l->addWidget(q._slider_polyDivShift = new QSlider(Qt::Horizontal), 1);
			q._slider_polyDivShift->setTickPosition(QSlider::TicksBelow);
			q._slider_polyDivShift->setMinimum(0);
			q._slider_polyDivShift->setMaximum(7);
			QObject::connect(q._slider_polyDivShift, SIGNAL(valueChanged(int)), receiver, SLOT(changed(int)));
			layout->addLayout(l, 6, 1);
		}
		QObject::connect(q.polyDivShift, SIGNAL(editingFinished()), receiver, SLOT(changed()));
		QObject::connect(q.polyDivShift, SIGNAL(returnPressed()), q.polyDivShift, SLOT(selectAll()));
		layout->addWidget(new QLabel(QObject::tr("architecture")), 7, 0);
		layout->addWidget(q.architecture = new QCheckBox(), 7, 1);
		QObject::connect(q.architecture, SIGNAL(clicked(bool)), receiver, SLOT(changed(bool)));
		layout->addWidget(new QLabel(QObject::tr("play")), 8, 0);
		layout->addWidget(q.play = new QCheckBox(), 8, 1);
		QObject::connect(q.play, SIGNAL(clicked(bool)), receiver, SLOT(changed(bool)));
		layout->addWidget(new QLabel(QObject::tr("cameraScene")), 9, 0);
		layout->addWidget(q.cameraScene = new NumericLineEdit<float>, 9, 1);
		QObject::connect(q.cameraScene, SIGNAL(editingFinished()), receiver, SLOT(changed()));
		QObject::connect(q.cameraScene, SIGNAL(returnPressed()), q.cameraScene, SLOT(selectAll()));
		layout->addWidget(new QLabel(QObject::tr("animationScene")), 10, 0);
		layout->addWidget(q.animationScene = new NumericLineEdit<float>, 10, 1);
		QObject::connect(q.animationScene, SIGNAL(editingFinished()), receiver, SLOT(changed()));
		QObject::connect(q.animationScene, SIGNAL(returnPressed()), q.animationScene, SLOT(selectAll()));
		layout->addWidget(new QLabel(QObject::tr("flagsAccu")), 11, 0);
		layout->addWidget(q.flagsAccu = new NumericLineEdit<int32_t>, 11, 1);
		QObject::connect(q.flagsAccu, SIGNAL(editingFinished()), receiver, SLOT(changed()));
		QObject::connect(q.flagsAccu, SIGNAL(returnPressed()), q.flagsAccu, SLOT(selectAll()));
		layout->addWidget(new QLabel(QObject::tr("beat")), 12, 0);
		layout->addWidget(q.beat = new NumericLineEdit<float>, 12, 1);
		QObject::connect(q.beat, SIGNAL(editingFinished()), receiver, SLOT(changed()));
		QObject::connect(q.beat, SIGNAL(returnPressed()), q.beat, SLOT(selectAll()));
		layout->addWidget(new QLabel(QObject::tr("scene")), 13, 0);
		layout->addWidget(q.scene = new QLineEdit(), 13, 1);
		QObject::connect(q.scene, SIGNAL(editingFinished()), receiver, SLOT(changed()));
		QObject::connect(q.scene, SIGNAL(returnPressed()), q.scene, SLOT(selectAll()));
		write(q, Seite());
		layout->addItem(new QSpacerItem(0, 0), 14, 0, 1, 2);
		layout->setRowStretch(14, 1);
		widget->setLayout(layout);
		return widget;
	}
	
	QWidget* init(QtProject& q, QWidget* receiver)
	{
		QToolBox* toolBox = new QToolBox();
		toolBox->addItem(init(q.unten, receiver), QObject::tr(""));
		toolBox->addItem(init(q.seite, receiver), QObject::tr(""));
		return toolBox;
	}
	
}
