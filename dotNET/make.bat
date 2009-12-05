@echo off

set SL_PATH=C:\Program Files\Microsoft SDKs\Silverlight\v2.0\Reference Assemblies
set CF_PATH=C:\Program Files\Microsoft.NET\SDK\CompactFramework
if DEFINED ProgramFiles(x86) set SL_PATH=C:\Program Files (x86)\Microsoft SDKs\Silverlight\v2.0\Reference Assemblies
if DEFINED ProgramFiles(x86) set CF_PATH=C:\Program Files (x86)\Microsoft.NET\SDK\CompactFramework

set DHPARAMS_RESOURCE=
set DHPARAMS_RESOURCE=%DHPARAMS_RESOURCE% -resource:dhparams\96.dhp
set DHPARAMS_RESOURCE=%DHPARAMS_RESOURCE% -resource:dhparams\128.dhp
set DHPARAMS_RESOURCE=%DHPARAMS_RESOURCE% -resource:dhparams\160.dhp
set DHPARAMS_RESOURCE=%DHPARAMS_RESOURCE% -resource:dhparams\192.dhp
set DHPARAMS_RESOURCE=%DHPARAMS_RESOURCE% -resource:dhparams\256.dhp
set DHPARAMS_RESOURCE=%DHPARAMS_RESOURCE% -resource:dhparams\512.dhp
set DHPARAMS_RESOURCE=%DHPARAMS_RESOURCE% -resource:dhparams\768.dhp
set DHPARAMS_RESOURCE=%DHPARAMS_RESOURCE% -resource:dhparams\1024.dhp
set DHPARAMS_RESOURCE=%DHPARAMS_RESOURCE% -resource:dhparams\1536.dhp
set DHPARAMS_RESOURCE=%DHPARAMS_RESOURCE% -resource:dhparams\2048.dhp
set DHPARAMS_RESOURCE=%DHPARAMS_RESOURCE% -resource:dhparams\3072.dhp
set DHPARAMS_RESOURCE=%DHPARAMS_RESOURCE% -resource:dhparams\4096.dhp

set PHPRPC_SRC=
set PHPRPC_SRC=%PHPRPC_SRC% ArrayList.cs
set PHPRPC_SRC=%PHPRPC_SRC% AssocArray.cs
set PHPRPC_SRC=%PHPRPC_SRC% BigInteger.cs
set PHPRPC_SRC=%PHPRPC_SRC% DHParams.cs
set PHPRPC_SRC=%PHPRPC_SRC% DynamicProxy.cs
set PHPRPC_SRC=%PHPRPC_SRC% Hashtable.cs
set PHPRPC_SRC=%PHPRPC_SRC% ISerializable.cs
set PHPRPC_SRC=%PHPRPC_SRC% MD5.cs
set PHPRPC_SRC=%PHPRPC_SRC% PHPConvert.cs
set PHPRPC_SRC=%PHPRPC_SRC% PHPFormatter.cs
set PHPRPC_SRC=%PHPRPC_SRC% PHPReader.cs
set PHPRPC_SRC=%PHPRPC_SRC% PHPRPC_Callback.cs
set PHPRPC_SRC=%PHPRPC_SRC% PHPRPC_Client.cs
set PHPRPC_SRC=%PHPRPC_SRC% PHPRPC_Error.cs
set PHPRPC_SRC=%PHPRPC_SRC% PHPRPC_InvocationHandler.cs
set PHPRPC_SRC=%PHPRPC_SRC% PHPRPC_Server.cs
set PHPRPC_SRC=%PHPRPC_SRC% PHPSerializationTag.cs
set PHPRPC_SRC=%PHPRPC_SRC% PHPWriter.cs
set PHPRPC_SRC=%PHPRPC_SRC% Serializable.cs
set PHPRPC_SRC=%PHPRPC_SRC% SerializableAttribute.cs
set PHPRPC_SRC=%PHPRPC_SRC% SerializationException.cs
set PHPRPC_SRC=%PHPRPC_SRC% XXTEA.cs
set PHPRPC_SRC=%PHPRPC_SRC% AssemblyInfo.cs

C:\WINDOWS\Microsoft.NET\Framework\v1.0.3705\Csc.exe -out:bin\1.0\org.phprpc.dll -define:NET1 -filealign:512 -target:library -optimize+ -debug- %DHPARAMS_RESOURCE% %PHPRPC_SRC%

C:\WINDOWS\Microsoft.NET\Framework\v1.0.3705\Csc.exe -out:bin\1.0\org.phprpc.client.dll -define:NET1;ClientOnly -filealign:512 -target:library -optimize+ -debug- %PHPRPC_SRC%

c:\WINDOWS\Microsoft.NET\Framework\v1.1.4322\Csc.exe -out:bin\1.1\org.phprpc.dll -define:NET1; -filealign:512 -target:library -optimize+ -debug- %DHPARAMS_RESOURCE% %PHPRPC_SRC%

