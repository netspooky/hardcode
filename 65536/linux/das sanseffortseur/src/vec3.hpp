#ifndef VEC3_HPP
#define VEC3_HPP

class vec3
{
public:
    vec3();
    vec3(float xx, float yy, float zz);
    float &operator()(int i);
    float operator()(int i) const;
    vec3 &operator-=(const vec3 &);
    vec3 operator-(const vec3 &);

    vec3 operator+(const vec3&v );
    vec3 operator*(float s);

    ~vec3();
    float x,y,z;
};


#endif
