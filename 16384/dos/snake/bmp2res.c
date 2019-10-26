/* CHANGES FROM ASM VERSION */
/* Input filenames passed to parameters */

#include <fcntl.h>;         /* Needed for open modes */
#include <sys/stat.h>;      /* Needed for create modes */

void main(int argc, char *argv[]) {
  int handle; char buffer[302]; char result[150]; int i, j, temp;

  /* Parameters control */
  if (argc != 3) {
    /* Usage */
    exit(1);
  }

  /* Let's read input file */
  handle = open(argv[1], O_RDONLY|O_BINARY);
  if (handle < 0) { printf("Can't open input BMP file\n"); exit(1); }

  /* Read input file (BMP 2 colors expected); Close it */
  read(handle, buffer, 302);
  close(handle);

  /* We have now in buffer[] an image like this: */
  /* 62 bytes (header) + 30 * (5 bytes (useful) + 3 bytes (zeros)) */
  /* Let's extract only the information bytes */
  for (i = 62; i < 302; i = i + 8) {
    for (j = 0; j < 5; j++) { result[(i-62)*5/8+j] = buffer[i+j]; }
  }

  /* Windows format saves the information from down-left to */
  /* up-right; We have to turn this information upside down */
  /* so we can read from up-left to down-right */
  for (i = 0; i < 150 / 2; i = i + 5) {
    for (j = 0; j < 5; j++) {
      temp = result[145 - i + j];
      result[145 - i + j] = result[i + j];
      result[i + j] = temp;
    }
  }

  /* The last thing to consider is that Windows saves black */
  /* with '0' and white with '1'; we want '1' to represent */
  /* wall (drawn in black) and '0' to non-wall (in white); */
  /* let's negate all the bytes; remember !0xAB = 255 - 0xAB */
  for (i = 0; i < 150; i++) { result[i] = 255 - result[i]; }

  /* Let's create destination file, save result[] and close it */
  handle = open(argv[2], O_WRONLY|O_CREAT|O_TRUNC|O_BINARY, S_IWRITE);
  write(handle, result, 150);
  close(handle);
}
