@ECHO OFF

REM --- If you changed the macros for the extension in your game,
REM --- You need to also supply the correct values here
SET RAPTOR_DEBUG_JSON_EXTENSION=.json
SET RAPTOR_DEBUG_SCRIPTOR_EXTENSION=.scriptor
SET RAPTOR_DEBUG_PARTICLE_EXTENSION=.particle
SET RAPTOR_RELEASE_JSON_EXTENSION=.jx
SET RAPTOR_RELEASE_SCRIPTOR_EXTENSION=.scx
SET RAPTOR_RELEASE_PARTICLE_EXTENSION=.ptx

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
SET /A BUILD=BUILD+1
(ECHO { "version": "%MAJOR%.%MINOR%.%BUILD%", "major": %MAJOR%, "minor": %MINOR%, "build": %BUILD%}) >%VJSN%
(ECHO MAJOR=%MAJOR%&ECHO MINOR=%MINOR%&ECHO BUILD=%BUILD%) >%VTXT%

IF [%YYconfig%]==[beta] GOTO OPTIONS
IF [%YYconfig%]==[release] GOTO OPTIONS
GOTO COMPILE

:OPTIONS
SET OPT=%~dp0\options
frep %OPT%\html5\options_html5.yy """option_html5_version""" "  ""option_html5_version"":""%MAJOR%.%MINOR%.%BUILD%.0""," -l
frep %OPT%\windows\options_windows.yy """option_windows_version""" "  ""option_windows_version"":""%MAJOR%.%MINOR%.%BUILD%.0""," -l
frep %OPT%\android\options_android.yy """option_android_version""" "  ""option_android_version"":""%MAJOR%.%MINOR%.%BUILD%.0""," -l
GOTO COMPILE

:SKIP
ECHO No version.txt found!

:COMPILE
IF [%YYTARGET_runtime%]==[Javascript] GOTO DO_FILE_LIST
GOTO CONFIG_CHECK

:DO_FILE_LIST
SET JEXT=%RAPTOR_DEBUG_JSON_EXTENSION%
SET SEXT=%RAPTOR_DEBUG_SCRIPTOR_EXTENSION%
SET PEXT=%RAPTOR_DEBUG_PARTICLE_EXTENSION%
IF [%YYconfig%]==[beta] SET JEXT=%RAPTOR_RELEASE_JSON_EXTENSION%
IF [%YYconfig%]==[beta] SET SEXT=%RAPTOR_RELEASE_SCRIPTOR_EXTENSION%
IF [%YYconfig%]==[beta] SET PEXT=%RAPTOR_RELEASE_PARTICLE_EXTENSION%
IF [%YYconfig%]==[release] SET JEXT=%RAPTOR_RELEASE_JSON_EXTENSION%
IF [%YYconfig%]==[release] SET SEXT=%RAPTOR_RELEASE_SCRIPTOR_EXTENSION%
IF [%YYconfig%]==[release] SET PEXT=%RAPTOR_RELEASE_PARTICLE_EXTENSION%

SET FLIST=%YYprojectDir%\datafiles\jsfilelist.json
ECHO { >%FLIST%
ECHO     "files": [ >>%FLIST%
for /f "delims=" %%i in ('dir /s /b /a-d /on "%YYprojectDir%\datafiles\*.txt"')   do @echo "%%i", >>"%FLIST%"
for /f "delims=" %%i in ('dir /s /b /a-d /on "%YYprojectDir%\datafiles\*%JEXT%"') do @echo "%%i", >>"%FLIST%"
for /f "delims=" %%i in ('dir /s /b /a-d /on "%YYprojectDir%\datafiles\*%SEXT%"') do @echo "%%i", >>"%FLIST%"
for /f "delims=" %%i in ('dir /s /b /a-d /on "%YYprojectDir%\datafiles\*%PEXT%"') do @echo "%%i", >>"%FLIST%"
ECHO     ], >>%FLIST%
ECHO     "directories": [ >>%FLIST%
for /f "delims=" %%i in ('dir /s /b /ad /on "%YYprojectDir%\datafiles\*.*"') do @echo "%%i", >>"%FLIST%"
FREP %FLIST% """%YYprojectDir%\datafiles\\" "        """
FREP %FLIST% "\\" "/"
ECHO     ] >>%FLIST%
ECHO } >>%FLIST%

:CONFIG_CHECK
IF [%YYconfig%]==[beta] GOTO RUNJX
IF [%YYconfig%]==[release] GOTO RUNJX
GOTO END

:RUNJX
ECHO Compiling included files...
%JSON_COMPILER% %~dp0 %YYconfig%
GOTO END

:END
ECHO Buildnumber update completed.