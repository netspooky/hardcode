/*
	This file is part of "otopoto / Collapse & Gatitos".

    "otopoto / Collapse & Gatitos" is free software: you can redistribute
	it and/or modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation, either version 3 of the
	License, or (at your option) any later version.

    "otopoto / Collapse & Gatitos" is distributed in the hope that it will
	be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
	of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with "otopoto / Collapse & Gatitos".  If not, see 
	<http://www.gnu.org/licenses/>.
*/

#ifndef EXTENSIONS_H
#define EXTENSIONS_H

#define glCreateProgram						((PFNGLCREATEPROGRAMPROC)		extensions[ 0])
#define glCreateShader(a)					((PFNGLCREATESHADERPROC) 		extensions[ 1])((a))
#define glShaderSource(a,b,c,d) 			((PFNGLSHADERSOURCEPROC) 		extensions[ 2])((a),(b),(c),(d))

#define glCompileShader(a)					((PFNGLCOMPILESHADERPROC)		extensions[ 3])((a))
#define glAttachShader(a,b)					((PFNGLATTACHSHADERPROC) 		extensions[ 4]) ((a),(b))

#define glLinkProgram(a)					((PFNGLLINKPROGRAMPROC)	 		extensions[ 5])((a))
#define glUseProgram(program)				((PFNGLLINKPROGRAMPROC)	 		extensions[ 6])((program))

#define glUniform1f(location,v0)			((PFNGLUNIFORM1FPROC)			extensions[ 7])((location),(v0))
#define glUniform2f(location,v0,v1)			((PFNGLUNIFORM2FPROC)			extensions[ 8])((location),(v0),(v1))
#define glUniform3f(location,v0,v1,v2)		((PFNGLUNIFORM3FPROC)			extensions[ 9])((location),(v0),(v1),(v2))
#define glGetUniformLocation(program,name)	((PFNGLGETUNIFORMLOCATIONPROC)	extensions[10])((program),(name))

#endif