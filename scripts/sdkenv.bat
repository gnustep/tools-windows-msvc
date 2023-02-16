@echo off

pushd %~dp0\..
set ROOT_DIR=%CD%
popd

:: ensure we're running from a developer command prompt
if  "%VSCMD_ARG_TGT_ARCH%" == "" (
  echo Error: missing developer environment.
  echo Please run from x64 or x86 Native Tools Command prompt for Visual Studio.
  exit 1
)

if not defined BUILD_TYPES set BUILD_TYPES=Debug Release
if not defined SRCROOT set SRCROOT=%ROOT_DIR%\src
if not defined CACHE_ROOT set CACHE_ROOT=%ROOT_DIR%\cache
if not defined INSTALL_ROOT set INSTALL_ROOT=C:\GNUstep

:: This is how we call into the MSYS2 shell. -full-path is needed so that
:: projects can find Clang installed in Windows-land, but note that this is
:: fragile as e.g. a Windows-installed "make" would be used instead of the one
:: installed in MSYS2. We could instead pass paths into MSYS2, but this doesn't
:: work because of spaces in Windows paths.
if not defined BASH set BASH=msys2_shell -defterm -no-start -msys2 -full-path -here -c

:: determine target triple
set ARCH=%VSCMD_ARG_TGT_ARCH%
if "%ARCH%" == "x86" (
  set TARGET=i686-pc-windows
  set MFLAG=-m32
) else if "%ARCH%" == "x64" (
  set TARGET=x86_64-pc-windows
  set MFLAG=-m64
) else (
  echo Unknown target architecture: %ARCH%
  exit /b 1
)

:: compiler flags: -m32/64 is required to ensure the right architecture is
:: built and linked. Unfortunately GNUstep Make ignores those, so we also set
:: them as part of the compiler.
if not defined CFLAGS set CFLAGS=%MFLAG%
if not defined CXXFLAGS set CXXFLAGS=%MFLAG%
if not defined OBJCFLAGS set OBJCFLAGS=%MFLAG%
if not defined OBJCXXFLAGS set OBJCXXFLAGS=%MFLAG%
if not defined ASMFLAGS set ASMFLAGS=%MFLAG%
if not defined CC set "CC=clang %MFLAG%"
if not defined CXX set "CXX=clang++ %MFLAG%"
if not defined OBJCC set "OBJCC=clang %MFLAG%"
if not defined OBJCXX set "OBJCXX=clang++ %MFLAG%"

:: LLD linker is required for linking Objective C
set LDFLAGS=-fuse-ld=lld

:: common CMake options
set CMAKE_BUILD_TYPE=%BUILD_TYPE%
if "%BUILD_TYPE%" == "Release" set CMAKE_BUILD_TYPE=RelWithDebInfo
set CMAKE_OPTIONS=^
  -G Ninja ^
  -D CMAKE_BUILD_TYPE=%CMAKE_BUILD_TYPE% ^
  -D CMAKE_INSTALL_PREFIX="%INSTALL_PREFIX%" ^
