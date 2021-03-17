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

:: Load environment
call %~dp0\env\sdkenv.bat || exit 1

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
if not exist "%SRCROOT%" (mkdir "%SRCROOT%" || exit 1)
if not exist "%INSTALL_ROOT%" (mkdir "%INSTALL_ROOT%" || exit 1)

:: Run phases for Debug/Release
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

:error_missing_command
  echo.
  echo Error: %1 not found.
  echo Please install %1 via %~2.
  exit 1
