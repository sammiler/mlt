# MLT vcpkg Port - MSVC Compatibility Fix

This is a vcpkg port for MLT (Multimedia Framework) version 7.33.0 that supports MSVC compilation with fixes for glaxnimate module compatibility.

## Fixed Issues

### CosToken Constructor Issue

The main issue was in the `glaxnimate/src/core/io/aep/cos.hpp` file where the `CosToken` class was using C++11 brace initialization syntax that wasn't compatible with MSVC's strict interpretation of constructor requirements.

**Problem**: The code was using `return {TokenType};` and `return {TokenType, value};` syntax, but the `CosToken` class only had default, copy, and move constructors.

**Solution**: Added explicit constructors to handle different parameter combinations:
- `explicit CosToken(CosTokenType type)` - for single token type
- `CosToken(CosTokenType type, double value)` - for numeric tokens
- `CosToken(CosTokenType type, bool value)` - for boolean tokens  
- `CosToken(CosTokenType type, const QString& value)` - for string tokens
- `CosToken(CosTokenType type, const QByteArray& value)` - for byte array tokens

All `return {...};` statements were replaced with explicit `return CosToken(...);` calls.

## Requirements

- **Windows only**: This port is specifically designed for MSVC on Windows
- **Git**: Required for submodule initialization
- **vcpkg**: Latest version recommended
- **C++20**: Standard requirement

## Installation

1. Copy the entire `port` directory to your vcpkg `ports` directory as `mlt`:
   ```
   cp -r port/ <vcpkg-root>/ports/mlt/
   ```

2. Install the package (default includes all standard features):
   ```
   vcpkg install mlt:x64-windows
   ```

## Dependencies

The following packages are automatically installed as core dependencies:
- `libxml2` - XML processing
- `dlfcn-win32` - Dynamic loading on Windows  
- `libiconv` - Character encoding conversion
- `pkgconf` - Package configuration
- `gettimeofday` - Time functions for Windows
- `pthreads` - POSIX threads for Windows

## Features

The port supports many optional features corresponding to CMake modules:

### Default Features (automatically enabled):
- `core`: Core MLT framework
- `avformat`: FFmpeg audio/video processing
- `decklink`: Blackmagic DeckLink support
- `frei0r`: Video effects library
- `gdk`: Image and text processing
- `jackrack`: JACK audio processing
- `kdenlive`: Kdenlive effects
- `normalize`: Audio normalization (GPL)
- `oldfilm`: Old film effects
- `plus`: Additional effects and filters
- `plusgpl`: Additional GPL effects
- `qt6`: Qt6 GUI components (GPL)
- `resample`: Audio resampling (GPL)
- `rtaudio`: Real-time audio I/O
- `rubberband`: Audio time-stretching (GPL)
- `sdl2`: SDL2 audio/video output
- `vidstab`: Video stabilization (GPL)
- `vorbis`: Ogg Vorbis audio support
- `xine`: XINE multimedia (GPL)
- `xml`: XML module

### Optional Features (disabled by default):
- `sox`: SoX audio processing
- `movit`: GPU-accelerated video processing
- `opencv`: Computer vision features
- `qt5`: Qt5 GUI components (legacy)
- `sdl1`: SDL1 support (legacy)
- `ndi`: NDI video over IP
- `spatialaudio`: Spatial audio processing
- `glaxnimate`: Glaxnimate animation support

### Installation Examples:

```bash
# Default installation (includes all standard features)
vcpkg install mlt:x64-windows

# Minimal installation (core only)
vcpkg install mlt[core]:x64-windows

# Custom installation with specific features
vcpkg install mlt[core,qt6,avformat,sdl2]:x64-windows

# Add optional features
vcpkg install mlt[sox,movit,opencv]:x64-windows
```

## Source Repository

This port pulls from: https://github.com/sammiler/mlt (msvc-master branch)

## Directory Structure

After installation, the package will be organized as:

```
<vcpkg-root>/installed/x64-windows/
├── bin/
│   ├── mlt-7.dll                    # Core MLT library
│   ├── mlt++-7.dll                  # MLT C++ wrapper
│   └── *.dll                        # Other dependencies
├── include/
│   └── mlt-7/
│       ├── framework/               # MLT C API headers
│       │   ├── mlt.h
│       │   ├── mlt_*.h
│       │   └── ...
│       └── mlt++/                   # MLT C++ API headers
│           ├── Mlt.h
│           ├── Mlt*.h
│           └── ...
├── lib/
│   ├── mlt-7.lib                    # Import library for mlt-7.dll
│   ├── mlt++-7.lib                  # Import library for mlt++-7.dll
│   ├── mlt/                         # MLT modules/plugins
│   │   ├── mltcore.dll
│   │   ├── mltavformat.dll          # If ffmpeg feature enabled
│   │   ├── mltqt6.dll               # If qt6 feature enabled
│   │   └── ...
│   ├── cmake/
│   │   └── Mlt7/                    # CMake configuration files
│   │       ├── Mlt7Config.cmake
│   │       ├── Mlt7ConfigVersion.cmake
│   │       └── Mlt7Targets.cmake
│   └── pkgconfig/                   # pkg-config files
│       ├── mlt-framework-7.pc
│       └── mlt++-7.pc
├── share/
│   └── mlt/                         # MLT data files (profiles, presets, etc.)
│       ├── profiles/
│       ├── presets/
│       └── ...
└── tools/
    └── mlt/
        └── melt.exe                 # MLT command-line tool
```

## Usage in CMake

```cmake
find_package(Mlt7 REQUIRED)
target_link_libraries(your_target PRIVATE Mlt7::mlt Mlt7::mlt++)
```

## Notes

- This is a Windows/MSVC-specific port
- The port builds both debug and release configurations
- MLT modules are installed as separate DLL files in the `lib/mlt/` directory
- All debug symbols (.pdb files) are preserved in debug builds but removed from release builds

## Testing

After copying to vcpkg/ports/mlt/, test the port:

```bash
vcpkg install mlt:x64-windows --editable
```

If there are issues, check the build logs and update the SHA512 hash in `portfile.cmake` after the first run.


## Full Features

vcpkg install mlt[core,avformat,decklink,frei0r,gdk,jackrack,kdenlive,normalize,oldfilm,plus,plusgpl,qt6,resample,rtaudio,rubberband,sdl2,vidstab,vorbis,xine,xml,opencv,glaxnimate-qt6]