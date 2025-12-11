# ghostscript-wasm

Ghostscript compiled to WebAssembly — runs in Node.js and Browsers.

Ghostscript-WASM allows you to render PS/EPS/PDF files entirely in WebAssembly with no native dependencies.

Built and tested from Ghostscript 10.07.0

## Building

These build tools are required:
* Emscripten ≥ 3.1.50
```
git clone https://github.com/emscripten-core/emsdk.git
cd emsdk
./emsdk install latest
./emsdk activate latest
source emsdk_env.sh
```
* wasm-opt (Binaryen)
```
brew install binaryen

// or

apt install binaryen
```

* Node.js ≥ 16

### Process

```
bash build-gs-wasm.sh
```

Output files will appear in:

```
dist/gs.js
dist/gs.wasm
```

Run test

```
npm install

// Node 
npm test

// Browser
npx http-server .
http://localhost:8080/tests/browser.html
 
```

## Credits

Ghostscript © Artifex Software
