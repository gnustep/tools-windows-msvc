@echo off

call :%*
exit /b %errorlevel%

:prepare_project
  set PROJECT=%1
  set REPO=%2
  set TAG=%3
  set BUILD_DIR="%SRCROOT%\%PROJECT%\build-%ARCH%"
  
  pushd "%SRCROOT%"
  
  if not exist "%PROJECT%" (
    echo ### Cloning project
    git clone --recursive %REPO% %PROJECT% || exit /b 1
  )
  
  popd
  
  exit /b 0
