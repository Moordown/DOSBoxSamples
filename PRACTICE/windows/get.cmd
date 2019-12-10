@ml64 /nologo /c /Fl%1.lst /Fo%1.obj %1.asm
@echo Link %1.exe
@link /subsystem:console /defaultlib:f:\test\kernel32.lib /section:.text,rwe /nologo /LARGEADDRESSAWARE:NO /entry:_start %1.obj