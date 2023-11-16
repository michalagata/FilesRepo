@ECHO OFF

SET InstallLocation=<SHARE>

IF "%~1" == "" (SET DestJbDir="C:\APPS\") ELSE (SET DestJbDir="%~1")

rem :NoArg
rem SET DestJbDir="C:\APPS\"

rem :ArgExists
echo APPS Path is set to %DestJbDir%

IF NOT EXIST "%InstallLocation%\" GOTO NoNAS

IF EXIST %TEMP%\JBTools RMDIR /S /Q %TEMP%\JBTools
mkdir %TEMP%\JBTools

IF EXIST %TEMP%\JBTools\Extracted RMDIR /S /Q %TEMP%\JBTools\Extracted
mkdir %TEMP%\JBTools\Extracted

pushd "%InstallLocation%\"

FOR /F "eol=| delims=" %%I IN ('DIR "*.zip" /A-D /B /O-D /TW 2^>nul') DO SET "NewestFile=%%I" & GOTO FoundFile

ECHO No *.zip file found!
GOTO :EOF

:FoundFile
ECHO Newest *.zip file is: "%NewestFile%"

copy /V /Y /Z "%InstallLocation%\%NewestFile%" "%TEMP%\JBTools\"


ren %TEMP%\JBTools\JetBrains.ReSharper.CommandLineTools.*.zip JetBrains.ReSharper.CommandLineTools.zip

"c:\Program Files\7-Zip\7z.exe" x -y -sdel %TEMP%\JBTools\JetBrains.ReSharper.CommandLineTools.zip -o%TEMP%\JBTools\Extracted

IF NOT EXIST "%DestJbDir%" mkdir "%DestJbDir%"

IF EXIST "%DestJbDir%\JBTools" del /F /Q /S "%DestJbDir%\JBTools\*.*"

IF NOT EXIST "%DestJbDir%\JBTools" mkdir "%DestJbDir%\JBTools"

xcopy /E /V /H /Y %TEMP%\JBTools\Extracted\*.* "%DestJbDir%\JBTools\"

:EOF

popd
IF EXIST %TEMP%\JBTools RMDIR /S /Q %TEMP%\JBTools
IF EXIST %TEMP%\JBTools RMDIR /S /Q %TEMP%\JBTools\Extracted
GOTO Finish

:NoNAS
echo NAS seems to be unavailable, cancelling!

:Finish
echo JBTools Operations finished.
