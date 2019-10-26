cmake_minimum_required(VERSION 2.8)

# set project (visual studio: solution)
project(Architectures)

# set default postfixes (can be overridden on the command line)
set(CMAKE_DEBUG_POSTFIX "d" CACHE STRING "Postfix for output library name in Debug build")
set(CMAKE_RELWITHDEBINFO_POSTFIX "r" CACHE STRING "Postfix for output library name in RelWithDebInfo build") 

include(Macros.cmake)


# import boost
set(Boost_USE_STATIC_LIBS ON)
find_package(Boost COMPONENTS system filesystem thread)

# import digi
find_package(Digi COMPONENTS Data)

# import packages that digi depends on
foreach(package ${Digi_PACKAGES})
	find_package(${package})
endforeach() 

# import QT
find_package(Qt4 COMPONENTS QtCore QtGui QtOpenGL)
include(${QT_USE_FILE})

# import GL
find_package(OpenGL REQUIRED) 

# set include directories
include_directories(${Boost_INCLUDE_DIRS} ${Digi_INCLUDE_DIRS})

# set preprocessor definitions and compiler switches
add_definitions(${Boost_DEFINITIONS} ${Digi_DEFINITIONS} -DBOOST_ALL_NO_LIB)

# find structio
find_program(STRUCTIO structio) 

# generate project.h, project.readEBML.h and project.writeEBML.h
add_custom_command(
	OUTPUT
		${CMAKE_CURRENT_SOURCE_DIR}/project.h
		${CMAKE_CURRENT_SOURCE_DIR}/project.readEBML.h
		${CMAKE_CURRENT_SOURCE_DIR}/project.writeEBML.h
		${CMAKE_CURRENT_SOURCE_DIR}/project.Qt.h
		${CMAKE_CURRENT_SOURCE_DIR}/project.initQt.h
		${CMAKE_CURRENT_SOURCE_DIR}/project.writeQt.h
		${CMAKE_CURRENT_SOURCE_DIR}/project.changeQt.h
		${CMAKE_CURRENT_SOURCE_DIR}/project.updateQt.h
		${CMAKE_CURRENT_SOURCE_DIR}/project.readJSON.h
		${CMAKE_CURRENT_SOURCE_DIR}/project.writeJSON.h
	COMMAND ${STRUCTIO} -g ebml -g qt -g json ${CMAKE_CURRENT_SOURCE_DIR}/project.struct
	DEPENDS project.struct
)

set(FILES
	main.cpp
	../../architectures/main.cpp
	../../architectures/deepflower.h
	project.struct
	project.h
	project.readEBML.h
	project.writeEBML.h
	project.Qt.h
	project.initQt.h
	project.writeQt.h
	project.changeQt.h
	project.updateQt.h
	project.readJSON.h
	project.writeJSON.h
	Utility.h
)

set(GUI
	GLView.cpp
	MainWindow.cpp
	LineEdits.h
)

# headers that need preprocessing by qt moc
set(GUI_HEADERS
	GLView.h	
	MainWindow.h
)

set(LIBRARIES
	${Boost_LIBRARIES}
	${QT_LIBRARIES}
	${Digi_LIBRARIES}
	${OPENGL_gl_LIBRARY}
	${OPENGL_glu_LIBRARY}
)

set(RESOURCES
)

# run moc on headers
QT4_WRAP_CPP(GUI_MOC ${GUI_HEADERS})
list(APPEND GUI ${GUI_HEADERS})

CREATE_APP(Architectures
	FILES ${FILES}
		${GUI} ${GUI_MOC}
	LIBRARIES ${LIBRARIES}
	RESOURCES ${RESOURCES}
)
source_group(GUI FILES ${GUI})
source_group(GUI\\moc FILES ${GUI_MOC})

# use standard main() entry point because QApplication needs argc and argv
if(WIN32)
	set_target_properties(Architectures PROPERTIES LINK_FLAGS "/ENTRY:mainCRTStartup")
endif()
