@echo off

:: NEEDED: set the variable for the directory of this script.
set TOP=%~dp0

set BUILD_CONFIG=%~1

if "%BUILD_CONFIG%" == "" goto :usage

if not exist "%TOP%\build\%BUILD_CONFIG%" goto :error

cmake --build "%TOP%\build\%BUILD_CONFIG%" --target clean

exit /b

:usage
	echo Usage: [BUILD_CONFIG: Debug/Release/...]
	exit /b 2
	
:error
	echo Build config doesn't exist!
	exit /b 2