@echo off

:: Load environment
call %~dp0..\env\sdkenv.bat

:: Call subroutine passed as argument
call :%*
exit /b %errorlevel%

:prepare_project
  if not defined PROJECT (echo Missing PROJECT && exit /b 1)
  if not defined REPO (echo Missing REPO && exit /b 1)
  
  cd "%SRCROOT%"
  
  :: clone project if needed
  if not exist "%PROJECT%" (
    echo.
    echo ### Cloning project
    git clone --recursive %REPO% %PROJECT% || exit /b 1
  )
  
  cd %PROJECT%
  
  if not [%NO_CLEAN%] == [true] (
    echo.
    echo ### Cleaning project
    git reset --hard
    git clean -qfdx
  )
  
  for /F "tokens=*" %%P in ('dir /b /s ^"%ROOT_DIR%\patches\%PROJECT%-*.patch^" 2^>nul') do (
    echo.
    echo ### Applying %%~nxP
    git apply %%P
  )
  
  exit /b 0
