@echo off
setlocal EnableDelayedExpansion

setlocal
IF "%selfWrapped%"=="" (
  REM this is necessary so that we can use "exit" to terminate the batch file,
  REM and all subroutines, but not the original cmd.exe
  REM https://superuser.com/a/203672
  set selfWrapped=true
  %ComSpec% /s /c ""%~0" %*"
  goto :eof
)
endlocal

:: Reset environment
call RefreshEnv.cmd >nul

:: Variables

pushd %~dp0
set ROOT_DIR=%CD%
popd

set ARCHITECTURES=(x86 x64)
set SRCROOT=%ROOT_DIR%\src
set INSTALL_ROOT=C:\GNUstep
set BASH=msys2_shell -defterm -no-start -msys2 -full-path -here -c

:: Check if all required commands are installed
where /Q git
if %errorlevel% neq 0 call :error_missing_command git
where /Q cmake
if %errorlevel% neq 0 call :error_missing_command cmake, "choco install cmake --installargs 'ADD_CMAKE_TO_PATH=System'"
where /Q ninja
if %errorlevel% neq 0 call :error_missing_command ninja
where /Q clang-cl
if %errorlevel% neq 0 call :error_missing_command clang-cl, "choco install llvm"
where /Q msys2_shell
if %errorlevel% neq 0 call :error_missing_command MSYS2, "choco install msys2"
call %BASH% 'which make >/dev/null 2>/dev/null'
if %errorlevel% neq 0 call :error_missing_command make, "pacman -S make"

if not exist "%SRCROOT%" (mkdir "%SRCROOT%")
if not exist "%INSTALL_ROOT%" (mkdir "%INSTALL_ROOT%")

for /f "usebackq delims=" %%i in (`call %BASH% 'cygpath -u "%ROOT_DIR%"'`) do (
  set UNIX_ROOT_DIR=%%i
)

:: Run phases

for %%G in %ARCHITECTURES% do (
  set ARCH=%%G
  call :buildarch
  
  :: Reset environment so we can call vcvarsall.bat multiple times
  call RefreshEnv.cmd >nul
)

goto :eof

:buildarch
  echo.
  echo ######## BUILDING FOR %ARCH% ########
  echo.
  
  set INSTALL_PREFIX=%INSTALL_ROOT%\%ARCH%
  
  for /f "usebackq delims=" %%i in (`call %BASH% 'cygpath -u "%INSTALL_PREFIX%"'`) do (
    set UNIX_INSTALL_PREFIX=%%i
  )
  
  call :vsdevcmd || (echo Failed && exit 1)

  for %%f in (%ROOT_DIR%\phases\*.bat) do (
    echo.
    echo ###### %%~nf ######
    echo.

    REM if "%%~nf" == "30-gnustep-base" (
      call %%f || (echo Failed && exit 1)
    REM )
  )
  
  goto :eof

:vsdevcmd
  :: https://github.com/microsoft/vswhere/wiki/Start-Developer-Command-Prompt
  for /f "usebackq delims=" %%i in (`"%ROOT_DIR%\vswhere.exe" -latest -property installationPath`) do (
    :: This assumes we are on a Windows x64 installation
    if "%ARCH%" == "x86" (
      call "%%i\VC\Auxiliary\Build\vcvarsall.bat" x64_x86 || exit 1
      set TARGET=x86-pc-windows
      set CFLAGS=-m32
      set CXXFLAGS=-m32
      set LDFLAGS=-fuse-ld=lld -m32
    ) else if "%ARCH%" == "x64" (
      call "%%i\VC\Auxiliary\Build\vcvarsall.bat" x64 || exit 1
      set TARGET=x86_64-pc-windows
      set CFLAGS=
      set CXXFLAGS=
      set LDFLAGS=-fuse-ld=lld
    ) else (
      echo Unknown ARCH: %ARCH%
      exit /b 1
    )
    goto :eof
  )
  :: Instance or command prompt not found
  exit /b 2

:error_missing_command
  if [%2] == [] (set install_cmd="choco install %1") else (set install_cmd=%2)
  if not x%install_cmd:pacman=% == x%install_cmd% (set "install_hint= in MSYS2")
  echo Error: %1 not found. Please install via %install_cmd%%install_hint%.
  exit 1
