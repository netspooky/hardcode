/*
 * comments from /usr/share/doc/libjpeg-../libjpeg.doc.gz
 */
/* #include <unistd.h> */
#include <stdlib.h>
#include <stdio.h> /*jpeglib*/
#include <jpeglib.h>
#include "demo.h"

/*
 * Decompression source managers follow a parallel design, but with some
 * additional frammishes. The source manager struct contains a pointer and
 * count defining the next byte to read from the work buffer and the number of
 * bytes remaining:
 */

typedef struct {
	struct jpeg_source_mgr mgr;
	const unsigned char *image;
	size_t image_size;
} my_jpeg_sourcemanager;

/*
static const JOCTET * next_input_byte; * => next byte to read from buffer */
/* static size_t bytes_in_buffer;         * # of bytes remaining in buffer */
/*
 * The library increments the pointer and decrements the count until the buffer
 * is emptied. The manager's fill_input_buffer method must reset the pointer
 * and count. In most applications, the manager must remember the buffer's
 * starting address and total size in private fields not visible to the
 * library.
 */

/* 
 * A data source manager provides five methods:
 */
void init_source (j_decompress_ptr cinfo);
int fill_input_buffer (j_decompress_ptr cinfo);
void skip_input_data (j_decompress_ptr cinfo, long num_bytes);
void term_source (j_decompress_ptr cinfo);

void create_jpeg_srcmgr (j_decompress_ptr cinfo, const unsigned char *image, size_t image_size);
image_t *read_jpeg(const unsigned char *data, size_t data_size);

/* Initialize source.  This is called by jpeg_read_header() before any data is
 * actually read.  Unlike init_destination(), it may leave bytes_in_buffer set
 * to 0 (in which case a fill_input_buffer() call will occur immediately).
 */
void init_source (j_decompress_ptr cinfo) {
	return;
}

/*
 * This is called whenever bytes_in_buffer has reached zero and more data is
 * wanted.  In typical applications, it should read fresh data into the buffer
 * (ignoring the current state of next_input_byte and bytes_in_buffer), reset
 * the pointer & count to the start of the buffer, and return TRUE indicating
 * that the buffer has been reloaded.  It is not necessary to fill the buffer
 * entirely, only to obtain at least one more byte.  bytes_in_buffer MUST be
 * set to a positive value if TRUE is returned.  A FALSE return should only be
 * used when I/O suspension is desired (this mode is discussed in the next
 * section).
 */
int fill_input_buffer (j_decompress_ptr cinfo) {
	return 0;
}

/* 
 * Skip num_bytes worth of data.  The buffer pointer and count should be
 * advanced over num_bytes input bytes, refilling the buffer as needed. This is
 * used to skip over a potentially large amount of uninteresting data (such as
 * an APPn marker).  In some applications it may be possible to optimize away
 * the reading of the skipped data, but it's not clear that being smart is
 * worth much trouble; large skips are uncommon.  bytes_in_buffer may be zero
 * on return.  A zero or negative skip count should be treated as a no-op.
 */
void skip_input_data (j_decompress_ptr cinfo, long num_bytes) {
}

/*
 * This routine is called only when the decompressor has failed to find a
 * restart (RSTn) marker where one is expected.  Its mission is to find a
 * suitable point for resuming decompression.  For most applications, we
 * recommend that you just use the default resync procedure,
 * jpeg_resync_to_restart().  However, if you are able to back up in the input
 * data stream, or if you have a-priori knowledge about the likely location of
 * restart markers, you may be able to do better.  Read the
 * read_restart_marker() and jpeg_resync_to_restart() routines in jdmarker.c if
 * you think you'd like to implement your own resync procedure.
 */
/*
resync_to_restart (j_decompress_ptr cinfo, int desired) {
	return jpeg_resync_to_restart(cinfo,desired);
}
*/
/*
 * Terminate source --- called by jpeg_finish_decompress() after all data has
 * been read.  Often a no-op.
 */
void term_source (j_decompress_ptr cinfo) {
	return;
}

/*
 */
void create_jpeg_srcmgr (j_decompress_ptr cinfo, const unsigned char *image,
		size_t image_size) {
	my_jpeg_sourcemanager *src;
	cinfo->src = (struct jpeg_source_mgr *)(*cinfo->mem->alloc_small)
		((j_common_ptr) cinfo, JPOOL_IMAGE, 
		 sizeof(my_jpeg_sourcemanager));
	src = (my_jpeg_sourcemanager *) cinfo->src;

	src->mgr.init_source = init_source;
	src->mgr.fill_input_buffer = fill_input_buffer;
	src->mgr.skip_input_data = skip_input_data;
	src->mgr.resync_to_restart = jpeg_resync_to_restart;
	src->mgr.term_source = term_source;

	src->image = image;
	src->mgr.bytes_in_buffer = image_size;
	src->mgr.next_input_byte = image;
} 

image_t *read_jpeg(const unsigned char *data, size_t data_size) {
	struct jpeg_decompress_struct cinfo;
	struct jpeg_error_mgr jerr;
	int line_size;
	unsigned int y;
	image_t *img;
	unsigned char *offset;

	img = (image_t*)malloc(sizeof(image_t));

	jpeg_create_decompress(&cinfo);
	cinfo.err = jpeg_std_error(&jerr);

	create_jpeg_srcmgr(&cinfo,data,data_size);

	jpeg_read_header(&cinfo, TRUE);
	
	jpeg_start_decompress(&cinfo);
	line_size = cinfo.output_width * cinfo.output_components;
	offset = img->data = malloc(line_size * cinfo.output_height);

	img->height = cinfo.output_height;
	img->width = cinfo.output_width;

	for (y = 0; y < cinfo.output_height ; y++) {
		jpeg_read_scanlines(&cinfo,(JSAMPARRAY) &offset, 1);
		offset += line_size;
	}
	jpeg_finish_decompress(&cinfo);
	jpeg_destroy_decompress(&cinfo);
	return img;
}
