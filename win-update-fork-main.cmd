@ECHO OFF

SET FORKSOURCE=gml-raptor

ECHO -
ECHO - Fetching latest from %FORKSOURCE%...
ECHO -
git fetch upstream

ECHO - 
ECHO - Merging %FORKSOURCE%/main into current branch...
ECHO - 
git merge upstream/main

ECHO -
ECHO - Merge completed. Look for conflicts and resolve them before you continue!
ECHO -

IF [%1]==[] PAUSE
