#!/bin/bash
#
# Build script for Vulture NetHack 3.6.6 Web (Emscripten) version
#
# Prerequisites:
#   1. Install Emscripten SDK:
#      git clone https://github.com/emscripten-core/emsdk.git
#      cd emsdk
#      ./emsdk install latest
#      ./emsdk activate latest
#      source ./emsdk_env.sh
#
#   2. Build the native version first to generate required files
#
#   3. Run this script from the sys/emscripten directory
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "Vulture NetHack 3.6.6 Web Build"
echo "================================"
echo ""

# Check for emcc
if ! command -v emcc &> /dev/null; then
    echo "ERROR: emcc not found!"
    echo ""
    echo "Please install the Emscripten SDK first:"
    echo "  git clone https://github.com/emscripten-core/emsdk.git"
    echo "  cd emsdk"
    echo "  ./emsdk install latest"
    echo "  ./emsdk activate latest"
    echo "  source ./emsdk_env.sh"
    exit 1
fi

# Check for em++
if ! command -v em++ &> /dev/null; then
    echo "ERROR: em++ not found!"
    echo "  em++ is required for Vulture's C++ source files."
    exit 1
fi

echo "Using Emscripten: $(emcc --version | head -1)"
echo ""

# Create build directory
BUILD_DIR="$ROOT_DIR/build-web"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Check for generated source files
echo "Step 1: Checking for generated source files..."
MISSING_FILES=""
for f in "$ROOT_DIR/src/vis_tab.c" "$ROOT_DIR/src/tile.c"; do
    if [ ! -f "$f" ]; then
        MISSING_FILES="$MISSING_FILES  $(basename $f)\n"
    fi
done
for f in "$ROOT_DIR/include/date.h" "$ROOT_DIR/include/onames.h" "$ROOT_DIR/include/pm.h"; do
    if [ ! -f "$f" ]; then
        MISSING_FILES="$MISSING_FILES  $(basename $f)\n"
    fi
done

if [ -n "$MISSING_FILES" ]; then
    echo "  Generated source files not found:"
    echo -e "$MISSING_FILES"
    echo "  Please build the native version first using:"
    echo "    cd $ROOT_DIR && make"
    echo "  This creates necessary generated files."
    exit 1
fi
echo "  Found generated source files."
echo ""

# Check for game data
echo "Step 2: Checking for game data..."
GAMEDATA_DIR="$ROOT_DIR/win/vulture/gamedata"
if [ ! -d "$GAMEDATA_DIR" ]; then
    echo "  ERROR: Game data directory not found at $GAMEDATA_DIR"
    exit 1
fi
echo "  Found game data directory."
echo ""

# Check for pre-generated parser/lexer files
echo "Step 3: Checking for pre-generated parser/lexer..."
PARSER_DIR="$ROOT_DIR/win/vulture/build_nethack_3_6_0"
if [ ! -f "$PARSER_DIR/vulture_tileconfig.parser.cpp" ] || [ ! -f "$PARSER_DIR/vulture_tileconfig.lexer.cpp" ]; then
    echo "  WARNING: Pre-generated parser/lexer files not found at $PARSER_DIR"
    echo "  The build may fail if bison/flex are not available."
fi
echo "  OK."
echo ""

# Build with Emscripten
echo "Step 4: Building with Emscripten..."
echo ""

# Copy the Makefile
cp "$SCRIPT_DIR/Makefile.em" "$BUILD_DIR/Makefile"

# Run make
make -j$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

echo ""
echo "Build complete!"
echo ""
echo "Output files in: $BUILD_DIR"
echo "  - nethack.html  (main HTML file)"
echo "  - nethack.js    (JavaScript glue code)"
echo "  - nethack.wasm  (WebAssembly binary)"
echo "  - nethack.data  (preloaded game data)"
echo ""
echo "To test, start a local web server:"
echo "  cd $BUILD_DIR"
echo "  node server.js"
echo "  # or: python3 -m http.server 8080"
echo ""
echo "Then open: http://localhost:4000/nethack.html"
