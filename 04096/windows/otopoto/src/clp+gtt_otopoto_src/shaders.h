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

#ifndef SHADERS_H
#define SHADERS_H

#pragma data_seg ("skyVP")
	#include "shaders/SkyVP.h"

#pragma data_seg ("skyFP")
	#include "shaders/SkyFP.h"

#pragma data_seg ("OceanVP")
	#include "shaders/OceanVP.h"

#pragma data_seg ("OceanFP")
	#include "shaders/OceanFP.h"

#pragma data_seg ("IsleFP")
	#include "shaders/IsleFP.h"

#pragma data_seg ("PalmTreeVP")
	#include "shaders/PalmTreeVP.h"

#pragma data_seg ("PalmLeavesVP")
	#include "shaders/PalmLeavesVP.h"

#pragma data_seg ("PalmFP")
	#include "shaders/PalmFP.h"

#pragma data_seg ()

#endif