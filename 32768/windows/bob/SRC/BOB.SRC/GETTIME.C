/*
  This file is part of bob, a 32k game for Mekka Symposium 2001.
  Copyright 2001 Kuno Woudt <warp-tmt@dds.nl>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program (see the file copying.txt); if not, write 
  to the Free Software Foundation, Inc., 
  59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#include "gettime.h"

#ifdef _WIN32
int
gettime(void)
{
  /* time in milliseconds since windows startup. */
  return timeGetTime(); 
}
#else // !_WIN32
int
gettime(void)
{
  struct timeval t;

  gettimeofday(&t, NULL); 

  return (t.tv_sec * 1000 + t.tv_usec / 1000);
}
#endif // _WIN32
 
