
GNUstep Windows MSVC Toolchain
==============================

[![CI](https://github.com/gnustep/tools-windows-msvc/actions/workflows/ci.yml/badge.svg)](https://github.com/gnustep/tools-windows-msvc/actions/workflows/ci.yml?query=branch%3Amaster)

This project comprises a collection of scripts to build a modern GNUstep toolchain, with support for blocks and Automatic Reference Counting (ARC), using Clang and the Visual Studio toolchain with the MSVC ABI. The toolchain can then be used to integrate Objective-C code in any Windows app, without using MinGW.

Libraries
---------
The toolchain currently consists of the following libraries:

- [GNUstep Base Library](https://github.com/gnustep/libs-base) (Foundation)
- [GNUstep CoreBase Library](https://github.com/gnustep/libs-corebase) (CoreFoundation)
- [libobjc2](https://github.com/gnustep/libobjc2) (using gnustep-2.0 runtime)
- [libdispatch](https://github.com/apple/swift-corelibs-libdispatch) (official Apple release from the Swift Core Libraries)
- [libffi](https://github.com/libffi/libffi)
- [libiconv](https://github.com/kiyolee/libiconv-win-build)
- [libxml2](https://github.com/GNOME/libxml2)
- [libxslt](https://github.com/GNOME/libxslt)
- [ICU](https://docs.microsoft.com/en-us/windows/win32/intl/international-components-for-unicode--icu-) (using system-provided DLL on Windows 10 version 1903 or later)

Prerequisites for Building
--------------------------
Building the toolchain require the following tools to be installed and available in the PATH. Their presence is verified when building the toolchain.

The MSYS2 installation is required to provide the Bash shell and Unix tools required to build some of the libraries, but no MinGW packages are needed. The Windows Clang installation is used to build all libraries.

**Windows tools**

- Visual Studio 2019
- Clang (via Visual Studio or `choco install llvm`)
- CMake (via Visual Studio or `choco install cmake --installargs 'ADD_CMAKE_TO_PATH=System'`)
- Git (`choco install git`)
- Ninja (`choco install ninja`)
- MSYS2 (`choco install msys2`)

**Unix tools**

- Make
- Autoconf/Automake
- libtool
- pkg-config

These can be installed via Pacman inside a MSYS2 shell:  
`pacman -S --needed make autoconf automake libtool pkg-config`

Building the Toolchain
----------------------
Run the [build.bat](build.bat) script in either a x86 or x64 Native Tools Command Prompt from Visual Studio to build the toolchain for x86 or x64.

```
Usage: build.bat
  --prefix INSTALL_ROOT    Install toolchain into given directory (default: C:\GNUstep)
  --type Debug/Release     Build only the given build type (default: both)
  --only PHASE             Re-build only the given phase (e.g. "gnustep-base")
  --only-dependencies      Build only GNUstep dependencies
  --patches DIR            Apply additional patches from given directory
  -h, --help, /?           Print usage information and exit
```

For each of the libraries, the script automatically downloads the source via Git into the `src` subdirectory, builds, and installs it.

The toolchain is installed into `C:\GNUstep\[x86|x64]\[Debug|Release]`.

Using the Toolchain
-------------------
Building and linking Objective-C code using the toolchain requires a number of compiler and linker flags.

When building in a Bash environment (like an MSYS2 shell), the `gnustep-config` tool can be used to query the necessary flags for building and linking:

    # add gnustep-config directory to PATH (use Debug or Release version)
    export PATH="$PATH:/c/GNUstep/x64/Debug/bin/"
    
    # build test.m to produce an object file test.o
    clang `gnustep-config --objc-flags` -c test.m
    
    # link object file into executable
    clang `gnustep-config --base-libs` -ldispatch -o test.exe test.o

The  `clang-cl` driver can also be used to build Objective-C code, but requires prefixing some of the options using the `-Xclang` modifier to pass them directly to Clang:

    # build test.m to produce an object file test.obj
    clang-cl -I C:\GNUstep\x64\Debug\include -fobjc-runtime=gnustep-2.0 -Xclang -fexceptions -Xclang -fobjc-exceptions -fblocks -DGNUSTEP -DGNUSTEP_WITH_DLL -DGNUSTEP_RUNTIME=1 -D_NONFRAGILE_ABI=1 -D_NATIVE_OBJC_EXCEPTIONS -DGSWARN -DGSDIAGNOSE /MDd /c test.m
    
    # link object file into executable
    clang-cl test.obj gnustep-base.lib objc.lib dispatch.lib /MDd -o test.exe

Specify `/MDd` for debug builds, and `/MD` for release builds, in order to link against the same run-time libraries as the DLLs in `C:\GNUstep\x64\Debug` and `C:\GNUstep\x64\Release` respectively.

Note that the `GNUSTEP_WITH_DLL` definition is always required to enable annotation of the Objective-C objects defined in the GNUstep Base DLL with `__declspec(dllexport)`.

Status
------
As support for using GNUstep with the MSVC ABI has only been recently added, and GNUstep support for Windows might not be as complete as on Unixes, many tests are still failing for various reasons.

Following is a list of some of the open items.

- [ ] Add support for building libdispatch for x86 (currently blocked by [libdispatch build issue](https://bugs.swift.org/browse/SR-14314))
- [ ] Figure out building Objective-C code in Visual Studio
- [ ] Fix tests in GNUstep Base
- [ ] Provide pre-built binaries
