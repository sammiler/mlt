@echo off
setlocal enabledelayedexpansion

REM MLT vcpkg port installation script
REM This script copies the port to vcpkg and attempts installation

set "SCRIPT_DIR=%~dp0"
set "PORT_SOURCE=%SCRIPT_DIR%"

REM Check if vcpkg root is set
if "%VCPKG_ROOT%"=="" (
    echo ERROR: VCPKG_ROOT environment variable is not set.
    echo Please set VCPKG_ROOT to your vcpkg installation directory.
    echo Example: set VCPKG_ROOT=C:\vcpkg
    pause
    exit /b 1
)

if not exist "%VCPKG_ROOT%\vcpkg.exe" (
    echo ERROR: vcpkg.exe not found in %VCPKG_ROOT%
    echo Please verify VCPKG_ROOT points to a valid vcpkg installation.
    pause
    exit /b 1
)

set "VCPKG_PORTS_DIR=%VCPKG_ROOT%\ports"
set "MLT_PORT_DIR=%VCPKG_PORTS_DIR%\mlt"

echo MLT vcpkg Port Installation Script
echo ==================================
echo.
echo VCPKG_ROOT: %VCPKG_ROOT%
echo Source Port: %PORT_SOURCE%
echo Target Port: %MLT_PORT_DIR%
echo.

REM Remove existing port if it exists
if exist "%MLT_PORT_DIR%" (
    echo Removing existing MLT port...
    rmdir /s /q "%MLT_PORT_DIR%"
)

REM Create port directory
echo Creating MLT port directory...
mkdir "%MLT_PORT_DIR%"

REM Copy port files
echo Copying port files...
copy "%PORT_SOURCE%\vcpkg.json" "%MLT_PORT_DIR%\" >nul
copy "%PORT_SOURCE%\portfile.cmake" "%MLT_PORT_DIR%\" >nul
if exist "%PORT_SOURCE%\README.md" copy "%PORT_SOURCE%\README.md" "%MLT_PORT_DIR%\" >nul

echo Port files copied successfully.
echo.

REM Ask user which features to install
echo Available installation options:
echo 1. Core only (minimal)
echo 2. Core + Qt6
echo 3. Core + FFmpeg + SDL2
echo 4. Core + SoX + Movit
echo 5. All features (Qt6 + FFmpeg + SDL2 + Frei0r + SoX + Movit)
echo 6. Custom selection
echo.
set /p choice="Enter your choice (1-6): "

set "FEATURES="
if "%choice%"=="1" set "FEATURES="
if "%choice%"=="2" set "FEATURES=[qt6]"
if "%choice%"=="3" set "FEATURES=[ffmpeg,sdl2]"
if "%choice%"=="4" set "FEATURES=[sox,movit]"
if "%choice%"=="5" set "FEATURES=[qt6,ffmpeg,sdl2,frei0r,sox,movit]"
if "%choice%"=="6" (
    echo Available features: qt6, ffmpeg, sdl2, frei0r, sox, movit
    echo Enter features manually ^(e.g., [qt6,ffmpeg]^):
    set /p FEATURES="Features: "
)

REM Build the install command
set "INSTALL_CMD=%VCPKG_ROOT%\vcpkg.exe install mlt%FEATURES%:x64-windows"

echo.
echo Running: %INSTALL_CMD%
echo.

REM Run the installation
%INSTALL_CMD%

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Installation failed with error code %ERRORLEVEL%
    echo.
    echo Common issues:
    echo - SHA512 hash mismatch ^(update hash in portfile.cmake^)
    echo - Missing dependencies
    echo - Build configuration issues
    echo.
    echo Check the vcpkg build logs for more details.
) else (
    echo.
    echo MLT installation completed successfully!
    echo.
    echo The package is now available at:
    echo %VCPKG_ROOT%\installed\x64-windows\
    echo.
    echo To use in CMake:
    echo find_package^(Mlt7 REQUIRED^)
    echo target_link_libraries^(your_target PRIVATE Mlt7::mlt Mlt7::mlt++^)
)

echo.
pause
