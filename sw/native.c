#include <stdint.h>
#include <stdio.h>

void used_i32(int32_t* ptr, size_t size) {
  printf("%p:\n", (void*) ptr);
  for (size_t it = 0; it < size; it++) {
    if (it != 0) {
      printf(", ");
      if (it % 32 == 0) {
        printf("\n");
      }
    }
    printf("%d", ptr[it]);
  }
  printf("\n");
}

void used_str(const char* str) {
  printf("%s\n", str);
}

void used_image(uint32_t* image, size_t height, size_t width) {
  // Print the image in PPM format
  printf("P3\n%zu %zu\n255\n", width, height);
  for (size_t y = 0; y < height; y++) {
    for (size_t x = 0; x < width; x++) {
      uint32_t pixel = image[y * width + x];
      uint8_t r = (pixel >> 16) & 0xFF;
      uint8_t g = (pixel >> 8) & 0xFF;
      uint8_t b = pixel & 0xFF;
      printf("%d %d %d ", r, g, b);
    }
    printf("\n");
  }
}
