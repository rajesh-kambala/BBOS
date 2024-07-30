<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PCGLibrary.asp" -->

<%

// If a valid Id is present, display the page.
var lId = pcg_GetId("priv_InvestigationId");
if (lId != 0) {
   eWare.SetContext("PRInvestigation", lId);

	// Get the Company and Person Ids for the new document
   var recMain = eWare.FindRecord("PRInvestigation", "priv_InvestigationId=" + lId);
	var lCompId = 43;
	var lPersId = 57;

	var sURL = new String( Request.ServerVariables("URL")() + "?" + Request.QueryString );

	// Get the main list
	var lstMain = eWare.GetBlock("LibraryList");
	lstMain.prevURL = sURL;

	// Build the main container
	var cntMain = eWare.GetBlock("container");
	cntMain.AddBlock(lstMain);
	cntMain.AddButton(eWare.Button("New", "new.gif", eWare.URL(343) + "&Key-1=" + iKey_CustomEntity + "&Key1=" + lCompId + "&Key2=" + lPersId + "&PrevCustomURL=" + lstMain.prevURL + "&E=PRInvestigation"));
	cntMain.DisplayButton(Button_Default) = false;

   eWare.AddContent(cntMain.Execute("libr_PRInvestigationId=" + lId));
}

Response.Write(eWare.GetPage());

%>

<!-- #include file="topcontent.asp" -->
