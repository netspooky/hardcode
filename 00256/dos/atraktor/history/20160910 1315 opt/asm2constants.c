#include <stdio.h>
#include <stdlib.h>

#define die(...) (fprintf(stderr, __VA_ARGS__), exit(-1), 1)

int main(int argc, char** argv) {
   if (argc != 3) die("Usage: constants <input> <output>");
   FILE* r; (r = fopen(argv[1], "rb")) || die("Can't open \"%s\"!", argv[1]);
   FILE* w; (w = fopen(argv[2], "w")) || die("Can't open \"%s\"!", argv[2]);

   unsigned char buf[65536];
   int n = fread(buf, 1, 65536, r);

   fprintf(w, "[ adr] BB ubb sbbb  WWWW uwwww swwwww  DDDDDDDD uddddddddd sdddddddddd  float    double\n");
   for (int i=0; i<n; i++) {
      fprintf(w, "\n[%04x] ", i);
      fprintf(w, "%02X ", *(unsigned char*)(&buf[i]));
      fprintf(w, "%3u ", *(unsigned char*)(&buf[i]));
      fprintf(w, "%4d  ", *(signed char*)(&buf[i]));
      if (i+2 <= n) {
         fprintf(w, "%04X ", *(unsigned short*)(&buf[i]));
         fprintf(w, "%5u ", *(unsigned short*)(&buf[i]));
         fprintf(w, "%6d  ", *(signed short*)(&buf[i]));
      }
      if (i+4 <= n) {
         fprintf(w, "%08X ", *(unsigned*)(&buf[i]));
         fprintf(w, "%10u ", *(unsigned*)(&buf[i]));
         fprintf(w, "%11d  ", *(signed*)(&buf[i]));
         fprintf(w, "%16.9g  ", *(float*)(&buf[i]));
      }
      if (i+8 <= n) {
         fprintf(w, "%25.18g  ", *(double*)(&buf[i]));
      }
   }


   fclose(r);
   fclose(w);

   return 0;
}
