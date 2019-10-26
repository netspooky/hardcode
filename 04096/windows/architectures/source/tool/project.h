#ifndef GENERATED_project_h
#define GENERATED_project_h

namespace project
{
	struct Unten
	{
		size_t _size;
		float cameraTime;
		float cameraTimeFine;
		float animationTime;
		float animationTimeFine;
		float cameraDistance;
		int32_t flags;
		
		Unten() : _size(), cameraTime(0), cameraTimeFine(0), animationTime(0), animationTimeFine(0), cameraDistance(0), flags(0) {}
		bool operator ==(const Unten&) const {return false;}
	};
	
	struct Seite
	{
		size_t _size;
		float zoomSpeed;
		float cameraSpeed;
		float animationSpeed;
		bool objectsBlackAndFlat;
		bool objectsWhite;
		bool backgroundBlack;
		int32_t polyDivShift;
		bool architecture;
		bool play;
		float cameraScene;
		float animationScene;
		int32_t flagsAccu;
		float beat;
		std::string scene;
		
		Seite() : _size(), zoomSpeed(0), cameraSpeed(0), animationSpeed(0), objectsBlackAndFlat(false), objectsWhite(false), backgroundBlack(false), polyDivShift(0), architecture(false), play(false), cameraScene(0), animationScene(0), flagsAccu(0), beat(0) {}
		bool operator ==(const Seite&) const {return false;}
	};
	
	struct Project
	{
		size_t _size;
		Unten unten;
		Seite seite;
		
		Project() : _size() {}
		bool operator ==(const Project&) const {return false;}
	};
	
	namespace event
	{
		enum
		{
			null = -1,
			set,
			add,
			erase,
			animationScene,
			animationSpeed,
			animationTime,
			animationTimeFine,
			architecture,
			backgroundBlack,
			beat,
			cameraDistance,
			cameraScene,
			cameraSpeed,
			cameraTime,
			cameraTimeFine,
			flags,
			flagsAccu,
			objectsBlackAndFlat,
			objectsWhite,
			play,
			polyDivShift,
			scene,
			seite,
			unten,
			zoomSpeed,
		};
	}
	
	namespace project
	{
		const uint32_t ebml = 0x200000;
	}
	
} // project
#endif
