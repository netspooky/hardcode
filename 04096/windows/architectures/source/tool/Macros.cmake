#message("Macros.cmake")

# create application which depends on given libraries and may have resources
# CREATE_APP(target FILES files LIBRARIES libraries RESOURCES resources)
#
# create library with given public headers, export label and optional versionize target
# CREATE_LIBRARY(target FILES files HEADERS headers EXPORT export VERSIONIZE?)
#
# resolve dependencies for components of multi-component library
# RESOLVE_DEPENDENCIES(namespace libraries)
#
# create initLibraries.h for given libraries
# CREATE_INIT_LIBRARIES(libraries)
#
# use precompiled header (.h and .cpp) for given sources
# USE_PRECOMPILED_HEADER(precompiled_header precompiled_source sources)
#
# add versionize target for given target
# ADD_VERSIONIZE(target)
#
# add resources to target. Mac OS X: copies into bundle, Windows: copies next to exe
# ADD_RESOURCES(target resources)
#
# add a google test based test project with given files, libraries and target properties
# ADD_GTEST(name FILES files LIBRARIES libraries PROPERTIES properties)



#
# create application which depends on given libraries and may have resources
#
function(CREATE_APP TARGET)
	
	# process arguments (passed in ${ARGN})		
	set(_nowhere)
	set(_curdest _nowhere)
	set(_val_args
		FILES
		LIBRARIES
		RESOURCES)
	set(_bool_args
		)
	
	# clear arguments
	foreach(_arg ${_val_args} ${_bool_args})
		set(${_arg} "")
	endforeach()
	
	# collect arguments
	foreach(_element ${ARGN})
		list(FIND _val_args ${_element} _val_arg_find)
		list(FIND _bool_args ${_element} _bool_arg_find)
		if(${_val_arg_find} GREATER -1)
			set(_curdest ${_element})
		elseif(${_bool_arg_find} GREATER -1)
			set(${_element} ON)
			set(_curdest _nowhere)
		else()
			list(APPEND ${_curdest} ${_element})
		endif()
	endforeach()
	if(_nowhere)
		message(FATAL_ERROR "Syntax error in argument list of CREATE_APP!")
	endif()

	#message("FILES: ${FILES}")
	#message("LIBRARIES: ${LIBRARIES}")
	#message("RESOURCES: ${RESOURCES}")

	# sort files (for xcode)
	list(SORT FILES)

	# add executable target
	add_executable(${TARGET} WIN32 MACOSX_BUNDLE ${FILES} ${RESOURCES})
	source_group(Files FILES ${FILES})
	source_group(Resources FILES ${RESOURCES})

	# add resources and create app bundle on mac os x
	set_target_properties(${TARGET} PROPERTIES
		RESOURCE "${RESOURCES}")

	# copy resources next to executable so that they are found when running in visual studio.
	# for mac os x the resources are copied automaticlly into the bundle
	if(WIN32)
		# create Resources directory next to executable
		add_custom_command(TARGET ${TARGET} POST_BUILD
			COMMAND ${CMAKE_COMMAND} -E make_directory
			"${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/Resources"
		)
		
		# copy all resources into Resources directory
		foreach(RESOURCE ${RESOURCES})
			if(NOT IS_ABSOLUTE ${RESOURCE})
				set(RESOURCE "${PROJECT_SOURCE_DIR}/${RESOURCE}")
			endif()
			add_custom_command(TARGET ${TARGET} POST_BUILD
				COMMAND ${CMAKE_COMMAND} -E copy_if_different
				"${RESOURCE}"
				"${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/Resources"
			)
		endforeach()
	endif()

	# set dependencies
	target_link_libraries(${TARGET} ${LIBRARIES})

	# install executable and resources
	install(TARGETS ${TARGET}
		RUNTIME DESTINATION bin
		BUNDLE DESTINATION bin
		RESOURCE DESTINATION bin/Resources
	)
	
endfunction(CREATE_APP) 


