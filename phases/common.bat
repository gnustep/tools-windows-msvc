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
    git reset --hard || exit /b 1
    git clean -qfdx || exit /b 1
  )
  
  if not [%NO_UPDATE%] == [true] (
    echo.
    if "%TAG%" == "" (
      :: check if we should update project
      set GIT_BRANCH=NONE
      for /f "usebackq delims=" %%i in (`git symbolic-ref --short -q HEAD`) do (
        set GIT_BRANCH=%%i
      )
      if not [%GIT_BRANCH%] == [NONE] (
        :: check if current branch has a remote
        set GIT_REMOTE=NONE
        for /f "usebackq delims=" %%i in (`git config --get branch.%GIT_BRANCH%.remote`) do (
          set GIT_REMOTE=%%i
        )
        if not [%GIT_REMOTE%] == [NONE] (
          echo ### Updating project
          git pull --ff-only || exit /b 1
        ) else (
          echo ### NOT updating project [no remote for branch %GIT_BRANCH%]
        )
      ) else (
        echo NOT updating project [not on branch]
      )
    ) else (
      echo ### Checking out %TAG%
      git fetch --tags || exit /b 1
      git checkout -q %TAG% || exit /b 1
    )
    
    :: update submodules if needed (also init in case submodule was added)
    git submodule sync --recursive || exit /b 1
    git submodule update --recursive --init || exit /b 1
  )
  
  for /F "tokens=*" %%P in ('dir /b /s ^"%ROOT_DIR%\patches\%PROJECT%-*.patch^" 2^>nul') do (
    echo.
    echo ### Applying %%~nxP
    git apply %%P
  )
  
  exit /b 0
