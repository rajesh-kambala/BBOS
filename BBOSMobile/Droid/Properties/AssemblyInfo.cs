using System.Reflection;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;
using Android.App;

// Information about this assembly is defined by the following attributes.
// Change them to the values specific to your project.

[assembly: AssemblyTitle ("BBOSMobile.Droid")]
[assembly: AssemblyDescription ("")]
[assembly: AssemblyConfiguration ("")]
[assembly: AssemblyCompany ("")]
[assembly: AssemblyProduct ("")]
[assembly: AssemblyCopyright ("derrickwiller")]
[assembly: AssemblyTrademark ("")]
[assembly: AssemblyCulture ("")]
[assembly: ComVisible(false)]
[assembly: Application(UsesCleartextTraffic = true)]

// The assembly version has the format "{Major}.{Minor}.{Build}.{Revision}".
// The form "{Major}.{Minor}.*" will automatically update the build and revision,
// and "{Major}.{Minor}.{Build}.*" will update just the revision.

[assembly: AssemblyVersion ("1.0.0")]
// Add some common permissions, these can be removed if not needed
[assembly: UsesPermission(Android.Manifest.Permission.Internet)]
[assembly: UsesPermission(Android.Manifest.Permission.WriteExternalStorage)]

//#if DEBUG
//[assembly: Application(Debuggable=true)]
//#else
//[assembly: Application(Debuggable=false)]
//#endif

// The following attributes are used to specify the signing key for the assembly,
// if desired. See the Mono documentation for more information about signing.

//[assembly: AssemblyDelaySign(false)]
//[assembly: AssemblyKeyFile("")]