#
# create console command which depends on given libraries and may have resources
#
function(CREATE_COMMAND TARGET)
	
	# process arguments (passed in ${ARGN})		
	set(_nowhere)
	set(_curdest _nowhere)
	set(_val_args
		FILES
		LIBRARIES
		RESOURCES)
	set(_bool_args
		)
	
	# clear arguments
	foreach(_arg ${_val_args} ${_bool_args})
		set(${_arg} "")
	endforeach()
	
	# collect arguments
	foreach(_element ${ARGN})
		list(FIND _val_args ${_element} _val_arg_find)
		list(FIND _bool_args ${_element} _bool_arg_find)
		if(${_val_arg_find} GREATER -1)
			set(_curdest ${_element})
		elseif(${_bool_arg_find} GREATER -1)
			set(${_element} ON)
			set(_curdest _nowhere)
		else()
			list(APPEND ${_curdest} ${_element})
		endif()
	endforeach()
	if(_nowhere)
		message(FATAL_ERROR "Syntax error in argument list of CREATE_APP!")
	endif()

	#message("FILES: ${FILES}")
	#message("LIBRARIES: ${LIBRARIES}")
	#message("RESOURCES: ${RESOURCES}")

	# sort files (for xcode)
	list(SORT FILES)

	# add executable target
	add_executable(${TARGET} MACOSX_BUNDLE ${FILES} ${RESOURCES})
	source_group(Files FILES ${FILES})
	source_group(Resources FILES ${RESOURCES})

	# add resources and create app bundle on mac os x
	set_target_properties(${TARGET} PROPERTIES
		RESOURCE "${RESOURCES}")

	# copy resources next to executable so that they are found when running in visual studio.
	# for mac os x the resources are copied automaticlly into the bundle
	if(WIN32)
		# create Resources directory next to executable
		add_custom_command(TARGET ${TARGET} POST_BUILD
			COMMAND ${CMAKE_COMMAND} -E make_directory
			"${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/Resources"
		)
		
		# copy all resources into Resources directory
		foreach(RESOURCE ${RESOURCES})
			if(NOT IS_ABSOLUTE ${RESOURCE})
				set(RESOURCE "${PROJECT_SOURCE_DIR}/${RESOURCE}")
			endif()
			add_custom_command(TARGET ${TARGET} POST_BUILD
				COMMAND ${CMAKE_COMMAND} -E copy_if_different
				"${RESOURCE}"
				"${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/Resources"
			)
		endforeach()
	endif()

	# set dependencies
	target_link_libraries(${TARGET} ${LIBRARIES})

	# install executable and resources
	install(TARGETS ${TARGET}
		RUNTIME DESTINATION bin
		BUNDLE DESTINATION bin
		RESOURCE DESTINATION bin/Resources
	)
	
endfunction(CREATE_COMMAND) 


#
# create library with given public headers, export label and optional versionize target
#
function(CREATE_LIBRARY TARGET)
	
	# process arguments (passed in ${ARGN})		
	set(_nowhere)
	set(_curdest _nowhere)
	set(_val_args
		FILES
		HEADERS
		EXPORT)
	set(_bool_args
		VERSIONIZE)
	
	# clear arguments
	foreach(_arg ${_val_args} ${_bool_args})
		set(${_arg} "")
	endforeach()
	
	# collect arguments
	foreach(_element ${ARGN})
		list(FIND _val_args ${_element} _val_arg_find)
		list(FIND _bool_args ${_element} _bool_arg_find)
		if(${_val_arg_find} GREATER -1)
			set(_curdest ${_element})
		elseif(${_bool_arg_find} GREATER -1)
			set(${_element} ON)
			set(_curdest _nowhere)
		else()
			list(APPEND ${_curdest} ${_element})
		endif()
	endforeach()
	if(_nowhere)
		message(FATAL_ERROR "Syntax error in argument list of CREATE_LIBRARY!")
	endif()

	#message("HEADERS: ${HEADERS}")
	#message("FILES: ${FILES}")
	#message("EXPORT: ${EXPORT}")
	
	# multi-component target: generate include suffix and remove . (e.g. foo.Bar -> foo/Bar and fooBar)
	string(REPLACE . / INCLUDE_SUFFIX ${TARGET})
	string(REPLACE . "" TARGET ${TARGET})

	# add headers to files and sort (for xcode)
	list(APPEND FILES ${HEADERS})
	list(SORT FILES)

	# add static lib target
	add_library(${TARGET} STATIC ${FILES})
	source_group(Files FILES ${FILES})

	# set public headers
	set_target_properties(${TARGET} PROPERTIES PUBLIC_HEADER "${HEADERS}")

	# install target and set label (EXPORT <label>)
	install(TARGETS ${TARGET}
		EXPORT ${EXPORT}
		PUBLIC_HEADER DESTINATION include/${INCLUDE_SUFFIX}
		ARCHIVE DESTINATION lib
	)

	# versionize
	if(VERSIONIZE)
		ADD_VERSIONIZE(${TARGET})
	endif()
	
endfunction(CREATE_LIBRARY) 


