@ECHO OFF

SET InstallLocation=\\10.200.200.245\share\SOFTWARE\!FREE

IF "%~1" == "" (SET DestJbDir="C:\APPS\") ELSE (SET DestJbDir="%~1")

rem :NoArg
rem SET DestJbDir="C:\APPS\"

rem :ArgExists
echo APPS Path is set to %DestJbDir%

IF NOT EXIST "%InstallLocation%\10.200.200.245\share\SOFTWARE\!FREE%%\" GOTO NoNAS

IF EXIST %TEMP%\SysInternals RMDIR /S /Q %TEMP%\SysInternals
mkdir %TEMP%\SysInternals
copy /V /Y /Z "%InstallLocation%\SysInternalsSuite.zip" %TEMP%\SysInternals\
"c:\Program Files\7-Zip\7z.exe" x -y -sdel %TEMP%\SysInternals\SysInternalsSuite.zip -o%TEMP%\SysInternals
rem %TEMP%\SysInternals\SysInternalsSuite.zip

IF NOT EXIST "%DestJbDir%\" mkdir "%DestJbDir%\"

IF EXIST "%DestJbDir%\SysInternals" del /F /Q /S "%DestJbDir%\SysInternals\*.*"

IF NOT EXIST "%DestJbDir%\SysInternals" mkdir "%DestJbDir%\SysInternals"

xcopy /E /V /H /Y %TEMP%\SysInternals\*.* "%DestJbDir%\SysInternals\"

IF EXIST %TEMP%\SysInternals RMDIR /S /Q %TEMP%\SysInternals

GOTO Finish

:NoNAS
echo NAS seems to be unavailable, cancelling!

:Finish
echo SysInternals Operations finished.