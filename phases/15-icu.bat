@echo off
setlocal

call "%~dp0\common.bat" loadenv || exit /b 1

if "%ARCH%" == "x86" (
  set ICU_RELEASE_URL=https://github.com/unicode-org/icu/releases/download/release-68-2/icu4c-68_2-Win32-MSVC2019.zip
) else if "%ARCH%" == "x64" (
  set ICU_RELEASE_URL=https://github.com/unicode-org/icu/releases/download/release-68-2/icu4c-68_2-Win64-MSVC2019.zip
) else (
  echo Unknown ARCH: %ARCH%
  exit /b 1
)

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
xcopy /Y /F "icu*.dll" "%INSTALL_PREFIX%\lib\" || exit /b 1
popd
pushd lib* || exit /b 1
xcopy /Y /F "icu*.lib" "%INSTALL_PREFIX%\lib\" || exit /b 1
popd
xcopy /Y /F /S "include\*" "%INSTALL_PREFIX%\include\" || exit /b 1
