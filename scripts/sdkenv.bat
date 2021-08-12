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

:: determine compile flags
set ARCH=%VSCMD_ARG_TGT_ARCH%
set CFLAGS=
set CXXFLAGS=
set LDFLAGS=-fuse-ld=lld

:: determine target triple
if "%ARCH%" == "x86" (
  set TARGET=i686-pc-windows
) else if "%ARCH%" == "x64" (
  set TARGET=x86_64-pc-windows
) else (
  echo Unknown target architecture: %ARCH%
  exit /b 1
)

:: Common CMake options
set CMAKE_ARCH=%ARCH%
if "%ARCH%" == "x86" set CMAKE_ARCH=Win32
set CMAKE_BUILD_TYPE=%BUILD_TYPE%
if "%BUILD_TYPE%" == "Release" set CMAKE_BUILD_TYPE=RelWithDebInfo
set CMAKE_OPTIONS=-T ClangCL -A %CMAKE_ARCH% -DCMAKE_INSTALL_PREFIX="%INSTALL_PREFIX%"
set CMAKE_BUILD_OPTIONS=--build . --config %CMAKE_BUILD_TYPE% -- -m
set CMAKE_INSTALL_OPTIONS=--build . --config %CMAKE_BUILD_TYPE% --target install
