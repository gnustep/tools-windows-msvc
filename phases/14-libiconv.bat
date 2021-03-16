
set PROJECT=libiconv
set REPO=https://github.com/kiyolee/libiconv-win-build.git

call "%~dp0\common.bat" prepare_project || exit /b 1

:: determine Visual Studio version
for /f "usebackq delims=" %%i in (`"%ROOT_DIR%\bin\vswhere.exe" -latest -property catalog_productLineVersion`) do (
  set VSVERSION=%%i
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
xcopy /Y /F %BUILD_DIR%\libiconv.lib "%INSTALL_PREFIX%\lib\iconv.lib*"
xcopy /Y /F %BUILD_DIR%\libiconv.dll "%INSTALL_PREFIX%\lib\"
xcopy /Y /F %BUILD_DIR%\libiconv.pdb "%INSTALL_PREFIX%\lib\"
xcopy /Y /F /S "%SRCROOT%\%PROJECT%\include\*" "%INSTALL_PREFIX%\include\"
