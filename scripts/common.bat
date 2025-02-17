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
  
  if defined NO_CLEAN (
    echo.
    echo ### Skipping project cleanup
  ) else (
    echo.
    echo ### Cleaning project
    git reset --hard || exit /b 1
    git clean -qfdx || exit /b 1
  )
  
  if defined NO_UPDATE (
    echo.
    echo ### Skipping project update
  ) else (
    echo.
    :: check out tag/branch if any
    if not "%TAG%" == "" (
      echo ### Checking out "%TAG%"
      git fetch --tags || exit /b 1
      git checkout -q %TAG% || exit /b 1
    )
    
    call :update_project || exit /b 1
    
    :: update submodules if needed (also init in case submodule was added)
    git submodule sync --recursive || exit /b 1
    git submodule update --recursive --init || exit /b 1
  )
  
  for /F "tokens=*" %%P in ('dir /b /s ^"%ROOT_DIR%\patches\%PROJECT%-*.patch^" 2^>nul') do (
    echo.
    echo ### Applying %%~nxP
    git apply -C1 %%P || exit /b 1
  )
  
  if defined ADDITIONAL_PATCHES_DIR (
    for /F "tokens=*" %%P in ('dir /b /s ^"%ADDITIONAL_PATCHES_DIR%\%PROJECT%-*.patch^" 2^>nul') do (
      echo.
      echo ### Applying %%~nxP
      git apply -C1 %%P || exit /b 1
    )
  )
  
  goto :eof

:update_project
  :: check if we should update project
  set GIT_BRANCH=NONE
  for /f "usebackq delims=" %%i in (`git symbolic-ref --short -q HEAD`) do (
    call :set_git_branch %%i || exit /b 1
  )
  if not [%GIT_BRANCH%] == [NONE] (
    call :update_project_2 || exit /b 1
  ) else if "%TAG%" == "" (
    echo NOT updating project [not on branch]
  )
  goto :eof

:update_project_2
  :: check if current branch has a remote
  set GIT_REMOTE=NONE
  for /f "usebackq delims=" %%i in (`git config --get branch.%GIT_BRANCH%.remote`) do (
    call :set_git_remote %%i || exit /b 1
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
