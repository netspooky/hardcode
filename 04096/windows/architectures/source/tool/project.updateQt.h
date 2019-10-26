namespace project
{
	void update(QtUnten& q, Unten& v, int* path)
	{
		switch (*path)
		{
		case event::null:
			write(q, v);
			break;
		case event::cameraTime:
			q.cameraTime->setText(QString::fromUtf8(boost::lexical_cast<std::string>(v.cameraTime).c_str()));
			q._slider_cameraTime->blockSignals(true);
			q._slider_cameraTime->setValue(int(v.cameraTime * 10.0f + 0.5f));
			q._slider_cameraTime->blockSignals(false);
			break;
		case event::cameraTimeFine:
			q.cameraTimeFine->setText(QString::fromUtf8(boost::lexical_cast<std::string>(v.cameraTimeFine).c_str()));
			q._slider_cameraTimeFine->blockSignals(true);
			q._slider_cameraTimeFine->setValue(int(v.cameraTimeFine * 100.0f + 0.5f));
			q._slider_cameraTimeFine->blockSignals(false);
			break;
		case event::animationTime:
			q.animationTime->setText(QString::fromUtf8(boost::lexical_cast<std::string>(v.animationTime).c_str()));
			q._slider_animationTime->blockSignals(true);
			q._slider_animationTime->setValue(int(v.animationTime * 1.0f + 0.5f));
			q._slider_animationTime->blockSignals(false);
			break;
		case event::animationTimeFine:
			q.animationTimeFine->setText(QString::fromUtf8(boost::lexical_cast<std::string>(v.animationTimeFine).c_str()));
			q._slider_animationTimeFine->blockSignals(true);
			q._slider_animationTimeFine->setValue(int(v.animationTimeFine * 100.0f + 0.5f));
			q._slider_animationTimeFine->blockSignals(false);
			break;
		case event::cameraDistance:
			q.cameraDistance->setText(QString::fromUtf8(boost::lexical_cast<std::string>(v.cameraDistance).c_str()));
			q._slider_cameraDistance->blockSignals(true);
			q._slider_cameraDistance->setValue(int(v.cameraDistance * 0.1f + 0.5f));
			q._slider_cameraDistance->blockSignals(false);
			break;
		case event::flags:
			q.flags->setText(QString::fromUtf8(boost::lexical_cast<std::string>(v.flags).c_str()));
			break;
		}
	}
	
	void update(QtSeite& q, Seite& v, int* path)
	{
		switch (*path)
		{
		case event::null:
			write(q, v);
			break;
		case event::zoomSpeed:
			q.zoomSpeed->setText(QString::fromUtf8(boost::lexical_cast<std::string>(v.zoomSpeed).c_str()));
			q._slider_zoomSpeed->blockSignals(true);
			q._slider_zoomSpeed->setValue(int(v.zoomSpeed * 5.0f + 500.5f));
			q._slider_zoomSpeed->blockSignals(false);
			break;
		case event::cameraSpeed:
			q.cameraSpeed->setText(QString::fromUtf8(boost::lexical_cast<std::string>(v.cameraSpeed).c_str()));
			q._slider_cameraSpeed->blockSignals(true);
			q._slider_cameraSpeed->setValue(int(v.cameraSpeed * 5.0f + 500.5f));
			q._slider_cameraSpeed->blockSignals(false);
			break;
		case event::animationSpeed:
			q.animationSpeed->setText(QString::fromUtf8(boost::lexical_cast<std::string>(v.animationSpeed).c_str()));
			q._slider_animationSpeed->blockSignals(true);
			q._slider_animationSpeed->setValue(int(v.animationSpeed * 5.0f + 500.5f));
			q._slider_animationSpeed->blockSignals(false);
			break;
		case event::objectsBlackAndFlat:
			q.objectsBlackAndFlat->setChecked(v.objectsBlackAndFlat);
			break;
		case event::objectsWhite:
			q.objectsWhite->setChecked(v.objectsWhite);
			break;
		case event::backgroundBlack:
			q.backgroundBlack->setChecked(v.backgroundBlack);
			break;
		case event::polyDivShift:
			q.polyDivShift->setText(QString::fromUtf8(boost::lexical_cast<std::string>(v.polyDivShift).c_str()));
			q._slider_polyDivShift->blockSignals(true);
			q._slider_polyDivShift->setValue(v.polyDivShift);
			q._slider_polyDivShift->blockSignals(false);
			break;
		case event::architecture:
			q.architecture->setChecked(v.architecture);
			break;
		case event::play:
			q.play->setChecked(v.play);
			break;
		case event::cameraScene:
			q.cameraScene->setText(QString::fromUtf8(boost::lexical_cast<std::string>(v.cameraScene).c_str()));
			break;
		case event::animationScene:
			q.animationScene->setText(QString::fromUtf8(boost::lexical_cast<std::string>(v.animationScene).c_str()));
			break;
		case event::flagsAccu:
			q.flagsAccu->setText(QString::fromUtf8(boost::lexical_cast<std::string>(v.flagsAccu).c_str()));
			break;
		case event::beat:
			q.beat->setText(QString::fromUtf8(boost::lexical_cast<std::string>(v.beat).c_str()));
			break;
		case event::scene:
			q.scene->setText(QString::fromUtf8(v.scene.c_str()));
			break;
		}
	}
	
	void update(QtProject& q, Project& v, int* path)
	{
		switch (*path)
		{
		case event::null:
			write(q, v);
			break;
		case event::unten:
			update(q.unten, v.unten, path + 1);
			break;
		case event::seite:
			update(q.seite, v.seite, path + 1);
			break;
		}
	}
	
}
