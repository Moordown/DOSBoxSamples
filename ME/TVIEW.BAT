: +++keyword+++ "@(#)%v %n, %f, %w"
: "@(#)3 TVIEW.BAT, 6-Nov-91,9:59:56, LDH"
@echo off
: Use the following line when using TLIB V5.00
tlib c "track n" p %1 b %tmp%\%2 > nul
: Use this line for TLIB V4.12?
: tlib p %1 b %tmp%\%2 > nul
cmpr %tmp%\%2 %3 %4 > nul
attrib -r %tmp%\%2 > nul
del %tmp%\%2 > nul
