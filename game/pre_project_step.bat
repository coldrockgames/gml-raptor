@ECHO OFF

ECHO gml-raptor build script started...
REM --- Set this to 0 to disable automatic build numbers
SET AUTOBUILD=0

REM --- If you changed the macros for the extension in your game,
REM --- You need to also supply the correct values here
SET RAPTOR_DEBUG_JSON_EXTENSION=.json
SET RAPTOR_DEBUG_SCRIPTOR_EXTENSION=.scriptor
SET RAPTOR_DEBUG_PARTICLE_EXTENSION=.particle

REM --- If you did not use the installer for the raptor-json-compiler, you have to set your
REM --- path to it manually here - DO NOT USE ANY "QUOTES"!
SET JSON_COMPILER=raptor-json-compiler.exe

REM --- DO NOT MODIFY THE SCRIPT BELOW THIS LINE!
REM ---------------------------------------------
SET VTXT=%~dp0\notes\version\version.txt
SET VJSN=%~dp0\datafiles\version.json

ECHO Updating build number...
IF NOT EXIST %VTXT% GOTO SKIP

for /f "delims== tokens=1,2" %%G in (%VTXT%) do set %%G=%%H
IF [%AUTOBUILD%]==[0] GOTO SKIP_NO_AUTO
SET /A BUILD=BUILD+1
:SKIP_NO_AUTO
ECHO Automatic build numbers are disabled.
(ECHO { "version": "%MAJOR%.%MINOR%.%BUILD%", "major": %MAJOR%, "minor": %MINOR%, "build": %BUILD%}) >%VJSN%
(ECHO MAJOR=%MAJOR%&ECHO MINOR=%MINOR%&ECHO BUILD=%BUILD%) >%VTXT%

IF [%YYconfig%]==[beta] GOTO OPTIONS
IF [%YYconfig%]==[release] GOTO OPTIONS
GOTO COMPILE

:OPTIONS
SET OPT=%~dp0\options
SET NEWVERSION=%MAJOR%.%MINOR%.%BUILD%.0
powershell -Command "(Get-Content %OPT%\html5\options_html5.yy    ) -replace '^\s*\"option_html5_version\".*', '  \"option_html5_version\":\"%NEWVERSION%\",' | Set-Content %OPT%\html5\options_html5.yy    "
powershell -Command "(Get-Content %OPT%\windows\options_windows.yy) -replace '^\s*\"option_windows_version\".*', '  \"option_windows_version\":\"%NEWVERSION%\",' | Set-Content %OPT%\windows\options_windows.yy"
powershell -Command "(Get-Content %OPT%\android\options_android.yy) -replace '^\s*\"option_android_version\".*', '  \"option_android_version\":\"%NEWVERSION%\",' | Set-Content %OPT%\android\options_android.yy"
GOTO COMPILE

:SKIP
ECHO No version.txt found!

:COMPILE
IF [%YYTARGET_runtime%]==[Javascript] GOTO DO_FILE_LIST
GOTO CONFIG_CHECK

:DO_FILE_LIST
ECHO HTML-Target found! Preparing jsfilelist.json...
SET JEXT=%RAPTOR_DEBUG_JSON_EXTENSION%
SET SEXT=%RAPTOR_DEBUG_SCRIPTOR_EXTENSION%
SET PEXT=%RAPTOR_DEBUG_PARTICLE_EXTENSION%

SET FLIST=%YYprojectDir%\datafiles\jsfilelist.json
ECHO { >%FLIST%
ECHO     "files": [ >>%FLIST%
for /f "delims=" %%i in ('dir /s /b /a-d /on "%YYprojectDir%\datafiles\*.txt"')   do @echo "%%i", >>"%FLIST%"
for /f "delims=" %%i in ('dir /s /b /a-d /on "%YYprojectDir%\datafiles\*%JEXT%"') do @echo "%%i", >>"%FLIST%"
for /f "delims=" %%i in ('dir /s /b /a-d /on "%YYprojectDir%\datafiles\*%SEXT%"') do @echo "%%i", >>"%FLIST%"
for /f "delims=" %%i in ('dir /s /b /a-d /on "%YYprojectDir%\datafiles\*%PEXT%"') do @echo "%%i", >>"%FLIST%"
ECHO     ""], >>%FLIST%
ECHO     "directories": [ >>%FLIST%
for /f "delims=" %%i in ('dir /s /b /ad /on "%YYprojectDir%\datafiles\*.*"') do @echo "%%i", >>"%FLIST%"

SET "ESCAPED=%YYprojectDir:\=\\%"
powershell -Command "(Get-Content %FLIST%) -replace '\"%ESCAPED%\\datafiles\\', '        \"' | Set-Content %FLIST%"
powershell -Command "(Get-Content %FLIST%) -replace '\\', '/' | Set-Content %FLIST%"

ECHO     ""] >>%FLIST%
ECHO } >>%FLIST%

:CONFIG_CHECK
IF [%YYconfig%]==[beta] GOTO RUNJX
IF [%YYconfig%]==[release] GOTO RUNJX
GOTO SOURCE_CODE_LOCATION

:RUNJX
REM The json compiler is not part of the raptor free edition
REM goto delete_hot_reload here as hot reloading is a pro feature
GOTO DELETE_HOT_RELOAD
:SOURCE_CODE_LOCATION
REM goto delete_hot_reload here as hot reloading is a pro feature
GOTO DELETE_HOT_RELOAD

:DELETE_HOT_RELOAD
IF EXIST %YYprojectDir%\datafiles\hotreload.json DEL /Q %YYprojectDir%\datafiles\hotreload.json
GOTO END

:END
ECHO gml-raptor build script completed.
