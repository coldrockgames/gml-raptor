@ECHO OFF

SET FORKSOURCE=gml-raptor

ECHO -
ECHO - Fetching latest from %FORKSOURCE%...
ECHO -
git fetch upstream

ECHO - 
ECHO - Merging %FORKSOURCE%/dev into current branch...
ECHO - 
git merge --no-edit upstream/dev

ECHO -
ECHO - Merge completed. Look for conflicts and resolve them before you continue!
ECHO -

IF [%1]==[] PAUSE
