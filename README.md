# Vulture NetHack 3.6.6

A graphical frontend for [NetHack 3.6.6](https://nethack.org) with isometric tiles, mouse-driven UI, sound effects, and music. Play in your browser via WebAssembly or natively on macOS and Linux.

Based on [Vulture's Eye/Claw](http://www.yourng.com/vulture.html), updated for NetHack 3.6.6 and ported to SDL2.

## Features

- Isometric tile-based graphics with smooth scrolling
- Point-and-click interface with context menus
- Ambient sound effects and background music
- Fullscreen and windowed modes with resizable windows
- WebAssembly build for playing in the browser
- SDL2-based rendering (migrated from SDL1)

## Play in Browser

Visit the [GitHub Pages deployment](https://rahuljaguste.github.io/Vulture-NetHack-3.6.6/) to play directly in your browser -- no installation required.

## Building from Source

### Prerequisites

**macOS (Homebrew):**
```bash
brew install sdl2 sdl2_mixer sdl2_ttf libpng libogg libvorbis theora
```

**Ubuntu/Debian:**
```bash
sudo apt install build-essential libsdl2-dev libsdl2-mixer-dev libsdl2-ttf-dev libpng-dev libogg-dev libvorbis-dev libtheora-dev
```

### Native Build

```bash
# Generate Makefiles
cd sys/unix && sh setup.sh && cd ../..

# Build and install locally
make -j$(nproc 2>/dev/null || sysctl -n hw.ncpu)
make install

# Run
compiled/games/lib/vulture-nethack-3.6.6dir/vulture-nethack-3.6.6
```

The game installs to `compiled/games/lib/vulture-nethack-3.6.6dir/`.

### WebAssembly Build (Emscripten)

Requires the [Emscripten SDK](https://emscripten.org/docs/getting_started/downloads.html) and a completed native build (for generated source files).

```bash
# Install Emscripten SDK (if not already installed)
git clone https://github.com/emscripten-core/emsdk.git
cd emsdk && ./emsdk install latest && ./emsdk activate latest && source ./emsdk_env.sh
cd ..

# Build native first (generates required files)
cd sys/unix && sh setup.sh && cd ../..
make -j$(nproc 2>/dev/null || sysctl -n hw.ncpu)
make install

# Build WebAssembly version
bash sys/emscripten/build-web.sh

# Test locally
cd build-web && node ../sys/emscripten/server.js
# Open http://localhost:4000/nethack.html
```

## How to Play

NetHack is a dungeon exploration game. Your goal is to descend through the Dungeon of Doom, retrieve the Amulet of Yendor, and ascend to offer it to your god.

- **Move**: Click on the map or use arrow keys / numpad
- **Actions**: Right-click objects and monsters for context menus
- **Inventory**: Click the backpack icon or press `i`
- **Commands**: Press `#` for extended commands, `?` for help
- **Save**: Press `S` to save and quit

For a full guide, see the [NetHack Guidebook](https://nethack.org/v366/Guidebook.html).

## Project Structure

```
src/              NetHack core game engine (C)
include/          Header files
win/vulture/      Vulture graphical frontend (C++)
  winclass/       Window class implementations
  gamedata/       Graphics, sounds, fonts, config
  vendor/         Third-party libraries (theoraplay)
sys/unix/         Unix/macOS build system
sys/emscripten/   WebAssembly build system
dat/              Game data files (levels, quests, etc.)
doc/              Documentation
```

## Recent Changes

- **Quest text fix** -- Fixed quest text not loading in the web build
- **Mouse input fix** -- Fixed mouse not working in native build
- **Game Over screen** -- Show a proper Game Over screen instead of auto-reloading on quit (web build)
- **CI/CD** -- Consolidated CI pipeline to web-only builds; deploy via gh-pages branch
- **Linux build fix** -- Fixed partial link conflict between `-r` and `-pie` flags on Linux
- **SDL2 migration** -- Fully ported from SDL1 to SDL2 (no more sdl12-compat dependency)
- **WebAssembly port** -- Play NetHack in the browser via Emscripten/WebAssembly
- **Community files** -- Added CONTRIBUTING.md, CODE_OF_CONDUCT.md, and issue/PR templates

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on how to contribute.

## License

This project is licensed under the [NetHack General Public License](LICENSE), based on the Bison General Public License. See the LICENSE file for details.

## Credits

- **NetHack DevTeam** -- the original NetHack game
- **Clive Crous** -- Vulture's Eye/Claw graphical frontend
- **Vulture contributors** -- ongoing maintenance and SDL2/WebAssembly port