#
# resolves dependencies for given libs and creates a list of needed libraries
# for each lib. also creates list of init and done functions for each lib
#
# example: namespace ns and libs Super, Foo, Bar where Super depends on Foo and Bar
#
# define dependencies:
# set(Foo_HAS_INIT_DONE YES)
# set(Super_DEPENDENCIES Foo Bar)
# set(Super_HAS_INIT_DONE YES)
#
# resolve dependencies:
# RESOLVE_DEPENDENCIES(ns Super;Foo;Bar)
#
# result:
# nsFoo_LIBRARIES = nsFoo
# nsFoo_INIT = nsFooInit
# nsFoo_DONE = nsFooDone
#
# nsBar_LIBRARIES = nsBar
# nsBar_INIT =
# nsBar_DONE =
#
# nsSuper_LIBRARIES = nsSuper;nsFoo;nsBar
# nsSuper_INIT = nsSuperInit;nsFooInit
# nsSuper_DONE = nsSuperDone;nsFooDone
#
# note: quote _LIBS argument when using a variable, e.g. RESOLVE_DEPENDENCIES(ns "${ALL_LIBS}")
#
macro(RESOLVE_DEPENDENCIES _NAMESPACE _LIBS)
	# resolve dependencies
	foreach(_LIB ${_LIBS})
		#message("")
		#message("${_LIB}_DEPENDENCIES ${${_LIB}_DEPENDENCIES}")

		# start with dependency variable of current lib, e.g. "Super_DEPENDENCIES" which contains "Foo;Bar"
		set(_WORKLIST ${_LIB}_DEPENDENCIES)
		#message("_WORKLIST ${_WORKLIST}")
		
		# process worklist until worklist is empty
		set(_RESULT ${_LIB})
		list(LENGTH _WORKLIST _WORKLIST_LENGTH)
		while(_WORKLIST_LENGTH GREATER 0)
			set(_NEW_WORKLIST "")
			foreach(_ITEM ${_WORKLIST})
				# ${_ITEM} is dependency variable of e.g. "Super", i.e. "Super_DEPENDENCIES"
				# ${${_ITEM}} is dependency list of e.g. "Super", i.e. "Foo;Bar"
				foreach(_LIB2 ${${_ITEM}})
					# add name of dependent lib with namespace to result, e.g. "nsFoo"
					list(APPEND _RESULT ${_LIB2})
					
					# build new worklist from dependency list, e.g. "Foo_DEPENDENCIES;Bar_DEPENDENCIES"
					list(APPEND _NEW_WORKLIST ${_LIB2}_DEPENDENCIES)
				endforeach()
			endforeach()
			list(REMOVE_DUPLICATES _NEW_WORKLIST)
			#message("_RESULT ${_RESULT}")
			#message("_NEW_WORKLIST ${_NEW_WORKLIST}")
					
			# set new worklist
			set(_WORKLIST ${_NEW_WORKLIST})
			
			# determine length
			list(LENGTH _WORKLIST _WORKLIST_LENGTH)
		endwhile()
		list(REMOVE_DUPLICATES _RESULT)

		# collect include dirs, definitions and libraries of dependent libraries
		# (e.g. SUPER_LIBRARIES = "nsSuper;nsFoo;nsBar")
		set(_${_LIB}_PACKAGES)
		set(_${_LIB}_INCLUDE_DIRS)
		set(_${_LIB}_DEFINITIONS)
		set(_${_LIB}_LIBRARIES)
		foreach(_LIB2 ${_RESULT})
			# collect packages
			list(APPEND _${_LIB}_PACKAGES ${${_LIB2}_PACKAGES})

			# collect include directories
			list(APPEND _${_LIB}_INCLUDE_DIRS ${${_LIB2}_INCLUDE_DIRS})
			
			# collect definitions
			list(APPEND _${_LIB}_DEFINITIONS ${${_LIB2}_DEFINITIONS})
			
			# collect libraries, also add name of dependent library
			list(APPEND _${_LIB}_LIBRARIES ${_NAMESPACE}${_LIB2} ${${_LIB2}_LIBRARIES})
			
			# collect libraries that have an init and done function
			if(${${_LIB2}_HAS_INIT_DONE})
				list(APPEND ${_LIB}_INIT_DONE ${_NAMESPACE}${_LIB2})
			endif()		
		endforeach()
		
		# remove duplicates
		if(_${_LIB}_PACKAGES)
			list(REMOVE_DUPLICATES _${_LIB}_PACKAGES)
		endif()
		if(_${_LIB}_INCLUDE_DIRS)
			list(REMOVE_DUPLICATES _${_LIB}_INCLUDE_DIRS)
		endif()
		if(_${_LIB}_DEFINITIONS)
			list(REMOVE_DUPLICATES _${_LIB}_DEFINITIONS)
		endif()
	endforeach()

	# copy variables for all libs
	foreach(_LIB ${_LIBS})
		set(${_LIB}_PACKAGES ${_${_LIB}_PACKAGES})
		set(${_LIB}_INCLUDE_DIRS ${_${_LIB}_INCLUDE_DIRS})
		set(${_LIB}_DEFINITIONS ${_${_LIB}_DEFINITIONS})
		set(${_LIB}_LIBRARIES ${_${_LIB}_LIBRARIES})

		#message("${_LIB}_PACKAGES ${${_LIB}_PACKAGES}")
		#message("${_LIB}_INCLUDE_DIRS ${${_LIB}_INCLUDE_DIRS}")
		#message("${_LIB}_DEFINITIONS ${${_LIB}_DEFINITIONS}")
		#message("${_LIB}_LIBRARIES ${${_LIB}_LIBRARIES}")
		#message("${_LIB}_INIT_DONE ${${_LIB}_INIT_DONE}")
	endforeach()
	
	# build component info
	set(COMPONENT_INFO )
	foreach(_LIB ${_LIBS})
		set(COMPONENT_INFO "${COMPONENT_INFO}set(_${_LIB}_PACKAGES ${${_LIB}_PACKAGES})\n")
		set(COMPONENT_INFO "${COMPONENT_INFO}set(_${_LIB}_INCLUDE_DIRS ${${_LIB}_INCLUDE_DIRS})\n")
		set(COMPONENT_INFO "${COMPONENT_INFO}set(_${_LIB}_DEFINITIONS ${${_LIB}_DEFINITIONS})\n")
		set(COMPONENT_INFO "${COMPONENT_INFO}set(_${_LIB}_LIBRARIES ${${_LIB}_LIBRARIES})\n")
		set(COMPONENT_INFO "${COMPONENT_INFO}set(_${_LIB}_INIT_DONE ${${_LIB}_INIT_DONE})\n")
	endforeach()
	#message("COMPONENT_INFO ${COMPONENT_INFO}")
	
