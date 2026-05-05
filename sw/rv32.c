int main();

#define NULL ((void*) 0)

__asm__(
  ".global _start\n"
  ".type _start, @function\n"
  "_start:\n"
  "  call main\n"
  // Protect early finish from prefetch.
  "  nop\n"
  "  nop\n"
  "  nop\n"
  ".align 2\n"
  ".option push\n"
  ".option arch, -c\n"
  "  ebreak\n"
  ".option pop\n"
  ".size _start, .-_start\n"
);

typedef _BitInt(8) int8_t;
typedef _BitInt(16) int16_t;
typedef _BitInt(32) int32_t;
typedef _BitInt(64) int64_t;

typedef unsigned _BitInt(8) uint8_t;
typedef unsigned _BitInt(16) uint16_t;
typedef unsigned _BitInt(32) uint32_t;
typedef unsigned _BitInt(64) uint64_t;

typedef unsigned _BitInt(sizeof(void*) * 8) size_t;

void used_i32(int32_t* ptr, size_t size) {
  asm volatile("" : : "r"(ptr) : "memory");
}

void used_str(const char* str) {
  asm volatile("" : : "r"(str) : "memory");
}

void used_image(uint32_t* image, size_t height, size_t width) {
  asm volatile("" : : "r"(image), "r"((int) height), "r"((int) width) : "memory");
}

void memset(void* ptr, int value, size_t num) {
  uint8_t* bytes = (uint8_t*) ptr;
  for (size_t it = 0; it < num; it++) {
    bytes[it] = (uint8_t) value;
  }
}

