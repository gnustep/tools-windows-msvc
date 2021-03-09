
pushd %~dp0\..
set ROOT_DIR=%CD%
popd

:: TODO: add support for x86
if not defined ARCHITECTURES set ARCHITECTURES=x64
if not defined SRCROOT set SRCROOT=%ROOT_DIR%\src
if not defined INSTALL_ROOT set INSTALL_ROOT=C:\GNUstep

:: This is how we call into the MSYS2 shell. -full-path is needed so that
:: projects can find Clang installed in Windows-land, but note that this is
:: fragile as e.g. a Windows-installed "make" would be used instead of the one
:: installed in MSYS2. We could instead pass paths into MSYS2, but this doesn't
:: work because of spaces in Windows paths.
if not defined BASH set BASH=msys2_shell -defterm -no-start -msys2 -full-path -here -c
