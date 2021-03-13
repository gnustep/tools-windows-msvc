
GNUstep Windows MSVC Toolchain
==============================

This project comprises a collection of scripts to build a modern GNUstep toolchain (with support for blocks and ARC) for the Windows MSVC ABI. The toolchain can then be used to integrate Objective-C code in any Windows app (without using MinGW).

Libraries
---------

The toolchain currently consists of the following libraries:

- [GNUstep Base Library](https://github.com/gnustep/libs-base) (Foundation)
- [libobjc2](https://github.com/gnustep/libobjc2) (using gnustep-2.0 runtime)
- [libdispatch](https://github.com/apple/swift-corelibs-libdispatch) (official Apple release from the Swift Core Libraries)
- [libffi](https://github.com/libffi/libffi)
- [Pthreads-win32](http://www.sourceware.org/pthreads-win32/)

Prerequisites for Building
--------------------------

Building the toolchain require the following tools to be installed and available in the PATH. Their presence is verified when building the toolchain.

The MSYS2 installation is required to provide the Bash shell and Unix tools required to build some of the libraries, but no MinGW packages are needed. The Windows Clang installation is used to build all libraries.

**Windows tools**

- Git (`choco install git`)
- CMake (`choco install cmake --installargs 'ADD_CMAKE_TO_PATH=System'`)
- Ninja (`choco install ninja`)
- Clang (`choco install llvm`)
- MSYS2 (`choco install msys2`)

**Unix tools**

- Make
- Autoconf/Automake
- libtool

These can be installed via Pacman inside a MSYS2 shell:  
`pacman -S --needed make autoconf automake libtool`

Building
--------

Run the [build.bat](build.bat) script from a Command Prompt (cmd) to build the toolchain.

For each of the libraries, the script automatically downloads the source via Git into the `src` subdirectory, and then builds and installs it.

The toolchain is installed into `C:\GNUstep\[x64|x86]\[Debug|Release]`.

Status
------

The scripts currently provide at least the minimum set of libraries needed to build GNUstep Base. Some GNUstep functionality might not be available due to missing dependencies. Also, as support for using GNUstep with the MSVC ABI has only been recently added, and Windows support in GNUstep is generally not as complete as on Unixes, many tests are still failing for various reasons. Following is a list of some of the open items.

- [ ] Add support for x86 (currently blocked by [libdispatch build issue](https://bugs.swift.org/browse/SR-14314))
- [ ] Add missing dependencies:
  - [ ] libiconv
  - [ ] ICU
  - [ ] libxml2
  - [ ] libxslt
- [ ] Build Pthreads-win32 from source (to match CRT version, or update GNUstep to use Windows threading APIs directly)
- [ ] Add parameters to build script e.g. for changing install prefix
- [ ] Fix tests in GNUstep Base
- [ ] Add CI and provide pre-built binaries
