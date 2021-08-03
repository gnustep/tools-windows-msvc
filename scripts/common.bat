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
  if not defined PROJECT (echo Missing PROJECT && exit /b 1)
  if not defined REPO (
    if defined GITHUB_REPO (
      set REPO=https://github.com/%GITHUB_REPO%.git
    ) else (
      echo Missing REPO && exit /b 1
    )
  )
  
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
    git reset --hard || exit /b 1
    git clean -qfdx || exit /b 1
  )
  
  if not [%NO_UPDATE%] == [true] (
    echo.
    :: check out tag/branch if any
    if not "%TAG%" == "" (
      echo ### Checking out %TAG%
      git fetch --tags || exit /b 1
      git checkout -q %TAG% || exit /b 1
    )
    
    call :update_project
    
    :: update submodules if needed (also init in case submodule was added)
    git submodule sync --recursive || exit /b 1
    git submodule update --recursive --init || exit /b 1
  )
  
  for /F "tokens=*" %%P in ('dir /b /s ^"%ROOT_DIR%\patches\%PROJECT%-*.patch^" 2^>nul') do (
    echo.
    echo ### Applying %%~nxP
    git apply %%P
  )
  
  if defined ADDITIONAL_PATCHES_DIR (
    for /F "tokens=*" %%P in ('dir /b /s ^"%ADDITIONAL_PATCHES_DIR%\%PROJECT%-*.patch^" 2^>nul') do (
      echo.
      echo ### Applying %%~nxP
      git apply %%P
    )
  )
  
  goto :eof

:update_project
  :: check if we should update project
  set GIT_BRANCH=NONE
  for /f "usebackq delims=" %%i in (`git symbolic-ref --short -q HEAD`) do (
    call :set_git_branch %%i
  )
  if not [%GIT_BRANCH%] == [NONE] (
    call :update_project_2
  ) else if "%TAG%" == "" (
    echo NOT updating project [not on branch]
  )
  goto :eof

:update_project_2
  :: check if current branch has a remote
  set GIT_REMOTE=NONE
  for /f "usebackq delims=" %%i in (`git config --get branch.%GIT_BRANCH%.remote`) do (
    call :set_git_remote %%i
  )
  if not [%GIT_REMOTE%] == [NONE] (
    echo ### Updating project
    git pull --ff-only || exit /b 1
  ) else (
    echo ### NOT updating project [no remote for branch %GIT_BRANCH%]
  )
  goto :eof

:set_git_branch
  set GIT_BRANCH=%1
  goto :eof
  
:set_git_remote
  set GIT_REMOTE=%1
  goto :eof

:write_pkgconfig
  set PKGCONFIG_NAME=%~1
  set PKGCONFIG_VERSION=%~2
  set PKGCONFIG_CFLAGS=%~3
  set PKGCONFIG_LIBS=%~4
  set PKGCONFIG_LIBS_PRIVATE=%~5
  set PKGCONFIG_REQUIRES=%~6
  
  :: trim "v" version prefix
  if /i "%PKGCONFIG_VERSION:~0,1%" == "v" (
    set PKGCONFIG_VERSION=%PKGCONFIG_VERSION:~1%
  )
  
  :: use forward slashes for prefix path
  set PKGCONFIG_PREFIX=%INSTALL_PREFIX:\=/%
  
  if not exist "%INSTALL_PREFIX%\lib\pkgconfig" (mkdir "%INSTALL_PREFIX%\lib\pkgconfig" || exit /b 1)
  
  echo Writing pkgconfig file...
  (
    echo prefix=%PKGCONFIG_PREFIX%
    echo exec_prefix=${prefix}
    echo libdir=${exec_prefix}/lib
    echo includedir=${prefix}/include
    echo.
    echo Name: %PKGCONFIG_NAME%
    echo Version: %PKGCONFIG_VERSION%
    echo Description: %PKGCONFIG_NAME%
    echo Requires: %PKGCONFIG_REQUIRES%
    echo.
    echo Cflags: -I${includedir} %PKGCONFIG_CFLAGS%
    echo Libs: -L${libdir} %PKGCONFIG_LIBS%
    echo Libs.private: %PKGCONFIG_LIBS_PRIVATE%
  ) > %INSTALL_PREFIX%\lib\pkgconfig\%PKGCONFIG_NAME%.pc
