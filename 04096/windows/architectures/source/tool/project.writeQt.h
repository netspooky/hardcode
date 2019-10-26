namespace project
{
	void write(QtUnten& q, const Unten& v)
	{
		q.cameraTime->setText(QString::fromUtf8(boost::lexical_cast<std::string>(v.cameraTime).c_str()));
		q._slider_cameraTime->blockSignals(true);
		q._slider_cameraTime->setValue(int(v.cameraTime * 10.0f + 0.5f));
		q._slider_cameraTime->blockSignals(false);
		q.cameraTimeFine->setText(QString::fromUtf8(boost::lexical_cast<std::string>(v.cameraTimeFine).c_str()));
		q._slider_cameraTimeFine->blockSignals(true);
		q._slider_cameraTimeFine->setValue(int(v.cameraTimeFine * 100.0f + 0.5f));
		q._slider_cameraTimeFine->blockSignals(false);
		q.animationTime->setText(QString::fromUtf8(boost::lexical_cast<std::string>(v.animationTime).c_str()));
		q._slider_animationTime->blockSignals(true);
		q._slider_animationTime->setValue(int(v.animationTime * 1.0f + 0.5f));
		q._slider_animationTime->blockSignals(false);
		q.animationTimeFine->setText(QString::fromUtf8(boost::lexical_cast<std::string>(v.animationTimeFine).c_str()));
		q._slider_animationTimeFine->blockSignals(true);
		q._slider_animationTimeFine->setValue(int(v.animationTimeFine * 100.0f + 0.5f));
		q._slider_animationTimeFine->blockSignals(false);
		q.cameraDistance->setText(QString::fromUtf8(boost::lexical_cast<std::string>(v.cameraDistance).c_str()));
		q._slider_cameraDistance->blockSignals(true);
		q._slider_cameraDistance->setValue(int(v.cameraDistance * 0.1f + 0.5f));
		q._slider_cameraDistance->blockSignals(false);
		q.flags->setText(QString::fromUtf8(boost::lexical_cast<std::string>(v.flags).c_str()));
	}
	
	void write(QtSeite& q, const Seite& v)
	{
		q.zoomSpeed->setText(QString::fromUtf8(boost::lexical_cast<std::string>(v.zoomSpeed).c_str()));
		q._slider_zoomSpeed->blockSignals(true);
		q._slider_zoomSpeed->setValue(int(v.zoomSpeed * 5.0f + 500.5f));
		q._slider_zoomSpeed->blockSignals(false);
		q.cameraSpeed->setText(QString::fromUtf8(boost::lexical_cast<std::string>(v.cameraSpeed).c_str()));
		q._slider_cameraSpeed->blockSignals(true);
		q._slider_cameraSpeed->setValue(int(v.cameraSpeed * 5.0f + 500.5f));
		q._slider_cameraSpeed->blockSignals(false);
		q.animationSpeed->setText(QString::fromUtf8(boost::lexical_cast<std::string>(v.animationSpeed).c_str()));
		q._slider_animationSpeed->blockSignals(true);
		q._slider_animationSpeed->setValue(int(v.animationSpeed * 5.0f + 500.5f));
		q._slider_animationSpeed->blockSignals(false);
		q.objectsBlackAndFlat->setChecked(v.objectsBlackAndFlat);
		q.objectsWhite->setChecked(v.objectsWhite);
		q.backgroundBlack->setChecked(v.backgroundBlack);
		q.polyDivShift->setText(QString::fromUtf8(boost::lexical_cast<std::string>(v.polyDivShift).c_str()));
		q._slider_polyDivShift->blockSignals(true);
		q._slider_polyDivShift->setValue(v.polyDivShift);
		q._slider_polyDivShift->blockSignals(false);
		q.architecture->setChecked(v.architecture);
		q.play->setChecked(v.play);
		q.cameraScene->setText(QString::fromUtf8(boost::lexical_cast<std::string>(v.cameraScene).c_str()));
		q.animationScene->setText(QString::fromUtf8(boost::lexical_cast<std::string>(v.animationScene).c_str()));
		q.flagsAccu->setText(QString::fromUtf8(boost::lexical_cast<std::string>(v.flagsAccu).c_str()));
		q.beat->setText(QString::fromUtf8(boost::lexical_cast<std::string>(v.beat).c_str()));
		q.scene->setText(QString::fromUtf8(v.scene.c_str()));
	}
	
	void write(QtProject& q, const Project& v)
	{
		write(q.unten, v.unten);
		write(q.seite, v.seite);
	}
	
}
