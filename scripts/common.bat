@echo off

:: load environment
call "%~dp0\sdkenv.bat"

:: Call subroutine passed as argument
setlocal
call :%*
exit /b %errorlevel%

:loadenv
  goto :eof

:prepare_project
for /f "usebackq tokens=*" %%A in (`yq ".[] | select(.name == \"%PROJECT%\") | .tag" "%YAML_FILE%"`) do set TAG=%%A
for /f "usebackq tokens=*" %%A in (`yq ".[] | select(.name == \"%PROJECT%\") | .archive" "%YAML_FILE%"`) do set ARCHIVE=%%A
for /f "usebackq tokens=*" %%A in (`yq ".[] | select(.name == \"%PROJECT%\") | .sha256" "%YAML_FILE%"`) do set EXPECTED_SHA=%%A

set ARCHIVE=!ARCHIVE:{TAG}=%TAG%!
set CACHE_DIR=%ROOT_DIR%\cache
set EXTRACT_DIR=%SRCROOT%\%PROJECT%-%TAG%
set FILE=%CACHE_DIR%\%PROJECT%-%TAG%.tar.gz

if not exist "%CACHE_DIR%" mkdir "%CACHE_DIR%"

if exist "%FILE%" (
    echo Found cached %PROJECT% at %FILE%
) else (
    echo Downloading %PROJECT% from %ARCHIVE%
    powershell -Command "Invoke-WebRequest -Uri '%ARCHIVE%' -OutFile '%FILE%'"
)

for /f "usebackq tokens=*" %%H in (`powershell -Command "(Get-FileHash -Algorithm SHA256 '%FILE%').Hash.ToLower()"`) do set ACTUAL_SHA=%%H

if /i "%ACTUAL_SHA%"=="%EXPECTED_SHA%" (
    echo SHA256 verified for %PROJECT%
) else (
    echo ERROR: SHA256 mismatch for %PROJECT%
    exit /b 1
)

if exist "%EXTRACT_DIR%" (
    echo Removing existing extraction directory: %EXTRACT_DIR%
    rmdir /s /q "%EXTRACT_DIR%"
)

echo Extracting %PROJECT% into %EXTRACT_DIR%
mkdir "%EXTRACT_DIR%"
cd "%EXTRACT_DIR%"
tar --strip-components=1 -xzf "%FILE%"

  
for /F "tokens=*" %%P in ('dir /b /s ^"%ROOT_DIR%\patches\%PROJECT%-*.patch^" 2^>nul') do (
  echo.
  echo ### Applying %%~nxP
  patch -p1 -i "%%P" || exit /b 1
)

if defined ADDITIONAL_PATCHES_DIR (
  for /F "tokens=*" %%P in ('dir /b /s ^"%ADDITIONAL_PATCHES_DIR%\%PROJECT%-*.patch^" 2^>nul') do (
    echo.
    echo ### Applying %%~nxP
    patch -p1 -i "%%P" || exit /b 1
  )
)

goto :eof
