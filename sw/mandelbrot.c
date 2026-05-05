// Copyright 2026 Can Joshua Lehmann

#ifndef SIZE_LOG2
#define SIZE_LOG2 10
#endif

#ifndef SIZE
#define SIZE (1 << SIZE_LOG2)
#endif

#ifndef MAX_ITERS
#define MAX_ITERS 256
#endif

typedef struct {
  int32_t x;
} fixed_8_24_t;

__attribute__((always_inline))
fixed_8_24_t fixed_add(fixed_8_24_t a, fixed_8_24_t b) {
  return (fixed_8_24_t) {.x = a.x + b.x};
}

__attribute__((always_inline))
fixed_8_24_t fixed_sub(fixed_8_24_t a, fixed_8_24_t b) {
  return (fixed_8_24_t) {.x = a.x - b.x};
}

__attribute__((always_inline))
fixed_8_24_t fixed_mul(fixed_8_24_t a, fixed_8_24_t b) {
  int64_t product = (int64_t) a.x * (int64_t) b.x;
  return (fixed_8_24_t) {.x = (int32_t) (product >> 24)};
}

__attribute__((always_inline))
fixed_8_24_t fixed_int(int32_t n) {
  return (fixed_8_24_t) {.x = n << 24};
}

__attribute__((always_inline))
int fixed_lt(fixed_8_24_t a, fixed_8_24_t b) {
  return a.x < b.x;
}

typedef struct {
  fixed_8_24_t real;
  fixed_8_24_t imag;
} complex_t;

__attribute__((always_inline))
complex_t complex_add(complex_t a, complex_t b) {
  return (complex_t) {
    .real = fixed_add(a.real, b.real),
    .imag = fixed_add(a.imag, b.imag)
  };
}

__attribute__((always_inline))
complex_t complex_mul(complex_t a, complex_t b) {
  // (a.real + a.imag i) * (b.real + b.imag i)
  // = a.real * b.real + a.real * b.imag i + a.imag i * b.real + a.imag i * b.imag i
  // = (a.real * b.real - a.imag * b.imag) + (a.real * b.imag + a.imag * b.real) i
  return (complex_t) {
    .real = fixed_sub(fixed_mul(a.real, b.real), fixed_mul(a.imag, b.imag)),
    .imag = fixed_add(fixed_mul(a.real, b.imag), fixed_mul(a.imag, b.real))
  };
}

__attribute__((always_inline))
fixed_8_24_t fixed_square_abs(complex_t z) {
  // |z|^2 = z.real^2 + z.imag^2
  return fixed_add(fixed_mul(z.real, z.real), fixed_mul(z.imag, z.imag));
}

__attribute__((always_inline))
uint8_t clamp8(size_t x) {
  return x > 255 ? 255 : (uint8_t) x;
}

__attribute__((always_inline))
uint32_t rgb(uint8_t r, uint8_t g, uint8_t b) {
  return ((uint32_t) r << 16) | ((uint32_t) g << 8) | (uint32_t) b;
}

void mandelbrot(uint32_t image[SIZE][SIZE]) {
  for (size_t y = 0; y < SIZE; y++) {
    for (size_t x = 0; x < SIZE; x++) {
      complex_t c = {
        .real = (fixed_8_24_t) {.x = (((int32_t) x - SIZE / 2) << (24 - SIZE_LOG2 + 1)) - (1 << 23)},
        .imag = (fixed_8_24_t) {.x = ((int32_t) y - SIZE / 2) << (24 - SIZE_LOG2 + 1)}
      };
      complex_t z = {0};
      size_t iters = 0;
      while (iters < MAX_ITERS && fixed_lt(fixed_square_abs(z), fixed_int(4))) {
        z = complex_add(complex_mul(z, z), c);
        iters++;
      }

      if (iters == MAX_ITERS) {
        image[y][x] = 0; // black
      } else {
        image[y][x] = rgb(clamp8(iters << 4), clamp8(iters << 2), 255 - clamp8(iters << 4));
      }
    }
  }
}



int main() {
  uint32_t image[SIZE][SIZE] = {0};
  mandelbrot(image);

  used_image(&image[0][0], SIZE, SIZE);

  return 0;
}
