/**
 * Functions for a ray tracer.
 *
 * @author Timo Wirén
 * @version 2008-02-27
 * @licence GNU GPL
 */
#ifdef XCOMPILE
#include <stdlib.h>
#endif
#include "common.h"

/**
 * Returns dot product of vectors a and b.
 */
static float dot(const Vector* a, const Vector* b) {

        return a->x * b->x + a->y * b->y + a->z * b->z;
}

static void cross(const Vector* a, const Vector* b, Vector* out) {

	out->x = a->y * b->z - a->z * b->y;
	out->y = a->z * b->x - a->x * b->z;
	out->z = a->x * b->y - a->y * b->x;
}

/**
 * Subtracts vector b from a and returns the resulting vector.
 */
static void subtract(const Vector* a, const Vector* b, Vector* out) {

        out->x = a->x - b->x;
        out->y = a->y - b->y;
        out->z = a->z - b->z;
}

/**
 * Normalizes a vector.
 */
static void normalize(Vector* v) {

	float inv_length = 1.0f / sqrt(dot(v, v));

	v->x *= inv_length;
	v->y *= inv_length;
	v->z *= inv_length;
}

/**
 * Returns vector's length.
 */
static float length(const Vector* v) {

	return sqrt(dot(v, v));
}

/**
 * Calculates information that is constant for a frame.
 */
static void precalc_frame(Object* objects, int obj_count) {

	int i;

	for (i = 0; i < obj_count; ++i) {
		subtract(&objects[i].position, &viewing_point, 
		  &objects[i].eye_to_surface);
		if (objects[i].type == SPHERE) {
			objects[i].length = objects[i].radius * 
			                    objects[i].radius - 
			                dot(&objects[i].eye_to_surface,
			                    &objects[i].eye_to_surface);
		} 
		if (objects[i].type == PLANE) {
			objects[i].edotn = dot(
			   &objects[i].eye_to_surface, &objects[i].hit_normal);

			objects[i].ndotp = dot(&objects[i].hit_normal,
			                       &objects[i].position);
		}
	}
}

/**
 * Calculates distance from origin vector ori to object oi's intersection point
 * Returns -1 if there is no intersection.
 */
