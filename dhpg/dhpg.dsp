# Microsoft Developer Studio Project File - Name="dhpg" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

CFG=dhpg - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "dhpg.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "dhpg.mak" CFG="dhpg - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "dhpg - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "dhpg - Win32 Debug" (based on "Win32 (x86) Console Application")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "dhpg - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /c
# ADD CPP /nologo /W3 /GX /O2 /I "big_int/include" /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /c
# ADD BASE RSC /l 0x804 /d "NDEBUG"
# ADD RSC /l 0x804 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib  kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib  kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386

!ELSEIF  "$(CFG)" == "dhpg - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /GZ  /c
# ADD CPP /nologo /W3 /Gm /GX /ZI /Od /I "big_int/include" /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /GZ /c
# ADD BASE RSC /l 0x804 /d "_DEBUG"
# ADD RSC /l 0x804 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib  kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib  kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386 /pdbtype:sept

!ENDIF 

# Begin Target

# Name "dhpg - Win32 Release"
# Name "dhpg - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=.\big_int\src\low_level_funcs\add.c
# End Source File
# Begin Source File

SOURCE=.\big_int\src\low_level_funcs\and.c
# End Source File
# Begin Source File

SOURCE=.\big_int\src\low_level_funcs\andnot.c
# End Source File
# Begin Source File

SOURCE=.\big_int\src\basic_funcs.c
# End Source File
# Begin Source File

SOURCE=.\big_int\src\bitset_funcs.c
# End Source File
# Begin Source File

SOURCE=.\big_int\src\low_level_funcs\cmp.c
# End Source File
# Begin Source File

SOURCE=.\dhpg.c
# End Source File
# Begin Source File

SOURCE=.\big_int\src\low_level_funcs\div.c
# End Source File
# Begin Source File

SOURCE=.\big_int\src\memory_manager.c
# End Source File
# Begin Source File

SOURCE=.\big_int\src\modular_arithmetic.c
# End Source File
# Begin Source File

SOURCE=.\big_int\src\low_level_funcs\mul.c
# End Source File
# Begin Source File

SOURCE=.\big_int\src\number_theory.c
# End Source File
# Begin Source File

SOURCE=.\big_int\src\low_level_funcs\or.c
# End Source File
# Begin Source File

SOURCE=.\big_int\src\service_funcs.c
# End Source File
# Begin Source File

SOURCE=.\big_int\src\sha1.c
# End Source File
# Begin Source File

SOURCE=.\big_int\src\low_level_funcs\sqr.c
# End Source File
# Begin Source File

SOURCE=.\big_int\src\str_funcs.c
# End Source File
# Begin Source File

SOURCE=.\big_int\src\low_level_funcs\sub.c
# End Source File
# Begin Source File

SOURCE=.\big_int\src\low_level_funcs\xor.c
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=.\big_int\include\basic_funcs.h
# End Source File
# Begin Source File

SOURCE=.\big_int\include\big_int.h
# End Source File
# Begin Source File

SOURCE=.\big_int\include\big_int_full.h
# End Source File
# Begin Source File

SOURCE=.\big_int\include\bitset_funcs.h
# End Source File
# Begin Source File

SOURCE=.\big_int\include\get_bit_length.h
# End Source File
# Begin Source File

SOURCE=.\big_int\include\low_level_funcs.h
# End Source File
# Begin Source File

SOURCE=.\big_int\include\memory_manager.h
# End Source File
# Begin Source File

SOURCE=.\big_int\include\modular_arithmetic.h
# End Source File
# Begin Source File

SOURCE=.\big_int\include\number_theory.h
# End Source File
# Begin Source File

SOURCE=.\big_int\include\service_funcs.h
# End Source File
# Begin Source File

SOURCE=.\big_int\include\sha1.h
# End Source File
# Begin Source File

SOURCE=.\big_int\include\str_funcs.h
# End Source File
# Begin Source File

SOURCE=.\big_int\include\str_types.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# End Group
# End Target
# End Project
