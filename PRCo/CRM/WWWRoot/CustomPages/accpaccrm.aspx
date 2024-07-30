	// This is the ACCPAC CRM standard include file for asp.net based asp pages
	// using the ACCPAC CRM business object.

	// Pages expire right away
	Response.Expires=-1;

	// ACCPAC CRM mode constants

	final int View=0;
	final int Edit=1;
	final int Save=2;
	final int PreDelete=3;
	final int PostDelete=4;
	final int Clear=6;

	// ACCPAC CRM button position constants
	final int  Bottom=0;
	final int Left=1;
	final int Right=2;
	final int Top=3;

	// ACCPAC CRM caption location constants
	final int CapDefault=0;
	final int CapTop=1;
	final int CapLeft=2;
	final int CapLeftAligned=3;
	final int CapRight=4;
	final int CapRightAligned=5;
	final int CapLeftAlignedRight=6;
	
	// determine is this is a wap page
	string Accept = Request.ServerVariables("HTTP_ACCEPT"));
	int IsWap=(Accept.indexOf("wml")!=-1);

	final string Button_Default="1";
	final string Button_Delete="2";
	final string Button_Continue="4";

    final int iKey_CustomEntity = 58;

	// create and initialise the ACCPAC CRM object

    string sInstallName = getInstallName(Request.ServerVariables("URL"));
    string ClassName = "eWare."+sInstallName;

	object CRM = eWare = Server.CreateObject(ClassName);
	eMsg = CRM.Init(
		Request.Querystring,
		Request.Form,
		Request.ServerVariables("HTTPS"),
		Request.ServerVariables("SERVER_NAME"),
		false,
		Request.ServerVariables("HTTP_USER_AGENT"),
		Accept);
		
	// check for errors
		
	if (eMsg!="")
	{
		Response.Write(eMsg);
		Response.End;
	}
	
	// start the page

	var Head,Body,EndBody;
	
	if (IsWap)
	{
		Response.ContentType = "text/vnd.wap.wml";
		Head="<?xml version=\"1.0\"?><!DOCTYPE wml PUBLIC \"-//WAPFORUM//DTD WML 1.1//EN\" \"http://www.wapforum.org/DTD/wml_1.1.xml\"><wml>";
		Body="<card id=\"s\">";
		EndBody="</card></wml>";
	}
	else
	{
		Head="<HTML><HEAD><LINK REL=\"stylesheet\" HREF=\"/"+sInstallName+"/eware.css\"><META http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">";
		Body="<BODY>";
		EndBody="</BODY></HTML>";
	}
	
	// this function is quite useful
	
	function Defined(Arg)
	{
		return (Arg+""!="undefined");
	}

	function getInstallName(sPath) {
		//Parse the install name out of the path
		var Path = new String(sPath);
		var InstallName = '';
		var iEndChar=0;iStartChar=0;

		Path = Path.toLowerCase();
		iEndChar = Path.indexOf('/custompages');
		if (iEndChar != -1) {
			//find the first '/' before this
			iStartChar = Path.substr(0,iEndChar).lastIndexOf('/');
			iStartChar++
			InstallName = Path.substring(iStartChar,iEndChar); 
		}
		return InstallName;

	}


</script>
