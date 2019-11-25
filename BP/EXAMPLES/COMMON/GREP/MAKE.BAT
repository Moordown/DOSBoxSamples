echo off

rem *************************************************
rem *						    *
rem *  Grep/C DLL demos                             *
rem *  Copyright (c) 1992 by Borland International  *
rem *						    *
rem *************************************************

rem --- Make REGEXP.DLL --------------------------------------------
if exist regexp.dll goto dllmade
cd dll
make
if errorlevel 1 goto error
copy regexp.dll ..
cd ..
:dllmade

rem --- Make TVGREP.EXE --------------------------------------------
cd tv
bpc -cp -m -u..;\bp\examples\dos\tvdemo tvgrep
if errorlevel 1 goto error
copy tvgrep.exe ..
cd ..

rem --- Make OWLGREP.EXE -------------------------------------------
cd owl
brc -r owlgrep.rc
if errorlevel 1 goto error
bpc -cw -m -u.. owlgrep
if errorlevel 1 goto error
copy owlgrep.exe ..
cd ..

:error
