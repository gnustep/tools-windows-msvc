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

:: Load environment
call %~dp0\env\sdkenv.bat

:: set up Visual Studio developer environment for finding prerequisites below
set ARCH=x64
call :vsdevcmd || exit 1

:: Check if all required commands are installed
echo ### Checking prerequisites
where git
if %errorlevel% neq 0 call :error_missing_command git, "'choco install git'"
where cmake
if %errorlevel% neq 0 call :error_missing_command cmake, "Visual Studio or 'choco install cmake --installargs ADD_CMAKE_TO_PATH=System'"
where ninja
if %errorlevel% neq 0 call :error_missing_command ninja, "'choco install ninja'"
where clang-cl
if %errorlevel% neq 0 call :error_missing_command clang-cl, "Visual Studio or 'choco install llvm'"
call %BASH% 'true'
if %errorlevel% neq 0 call :error_missing_command MSYS2, "'choco install msys2'"
call %BASH% 'which make 2>/dev/null'
if %errorlevel% neq 0 call :error_missing_command make, "'pacman -S make' in MSYS2"
call %BASH% 'which autoconf 2>/dev/null'
if %errorlevel% neq 0 call :error_missing_command autoconf, "'pacman -S autoconf' in MSYS2"
call %BASH% 'which automake 2>/dev/null'
if %errorlevel% neq 0 call :error_missing_command automake, "'pacman -S automake' in MSYS2"
call %BASH% 'which libtool 2>/dev/null'
if %errorlevel% neq 0 call :error_missing_command libtool, "'pacman -S libtool' in MSYS2"

:: Create directories
if not exist "%SRCROOT%" (mkdir "%SRCROOT%")
if not exist "%INSTALL_ROOT%" (mkdir "%INSTALL_ROOT%")

:: Run phases
for %%G in (%ARCHITECTURES%) do (
  :: Reset environment so we can call vcvarsall.bat again
  call RefreshEnv.cmd >nul
  
  set ARCH=%%G
  call :buildarch
)

echo.
echo ### Finished building GNUstep into:
echo ### %INSTALL_ROOT%

goto :eof

:buildarch
  :: set up Visual Studio developer environment
  call :vsdevcmd || exit 1
  
  :: build DebuG/Release
  for %%G in (%BUILD_TYPES%) do (
    set BUILD_TYPE=%%G
    call :build
  )
  goto :eof

:build
  echo.
  echo ######## BUILDING FOR %ARCH% %BUILD_TYPE% ########
  
  set INSTALL_PREFIX=%INSTALL_ROOT%\%ARCH%\%BUILD_TYPE%
  
  for /f "usebackq delims=" %%i in (`call %BASH% 'cygpath -u "%INSTALL_PREFIX%"'`) do (
    set UNIX_INSTALL_PREFIX=%%i
  )

  for %%f in (%ROOT_DIR%\phases\??-*.*) do (
    echo.
    echo ###### %%~nf ######
    
    if %%~xf == .bat (
      call %%f || (echo Failed && exit 1)
    ) else if %%~xf == .sh (
      call %BASH% '`cygpath -u "%%f"`' || (echo Failed && exit 1)
    ) else (
      echo Error invalid phase: %%f && exit 1
    )
  )
  
  :: don't update projects for subsequent architectures to avoid mismatching builds
  set NO_UPDATE=true
  
  :: always clean projects for subsequent architectures
  set NO_CLEAN=false
  
  goto :eof

:vsdevcmd
  :: https://github.com/microsoft/vswhere/wiki/Start-Developer-Command-Prompt
  for /f "usebackq delims=" %%i in (`"%ROOT_DIR%\bin\vswhere.exe" -latest -property installationPath`) do (
    :: This assumes we are on a Windows x64 installation
    if "%ARCH%" == "x86" (
      call "%%i\VC\Auxiliary\Build\vcvarsall.bat" x64_x86 || exit 1
      set TARGET=i686-pc-windows
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
  echo Error: Visual Studio installation could not be found.
  exit /b 2

:error_missing_command
  echo.
  echo Error: %1 not found.
  echo Please install %1 via %~2.
  exit 1
