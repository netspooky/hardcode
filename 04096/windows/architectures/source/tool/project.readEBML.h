namespace project
{
	void readStruct(EBMLReader& r, Unten& v, size_t maxSize)
	{
		v._size = r.readSize(maxSize);
		size_t start = r.getByteCount();
		while (r.getByteCount() - start < v._size)
		{
			uint32_t id = r.readID();
			switch (id)
			{
			case 0x80:
				r.read(v.cameraTime);
				break;
			case 0x81:
				r.read(v.cameraTimeFine);
				break;
			case 0x82:
				r.read(v.animationTime);
				break;
			case 0x83:
				r.read(v.animationTimeFine);
				break;
			case 0x84:
				r.read(v.cameraDistance);
				break;
			case 0x85:
				r.read(v.flags);
				break;
			default:
				r.skip(r.readSize(maxSize));
			};
		};
	}
	
	void readStruct(EBMLReader& r, Seite& v, size_t maxSize)
	{
		v._size = r.readSize(maxSize);
		size_t start = r.getByteCount();
		while (r.getByteCount() - start < v._size)
		{
			uint32_t id = r.readID();
			switch (id)
			{
			case 0x82:
				r.read(v.zoomSpeed);
				break;
			case 0x83:
				r.read(v.cameraSpeed);
				break;
			case 0x84:
				r.read(v.animationSpeed);
				break;
			case 0x85:
				r.read(v.objectsBlackAndFlat);
				break;
			case 0x86:
				r.read(v.objectsWhite);
				break;
			case 0x87:
				r.read(v.backgroundBlack);
				break;
			case 0x88:
				r.read(v.polyDivShift);
				break;
			case 0x89:
				r.read(v.architecture);
				break;
			case 0x8a:
				r.read(v.play);
				break;
			case 0x8b:
				r.read(v.cameraScene);
				break;
			case 0x8c:
				r.read(v.animationScene);
				break;
			case 0x8d:
				r.read(v.flagsAccu);
				break;
			case 0x8e:
				r.read(v.beat);
				break;
			case 0x8f:
				r.read(v.scene);
				break;
			default:
				r.skip(r.readSize(maxSize));
			};
		};
	}
	
	void readStruct(EBMLReader& r, Project& v, size_t maxSize)
	{
		v._size = r.readSize(maxSize);
		size_t start = r.getByteCount();
		while (r.getByteCount() - start < v._size)
		{
			uint32_t id = r.readID();
			switch (id)
			{
			case 0x200001:
				readStruct(r, v.unten, 268435456u);
				break;
			case 0x200002:
				readStruct(r, v.seite, 268435456u);
				break;
			default:
				r.skip(r.readSize(maxSize));
			};
		};
	}
	
	namespace project
	{
		void read(EBMLReader& r, Project& v)
		{
			if (r.readID() != 0x200000)
				throw digi::DataException(r.getDevice(), digi::DataException::FORMAT_ERROR);
			readStruct(r, v, 268435456u);
		}
	}
	
}
