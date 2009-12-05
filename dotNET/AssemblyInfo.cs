using System.Reflection;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;

[assembly: AssemblyTitle("PHPRPC 3.0.2")]
#if PocketPC || Smartphone || WindowsCE
[assembly: AssemblyDescription("PHPRPC 3.0.2 for .NET Compact Framework")]
[assembly: AssemblyProduct("PHPRPC 3.0.2 for .NET Compact Framework")]
#else
#if Mono
[assembly: AssemblyDescription("PHPRPC 3.0.2 for Mono")]
[assembly: AssemblyProduct("PHPRPC 3.0.2 for Mono")]
#else
[assembly: AssemblyDescription("PHPRPC 3.0.2 for .NET Framework")]
[assembly: AssemblyProduct("PHPRPC 3.0.2 for .NET Framework")]
#endif
#endif
[assembly: AssemblyConfiguration("")]
[assembly: AssemblyCompany("phprpc.org")]
[assembly: AssemblyCopyright("phprpc.org")]
[assembly: AssemblyTrademark("phprpc.org")]
[assembly: AssemblyCulture("")]

[assembly: AssemblyVersion("3.0.2.21100")]
