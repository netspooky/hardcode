layout(points) in;
layout(line_strip, max_vertices = 4) out;

out Fragment {
    vec4 pos;
} frag;

void note(float ch, float pos, float l, float f) {
    vec4 v = vec4(pos, ch, 0, 1) * vec4(2.0/"RUNTIME",2.0/"CHANNELS",0,1) - vec4(1,0.95,0,0);

    gl_Position = v;
    frag.pos = vec4(1,pos,l,f);
    EmitVertex();

    gl_Position = v + vec4(l*2/"RUNTIME",0,0,0);
    frag.pos = vec4(1,pos,l,f);
    EmitVertex();
}

void kick(int id) {
    note("KICK", id*0.5, 0.25, 0);
}

void kosh(int id) {
    note("KOSH", id*0.5+0.3, 0.1, 0);
}

void noise(int id) {
    note("NOISE", id*2, 2, 0);
}

void main() {
    // Vertex shader writes gl_VertexID as position
    int id = int(gl_in[0].gl_Position.x);

    if (id < 30) {
        kick(id);
        return;
    }
    if (id < 60) {
        kosh(id-30);
        return;
    }
    if (id < 70) {
        noise(id-52);
        return;
    }
    if (id < 110) {
        kick(id-30);
        return;
    }
    if (id < 120) {
        kosh(id-60);
        return;
    }
}
