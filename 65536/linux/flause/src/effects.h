#ifndef __EFFECTS_H_
#define __EFFECTS_H_
extern void fade(int, GLclampf, GLclampf, GLclampf);
extern void sphere(int);
extern void flying_planes(void);
extern void print(const char *string,double size);
extern double bezier(double, double, int, int);
extern image_t *generate_star_field(int,int,int);
extern image_t *generate_particle_tex(int,int);
extern image_t *generate_rand_tex(int,int);
extern void scrollprint(const char *string, int);
extern void anim_firkant(float, float, float, float, float, float, float, float);
extern void tunnel(void);
extern void partikkel_init(void);
extern void partikkel(double,double,double,double);
extern int texture_upload(image_t *,int);
extern image_t *bw_to_rgb(char* data);
extern GLuint *make_font_textures(void);
#endif
