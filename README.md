# Hazard3 Mandelbrot Testbench

This project provides a Verilator-based simulation environment for a Mandelbrot
fractal generator running on a Hazard3 RISC-V processor. It supports both
real-time visualization via SDL2 and headless execution with image export.

## Getting Started

To clone the repository and initialize the Hazard3 submodule (without its own recursive submodules):

```bash
git clone --depth 1 https://github.com/verijit/verilator-hazard3-mandelbrot-testbench.git
cd verilator-hazard3-mandelbrot-testbench
git submodule update --init --depth 1 Hazard3
```

## Prerequisites

To build the project, you need the following dependencies:

- Verilator
- Clang/LLVM
- SDL2 & SDL2_image
- Python 3

## Building

The project uses a `Makefile` to manage the build process.

Build with Visualization (SDL2):
```bash
make main_verilator_sdl
```

Build Headless (No SDL):

```bash
make main_verilator
```

(we build with `-O3`, because it is slightly faster than `-Os` for this core.)

## Running

### Interactive Mode (SDL2)

If you built `main_verilator_sdl`, run it with:

```bash
./main_verilator_sdl
```

Start the simulation by pressing `r`. The progress of the Mandelbrot
computation will be shown live in the window. It is implemented by reading the
correct part of the simulated RAM and showing it as an image (not by simulating
a frame buffer or anything advanced). The window title is updated with
MCycles/s every few seconds. This mode is for demo purposes and costs some
performance (about 10-20%) compared to running headless.

### Headless Mode

If you built `main_verilator`, run it with:

```bash
./main_verilator
```

The simulation will run at maximum speed in the console.

Upon completion (when the simulated hardware executes an EBREAK instruction and
sets the `finished` flag), the simulation will print final cycle count and
simulation speed. The final fractal will be written into the file `output.ppm`.


## Project Structure

- `main_verilator.cpp`: The C++ testbench and simulation loop.
- `monitor.hpp`: SDL2-based visualization engine (used in SDL build).
- `sw/mandelbrot.c`: RISC-V C source code for the Mandelbrot calculation.
- `soc.tmpl.v`: The top-level Verilog module for the Hazard3 core.
- `Hazard3/`: Submodule containing the Hazard3 RISC-V core.
- `ahb_sync_sram.v` / `sram_sync.v`: Memory components for the SoC.


## Results

On an AMD Ryzen 7 PRO 7840U with 32GB RAM running Ubuntu 24.04 the timing
results of verilator compared against [verijit](https://verijit.com) are:

| Simulator | MCycles/s | max RAM used in MB |
|-----------|----------:|-------------------:|
| verilator |       3.6 |                133 |
| verijit   |     766.8 |                449 |
| ratio     |      213x |              0.30x |
