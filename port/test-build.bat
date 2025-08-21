@echo off
setlocal enabledelayedexpansion

REM MLT test build script

set "SCRIPT_DIR=%~dp0"
set "TEST_DIR=%SCRIPT_DIR%test"
set "BUILD_DIR=%TEST_DIR%\build"

if "%VCPKG_ROOT%"=="" (
    echo ERROR: VCPKG_ROOT environment variable is not set.
    pause
    exit /b 1
)

echo MLT Test Build Script
echo =====================
echo.

REM Check if MLT is installed
set "INSTALLED_DIR=%VCPKG_ROOT%\installed\x64-windows"
if not exist "%INSTALLED_DIR%\include\mlt-7" (
    echo ERROR: MLT does not appear to be installed in vcpkg.
    echo Please install MLT first using install-port.bat
    pause
    exit /b 1
)

REM Clean and create build directory
if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
mkdir "%BUILD_DIR%"

cd "%BUILD_DIR%"

echo Configuring CMake project...
cmake .. -DCMAKE_TOOLCHAIN_FILE="%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake"

if %ERRORLEVEL% NEQ 0 (
    echo CMake configuration failed!
    pause
    exit /b 1
)

echo Building project...
cmake --build . --config Release

if %ERRORLEVEL% NEQ 0 (
    echo Build failed!
    pause
    exit /b 1
)

echo.
echo Build completed successfully!

if exist "Release\mlt_test.exe" (
    echo.
    echo Running test...
    echo ===============
    Release\mlt_test.exe
    echo.
    echo Test execution completed.
) else (
    echo Test executable not found.
)

echo.
pause
