echo off
ml /c %1.asm
IF errorlevel 1  goto errexit
link386 /PM:PM /ALIGN:4 /BASE:0x10000 /E %1.obj,,,c:\toolkt21\os2lib\os2386.lib;
del *.obj
del *.map
goto leave
:errexit
Echo Compile Error NO Link
:leave
