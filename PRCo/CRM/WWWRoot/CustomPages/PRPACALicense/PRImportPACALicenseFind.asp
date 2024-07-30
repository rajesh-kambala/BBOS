<!-- #include file ="..\accpaccrm.js" -->

<%
var sEntityName = "PRImportPACALicense";

/* This cannot be processes as a standard find because the New button will 
   be removed and a import button will be added.
 */
eWare.SetContext("Find");


var sURL=new String( Request.ServerVariables("URL")() + "?" + Request.QueryString );
//Response.Write("URL: " + sURL); 
//Response.Write("<br>Mode: " + eWare.Mode);
searchEntry=eWare.GetBlock(sEntityName + "SearchBox");
searchEntry.Title=eWare.GetTrans("Tabnames","Search");

searchList=eWare.GetBlock(sEntityName + "Grid");
searchContainer=eWare.GetBlock("container");

searchContainer.ButtonTitle="Search";
searchContainer.ButtonImage="Search.gif";

searchContainer.AddBlock(searchEntry);
if( eWare.Mode == Find || eWare.Mode == View)
  searchContainer.AddBlock(searchList);

searchContainer.AddButton(eWare.Button("Clear", "clear.gif", "javascript:document.EntryForm.em.value='6';document.EntryForm.submit();"));
searchContainer.AddButton(eWare.Button("Import", "new.gif", eWare.Url("PRPACALicense/PACAImportFiles.aspx")));

searchContainer.AddButton(eWare.Button("Move License", "componentscript.gif", eWare.Url("PRPACALicense/PRPACALicenseMove.asp")));

searchList.ArgObj=searchEntry;
searchList.prevURL=sURL;
eWare.AddContent(searchContainer.Execute(searchEntry));

Response.Write(eWare.GetPage());

%>
