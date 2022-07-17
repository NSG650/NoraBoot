cl /c t.c
link /OUT:"loader.sys" /INCREMENTAL:NO /NOLOGO /MANIFEST:NO /NODEFAULTLIB /MAP:"loader.map" /SUBSYSTEM:NATIVE /DRIVER /OPT:REF /OPT:ICF /ENTRY:"_start" /BASE:"0x100000" /FIXED:No /ERRORREPORT:PROMPT t.obj
xcopy .\loader.sys ..\