<%@ CodePage=65001 Language=JavaScript%>
<%

	// This is the eWare standard include file for javascript based asp pages
	// using the eWare business object.

	// This file should be included on the first line of your asp file.

	// Please consult the eWare documentation for more information.
	
	// Pages expire right away

	Response.Expires=-1;

	// eWare mode constants

	var View=0, Edit=1, Save=2, PreDelete=3, PostDelete=4, Clear=6;

	// eWare button position constants

	var Bottom=0, Left=1, Right=2, Top=3;

	// eWare caption location constants

	var CapDefault=0, CapTop=1, CapLeft=2, CapLeftAligned=3, CapRight=4, CapRightAligned=5, CapLeftAlignedRight=6;
	
	// determine is this is a wap page
	
	var Accept=new String(Request.ServerVariables("HTTP_ACCEPT"));
	var IsWap=(Accept.indexOf("wml")!=-1);

	var Button_Default="1", Button_Delete="2", Button_Continue="4";

        var iKey_CustomEntity = 58;

	// create and initialise the eWare object

        var sInstallName = getInstallName(Request.ServerVariables("URL"));
        var ClassName = "eWare."+sInstallName;
         
	eWare = Server.CreateObject(ClassName);
	eMsg = eWare.Init(
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

	var Body,EndBody;
	
	if (IsWap)
	{
		Response.ContentType = "text/vnd.wap.wml";
		Response.Write("<?xml version=\"1.0\"?><!DOCTYPE wml PUBLIC \"-//WAPFORUM//DTD WML 1.1//EN\" \"http://www.wapforum.org/DTD/wml_1.1.xml\"><wml>");
		Body="<card id=\"s\">";
		EndBody="</card></wml>";
	}
	else
	{
		Response.Write("<HTML><HEAD><LINK REL=\"stylesheet\" HREF=\"/"+sInstallName+"/eware.css\"><META http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">");
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



%>

