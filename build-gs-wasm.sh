#!/bin/bash
set -euo pipefail

ROOT="$PWD"
SRC_DIR="$ROOT/src"
OUT_DIR="$ROOT/dist"

mkdir -p "$SRC_DIR" "$OUT_DIR"

#########################################
# 1. Clone Ghostscript master
#########################################
if [ ! -d "$SRC_DIR/ghostpdl" ]; then
    echo "Cloning Ghostscript master..."
    git clone --depth 1 https://github.com/ArtifexSoftware/ghostpdl.git "$SRC_DIR/ghostpdl"
fi

cd "$SRC_DIR/ghostpdl"

#########################################
# 2. Configure Ghostscript
#########################################
echo "Running autogen.sh (emscripten)..."

emconfigure ./autogen.sh \
    --host=wasm32-unknown-emscripten \
    --without-x \
    --disable-threading \
    --disable-cups \
    --disable-dbus \
    --disable-gtk \
    --with-arch_h="$ROOT/arch_wasm.h" \
    CCAUX=gcc


#########################################
# 3. Emscripten flags
#########################################
export GS_LDFLAGS="\
-lnodefs.js -lworkerfs.js \
--pre-js $ROOT/js/pre.js \
--post-js $ROOT/js/post.js \
--closure 1 \
-s EMULATE_FUNCTION_POINTER_CASTS=1 \
-s WASM_BIGINT=1 \
-s INITIAL_MEMORY=67108864 \
-s ALLOW_MEMORY_GROWTH=1 \
-s ENVIRONMENT='web,worker,node' \
-s EXPORTED_RUNTIME_METHODS='[\"callMain\",\"FS\",\"NODEFS\",\"WORKERFS\",\"ENV\",\"getValue\",\"setValue\"]' \
-s INCOMING_MODULE_JS_API='[\"noInitialRun\",\"noFSInit\",\"locateFile\",\"preRun\",\"instantiateWasm\"]' \
-s NO_DISABLE_EXCEPTION_CATCHING=1 \
-s BINARYEN_EXTRA_PASSES=\"--pass-arg=max-func-params@39\" \
-s MODULARIZE=1 \
"


#########################################
# 4. Build Ghostscript → WASM
#########################################
echo "Building Ghostscript → WASM..."

emmake make \
    XE=".js" \
    LDFLAGS="$GS_LDFLAGS" \
    -j$(nproc)

#########################################
# 5. Extract output
#########################################
echo "Copying output..."

cp -v ./bin/gs.js "$OUT_DIR"
cp -v ./bin/gs.wasm "$OUT_DIR"

if command -v wasm-opt >/dev/null; then
    echo "Optimizing WASM with wasm-opt..."
    wasm-opt "$OUT_DIR/gs.wasm" -Oz -o "$OUT_DIR/gs.wasm"
fi

echo
echo "===================================="
echo " DONE — Ghostscript WASM build ready"
echo " Files:"
echo "  → dist/gs.js"
echo "  → dist/gs.wasm"
echo "===================================="
