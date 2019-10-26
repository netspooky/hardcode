namespace project
{
	void writeStruct(JSONWriter& w, Unten& s)
	{
		w.beginStruct();
		w.writeAttribute("cameraTime");
		w.writeNumber(lexicalCast<std::string>(s.cameraTime));
		w.writeAttribute("cameraTimeFine");
		w.writeNumber(lexicalCast<std::string>(s.cameraTimeFine));
		w.writeAttribute("animationTime");
		w.writeNumber(lexicalCast<std::string>(s.animationTime));
		w.writeAttribute("animationTimeFine");
		w.writeNumber(lexicalCast<std::string>(s.animationTimeFine));
		w.writeAttribute("cameraDistance");
		w.writeNumber(lexicalCast<std::string>(s.cameraDistance));
		w.writeAttribute("flags");
		w.writeNumber(lexicalCast<std::string>(s.flags));
		w.endStruct();
	}
	
	void writeStruct(JSONWriter& w, Seite& s)
	{
		w.beginStruct();
		w.writeAttribute("zoomSpeed");
		w.writeNumber(lexicalCast<std::string>(s.zoomSpeed));
		w.writeAttribute("cameraSpeed");
		w.writeNumber(lexicalCast<std::string>(s.cameraSpeed));
		w.writeAttribute("animationSpeed");
		w.writeNumber(lexicalCast<std::string>(s.animationSpeed));
		w.writeAttribute("objectsBlackAndFlat");
		w.writeBool(s.objectsBlackAndFlat);
		w.writeAttribute("objectsWhite");
		w.writeBool(s.objectsWhite);
		w.writeAttribute("backgroundBlack");
		w.writeBool(s.backgroundBlack);
		w.writeAttribute("polyDivShift");
		w.writeNumber(lexicalCast<std::string>(s.polyDivShift));
		w.writeAttribute("architecture");
		w.writeBool(s.architecture);
		w.writeAttribute("play");
		w.writeBool(s.play);
		w.writeAttribute("cameraScene");
		w.writeNumber(lexicalCast<std::string>(s.cameraScene));
		w.writeAttribute("animationScene");
		w.writeNumber(lexicalCast<std::string>(s.animationScene));
		w.writeAttribute("flagsAccu");
		w.writeNumber(lexicalCast<std::string>(s.flagsAccu));
		w.writeAttribute("beat");
		w.writeNumber(lexicalCast<std::string>(s.beat));
		w.writeAttribute("scene");
		w.writeString(s.scene);
		w.endStruct();
	}
	
	void writeStruct(JSONWriter& w, Project& s)
	{
		w.beginStruct();
		w.writeAttribute("unten");
		writeStruct(w, s.unten);
		w.writeAttribute("seite");
		writeStruct(w, s.seite);
		w.endStruct();
	}
	
	namespace project
	{
		void write(JSONWriter& w, Project& v)
		{
			w.beginStruct();
			w.writeAttribute("project");
			writeStruct(w, v);
			w.endStruct();
		}
	}
	
}
