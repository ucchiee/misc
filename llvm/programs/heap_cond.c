#include <stdio.h>
#include <stdlib.h>

int main(void) {
  int *ptr;
  ptr = (int *)malloc(sizeof(int));
  *ptr = 0;
  if (*ptr > 10) {
    printf("hello %d\n", *ptr);
  } else {
    printf("world\n");
  }
  return *ptr;
}
