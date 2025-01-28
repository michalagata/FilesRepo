@echo off
setlocal enabledelayedexpansion

:: Check if the user provided a version parameter
if "%~1"=="" (
    echo Usage: %~nx0 [dotnet_major_version]
    echo Example: %~nx0 6
    exit /b 1
)

set "dotnet_major_version=%~1"
set "locations=C:\Program Files\dotnet C:\Program Files (x86)\dotnet %USERPROFILE%\.dotnet"

echo Searching for all .NET versions matching major version %dotnet_major_version% in known locations...

for %%L in (%locations%) do (
    if exist "%%L" (
        echo Checking location: %%L
        call :DeleteDotnetVersion "%%L"
    ) else (
        echo Skipping non-existent location: %%L
    )
)

echo Operation completed.
exit /b 0

:DeleteDotnetVersion
set "target_folder=%~1"
:: Search for subfolders matching the major version
for /r "%target_folder%\shared" %%D in (.) do (
    if exist "%%D" (
        echo Checking subfolder: %%D
        for /d %%V in ("%%D\%dotnet_major_version%.*") do (
            echo Found matching folder: %%V
            echo Deleting folder %%V...
            rmdir /s /q "%%V" 2>nul
            if errorlevel 1 (
                echo Failed to delete %%V
            ) else (
                echo Successfully deleted %%V
            )
        )
    )
)
exit /b