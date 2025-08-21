@echo off
setlocal enabledelayedexpansion

REM MLT vcpkg port verification script
REM This script checks if MLT was installed correctly

if "%VCPKG_ROOT%"=="" (
    echo ERROR: VCPKG_ROOT environment variable is not set.
    pause
    exit /b 1
)

set "INSTALLED_DIR=%VCPKG_ROOT%\installed\x64-windows"

echo MLT vcpkg Port Verification
echo ===========================
echo.

echo Checking installation directory: %INSTALLED_DIR%
echo.

REM Check if installation directory exists
if not exist "%INSTALLED_DIR%" (
    echo ERROR: Installation directory does not exist.
    echo MLT may not be installed yet.
    pause
    exit /b 1
)

REM Check core files
echo Checking core files:

set "MISSING_FILES="

if exist "%INSTALLED_DIR%\bin\mlt-7.dll" (
    echo [✓] mlt-7.dll found
) else (
    echo [✗] mlt-7.dll NOT found
    set "MISSING_FILES=1"
)

if exist "%INSTALLED_DIR%\bin\mlt++-7.dll" (
    echo [✓] mlt++-7.dll found
) else (
    echo [✗] mlt++-7.dll NOT found
    set "MISSING_FILES=1"
)

if exist "%INSTALLED_DIR%\lib\mlt-7.lib" (
    echo [✓] mlt-7.lib found
) else (
    echo [✗] mlt-7.lib NOT found
    set "MISSING_FILES=1"
)

if exist "%INSTALLED_DIR%\lib\mlt++-7.lib" (
    echo [✓] mlt++-7.lib found
) else (
    echo [✗] mlt++-7.lib NOT found
    set "MISSING_FILES=1"
)

echo.
echo Checking headers:

if exist "%INSTALLED_DIR%\include\mlt-7\framework\mlt.h" (
    echo [✓] MLT framework headers found
) else (
    echo [✗] MLT framework headers NOT found
    set "MISSING_FILES=1"
)

if exist "%INSTALLED_DIR%\include\mlt-7\mlt++\Mlt.h" (
    echo [✓] MLT++ headers found
) else (
    echo [✗] MLT++ headers NOT found
    set "MISSING_FILES=1"
)

echo.
echo Checking modules:

if exist "%INSTALLED_DIR%\lib\mlt" (
    echo [✓] MLT modules directory found
    dir /b "%INSTALLED_DIR%\lib\mlt\*.dll" 2>nul | find /c ".dll" >temp_count.txt
    set /p MODULE_COUNT=<temp_count.txt
    del temp_count.txt
    echo     Found !MODULE_COUNT! module(s)
) else (
    echo [✗] MLT modules directory NOT found
    set "MISSING_FILES=1"
)

echo.
echo Checking tools:

if exist "%INSTALLED_DIR%\tools\mlt\melt.exe" (
    echo [✓] melt.exe tool found
) else (
    echo [✗] melt.exe tool NOT found
    set "MISSING_FILES=1"
)

echo.
echo Checking CMake config:

if exist "%INSTALLED_DIR%\lib\cmake\Mlt7\Mlt7Config.cmake" (
    echo [✓] CMake configuration found
) else (
    echo [✗] CMake configuration NOT found
    set "MISSING_FILES=1"
)

echo.
echo Checking data files:

if exist "%INSTALLED_DIR%\share\mlt" (
    echo [✓] MLT data directory found
) else (
    echo [✗] MLT data directory NOT found
    set "MISSING_FILES=1"
)

echo.
echo ===========================

if "%MISSING_FILES%"=="1" (
    echo RESULT: Installation appears to be INCOMPLETE
    echo Some expected files are missing.
) else (
    echo RESULT: Installation appears to be SUCCESSFUL
    echo All expected files are present.
)

echo.
echo Installation summary saved to verification_result.txt

REM Save results to file
(
    echo MLT vcpkg Port Verification Results
    echo Generated: %date% %time%
    echo.
    echo Installation directory: %INSTALLED_DIR%
    echo.
    if "%MISSING_FILES%"=="1" (
        echo Status: INCOMPLETE - Some files missing
    ) else (
        echo Status: COMPLETE - All expected files found
    )
) > verification_result.txt

pause
