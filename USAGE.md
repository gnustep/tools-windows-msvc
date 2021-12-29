### Prerequisite

1. [Microsoft Visual Studio 2019 or later](https://visualstudio.microsoft.com/downloads/) (You should install **Desktop development with C++** in workload and  **C++ Clang Compiler for Windows**, **C++ Clang-cl for build tools (x64/x86)** in Invidual components)
2. [GNUstep Windows MSVC Toolchain](https://github.com/gnustep/tools-windows-msvc/releases)

### Preparation

#### Install GNUstep Windows MSVC Toolchain

Extract the toolchain from the .zip file you downloaded. It is recommended you extract the `GNUstep` folder to `C:\` so the toolchain will be organized like `C:\GNUstep\x86[x64]\Debug[Release]`. You can use a different path, but note that some configuration files have the path hardcoded.

To go from here, we assume we are building an x64 app/dll and we are using `C:\GNUstep\x64\Debug` as the toolchain root.

### Create Project

Launch Visual Studio, select "Create a new project". There are many projects to choose from, ensure that you choose one that is compatible with C++/Win32. For example: Console App, Windows Desktop Application, Static Library, Dynamic-Link Library (DLL).

To go from here, we assume we are building a Console App.

We choose a name for the project and create the project. In this example, we choose ObjCHello.

When the project is created, change current configuration to Debug, x64.

### Edit Project

#### Edit Project Properties

1. Right click on the ObjCHello project in Solution Explorer, and select Properties.

2. In General, change Platform Toolset to LLVM (clang-cl). MSVC does not support compiling Objective-C source files.
3. In VC++ Directories, add `C:\GNUstep\x64\Debug\include` to Include Directories, and `C:\GNUstep\x64\Debug\lib` to Library Directories. To ensure toolchain headers and libraries can be correctly found.
4. In C/C++ -> Preprocessor, add the followings to Preprocessor Definitions.

```
GNUSTEP
GNUSTEP_WITH_DLL
GNUSTEP_RUNTIME=1
_NONFRAGILE_ABI=1
_NATIVE_OBJC_EXCEPTIONS
GSWARN
GSDIAGNOSE
```

5. In C/C++ -> Command Line, add `-fobjc-runtime=gnustep-2.0 -Xclang -fexceptions -Xclang -fobjc-exceptions -fblocks -Xclang -fobjc-arc ` to Additional Options. It does not have to be perfect match, if you do not use ARC, you can pass `-fno-objc-arc` instead.
6. In Linker -> Input, add the library you need to Additional Dependencies, for example

```
gnustep-base.lib
objc.lib
dispatch.lib
```

#### Edit Project File

1. Right click on the ObjCHello project in Solution Explorer, and select Unload Project.

2. Double click on the project again and it should present you the raw vcxproj file.

3. Under this line `<Import Project="$(VCTargetsPath)\Microsoft.Cpp.props" />`, add the following lines to tell MSBuild to use MSVC Linker (link.exe) instead of LLVM Linker (lld-link.exe) because lld-link.exe will throw error.

   ```
   <PropertyGroup>
     <LinkToolExe>link.exe</LinkToolExe>
   </PropertyGroup>
   ```

4. Above the closing line of `</Project>` add the following lines to copy GNUstep DLLs to output directory.

   ```
   <ItemGroup>
     <Content Include="C:\GNUstep\x64\Debug\bin\*.dll">
       <CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>
       <TargetPath>%(Filename)%(Extension)</TargetPath>
     </Content>
   </ItemGroup>
   ```

5. Right click on the ObjCHello project in Solution Explorer, and select Reload Project.

#### Edit File Properties

1. Right click on the `ObjCHello.cpp` that the project comes with and rename it to `ObjCHello.m`. (Or `ObjCHello.mm` in Objective-C++).
2. Right click on the `ObjCHello.m` file and select Properties.
3. In C/C++ -> Advanced, clear the Compile As. This tells MSBuild to not set /TP or /TC flags when compiling the file.

### Write Code and Run

Now you can start writing your Objective-C code in the `ObjCHello.m` file. You can test the setup by replacing the content of the file with

```objective-c
#include <Foundation/Foundation.h>

int main(int argc, char *argv[])
{
    NSLog(@"Hello Objective-C");
    return 0;
}
```

Placing a breakpoint at line `NSLog(@"Hello Objective-C");` and run from Visual Studio, you should be seeing the breakpoint getting hit.

### Troubleshooeting

#### Compile Error

1. `'Foundation/Foundatiosn.h' file not found`

Please ensure that you correctly set Include Directories.

2. `#import of type library is an unsupported Microsoft feature`

Please ensure that you have cleared the Compile As property of the file.

#### Link Error

1. `cannot open input file 'gnustep-base.lib'`

Please ensure that you correctly set Library Directories.

2. ` unresolved external symbol __objc_load referenced in function .objcv2_load_function`

Please ensure that you correctly set Linker -> Input.

3. `relocation against symbol in discarded section: __start_.objcrt$SEL`

Please ensure that you have changed the linker to link.exe.

#### Runtime Error

`The code execution cannot proceed because gnustep-base-1_28.dll was not found. Reinstalling the program may fix this problem.`

Please ensure that DLLs are copied to the output folder.



