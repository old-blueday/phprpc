@echo off
set WTK_PATH=E:\GreenSoft\WTK2.5.2
md tempclasses
javac -g:none -source 1.2 -target 1.2 -bootclasspath %WTK_PATH%\lib\cldcapi11.jar;%WTK_PATH%\lib\midpapi10.jar;%WTK_PATH%\lib\satsa-crypto.jar -d tempclasses org\phprpc\*.java org\phprpc\util\*.java
%WTK_PATH%\bin\preverify.exe -classpath %WTK_PATH%\lib\cldcapi11.jar;%WTK_PATH%\lib\midpapi10.jar;%WTK_PATH%\lib\satsa-crypto.jar -target CLDC1.1 -d classes tempclasses
jar cfm dist\PHPRPC_for_J2ME.jar manifest -C classes .
rd /S /Q tempclasses
rd /S /Q classes