c:\WINDOWS\Microsoft.NET\Framework\v1.1.4322\Csc.exe -out:bin\1.1\org.phprpc.client.dll -define:NET1;ClientOnly -filealign:512 -target:library -optimize+ -debug- %PHPRPC_SRC%

c:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\Csc.exe -out:bin\2.0\org.phprpc.dll -filealign:512 -target:library -optimize+ -debug- %DHPARAMS_RESOURCE% %PHPRPC_SRC%

c:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\Csc.exe -out:bin\2.0\org.phprpc.client.dll -define:ClientOnly -filealign:512 -target:library -optimize+ -debug- %PHPRPC_SRC%

C:\WINDOWS\Microsoft.NET\Framework\v3.5\Csc.exe -out:bin\3.5\org.phprpc.dll -filealign:512 -target:library -optimize+ -debug- %DHPARAMS_RESOURCE% %PHPRPC_SRC%

C:\WINDOWS\Microsoft.NET\Framework\v3.5\Csc.exe -out:bin\3.5\org.phprpc.client.dll -define:ClientOnly -filealign:512 -target:library -optimize+ -debug- %PHPRPC_SRC%

set SL_REFERENCE=
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL_PATH%\mscorlib.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL_PATH%\System.Core.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL_PATH%\system.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL_PATH%\System.Net.dll"

C:\WINDOWS\Microsoft.NET\Framework\v3.5\Csc.exe -out:bin\SilverLight2\org.phprpc.client.dll -define:ClientOnly;SILVERLIGHT -filealign:512 -target:library -optimize+ -debug- -noconfig -nowarn:0444,1701,1702 -nostdlib+ %SL_REFERENCE% %PHPRPC_SRC%

set CF_REFERENCE=
set CF_REFERENCE=%CF_REFERENCE% -reference:"%CF_PATH%\v1.0\WindowsCE\mscorlib.dll"
set CF_REFERENCE=%CF_REFERENCE% -reference:"%CF_PATH%\v1.0\WindowsCE\System.dll"

c:\WINDOWS\Microsoft.NET\Framework\v1.1.4322\Csc.exe -out:bin\CF1.0\org.phprpc.client.dll -define:Smartphone;NETCF1 -noconfig -nostdlib -filealign:512 -target:library -optimize+ -debug- %CF_REFERENCE% %PHPRPC_SRC%

set CF_REFERENCE=
set CF_REFERENCE=%CF_REFERENCE% -reference:"%CF_PATH%\v2.0\WindowsCE\mscorlib.dll"
set CF_REFERENCE=%CF_REFERENCE% -reference:"%CF_PATH%\v2.0\WindowsCE\System.dll"

C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\Csc.exe -out:bin\CF2.0\org.phprpc.client.dll -define:Smartphone;NETCF20 -noconfig -nostdlib -filealign:512 -target:library -optimize+ -debug- %CF_REFERENCE% %PHPRPC_SRC%

set CF_REFERENCE=
set CF_REFERENCE=%CF_REFERENCE% -reference:"%CF_PATH%\v3.5\WindowsCE\mscorlib.dll"
set CF_REFERENCE=%CF_REFERENCE% -reference:"%CF_PATH%\v3.5\WindowsCE\System.dll"

C:\WINDOWS\Microsoft.NET\Framework\v3.5\Csc.exe -out:bin\CF3.5\org.phprpc.client.dll -define:Smartphone;NETCF35 -noconfig -nostdlib -filealign:512 -target:library -optimize+ -debug- %CF_REFERENCE% %PHPRPC_SRC%

call mcs -out:bin\Mono\org.phprpc.dll -define:Mono;NET1 -noconfig -target:library -optimize+ -debug- -reference:System,System.Web,Mono.Security %DHPARAMS_RESOURCE% %PHPRPC_SRC%

call mcs -out:bin\Mono\org.phprpc.client.dll -define:Mono;NET1;ClientOnly -noconfig -target:library -optimize+ -debug- -reference:System,System.Web,Mono.Security %PHPRPC_SRC%

call gmcs -out:bin\Mono2\org.phprpc.dll -define:Mono -noconfig -target:library -optimize+ -debug- -reference:System,System.Web,Mono.Security %DHPARAMS_RESOURCE% %PHPRPC_SRC%

call gmcs -out:bin\Mono2\org.phprpc.client.dll -define:Mono;ClientOnly -noconfig -target:library -optimize+ -debug- -reference:System,System.Web,Mono.Security %PHPRPC_SRC%

set DHPARAMS_RESOURCE=
set PHPRPC_SRC=
set SL_REFERENCE=
set SL_PATH=
set CF_REFERENCE=
set CF_PATH=