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
  
  if not exist "%PROJECT%" (
    echo ### Cloning project
    git clone --recursive %REPO% %PROJECT% || exit /b 1
  )
  
  exit /b 0
