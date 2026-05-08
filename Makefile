SDL2_FLAGS := $(shell sdl2-config --cflags --libs) -lSDL2_image
LLVM_FLAGS := $(shell llvm-config --cflags --libs)
INSPECT_FLAGS := ${INSPECT_FLAGS} -DPROFILE_STATS
INSPECT_FLAGS := ${INSPECT_FLAGS} -DNO_COUNT_COLLISIONS
OPT_FLAGS := -g -O3 -march=native -DNDEBUG
CXXFLAGS := ${OPT_FLAGS} ${LLVM_FLAGS} ${SDL2_FLAGS} ${INSPECT_FLAGS} --std=c++20

all: main_verilator_sdl main_verilator

clean:
	rm -rf obj_dir main_verilator main_verilator_sdl

HAZARD3_FILES := \
	ahb_sync_sram.v \
	sram_sync.v \
	Hazard3/hdl/hazard3_core.v \
	Hazard3/hdl/hazard3_cpu_2port.v \
	Hazard3/hdl/arith/hazard3_alu.v \
	Hazard3/hdl/arith/hazard3_branchcmp.v \
	Hazard3/hdl/arith/hazard3_mul_fast.v \
	Hazard3/hdl/arith/hazard3_muldiv_seq.v \
	Hazard3/hdl/arith/hazard3_onehot_encode.v \
	Hazard3/hdl/arith/hazard3_onehot_priority.v \
	Hazard3/hdl/arith/hazard3_onehot_priority_dynamic.v \
	Hazard3/hdl/arith/hazard3_priority_encode.v \
	Hazard3/hdl/arith/hazard3_shift_barrel.v \
	Hazard3/hdl/hazard3_csr.v \
	Hazard3/hdl/hazard3_decode.v \
	Hazard3/hdl/hazard3_frontend.v \
	Hazard3/hdl/hazard3_instr_decompress.v \
	Hazard3/hdl/hazard3_irq_ctrl.v \
	Hazard3/hdl/hazard3_pmp.v \
	Hazard3/hdl/hazard3_power_ctrl.v \
	Hazard3/hdl/hazard3_regfile_1w2r.v \
	Hazard3/hdl/hazard3_triggers.v

all: main_verilator main_verilator_sdl

main_verilator_sdl: mandelbrot_10.v main_verilator.cpp monitor.hpp
	rm -rf obj_dir
	verilator --cc --exe -LDFLAGS "${SDL2_FLAGS}" -CFLAGS "-DUSE_SDL" -j 1 -O3 --x-assign fast --x-initial fast --no-assert --compiler clang  \
		main_verilator.cpp \
		-IHazard3/ \
		-IHazard3/hdl/ \
		mandelbrot_10.v \
		$(HAZARD3_FILES)
	(cd obj_dir; make OPT_FAST="-O3 -march=native --std=c++20" -f Vmandelbrot_10.mk )
	cp obj_dir/Vmandelbrot_10 main_verilator_sdl

main_verilator: mandelbrot_10.v main_verilator.cpp
	rm -rf obj_dir
	verilator --cc --exe -j 1 -O3 --x-assign fast --x-initial fast --no-assert --compiler clang  \
		main_verilator.cpp \
		-IHazard3/ \
		-IHazard3/hdl/ \
		mandelbrot_10.v \
		$(HAZARD3_FILES)
	(cd obj_dir; make OPT_FAST="-O3 -march=native --std=c++20" -f Vmandelbrot_10.mk)
	cp obj_dir/Vmandelbrot_10 main_verilator

mandelbrot_10.v: sw/bin/mandelbrot_rv32imac venv/bin/python load_elf.py soc.tmpl.v
	venv/bin/python load_elf.py $< $@

venv/bin/python: requirements.txt
	rm -rf venv
	python3 -m venv venv
	./venv/bin/pip install -r requirements.txt

