#define SIZE_LOG2 10
#define SIZE (1 << SIZE_LOG2)

#include <iostream>
#include <chrono>
#include <fstream>

#include "Vmandelbrot_10.h"
#include "Vmandelbrot_10___024root.h"
#include "verilated.h"

#ifdef USE_SDL
#include "monitor.hpp"
#endif

#define MEASURE_TIME_EVERY_N_CYCLES 10000000

int main(int argc, char** argv) {
  std::cout << "starting\n";
  VerilatedContext* context = new VerilatedContext;
  context->commandArgs(argc, argv);

  using Clock = std::chrono::high_resolution_clock;

  size_t cycle = 0;

  Vmandelbrot_10* top = new Vmandelbrot_10(context);

  uint32_t* image = (uint32_t*) top->rootp->soc__DOT__d_ram__DOT__sram__DOT__behav_mem__DOT__mem.data() + 15728639;
  #ifdef USE_SDL
  Monitor::Handle handle = Monitor::launch("Verilator", SIZE, SIZE, image, "splash-verilator.png");

  handle.sema().acquire();
  #endif
  Clock::time_point start = Clock::now();
  Clock::time_point timeslice_start = start;
  size_t measure_time_at_cycle = MEASURE_TIME_EVERY_N_CYCLES;
  size_t timeslice_start_at_cycle = 0;
  while (!top->finished) {
    top->clock = 0;
    top->eval();
    top->clock = 1;
    top->eval();
    cycle++;
    size_t cycles_in_timeslice = cycle - timeslice_start_at_cycle;
    if (cycles_in_timeslice >= MEASURE_TIME_EVERY_N_CYCLES) {
      Clock::time_point end = Clock::now();
      size_t us = std::chrono::duration_cast<std::chrono::microseconds>(end - timeslice_start).count();
      double mcycles_per_sec = (double) cycles_in_timeslice / (double) us;
      #ifdef USE_SDL
      handle.set_mcycles_per_sec(mcycles_per_sec);
      #endif
      timeslice_start = end;
      timeslice_start_at_cycle = cycle;
      std::cout << mcycles_per_sec << " MCycles/sec" << std::endl;
    }
  }
  Clock::time_point end = Clock::now();
  size_t us = std::chrono::duration_cast<std::chrono::microseconds>(end - start).count();
  size_t secs = std::chrono::duration_cast<std::chrono::seconds>(end - start).count();
  double mcycles_per_sec = (double) cycle / (double) us;

  std::cout << "Finished at cycle " << cycle << "." << std::endl;
  std::cout << "Ran with " << mcycles_per_sec << " MCycles/s." << std::endl;
  std::cout << "Total time: " << secs << " seconds" << std::endl;

  std::cout << "Writing output.ppm..." << std::endl;
  std::ofstream out("output.ppm", std::ios::binary);
  out << "P6\n" << SIZE << " " << SIZE << "\n255\n";
  for (int i = 0; i < SIZE * SIZE; ++i) {
    uint32_t pixel = image[i];
    uint8_t r = (pixel >> 16) & 0xFF;
    uint8_t g = (pixel >> 8) & 0xFF;
    uint8_t b = pixel & 0xFF;
    out.put(r);
    out.put(g);
    out.put(b);
  }
  out.close();

  #ifdef USE_SDL
  handle.join();
  #endif

  return 0;
}
