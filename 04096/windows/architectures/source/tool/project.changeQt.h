namespace project
{
	int change(QtUnten& q, Unten& v, QObject* sender, int* path)
	{
		if (sender == q.cameraTime)
		{
			v.cameraTime = q.cameraTime->value();
			q._slider_cameraTime->blockSignals(true);
			q._slider_cameraTime->setValue(int(v.cameraTime * 10.0f + 0.5f));
			q._slider_cameraTime->blockSignals(false);
			*path = event::cameraTime;
			return event::set;
		}
		if (sender == q._slider_cameraTime)
		{
			v.cameraTime = float(q._slider_cameraTime->value()) * 0.1f + 0.0f;
			q.cameraTime->setValue(v.cameraTime);
			*path = event::cameraTime;
			return event::set;
		}
		if (sender == q.cameraTimeFine)
		{
			v.cameraTimeFine = q.cameraTimeFine->value();
			q._slider_cameraTimeFine->blockSignals(true);
			q._slider_cameraTimeFine->setValue(int(v.cameraTimeFine * 100.0f + 0.5f));
			q._slider_cameraTimeFine->blockSignals(false);
			*path = event::cameraTimeFine;
			return event::set;
		}
		if (sender == q._slider_cameraTimeFine)
		{
			v.cameraTimeFine = float(q._slider_cameraTimeFine->value()) * 0.01f + 0.0f;
			q.cameraTimeFine->setValue(v.cameraTimeFine);
			*path = event::cameraTimeFine;
			return event::set;
		}
		if (sender == q.animationTime)
		{
			v.animationTime = q.animationTime->value();
			q._slider_animationTime->blockSignals(true);
			q._slider_animationTime->setValue(int(v.animationTime * 1.0f + 0.5f));
			q._slider_animationTime->blockSignals(false);
			*path = event::animationTime;
			return event::set;
		}
		if (sender == q._slider_animationTime)
		{
			v.animationTime = float(q._slider_animationTime->value()) * 1.0f + 0.0f;
			q.animationTime->setValue(v.animationTime);
			*path = event::animationTime;
			return event::set;
		}
		if (sender == q.animationTimeFine)
		{
			v.animationTimeFine = q.animationTimeFine->value();
			q._slider_animationTimeFine->blockSignals(true);
			q._slider_animationTimeFine->setValue(int(v.animationTimeFine * 100.0f + 0.5f));
			q._slider_animationTimeFine->blockSignals(false);
			*path = event::animationTimeFine;
			return event::set;
		}
		if (sender == q._slider_animationTimeFine)
		{
			v.animationTimeFine = float(q._slider_animationTimeFine->value()) * 0.01f + 0.0f;
			q.animationTimeFine->setValue(v.animationTimeFine);
			*path = event::animationTimeFine;
			return event::set;
		}
		if (sender == q.cameraDistance)
		{
			v.cameraDistance = q.cameraDistance->value();
			q._slider_cameraDistance->blockSignals(true);
			q._slider_cameraDistance->setValue(int(v.cameraDistance * 0.1f + 0.5f));
			q._slider_cameraDistance->blockSignals(false);
			*path = event::cameraDistance;
			return event::set;
		}
		if (sender == q._slider_cameraDistance)
		{
			v.cameraDistance = float(q._slider_cameraDistance->value()) * 10.0f + 0.0f;
			q.cameraDistance->setValue(v.cameraDistance);
			*path = event::cameraDistance;
			return event::set;
		}
		if (sender == q.flags)
		{
				v.flags = q.flags->value();
			*path = event::flags;
			return event::set;
		}
		return event::null;
	}
	
	int change(QtSeite& q, Seite& v, QObject* sender, int* path)
	{
		if (sender == q.zoomSpeed)
		{
			v.zoomSpeed = q.zoomSpeed->value();
			q._slider_zoomSpeed->blockSignals(true);
			q._slider_zoomSpeed->setValue(int(v.zoomSpeed * 5.0f + 500.5f));
			q._slider_zoomSpeed->blockSignals(false);
			*path = event::zoomSpeed;
			return event::set;
		}
		if (sender == q._slider_zoomSpeed)
		{
			v.zoomSpeed = float(q._slider_zoomSpeed->value()) * 0.2f + -100.0f;
			q.zoomSpeed->setValue(v.zoomSpeed);
			*path = event::zoomSpeed;
			return event::set;
		}
		if (sender == q.cameraSpeed)
		{
			v.cameraSpeed = q.cameraSpeed->value();
			q._slider_cameraSpeed->blockSignals(true);
			q._slider_cameraSpeed->setValue(int(v.cameraSpeed * 5.0f + 500.5f));
			q._slider_cameraSpeed->blockSignals(false);
			*path = event::cameraSpeed;
			return event::set;
		}
		if (sender == q._slider_cameraSpeed)
		{
			v.cameraSpeed = float(q._slider_cameraSpeed->value()) * 0.2f + -100.0f;
			q.cameraSpeed->setValue(v.cameraSpeed);
			*path = event::cameraSpeed;
			return event::set;
		}
		if (sender == q.animationSpeed)
		{
			v.animationSpeed = q.animationSpeed->value();
			q._slider_animationSpeed->blockSignals(true);
			q._slider_animationSpeed->setValue(int(v.animationSpeed * 5.0f + 500.5f));
			q._slider_animationSpeed->blockSignals(false);
			*path = event::animationSpeed;
			return event::set;
		}
		if (sender == q._slider_animationSpeed)
		{
			v.animationSpeed = float(q._slider_animationSpeed->value()) * 0.2f + -100.0f;
			q.animationSpeed->setValue(v.animationSpeed);
			*path = event::animationSpeed;
			return event::set;
		}
		if (sender == q.objectsBlackAndFlat)
		{
			v.objectsBlackAndFlat = q.objectsBlackAndFlat->isChecked();
			*path = event::objectsBlackAndFlat;
			return event::set;
		}
		if (sender == q.objectsWhite)
		{
			v.objectsWhite = q.objectsWhite->isChecked();
			*path = event::objectsWhite;
			return event::set;
		}
		if (sender == q.backgroundBlack)
		{
			v.backgroundBlack = q.backgroundBlack->isChecked();
			*path = event::backgroundBlack;
			return event::set;
		}
		if (sender == q.polyDivShift)
		{
			v.polyDivShift = q.polyDivShift->value();
			q._slider_polyDivShift->blockSignals(true);
			q._slider_polyDivShift->setValue(v.polyDivShift);
			q._slider_polyDivShift->blockSignals(false);
			*path = event::polyDivShift;
			return event::set;
		}
		if (sender == q._slider_polyDivShift)
		{
			v.polyDivShift = q._slider_polyDivShift->value();
			q.polyDivShift->setValue(v.polyDivShift);
			*path = event::polyDivShift;
			return event::set;
		}
		if (sender == q.architecture)
		{
			v.architecture = q.architecture->isChecked();
			*path = event::architecture;
			return event::set;
		}
		if (sender == q.play)
		{
			v.play = q.play->isChecked();
			*path = event::play;
			return event::set;
		}
		if (sender == q.cameraScene)
		{
				v.cameraScene = q.cameraScene->value();
			*path = event::cameraScene;
			return event::set;
		}
		if (sender == q.animationScene)
		{
				v.animationScene = q.animationScene->value();
			*path = event::animationScene;
			return event::set;
		}
		if (sender == q.flagsAccu)
		{
				v.flagsAccu = q.flagsAccu->value();
			*path = event::flagsAccu;
			return event::set;
		}
		if (sender == q.beat)
		{
				v.beat = q.beat->value();
			*path = event::beat;
			return event::set;
		}
		if (sender == q.scene)
		{
			v.scene = q.scene->text().toUtf8().data();
			*path = event::scene;
			return event::set;
		}
		return event::null;
	}
	
	int change(QtProject& q, Project& v, QObject* sender, int* path)
	{
		{
			int command = change(q.unten, v.unten, sender, path + 1);
			if (command != event::null)
			{
				*path = event::unten;
				return command;
			}
		}
		{
			int command = change(q.seite, v.seite, sender, path + 1);
			if (command != event::null)
			{
				*path = event::seite;
				return command;
			}
		}
		return event::null;
	}
	
}
