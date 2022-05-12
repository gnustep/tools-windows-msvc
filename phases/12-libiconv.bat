@echo off
setlocal

set PROJECT=libiconv
set GITHUB_REPO=kiyolee/libiconv-win-build
set TAG=

:: load environment and prepare project
call "%~dp0\..\scripts\common.bat" prepare_project || exit /b 1

:: determine Visual Studio version
if "%VisualStudioVersion:~0,3%" == "17." set VSVERSION=2022
if "%VisualStudioVersion:~0,3%" == "16." set VSVERSION=2019
if "%VisualStudioVersion:~0,3%" == "15." set VSVERSION=2017
if "%VisualStudioVersion:~0,3%" == "14." set VSVERSION=2015

if "%VSVERSION%" == "" (
  echo Error: unknown or unsupported Visual Studio version "%VisualStudioVersion%"
  exit /b 1
)

cd "%SRCROOT%\%PROJECT%\build-VS%VSVERSION%" || exit /b 1

if "%ARCH%" == "x86" (
  set BUILD_DIR=%BUILD_TYPE%
  set PLATFORM=Win32
) else if "%ARCH%" == "x64" (
  set BUILD_DIR=x64\%BUILD_TYPE%
  set PLATFORM=x64
) else (
  echo Unknown ARCH: %ARCH%
  exit /b 1
)

echo.
echo ### Building
msbuild libiconv.sln -t:dll\libiconv -p:Configuration=%BUILD_TYPE% -p:Platform=%PLATFORM%

echo.
echo ### Installing
:: rename libiconv.lib to iconv.lib to allow linking using -liconv
:: (the wildcard suffix is required to suppress the "file or directory" prompt)
xcopy /Y /F %BUILD_DIR%\libiconv.lib "%INSTALL_PREFIX%\lib\iconv.lib*" || exit /b 1
xcopy /Y /F %BUILD_DIR%\libiconv.dll "%INSTALL_PREFIX%\bin\" || exit /b 1
xcopy /Y /F %BUILD_DIR%\libiconv.pdb "%INSTALL_PREFIX%\bin\" || exit /b 1
xcopy /Y /F /S "%SRCROOT%\%PROJECT%\include\*" "%INSTALL_PREFIX%\include\" || exit /b 1
