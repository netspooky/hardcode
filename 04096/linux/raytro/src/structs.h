/**
 * Structs for a ray tracer.
 *
 * @author Timo Wirén
 * @version 2008-02-24
 * @licence GNU GPL
 */
typedef struct {
	float x, y, z;
} Vector;

typedef struct {
	Vector position; /* Center of the sphere or a point in the plane. */
	Vector hit_point;
	Vector hit_normal;
	Vector color;
	Vector eye_to_surface; 
	Vector north;
	Vector equator;
	Vector axis; /* cylinder stuff: vector pointing from position */

	float radius;

	/* Used in the first-hit optimization. */
	float length; 
	float ndotp; 
	float edotn;

	float diffuse;
	float specular;
	int shininess;

	char type;
	char reflective;
	
	int texture[256 * 256];
} Object;
