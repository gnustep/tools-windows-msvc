
# GNUstep Windows MSVC Toolchain

[![CI](https://github.com/gnustep/tools-windows-msvc/actions/workflows/ci.yml/badge.svg)](https://github.com/gnustep/tools-windows-msvc/actions/workflows/ci.yml?query=branch%3Amaster)

This project comprises a collection of scripts to build a modern GNUstep toolchain, with support for blocks and Automatic Reference Counting (ARC), using LLVM/Clang and the Visual Studio toolchain. The toolchain can be used to integrate Objective-C code in any Windows app, including Visual Studio projects using LLVM/Clang (see below), without using MinGW.


## Libraries

The toolchain consists of the following libraries:

- [GNUstep Base Library](https://github.com/gnustep/libs-base) (Foundation)
- [GNUstep CoreBase Library](https://github.com/gnustep/libs-corebase) (CoreFoundation)
- [libobjc2](https://github.com/gnustep/libobjc2) (using gnustep-2.0 runtime)
- [libdispatch](https://github.com/apple/swift-corelibs-libdispatch) (official Apple release from the Swift Core Libraries)
- [libffi](https://github.com/libffi/libffi)
- [libiconv](https://github.com/kiyolee/libiconv-win-build)
- [libxml2](https://github.com/GNOME/libxml2)
- [libxslt](https://github.com/GNOME/libxslt)
- [libcurl](https://github.com/curl/curl)
- [ICU](https://docs.microsoft.com/en-us/windows/win32/intl/international-components-for-unicode--icu-) (using system-provided DLL on Windows 10 version 1903 or later)


## Installation

To install a pre-built release, download it from [the releases on GitHub](https://github.com/gnustep/tools-windows-msvc/releases) and unpack it into into `C:\GNUstep` (this location is only required if you plan on using the `gnustep-config` script, otherwise any location will work).

You should end up with the folders `C:\GNUstep\x64\Debug` and `C:\GNUstep\x64\Release` when using the x64 toolchain. The explanations below and the example project assume this installation location.


## Using the Toolchain from the Command Line

Building and linking Objective-C code using the toolchain and Clang requires a number of compiler and linker flags.

When building in a Bash environment (like an MSYS2 shell), the `gnustep-config` tool can be used to query the necessary flags for building and linking:

    # add gnustep-config directory to PATH (use Debug or Release version)
    export PATH="$PATH:/c/GNUstep/x64/Debug/bin/"
    
    # build test.m to produce an object file test.o
    clang `gnustep-config --objc-flags` -c test.m
    
    # link object file into executable
    clang `gnustep-config --base-libs` -ldispatch -o test.exe test.o

Alternatively, `clang-cl.exe` can be used to build Objective-C code directly in a Visual Studio environment like the "x64 Native Tools Command Prompt". Note that this requires prefixing some of the required compiler flags with `-Xclang` to pass them directly to Clang:

    # build test.m to produce an object file test.obj
    clang-cl -I C:\GNUstep\x64\Debug\include -fobjc-runtime=gnustep-2.0 -Xclang -fexceptions -Xclang -fobjc-exceptions -fblocks -DGNUSTEP -DGNUSTEP_WITH_DLL -DGNUSTEP_RUNTIME=1 -D_NONFRAGILE_ABI=1 -D_NATIVE_OBJC_EXCEPTIONS /MDd /c test.m
    
    # link object file into executable
    clang-cl test.obj gnustep-base.lib objc.lib dispatch.lib /MDd -o test.exe /link /LIBPATH:C:\GNUstep\x64\Debug\lib

Specify `/MDd` for debug builds, and `/MD` for release builds, in order to link against the same runtime libraries as the DLLs in `C:\GNUstep\x64\Debug` and `C:\GNUstep\x64\Release` respectively.

Note that the `GNUSTEP_WITH_DLL` definition is always required to enable annotation of the Objective-C objects defined in the GNUstep Base DLL with `__declspec(dllexport)`.


## Using the Toolchain in Visual Studio

The [examples/ObjCWin32](examples/ObjCWin32) folder contains a Visual Studio project that is set up with support for Objective-C.

Following are instructions to set up your own project, or add Objective-C support to an existing Win32 Visual Studio project.

### Create the Project

Launch Visual Studio, select "Create a new project", and select a project template that is compatible with C++/Win32, e.g. Console App, Windows Desktop Application, Static Library, Dynamic-Link Library (DLL). In the following we assume we are building a Console App.

Choose a name for the project and create the project. In this example, we choose ObjCHello.

### Edit the Project

#### Edit Project Properties

1. Right-click the project in Solution Explorer and select "Properties".
2. In "General" change "Platform Toolset" to "LLVM (clang-cl)". MSVC does not support compiling Objective-C source files.
3. In "VC++ Directories" add the following for toolchain headers and libraries to be found: 
    * Include Directories: `C:\GNUstep\$(LibrariesArchitecture)\$(Configuration)\include`
    * Library Directories: `C:\GNUstep\$(LibrariesArchitecture)\$(Configuration)\lib`
4. Set required preprocessor definitions in C/C++ > Preprocessor > Preprocessor Definitions:  
  `GNUSTEP;GNUSTEP_WITH_DLL;GNUSTEP_RUNTIME=1;_NONFRAGILE_ABI=1;_NATIVE_OBJC_EXCEPTIONS`
5. Add required compiler options in C/C++ > Command Line > Additional Options:  
  `-fobjc-runtime=gnustep-2.0 -Xclang -fexceptions -Xclang -fobjc-exceptions -fblocks -Xclang -fobjc-arc`  
  Remove the last two options (`-Xclang -fobjc-arc`) if you don't want to use Automatic Reference Counting (ARC).
6. Link required libraries in Linker > Input > Additional Dependencies:  
  `gnustep-base.lib;objc.lib;dispatch.lib`

#### Edit Project File

1. Right-click the project in Solution Explorer and select "Unload Project".
2. Double-click on the project again and to open the raw vcxproj file.
3. Above the last line `</Project>` add the following to copy the GNUstep DLLs to the output directory.
   ```
   <ItemGroup>
     <Content Include="C:\GNUstep\$(LibrariesArchitecture)\$(Configuration)\bin\*.dll">
       <CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>
       <TargetPath>%(Filename)%(Extension)</TargetPath>
     </Content>
   </ItemGroup>
   ```
4. Right click the project in Solution Explorer and select "Reload Project".

#### Edit Source File Properties

1. Right-click on the `ObjCHello.cpp` source file and rename it to `ObjCHello.m` (or `ObjCHello.mm` for Objective-C++).
2. Right-click on each Objective-C(++) file in the project and select "Properties".
3. In C/C++ > Advanced, clear the "Compile As" option.  
This means the file will be built as Objective-C(++) based on the file extension (by not setting `/TC`/`/TP` flags that otherwise cause the file to be built as C/C++ irrespective of its extension).

### Add Objective-C Code and Run

Now you can start writing your Objective-C code in the `ObjCHello.m` file. You can test the setup by replacing the content of the file with:

```objective-c
#include <Foundation/Foundation.h>

int main(int argc, char *argv[])
{
    NSLog(@"Hello Objective-C");
    return 0;
}
```

Place a breakpoint at the line `NSLog(@"Hello Objective-C");` and run from Visual Studio. You should see the breakpoint getting hit, and the log printed in the "Output" panel when you continue.


## Status and Known Issues

* The toolchain supports x64 only (due to a [build error](https://bugs.swift.org/browse/SR-14314) in libdispatch on x86).

* LLVM/Clang has the following known issues with Objective-C code on Windows. For the time being, it is recommended to use Clang 13 (e.g. from Visual Studio 2019), until Clang 16 has been released which fixes most of them.
  - Using `@finally` crashing Clang ([issue](https://github.com/llvm/llvm-project/issues/43828), [issue](https://github.com/llvm/llvm-project/issues/51899))
  - Exception handling with ARC causing access violation ([issue](https://github.com/gnustep/libobjc2/issues/222), fixed in Clang 15)
  - Certain Objective-C++ code crashing Clang ([issue](https://github.com/llvm/llvm-project/issues/54556), affects Clang 14, fixed in Clang 15)
  - Objective-C class methods not working with ARC ([issue](https://github.com/llvm/llvm-project/issues/56952), affects Clang 14, fixed in Clang 16)

* The compilation will fail if the Windows home folder contains whitespace, e.g. `C:\Users\John Appleseed`.

* When utilizing the built-in gnustep-make test suite's debug capabilities, the preferred debugger on Windows is lldb. lldb (from the Chocolatey package manager) links to `python310.dll`, but is not found if Python 3.10.x is not installed and added to PATH. The error message is obscure and doesn't mention the missing dependency. Install Python3 manually using the official Python Installer. After downloading and executing the installer, select `Add to PATH` and proceed with the installation. You can now use the lldb debugger.


## Troubleshooting

### Compile Errors

* `'Foundation/Foundation.h' file not found`  
Please ensure that you correctly set "Include Directories".

* `#import of type library is an unsupported Microsoft feature`  
Please ensure that you have cleared the "Compile As" property of the file.

### Link Errors

* `cannot open input file 'gnustep-base.lib'`  
Please ensure that you correctly set "Library Directories".

* `unresolved external symbol __objc_load referenced in function .objcv2_load_function`  
Please ensure that you added the required linking options in Linker > Input > Additional Dependencies.

* `relocation against symbol in discarded section: __start_.objcrt$SEL`  
Please ensure that you include some Objective-C code in your project. (This is currently required due to a [compiler/linker issue](https://github.com/llvm/llvm-project/issues/49025) when using the LLD linker. Alternatively you can use link.exe instead of LLD.)

### Runtime Errors

* `The code execution cannot proceed because gnustep-base-1_28.dll was not found. Reinstalling the program may fix this problem.`  
Please ensure that DLLs are copied to the output folder.

* Objective-C categories are not found at runtime
Linking static libraries containing Objective-C categories into an executable or shared library will strip the categories during the linking process. This can be worked around by linking with the [`WHOLEARCHIVE`](https://learn.microsoft.com/en-us/cpp/build/reference/wholearchive-include-all-library-object-files) linker option (e.g. `/WHOLEARCHIVE:MyStaticLibrary.lib`), or by directly linking the object files from the library (e.g. by using "[object libraries](https://cmake.org/cmake/help/latest/command/add_library.html#object-libraries)" when using CMake).


## Building the Toolchain

### Prerequisites

Building the toolchain require the following tools to be installed and available in the PATH. Their presence is verified when building the toolchain.

The MSYS2 installation is required to provide the Bash shell and Unix tools required to build some of the libraries, but no MinGW packages are needed. The Windows Clang installation is used to build all libraries.

**Windows tools**

- Visual Studio 2019
- Clang (via Visual Studio or `choco install llvm`)
- CMake (via Visual Studio or `choco install cmake --installargs 'ADD_CMAKE_TO_PATH=System'`)
- Git (`choco install git`)
- Ninja (`choco install ninja`)
- MSYS2 (`choco install msys2`)
- NASM (`choco install nasm`)

**Unix tools**

- Make
- Autoconf/Automake
- libtool
- pkg-config

These can be installed via Pacman inside a MSYS2 shell:  
`pacman -S --needed make autoconf automake libtool pkg-config`

Please make sure that you do _not_ have `gmake` installed in your MSYS2 environment, as it is not compatible but will be picked up by the project Makefiles. Running `which gmake` in MSYS2 should print "which: no gmake in ...".


### Building

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
