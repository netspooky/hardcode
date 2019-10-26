#include <stdlib.h>
#include <stdio.h> /*jpeglib*/
#include <jpeglib.h>

typedef struct {
	unsigned char *data;
	unsigned short height;
	unsigned short width;
} image_t;

typedef struct {
	struct jpeg_source_mgr mgr;
	const unsigned char *image;
	size_t image_size;
} my_jpeg_sourcemanager;

void init_source (j_decompress_ptr cinfo);
int fill_input_buffer (j_decompress_ptr cinfo);
void skip_input_data (j_decompress_ptr cinfo, long num_bytes);
void term_source (j_decompress_ptr cinfo);

void create_jpeg_srcmgr (j_decompress_ptr cinfo, const unsigned char *image, size_t image_size);
image_t *read_jpeg(const unsigned char *data, int data_size);

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

void init_source (j_decompress_ptr cinfo) {
	return;
}

int fill_input_buffer (j_decompress_ptr cinfo) {
	return 0;
}

void skip_input_data (j_decompress_ptr cinfo, long num_bytes) {
}

void term_source (j_decompress_ptr cinfo) {
	return;
}

image_t *read_jpeg(const unsigned char *data, int data_size) {
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
