#include <stdio.h>

void foo() {
  int a, b;
  a = 0;
  b = 10;
  if (a > 0) {
    printf("hello\n");
  } else if (b > 0) {
    printf("world\n");
  } else {
    printf("c lang\n");
  }
}

int main() {
  int a, b;
  a = 0;
  b = 10;
  if (a < 10 && b < 100) {
    printf("hello\n");
  } else {
    printf("world\n");
  }
  return 0;
}
