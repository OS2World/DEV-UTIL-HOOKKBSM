cls
Echo Installing hookkbsm
Pause Ctrl-C to Abort - Any Other Key Continues

If exist c:\os2\hook  goto  direxists
md c:\os2\hook

:direxists
copy hookkbsm.exe c:\os2\hook\
copy hot-keys.prg c:\os2\hook\
copy hookdlsm.dll c:\os2\dll\

If exist c:\os2\hook\hookkbsm.dat goto rename_old

:next1
copy hookkbsm.dat c:\os2\hook\
copy hot-keys.usr c:\os2\hook\
goto leave

:rename_old
rename c:\os2\hook\hookkbsm.dat hookkbsm.old
rename c:\os2\hook\hot-keys.usr hot-keys.old
goto next1

:leave
Echo Installation Completed

