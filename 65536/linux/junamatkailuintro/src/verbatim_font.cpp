#include "verbatim_mesh.hpp"
#include "font_data.hpp"

static CompiledMesh* generate_glyph(VertexBuffer * vertex_buffer, unsigned c)
{
    Mesh msh;

    const float SCALE = 0.365f;

    font_data::glyph_record const & r = font_data::glyph_records[c];

    for(unsigned i = 0; i<r.v_count; ++i)
    {
        float x = r.vertices[i*2+0] * SCALE;
        float y = r.vertices[i*2+1] * SCALE;
        msh.addVertex(Vector3(x,y,0));
    }

    for(unsigned i = 0; i<r.i_count/3; ++i)
    {
        unsigned i0 = r.indices[i*3+0];
        unsigned i1 = r.indices[i*3+1];
        unsigned i2 = r.indices[i*3+2];
        msh.addFace(Face(i0, i1, i2, Color(255, 0, 0, 255)));
    }

    return msh.insert(vertex_buffer, 0.0f);
}

