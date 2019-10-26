in Fragment {
    vec4 pos;
} frag;

out vec4 color;

void main(){
    color = frag.pos;
}
