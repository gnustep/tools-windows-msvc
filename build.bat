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

set "SCRIPT_NAME=%~0"
set "ROOT_DIR=%~dp0"

:: parse command-line arguments
:getopts
  if /i "%~1" == "-h" goto usage
  if /i "%~1" == "--help" goto usage
  if /i "%~1" == "/?" goto usage
  
  if /i "%~1" == "--prefix" set "INSTALL_ROOT=%~2" & shift & shift & goto getopts
  if /i "%~1" == "--type" set "BUILD_TYPES=%~2" & shift & shift & goto getopts
  if /i "%~1" == "--only" set "ONLY_PHASE=%~2" & shift & shift & goto getopts
  if /i "%~1" == "--only-dependencies" set ONLY_DEPENDENCIES=1 & shift & goto getopts
  if /i "%~1" == "--patches" set "ADDITIONAL_PATCHES_DIR=%~2" & shift & shift & goto getopts
  
  if not "%~1" == "" echo Unknown option: %~1 & exit 1

:: validate options
if defined BUILD_TYPES (
  if not "%BUILD_TYPES%" == "Debug" (
    if not "%BUILD_TYPES%" == "Release" (
      echo Error: invalid build type "%BUILD_TYPES%"
      exit 1
    )
  )
)
if defined ADDITIONAL_PATCHES_DIR (
  if not exist "%ADDITIONAL_PATCHES_DIR%" (
    echo Error: patches directory does not exist
    echo     %ADDITIONAL_PATCHES_DIR%
    exit 1
  )
)
if defined ONLY_PHASE (
  for %%F in (%ROOT_DIR%\phases\??-%ONLY_PHASE%.*) do (
    set ONLY_PHASE_VALID=1
  )
  if not defined ONLY_PHASE_VALID (
    echo Error: Unknown phase "%ONLY_PHASE%"
    for %%F in (%ROOT_DIR%\phases\??-*.*) do (
      call :set_phase_vars %%F
      set "PHASES=!PHASES!!PHASE_NAME! "
    )
    echo Valid phases: !PHASES!
    exit 1
  )
)

:: load environment
call %ROOT_DIR%\scripts\sdkenv.bat || exit 1

:: print options
echo ### Building into: %INSTALL_ROOT%
echo ### Building for: %BUILD_TYPES%
if defined ONLY_PHASE (
  echo ### Building only %ONLY_PHASE%
) else if defined ONLY_DEPENDENCIES (
  echo ### Bulding only dependencies
)
if defined ADDITIONAL_PATCHES_DIR (
  echo ### Additional patches: %ADDITIONAL_PATCHES_DIR%
)

:: check if all required commands are installed
echo.
echo ### Checking prerequisites
echo Using Bash shell: %BASH%
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
call %BASH% 'which make'
if %errorlevel% neq 0 call :error_missing_command make, "'pacman -S make' in MSYS2"
call %BASH% 'which autoconf'
if %errorlevel% neq 0 call :error_missing_command autoconf, "'pacman -S autoconf' in MSYS2"
call %BASH% 'which automake'
if %errorlevel% neq 0 call :error_missing_command automake, "'pacman -S automake' in MSYS2"
call %BASH% 'which libtool'
if %errorlevel% neq 0 call :error_missing_command libtool, "'pacman -S libtool' in MSYS2"

:: create directories
if not exist "%SRCROOT%" (mkdir "%SRCROOT%" || exit 1)
if not exist "%INSTALL_ROOT%\%ARCH%" (mkdir "%INSTALL_ROOT%\%ARCH%" || exit 1)

:: run phases for debug/release
for %%G in (%BUILD_TYPES%) do (
  set BUILD_TYPE=%%G
  call :build
)

echo.
echo ### Finished building GNUstep into:
echo ### %INSTALL_ROOT%\%ARCH%

goto :eof

:build
  echo.
  echo ######## BUILDING FOR %ARCH% %BUILD_TYPE% ########
  
  set INSTALL_PREFIX=%INSTALL_ROOT%\%ARCH%\%BUILD_TYPE%
  
  for /f "usebackq delims=" %%i in (`call %BASH% 'cygpath -u "%INSTALL_PREFIX%"'`) do (
    set UNIX_INSTALL_PREFIX=%%i
  )
  
  if not defined ONLY_PHASE (
    :: keep backup of previous build if any
    if exist "%INSTALL_PREFIX%" (
      move /Y "%INSTALL_PREFIX%" "%INSTALL_PREFIX%.bak" || exit 1
    )
    :: remove previous failed build if any
    if exist "%INSTALL_PREFIX%.failed" (
      rmdir /S /Q "%INSTALL_PREFIX%.failed" || exit 1
    )
  )
  
  for %%F in (%ROOT_DIR%\phases\??-*.*) do (
    call :set_phase_vars %%F
    if defined ONLY_PHASE (
      if /i "%ONLY_PHASE%" == "!PHASE_NAME!" (
        call :build_phase
      )
    ) else if defined ONLY_DEPENDENCIES (
      if defined PHASE_IS_DEPENDENCY (
        call :build_phase
      )
    ) else (
      call :build_phase
    )
  )
  
  :: remove backup if all went well
  if exist "%INSTALL_PREFIX%.bak" (rmdir /S /Q "%INSTALL_PREFIX%.bak" || exit 1)
  
  :: don't update projects for subsequent build types to avoid mismatching builds
  set NO_UPDATE=true
  
  :: always clean projects for subsequent build types
  set NO_CLEAN=false
  
  goto :eof

:build_phase
  echo.
  echo ###### %PHASE_NAME% ######
  
  if %PHASE_EXTENSION% == .bat (
    call %PHASE% || (echo Failed && exit 1)
  ) else if %PHASE_EXTENSION% == .sh (
    call %BASH% '`cygpath -u "%PHASE%"`' || (echo Failed && exit 1)
  ) else (
    echo Error invalid phase: %PHASE_NAME% && exit 1
  )
  goto :eof

:set_phase_vars
  set PHASE=%1
  set PHASE_EXTENSION=%~x1
  set PHASE_NAME=%~n1
  if %PHASE_NAME:~0,1% == 1 (
    set PHASE_IS_DEPENDENCY=1
  ) else (
    set PHASE_IS_DEPENDENCY=
  )
  set PHASE_NAME=%PHASE_NAME:~3%
  goto :eof

:error_missing_command
  echo.
  echo Error: %1 not found.
  echo Please install %1 via %~2.
  exit 1

:usage
  echo Builds GNUstep Windows MSVC toolchain
  echo https://github.com/gnustep/tools-windows-msvc
  echo.
  echo Usage: %SCRIPT_NAME%
  echo   --prefix INSTALL_ROOT    Install into given directory (default: C:\GNUstep), followed by [x86^|x64]\[Debug^|Release]
  echo   --type Debug/Release     Build only the given build type (default: both)
  echo   --only PHASE             Re-build only the given phase (e.g. "gnustep-base")
  echo   --only-dependencies      Build only GNUstep dependencies
  echo   --patches DIR            Apply additional patches from given directory
  echo   -h, --help, /?           Print usage information and exit
  exit 1

