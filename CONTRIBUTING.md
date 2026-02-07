# Contributing to Vulture NetHack

Thank you for your interest in contributing! This guide explains how to get started.

## Getting Started

1. Fork the repository on GitHub
2. Clone your fork locally
3. Build the project (see [README.md](README.md) for instructions)
4. Create a branch for your changes

```bash
git checkout -b my-feature vultures-3.6.6
```

## Development Setup

### Native Build (macOS)

```bash
brew install sdl2 sdl2_mixer sdl2_ttf libpng libogg libvorbis theora
cd sys/unix && sh setup.sh && cd ../..
make -j$(sysctl -n hw.ncpu)
```

After editing `Makefile.src` or `Makefile.top`, re-run `setup.sh` to regenerate Makefiles.

### Native Build (Linux)

```bash
sudo apt install build-essential libsdl2-dev libsdl2-mixer-dev libsdl2-ttf-dev libpng-dev libogg-dev libvorbis-dev libtheora-dev
cd sys/unix && sh setup.sh && cd ../..
make -j$(nproc)
```

### WebAssembly Build

See [README.md](README.md#webassembly-build-emscripten) for Emscripten setup.

## What to Work On

- Check [open issues](https://github.com/rahuljaguste/Vulture-NetHack-3.6.6/issues) for bugs and feature requests
- Issues labeled `good first issue` are a good starting point
- If you want to work on something not listed, open an issue first to discuss

## Code Style

- **C code** (NetHack core in `src/`): Follow the existing NetHack style. Use tabs for indentation. See `DEVEL/code_style.txt` for details.
- **C++ code** (Vulture frontend in `win/vulture/`): Use tabs for indentation. Follow the existing patterns in the codebase.
- Keep changes focused -- don't mix unrelated fixes in one PR.
- Don't add unnecessary comments, docstrings, or type annotations to code you didn't change.

## Submitting Changes

1. Commit your changes with a clear, descriptive message:
   ```bash
   git commit -m "Fix mouse wheel scrolling in inventory window"
   ```
2. Push to your fork:
   ```bash
   git push origin my-feature
   ```
3. Open a Pull Request against the `vultures-3.6.6` branch
4. Describe what your changes do and why
5. Reference any related issues (e.g., "Fixes #42")

## Pull Request Guidelines

- Keep PRs small and focused on a single change
- Ensure the native build compiles without new warnings
- Test your changes by playing the game
- If your change affects the WebAssembly build, test that too

## Platform-Specific Notes

### macOS
- Use `-lc++` instead of `-lstdc++` for C++ linking
- Homebrew headers are at `/opt/homebrew/include` on Apple Silicon

### Emscripten
- `fork()`, `exec()`, `signal()` are unavailable -- guard with `#ifdef __EMSCRIPTEN__`
- Use `emscripten_sleep()` instead of blocking calls
- Never call game functions directly from JS -- use `SDL_PushEvent` to avoid reentrancy crashes
- Data files must be built with Emscripten-compiled utilities due to struct alignment differences between architectures

## Reporting Bugs

Open an issue with:
- What you expected to happen
- What actually happened
- Steps to reproduce
- Platform and build type (native/web)

## Questions?

Open an issue or start a discussion. We're happy to help!
