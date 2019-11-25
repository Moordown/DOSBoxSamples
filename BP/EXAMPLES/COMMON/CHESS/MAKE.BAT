echo off

cd DLL
rc -r lopenlib.rc
if errorlevel 1 goto error
bpc -m -cw -$S-,W- -DDLL chess
if errorlevel 1 goto error
copy chess.dll ..
cd ..

cd OWL
bpc -m -cw -$S- -DDLL -u..\DLL owlchess
if errorlevel 1 goto error
copy owlchess.exe ..
cd ..

cd TV
bpc -m -cp -$S- -DDLL -u..\DLL tvchess
if errorlevel 1 goto error
copy tvchess.exe ..
cd ..

:error