endmacro(RESOLVE_DEPENDENCIES)


#
# use this function to create InitLibraries.h containing initLibraries() and doneLibraries()
#
set(INIT_LIBRARIES_FILE ${CMAKE_CURRENT_LIST_DIR}/InitLibraries.h.cmake)
function(CREATE_INIT_LIBRARIES)
	set(LIBRARIES ${ARGN})
	list(REMOVE_DUPLICATES LIBRARIES)
	#message("CREATE_INIT_LIBRARIES(LIBRARIES = ${LIBRARIES})")
	
	# init functions
	set(INIT_FUNCTIONS "")
	set(INIT_FUNCTION_PROTOTYPES "")
	foreach(LIBRARY ${LIBRARIES})
		set(INIT_FUNCTIONS "${INIT_FUNCTIONS}${LIBRARY}Init();\n\t")
		set(INIT_FUNCTION_PROTOTYPES "${INIT_FUNCTION_PROTOTYPES}void ${LIBRARY}Init(); ")
	endforeach()
	#message("init functions: ${INIT_FUNCTIONS}")

	# done functions
	set(DONE_FUNCTIONS "")
	set(DONE_FUNCTION_PROTOTYPES "")
	foreach(LIBRARY ${LIBRARIES})
		set(DONE_FUNCTIONS "${DONE_FUNCTIONS}${LIBRARY}Done();\n\t")
		set(DONE_FUNCTION_PROTOTYPES "${DONE_FUNCTION_PROTOTYPES}void ${LIBRARY}Done(); ")
	endforeach()
	#message("done functions: ${DONE_FUNCTIONS}")

	# generate InitLibraries.h from InitLibraries.h.cmake
	configure_file(${INIT_LIBRARIES_FILE} ${CMAKE_CURRENT_SOURCE_DIR}/InitLibraries.h)
	
endfunction(CREATE_INIT_LIBRARIES)


