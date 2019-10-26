namespace project
{
	struct QtUnten
	{
		NumericLineEdit<float>* cameraTime;
		QSlider* _slider_cameraTime;
		NumericLineEdit<float>* cameraTimeFine;
		QSlider* _slider_cameraTimeFine;
		NumericLineEdit<float>* animationTime;
		QSlider* _slider_animationTime;
		NumericLineEdit<float>* animationTimeFine;
		QSlider* _slider_animationTimeFine;
		NumericLineEdit<float>* cameraDistance;
		QSlider* _slider_cameraDistance;
		NumericLineEdit<int32_t>* flags;
	};
	
	struct QtSeite
	{
		NumericLineEdit<float>* zoomSpeed;
		QSlider* _slider_zoomSpeed;
		NumericLineEdit<float>* cameraSpeed;
		QSlider* _slider_cameraSpeed;
		NumericLineEdit<float>* animationSpeed;
		QSlider* _slider_animationSpeed;
		QCheckBox* objectsBlackAndFlat;
		QCheckBox* objectsWhite;
		QCheckBox* backgroundBlack;
		NumericLineEdit<int32_t>* polyDivShift;
		QSlider* _slider_polyDivShift;
		QCheckBox* architecture;
		QCheckBox* play;
		NumericLineEdit<float>* cameraScene;
		NumericLineEdit<float>* animationScene;
		NumericLineEdit<int32_t>* flagsAccu;
		NumericLineEdit<float>* beat;
		QLineEdit* scene;
	};
	
	struct QtProject
	{
		QtUnten unten;
		QtSeite seite;
	};
	
}
