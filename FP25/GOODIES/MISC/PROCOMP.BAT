@echo off
REM   PROCOMP.BAT
REM
REM   Usage:
REM
REM      procomp template
REM
REM        - or -
REM
REM	 procomp /s template
REM
if %1x == x goto noarg
fls %1 %2 >$files.lst
fox procomp
erase $files.lst
goto alldone
:noarg
echo 
echo Usage:    procomp filetemplate
echo 
:alldone
