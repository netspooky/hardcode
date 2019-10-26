#include "particlesystem.h"
#include "utility.h"

void ps_calc_normals(particlesystem* ps) {

	int		i;
	vec		v[2];
	face*	f;

	f = ps->faces;

	for(i=0; i<ps->face_count; i++) {

		vec_sub(&v[0], &ps->particles[f->idx[0]].pos, &ps->particles[f->idx[1]].pos);
		vec_sub(&v[1], &ps->particles[f->idx[0]].pos, &ps->particles[f->idx[3]].pos);
		vec_cross(&f->normal, &v[0], &v[1]);
		//vec_normalize(&f->normal);	// we have GL_NORMALIZE enabled

		f++;
	}
}

void ps_create_springs(particlesystem* ps) {

	int		i;
	face*	f;
	spring*	s;

	f = ps->faces;
	s = ps->springs;

	for(i=0; i<ps->face_count; i++) {

		spring_set(s++, &ps->particles[f->idx[0]], &ps->particles[f->idx[1]]);
		spring_set(s++, &ps->particles[f->idx[1]], &ps->particles[f->idx[2]]);
		spring_set(s++, &ps->particles[f->idx[2]], &ps->particles[f->idx[3]]);
		spring_set(s++, &ps->particles[f->idx[3]], &ps->particles[f->idx[0]]);
		spring_set(s++, &ps->particles[f->idx[0]], &ps->particles[f->idx[2]]);	// cross
		spring_set(s++, &ps->particles[f->idx[1]], &ps->particles[f->idx[3]]);

		f++;
	}

	// default texture id (reset for floor & cloth!)
	ps->texture = 3;
}

void ps_plane(particlesystem* ps, float sx, float sy, float im) {

	int			j, i;
	vec			v;
	particle*	p;
	face*		f;

	p = ps->particles;
	f = ps->faces;

	// verts
	ps->particle_count	= PLANE_SUBX * PLANE_SUBY;
	for(j=0; j<PLANE_SUBY; j++) {

		for(i=0; i<PLANE_SUBX; i++) {

			vec_set(	&v,	-sx * 0.5f + (float)i * (sx / (float)(PLANE_SUBX - 1)),
							0.0f,
							-sy * 0.5f + (float)j * (sy / (float)(PLANE_SUBY - 1))
					);
			
			particle_set(p, &v, im);

			vec_set(	&p->tex,	(float)i * (PLANE_TEXX / (float)(PLANE_SUBX - 1)),
									(float)j * (PLANE_TEXY / (float)(PLANE_SUBY - 1)),
									0.0f
					);

			p++;
		}
	}

	// indices
	ps->face_count	= (PLANE_SUBX - 1) * (PLANE_SUBY - 1);

	for(j=0; j<PLANE_SUBY - 1; j++)
		for(i=0; i<PLANE_SUBX - 1; i++)
			face_set(	f++, PLANE_SUBX * j + i,
							 PLANE_SUBX * (j + 1) + i, 
							 PLANE_SUBX * (j + 1) + i + 1,
							 PLANE_SUBX * j + i + 1	);

	ps_create_springs(ps);
}

void ps_box(particlesystem* ps, float sx, float sy, float sz, float tx, float ty, float im) {

	int			i;
	vec			v;
	particle*	p;
	face*		f;

	p = ps->particles;
	f = ps->faces;
	
	ps->particle_count	= 8;

	// verts
	for(i=0; i<ps->particle_count; i++) {

		vec_set(&v, (i & 1) ? 0.0f : sx, (i & 2) ? 0.0f : sy, (i & 4) ? 0.0f : sz);
		particle_set(p, &v, im);

		p++;
	}

	// indices
	ps->face_count = 6;
	
	face_set(f++, 0, 1, 3, 2);
	face_set(f++, 5, 4, 6, 7);
	face_set(f++, 4, 0, 2, 6);
	face_set(f++, 5, 7, 3, 1);
	face_set(f++, 5, 1, 0, 4);
	face_set(f++, 7, 6, 2, 3);

	ps_create_springs(ps);
}

void ps_set_force(particlesystem* ps, float maskx, float masky, float maskz) {

	int			i;
	particle*	p;

	p = ps->particles;

	for(i=0; i<ps->particle_count; i++) {
		vec_set(&p->force,	maskx * randf(-360.0f, 360.0f), 
							masky * randf(-360.0f, 360.0f),
							maskz * randf(-360.0f, 360.0f)	);
		p++;
	}
}

void ps_translate(particlesystem* ps, float x, float y, float z) {

	int			i;
	vec			tmp;
	particle*	p;

	p = ps->particles;
	vec_set(&tmp, x, y, z);

	for(i=0; i<ps->particle_count; i++) {
		vec_add(&p->pos, &p->pos, &tmp);
		vec_add(&p->opos, &p->opos, &tmp);
		p++;
	}
}

