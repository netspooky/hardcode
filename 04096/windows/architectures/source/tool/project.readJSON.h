namespace project
{
	void readStruct(JSONReader& r, Unten& s)
	{
		JSONReader::Token token;
		while ((token = r.read()) == JSONReader::ATTRIBUTE)
		{
			static const char* ids[] =
			{
				"animationTime",
				"animationTimeFine",
				"cameraDistance",
				"cameraTime",
				"cameraTimeFine",
				"flags",
			};
			size_t index = findIndex(ids, 6u, r.getValue());
			token = r.read();
			switch (index)
			{
			case 0:
				if (token != JSONReader::NUMBER)
					throw digi::DataException(r.getDevice(), digi::DataException::FORMAT_ERROR);
				s.animationTime = lexicalCast<float>(r.getValue());
				break;
			case 1:
				if (token != JSONReader::NUMBER)
					throw digi::DataException(r.getDevice(), digi::DataException::FORMAT_ERROR);
				s.animationTimeFine = lexicalCast<float>(r.getValue());
				break;
			case 2:
				if (token != JSONReader::NUMBER)
					throw digi::DataException(r.getDevice(), digi::DataException::FORMAT_ERROR);
				s.cameraDistance = lexicalCast<float>(r.getValue());
				break;
			case 3:
				if (token != JSONReader::NUMBER)
					throw digi::DataException(r.getDevice(), digi::DataException::FORMAT_ERROR);
				s.cameraTime = lexicalCast<float>(r.getValue());
				break;
			case 4:
				if (token != JSONReader::NUMBER)
					throw digi::DataException(r.getDevice(), digi::DataException::FORMAT_ERROR);
				s.cameraTimeFine = lexicalCast<float>(r.getValue());
				break;
			case 5:
				if (token != JSONReader::NUMBER)
					throw digi::DataException(r.getDevice(), digi::DataException::FORMAT_ERROR);
				s.flags = lexicalCast<int32_t>(r.getValue());
				break;
			default:
				r.skipValue(token);
			}
		}
	}
	
	void readStruct(JSONReader& r, Seite& s)
	{
		JSONReader::Token token;
		while ((token = r.read()) == JSONReader::ATTRIBUTE)
		{
			static const char* ids[] =
			{
				"animationScene",
				"animationSpeed",
				"architecture",
				"backgroundBlack",
				"beat",
				"cameraScene",
				"cameraSpeed",
				"flagsAccu",
				"objectsBlackAndFlat",
				"objectsWhite",
				"play",
				"polyDivShift",
				"scene",
				"zoomSpeed",
			};
			size_t index = findIndex(ids, 14u, r.getValue());
			token = r.read();
			switch (index)
			{
			case 0:
				if (token != JSONReader::NUMBER)
					throw digi::DataException(r.getDevice(), digi::DataException::FORMAT_ERROR);
				s.animationScene = lexicalCast<float>(r.getValue());
				break;
			case 1:
				if (token != JSONReader::NUMBER)
					throw digi::DataException(r.getDevice(), digi::DataException::FORMAT_ERROR);
				s.animationSpeed = lexicalCast<float>(r.getValue());
				break;
			case 2:
				if (token != JSONReader::BOOLEAN)
					throw digi::DataException(r.getDevice(), digi::DataException::FORMAT_ERROR);
				s.architecture = r.getBool();
				break;
			case 3:
				if (token != JSONReader::BOOLEAN)
					throw digi::DataException(r.getDevice(), digi::DataException::FORMAT_ERROR);
				s.backgroundBlack = r.getBool();
				break;
			case 4:
				if (token != JSONReader::NUMBER)
					throw digi::DataException(r.getDevice(), digi::DataException::FORMAT_ERROR);
				s.beat = lexicalCast<float>(r.getValue());
				break;
			case 5:
				if (token != JSONReader::NUMBER)
					throw digi::DataException(r.getDevice(), digi::DataException::FORMAT_ERROR);
				s.cameraScene = lexicalCast<float>(r.getValue());
				break;
			case 6:
				if (token != JSONReader::NUMBER)
					throw digi::DataException(r.getDevice(), digi::DataException::FORMAT_ERROR);
				s.cameraSpeed = lexicalCast<float>(r.getValue());
				break;
			case 7:
				if (token != JSONReader::NUMBER)
					throw digi::DataException(r.getDevice(), digi::DataException::FORMAT_ERROR);
				s.flagsAccu = lexicalCast<int32_t>(r.getValue());
				break;
			case 8:
				if (token != JSONReader::BOOLEAN)
					throw digi::DataException(r.getDevice(), digi::DataException::FORMAT_ERROR);
				s.objectsBlackAndFlat = r.getBool();
				break;
			case 9:
				if (token != JSONReader::BOOLEAN)
					throw digi::DataException(r.getDevice(), digi::DataException::FORMAT_ERROR);
				s.objectsWhite = r.getBool();
				break;
			case 10:
				if (token != JSONReader::BOOLEAN)
					throw digi::DataException(r.getDevice(), digi::DataException::FORMAT_ERROR);
				s.play = r.getBool();
				break;
			case 11:
				if (token != JSONReader::NUMBER)
					throw digi::DataException(r.getDevice(), digi::DataException::FORMAT_ERROR);
				s.polyDivShift = lexicalCast<int32_t>(r.getValue());
				break;
			case 12:
				if (token != JSONReader::STRING)
					throw digi::DataException(r.getDevice(), digi::DataException::FORMAT_ERROR);
				s.scene = r.getValue();
				break;
			case 13:
				if (token != JSONReader::NUMBER)
					throw digi::DataException(r.getDevice(), digi::DataException::FORMAT_ERROR);
				s.zoomSpeed = lexicalCast<float>(r.getValue());
				break;
			default:
				r.skipValue(token);
			}
		}
	}
	
	void readStruct(JSONReader& r, Project& s)
	{
		JSONReader::Token token;
		while ((token = r.read()) == JSONReader::ATTRIBUTE)
		{
			static const char* ids[] =
			{
				"seite",
				"unten",
			};
			size_t index = findIndex(ids, 2u, r.getValue());
			token = r.read();
			switch (index)
			{
			case 0:
				if (token != JSONReader::BEGIN_STRUCT)
					throw digi::DataException(r.getDevice(), digi::DataException::FORMAT_ERROR);
				readStruct(r, s.seite);
				break;
			case 1:
				if (token != JSONReader::BEGIN_STRUCT)
					throw digi::DataException(r.getDevice(), digi::DataException::FORMAT_ERROR);
				readStruct(r, s.unten);
				break;
			default:
				r.skipValue(token);
			}
		}
	}
	
	namespace project
	{
		void read(JSONReader& r, Project& v)
		{
			if (r.read() != JSONReader::BEGIN_STRUCT || r.read() != JSONReader::ATTRIBUTE || r.getValue() != "project" || r.read() != JSONReader::BEGIN_STRUCT)
				throw digi::DataException(r.getDevice(), digi::DataException::FORMAT_ERROR);
			readStruct(r, v);
			r.read();
		}
	}
	
}
