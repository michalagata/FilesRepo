@ECHO OFF

SET InstallLocation=\\10.200.200.245\share\INSTALL

set mydate=%date:~6,4%-%date:~3,2%-%date:~0,2%

pushd %InstallLocation%
for /f "delims== tokens=1,2" %%G in (Versions.txt) do set %%G=%%H
popd

echo Dotnet updated at: %DOTNET_UPDATED%
echo Current date: %mydate%

echo "Checking existence of required toolset"
IF NOT EXIST "C:\Program Files (x86)\dotnet-core-uninstall\" SET DOTNET_CORE_UNINSTALL="true"

if defined DOTNET_CORE_UNINSTALL (
	echo "Defined DOTNET_CORE_UNINSTALL"
		pushd %InstallLocation%\Tools\
		msiexec /i dotnet-core-uninstall.msi /quiet /qn /norestart
		popd
		timeout 90 > NUL
) else (
echo "dotnet-core-uninstall is already installed, proceeding..."
)

echo "Deleting static vulnerabilities"
rem IF EXIST "" rd /s /q ""
IF EXIST "C:\Program Files\Android\jdk\jdk-8.0.302.8-hotspot\" rd /s /q "C:\Program Files\Android\jdk\jdk-8.0.302.8-hotspot\"
IF EXIST "C:\Program Files\Microsoft\jdk-11.0.12.7-hotspot\" rd /s /q "C:\Program Files\Microsoft\jdk-11.0.12.7-hotspot\"
IF EXIST "C:\Program Files\Microsoft\jdk-11.0.16.101-hotspot\" rd /s /q "C:\Program Files\Microsoft\jdk-11.0.16.101-hotspot\"

echo "Performing registry operations"
IF NOT EXIST "C:\TEMP\" mkdir "C:\TEMP\"
IF NOT EXIST "C:\TEMP\REG\" mkdir "C:\TEMP\REG\"
IF EXIST "C:\TEMP\REG\" copy /V /Y /Z "%InstallLocation%\REG\*.*" "C:\TEMP\REG\"
echo "Appliance of the scripts..."
for %%i in (C:\TEMP\REG\*.reg) do (regedit /s "%%i")
IF EXIST "C:\TEMP\REG\" rmdir /S /Q C:\TEMP\REG\

if defined MAINTAIN_AGENTS (
echo "Stopping agents"
rem startservice, stopservice, pauseservice, resumeservice
wmic service where "name like 'TCBuildAge%%'" call stopservice

timeout 90 > NUL
)

echo "Checking for RECURRENT_DELETIONS..."
if defined RECURRENT_DELETIONS (
	echo "Defined RECURRENT_DELETIONS"
	echo "Recurrent loops for RD"
	for /d %%G in ("C:\Program Files\dotnet\shared\Microsoft.WindowsDesktop.App\3.0.*","C:\Program Files\dotnet\shared\Microsoft.WindowsDesktop.App\6.0.4","C:\Program Files\dotnet\shared\Microsoft.WindowsDesktop.App\3.1.3","C:\Program Files\dotnet\shared\Microsoft.WindowsDesktop.App\5.*","C:\Program Files\dotnet\shared\Microsoft.WindowsDesktop.App\6.0.12","C:\Program Files\dotnet\shared\Microsoft.WindowsDesktop.App\7.0.1","C:\Program Files\dotnet\shared\Microsoft.WindowsDesktop.App\7.0.4") do IF EXIST "%%~G" rd /s /q "%%~G"
	for /d %%G in ("C:\Program Files (x86)\dotnet\shared\Microsoft.WindowsDesktop.App\3.0.*","C:\Program Files (x86)\dotnet\shared\Microsoft.WindowsDesktop.App\6.0.4","C:\Program Files (x86)\dotnet\shared\Microsoft.WindowsDesktop.App\3.1.3","C:\Program Files (x86)\dotnet\shared\Microsoft.WindowsDesktop.App\5.*","C:\Program Files (x86)\dotnet\shared\Microsoft.WindowsDesktop.App\6.0.12","C:\Program Files (x86)\dotnet\shared\Microsoft.WindowsDesktop.App\7.0.1","C:\Program Files (x86)\dotnet\shared\Microsoft.WindowsDesktop.App\7.0.4") do IF EXIST "%%~G" rd /s /q "%%~G"
	for /d %%G in ("C:\Program Files\dotnet\sdk\5.*","C:\Program Files\dotnet\sdk\6.0.202","C:\Program Files\dotnet\sdk\7.0.101") do IF EXIST "%%~G" rd /s /q "%%~G"
	) else (
	echo "Undefined RECURRENT_DELETIONS, proceeding..."
)

