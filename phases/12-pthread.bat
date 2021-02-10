
set PTHREAD_RELEASE_URL=ftp://sourceware.org/pub/pthreads-win32/prebuilt-dll-2-9-1-release

pushd "%INSTALL_PREFIX%"

pushd lib
if not exist pthreadVC2.dll (curl -O# %PTHREAD_RELEASE_URL%/dll/%ARCH%/pthreadVC2.dll || exit /b 1)
if not exist pthreadVC2.lib (curl -O# %PTHREAD_RELEASE_URL%/lib/%ARCH%/pthreadVC2.lib || exit /b 1)
popd

pushd include
if not exist sched.h (curl -O# %PTHREAD_RELEASE_URL%/include/sched.h || exit /b 1)
if not exist semaphore.h (curl -O# %PTHREAD_RELEASE_URL%/include/semaphore.h || exit /b 1)
if not exist pthread.h (
  curl -O# %PTHREAD_RELEASE_URL%/include/pthread.h || exit /b 1
  ren pthread.h pthread.orig.h
  (
    echo // Windows headers define timspec without _TIMESPEC_DEFINED
    echo #if defined^(_MSC_VER^) ^&^& ^^!defined^(_TIMESPEC_DEFINED^)
    echo #define _TIMESPEC_DEFINED
    echo #endif
  ) > pthread.h || exit /b 1
  type pthread.orig.h >> pthread.h
  del pthread.orig.h
)

popd

popd

echo.
echo pthreads-win32 installed
