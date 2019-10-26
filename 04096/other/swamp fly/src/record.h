#ifndef RECORD_H_INCLUDE
#define RECORD_H_INCLUDE

//######################################
// Function ############################
//######################################

/** \brief Write one PNG file.
 *
 * Written according to the libpng manual.
 *
 * Y direction specifies the row update direction. Note that for example
 * OpenGL gives the screen rows in reverse order from bottom to top instead
 * of top to bottom typical to graphics files.
 *
 * @param filename File to write.
 * @param width Width of image.
 * @param height Height of image.
 * @param data RGB24 image data.
 * @param ydir Y direction, 1 or -1;
 * @return Zero on success, negative on failure.
 */
extern int write_png(const char *filename, unsigned width, unsigned height,
		void *data, int ydir);

/** \brief Save OpenGL buffer as.
 *
 * @param filename Filename to save GL buffer to.
 */
extern int write_opengl_viewport(const char *filename);

//######################################
// End #################################
//######################################

#endif
