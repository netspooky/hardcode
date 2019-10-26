#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "png.h"
#ifdef __APPLE__
#include "SDL/SDL_opengl.h"
#else
#include "SDL_opengl.h"
#endif

#include "record.h"

//######################################
// Function ############################
//######################################

int write_png(const char *filename, unsigned width, unsigned height, void *data, int ydir)
{
	// Sanity checks.
	if((ydir != -1) && (ydir != 1))
	{
		fprintf(stderr, "write_png: invalid y direction: %i\n", ydir);
		return -1;
	}
	if((width <= 0) || (height <= 0))
	{
		fprintf(stderr, "write_png: invalid dimensions: %ix%i\n", width, height);
		return -1;
	}

	// libpng chunk reservation process.
	FILE *fptr = fopen(filename, "w");
	if(!fptr)
	{
		fprintf(stderr, "fopen \"%s\": %s", filename, strerror(errno));
		return -1;
	}
	png_struct *png_struct_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING,
			NULL, NULL, NULL);
	if(!png_struct_ptr)
	{
		fprintf(stderr, "png_create_write_struct: ERROR\n");
		fclose(fptr);
		return -1;
	}
	png_info *png_info_ptr = png_create_info_struct(png_struct_ptr);
	if(!png_info_ptr)
	{
		fprintf(stderr, "png_create_info_struct: ERROR\n");
		png_destroy_write_struct(&png_struct_ptr, NULL);
		fclose(fptr);
		return -1;
	}
	if(setjmp(png_jmpbuf(png_struct_ptr)))
	{
		fprintf(stderr, "setjmp: ERROR\n");
		png_destroy_write_struct(&png_struct_ptr, &png_info_ptr);
		fclose(fptr);
		return -1;
	}

	// Set image info.
	png_init_io(png_struct_ptr, fptr);
	png_set_compression_level(png_struct_ptr, Z_BEST_COMPRESSION);
	png_set_IHDR(png_struct_ptr, png_info_ptr,
			width, height,
			8, PNG_COLOR_TYPE_RGB,
			PNG_INTERLACE_NONE,
			PNG_COMPRESSION_TYPE_DEFAULT,
			PNG_FILTER_TYPE_DEFAULT);

	// Low-level write interface.
	png_write_info(png_struct_ptr, png_info_ptr);
	png_byte **row_pointers = (png_byte**)malloc(sizeof(png_byte*) * height);
	for(unsigned ii = 0; (ii < height); ++ii)
	{
		row_pointers[ii] = ((png_byte*)data) +
			((ydir == 1) ? (width * ii * 3) :
			 (width * (height - 1 - ii) * 3));
	}
	png_write_rows(png_struct_ptr, row_pointers, height);
	png_write_end(png_struct_ptr, png_info_ptr);

	// Cleanup.
	png_destroy_write_struct(&png_struct_ptr, &png_info_ptr);
	free(row_pointers);
	fclose(fptr);
	return 0;
}

int write_opengl_viewport(const char *filename)
{
	// Get viewport coordinates.
	GLint viewport[4];
	glGetIntegerv(GL_VIEWPORT, viewport);

	// Read framebuffer data.
	unsigned width = (unsigned)viewport[2],
					 height = (unsigned)viewport[3];
	png_byte *data = (png_byte*)malloc(sizeof(png_byte) * width * height * 3);
	glReadPixels(viewport[0], viewport[1], (int)width, (int)height,
			GL_RGB, GL_UNSIGNED_BYTE, data);

	// Write framebuffer data.
	int ret = write_png(filename, width, height, data, -1);
	free(data);
	return ret;
}

//######################################
// End #################################
//######################################

