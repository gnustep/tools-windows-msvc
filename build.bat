@echo off
setlocal EnableDelayedExpansion

REM https://superuser.com/a/203672
setlocal
IF "%selfWrapped%"=="" (
  REM this is necessary so that we can use "exit" to terminate the batch file,
  REM and all subroutines, but not the original cmd.exe
  set selfWrapped=true
  %ComSpec% /s /c ""%~0" %*"
  goto :eof
)
endlocal

REM Reset environment
call RefreshEnv.cmd >nul

REM Variables

pushd %~dp0
set ROOT_DIR=%CD%
popd

set ARCHITECTURES=(x86 x64)
set SRCROOT=%ROOT_DIR%\src
set INSTALL_ROOT=C:\GNUstep

REM Check if all required commands are installed
where /Q git
if %errorlevel% neq 0 call :error_missing_command git
where /Q cmake
if %errorlevel% neq 0 call :error_missing_command cmake, "choco install cmake --installargs 'ADD_CMAKE_TO_PATH=System'"
where /Q ninja
if %errorlevel% neq 0 call :error_missing_command ninja
where /Q make
if %errorlevel% neq 0 call :error_missing_command make
where /Q clang-cl
if %errorlevel% neq 0 call :error_missing_command clang-cl, "choco install llvm"

REM Find Git Bash
for /f "usebackq delims=" %%i in (`where git`) do (
  set GITBASH=%%~di%%~pi..\bin\bash.exe
)
if not exist "%GITBASH%" call :error_missing_command "Git Bash", "choco install git"

if not exist "%SRCROOT%" (mkdir "%SRCROOT%")
if not exist "%INSTALL_ROOT%" (mkdir "%INSTALL_ROOT%")

REM Run phases

for %%G in %ARCHITECTURES% do (
  set ARCH=%%G
  call :buildarch
  
  REM Reset environment so we can call vcvarsall.bat multiple times
  call RefreshEnv.cmd >nul
)

goto :eof

:buildarch
  echo.
  echo ######## BUILDING FOR %ARCH% ########
  echo.
  
  set INSTALL_PREFIX=%INSTALL_ROOT%\%ARCH%
  
  REM Determine install prefix as Unix path
  pushd "%INSTALL_PREFIX%"
  for /f "usebackq delims=" %%i in (`call "%GITBASH%" -c 'pwd'`) do (
    set UNIX_INSTALL_PREFIX=%%i
  )
  popd

  call :vsdevcmd || (echo Failed && exit 1)

  for %%f in (%ROOT_DIR%\phases\*.bat) do (
    echo.
    echo ###### %%~nf ######
    echo.

    call %%f || (echo Failed && exit 1)
  )
  
  goto :eof

:vsdevcmd
  REM https://github.com/microsoft/vswhere/wiki/Start-Developer-Command-Prompt
  for /f "usebackq delims=" %%i in (`"%ROOT_DIR%\vswhere.exe" -latest -property installationPath`) do (
    REM This assumes we are on a x64 machine
    if "%ARCH%" == "x86" (
      set CFLAGS=-m32
      set CXXFLAGS=-m32
      call "%%i\VC\Auxiliary\Build\vcvarsall.bat" x64_x86 || exit 1
    ) else (
      call "%%i\VC\Auxiliary\Build\vcvarsall.bat" %ARCH% || exit 1
      set CFLAGS=
      set CXXFLAGS=
    )
    goto :eof
  )
  REM Instance or command prompt not found
  exit /b 2

:error_missing_command
  if [%2] == [] (set install_cmd="choco install %1") else (set install_cmd=%2)
  echo Error: %1 not found. Please install via %install_cmd%.
  exit 1
