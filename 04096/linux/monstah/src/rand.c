static int rand_next = 1;

int rand() {
  rand_next = 123123 * rand_next + 53151;
  return rand_next / 65536;
}
