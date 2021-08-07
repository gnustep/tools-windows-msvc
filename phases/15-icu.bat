@echo off
setlocal

set GITHUB_REPO=unicode-org/icu

call "%~dp0\..\scripts\common.bat" loadenv || exit /b 1

:: determine whether we can use the Windows-provided ICU
:: (requires Windows 10 version 1903 / build 18362 or later)
for /f "tokens=4-6 delims=. " %%i in ('ver') do (
  set WIN_VERSION=%%i
  set WIN_BUILD=%%k
)
if %WIN_VERSION% GTR 10 (
  :: Windows 11 or later
  set SKIP_ICU=1
) else if %WIN_VERSION% EQU 10 (
  if %WIN_BUILD% GEQ 18362 (
    :: Windows 10 version 1903 / build 18362 or later
    set SKIP_ICU=1
  )
)
if defined SKIP_ICU (
  echo Using system-provided ICU DLL ^(requires Windows 10 version 1903 or later^)
  exit /b 0
)

:: get the latest release tag from GitHub
cd %~dp0
if not defined ICU_VERSION (
  for /f "usebackq delims=" %%i in (`call %BASH% '../scripts/get-latest-github-release-tag.sh %GITHUB_REPO%'`) do (
    for /f "tokens=2,3 delims=-" %%j in ("%%i") do (
      set ICU_VERSION=%%j.%%k
    )
  )
)
if not defined ICU_VERSION (
  echo Error getting latest ICU release
  exit /b 1
)
echo Using ICU %ICU_VERSION%

:: build download URL
if "%ARCH%" == "x86" set ICU_ARCH=Win32
if "%ARCH%" == "x64" set ICU_ARCH=Win64
set ICU_RELEASE_URL=https://github.com/%GITHUB_REPO%/releases/download/release-%ICU_VERSION:.=-%/icu4c-%ICU_VERSION:.=_%-%ICU_ARCH%-MSVC2019.zip

for %%a in ("%ICU_RELEASE_URL%") do (
   set ICU_RELEASE_FILE=%%~nxa
   set ICU_RELEASE_NAME=%%~na
)

if not exist "%CACHE_ROOT%" (mkdir "%CACHE_ROOT%" || exit /b 1)
cd "%CACHE_ROOT%" || exit /b 1

if not exist %ICU_RELEASE_FILE% (
  echo.
  echo ### Downloading release
  curl -L -O# %ICU_RELEASE_URL% || exit /b 1
)

if not exist %ICU_RELEASE_NAME% (
  echo.
  echo ### Extracting release
  powershell Expand-Archive %ICU_RELEASE_FILE% || exit /b 1
)

echo.
echo ### Installing
cd %ICU_RELEASE_NAME% || exit /b 1
pushd bin* || exit /b 1
xcopy /Y /F "icu*.dll" "%INSTALL_PREFIX%\bin\" || exit /b 1
popd
pushd lib* || exit /b 1
xcopy /Y /F "icu*.lib" "%INSTALL_PREFIX%\lib\" || exit /b 1
popd
xcopy /Y /F /S "include\*" "%INSTALL_PREFIX%\include\" || exit /b 1

:: write pkgconfig files
call "%~dp0\..\scripts\common.bat" write_pkgconfig icu-i18n %ICU_VERSION% "" -licuin "" icu-uc || exit /b 1
call "%~dp0\..\scripts\common.bat" write_pkgconfig icu-io %ICU_VERSION% "" -licuio "" icu-i18n || exit /b 1
call "%~dp0\..\scripts\common.bat" write_pkgconfig icu-uc %ICU_VERSION% "" "-licuuc -licudt" || exit /b 1
