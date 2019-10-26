#include <cstdio>

int main() {
    int window_w, window_h, image_w, image_h;
    scanf("%d %d %d %d", &window_w, &window_h, &image_w, &image_h);

    printf("const size_t window_w = %d, window_h = %d;\n", window_w, window_h);
    printf("const size_t image_w = %d, image_h = %d;\n", image_w, image_h);
    printf("const size_t fb_w = %d, fb_h = %d;\n", image_w*4, image_h*4);
    printf("#define SCALE \"vec2(%f,%f)\"\n", float(image_w) / float(window_w), float(image_h) / float(window_h));
    printf("#define FB_W \"%d\"\n", image_w * 4);
    printf("#define FB \"vec2(%d,%d)\"\n", image_w * 4, image_h * 4);
    return 0;
}
