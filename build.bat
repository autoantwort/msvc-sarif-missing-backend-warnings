@echo off
rem Compiles main.cpp with SARIF output. Run from a "x64 Native Tools Command Prompt for VS 2022",
rem or let this script set up the environment via vswhere.
setlocal

where cl >nul 2>nul
if errorlevel 1 (
    set "PATH=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer;%PATH%"
    for /f "usebackq delims=" %%i in (`"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -latest -property installationPath`) do (
        call "%%i\VC\Auxiliary\Build\vcvars64.bat" >nul
    )
)

cd /d "%~dp0"
if exist sarif rmdir /s /q sarif
mkdir sarif

cl /nologo /c /W4 /O2 /experimental:log sarif\ main.cpp

echo.
echo ===== ruleIds in sarif\main.sarif =====
findstr /c:"\"ruleId\"" sarif\main.sarif
