namespace project
{
	size_t calcStructSize(Unten& v)
	{
		v._size = 0;
		v._size += 1 + EBMLWriter::calcSize(v.cameraTime);
		v._size += 1 + EBMLWriter::calcSize(v.cameraTimeFine);
		v._size += 1 + EBMLWriter::calcSize(v.animationTime);
		v._size += 1 + EBMLWriter::calcSize(v.animationTimeFine);
		v._size += 1 + EBMLWriter::calcSize(v.cameraDistance);
		v._size += 1 + EBMLWriter::calcSize(v.flags);
		return EBMLWriter::calcSizeVarInt(v._size) + v._size;
	}
	
	void writeStruct(EBMLWriter& w, Unten& v)
	{
		w.writeVarInt(v._size);
		w.write(0x80, v.cameraTime);
		w.write(0x81, v.cameraTimeFine);
		w.write(0x82, v.animationTime);
		w.write(0x83, v.animationTimeFine);
		w.write(0x84, v.cameraDistance);
		w.write(0x85, v.flags);
	}
	
	size_t calcStructSize(Seite& v)
	{
		v._size = 0;
		v._size += 1 + EBMLWriter::calcSize(v.zoomSpeed);
		v._size += 1 + EBMLWriter::calcSize(v.cameraSpeed);
		v._size += 1 + EBMLWriter::calcSize(v.animationSpeed);
		v._size += 1 + EBMLWriter::calcSize(v.objectsBlackAndFlat);
		v._size += 1 + EBMLWriter::calcSize(v.objectsWhite);
		v._size += 1 + EBMLWriter::calcSize(v.backgroundBlack);
		v._size += 1 + EBMLWriter::calcSize(v.polyDivShift);
		v._size += 1 + EBMLWriter::calcSize(v.architecture);
		v._size += 1 + EBMLWriter::calcSize(v.play);
		v._size += 1 + EBMLWriter::calcSize(v.cameraScene);
		v._size += 1 + EBMLWriter::calcSize(v.animationScene);
		v._size += 1 + EBMLWriter::calcSize(v.flagsAccu);
		v._size += 1 + EBMLWriter::calcSize(v.beat);
		v._size += 1 + EBMLWriter::calcSize(v.scene);
		return EBMLWriter::calcSizeVarInt(v._size) + v._size;
	}
	
	void writeStruct(EBMLWriter& w, Seite& v)
	{
		w.writeVarInt(v._size);
		w.write(0x82, v.zoomSpeed);
		w.write(0x83, v.cameraSpeed);
		w.write(0x84, v.animationSpeed);
		w.write(0x85, v.objectsBlackAndFlat);
		w.write(0x86, v.objectsWhite);
		w.write(0x87, v.backgroundBlack);
		w.write(0x88, v.polyDivShift);
		w.write(0x89, v.architecture);
		w.write(0x8a, v.play);
		w.write(0x8b, v.cameraScene);
		w.write(0x8c, v.animationScene);
		w.write(0x8d, v.flagsAccu);
		w.write(0x8e, v.beat);
		w.write(0x8f, v.scene);
	}
	
	size_t calcStructSize(Project& v)
	{
		v._size = 0;
		v._size += 3 + calcStructSize(v.unten);
		v._size += 3 + calcStructSize(v.seite);
		return EBMLWriter::calcSizeVarInt(v._size) + v._size;
	}
	
	void writeStruct(EBMLWriter& w, Project& v)
	{
		w.writeVarInt(v._size);
		w.writeID(0x200001);
		writeStruct(w, v.unten);
		w.writeID(0x200002);
		writeStruct(w, v.seite);
	}
	
	namespace project
	{
		size_t calcSize(Project& v)
		{
			return 3 + calcStructSize(v);
		}
		
		void write(EBMLWriter& w, Project& v)
		{
			calcStructSize(v);
			w.writeID(0x200000);
			writeStruct(w, v);
		}
	}
	
}