#
# macro for using a precompiled header
#
function(USE_PRECOMPILED_HEADER PrecompiledHeader PrecompiledSource Sources)
	if(MSVC)
		get_filename_component(PrecompiledBasename ${PrecompiledSource} NAME_WE)
		set(PrecompiledBinary "${CMAKE_CURRENT_BINARY_DIR}/${PrecompiledBasename}.pch")

		# set properties on PrecompiledSource (.cpp)
		SET_SOURCE_FILES_PROPERTIES(${PrecompiledSource}
			PROPERTIES COMPILE_FLAGS "/Yc\"${PrecompiledHeader}\" /Fp\"${PrecompiledBinary}\""
				OBJECT_OUTPUTS "${PrecompiledBinary}")		

		# set properties on all sources
		SET_SOURCE_FILES_PROPERTIES(${Sources}
			PROPERTIES COMPILE_FLAGS "/Yu\"${PrecompiledBinary}\" /FI\"${PrecompiledBinary}\" /Fp\"${PrecompiledBinary}\""
				OBJECT_DEPENDS "${PrecompiledBinary}")
	endif(MSVC)
endfunction(USE_PRECOMPILED_HEADER)


#
# support for versionize using svn version info
#

set(VERSIONIZE_FILE ${CMAKE_CURRENT_LIST_DIR}/Versionize.cmake)
set(VERSION_H_FILE ${CMAKE_CURRENT_LIST_DIR}/Version.h.cmake)
#message("Versionize: ${VERSIONIZE_FILE}")
#message("Version.h: ${VERSION_H_FILE}")

# use this macro to add versionize support to a library
function(ADD_VERSIONIZE TARGET)

	# this target is always out of date and creates Version.h from Version.h.cmake
	# note: don't add Version.h to source control
	add_custom_target("_Ver_${TARGET}" ALL
		${CMAKE_COMMAND}
		-DNAME:STRING="${TARGET}"
		-DWORKING_DIR:PATH="${CMAKE_CURRENT_SOURCE_DIR}"
		-DVERSION_H:PATH="${VERSION_H_FILE}"
		-P ${VERSIONIZE_FILE}
	)
	
	# ensure the versionize target is built before the versionized target
	add_dependencies(${TARGET} "_Ver_${TARGET}")
	
endfunction(ADD_VERSIONIZE)


#
# support for google test unit test framework
#
# example: ADD_GTEST(TestMyLib TESTS TestMyLib.cpp LIBRARIES MyLib)
#

# find google test
if(ENABLE_TESTS)
	find_package(GTest)
	#message("GTEST_LIBRARIES ${GTEST_LIBRARIES}")
	if(GTEST_FOUND)
		enable_testing()
	endif()
endif()

function(ADD_GTEST NAME)
	
	if(NOT ENABLE_TESTS)
		message("ADD_GTEST(${NAME}): tests disabled")
	elseif(NOT GTEST_FOUND)
		message("ADD_GTEST(${NAME}): test skipped because google test not found")
	else()
		# process arguments (passed in ${ARGN})		
		set(_nowhere)
		set(_curdest _nowhere)
		set(_val_args
			FILES
			LIBRARIES
			PROPERTIES
		)
		set(_bool_args
		)
		
		# clear arguments
		foreach(_arg ${_val_args} ${_bool_args})
			set(${_arg} "")
		endforeach()
		
		# collect arguments
		foreach(_element ${ARGN})
			list(FIND _val_args ${_element} _val_arg_find)
			list(FIND _bool_args ${_element} _bool_arg_find)
			if(${_val_arg_find} GREATER -1)
				set(_curdest ${_element})
			elseif(${_bool_arg_find} GREATER -1)
				set(${_element} ON)
				set(_curdest _nowhere)
			else()
				list(APPEND ${_curdest} ${_element})
			endif()
		endforeach()
		if(_nowhere)
			message(FATAL_ERROR "Syntax error in argument list of ADD_GTEST!")
		endif()

		# add include directory for gtest
		include_directories(${GTEST_INCLUDE_DIRS}) 

		# add executable target
		add_executable(${NAME} ${FILES})
		source_group(Tests FILES ${FILES})
		
		# gtest needs pthread on unix
		if(UNIX)
			list(APPEND LIBRARIES pthread)
		endif()
		
		# set dependencies
		target_link_libraries(${NAME} ${GTEST_LIBRARIES} ${LIBRARIES})

		# set properties
		if(PROPERTIES)
			set_target_properties(${NAME} PROPERTIES ${PROPERTIES})
		endif()

		# install folder for executables
		install(TARGETS ${NAME}
			RUNTIME DESTINATION bin
			BUNDLE DESTINATION bin
		)
		add_test(NAME ${NAME}
			WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
			COMMAND ${NAME})
	endif()

endfunction(ADD_GTEST)
