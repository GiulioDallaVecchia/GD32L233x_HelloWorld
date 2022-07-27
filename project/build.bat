@echo off

:: NEEDED: set the variable for the directory of this script.
set TOP=%~dp0

set BUILD_CONFIG=%~1

if "%BUILD_CONFIG%" == "" goto :usage

if exist "%TOP%\build\%BUILD_CONFIG%" rd /s /q "%TOP%\build\%BUILD_CONFIG%"

if not exist "%TOP%\build\%BUILD_CONFIG%" mkdir "%TOP%\build\%BUILD_CONFIG%"

cmake --preset %BUILD_CONFIG% -G Ninja

cmake --build "%TOP%\build\%BUILD_CONFIG%" --verbose

exit /b

:usage
	echo Usage: [BUILD_CONFIG: Debug/Release/...]
	exit /b 2