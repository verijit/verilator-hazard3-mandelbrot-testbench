// Copyright 2026 Can Joshua Lehmann
// Displays a buffer in RAM as an image using SDL2.
// Runs in parallel with the simulation

#include <string>
#include <thread>
#include <semaphore>
#include <atomic>

#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>

class Monitor {
private:
  size_t _width = 0;
  size_t _height = 0;
  uint32_t* _image = nullptr;

  SDL_Window* _window = nullptr;
  SDL_Renderer* _renderer = nullptr;
  SDL_Texture* _texture = nullptr;
  SDL_Texture* _splash_texture = nullptr;
  bool _show_splash = true;

  std::string _base_title;
  std::atomic<double>& _mcycles_per_sec;
public:
  Monitor(const std::string& title,
          size_t width,
          size_t height,
          uint32_t* image,
          const char* splash_path,
          std::atomic<double>& mcycles_per_sec):
      _width(width), _height(height), _image(image),
      _base_title(title), _mcycles_per_sec(mcycles_per_sec) {

    SDL_Init(SDL_INIT_EVERYTHING);

    _window = SDL_CreateWindow(
      title.c_str(),
      SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
      width, height,
      0
    );

    _renderer = SDL_CreateRenderer(_window, -1, 0);

    _texture = SDL_CreateTexture(
      _renderer,
      SDL_PIXELFORMAT_XRGB8888,
      SDL_TEXTUREACCESS_STREAMING,
      width, height
    );

    SDL_Surface* splash_surface = IMG_Load(splash_path);
    if (splash_surface) {
      _splash_texture = SDL_CreateTextureFromSurface(_renderer, splash_surface);
      SDL_FreeSurface(splash_surface);
    }
  }

  void run(std::counting_semaphore<>& sema) {
    double last_mcycles_per_sec = 0.0;

    while (true) {
      SDL_Event event;
      while (SDL_PollEvent(&event)) {
        if (event.type == SDL_QUIT) {
          // just exit the process, otherwise the window becomes unresponsive
          // until the simulation is done
          exit(0);
          return;
        }

        if (event.type == SDL_KEYDOWN) {
          if (event.key.keysym.sym == SDLK_r) {
            _show_splash = false;
            sema.release();
          }
        }
      }

      if (!_show_splash) {
        double current_mcycles = _mcycles_per_sec.load(std::memory_order_relaxed);
        if (current_mcycles != last_mcycles_per_sec) {
          std::string new_title = _base_title;
          if (current_mcycles > 0.0) {
            new_title += " - " + std::to_string(current_mcycles) + " MCycles/s";
          }
          SDL_SetWindowTitle(_window, new_title.c_str());
          last_mcycles_per_sec = current_mcycles;
        }
      }

      if (_show_splash && _splash_texture) {
        SDL_SetRenderDrawColor(_renderer, 255, 255, 255, 0);
        SDL_RenderClear(_renderer);
        SDL_RenderCopy(_renderer, _splash_texture, nullptr, nullptr);
      } else {
        SDL_RenderClear(_renderer);
        SDL_UpdateTexture(_texture, nullptr, _image, _width * sizeof(uint32_t));
        SDL_RenderCopy(_renderer, _texture, nullptr, nullptr);
      }
      SDL_RenderPresent(_renderer);
    }
  }

  class Handle {
  private:
    std::thread _thread;
    std::counting_semaphore<> _sema;
    std::atomic<double> _mcycles_per_sec{0.0};
  public:
    Handle(const std::string& title,
           size_t width,
           size_t height,
           uint32_t* image,
           const char* splash_path): _sema(0) {

      _thread = std::thread([this, title, width, height, image, splash_path](){
        Monitor monitor(title, width, height, image, splash_path, _mcycles_per_sec);
        monitor.run(_sema);
      });
    }

    std::counting_semaphore<>& sema() { return _sema; }

    void set_mcycles_per_sec(double value) {
      _mcycles_per_sec.store(value, std::memory_order_relaxed);
    }

    void join() {
      _thread.join();
    }
  };

  static Handle launch(const std::string& title,
                       size_t width,
                       size_t height,
                       uint32_t* image,
                       const char* splash_path) {
    return Handle(title, width, height, image, splash_path);
  }
};
