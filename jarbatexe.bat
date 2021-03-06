@echo off
REM this script converts jar files to executable x64 files. For windows
REM main code here
REM --------------

REM parse command line arguments
set jarfile=""
set exefile=""
set ui=gui
set icon=""
:readArgs
if not "%1"=="" (
    if "%1"=="-help" (
	echo Usage:	jarbatexe.bat -in ^<path_to_jar^> -out ^<path_to_exe^> [options]
	echo   where options include
	echo 	-headless		use this if your application does not have a GUI. Attention: it's not possible to make an exe file that works with command line parameters!
	echo 	-icon ^<path_to_icon^>	set the icon of the generated executable ^(only .ico files^)
	exit /b
    )
    if "%1"=="-in" (
        set jarfile="%2"
        shift
    )
    if "%1"=="-out" (
        set exefile="%2"
        shift
    )
    if "%1"=="-headless" (
        set ui=console
        shift
    )
    if "%1"=="-icon" (
        set icon=%2
        shift
    )
    shift
    goto :readArgs
)
REM check if all mandatory arguments were passed
REM 	echo %jarfile%
REM 	echo %exefile%
REM 	echo %headless%
REM 	echo %icon%
if %jarfile%=="" goto error
if %exefile%=="" goto error
goto run
REM -- if one of those arguments is missing:
:error
echo error: mandatory options: '-in ^<path_to_jar^>', '-out ^<path_to_exe^>'
goto end
REM -- else:
REM begin the 'conversion'
:run
REM ---------- START OF ACTUAL CONVERSION ------------

REM get Java Version Tag as String to remove it from the module list output
call :getJavaVersionTag
REM 	echo %JavaVersionTag%

REM get list of needed modules, passing the JavaVersionTag because he has to be removed from those module names in the list
REM (valid module names needed by jlink have to not contain those version tags)
call :getModuleList %JavaVersionTag%
REM 	echo '%ModuleList%'

REM based on those modules, generate a custom Java Runtime Environment (jre)
if exist bundle @RD /S /Q bundle
mkdir bundle
jlink --no-header-files --no-man-pages --compress=2 --add-modules %ModuleList% --output bundle\jre

REM use Launch4j to generate an exe file that calls the generated jre to execute the jar packed within itsself
REM first get the xml code for the launch4j configuration file and write it to launch4j_config.xml
call :writeLaunch4jConfig
REM then use it
launch4jc.exe launch4j_config.xml
REM then delete it
del launch4j_config.xml

REM use warp-packer to generate an exe file containing the generated jre and the generated exe
REM this file unpacks itsself when its started and then runs the extracted exe file (generated by launch4j) using our custom jre
warp-packer -a windows-x64 -i bundle -e app.exe -o %exefile%

REM conversion done. remove the needed temporary directory
@RD /S /Q bundle


REM if the user wants to, set an icon for the generated exe
set iconWithoutQuotes=%icon:"=%
if not "%iconWithoutQuotes%"=="" (
	ResourceHacker -open %exefile% -save %exefile% -action addskip -res %icon% -mask ICONGROUP,MAINICON,
)

REM end of script
:end
exit /b
REM -------------

REM --------------------------------------------------------------
REM to keep the script clean, all used functions are declared here
REM function to extract the java version tag as string from the output of the 'java -version' command
:getJavaVersionTag
	SetLocal
	java -version > java_version.txt 2>&1
	set /p jv= < java_version.txt
	del java_version.txt
	set jv=%jv:_=#%
	set jv=%jv:"=_%
	for /f "tokens=2 delims=_" %%a in ("%jv%") do (
		set jv=%%a
	)
	EndLocal & set "JavaVersionTag=%jv%"
	exit /b

REM function to extract all needed java module names into a list
:getModuleList
	java -p %jarfile% --list-modules> modules.txt 
	head --lines=-1 modules.txt > modules1.txt
	REM all those java version tags inside the list, these are not valid module names
	SetLocal EnableDelayedExpansion
	set "line="
	for /F "delims=" %%a in (modules1.txt) do (
		set oldline=%%a
		set "line=!line!,!oldline!"
	)
	echo !line:~1!>modules1.txt
	set "line="
	for /F "delims=" %%a in (modules1.txt) do (
		set oldline=%%a
		set "line=!oldline:@%~1=!"
	)
	REM these files are not needed anymore
	del modules.txt
	del modules1.txt
	EndLocal & set "ModuleList=%line%"
	exit /b

REM function to get the xml code needed for the Launch4j configuration file
:writeLaunch4jConfig
	set jarfileWithoutQuotes=%jarfile:"=%
	SetLocal EnableDelayedExpansion
	set configStr=^<?xml version="1.0" encoding="UTF-8"?^>^<launch4jConfig^>  ^<dontWrapJar^>false^</dontWrapJar^>  ^<headerType^>%ui%^</headerType^>  ^<jar^>%~dp0%jarfileWithoutQuotes%^</jar^>  ^<outfile^>%~dp0bundle\app.exe^</outfile^>  ^<errTitle^>^</errTitle^>  ^<cmdLine^>^</cmdLine^>  ^<chdir^>.^</chdir^>  ^<priority^>normal^</priority^>  ^<downloadUrl^>http://java.com/download^</downloadUrl^>  ^<supportUrl^>^</supportUrl^>  ^<stayAlive^>false^</stayAlive^>  ^<restartOnCrash^>false^</restartOnCrash^>  ^<manifest^>^</manifest^>  ^<jre^>    ^<path^>jre^</path^>    ^<bundledJre64Bit^>false^</bundledJre64Bit^>    ^<bundledJreAsFallback^>false^</bundledJreAsFallback^>    ^<minVersion^>^</minVersion^>    ^<maxVersion^>^</maxVersion^>    ^<jdkPreference^>preferJre^</jdkPreference^>    ^<runtimeBits^>64/32^</runtimeBits^>  ^</jre^>  ^<messages^>    ^<startupErr^>An error occurred while starting the application.^</startupErr^>    ^<bundledJreErr^>This application was configured to use a bundled Java Runtime Environment but the runtime is missing or corrupted.^</bundledJreErr^>    ^<jreVersionErr^>This application requires a Java Runtime Environment^</jreVersionErr^>    ^<launcherErr^>The registry refers to a nonexistent Java Runtime Environment installation or the runtime is corrupted.^</launcherErr^>    ^<instanceAlreadyExistsMsg^>An application instance is of NQueensFaf is already running.^</instanceAlreadyExistsMsg^>  ^</messages^>^</launch4jConfig^>
	echo !configStr! > launch4j_config.xml
	EndLocal
	exit /b