echo "Checking for REMOVE_JAVA_LIBS..."
if defined REMOVE_JAVA_LIBS	(
	echo "Defined REMOVE_JAVA_LIBS"
	echo "Deleting recursive vulnerabilities"
	IF EXIST "C:\BUILD\" del /s /f /q C:\BUILD\commons-text-1.9.jar
	IF EXIST "C:\BUILD\" del /s /f /q C:\BUILD\log4j-over-slf4j-1.7.36.jar
	IF EXIST "C:\BUILD\" del /s /f /q C:\BUILD\java.exe
	IF EXIST "C:\BUILD\" del /s /f /q C:\BUILD\log4j-1.2.12.jar
	IF EXIST "C:\BUILD\" del /s /f /q C:\BUILD\log4j-1.2.17.jar
	IF EXIST "C:\Program Files (x86)\Android\android-sdk\cmdline-tools\7.0\lib\external\lint-psi\intellij-core\" del /s /f /q "C:\Program Files (x86)\Android\android-sdk\intellij-core-mvn.jar"
	IF EXIST "C:\Users\builder\.sonar\" del /s /f /q C:\Users\builder\.sonar\commons-text-1.8.jar
	) else (
	echo "Undefined REMOVE_JAVA_LIBS, proceeding..."
)

echo "Checking for JAVA_UPDATED..."
if defined JAVA_UPDATED (
	echo "Defined JAVA_UPDATED"
	if %mydate% LEQ %JAVA_UPDATED% (
		echo "New Java version found, performing update!"
		IF EXIST "C:\Program Files\Microsoft\OpenJDK\" del /F /S /Q "C:\Program Files\Microsoft\OpenJDK\*.*"
		IF EXIST "C:\Program Files\Microsoft\OpenJDK\" xcopy /E /H /C /I /Y  "%InstallLocation%\OpenJDK\*.*" "C:\Program Files\Microsoft\OpenJDK\"
		IF EXIST "C:\APPS\JAVA\" del /F /S /Q "C:\APPS\JAVA\*.*"
		IF EXIST "C:\APPS\JAVA\" xcopy /E /H /C /I /Y  "%InstallLocation%\OpenJDK\*.*" "C:\APPS\JAVA\"
		IF EXIST "%InstallLocation%\TC-CA-Certs\cacerts" copy /V /Y "%InstallLocation%\TC-CA-Certs\cacerts" "C:\APPS\JAVA\lib\security\"
		) else (
		echo "Current Java versions are installed, no need to touch it..."
	)
) else (
		echo "Undefined JAVA_UPDATED, proceeding..."
)