static float intersect(Object* objects, int oi, const Vector* ori, const Vector* dir, int mode) {

	float closest, len, half;
	Vector origin_to_center;

        Vector ray_to_base;
        Vector n, dist, o;
        char hit = 0;
        float d, ss, t;

	if (objects[oi].type == SPHERE) {
		if (mode == PRIMARY_RAY) {
			len = objects[oi].length;
			closest = dot(&objects[oi].eye_to_surface, dir);
			if (closest < 0) return -1;
		} else {  /* SECONDARY_RAY */
			subtract(&objects[oi].position,ori, &origin_to_center);
			
			closest = dot(&origin_to_center, dir);
			if (closest < 0) return -1;
			len = objects[oi].radius * objects[oi].radius - 
			     dot(&origin_to_center, &origin_to_center);
		}

		half = len + closest * closest;

		return half > 0? closest - sqrt(half) : -1; 
	} 
	if (objects[oi].type == PLANE) {
		if (mode == PRIMARY_RAY) {
			len = objects[oi].edotn / 
			                dot(&objects[oi].hit_normal, dir);
		} else { /* SECONDARY_RAY */ 
			len = (objects[oi].ndotp - 
			                 dot(&objects[oi].hit_normal, ori)) / 
			                 dot(&objects[oi].hit_normal, dir);
		}

		return len > .003f? len : -1.0f;
	}
	if (objects[oi].type == CYLINDER) {
		subtract(ori, &objects[oi].position, &ray_to_base);

		cross(dir, &objects[oi].axis, &n);

		len = sqrt(n.x * n.x + n.y * n.y + n.z * n.z);

		/* Ray is paraller to cylinder. */
		if (len > 0 && len < 0.003f) {
			d = dot(&ray_to_base, &objects[oi].axis);

			dist.x = ray_to_base.x - d * objects[oi].axis.x;
			dist.y = ray_to_base.y - d * objects[oi].axis.y;
			dist.z = ray_to_base.z - d * objects[oi].axis.z;
#ifdef XCOMPILE
			d = sqrt(dist.x*dist.x + dist.y*dist.y + dist.z*dist.z);
#else
			d = sqrtf(dist.x*dist.x + dist.y*dist.y + dist.z*dist.z);
#endif

	                return d <= objects[oi].radius? d : -1.0f;
        	}

		normalize(&n);

		d = fabs(dot(&ray_to_base, &n));
		hit = (d <= objects[oi].radius);

		if (hit) {
			cross(&ray_to_base, &objects[oi].axis, &o);
			t = -dot(&o, &n) / len;
			cross(&n, &objects[oi].axis, &o);
			normalize(&o);
#ifdef XCOMPILE
			ss = fabs(sqrt(objects[oi].radius*objects[oi].radius - 
#else
			ss = fabs(sqrtf(objects[oi].radius*objects[oi].radius - 
#endif
			          d * d) / dot(dir, &o));
			return (t - ss > 0.003f)? (t - ss) : -1.0f;
		}
		return -1.0f;
	}
	return -1.0f;
}

/**
 * Calculates texture at hit point and saves color to object's property 'color'
 */
static void calculate_texture(Object* objects, int o) {

	int u, v;
	float phi, theta;

	if (objects[o].type == SPHERE) {
		phi = acos(-dot(&objects[o].hit_normal, &objects[o].north));
		v = (int)(phi * (256.0f / 3.14159f));
		theta = acos(dot(&objects[o].equator, &objects[o].hit_normal) / sin(phi)) * (128.0f / M_PI);
		u = (int)theta;
		if (dot(&objects[o].position, &objects[o].hit_normal) > 0) u = 256 - (int)theta;
	} else { /* type == PLANE || CYLINDER */
		u = abs((int)(fmod(dot(&objects[o].hit_point, &objects[o].north), 256.0f)));
		v = abs((int)(fmod(dot(&objects[o].hit_point, &objects[o].equator), 256.0f)));
	}
	
        objects[o].color.x = (objects[o].texture[(v<<8) + u] & 0xFF0000)>>16;
        objects[o].color.y = (objects[o].texture[(v<<8) + u] & 0x00FF00)>>8;
        objects[o].color.z = (objects[o].texture[(v<<8) + u] & 0x0000FF);
}

/**
 * Shades the hit point.
 *
 * @param objects object array.
 * @param obj_count number of objects.
 * @param origin origin vector.
 * @param o object index.
 *
 * @return color of the point.
 */
static Vector shade(Object* objects, int obj_count, const Vector* direction, int o) {
	Object* ob = &objects[o];
	Vector L;
	Vector temp;
	float inten = 0, nl, t, dist_obj_light, I;
	const float ambient = 0.3f;
	int in_shadow = 0, i, li;



	for (li = 0; li < LIGHT_COUNT; ++li) {
		/* Surface to light. */
		subtract(&lights[li], &ob->hit_point, &L);

		dist_obj_light = length(&L);
		normalize(&L);

		nl = dot(&ob->hit_normal, &L);
		if (nl < 0) continue;

		/* Shadow check. */
		in_shadow = 0;
		for (i = 0; i < obj_count; ++i) {
		    t = intersect(objects, i, &ob->hit_point, &L, SECONDARY_RAY);
			if (t > .001f && t < dist_obj_light) {
				in_shadow = 1;
				break;
			}
		}	

		if (in_shadow == 1) continue;

		subtract(direction, &L, &temp);

		/* Halfway vector between L and surface to origin. */
		t = length(&temp);
		L.x /= t; 
		L.y /= t; 
		L.z /= t; 
		
		inten += ob->diffuse * nl + ob->specular * 
#ifdef XCOMPILE
		        pow(dot(&ob->hit_normal, &L), ob->shininess);		
#else
		        powf(dot(&ob->hit_normal, &L), ob->shininess);		
#endif
	}
	
	calculate_texture(objects, o);

	I = ambient + inten;
	/*
	if (I < 0) {
		I = ambient;
	}

	if (I > 1) {
		I = 1;
	}
	*/
	ob->color.x *= ambient + inten;
	ob->color.y *= ambient + inten;
	ob->color.z *= ambient + inten;
	return ob->color;
}

/**
 * Shoots a ray and returns a color.
 */
static Vector trace_ray(Object* objects, int obj_count, const Vector* origin,
                        const Vector* direction, int depth, int mode) {
	Vector out_color, temp, reflected;
	int n = -1;
	float ndoti = 1e20;

	/* calc_nearest_object. ndoti is distance to nearest object. */
	int i;
	float t;

	for (i = 0; i < obj_count; ++i) {
		t = intersect(objects, i, origin, direction, mode);
		if (t > 0 && t < ndoti) {
			ndoti = t;
			n = i;
		}
	}
	/* ******************* */

	out_color.x = out_color.y = out_color.z = 0;

	if (n == -1) return out_color;

	/* Calculate intersection point and normal. */
	objects[n].hit_point.x = origin->x + direction->x * ndoti;
	objects[n].hit_point.y = origin->y + direction->y * ndoti;
	objects[n].hit_point.z = origin->z + direction->z * ndoti;

	if (objects[n].type == SPHERE) {
		objects[n].hit_normal.x = (objects[n].hit_point.x - 
		                    objects[n].position.x) / objects[n].radius;

		objects[n].hit_normal.y = (objects[n].hit_point.y - 
		                    objects[n].position.y) / objects[n].radius;

		objects[n].hit_normal.z = (objects[n].hit_point.z - 
		                    objects[n].position.z) / objects[n].radius;
	}

	if (objects[n].type == CYLINDER) {
		subtract(&objects[n].hit_point, &objects[n].position, &objects[n].hit_normal);
		normalize(&objects[n].hit_normal);
	}

	out_color = shade(objects, obj_count, direction, n);

	/* Shoot reflected ray. */
	if (depth > 0 && objects[n].reflective == 1) {
		ndoti = 2.0f * dot(&objects[n].hit_normal, direction);
		temp.x = objects[n].hit_normal.x * ndoti;
		temp.y = objects[n].hit_normal.y * ndoti;
		temp.z = objects[n].hit_normal.z * ndoti;
		
		reflected.x = direction->x - temp.x;
		reflected.y = direction->y - temp.y;
		reflected.z = direction->z - temp.z;

		normalize(&reflected);

		temp = trace_ray(objects, obj_count, &objects[n].hit_point, &reflected, depth-1, SECONDARY_RAY);
		out_color.x += temp.x * .6f;
		out_color.y += temp.y * .6f;
		out_color.z += temp.z * .6f;
	}
	if (out_color.x > 255) out_color.x = 255;
	if (out_color.y > 255) out_color.y = 255;
	if (out_color.z > 255) out_color.z = 255;

	return out_color;
}

static void render_scene(Object* objects, int obj_count, Uint32* pixbuf) {

	int i;
	Vector color;

	precalc_frame(objects, obj_count);

	for (i = 0; i < WIDTH * HEIGHT; i += 2) {
		color = trace_ray(objects, obj_count, &viewing_point, 
		                  &ray_directions[i], 2, PRIMARY_RAY);
		pixbuf[i] = pixbuf[i+1] = ((int)color.x<<16) + ((int)color.y<<8) + (int)color.z;
		
	}
}

static void generate_texture(int* texture, char type) {

	int u, v, u2, v2, r = 0;

	srand(1337);

	for (v = 0; v < 256; ++v) {
		for (u = 0; u < 256; ++u) {
			texture[(v<<8)+u] = 0xffffff;

			if (type == TEXTURE_XOR) {
			    texture[(v<<8) + u] = ((u+100) ^ v) + (((u+100) ^ v)<<8) + (((u+100) ^ v)<<16);
			}
			if (type == TEXTURE_GRID) {
				texture[(v<<8) + u] = u%20 < 10 && v%20 < 10? 
				                      0xff0000 : 0xff00ff;
			}
			if (type == TEXTURE_NOISE || type == TEXTURE_NOISEBW) {
				r = 192+rand()%64;
				texture[(v<<8) + u] = type == TEXTURE_NOISE? r<<8 : r + (r<<8) + (r<<16);
			}
		}
	}
	if (type == TEXTURE_AMIGA) {
		for (v2 = 0; v2 < 256; v2 += 32) {
			for (u2 = 0; u2 < 256; u2 += 32) {
				for (v = 0; v < 16; ++v) {
					for (u = 0; u < 16; ++u) {
						texture[((v+v2)<<8) + u + u2] = 0xff0000;
						texture[((v+v2+16)<<8) + u + u2 + 16] = 0xff0000;
					}
				}
			}
		}
	}
}

/**
 * Creates a sphere.
 *
 * @param x x coordinate of sphere's center.
 * @param y y coordinate of sphere's center. 
 * @param z z coordinate of sphere's center.
 * @param radius sphere's radius.
 * @param tt texture type.
 *
 * @return created object.
 */
static Object create_sphere(float x, float y, float z, float radius, int tt) {

	Object out;

	out.type = SPHERE;

	out.reflective = 1;

	out.radius = radius;

	out.north.x = 1;
	out.north.y = 0;
	out.north.z = 0;

	out.equator.x = 0;
	out.equator.y = 1;
	out.equator.z = 0;

	out.position.x = x;
	out.position.y = y;
	out.position.z = z;

	out.diffuse = .6775f;
	out.specular = .772f;
	out.shininess = 82;

	generate_texture(out.texture, tt);

	return out;
}

/**
 * Creates a plane.
 *
 * @param x x coordinate of a point on the plane.
 * @param y y coordinate of a point on the plane.
 * @param z z coordinate of a point on the plane.
 * @param nx plane's normal x component.
 * @param ny plane's normal y component.
 * @param nz plane's normal z component.
 * @param tt texture type.
 *
 * @return created object.
 */
static Object create_plane(float x, float y, float z, 
                           float nx, float ny, float nz, int tt) {
	Object out;

	out.type = PLANE;

	out.position.x = x;
	out.position.y = y;
	out.position.z = z;

	out.hit_normal.x = nx;
	out.hit_normal.y = ny;
	out.hit_normal.z = nz;

	out.reflective = 0;

	out.diffuse = .7775f;
	out.specular = .272f;
	out.shininess = 12;

	out.equator.x = out.hit_normal.y;
	out.equator.y = out.hit_normal.z;
	out.equator.z = -out.hit_normal.x;

	cross(&out.equator, &out.hit_normal, &out.north);

	generate_texture(out.texture, tt);

	return out;
}

static Object create_cylinder(float bx, float by, float bz, float radius, 
                            float ax, float ay, float az, int tt) {
	Object out;

	out.type = CYLINDER;

	out.position.x = bx; /* base */
	out.position.y = by;
	out.position.z = bz;

	out.axis.x = ax;
	out.axis.y = ay;
	out.axis.z = az;

	out.radius = radius;

	out.equator.x = out.position.y;
	out.equator.y = out.position.z;
	out.equator.z = -out.position.x;

	cross(&out.equator, &out.position, &out.north);

	generate_texture(out.texture, tt);

	return out;
}

static void create_room() {

	room[0] = create_plane(0, 30, 0, 0, -1, 0, TEXTURE_XOR); /* floor */
	room[1] = create_plane(0, -20, 0, 0, 1, 0, TEXTURE_XOR); /* ceiling */
	room[2] = create_plane(-50, 0, 0, 1, 0, 0, TEXTURE_XOR); /* lwall */
	room[3] = create_plane(50, 0, 0, -1, 0, 0, TEXTURE_XOR); /* rwall */
	room[4] = create_plane(0, 0, 40, 0, 0, -1, TEXTURE_XOR); /* bwall */
	room[5] = create_sphere(0, 16, -20, 15, TEXTURE_AMIGA);
	room[6] = create_cylinder(-30, 30, -20, 10, 0, -1, 0, TEXTURE_NOISEBW);
	room[7] = create_cylinder(30, 30, -20, 10, 0, -1, 0, TEXTURE_NOISEBW);
}

/**
 * Creates a sphere flake in the sphere_flake[] array.
 *
 * @param x x coordinate of the center sphere.
 * @param y y coordinate of the center sphere.
 * @param z z coordinate of the center sphere.
 * @param r radius of the center sphere.
 * @param depth depth of recursion.
 * @param axl axis of entry. Should be AXEL_F in the initial call.
 * @param oi index into sphere_flake[] array.
 */
static void create_sphereflake(float x, float y, float z, int r, int depth, int axl, int oi) {

	sphere_flake[oi] = create_sphere(x, y, z, r, TEXTURE_AMIGA);
	
	if (depth > 0) {
	    if (axl != AXEL_XP) create_sphereflake(x+3*r/2,y,z,r/2,depth-1,AXEL_XN, ++oi);
	    if (axl != AXEL_XN) create_sphereflake(x-3*r/2,y,z,r/2,depth-1,AXEL_XP, ++oi);
	    if (axl != AXEL_YP) create_sphereflake(x,y+3*r/2,z,r/2,depth-1,AXEL_YN, ++oi);
	    if (axl != AXEL_YN) create_sphereflake(x,y-3*r/2,z,r/2,depth-1,AXEL_YP, ++oi);
	    if (axl != AXEL_ZP) create_sphereflake(x,y,z+3*r/2,r/2,depth-1,AXEL_ZN, ++oi);
	    if (axl != AXEL_ZN) create_sphereflake(x,y,z-3*r/2,r/2,depth-1,AXEL_ZP, ++oi);
	}
	sphere_flake[oi+1] = create_plane(0, 40, 0, 0, -1, 0, TEXTURE_NOISE);
}

/* text is composed of 69 spheres. */
static void create_wAMMA() {
	const char text[23*6] = { 
	      0,0,0,0,0,1,0,0,1,0,0,0,1,0,1,0,0,0,1,0,0,1,0,
	      0,0,0,0,1,0,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,0,1,
	      1,0,1,0,1,1,1,0,1,1,1,1,1,0,1,1,1,1,1,0,1,1,1,
	      1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,
	      1,1,1,0,1,0,1,0,1,0,0,0,1,0,1,0,0,0,1,0,1,0,1,
	      1,0,1,0,1,0,1,0,1,0,0,0,1,0,1,0,0,0,1,0,1,0,1
	};
	int x, y, i = 0;

	for (y = 0; y < 6; ++y) {
		for (x = 0; x < 23; ++x) {
			if (text[y * 23 + x] == 1) {
			    wAMMA[i] = create_sphere(x*4-45, y*4-10, -25,2, TEXTURE_GRID);
			    wAMMA[i].reflective = 0;
			    ++i;
			}
		}
	}
	wAMMA[69] = create_plane(0, 0, -10, 0, 0, -1, TEXTURE_XOR);
	wAMMA[70] = create_sphere(0, 30, -35, 15, TEXTURE_XOR);
}
