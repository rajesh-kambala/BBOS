<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PCGLibrary.asp" -->

<%

// If a valid Id is present, display the page.
var lId = pcg_GetId("priv_InvestigationId");
if (lId != 0) {
   eWare.SetContext("PRInvestigation", lId);

	var recMain = eWare.FindRecord("PRInvestigation","priv_InvestigationId=" + lId);

	var sURL = new String(Request.ServerVariables("URL")() + "?" + Request.QueryString);

	// Get the main list
   var lstMain = eWare.GetBlock("PRInvestigationNoteList");
	lstMain.prevURL = sURL;

	// Build the main container
	var cntMain = eWare.GetBlock("container");
	cntMain.AddBlock(lstMain);
	cntMain.AddButton(eWare.Button("New Note", "newtask.gif", eWare.URL("PRInvestigation/PRInvestigationNoteNew.asp?priv_InvestigationId=" + lId) + "&E=PRInvestigation", 'note', 'insert'));
	cntMain.DisplayButton(Button_Default) = false;

	eWare.AddContent(cntMain.Execute("Note_ForeignTableId=137 and Note_ForeignId=" + lId));
}

Response.Write(eWare.GetPage());

%>

<!-- #include file="topcontent.asp" -->