echo "Checking for nuclear removal..."
if defined NUCLEAR_REMOVAL (
	echo "Defined NUCLEAR_REMOVAL"
	rem Remove All
	IF EXIST "C:\Program Files (x86)\dotnet-core-uninstall\" "C:\Program Files (x86)\dotnet-core-uninstall\dotnet-core-uninstall.exe" remove --all --sdk -y --force 
	IF EXIST "C:\Program Files (x86)\dotnet-core-uninstall\" "C:\Program Files (x86)\dotnet-core-uninstall\dotnet-core-uninstall.exe" remove --all --runtime -y --force
	IF EXIST "C:\Program Files (x86)\dotnet-core-uninstall\" "C:\Program Files (x86)\dotnet-core-uninstall\dotnet-core-uninstall.exe" remove --all --aspnet-runtime -y --force
	IF EXIST "C:\Program Files (x86)\dotnet-core-uninstall\" "C:\Program Files (x86)\dotnet-core-uninstall\dotnet-core-uninstall.exe" remove --all --hosting-bundle -y --force
	echo "Reconstructing dotnet"

	echo "6.0"
	pushd %InstallLocation%\DOTNET\6.0\
	if defined DOTNET_BUILD_SERVER (
		echo "Defined DOTNET_BUILD_SERVER, installing full SDK..."
		dotnet-sdk.exe /install /quiet /norestart
		timeout 90 > NUL
		dotnet-hosting.exe /install /quiet /norestart
		) else (
		echo "Undefined DOTNET_BUILD_SERVER, proceeding only with runtimes..."
		dotnet-runtime.exe /install /quiet /norestart
		timeout 90 > NUL
		windowsdesktop-runtime.exe /install /quiet /norestart
		timeout 90 > NUL
		aspnetcore-runtime.exe /install /quiet /norestart
		timeout 90 > NUL
		dotnet-hosting.exe /install /quiet /norestart
		)
popd
timeout 90 > NUL

echo "7.0"
pushd %InstallLocation%\DOTNET\7.0\
	if defined DOTNET_BUILD_SERVER (
	echo "Defined DOTNET_BUILD_SERVER, installing full SDK..."
	dotnet-sdk.exe /install /quiet /norestart
	timeout 90 > NUL
	dotnet-hosting.exe /install /quiet /norestart
	) else (
		echo "Undefined DOTNET_BUILD_SERVER, proceeding only with runtimes..."
		dotnet-runtime.exe /install /quiet /norestart
		timeout 90 > NUL
		windowsdesktop-runtime.exe /install /quiet /norestart
		timeout 90 > NUL
		aspnetcore-runtime.exe /install /quiet /norestart
		timeout 90 > NUL
		dotnet-hosting.exe /install /quiet /norestart
		)
popd
timeout 90 > NUL

echo "8.0"
pushd %InstallLocation%\DOTNET\8.0\
	if defined DOTNET_BUILD_SERVER (
	echo "Defined DOTNET_BUILD_SERVER, installing full SDK..."
	dotnet-sdk.exe /install /quiet /norestart
	timeout 90 > NUL
	dotnet-hosting.exe /install /quiet /norestart
	) else (
		echo "Undefined DOTNET_BUILD_SERVER, proceeding only with runtimes..."
		dotnet-runtime.exe /install /quiet /norestart
		timeout 90 > NUL
		windowsdesktop-runtime.exe /install /quiet /norestart
		timeout 90 > NUL
		aspnetcore-runtime.exe /install /quiet /norestart
		timeout 90 > NUL
		dotnet-hosting.exe /install /quiet /norestart
		)
popd
timeout 90 > NUL
	) else (
	echo "Undefined NUCLEAR_REMOVAL, proceeding..."
			if defined DOTNET_UPDATED (
		echo "Defined DOTNET_UPDATED"
		if %mydate% LEQ %DOTNET_UPDATED% (
		echo "New dotnet versions found, removing current dotnet!"
		IF EXIST "C:\Program Files (x86)\dotnet-core-uninstall\" "C:\Program Files (x86)\dotnet-core-uninstall\dotnet-core-uninstall.exe" remove --all --sdk -y --force 
		IF EXIST "C:\Program Files (x86)\dotnet-core-uninstall\" "C:\Program Files (x86)\dotnet-core-uninstall\dotnet-core-uninstall.exe" remove --all --runtime -y --force
		IF EXIST "C:\Program Files (x86)\dotnet-core-uninstall\" "C:\Program Files (x86)\dotnet-core-uninstall\dotnet-core-uninstall.exe" remove --all --aspnet-runtime -y --force
		IF EXIST "C:\Program Files (x86)\dotnet-core-uninstall\" "C:\Program Files (x86)\dotnet-core-uninstall\dotnet-core-uninstall.exe" remove --all --hosting-bundle -y --force
		echo "Reconstructing dotnet"

		echo "6.0"
		pushd %InstallLocation%\DOTNET\6.0\
		if defined DOTNET_BUILD_SERVER (
			echo "Defined DOTNET_BUILD_SERVER, installing full SDK..."
			dotnet-sdk.exe /install /quiet /norestart
			timeout 90 > NUL
			dotnet-hosting.exe /install /quiet /norestart
			) else (
			echo "Undefined DOTNET_BUILD_SERVER, proceeding only with runtimes..."
			dotnet-runtime.exe /install /quiet /norestart
			timeout 90 > NUL
			windowsdesktop-runtime.exe /install /quiet /norestart
			timeout 90 > NUL
			aspnetcore-runtime.exe /install /quiet /norestart
			timeout 90 > NUL
			dotnet-hosting.exe /install /quiet /norestart
			)
		popd
		timeout 90 > NUL

		echo "7.0"
		pushd %InstallLocation%\DOTNET\7.0\
			if defined DOTNET_BUILD_SERVER (
			echo "Defined DOTNET_BUILD_SERVER, installing full SDK..."
			dotnet-sdk.exe /install /quiet /norestart
			timeout 90 > NUL
			dotnet-hosting.exe /install /quiet /norestart
			) else (
				echo "Undefined DOTNET_BUILD_SERVER, proceeding only with runtimes..."
				dotnet-runtime.exe /install /quiet /norestart
				timeout 90 > NUL
				windowsdesktop-runtime.exe /install /quiet /norestart
				timeout 90 > NUL
				aspnetcore-runtime.exe /install /quiet /norestart
				timeout 90 > NUL
				dotnet-hosting.exe /install /quiet /norestart
				)
		popd
		timeout 90 > NUL

		echo "8.0"
		pushd %InstallLocation%\DOTNET\8.0\
			if defined DOTNET_BUILD_SERVER (
			echo "Defined DOTNET_BUILD_SERVER, installing full SDK..."
			dotnet-sdk.exe /install /quiet /norestart
			timeout 90 > NUL
			dotnet-hosting.exe /install /quiet /norestart
			) else (
				echo "Undefined DOTNET_BUILD_SERVER, proceeding only with runtimes..."
				dotnet-runtime.exe /install /quiet /norestart
				timeout 90 > NUL
				windowsdesktop-runtime.exe /install /quiet /norestart
				timeout 90 > NUL
				aspnetcore-runtime.exe /install /quiet /norestart
				timeout 90 > NUL
				dotnet-hosting.exe /install /quiet /norestart
				)
		popd
		timeout 90 > NUL
			) else (
			echo "Current dotnet versions are installed, no need to touch it..."
			)
		) else (
		echo "Undefined DOTNET_UPDATED, proceeding..."
		)
)

timeout 90 > NUL

if defined MAINTAIN_AGENTS (
echo "Starting agents"
wmic service where "name like 'TCBuildAge%%'" call startservice
)

echo "Checking for NUCLEAR_RESTART due to optionally required restart..."
if defined NUCLEAR_RESTART (
	echo "Defined NUCLEAR_RESTART - will perform restart now!"
	shutdown -r -t 0
	) else (
echo "Undefined NUCLEAR_RESTART, ending now!"
)