CFLAGS := -fPIC -ffreestanding -nostdlib -O2 -fno-unroll-loops -fno-inline-functions
CFLAGS_RV32IMAC := ${CFLAGS} -target riscv32-unknown-unknown -march=rv32imac

SW_DIR := .
TESTS=${SW_DIR}/mandelbrot.c

ARCHS := native rv32imac
ELF_TARGETS := $(foreach arch,$(ARCHS),$(patsubst ${SW_DIR}/%.c,bin/%_${arch},${TESTS}))
ASM_TARGETS := $(foreach arch,$(ARCHS),$(patsubst ${SW_DIR}/%.c,bin/%_${arch}.asm,${TESTS}))

all: ${ELF_TARGETS} ${ASM_TARGETS}

bin/%_rv32imac: %.c rv32.c
	clang ${CFLAGS_RV32IMAC} --include rv32.c -o $@ $<

bin/%_native: %.c native.c
	clang --include native.c -o $@ $<

bin/%.asm: bin/%
	llvm-objdump --disassemble $< > $@

clean:
	-rm -r bin
	mkdir bin

list:
	@echo "ELF targets:"
	@echo "${ELF_TARGETS}"
	@echo "ASM targets:"
	@echo "${ASM_TARGETS}"
