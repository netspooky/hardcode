#include "verbatim_mesh.hpp"

static CompiledMesh* compile_blender_model(VertexBuffer * vertex_buffer, 
                                           unsigned vert_count,
                                           float * vert_vector,
                                           unsigned face_count,
                                           unsigned * face_vector,
                                           float scale = 1.0f)
{
    Mesh msh;

    for(unsigned i=0; i<vert_count; ++i)
    {
        float x = vert_vector[i*3+0] * scale;
        float y = vert_vector[i*3+1] * scale;
        float z = vert_vector[i*3+2] * scale;
        msh.addVertex(Vector3(x,y,z));
    }

    for(unsigned i=0; i<face_count; ++i)
    {
        unsigned i0 = face_vector[i*6+0];
        unsigned i1 = face_vector[i*6+1];
        unsigned i2 = face_vector[i*6+2];
        uint8_t r = static_cast<uint8_t>(face_vector[i*6+3]);
        uint8_t g = static_cast<uint8_t>(face_vector[i*6+4]);
        uint8_t b = static_cast<uint8_t>(face_vector[i*6+5]);
        msh.addFace(Face(i0, i1, i2, Color(r, g, b, 255)));
    }

    return msh.insert(vertex_buffer);
}

