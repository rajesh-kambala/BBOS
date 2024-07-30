<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PCGLibrary.asp" -->

<%

if (eWare.Mode < Edit) {
	eWare.Mode = Edit;
}

// If a valid Id is present, display the page.
var lId = pcg_GetId("priv_InvestigationId");
if (lId != 0) {
   eWare.SetContext("PRInvestigation", lId);

	var sSID = new String(Request.Querystring("SID"));

	var recMain = eWare.CreateRecord("Notes");
	recMain("Note_ForeignTableId") = 137;
	recMain("Note_ForeignId") = lId;

	EntryGroup = eWare.GetBlock("PRNoteBox");
	EntryGroup.Title = "Note";

	context = Request.QueryString("context");

	if (!Defined(context)) {
		context = Request.QueryString("Key0");
	}

	eWare.SetContext("New");

	var cntMain = eWare.GetBlock("container");
	cntMain.AddBlock(EntryGroup);
	cntMain.AddButton(eWare.Button("Cancel", "cancel.gif", eWare.Url("PRInvestigation/PRInvestigationNote.asp?priv_InvestigationId=" + lId) + "&Key-1=" + iKey_CustomEntity + "&E=PRInvestigation"));

	eWare.AddContent(cntMain.Execute(recMain));

	if (eWare.Mode == Save) {
		Response.Redirect("PRInvestigationNote.asp?J=PRInvestigation/PRInvestigationNote.asp&E=PRInvestigation&" + Request.QueryString);
	} else {
		RefreshTabs = Request.QueryString("RefreshTabs");

		if (RefreshTabs == 'Y') {
			Response.Write(eWare.GetPage('New'));
		} else {
			Response.Write(eWare.GetPage());
		}
	}
}

%>