void ps_relax(particlesystem* ps, float radius2, float deform) {

	int			i;
	vec			tmp;
//	vec			response;

	float		len;
//	float		mass_sum;
//	float		vel_n;

	particle*	p;
	spring*		s;

	s = ps->springs;
	p = ps->particles;

	// floor constraint
	for(i=0; i<ps->particle_count; i++) {

		// special case: sphere at (0/0/0)
		len = vec_length2(&p->pos);

//		if((len < radius2) || (p->pos.y < 0.05f)) {

			// sphere
			if(len < radius2)
				vec_mul(&p->pos, &p->pos, sqrt(radius2 / len));

			// plane
			p->pos.y = max(p->pos.y, 0.06f);
		
			// calc velocity normal to plane (trivial case: plane normal 0/1/0)
			// add response
			//vec_set(&response, 0.0f, fabs(p->pos.y - p->opos.y) * 80.0f, 0.0f);
			//vec_add(&p->force, &p->force, &response);

//		}//*/

		p++;
	}

	// spring constraint
	for(i=0; i<ps->face_count * 6; i++) {

		/*if(s->restLength == 0.0f) {
			s++;
			continue;
		}*/

		//mass_sum = s->p1->invm + s->p2->invm;

		//if(mass_sum != 0.0f) {		// = both particles of spring fixed -> does not happen!

			// adjust spring len to rest len of spring
			// move particles equally (if not fixed!)
			vec_sub(&tmp, &s->p2->pos, &s->p1->pos);
			len = vec_length(&tmp);

			//vec_mul(&dp, &dp, (len - s->restLength) / (len * mass_sum));
			vec_mul(&tmp, &tmp, (len - s->restLength) / (len * (s->p1->invm + s->p2->invm)));

			vec_madd(&s->p1->pos, &s->p1->pos, &tmp, s->p1->invm * deform);
			vec_madd(&s->p2->pos, &s->p2->pos, &tmp, -s->p2->invm * deform);
		//}

		s++;
	}
}

void ps_integrate(particlesystem* ps, float delta) {

	int			i;
	vec			tmp;
	particle*	p;

	ps_calc_normals(ps);

	// 3 in 1
	// apply gravity to existing forces + integrate + clear force
	p = ps->particles;
	for(i=0; i<ps->particle_count; i++) {

		// add gravity
		p->force.y -= 9.81f;

		// verlet integrate
		// new_pos += (pos - opos) * 0.99 + (force / mass) * delta^2
		// old_pos = pos
		vec_sub(&tmp, &p->pos, &p->opos);
		vec_cpy(&p->opos, &p->pos);
		vec_madd(&p->pos, &p->pos, &tmp, 0.99f);
		vec_madd(&p->pos, &p->pos, &p->force, p->invm * delta * delta);

		// clear force
		vec_set(&p->force, 0.0f, 0.0f, 0.0f);

		p++;
	}

	//ps->time += delta;
}

void ps_render(particlesystem* ps) {

	int		j, i;
	face*	f;

	f = ps->faces;

	glBindTexture(GL_TEXTURE_2D, ps->texture);
	glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_LIGHTING);
	glEnable(GL_TEXTURE_2D);

	// render solid
	glBegin(GL_QUADS);
	for(j=0; j<ps->face_count; j++) {

		glNormal3fv(&f->normal.x);

		for(i=0; i<4; i++) {

			glTexCoord2fv(&ps->particles[f->idx[i]].tex.x);
			glVertex3fv(&ps->particles[f->idx[i]].pos.x);
		}

		f++;
	}
	glEnd();
}

void ps_render_extras(particlesystem* ps, int shadows) {

	int		j, i;
	face*	f;

	glBlendFunc(GL_SRC_ALPHA, GL_ZERO);
	glDisable(GL_LIGHTING);
	glDisable(GL_TEXTURE_2D);
	glColor4f(0.05f, 0.05f, 0.05f, 0.2f);

#ifdef SHADOWS

	// shadows general case:
	// p = l - ( (d+n.l) / n.(v-l) ) * (v - l)
	// (v.. projected vertex)

	if(shadows) {

		f = ps->faces;

		glBegin(GL_QUADS);
		for(j=0; j<ps->face_count; j++) {

			for(i=0; i<4; i++) {

				// special case n=(0/1/0) and d = 0
				// suppose lightsource at l=(0/500/0)

				// check for back projection
				// error prone: if objects particles are above AND under lightsource
				if(ps->particles[f->idx[i]].pos.y < 500.0f)
					glVertex3f(	(500.0f * ps->particles[f->idx[i]].pos.x) / (500.0f - ps->particles[f->idx[i]].pos.y),
								0.03f,
								(500.0f * ps->particles[f->idx[i]].pos.z) / (500.0f - ps->particles[f->idx[i]].pos.y)
							);
			}

			f++;
		}
		glEnd();
	}
#endif

	// render wireframe
	f = ps->faces;

	glBegin(GL_LINES);

	for(j=0; j<ps->face_count; j++) {

		for(i=0; i<4; i++) {
			glVertex3fv(&ps->particles[f->idx[i]].pos.x);
			glVertex3fv(&ps->particles[f->idx[(i + 1) % 4]].pos.x);
		}

		f++;
	}

	glEnd();
}

void ps_render_range(particlesystem* ps, int count, int shadows) {

	int i;

	for(i=0; i<count; i++) {

		ps_render(&ps[i]);
		ps_render_extras(&ps[i], shadows);
	}
}
