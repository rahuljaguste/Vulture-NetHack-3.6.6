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
#      (cd sys/unix && sh setup.sh && cd ../.. && make && make install)
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

# Check for native install
echo "Step 4: Checking for native install..."
NATIVE_DATADIR="$ROOT_DIR/compiled/games/lib/vulture-nethack-3.6.6dir"
if [ ! -d "$NATIVE_DATADIR" ]; then
    echo "  ERROR: Native install not found at $NATIVE_DATADIR"
    echo "  Please run 'make install' first."
    exit 1
fi
echo "  Found native install."
echo ""

# Build WASM utilities (dgn_comp, lev_comp, dlb) if not present
echo "Step 5: Building WASM utilities..."
UTIL_WASM_DIR="$BUILD_DIR/util-wasm"
mkdir -p "$UTIL_WASM_DIR"

UTIL_CFLAGS="-O2 -I$ROOT_DIR/include -I$ROOT_DIR/src -s NODERAWFS=1 -s EXIT_RUNTIME=1"

if [ ! -f "$UTIL_WASM_DIR/dgn_comp.js" ]; then
    echo "  Building dgn_comp..."
    emcc $UTIL_CFLAGS \
        "$ROOT_DIR/util/dgn_comp.c" \
        "$ROOT_DIR/util/dgn_lex.c" \
        "$ROOT_DIR/util/dgn_yacc.c" \
        "$ROOT_DIR/util/alloc.c" \
        "$ROOT_DIR/util/panic.c" \
        -o "$UTIL_WASM_DIR/dgn_comp.js"
else
    echo "  dgn_comp already built."
fi

if [ ! -f "$UTIL_WASM_DIR/lev_comp.js" ]; then
    echo "  Building lev_comp..."
    emcc $UTIL_CFLAGS \
        "$ROOT_DIR/util/lev_comp.c" \
        "$ROOT_DIR/util/lev_lex.c" \
        "$ROOT_DIR/util/lev_main.c" \
        "$ROOT_DIR/util/alloc.c" \
        "$ROOT_DIR/util/panic.c" \
        "$ROOT_DIR/src/decl.c" \
        "$ROOT_DIR/src/drawing.c" \
        "$ROOT_DIR/src/monst.c" \
        "$ROOT_DIR/src/objects.c" \
        -o "$UTIL_WASM_DIR/lev_comp.js"
else
    echo "  lev_comp already built."
fi

if [ ! -f "$UTIL_WASM_DIR/dlb.js" ]; then
    echo "  Building dlb..."
    emcc $UTIL_CFLAGS -DDLB \
        "$ROOT_DIR/util/dlb_main.c" \
        "$ROOT_DIR/src/dlb.c" \
        "$ROOT_DIR/util/alloc.c" \
        "$ROOT_DIR/util/panic.c" \
        -o "$UTIL_WASM_DIR/dlb.js"
else
    echo "  dlb already built."
fi
echo "  WASM utilities ready."
echo ""

# Rebuild data files with WASM utilities for correct struct alignment
# (unsigned long is 8 bytes on ARM64 but 4 bytes on WASM32)
echo "Step 6: Rebuilding data files for WASM..."
NHDATA_DIR="$BUILD_DIR/nhdata"
rm -rf "$NHDATA_DIR"
cp -R "$NATIVE_DATADIR" "$NHDATA_DIR"

cd "$ROOT_DIR/dat"

# Rebuild dungeon data
echo "  Rebuilding dungeon..."
node "$UTIL_WASM_DIR/dgn_comp.js" dungeon.pdf

# Rebuild all level files
echo "  Rebuilding levels..."
for des in bigroom.des castle.des endgame.des gehennom.des knox.des medusa.des \
           mines.des oracle.des sokoban.des tower.des yendor.des \
           Arch.des Barb.des Caveman.des Healer.des Knight.des Monk.des \
           Priest.des Ranger.des Rogue.des Samurai.des Tourist.des \
           Valkyrie.des Wizard.des; do
    node "$UTIL_WASM_DIR/lev_comp.js" "$des"
done

# Rebuild nhdat archive
echo "  Rebuilding nhdat archive..."
LC_ALL=C node "$UTIL_WASM_DIR/dlb.js" cf nhdat \
    help hh cmdhelp keyhelp history opthelp wizhelp dungeon tribute \
    asmodeus.lev baalz.lev bigrm-*.lev castle.lev fakewiz?.lev \
    juiblex.lev knox.lev medusa-?.lev minend-?.lev minefill.lev \
    minetn-?.lev oracle.lev orcus.lev sanctum.lev soko?-?.lev \
    tower?.lev valley.lev wizard?.lev astral.lev air.lev earth.lev \
    fire.lev water.lev ???-goal.lev ???-fil?.lev ???-loca.lev \
    ???-strt.lev bogusmon data engrave epitaph oracles options quest.dat rumors

cp nhdat "$NHDATA_DIR/nhdat"
echo "  Data files rebuilt for WASM."
echo ""

cd "$BUILD_DIR"

# Build with Emscripten
echo "Step 7: Building with Emscripten..."
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
